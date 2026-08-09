// AuthNotifier -- the single source of truth for "is the user logged in"
// (07-RESEARCH.md Pattern 1). Every Phase 7 auth-aware screen (AuthScreen,
// AccountSection, ModeIndicator) watches this one provider; no screen
// duplicates auth-state logic.

import 'dart:async';
import 'dart:convert';

import 'package:co2diet/core/di/auth_providers.dart';
import 'package:co2diet/core/di/legal_providers.dart';
import 'package:co2diet/domain/entities/auth_state.dart';
import 'package:co2diet/domain/services/backend_config.dart';
import 'package:co2diet/domain/services/keycloak_config.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

/// Secure-storage key for the persisted OIDC refresh token.
const kRefreshTokenKey = 'kc_refresh_token';

/// Secure-storage key for the cached authenticated user's email -- read on
/// cold start to optimistically restore [AuthAuthenticated] state before
/// the silent-refresh network call resolves (CONTEXT.md: "no visible
/// loading state").
const kCachedEmailKey = 'kc_cached_email';

/// Thrown by [AuthNotifier.deleteAccount] when the backend's `DELETE
/// {BackendConfig.baseUrl}/me/account` call returns a non-2xx response.
///
/// Mirrors `NetworkException`'s same-file precedent
/// (`food_catalog_repository.dart`, Phase 2).
class AccountDeletionException implements Exception {
  /// Creates an [AccountDeletionException] carrying the failing
  /// [statusCode].
  AccountDeletionException(this.statusCode);

  /// The HTTP status code the backend returned.
  final int statusCode;

  @override
  String toString() => 'AccountDeletionException(statusCode: $statusCode)';
}

/// The single source of truth for "is the user logged in."
///
/// A plain synchronous `Notifier<AuthState>` (not `AsyncNotifier`) --
/// mirrors `OnboardingGateNotifier`'s established precedent -- so `build()`
/// returns an immediate `AuthState` synchronously (CONTEXT.md: "no visible
/// loading state" on cold start / silent refresh), with all async
/// token-refresh work kicked off as a fire-and-forget [_silentRefresh]
/// call from `build()` itself.
///
/// keepAlive: true -- same rationale as `auth_providers.dart`'s
/// secureStorage/appAuth/authHttpClient providers: this is app-lifetime
/// state, read via bare `ref.read`/`ref.watch` from widgets/mutation
/// methods that may outlive their triggering widget (the exact
/// `UnmountedRefException` risk class already documented for
/// `OnboardingGateNotifier`/`mealEntryProvider`).
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  /// The most recently seen ID token, cached in-memory only (never
  /// persisted) so [logout] can pass it as `idTokenHint` to Keycloak's
  /// `endSession` call. `null` until a sign-in/signup/silent-refresh
  /// response has supplied one.
  String? _idToken;

  @override
  AuthState build() {
    unawaited(_silentRefresh());
    return AuthState.unauthenticated();
  }

  /// Reads the stored refresh token and, if present, optimistically
  /// restores [AuthAuthenticated] using the cached email before attempting
  /// a real token exchange against Keycloak.
  ///
  /// Distinguishes a connectivity failure (leaves state untouched -- stays
  /// optimistically authenticated, does not delete the refresh token) from
  /// a genuine `invalid_grant`/revoked-token rejection (clears storage,
  /// sets `AuthUnauthenticated(sessionExpired: true)`) -- CONTEXT.md's
  /// locked "network failure vs. real invalidation" distinction.
  Future<void> _silentRefresh() async {
    final storage = ref.read(secureStorageProvider);
    final refreshToken = await storage.read(key: kRefreshTokenKey);
    if (refreshToken == null) {
      return;
    }

    final cachedEmail = await storage.read(key: kCachedEmailKey);
    if (cachedEmail != null) {
      state = AuthState.authenticated(email: cachedEmail);
    }

    try {
      final response = await ref.read(appAuthProvider).token(
        TokenRequest(
          KeycloakConfig.clientId,
          KeycloakConfig.redirectUrl,
          issuer: KeycloakConfig.issuer,
          refreshToken: refreshToken,
          scopes: KeycloakConfig.scopes,
        ),
      );
      _idToken = response.idToken ?? _idToken;
      final newRefreshToken = response.refreshToken ?? refreshToken;
      await storage.write(key: kRefreshTokenKey, value: newRefreshToken);

      final userInfo = await _fetchUserInfo(
        response.accessToken ?? '',
        fallbackEmail: cachedEmail,
      );
      await storage.write(key: kCachedEmailKey, value: userInfo.email);
      state = AuthState.authenticated(
        email: userInfo.email,
        accessToken: response.accessToken,
      );
    } on FlutterAppAuthPlatformException catch (e) {
      if (_isGenuineInvalidation(e)) {
        await storage.delete(key: kRefreshTokenKey);
        await storage.delete(key: kCachedEmailKey);
        state = AuthState.unauthenticated(sessionExpired: true);
      }
      // Otherwise: looks like a connectivity failure -- stay
      // optimistically authenticated, leave the stored refresh token
      // alone (CONTEXT.md's locked distinction).
    } on Exception catch (_) {
      // Any other thrown exception (timeout, DNS failure, offline) is
      // treated the same as a connectivity failure -- stay optimistic.
    }
  }

  /// `true` when [e] carries an OAuth-spec error code indicating a genuine
  /// server-side rejection (revoked/expired refresh token) rather than a
  /// connectivity problem.
  bool _isGenuineInvalidation(FlutterAppAuthPlatformException e) {
    const invalidationCodes = {
      FlutterAppAuthOAuthError.invalidGrant,
      'invalid_token',
    };
    return invalidationCodes.contains(e.platformErrorDetails.error);
  }

  /// Calls Keycloak's `/userinfo` endpoint for [accessToken], returning the
  /// user's email and whether it's verified.
  ///
  /// Defensive: a `/userinfo` failure must not crash the whole refresh --
  /// falls back to [fallbackEmail] (or a generic `'Account'` label) and
  /// `emailVerified: true` (so a transient `/userinfo` hiccup never
  /// incorrectly blocks an already-established session).
  Future<({String email, bool emailVerified})> _fetchUserInfo(
    String accessToken, {
    String? fallbackEmail,
  }) async {
    final fallback = fallbackEmail ?? 'Account';
    try {
      final response = await ref
          .read(authHttpClientProvider)
          .get(
            Uri.parse(
              '${KeycloakConfig.issuer}/protocol/openid-connect/userinfo',
            ),
            headers: {'Authorization': 'Bearer $accessToken'},
          );
      if (response.statusCode != 200) {
        return (email: fallback, emailVerified: true);
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (
        email: body['email'] as String? ?? fallback,
        emailVerified: body['email_verified'] as bool? ?? true,
      );
    } on Exception catch (_) {
      return (email: fallback, emailVerified: true);
    }
  }

  /// Shared success path for [signIn], [signUp], and [signInWithIdp].
  ///
  /// Persists the refresh token and cached email, and sets
  /// `AuthState.authenticated(...)`, ONLY when the `/userinfo` response's
  /// `email_verified` claim is `true` -- defensively covering
  /// 07-RESEARCH.md Assumption A6's "Keycloak issues tokens anyway with
  /// `email_verified: false`" branch, so CONTEXT.md's "a logged-in account
  /// is always verified" invariant holds either way. When [recordConsent]
  /// is `true` (only ever passed by [signUp]) and the email is verified,
  /// also writes an `account_mode_terms` consent_records entry.
  Future<void> _completeSignIn(
    TokenResponse response, {
    bool recordConsent = false,
  }) async {
    final accessToken = response.accessToken;
    if (accessToken == null) {
      return;
    }

    final userInfo = await _fetchUserInfo(accessToken);
    if (!userInfo.emailVerified) {
      // Defensive client-side gate (07-RESEARCH.md Assumption A6) -- do
      // NOT persist the refresh token, do NOT record consent, and leave
      // state unauthenticated.
      return;
    }

    _idToken = response.idToken ?? _idToken;
    final storage = ref.read(secureStorageProvider);
    final refreshToken = response.refreshToken;
    if (refreshToken != null) {
      await storage.write(key: kRefreshTokenKey, value: refreshToken);
    }
    await storage.write(key: kCachedEmailKey, value: userInfo.email);

    if (recordConsent) {
      await ref
          .read(consentRepositoryProvider)
          .recordConsent(
            policyVersion: await ref
                .read(legalDocumentLoaderProvider)
                .versionOf('terms.md'),
            appVersion: await ref.read(appVersionProvider.future),
            consentsGiven: const ['account_mode_terms'],
          );
    }

    state = AuthState.authenticated(
      email: userInfo.email,
      accessToken: accessToken,
    );
  }

  /// Signs in via Keycloak's hosted login page (system browser, PKCE).
  ///
  /// [loginHint], when provided (the email the user already typed), is
  /// forwarded as the standard OIDC `login_hint` parameter to prefill
  /// Keycloak's hosted login page.
  ///
  /// A cancelled/dismissed browser flow -- or any other exception thrown
  /// by the authorization call -- is caught and swallowed: state stays
  /// exactly as it was before the call (CONTEXT.md: "Backing out of the
  /// system browser returns silently to the auth screen").
  Future<void> signIn({String? loginHint}) async {
    try {
      final response = await ref
          .read(appAuthProvider)
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              KeycloakConfig.clientId,
              KeycloakConfig.redirectUrl,
              issuer: KeycloakConfig.issuer,
              scopes: KeycloakConfig.scopes,
              additionalParameters: loginHint == null
                  ? null
                  : {'login_hint': loginHint},
            ),
          );
      await _completeSignIn(response);
    } on Exception catch (_) {
      // Swallowed -- see doc comment above.
    }
  }

  /// Signs up via Keycloak's hosted registration page (system browser,
  /// PKCE, `prompt=create` -- OAuth "Initiating User Registration"
  /// convention, `[ASSUMED]` supported by the eventual realm).
  ///
  /// [loginHint] behaves as in [signIn]. [recordConsent] defaults to
  /// `true` (a genuine new signup writes an `account_mode_terms`
  /// consent_records row); `CheckEmailScreen`'s "Resend email" action
  /// passes `false` to re-open the same browser flow without writing a
  /// second consent row for what is still the same signup session
  /// (CONTEXT.md's Audit trail decision).
  Future<void> signUp({String? loginHint, bool recordConsent = true}) async {
    try {
      final response = await ref
          .read(appAuthProvider)
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              KeycloakConfig.clientId,
              KeycloakConfig.redirectUrl,
              issuer: KeycloakConfig.issuer,
              scopes: KeycloakConfig.scopes,
              additionalParameters: {
                'prompt': 'create',
                'login_hint': ?loginHint,
              },
            ),
          );
      await _completeSignIn(response, recordConsent: recordConsent);
    } on Exception catch (_) {
      // Swallowed -- see [signIn].
    }
  }

  /// Signs in via a Keycloak-brokered social identity provider
  /// (`kc_idp_hint`), skipping Keycloak's own login page and going
  /// straight to the named IdP's login screen.
  Future<void> signInWithIdp(String idpAlias) async {
    try {
      final response = await ref
          .read(appAuthProvider)
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              KeycloakConfig.clientId,
              KeycloakConfig.redirectUrl,
              issuer: KeycloakConfig.issuer,
              scopes: KeycloakConfig.scopes,
              additionalParameters: {'kc_idp_hint': idpAlias},
            ),
          );
      await _completeSignIn(response);
    } on Exception catch (_) {
      // Swallowed -- see [signIn].
    }
  }

  /// Logs out immediately: clears local state regardless of whether
  /// Keycloak's `endSession` browser round-trip succeeds (CONTEXT.md:
  /// "immediate, no confirmation dialog" -- low-stakes, nothing to lose
  /// since nothing was synced).
  Future<void> logout() async {
    try {
      await ref
          .read(appAuthProvider)
          .endSession(
            EndSessionRequest(
              idTokenHint: _idToken,
              postLogoutRedirectUrl: KeycloakConfig.redirectUrl,
              issuer: KeycloakConfig.issuer,
            ),
          );
    } on Exception catch (_) {
      // Best-effort server-side revocation -- local state clears
      // regardless of this call's outcome.
    }
    _idToken = null;
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: kRefreshTokenKey);
    await storage.delete(key: kCachedEmailKey);
    state = AuthState.unauthenticated();
  }

  /// Deletes the backend account (GDPR / PRIV-05).
  ///
  /// On a 2xx response: clears secure storage, sets
  /// `AuthState.unauthenticated()`, and records an `account_deletion`
  /// consent_records entry. On a non-2xx response: throws
  /// [AccountDeletionException] and leaves state/storage completely
  /// untouched -- the caller (Plan 07-06's AccountSection) catches this to
  /// show an inline error.
  Future<void> deleteAccount() async {
    final current = state;
    final accessToken = current is AuthAuthenticated
        ? current.accessToken
        : null;

    final response = await ref
        .read(authHttpClientProvider)
        .delete(
          Uri.parse('${BackendConfig.baseUrl}/me/account'),
          headers: {
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
        );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AccountDeletionException(response.statusCode);
    }

    _idToken = null;
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: kRefreshTokenKey);
    await storage.delete(key: kCachedEmailKey);
    state = AuthState.unauthenticated();

    await ref
        .read(consentRepositoryProvider)
        .recordConsent(
          policyVersion: await ref
              .read(legalDocumentLoaderProvider)
              .versionOf('terms.md'),
          appVersion: await ref.read(appVersionProvider.future),
          consentsGiven: const ['account_deletion'],
        );
  }

  /// Consumes a one-shot `AuthUnauthenticated(sessionExpired: true)`
  /// state, replacing it with `sessionExpired: false` so the "You've been
  /// signed out" notice never reappears on rebuild.
  void acknowledgeSessionExpired() {
    final current = state;
    if (current is AuthUnauthenticated && current.sessionExpired) {
      state = AuthState.unauthenticated();
    }
  }
}

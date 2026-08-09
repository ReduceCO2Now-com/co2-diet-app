// Real unit tests for AuthNotifier + realmDiscoveryReadyProvider (replaces
// Plan 07-01's Wave 0 stub).
//
// Uses ProviderContainer + mocked FlutterAppAuth/FlutterSecureStorage/
// http.Client/IConsentRepository via mocktail, following the
// ProviderContainer + registerFallbackValue pattern established in
// test/features/weight/weight_notifier_test.dart and
// test/features/legal/legal_consent_screen_test.dart's
// `_FakeLegalDocumentLoader` (avoids a real `rootBundle.loadString`
// platform-channel round trip for `docs/legal/terms.md`).

import 'dart:async';
import 'dart:convert';

import 'package:co2diet/core/di/auth_providers.dart';
import 'package:co2diet/core/di/legal_providers.dart';
import 'package:co2diet/domain/entities/auth_state.dart';
import 'package:co2diet/domain/repositories/i_consent_repository.dart';
import 'package:co2diet/domain/services/keycloak_config.dart';
import 'package:co2diet/domain/services/legal_document_loader.dart';
import 'package:co2diet/features/auth/providers/auth_provider.dart';
import 'package:co2diet/features/auth/providers/realm_discovery_provider.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockAppAuth extends Mock implements FlutterAppAuth {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockHttpClient extends Mock implements http.Client {}

class _MockConsentRepository extends Mock implements IConsentRepository {}

/// Avoids depending on a real `rootBundle.loadString` platform-channel
/// round trip for `docs/legal/terms.md` -- mirrors
/// `legal_consent_screen_test.dart`'s `_FakeLegalDocumentLoader`.
class _FakeLegalDocumentLoader extends LegalDocumentLoader {
  const _FakeLegalDocumentLoader();

  @override
  Future<String> versionOf(String assetFileName) async => 'test-version';
}

AuthorizationTokenResponse _buildAuthResponse({
  String accessToken = 'access-token',
  String? refreshToken = 'new-refresh-token',
  String? idToken = 'id-token',
}) => AuthorizationTokenResponse(
  accessToken,
  refreshToken,
  DateTime.now().add(const Duration(hours: 1)),
  idToken,
  'Bearer',
  KeycloakConfig.scopes,
  null,
  null,
);

TokenResponse _buildTokenResponse({
  String accessToken = 'access-token',
  String? refreshToken = 'new-refresh-token',
  String? idToken = 'id-token',
}) => TokenResponse(
  accessToken,
  refreshToken,
  DateTime.now().add(const Duration(hours: 1)),
  idToken,
  'Bearer',
  KeycloakConfig.scopes,
  null,
);

http.Response _userInfoResponse({
  String email = 'user@example.com',
  bool emailVerified = true,
}) => http.Response(
  jsonEncode({'email': email, 'email_verified': emailVerified}),
  200,
);

void main() {
  late _MockAppAuth mockAppAuth;
  late _MockSecureStorage mockStorage;
  late _MockHttpClient mockHttpClient;
  late _MockConsentRepository mockConsentRepository;

  setUpAll(() {
    registerFallbackValue(
      TokenRequest(
        KeycloakConfig.clientId,
        KeycloakConfig.redirectUrl,
        issuer: KeycloakConfig.issuer,
      ),
    );
    registerFallbackValue(
      AuthorizationTokenRequest(
        KeycloakConfig.clientId,
        KeycloakConfig.redirectUrl,
        issuer: KeycloakConfig.issuer,
      ),
    );
    registerFallbackValue(
      EndSessionRequest(issuer: KeycloakConfig.issuer),
    );
    registerFallbackValue(Uri.parse('http://localhost'));
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    mockAppAuth = _MockAppAuth();
    mockStorage = _MockSecureStorage();
    mockHttpClient = _MockHttpClient();
    mockConsentRepository = _MockConsentRepository();

    // Default: no stored refresh token / cached email -- overridden per
    // test as needed.
    when(
      () => mockStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    when(
      () => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockStorage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});

    when(
      () => mockConsentRepository.recordConsent(
        policyVersion: any(named: 'policyVersion'),
        appVersion: any(named: 'appVersion'),
        consentsGiven: any(named: 'consentsGiven'),
      ),
    ).thenAnswer((_) async {});
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        appAuthProvider.overrideWithValue(mockAppAuth),
        secureStorageProvider.overrideWithValue(mockStorage),
        authHttpClientProvider.overrideWithValue(mockHttpClient),
        consentRepositoryProvider.overrideWithValue(mockConsentRepository),
        appVersionProvider.overrideWith((ref) async => '0.1.0+1'),
        legalDocumentLoaderProvider.overrideWithValue(
          const _FakeLegalDocumentLoader(),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Awaits the first [AuthState] from [authProvider] satisfying
  /// [predicate], starting from whatever the state is right now (fires
  /// immediately, so an already-satisfying state resolves without waiting
  /// for a further rebuild).
  Future<AuthState> waitForState(
    ProviderContainer container,
    bool Function(AuthState) predicate, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<AuthState>();
    final sub = container.listen<AuthState>(authProvider, (prev, next) {
      if (predicate(next) && !completer.isCompleted) {
        completer.complete(next);
      }
    }, fireImmediately: true);

    try {
      return await completer.future.timeout(timeout);
    } finally {
      sub.close();
    }
  }

  group('AuthNotifier', () {
    test(
      'build() returns AuthUnauthenticated with no stored refresh token',
      () async {
        final container = makeContainer();

        final state = await waitForState(
          container,
          (s) => s is AuthUnauthenticated,
        );

        expect(state, isA<AuthUnauthenticated>());
        verifyNever(() => mockAppAuth.token(any()));
      },
    );

    test(
      'build() optimistically returns AuthAuthenticated using a cached '
      'email when a refresh token exists, before the network call '
      'resolves',
      () async {
        when(
          () => mockStorage.read(key: kRefreshTokenKey),
        ).thenAnswer((_) async => 'stored-refresh-token');
        when(
          () => mockStorage.read(key: kCachedEmailKey),
        ).thenAnswer((_) async => 'cached@example.com');

        // Block the token-refresh network call so the optimistic state
        // is observable before it resolves.
        final tokenCompleter = Completer<TokenResponse>();
        when(
          () => mockAppAuth.token(any()),
        ).thenAnswer((_) => tokenCompleter.future);

        final container = makeContainer();

        final optimisticState = await waitForState(
          container,
          (s) => s is AuthAuthenticated,
        );

        expect(optimisticState, isA<AuthAuthenticated>());
        expect(
          (optimisticState as AuthAuthenticated).email,
          'cached@example.com',
        );
        expect(optimisticState.accessToken, isNull);

        tokenCompleter.complete(_buildTokenResponse());
      },
    );

    test(
      'successful silent refresh yields AuthAuthenticated with the '
      'userinfo-resolved email and persists the new refresh token',
      () async {
        when(
          () => mockStorage.read(key: kRefreshTokenKey),
        ).thenAnswer((_) async => 'stored-refresh-token');
        when(
          () => mockStorage.read(key: kCachedEmailKey),
        ).thenAnswer((_) async => 'cached@example.com');
        when(() => mockAppAuth.token(any())).thenAnswer(
          (_) async => _buildTokenResponse(refreshToken: 'rotated-token'),
        );
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer(
          (_) async => _userInfoResponse(email: 'fresh@example.com'),
        );

        final container = makeContainer();

        final state = await waitForState(
          container,
          (s) =>
              s is AuthAuthenticated && s.email == 'fresh@example.com',
        );

        expect(state, isA<AuthAuthenticated>());
        expect((state as AuthAuthenticated).accessToken, 'access-token');
        verify(
          () => mockStorage.write(
            key: kRefreshTokenKey,
            value: 'rotated-token',
          ),
        ).called(1);
        verify(
          () => mockStorage.write(
            key: kCachedEmailKey,
            value: 'fresh@example.com',
          ),
        ).called(1);
      },
    );

    test(
      'a network-failure refresh error keeps state AuthAuthenticated and '
      'does not delete the stored refresh token (CONTEXT.md: network '
      'failure vs. real invalidation)',
      () async {
        when(
          () => mockStorage.read(key: kRefreshTokenKey),
        ).thenAnswer((_) async => 'stored-refresh-token');
        when(
          () => mockStorage.read(key: kCachedEmailKey),
        ).thenAnswer((_) async => 'cached@example.com');
        when(() => mockAppAuth.token(any())).thenThrow(
          FlutterAppAuthPlatformException(
            code: 'network_error',
            platformErrorDetails: FlutterAppAuthPlatformErrorDetails(
              error: 'connection_failed',
            ),
          ),
        );

        final container = makeContainer();

        final state = await waitForState(
          container,
          (s) => s is AuthAuthenticated,
        );

        expect(state, isA<AuthAuthenticated>());
        expect((state as AuthAuthenticated).email, 'cached@example.com');
        verifyNever(() => mockStorage.delete(key: kRefreshTokenKey));
        verifyNever(() => mockStorage.delete(key: kCachedEmailKey));
      },
    );

    test(
      'a genuine invalid_grant/revoked-token refresh error yields '
      'AuthUnauthenticated(sessionExpired: true) and deletes stored '
      'refresh token + cached email',
      () async {
        when(
          () => mockStorage.read(key: kRefreshTokenKey),
        ).thenAnswer((_) async => 'stored-refresh-token');
        when(
          () => mockStorage.read(key: kCachedEmailKey),
        ).thenAnswer((_) async => 'cached@example.com');
        when(() => mockAppAuth.token(any())).thenThrow(
          FlutterAppAuthPlatformException(
            code: 'oauth',
            platformErrorDetails: FlutterAppAuthPlatformErrorDetails(
              error: FlutterAppAuthOAuthError.invalidGrant,
            ),
          ),
        );

        final container = makeContainer();

        final state = await waitForState(
          container,
          (s) => s is AuthUnauthenticated && s.sessionExpired,
        );

        expect(state, isA<AuthUnauthenticated>());
        expect((state as AuthUnauthenticated).sessionExpired, isTrue);
        verify(() => mockStorage.delete(key: kRefreshTokenKey)).called(1);
        verify(() => mockStorage.delete(key: kCachedEmailKey)).called(1);
      },
    );

    test(
      'signIn() calls authorizeAndExchangeCode with no kc_idp_hint/prompt '
      'params',
      () async {
        when(
          () => mockAppAuth.authorizeAndExchangeCode(any()),
        ).thenAnswer((_) async => _buildAuthResponse());
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => _userInfoResponse());

        final container = makeContainer();
        await waitForState(container, (s) => s is AuthUnauthenticated);

        await container.read(authProvider.notifier).signIn();

        final captured = verify(
          () => mockAppAuth.authorizeAndExchangeCode(captureAny()),
        ).captured;
        final request = captured.single as AuthorizationTokenRequest;
        expect(request.additionalParameters, isNull);
      },
    );

    test(
      'signUp() calls authorizeAndExchangeCode with a prompt=create '
      "additionalParameters entry and records an 'account_mode_terms' "
      'consent event on success',
      () async {
        when(
          () => mockAppAuth.authorizeAndExchangeCode(any()),
        ).thenAnswer((_) async => _buildAuthResponse());
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => _userInfoResponse());

        final container = makeContainer();
        await waitForState(container, (s) => s is AuthUnauthenticated);

        await container.read(authProvider.notifier).signUp();

        final captured = verify(
          () => mockAppAuth.authorizeAndExchangeCode(captureAny()),
        ).captured;
        final request = captured.single as AuthorizationTokenRequest;
        expect(request.additionalParameters, {'prompt': 'create'});

        verify(
          () => mockConsentRepository.recordConsent(
            policyVersion: 'test-version',
            appVersion: '0.1.0+1',
            consentsGiven: ['account_mode_terms'],
          ),
        ).called(1);

        final state = container.read(authProvider);
        expect(state, isA<AuthAuthenticated>());
      },
    );

    test(
      'signUp() with an unverified email leaves state '
      'AuthUnauthenticated and does not record consent (07-RESEARCH.md '
      'Assumption A6 defensive branch)',
      () async {
        when(
          () => mockAppAuth.authorizeAndExchangeCode(any()),
        ).thenAnswer((_) async => _buildAuthResponse());
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer(
          (_) async => _userInfoResponse(emailVerified: false),
        );

        final container = makeContainer();
        await waitForState(container, (s) => s is AuthUnauthenticated);

        await container.read(authProvider.notifier).signUp();

        expect(container.read(authProvider), isA<AuthUnauthenticated>());
        verifyNever(
          () => mockConsentRepository.recordConsent(
            policyVersion: any(named: 'policyVersion'),
            appVersion: any(named: 'appVersion'),
            consentsGiven: any(named: 'consentsGiven'),
          ),
        );
        verifyNever(
          () => mockStorage.write(
            key: kRefreshTokenKey,
            value: any(named: 'value'),
          ),
        );
      },
    );

    test(
      'a mocked authorizeAndExchangeCode throwing a login-flow/ '
      'verification-required error is caught the same way as any other '
      'non-cancellation exception, leaving state unchanged',
      () async {
        when(
          () => mockAppAuth.authorizeAndExchangeCode(any()),
        ).thenThrow(Exception('verification_required'));

        final container = makeContainer();
        await waitForState(container, (s) => s is AuthUnauthenticated);

        await container.read(authProvider.notifier).signUp();

        expect(container.read(authProvider), isA<AuthUnauthenticated>());
      },
    );

    test(
      "signInWithIdp('apple') and signInWithIdp('google') pass the "
      'matching kc_idp_hint alias',
      () async {
        when(
          () => mockAppAuth.authorizeAndExchangeCode(any()),
        ).thenAnswer((_) async => _buildAuthResponse());
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => _userInfoResponse());

        final container = makeContainer();
        await waitForState(container, (s) => s is AuthUnauthenticated);

        await container.read(authProvider.notifier).signInWithIdp('apple');
        await container.read(authProvider.notifier).signInWithIdp('google');

        final captured = verify(
          () => mockAppAuth.authorizeAndExchangeCode(captureAny()),
        ).captured;
        expect(captured, hasLength(2));
        expect(
          (captured[0] as AuthorizationTokenRequest).additionalParameters,
          {'kc_idp_hint': 'apple'},
        );
        expect(
          (captured[1] as AuthorizationTokenRequest).additionalParameters,
          {'kc_idp_hint': 'google'},
        );
      },
    );

    test(
      'signIn(loginHint:) and signUp(loginHint:) forward login_hint in '
      'additionalParameters; omitting loginHint produces no login_hint '
      'key',
      () async {
        when(
          () => mockAppAuth.authorizeAndExchangeCode(any()),
        ).thenAnswer((_) async => _buildAuthResponse());
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => _userInfoResponse());

        final container = makeContainer();
        await waitForState(container, (s) => s is AuthUnauthenticated);

        await container
            .read(authProvider.notifier)
            .signIn(loginHint: 'user@example.com');
        await container
            .read(authProvider.notifier)
            .signUp(loginHint: 'user@example.com', recordConsent: false);

        final captured = verify(
          () => mockAppAuth.authorizeAndExchangeCode(captureAny()),
        ).captured;
        expect(captured, hasLength(2));

        final signInRequest = captured[0] as AuthorizationTokenRequest;
        expect(
          signInRequest.additionalParameters,
          {'login_hint': 'user@example.com'},
        );

        final signUpRequest = captured[1] as AuthorizationTokenRequest;
        expect(signUpRequest.additionalParameters, {
          'prompt': 'create',
          'login_hint': 'user@example.com',
        });
      },
    );

    test(
      'a cancelled/dismissed browser flow is caught and swallowed -- '
      'state stays exactly as it was before the call',
      () async {
        when(() => mockAppAuth.authorizeAndExchangeCode(any())).thenThrow(
          FlutterAppAuthUserCancelledException(
            code: 'cancelled',
            platformErrorDetails: FlutterAppAuthPlatformErrorDetails(),
          ),
        );

        final container = makeContainer();
        await waitForState(container, (s) => s is AuthUnauthenticated);

        await container.read(authProvider.notifier).signIn();

        expect(container.read(authProvider), isA<AuthUnauthenticated>());
      },
    );

    test(
      'logout() calls endSession, clears secure storage, and sets '
      'AuthUnauthenticated(sessionExpired: false)',
      () async {
        when(
          () => mockAppAuth.endSession(any()),
        ).thenAnswer((_) async => EndSessionResponse(null));

        final container = makeContainer();
        await waitForState(container, (s) => s is AuthUnauthenticated);

        await container.read(authProvider.notifier).logout();

        final state = container.read(authProvider);
        expect(state, isA<AuthUnauthenticated>());
        expect((state as AuthUnauthenticated).sessionExpired, isFalse);
        verify(() => mockAppAuth.endSession(any())).called(1);
        verify(() => mockStorage.delete(key: kRefreshTokenKey)).called(1);
        verify(() => mockStorage.delete(key: kCachedEmailKey)).called(1);
      },
    );

    test(
      'deleteAccount() on a 2xx response clears secure storage, sets '
      'AuthUnauthenticated, and records an account_deletion consent '
      'event',
      () async {
        when(
          () => mockAppAuth.authorizeAndExchangeCode(any()),
        ).thenAnswer((_) async => _buildAuthResponse());
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => _userInfoResponse());
        when(
          () => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
          ),
        ).thenAnswer((_) async => http.Response('', 204));

        final container = makeContainer();
        await waitForState(container, (s) => s is AuthUnauthenticated);
        await container.read(authProvider.notifier).signIn();
        expect(container.read(authProvider), isA<AuthAuthenticated>());

        await container.read(authProvider.notifier).deleteAccount();

        final state = container.read(authProvider);
        expect(state, isA<AuthUnauthenticated>());
        verify(() => mockStorage.delete(key: kRefreshTokenKey)).called(1);
        verify(() => mockStorage.delete(key: kCachedEmailKey)).called(1);
        verify(
          () => mockConsentRepository.recordConsent(
            policyVersion: 'test-version',
            appVersion: '0.1.0+1',
            consentsGiven: ['account_deletion'],
          ),
        ).called(1);
      },
    );

    test(
      'deleteAccount() on a non-2xx response throws '
      'AccountDeletionException and leaves state/storage untouched',
      () async {
        when(
          () => mockAppAuth.authorizeAndExchangeCode(any()),
        ).thenAnswer((_) async => _buildAuthResponse());
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => _userInfoResponse());
        when(
          () => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
          ),
        ).thenAnswer((_) async => http.Response('error', 500));

        final container = makeContainer();
        await waitForState(container, (s) => s is AuthUnauthenticated);
        await container.read(authProvider.notifier).signIn();
        expect(container.read(authProvider), isA<AuthAuthenticated>());

        await expectLater(
          container.read(authProvider.notifier).deleteAccount(),
          throwsA(isA<AccountDeletionException>()),
        );

        expect(container.read(authProvider), isA<AuthAuthenticated>());
        verifyNever(() => mockStorage.delete(key: kRefreshTokenKey));
        verifyNever(() => mockStorage.delete(key: kCachedEmailKey));
      },
    );
  });

  group('realmDiscoveryReadyProvider', () {
    test('returns true on HTTP 200 from the discovery endpoint', () async {
      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response('{}', 200));

      final container = makeContainer();

      final result = await container.read(realmDiscoveryReadyProvider.future);

      expect(result, isTrue);
    });

    test(
      'returns false on a non-200 response or a thrown exception',
      () async {
        when(
          () => mockHttpClient.get(any()),
        ).thenAnswer((_) async => http.Response('', 503));

        final container = makeContainer();
        final nonOkResult = await container.read(
          realmDiscoveryReadyProvider.future,
        );
        expect(nonOkResult, isFalse);
      },
    );

    test('returns false when the discovery call throws', () async {
      when(() => mockHttpClient.get(any())).thenThrow(Exception('offline'));

      final container = makeContainer();
      final result = await container.read(realmDiscoveryReadyProvider.future);

      expect(result, isFalse);
    });
  });
}

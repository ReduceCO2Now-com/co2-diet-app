// Auth-related DI providers: secureStorage, appAuth, authHttpClient.
//
// Kept in a separate file (mirrors legal_providers.dart) to keep
// providers.dart focused on core infrastructure (AppDatabase, profile).
//
// All three providers are thin wrappers around third-party clients with no
// app-specific logic -- AuthNotifier (Plan 07-03) is where the real OIDC
// flow / secure-storage read-write / backend HTTP calls live.

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

/// Provides the [FlutterSecureStorage] instance used to persist the OIDC
/// refresh token on-device (Keychain on iOS, Keystore-backed
/// EncryptedSharedPreferences on Android).
///
/// keepAlive: true — AuthNotifier (Plan 07-03, itself keepAlive) reads this
/// via bare `ref.read` from mutation methods (login/logout) that may run
/// after their own widget disposes. Non-keepAlive would risk an
/// UnmountedRefException, the same risk class documented for
/// OnboardingGateNotifier/mealEntryProvider precedents ([Phase 04-09]).
@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) => const FlutterSecureStorage();

/// Provides the [FlutterAppAuth] instance used to run the system-browser
/// OIDC + PKCE login flow against Keycloak.
///
/// keepAlive: true — same rationale as [secureStorageProvider]: read from
/// AuthNotifier's mutation methods, which may outlive the widget that
/// triggered them.
@Riverpod(keepAlive: true)
FlutterAppAuth appAuth(Ref ref) => const FlutterAppAuth();

/// Provides the [http.Client] used for direct backend calls (e.g. Plan
/// 07-03's `deleteAccount()` against `BackendConfig.baseUrl`) that don't go
/// through Keycloak's OIDC endpoints.
///
/// keepAlive: true — same rationale as [secureStorageProvider].
/// `ref.onDispose` closes the client cleanly on ProviderScope disposal
/// (mirrors `appDatabaseProvider`'s `ref.onDispose(db.close)` pattern).
@Riverpod(keepAlive: true)
http.Client authHttpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [FlutterSecureStorage] instance used to persist the OIDC
/// refresh token on-device (Keychain on iOS, Keystore-backed EncryptedSharedPreferences
/// on Android).
///
/// keepAlive: true — AuthNotifier (Plan 07-03, itself keepAlive) reads this
/// via bare `ref.read` from mutation methods (login/logout) that may run
/// after their own widget disposes. Non-keepAlive would risk an
/// UnmountedRefException, the same risk class documented for
/// OnboardingGateNotifier/mealEntryProvider precedents ([Phase 04-09]).

@ProviderFor(secureStorage)
final secureStorageProvider = SecureStorageProvider._();

/// Provides the [FlutterSecureStorage] instance used to persist the OIDC
/// refresh token on-device (Keychain on iOS, Keystore-backed EncryptedSharedPreferences
/// on Android).
///
/// keepAlive: true — AuthNotifier (Plan 07-03, itself keepAlive) reads this
/// via bare `ref.read` from mutation methods (login/logout) that may run
/// after their own widget disposes. Non-keepAlive would risk an
/// UnmountedRefException, the same risk class documented for
/// OnboardingGateNotifier/mealEntryProvider precedents ([Phase 04-09]).

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  /// Provides the [FlutterSecureStorage] instance used to persist the OIDC
  /// refresh token on-device (Keychain on iOS, Keystore-backed EncryptedSharedPreferences
  /// on Android).
  ///
  /// keepAlive: true — AuthNotifier (Plan 07-03, itself keepAlive) reads this
  /// via bare `ref.read` from mutation methods (login/logout) that may run
  /// after their own widget disposes. Non-keepAlive would risk an
  /// UnmountedRefException, the same risk class documented for
  /// OnboardingGateNotifier/mealEntryProvider precedents ([Phase 04-09]).
  SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'0cd1b80f91784467390034386f925a0be155bfbd';

/// Provides the [FlutterAppAuth] instance used to run the system-browser
/// OIDC + PKCE login flow against Keycloak.
///
/// keepAlive: true — same rationale as [secureStorageProvider]: read from
/// AuthNotifier's mutation methods, which may outlive the widget that
/// triggered them.

@ProviderFor(appAuth)
final appAuthProvider = AppAuthProvider._();

/// Provides the [FlutterAppAuth] instance used to run the system-browser
/// OIDC + PKCE login flow against Keycloak.
///
/// keepAlive: true — same rationale as [secureStorageProvider]: read from
/// AuthNotifier's mutation methods, which may outlive the widget that
/// triggered them.

final class AppAuthProvider
    extends $FunctionalProvider<FlutterAppAuth, FlutterAppAuth, FlutterAppAuth>
    with $Provider<FlutterAppAuth> {
  /// Provides the [FlutterAppAuth] instance used to run the system-browser
  /// OIDC + PKCE login flow against Keycloak.
  ///
  /// keepAlive: true — same rationale as [secureStorageProvider]: read from
  /// AuthNotifier's mutation methods, which may outlive the widget that
  /// triggered them.
  AppAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appAuthHash();

  @$internal
  @override
  $ProviderElement<FlutterAppAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FlutterAppAuth create(Ref ref) {
    return appAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterAppAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterAppAuth>(value),
    );
  }
}

String _$appAuthHash() => r'83442944f4804b5bb8d8b1fde82a144b16c24a34';

/// Provides the [http.Client] used for direct backend calls (e.g. Plan
/// 07-03's `deleteAccount()` against [BackendConfig.baseUrl]) that don't go
/// through Keycloak's OIDC endpoints.
///
/// keepAlive: true — same rationale as [secureStorageProvider].
/// `ref.onDispose` closes the client cleanly on ProviderScope disposal
/// (mirrors `appDatabaseProvider`'s `ref.onDispose(db.close)` pattern).

@ProviderFor(authHttpClient)
final authHttpClientProvider = AuthHttpClientProvider._();

/// Provides the [http.Client] used for direct backend calls (e.g. Plan
/// 07-03's `deleteAccount()` against [BackendConfig.baseUrl]) that don't go
/// through Keycloak's OIDC endpoints.
///
/// keepAlive: true — same rationale as [secureStorageProvider].
/// `ref.onDispose` closes the client cleanly on ProviderScope disposal
/// (mirrors `appDatabaseProvider`'s `ref.onDispose(db.close)` pattern).

final class AuthHttpClientProvider
    extends $FunctionalProvider<http.Client, http.Client, http.Client>
    with $Provider<http.Client> {
  /// Provides the [http.Client] used for direct backend calls (e.g. Plan
  /// 07-03's `deleteAccount()` against [BackendConfig.baseUrl]) that don't go
  /// through Keycloak's OIDC endpoints.
  ///
  /// keepAlive: true — same rationale as [secureStorageProvider].
  /// `ref.onDispose` closes the client cleanly on ProviderScope disposal
  /// (mirrors `appDatabaseProvider`'s `ref.onDispose(db.close)` pattern).
  AuthHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHttpClientHash();

  @$internal
  @override
  $ProviderElement<http.Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  http.Client create(Ref ref) {
    return authHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(http.Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<http.Client>(value),
    );
  }
}

String _$authHttpClientHash() => r'8807ac835afe88d0cefff30d3da9b48ec4e009b6';

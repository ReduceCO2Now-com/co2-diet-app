// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

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
final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AuthState> {
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
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authNotifierHash() => r'7266c3cc2eadb59d524bd460de1344d3514218dd';

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

abstract class _$AuthNotifier extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

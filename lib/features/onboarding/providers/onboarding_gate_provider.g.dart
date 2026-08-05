// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_gate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the app-wide [SharedPreferences] instance.
///
/// The default implementation throws — this provider MUST be overridden in
/// `main.dart` via `ProviderScope(overrides: [sharedPreferencesProvider
/// .overrideWithValue(prefs)])` after `SharedPreferences.getInstance()`
/// resolves, before `runApp`. Tests override it with
/// `SharedPreferences.setMockInitialValues({})` + a real instance rather
/// than mocking this provider directly.
///
/// keepAlive: true — wraps a genuine app-lifetime singleton resource
/// (mirrors [appDatabaseProvider]'s treatment of [AppDatabase]), not
/// screen-scoped data. Without it, plain `@riverpod`'s autoDispose default
/// tears this down whenever nothing happens to be watching it, which is
/// exactly the condition under which [OnboardingGateNotifier
/// .completeOnboarding] is called (06-10 manual verification found this
/// live: OnboardingCarouselScreen never watches [onboardingGateProvider],
/// so calling `completeOnboarding()` from its "Go to Dashboard" button hit
/// an `UnmountedRefException` mid-`await`, silently swallowing the
/// subsequent `context.go('/dashboard')` and leaving `hasCompletedOnboarding`
/// never durably flipped for the redirect to observe).

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provides the app-wide [SharedPreferences] instance.
///
/// The default implementation throws — this provider MUST be overridden in
/// `main.dart` via `ProviderScope(overrides: [sharedPreferencesProvider
/// .overrideWithValue(prefs)])` after `SharedPreferences.getInstance()`
/// resolves, before `runApp`. Tests override it with
/// `SharedPreferences.setMockInitialValues({})` + a real instance rather
/// than mocking this provider directly.
///
/// keepAlive: true — wraps a genuine app-lifetime singleton resource
/// (mirrors [appDatabaseProvider]'s treatment of [AppDatabase]), not
/// screen-scoped data. Without it, plain `@riverpod`'s autoDispose default
/// tears this down whenever nothing happens to be watching it, which is
/// exactly the condition under which [OnboardingGateNotifier
/// .completeOnboarding] is called (06-10 manual verification found this
/// live: OnboardingCarouselScreen never watches [onboardingGateProvider],
/// so calling `completeOnboarding()` from its "Go to Dashboard" button hit
/// an `UnmountedRefException` mid-`await`, silently swallowing the
/// subsequent `context.go('/dashboard')` and leaving `hasCompletedOnboarding`
/// never durably flipped for the redirect to observe).

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Provides the app-wide [SharedPreferences] instance.
  ///
  /// The default implementation throws — this provider MUST be overridden in
  /// `main.dart` via `ProviderScope(overrides: [sharedPreferencesProvider
  /// .overrideWithValue(prefs)])` after `SharedPreferences.getInstance()`
  /// resolves, before `runApp`. Tests override it with
  /// `SharedPreferences.setMockInitialValues({})` + a real instance rather
  /// than mocking this provider directly.
  ///
  /// keepAlive: true — wraps a genuine app-lifetime singleton resource
  /// (mirrors [appDatabaseProvider]'s treatment of [AppDatabase]), not
  /// screen-scoped data. Without it, plain `@riverpod`'s autoDispose default
  /// tears this down whenever nothing happens to be watching it, which is
  /// exactly the condition under which [OnboardingGateNotifier
  /// .completeOnboarding] is called (06-10 manual verification found this
  /// live: OnboardingCarouselScreen never watches [onboardingGateProvider],
  /// so calling `completeOnboarding()` from its "Go to Dashboard" button hit
  /// an `UnmountedRefException` mid-`await`, silently swallowing the
  /// subsequent `context.go('/dashboard')` and leaving `hasCompletedOnboarding`
  /// never durably flipped for the redirect to observe).
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'bb9e6ef7d3a26ef805262492637387254e4f6936';

/// Tracks whether the user has completed the onboarding flow
/// (Splash → Welcome → Legal Consent → Profile Setup → Carousel).
///
/// A plain synchronous `Notifier<bool>` (not `AsyncNotifier`) since
/// [build] only reads a value out of the already-loaded [SharedPreferences]
/// instance supplied via [sharedPreferencesProvider] — there is no async
/// work to await at construction time.
///
/// Plan 06-09's router redirect watches this provider to gate every route
/// behind onboarding completion (ONBD-01/05). T-06-05-01: this flag is a
/// plain on-device SharedPreferences value and can be tampered with on a
/// rooted/jailbroken device to skip onboarding directly — accepted risk,
/// the router redirect is still the enforced path for normal navigation.
///
/// keepAlive: true — this is app-lifetime gate state read from every
/// top-level navigation via the router's `redirect` callback (a bare
/// `ref.read`, with no active watcher of its own), and mutated from
/// screens (`OnboardingCarouselScreen`) that never watch it either. Plain
/// `@riverpod`'s autoDispose default let this provider get torn down
/// between [completeOnboarding]'s `await` and its `state = true`, throwing
/// `UnmountedRefException` and silently dropping the onboarding-complete
/// signal — found via real-device testing in 06-10 manual verification.

@ProviderFor(OnboardingGateNotifier)
final onboardingGateProvider = OnboardingGateNotifierProvider._();

/// Tracks whether the user has completed the onboarding flow
/// (Splash → Welcome → Legal Consent → Profile Setup → Carousel).
///
/// A plain synchronous `Notifier<bool>` (not `AsyncNotifier`) since
/// [build] only reads a value out of the already-loaded [SharedPreferences]
/// instance supplied via [sharedPreferencesProvider] — there is no async
/// work to await at construction time.
///
/// Plan 06-09's router redirect watches this provider to gate every route
/// behind onboarding completion (ONBD-01/05). T-06-05-01: this flag is a
/// plain on-device SharedPreferences value and can be tampered with on a
/// rooted/jailbroken device to skip onboarding directly — accepted risk,
/// the router redirect is still the enforced path for normal navigation.
///
/// keepAlive: true — this is app-lifetime gate state read from every
/// top-level navigation via the router's `redirect` callback (a bare
/// `ref.read`, with no active watcher of its own), and mutated from
/// screens (`OnboardingCarouselScreen`) that never watch it either. Plain
/// `@riverpod`'s autoDispose default let this provider get torn down
/// between [completeOnboarding]'s `await` and its `state = true`, throwing
/// `UnmountedRefException` and silently dropping the onboarding-complete
/// signal — found via real-device testing in 06-10 manual verification.
final class OnboardingGateNotifierProvider
    extends $NotifierProvider<OnboardingGateNotifier, bool> {
  /// Tracks whether the user has completed the onboarding flow
  /// (Splash → Welcome → Legal Consent → Profile Setup → Carousel).
  ///
  /// A plain synchronous `Notifier<bool>` (not `AsyncNotifier`) since
  /// [build] only reads a value out of the already-loaded [SharedPreferences]
  /// instance supplied via [sharedPreferencesProvider] — there is no async
  /// work to await at construction time.
  ///
  /// Plan 06-09's router redirect watches this provider to gate every route
  /// behind onboarding completion (ONBD-01/05). T-06-05-01: this flag is a
  /// plain on-device SharedPreferences value and can be tampered with on a
  /// rooted/jailbroken device to skip onboarding directly — accepted risk,
  /// the router redirect is still the enforced path for normal navigation.
  ///
  /// keepAlive: true — this is app-lifetime gate state read from every
  /// top-level navigation via the router's `redirect` callback (a bare
  /// `ref.read`, with no active watcher of its own), and mutated from
  /// screens (`OnboardingCarouselScreen`) that never watch it either. Plain
  /// `@riverpod`'s autoDispose default let this provider get torn down
  /// between [completeOnboarding]'s `await` and its `state = true`, throwing
  /// `UnmountedRefException` and silently dropping the onboarding-complete
  /// signal — found via real-device testing in 06-10 manual verification.
  OnboardingGateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingGateNotifierHash();

  @$internal
  @override
  OnboardingGateNotifier create() => OnboardingGateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onboardingGateNotifierHash() =>
    r'0a319e6089b228b83ab30233d3fab6152ca5f226';

/// Tracks whether the user has completed the onboarding flow
/// (Splash → Welcome → Legal Consent → Profile Setup → Carousel).
///
/// A plain synchronous `Notifier<bool>` (not `AsyncNotifier`) since
/// [build] only reads a value out of the already-loaded [SharedPreferences]
/// instance supplied via [sharedPreferencesProvider] — there is no async
/// work to await at construction time.
///
/// Plan 06-09's router redirect watches this provider to gate every route
/// behind onboarding completion (ONBD-01/05). T-06-05-01: this flag is a
/// plain on-device SharedPreferences value and can be tampered with on a
/// rooted/jailbroken device to skip onboarding directly — accepted risk,
/// the router redirect is still the enforced path for normal navigation.
///
/// keepAlive: true — this is app-lifetime gate state read from every
/// top-level navigation via the router's `redirect` callback (a bare
/// `ref.read`, with no active watcher of its own), and mutated from
/// screens (`OnboardingCarouselScreen`) that never watch it either. Plain
/// `@riverpod`'s autoDispose default let this provider get torn down
/// between [completeOnboarding]'s `await` and its `state = true`, throwing
/// `UnmountedRefException` and silently dropping the onboarding-complete
/// signal — found via real-device testing in 06-10 manual verification.

abstract class _$OnboardingGateNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

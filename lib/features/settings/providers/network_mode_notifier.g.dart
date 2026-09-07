// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_mode_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's connectivity choice — see
/// `docs/decisions/0001-connectivity-choice-not-account-mode.md`.
///
/// A plain synchronous `Notifier` mirroring [OnboardingGateNotifier]: the
/// value is read straight out of the already-loaded [sharedPreferences]
/// instance, so there is no async work at construction.
///
/// keepAlive: true — same rationale as the onboarding gate. This is
/// app-lifetime state read from the data layer through [NetworkPolicy] (a
/// bare read, with no widget watching it) and mutated from a Settings row
/// that does not watch it either. Under plain `@riverpod`'s autoDispose
/// default that combination is exactly what silently dropped the onboarding
/// completion signal in 06-10.

@ProviderFor(NetworkModeNotifier)
final networkModeProvider = NetworkModeNotifierProvider._();

/// The user's connectivity choice — see
/// `docs/decisions/0001-connectivity-choice-not-account-mode.md`.
///
/// A plain synchronous `Notifier` mirroring [OnboardingGateNotifier]: the
/// value is read straight out of the already-loaded [sharedPreferences]
/// instance, so there is no async work at construction.
///
/// keepAlive: true — same rationale as the onboarding gate. This is
/// app-lifetime state read from the data layer through [NetworkPolicy] (a
/// bare read, with no widget watching it) and mutated from a Settings row
/// that does not watch it either. Under plain `@riverpod`'s autoDispose
/// default that combination is exactly what silently dropped the onboarding
/// completion signal in 06-10.
final class NetworkModeNotifierProvider
    extends $NotifierProvider<NetworkModeNotifier, NetworkMode> {
  /// The user's connectivity choice — see
  /// `docs/decisions/0001-connectivity-choice-not-account-mode.md`.
  ///
  /// A plain synchronous `Notifier` mirroring [OnboardingGateNotifier]: the
  /// value is read straight out of the already-loaded [sharedPreferences]
  /// instance, so there is no async work at construction.
  ///
  /// keepAlive: true — same rationale as the onboarding gate. This is
  /// app-lifetime state read from the data layer through [NetworkPolicy] (a
  /// bare read, with no widget watching it) and mutated from a Settings row
  /// that does not watch it either. Under plain `@riverpod`'s autoDispose
  /// default that combination is exactly what silently dropped the onboarding
  /// completion signal in 06-10.
  NetworkModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkModeNotifierHash();

  @$internal
  @override
  NetworkModeNotifier create() => NetworkModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkMode>(value),
    );
  }
}

String _$networkModeNotifierHash() =>
    r'5aaa768c3775346064a926e7b34091a009a12e2a';

/// The user's connectivity choice — see
/// `docs/decisions/0001-connectivity-choice-not-account-mode.md`.
///
/// A plain synchronous `Notifier` mirroring [OnboardingGateNotifier]: the
/// value is read straight out of the already-loaded [sharedPreferences]
/// instance, so there is no async work at construction.
///
/// keepAlive: true — same rationale as the onboarding gate. This is
/// app-lifetime state read from the data layer through [NetworkPolicy] (a
/// bare read, with no widget watching it) and mutated from a Settings row
/// that does not watch it either. Under plain `@riverpod`'s autoDispose
/// default that combination is exactly what silently dropped the onboarding
/// completion signal in 06-10.

abstract class _$NetworkModeNotifier extends $Notifier<NetworkMode> {
  NetworkMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NetworkMode, NetworkMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NetworkMode, NetworkMode>,
              NetworkMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provides the [NetworkPolicy] the data layer depends on.

@ProviderFor(networkPolicy)
final networkPolicyProvider = NetworkPolicyProvider._();

/// Provides the [NetworkPolicy] the data layer depends on.

final class NetworkPolicyProvider
    extends $FunctionalProvider<NetworkPolicy, NetworkPolicy, NetworkPolicy>
    with $Provider<NetworkPolicy> {
  /// Provides the [NetworkPolicy] the data layer depends on.
  NetworkPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkPolicyHash();

  @$internal
  @override
  $ProviderElement<NetworkPolicy> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NetworkPolicy create(Ref ref) {
    return networkPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkPolicy>(value),
    );
  }
}

String _$networkPolicyHash() => r'8853b6927a9762512d4bece79bc3837c8d103873';

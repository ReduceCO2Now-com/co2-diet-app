import 'package:co2diet/domain/entities/network_mode.dart';
import 'package:co2diet/domain/services/network_policy.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_mode_notifier.g.dart';

/// SharedPreferences key backing [NetworkModeNotifier].
const kNetworkModeKey = 'networkMode';

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
@Riverpod(keepAlive: true)
class NetworkModeNotifier extends _$NetworkModeNotifier {
  @override
  NetworkMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return NetworkMode.fromStorage(prefs.getString(kNetworkModeKey));
  }

  /// Persists [mode] and updates state, so a caller can read the new value
  /// immediately after this resolves without waiting for a rebuild.
  Future<void> setMode(NetworkMode mode) async {
    await ref.read(sharedPreferencesProvider).setString(
      kNetworkModeKey,
      mode.name,
    );
    state = mode;
  }
}

/// Adapts [networkModeProvider] to the domain's [NetworkPolicy] port.
///
/// Holds the reader rather than a snapshot so a mid-session change in
/// Settings takes effect on the very next lookup.
class RiverpodNetworkPolicy implements NetworkPolicy {
  /// Creates a policy that reads the current mode via [readMode].
  const RiverpodNetworkPolicy(this.readMode);

  /// Returns the currently selected mode.
  final NetworkMode Function() readMode;

  @override
  bool get allowsRemoteLookups => readMode().allowsRemoteLookups;
}

/// Provides the [NetworkPolicy] the data layer depends on.
@Riverpod(keepAlive: true)
NetworkPolicy networkPolicy(Ref ref) =>
    RiverpodNetworkPolicy(() => ref.read(networkModeProvider));

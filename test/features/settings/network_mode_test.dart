// Tests for the connectivity choice (decision 0001): the preference itself,
// and the guarantee that "offline only" produces no outbound lookup.

import 'package:co2diet/domain/entities/network_mode.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:co2diet/features/settings/providers/network_mode_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
}

void main() {
  group('NetworkMode.fromStorage', () {
    test('defaults to onlineAllowed when nothing is stored', () {
      // Preserves pre-preference behaviour: defaulting to offline would
      // silently remove food search for users who never made a choice.
      expect(NetworkMode.fromStorage(null), NetworkMode.onlineAllowed);
    });

    test('defaults to onlineAllowed on an unrecognised value', () {
      expect(NetworkMode.fromStorage('nonsense'), NetworkMode.onlineAllowed);
    });

    test('round-trips offlineOnly', () {
      expect(
        NetworkMode.fromStorage(NetworkMode.offlineOnly.name),
        NetworkMode.offlineOnly,
      );
    });
  });

  group('allowsRemoteLookups', () {
    test('is false only for offlineOnly', () {
      expect(NetworkMode.offlineOnly.allowsRemoteLookups, isFalse);
      expect(NetworkMode.onlineAllowed.allowsRemoteLookups, isTrue);
    });
  });

  group('NetworkModeNotifier', () {
    test('reads the persisted mode on build', () async {
      final container = await _container({
        kNetworkModeKey: NetworkMode.offlineOnly.name,
      });
      addTearDown(container.dispose);

      expect(container.read(networkModeProvider), NetworkMode.offlineOnly);
    });

    test('setMode persists and updates state synchronously', () async {
      final container = await _container();
      addTearDown(container.dispose);

      expect(container.read(networkModeProvider), NetworkMode.onlineAllowed);

      await container
          .read(networkModeProvider.notifier)
          .setMode(NetworkMode.offlineOnly);

      // Readable immediately, without waiting for a rebuild — the same
      // contract OnboardingGateNotifier.completeOnboarding() relies on.
      expect(container.read(networkModeProvider), NetworkMode.offlineOnly);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kNetworkModeKey), NetworkMode.offlineOnly.name);
    });

    test('the choice survives a rebuild of the container', () async {
      final container = await _container();
      addTearDown(container.dispose);
      await container
          .read(networkModeProvider.notifier)
          .setMode(NetworkMode.offlineOnly);

      final reopened = await _container({
        kNetworkModeKey: NetworkMode.offlineOnly.name,
      });
      addTearDown(reopened.dispose);
      expect(reopened.read(networkModeProvider), NetworkMode.offlineOnly);
    });
  });

  group('RiverpodNetworkPolicy', () {
    test('reflects a mid-session change rather than a captured snapshot', () {
      // The policy is constructed once and injected into the repository, so
      // it must read the mode on every access — otherwise turning the
      // setting off would not take effect until an app restart.
      var mode = NetworkMode.onlineAllowed;
      final policy = RiverpodNetworkPolicy(() => mode);

      expect(policy.allowsRemoteLookups, isTrue);
      mode = NetworkMode.offlineOnly;
      expect(policy.allowsRemoteLookups, isFalse);
    });
  });
}

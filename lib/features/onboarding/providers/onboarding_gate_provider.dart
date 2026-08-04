import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_gate_provider.g.dart';

/// Provides the app-wide [SharedPreferences] instance.
///
/// The default implementation throws — this provider MUST be overridden in
/// `main.dart` via `ProviderScope(overrides: [sharedPreferencesProvider
/// .overrideWithValue(prefs)])` after `SharedPreferences.getInstance()`
/// resolves, before `runApp`. Tests override it with
/// `SharedPreferences.setMockInitialValues({})` + a real instance rather
/// than mocking this provider directly.
@riverpod
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('overridden in main.dart via ProviderScope');

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
@riverpod
class OnboardingGateNotifier extends _$OnboardingGateNotifier {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool('hasCompletedOnboarding') ??
      false;

  /// Persists onboarding completion to disk and updates state synchronously
  /// so callers can `ref.read` the new value immediately after this
  /// resolves, without waiting for a separate rebuild.
  Future<void> completeOnboarding() async {
    await ref.read(sharedPreferencesProvider).setBool(
      'hasCompletedOnboarding',
      true,
    );
    state = true;
  }
}

import 'package:co2diet/core/di/co2_settings_providers.dart';
import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'co2_settings_notifier.g.dart';

/// AsyncNotifier that loads and saves the user's CO2 Calculation Settings
/// (CO2-03).
///
/// Mirrors `ProfileNotifier`'s exact shape (per RESEARCH.md: "same pattern
/// as ProfileScreen/ProfileNotifier"). This settings layer is strictly
/// separate from any food's own CO2 data — [saveSettings] never rewrites
/// or recalculates already-logged meal entries.
///
/// Anti-patterns avoided:
///   - Does NOT import package:drift or AppDatabase.
///   - Does NOT use AutoDisposeRef (Riverpod 3.x uses unified Ref).
///   - Does NOT use StateNotifierProvider.
@riverpod
class Co2SettingsNotifier extends _$Co2SettingsNotifier {
  @override
  Future<Co2Settings> build() {
    return ref.watch(co2SettingsRepositoryProvider).getSettings();
  }

  /// Persists [settings] to storage and re-runs build() so the notifier
  /// reflects the freshly saved state.
  ///
  /// Deliberately does NOT set `state = AsyncValue.loading()` before the
  /// write -- this method fires on every keystroke via this screen's
  /// auto-save `onChanged`. Forcing a loading state here made the screen's
  /// `.when(loading: ...)` branch swap the entire body out for a spinner
  /// on every keystroke, which is what caused intermittent focus/keyboard
  /// loss even after the per-field `ValueKey` fix (see `ProfileNotifier
  /// .saveProfile`'s identical fix/explanation). Mirrors `WeightNotifier`'s
  /// save methods, which never transition through an explicit loading
  /// state for the same reason.
  Future<void> saveSettings(Co2Settings settings) async {
    state = await AsyncValue.guard(() async {
      await ref.read(co2SettingsRepositoryProvider).saveSettings(settings);
      return settings;
    });
    ref.invalidateSelf();
  }
}

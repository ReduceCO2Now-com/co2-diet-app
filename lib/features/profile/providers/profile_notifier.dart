import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/domain/entities/user_profile.dart';
import 'package:co2diet/domain/services/target_calculator.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_notifier.g.dart';

/// AsyncNotifier that loads the user profile and attaches computed
/// `CalcTargets` via [TargetCalculator.derive] on each build().
///
/// UI consumers: watch this provider to receive a [UserProfile?] with
/// targets pre-computed. Call [saveProfile] or [updateField] to persist
/// changes; the notifier re-runs build() after each save.
///
/// Anti-patterns avoided:
///   - Does NOT import package:drift or AppDatabase.
///   - Does NOT use AutoDisposeRef (Riverpod 3.x uses unified Ref).
///   - Does NOT use StateNotifierProvider.
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<UserProfile?> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    final profile = await repo.getProfile();
    if (profile == null) return null;

    // Attach computed targets — TargetCalculator.derive handles missing fields
    // by returning a CalcTargets with all-null values (shown as '—' in UI).
    final targets = TargetCalculator.derive(
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      age: profile.age,
      gender: profile.gender,
      activityLevel: profile.activityLevel,
      goal: profile.goal,
      existingTargets: profile.targets,
    );
    return profile.copyWith(targets: targets);
  }

  /// Persists [profile] to storage and re-runs build() to recompute targets.
  ///
  /// Deliberately does NOT set `state = AsyncValue.loading()` before the
  /// write (unlike a typical explicit-submit save flow): this method is
  /// called from `ProfileForm`'s auto-save `onChanged` on every single
  /// keystroke. Forcing a loading state here made `ProfileScreen`'s
  /// `.when(loading: ...)` branch swap the entire body out for a spinner
  /// on every keystroke -- tearing down and rebuilding the whole
  /// `ProfileForm` (not just one field) regardless of any per-field key
  /// fix, which is what caused the intermittent (timing-dependent on how
  /// fast the write completes) focus/keyboard loss survivors reported
  /// even after the per-field `ValueKey` fix. Mirrors `WeightNotifier`'s
  /// `saveGoal`/`saveReminderSettings`, which never transition through an
  /// explicit loading state for the same reason.
  Future<void> saveProfile(UserProfile profile) async {
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).saveProfile(profile);
      return profile;
    });
    // Re-run build() so the notifier picks up the freshly persisted row and
    // recomputes targets with the latest profile fields.
    ref.invalidateSelf();
  }

  /// Convenience method for single-field auto-save from the Profile form.
  ///
  /// Applies [updater] to the current profile (or a blank placeholder if
  /// no profile exists yet) and calls [saveProfile].
  Future<void> updateField(UserProfile Function(UserProfile) updater) async {
    final current = state.value ??
        const UserProfile(id: ''); // blank placeholder for new profiles
    final updated = updater(current);
    await saveProfile(updated);
  }

  /// Returns `'imperial'` when [context]'s locale is US, Liberia, or Myanmar;
  /// returns `'metric'` for all other locales.
  ///
  /// This is a pure static helper — it does NOT call [saveProfile] itself.
  /// The Profile screen calls [updateField] with the result when a new
  /// profile is being created for the first time.
  static String setLocaleUnits(BuildContext context) {
    final countryCode = Localizations.localeOf(context).countryCode;
    const imperialCountries = {'US', 'LR', 'MM'};
    return imperialCountries.contains(countryCode) ? 'imperial' : 'metric';
  }
}

/// Reactive stream provider that emits [UserProfile?] with targets attached.
///
/// Plan 01-05 (Profile screen) uses this for real-time UI updates without
/// relying on AsyncNotifier's polling approach. Targets are recomputed on
/// each emission from the underlying Drift stream.
///
/// This provider never imports package:drift — it goes through
/// [profileRepositoryProvider].
@riverpod
Stream<UserProfile?> profileStream(Ref ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.watchProfile().map((profile) {
    if (profile == null) return null;
    final targets = TargetCalculator.derive(
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      age: profile.age,
      gender: profile.gender,
      activityLevel: profile.activityLevel,
      goal: profile.goal,
    );
    return profile.copyWith(targets: targets);
  });
}

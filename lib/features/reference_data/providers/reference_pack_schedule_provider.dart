// ReferencePackScheduleNotifier: SharedPreferences-backed schedule +
// lastCheckedAt for the delta-refresh scheduling feature (09-CONTEXT.md's
// "Delta Refresh: Schedule & Prompting" decision block). Mirrors
// MethodologyBannerDismissalNotifier's SharedPreferences-backed keepAlive
// pattern exactly (dashboard/providers/methodology_banner_provider.dart) --
// `build()` reads `sharedPreferencesProvider` synchronously, no async work.
//
// Honesty framing (09-CONTEXT.md, restated here since this is the provider
// that implements it): this app has no true background scheduler
// (no workmanager/background_fetch/Timer.periodic exists anywhere in this
// codebase). Weekly/Monthly "scheduling" is really a foreground app-open
// check, throttled the same way Plan 05-13/05-18's weigh-in reminder
// re-arm already is. [isCheckDue] never persists a computed "next fire
// time" -- it recomputes fresh from `DateTime.now()` on every call, exactly
// mirroring that established pattern.

import 'package:co2diet/domain/entities/reference_pack_status.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reference_pack_schedule_provider.g.dart';

/// The current delta-refresh schedule plus the last time an automatic
/// check actually ran -- `null` `lastCheckedAt` means "never checked".
typedef ReferencePackScheduleState = ({
  ReferencePackSchedule schedule,
  DateTime? lastCheckedAt,
});

/// Returns `true` when an automatic delta-refresh check is due right now,
/// given [schedule], the [lastCheckedAt] timestamp of the last completed
/// check (`null` = never checked), and the current moment [now].
///
/// Pure, side-effect-free -- easily unit-testable without any
/// SharedPreferences/widget setup. `manual` is never due. `weekly`/
/// `monthly` are due when [lastCheckedAt] is `null` (never checked) or the
/// elapsed gap to [now] has reached the configured interval (7 or 30 days
/// respectively).
bool isCheckDue(
  ReferencePackSchedule schedule,
  DateTime? lastCheckedAt,
  DateTime now,
) {
  switch (schedule) {
    case ReferencePackSchedule.manual:
      return false;
    case ReferencePackSchedule.weekly:
      if (lastCheckedAt == null) return true;
      return now.difference(lastCheckedAt) >= const Duration(days: 7);
    case ReferencePackSchedule.monthly:
      if (lastCheckedAt == null) return true;
      return now.difference(lastCheckedAt) >= const Duration(days: 30);
  }
}

/// Persists and exposes the delta-refresh schedule + last-checked
/// timestamp.
///
/// keepAlive: true -- mirrors `MethodologyBannerDismissalNotifier`'s
/// established rationale: [setSchedule]/[recordCheckedNow]/[resetToManual]
/// are all called from widget callbacks (a `SegmentedButton` selection, a
/// revert-confirmation dialog, `Co2DietApp`'s lifecycle observer) that may
/// not keep an active watcher of this provider alive across the `await`.
@Riverpod(keepAlive: true)
class ReferencePackScheduleNotifier extends _$ReferencePackScheduleNotifier {
  static const _scheduleKey = 'referencePackSchedule';
  static const _lastCheckedAtKey = 'referencePackLastCheckedAt';

  @override
  ReferencePackScheduleState build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    final scheduleName = prefs.getString(_scheduleKey);
    final schedule = ReferencePackSchedule.values.firstWhere(
      (value) => value.name == scheduleName,
      orElse: () => ReferencePackSchedule.manual,
    );

    final lastCheckedAtRaw = prefs.getString(_lastCheckedAtKey);
    final lastCheckedAt = lastCheckedAtRaw == null
        ? null
        : DateTime.parse(lastCheckedAtRaw);

    return (schedule: schedule, lastCheckedAt: lastCheckedAt);
  }

  /// Persists [schedule] and updates state synchronously.
  Future<void> setSchedule(ReferencePackSchedule schedule) async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(
          _scheduleKey,
          schedule.name,
        );
    state = (schedule: schedule, lastCheckedAt: state.lastCheckedAt);
  }

  /// Persists `DateTime.now()` as the last-checked timestamp -- called
  /// once an automatic check completes, regardless of whether it found an
  /// update (a manifest that reports "no update" still counts as a
  /// completed check for throttling purposes).
  Future<void> recordCheckedNow() async {
    final now = DateTime.now();
    await ref
        .read(sharedPreferencesProvider)
        .setString(
          _lastCheckedAtKey,
          now.toIso8601String(),
        );
    state = (schedule: state.schedule, lastCheckedAt: now);
  }

  /// Resets the schedule back to [ReferencePackSchedule.manual] --
  /// 09-CONTEXT.md: "Reverting to the starter pack resets the schedule
  /// setting back to 'Manual only'" (stated under both the Delta Refresh
  /// and Revert-to-Seed Behavior sections -- the same single rule).
  Future<void> resetToManual() => setSchedule(ReferencePackSchedule.manual);
}

import 'dart:async';

import 'package:co2diet/core/di/notification_providers.dart';
import 'package:co2diet/core/router/app_router.dart';
import 'package:co2diet/core/theme/app_theme.dart';
import 'package:co2diet/features/reference_data/providers/reference_pack_notifier.dart';
import 'package:co2diet/features/reference_data/providers/reference_pack_schedule_provider.dart';
import 'package:co2diet/features/weight/providers/weight_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget.
///
/// Uses [MaterialApp.router] with go_router provided by [appRouterProvider].
/// Wired in Plan 01-05.
///
/// `ConsumerStatefulWidget` (not `ConsumerWidget`, since Plan 05-18) with a
/// [WidgetsBindingObserver] mixin: on every [AppLifecycleState.resumed]
/// event, re-arms the biweekly/monthly weigh-in reminder when one is
/// enabled -- **the fix for the checker-flagged biweekly/monthly gap**.
/// `flutter_local_notifications` has no native long-interval recurrence
/// primitive (see `NotificationService.scheduleWeighInReminder`'s doc
/// comment), so `scheduleWeighInReminder` only ever schedules the single
/// next occurrence computed fresh from `DateTime.now()`. Something must
/// periodically re-invoke it to keep that occurrence fresh for
/// infrequent-checkin users -- app-foreground (not a specific screen being
/// opened) is the reliable trigger every user experiences regardless of
/// navigation history. This runs in *addition to*, not instead of, Plan
/// 05-13's existing `WeighInReminderSection` screen-open re-arm call.
///
/// Plan 09-06 adds a second, independent `AppLifecycleState.resumed` check:
/// when the user has opted into Weekly/Monthly automatic reference-pack
/// delta-refresh (`ReferencePackScheduleNotifier`), and the configured
/// interval has actually elapsed (`isCheckDue`), triggers
/// `ReferencePackNotifier.checkForUpdateIfDue()`. Same honest
/// foreground-check framing as the weigh-in reminder re-arm above -- this
/// app has no true background scheduler. Deliberately independent of the
/// weigh-in reminder block: neither reads nor mutates the other's state.
class Co2DietApp extends ConsumerStatefulWidget {
  /// Creates the root [Co2DietApp] widget.
  const Co2DietApp({super.key});

  @override
  ConsumerState<Co2DietApp> createState() => _Co2DietAppState();
}

class _Co2DietAppState extends ConsumerState<Co2DietApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;

    _rearmWeighInReminderIfNeeded();

    // Plan 09-06: independent reference-pack delta-refresh check. A
    // top-level sibling call, not nested inside the weigh-in block above
    // -- deliberately so this can never be short-circuited by that block's
    // own early returns (e.g. `weightProvider` still loading, or no
    // reminder configured). Neither block reads or mutates the other's
    // state.
    unawaited(_checkReferencePackIfDue());
  }

  /// Re-arms the biweekly/monthly weigh-in reminder when one is enabled --
  /// Plan 05-18's original `AppLifecycleState.resumed` behavior, extracted
  /// into its own method so Plan 09-06's independent reference-pack check
  /// (called as a sibling, not nested inside this one) is never
  /// short-circuited by this method's own early returns.
  void _rearmWeighInReminderIfNeeded() {
    // .value (not valueOrNull -- undefined in this Riverpod 3.3.2 pin, see
    // STATE.md [Phase 01-04] decision) returns null in loading/error states.
    final settings = ref.read(weightProvider).value?.settings;
    if (settings == null) return;

    final frequency = settings.reminderFrequency ?? 'never';
    if (!settings.reminderEnabled || frequency == 'never') return;

    unawaited(
      ref
          .read(notificationServiceProvider)
          .scheduleWeighInReminder(
            frequency: frequency,
            weekday: settings.reminderWeekday,
            time: settings.reminderTime ?? '09:00',
          ),
    );
  }

  /// Checks the CDN manifest for a reference-pack update only when the
  /// configured schedule's interval has actually elapsed
  /// ([isCheckDue]) -- the throttled foreground-check counterpart to the
  /// weigh-in reminder re-arm above. Records the check timestamp
  /// regardless of outcome, so a manifest that reports "no update" still
  /// counts as a completed check for throttling purposes.
  Future<void> _checkReferencePackIfDue() async {
    final scheduleState = ref.read(referencePackScheduleProvider);
    final due = isCheckDue(
      scheduleState.schedule,
      scheduleState.lastCheckedAt,
      DateTime.now(),
    );
    if (!due) return;

    await ref.read(referencePackProvider.notifier).checkForUpdateIfDue();
    await ref.read(referencePackScheduleProvider.notifier).recordCheckedNow();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CO₂ Diet',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      // ACC-02: respects the system's Dynamic Type / font-scaling setting
      // everywhere, but clamps it to 1.6x so no key screen overflows at
      // extreme accessibility text sizes.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 1,
        maxScaleFactor: 1.6,
        child: child!,
      ),
    );
  }
}

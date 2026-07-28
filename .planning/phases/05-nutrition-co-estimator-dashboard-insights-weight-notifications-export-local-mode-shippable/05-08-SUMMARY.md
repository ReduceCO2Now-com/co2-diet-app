---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 08
subsystem: notifications
tags: [flutter_local_notifications, timezone, flutter_timezone, fl_chart, riverpod, go_router, mocktail]

# Dependency graph
requires:
  - phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
    provides: "05-05 DAO layer (NotificationPrefsDao), 05-03 schema foundation"
provides:
  - "Four new pubspec.yaml dependencies (fl_chart, flutter_local_notifications, timezone, flutter_timezone) -- human-approved via blocking package-legitimacy checkpoint"
  - "NotificationPrefs domain entity covering all four meal slots (breakfast/lunch/dinner/snack), each with enabled+time fields"
  - "INotificationPrefsRepository / NotificationPrefsRepository (Drift-backed, Co2SettingsRepository upsert convention)"
  - "NotificationService -- init, JIT permission request, per-slot + weigh-in scheduling, tap navigation"
  - "notificationServiceProvider -- the single authoritative DI-access path for 05-13/05-14/05-18"
  - "rootNavigatorKey wired into GoRouter; main.dart initializes NotificationService and handles cold-start notification-tap launch"
affects: [05-13-weight-tracking-screen, 05-14-notification-settings-screen, 05-18-food-search-initial-slot-and-lifecycle-observer, 05-11-dashboard-sparkline, 05-15-data-analysis-trend-section]

# Tech tracking
tech-stack:
  added: [fl_chart 1.2.0, flutter_local_notifications 22.2.0, timezone 0.11.1, flutter_timezone 5.1.0]
  patterns:
    - "Constructor-injected FlutterLocalNotificationsPlugin (not a static singleton) for testability"
    - "Stable per-slot/per-kind notification ids (100 + MealSlot.index for meal reminders, fixed 200 for weigh-in) so re-scheduling replaces rather than duplicates"
    - "PlatformException from the plugin caught and surfaced as a typed false/no-op result, never propagated"
    - "rootNavigatorKey (GlobalKey<NavigatorState>) captured once in app_router.dart so non-widget code can navigate with no BuildContext/ref"

key-files:
  created:
    - lib/domain/entities/notification_prefs.dart
    - lib/domain/repositories/i_notification_prefs_repository.dart
    - lib/data/repositories/notification_prefs_repository.dart
    - lib/domain/services/notification_service.dart
  modified:
    - pubspec.yaml
    - lib/core/di/notification_providers.dart
    - lib/core/router/app_router.dart
    - lib/main.dart
    - test/domain/services/notification_service_test.dart

key-decisions:
  - "NotificationPrefs models the fixed 4-slot table layout as flat named fields (breakfastEnabled/breakfastTime, etc.) rather than a Map<MealSlot, MealReminderConfig> -- avoids an extra indirection layer for a fixed set; enabledFor()/timeFor() provide generic lookup"
  - "notificationServiceProvider constructs NotificationService(FlutterLocalNotificationsPlugin()) fresh -- a second plugin instance distinct from the one main.dart uses to call initialize() before runApp; both share the same underlying platform method channel, so only one initialize() call is needed globally to register the tap-response callback"
  - "scheduleWeighInReminder's biweekly/monthly branches have no native recurrence primitive in flutter_local_notifications, so they schedule only the next single occurrence computed fresh from DateTime.now() every call -- idempotent via the fixed id 200, relying on Plan 05-18's AppLifecycleState.resumed re-invocation to keep the occurrence fresh for infrequent-checkin users (05-CONTEXT.md Planning Addendum, locked decision)"
  - "Required-named-parameter ordering fixed in scheduleWeighInReminder (time before the optional weekday) to satisfy very_good_analysis's always_put_required_named_parameters_first -- no caller impact since all args are passed by name"

patterns-established:
  - "Package-legitimacy blocking-human checkpoint precedent (pub.dev is not slopcheck-supported) reused a second time (after 04-11's flutter_slidable) for all four of this plan's new dependencies"
  - "Cold-start vs. warm notification-tap navigation split: onDidReceiveNotificationResponse (warm) inside NotificationService.initialize(), getNotificationAppLaunchDetails() + WidgetsBinding.instance.addPostFrameCallback (cold) inside main.dart, both funneling through the same static NotificationService.navigateToPayload validator"

requirements-completed: []  # NOTIF-01/02/03 intentionally NOT marked complete -- see note below

# Metrics
duration: ~15min (this session; Task 1 was completed and committed in a prior session before the package-legitimacy checkpoint was presented for approval)
completed: 2026-07-28
---

# Phase 5 Plan 8: Notification packages + NotificationPrefs domain layer + NotificationService Summary

**Installed fl_chart/flutter_local_notifications/timezone/flutter_timezone (human-approved), built the NotificationPrefs domain layer, and shipped NotificationService with stable-id scheduling, JIT permission requesting, and rootNavigatorKey-based tap navigation.**

## Performance

- **Duration:** ~15 min (Task 2, this session) + prior-session Task 1
- **Completed:** 2026-07-28
- **Tasks:** 2/2
- **Files modified:** 9 (4 created, 5 modified) across both tasks combined

## Accomplishments

- Four new pubspec.yaml dependencies installed and human-approved via a blocking package-legitimacy checkpoint (pub.dev is not a slopcheck-supported ecosystem — same precedent as Plan 04-11's `flutter_slidable`)
- `NotificationPrefs` domain entity + `INotificationPrefsRepository`/`NotificationPrefsRepository` covering all four meal slots
- `NotificationService` — named-parameter-only `flutter_local_notifications` v22 API usage, `AndroidScheduleMode.inexactAllowWhileIdle` exclusively, JIT permission requesting only, stable per-slot/per-kind notification ids so re-scheduling replaces rather than duplicates
- `rootNavigatorKey` wired into `GoRouter`; `main.dart` initializes the service and handles both warm and cold-start notification-tap navigation
- `notificationServiceProvider` registered exactly once, in this plan, as the single authoritative DI-access path for 05-13/05-14/05-18
- De-skipped `notification_service_test.dart` — all 6 Wave-0 stub assertions now real, using mocktail against a mocked `FlutterLocalNotificationsPlugin`

## Task Commits

1. **Task 1: Install dependencies and build the NotificationPrefs domain layer** - `b1284db` (feat) — completed in a prior session, before this session's checkpoint-resume
2. **Task 2: NotificationService, rootNavigatorKey, and main.dart wiring** - `7852e52` (feat)

**Plan metadata:** (this commit, following SUMMARY/STATE/ROADMAP update)

## Files Created/Modified

- `pubspec.yaml` — fl_chart 1.2.0, flutter_local_notifications 22.2.0, timezone 0.11.1, flutter_timezone 5.1.0 with version-comment blocks
- `lib/domain/entities/notification_prefs.dart` — `NotificationPrefs` entity, 4 meal slots, sentinel `copyWith`
- `lib/domain/repositories/i_notification_prefs_repository.dart` — repository interface
- `lib/data/repositories/notification_prefs_repository.dart` — Drift-backed implementation
- `lib/core/di/notification_providers.dart` — `notificationPrefsDaoProvider`, `notificationPrefsRepositoryProvider`, `notificationServiceProvider`
- `lib/domain/services/notification_service.dart` — `NotificationService` (init, JIT permission, per-slot + weigh-in scheduling, tap navigation)
- `lib/core/router/app_router.dart` — `rootNavigatorKey` (`GlobalKey<NavigatorState>`), passed into `GoRouter(navigatorKey: ...)`
- `lib/main.dart` — initializes `NotificationService` before `runApp` (non-fatal on exception); cold-start launch-details check + post-frame navigation callback
- `test/domain/services/notification_service_test.dart` — de-skipped, 6 real mocktail-based assertions

## Decisions Made

- `NotificationPrefs` uses flat named fields per meal slot rather than a `Map<MealSlot, MealReminderConfig>` (avoids indirection for a fixed 4-slot set)
- `notificationServiceProvider` and `main.dart`'s pre-`runApp` initialization each construct their own `FlutterLocalNotificationsPlugin()` instance — both share the same underlying platform method channel, so only `main.dart`'s single `initialize()` call is needed to register the tap-response callback globally; the DI-provided instance is only ever used for scheduling/cancel calls, not re-initialized
- `scheduleWeighInReminder`'s biweekly/monthly branches schedule only the next single occurrence (no native recurrence primitive exists) — idempotent via the fixed id 200; Plan 05-18 is responsible for the `AppLifecycleState.resumed` re-invocation that keeps this fresh
- Required-named-parameter order fixed in `scheduleWeighInReminder` (`time` before optional `weekday`) to satisfy `very_good_analysis`'s `always_put_required_named_parameters_first` lint — purely a declaration-order fix, no caller impact (all call sites already use named arguments)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed lint violations surfaced by `flutter analyze` on the newly written files**
- **Found during:** Task 2 (NotificationService implementation)
- **Issue:** `GoRouter.of(context).push(payload)`'s discarded `Future` tripped `discarded_futures`; `scheduleWeighInReminder`'s parameter order (`required frequency, weekday, required time`) tripped `always_put_required_named_parameters_first`; one test line exceeded 80 chars
- **Fix:** Wrapped the navigation push in `unawaited()` (added `dart:async` import); reordered `scheduleWeighInReminder`'s named parameters so both `required` params come before the optional `weekday`; reformatted the long test line across multiple lines
- **Files modified:** `lib/domain/services/notification_service.dart`, `test/domain/services/notification_service_test.dart`
- **Verification:** `flutter analyze` on all 5 plan-relevant files returns "No issues found!"
- **Committed in:** `7852e52` (Task 2 commit)

**2. [Rule 3 - Blocking] Fixed test-only `tz.setLocalLocation('UTC')` lookup failure**
- **Found during:** Task 2 (writing `notification_service_test.dart`)
- **Issue:** `tz.getLocation('UTC')` throws `LocationNotFoundException` — the bundled tzdb uses `'Etc/UTC'` as the canonical IANA name, not the bare string `'UTC'`
- **Fix:** Used the `timezone` package's pre-built `tz.UTC` `Location` constant directly (`tz.setLocalLocation(tz.UTC)`) instead of a database lookup
- **Files modified:** `test/domain/services/notification_service_test.dart`
- **Verification:** `flutter test test/domain/services/notification_service_test.dart` — all 6 tests pass
- **Committed in:** `7852e52` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (1 bug/lint, 1 blocking test-setup fix)
**Impact on plan:** Both fixes were mechanical (lint compliance, correct IANA timezone name) with no behavioral or scope change. No architectural deviation.

## Issues Encountered

None beyond the auto-fixed items above. A prior execution attempt on this same plan reached the package-legitimacy checkpoint, was approved by the user ("approved"), and Task 1 was completed/committed (`b1284db`) in that session; this session verified Task 1's actual repository state (rather than trusting a stale "0/2 tasks done" resume note) and completed Task 2 on top of it.

## User Setup Required

None — no external service configuration required. All four packages are local-only (chart rendering, on-device notification scheduling); no network calls, no API keys.

## Next Phase Readiness

- `notificationServiceProvider` is ready for 05-13 (Weight Tracking screen — weigh-in reminder toggle), 05-14 (Notification Settings screen — meal-slot reminder toggles), and 05-18 (food-search `initialSlot` wiring + `AppLifecycleState.resumed` weigh-in re-arm observer)
- `fl_chart` is ready for 05-11 (Dashboard sparkline), 05-13 (Weight Tracking chart), 05-15 (Data Analysis trend section)
- **NOTIF-01/02/03 are intentionally NOT marked complete in REQUIREMENTS.md.** This plan delivers only the domain/service layer (`NotificationService` + `NotificationPrefs`) — the actual meal-reminder and weigh-in-reminder UI toggles that let a user configure and observe these reminders don't exist until Plans 05-13/05-14/05-18. Marking the requirements complete now would repeat the mistake corrected in commit `746dbf8` (partial/domain-layer-only work marked complete for WT-01..04 in Plan 05-07).
- `payload: '/food-search?slot=${slot.name}'` is a cross-plan contract Plan 05-18's food-search `initialSlot` wiring must implement exactly as documented in `notification_service.dart`'s doc comment

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-28*

## Self-Check: PASSED

All created/modified files verified present on disk; both task commits (`b1284db`, `7852e52`) verified present in git history.

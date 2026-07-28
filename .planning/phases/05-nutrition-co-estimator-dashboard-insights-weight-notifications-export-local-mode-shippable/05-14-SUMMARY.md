---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 14
subsystem: notifications
tags: [flutter, riverpod, flutter_local_notifications, notifications, ui]

# Dependency graph
requires:
  - phase: 05-08
    provides: NotificationService, NotificationPrefs domain layer, notificationServiceProvider/notificationPrefsRepositoryProvider DI
provides:
  - NotificationPrefsNotifier (notificationPrefsProvider) -- Riverpod glue keeping stored NotificationPrefs and live-scheduled OS notifications in sync
  - MealReminderSettingsSection -- standalone, embeddable widget with 4 independent meal-slot reminder rows
affects: [05-18]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Per-row ConsumerStatefulWidget holding local pending-time + permission-denied-message state, siblings independent (mirrors WeighInReminderSection's Plan 05-13 pattern)"
    - "Defensive ref.invalidate(provider) call on a permission-denial no-op path, since the notifier's own state never changes on denial"

key-files:
  created:
    - lib/features/notifications/providers/notification_prefs_notifier.dart
    - lib/features/notifications/providers/notification_prefs_notifier.g.dart
    - lib/features/notifications/widgets/meal_reminder_settings_section.dart
  modified:
    - test/features/notifications/notification_prefs_ui_test.dart

key-decisions:
  - "NotificationPrefsNotifier.setSlotEnabled reads current prefs via state.value ?? await future (not a fresh repository read) before merging the single slot's fields -- avoids a redundant getPrefs() round trip when build() has already completed"
  - "MealReminderSettingsSection itself stays a stateless ConsumerWidget; each of the 4 rows is a private _MealSlotRow ConsumerStatefulWidget holding its own local _time/_permissionDeniedMessage state -- keeps rows independently interactive without lifting state up"
  - "Time picked before a slot's reminder is enabled is remembered locally (not persisted) until the switch is turned on, mirroring WeighInReminderSection's _pickTime-only-reschedules-if-_enabled precedent"

patterns-established:
  - "AppTextTheme has no bodyMd token -- bodyLg is the correct token for row-label-sized body text (bodySm is for secondary/caption text)"

requirements-completed: []

# Metrics
duration: ~16min
completed: 2026-07-28
---

# Phase 05 Plan 14: Meal Reminder Settings Section Summary

**NotificationPrefsNotifier + MealReminderSettingsSection: four independently configurable meal-slot reminder rows (Breakfast/Lunch/Dinner/Snack), each with just-in-time permission requesting and a row-scoped Open Settings recovery link on denial.**

## Performance

- **Duration:** ~16 min
- **Started:** 2026-07-28T16:50Z (immediately after 05-13 commit)
- **Completed:** 2026-07-28T17:06Z
- **Tasks:** 2
- **Files modified:** 4 (3 created, 1 modified test file touched by both tasks)

## Accomplishments
- `NotificationPrefsNotifier` (`notificationPrefsProvider`): loads `NotificationPrefs` via `build()`, and `setSlotEnabled(slot, enabled, {time})` requests permission just-in-time only when enabling, persists via the repository, and calls `scheduleMealReminder`/`cancelMealReminder` on `NotificationService` -- the single place stored prefs and live-scheduled OS notifications stay in sync.
- `MealReminderSettingsSection`: renders 4 independent rows (one per `MealSlot`), each with its own time-picker `TextButton` and `Switch`; a denied permission reverts only that row's toggle and shows an inline "Open Settings" recovery link beneath that specific row.
- Consumes the existing `notificationServiceProvider` (registered by Plan 05-08) via `ref.read`/`ref.watch` -- no competing provider declared, `lib/core/di/notification_providers.dart` untouched.
- Fully de-skipped `test/features/notifications/notification_prefs_ui_test.dart`: 4 notifier-level unit tests (mocktail-mocked `INotificationPrefsRepository`/`NotificationService`) + 2 widget-level tests (fake repository + mocktail-mocked service).

## Task Commits

Each task was committed atomically:

1. **Task 1: NotificationPrefsNotifier** - `36cdd1e` (feat)
2. **Task 2: MealReminderSettingsSection widget** - `4cf3551` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified
- `lib/features/notifications/providers/notification_prefs_notifier.dart` - `NotificationPrefsNotifier` AsyncNotifier: `build()` loads prefs, `setSlotEnabled` gates on permission then persists + schedules/cancels
- `lib/features/notifications/providers/notification_prefs_notifier.g.dart` - riverpod_generator output (`notificationPrefsProvider`)
- `lib/features/notifications/widgets/meal_reminder_settings_section.dart` - `MealReminderSettingsSection` (ConsumerWidget) + private `_MealSlotRow` (ConsumerStatefulWidget) per meal slot
- `test/features/notifications/notification_prefs_ui_test.dart` - De-skipped: `NotificationPrefsNotifier` unit tests (Task 1) + `Meal reminder settings section` widget tests (Task 2)

## Decisions Made
- `setSlotEnabled` merges only the touched slot's enabled/time fields into the full `NotificationPrefs` row (via a generic `_withSlot` switch helper) before calling `savePrefs`, since the repository's `savePrefs` always writes the complete 4-slot row (`NotificationPrefsRepository.savePrefs` reads-then-upserts the single row using all 8 fields) -- a partial call would silently reset the other three slots to their previous copyWith-preserved values, which is exactly what `_withSlot` guarantees by starting from `current` (the just-loaded/just-built prefs), not a blank `NotificationPrefs()`.
- Each of the 4 rows manages its own local `_time`/`_permissionDeniedMessage` state as a private `ConsumerStatefulWidget`, rather than the parent `MealReminderSettingsSection` (a stateless `ConsumerWidget`) tracking a `Map<MealSlot, ...>` -- keeps each row's interaction logic (time-picker, toggle, denial recovery) self-contained and independently testable, matching `WeighInReminderSection`'s (Plan 05-13) established local-state pattern for the same permission-denied UX, scaled to 4 independent rows instead of 1.
- On a denied `setSlotEnabled` call, the row calls `ref.invalidate(notificationPrefsProvider)` defensively even though the notifier's own state never actually changes on denial (no `savePrefs`/schedule call happens) -- this is a belt-and-suspenders re-read per the plan's explicit instruction, guarding against any future notifier change that might leave stale intermediate state cached.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `AppTextTheme.bodyMd` does not exist -- used `bodyLg` instead**
- **Found during:** Task 2 (widget compilation failed: "Member not found: 'bodyMd'")
- **Issue:** Plan's own reference widget (`weigh_in_reminder_section.dart`) doesn't use `AppTextTheme` for its section title style directly in a way that surfaced this; `AppTextTheme` only exposes `displayLg`, `headlineLg`, `headlineLgMobile`, `titleMd`, `bodyLg`, `bodySm`, `labelCaps` -- no `bodyMd` token exists.
- **Fix:** Changed the meal-slot label `Text` style from `AppTextTheme.bodyMd` to `AppTextTheme.bodyLg` (the correct token for primary row-label-sized body text; `bodySm` is reserved for secondary/caption text like the permission-denied message).
- **Files modified:** `lib/features/notifications/widgets/meal_reminder_settings_section.dart`
- **Verification:** `flutter test test/features/notifications/` passes; `flutter analyze` clean.
- **Committed in:** `4cf3551` (Task 2 commit)

**2. [Rule 1 - Bug] `dart format` reflow on `notification_prefs_notifier.dart` (Task 1's own file)**
- **Found during:** Task 2 (running `dart format` across the feature directory before the final commit)
- **Issue:** One line in Task 1's already-committed notifier file exceeded the formatter's preferred wrap point after a prior edit pass, leaving a 2-line expression that `dart format` collapses to 1 line at 80 chars.
- **Fix:** Ran `dart format` on the file; single-line reflow of the `resolvedTime` assignment, no logic change.
- **Files modified:** `lib/features/notifications/providers/notification_prefs_notifier.dart`
- **Verification:** `flutter test test/features/notifications/` still passes (6/6); `flutter analyze` unchanged (still only the one pre-existing info-level lint).
- **Committed in:** `4cf3551` (bundled into Task 2 commit, noted in commit message)

**3. [unnecessary_lambdas lint - test only] Tearoff instead of closure for zero-arg mocktail stubs**
- **Found during:** Task 2 (`flutter analyze test/features/notifications/` flagged 2 `unnecessary_lambdas` info issues)
- **Issue:** `when(() => service.requestPermissionIfNeeded())` triggers `unnecessary_lambdas` since the closure body is exactly a zero-arg tearoff-eligible call.
- **Fix:** Changed to `when(service.requestPermissionIfNeeded)` (direct tearoff) in both widget tests. No behavior change -- mocktail's `when()` accepts either form.
- **Files modified:** `test/features/notifications/notification_prefs_ui_test.dart`
- **Verification:** `flutter test test/features/notifications/` passes (6/6); `flutter analyze test/features/notifications/` clean (0 issues).
- **Committed in:** `4cf3551` (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (2 Rule 1 bugs, 1 lint cleanup in test code)
**Impact on plan:** All minor, contained to this plan's own new/touched files. No scope creep, no architectural changes.

## Issues Encountered
None beyond the auto-fixed items above.

## Known Stubs
None. `MealReminderSettingsSection` is intentionally a standalone widget not yet reachable from `SettingsScreen` -- this is the plan's explicit, documented design (Plan 05-18 embeds it), not an unintentional stub. It renders real per-slot data from `notificationPrefsProvider` with no hardcoded/placeholder values.

## Threat Flags

None. This plan adds no new trust-boundary surface -- it delegates entirely to `NotificationService` (Plan 05-08), which already owns the OS-notification-boundary threat model, per this plan's own `<threat_model>` section (disposition: N/A, all surface pre-existing).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `MealReminderSettingsSection` is fully built, tested, and ready to be embedded -- Plan 05-18 is the consumer.
- NOTIF-01 is **NOT** marked complete in REQUIREMENTS.md: the requirement's full text requires the section to be reachable in Settings, which only happens once Plan 05-18 wires it in. This mirrors the exact same "standalone, not-yet-embedded" treatment already applied to WT-01–05/NOTIF-02 (Plan 05-13) and CO2-03 (Plan 05-12).
- No blockers for Plan 05-18: `notificationServiceProvider`/`notificationPrefsRepositoryProvider` (05-08) and this plan's `notificationPrefsProvider`/`MealReminderSettingsSection` are all in place for that plan to consume directly.

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-28*

## Self-Check: PASSED

All created files and both task commits (36cdd1e, 4cf3551) verified present.

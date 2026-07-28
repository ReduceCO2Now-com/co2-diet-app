---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 18
subsystem: ui
tags: [go_router, riverpod, dashboard, notifications, app-lifecycle, flutter]

# Dependency graph
requires:
  - phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
    provides: "05-11 Dashboard widgets, 05-12 Co2SettingsScreen, 05-13 WeightScreen, 05-14 MealReminderSettingsSection, 05-15 DataAnalysisScreen, 05-16 BackupRestoreScreen, 05-17 Improvement Opportunities/Insights Timeline, 05-08 NotificationService/notificationServiceProvider"
provides:
  - "Four new go_router routes: /co2-settings, /weight-tracking, /data-analysis, /backup-restore, each with safe query-param fallbacks"
  - "FoodSearchScreen.initialSlot pre-selection contract shared by Dashboard quick-log buttons and NotificationService's meal-reminder tap payload"
  - "Fully composed PlaceholderDashboardScreen: goal-emphasized metric cards, switchable 7-day trend sparkline, quick insight line, mode indicator, per-slot quick-log buttons + Quick Add, and a bottom CO2 profile prompt card"
  - "Co2DietApp AppLifecycleState.resumed observer that re-arms the weigh-in reminder on every app-foreground event"
  - "SettingsScreen entry points for CO2 Calculation Settings, Weight Tracking, Backup & Restore, plus the embedded MealReminderSettingsSection"
affects: [05-19]

# Tech tracking
tech-stack:
  added: [collection ^1.19.1]
  patterns:
    - "PlaceholderDashboardScreen converted from ConsumerWidget to ConsumerStatefulWidget to hold two session-only local UI selections (sparkline metric, CO2-prompt dismissal) without introducing a new Riverpod provider -- mirrors WeighInReminderSection/MealReminderSettingsSection's established local-widget-state convention"
    - "Co2DietApp converted from ConsumerWidget to ConsumerStatefulWidget + WidgetsBindingObserver -- the app-root lifecycle-observer pattern for re-invoking a stateless 'schedule next occurrence' service call on a broader trigger than any single screen's lifecycle"
    - "firstWhereOrNull-based safe query-param parsing for /data-analysis?metric= and /food-search?slot= -- never crashes on a malformed/absent deep link, always falls back to a documented default"

key-files:
  created:
    - test/features/dashboard/dashboard_composition_test.dart
    - test/features/settings/settings_screen_test.dart
  modified:
    - lib/core/router/app_router.dart
    - lib/features/food_search/screens/food_search_screen.dart
    - lib/features/dashboard/screens/placeholder_dashboard_screen.dart
    - lib/app.dart
    - lib/features/settings/screens/settings_screen.dart
    - pubspec.yaml
    - test/features/dashboard/dashboard_swipe_integration_test.dart
    - test/features/dashboard/metric_card_test.dart
    - test/features/dashboard/meal_entry_row_test.dart

key-decisions:
  - "QuickInsightLine's 'most notable metric' selection implemented as the largest single-meal-slot-share fraction across all 3 metrics (CO2/calories/protein), not a per-metric target-deviation comparison -- CO2 has no numeric target in this codebase (co2GTarget is never populated by TargetCalculator, confirmed in 05-15), so a uniform slot-share selection is the only approach that genuinely 'covers all three metrics' per CONTEXT.md, and it matches the requirement's literal example ('Lunch contributed most CO2 today') exactly"
  - "Sparkline's initial selected metric defaults to CO2 (plain local widget state, not persisted) -- an arbitrary-but-documented default consistent with the router's own /data-analysis fallback-to-co2 convention"
  - "Co2DietApp reads WeightState.settings via .value (not .valueOrNull, which does not exist on AsyncValue in this project's pinned Riverpod 3.3.2 per the [Phase 01-04] decision already in STATE.md) -- PLAN.md's action text said valueOrNull, corrected during implementation"
  - "collection added as a direct pubspec.yaml dependency (was already resolved transitively) for firstWhereOrNull -- no package-legitimacy checkpoint needed, it is the official dart-lang team collection-utilities package already present in pubspec.lock"

patterns-established:
  - "Every slot's quick-log button (Breakfast/Lunch/Dinner/Snack) always renders regardless of whether that slot has any logged entries today -- only the slot *section header* above the meal list is conditionally hidden when a slot is empty. Tests asserting 'no entries -> slot name text absent' from Phase 4 needed updating to 'slot name still present once (button), header absent' since the button and header render at different visibility conditions."
---

# Phase 5 Plan 18: Dashboard/Settings Integration & App-Lifecycle Weigh-in Re-arm Summary

**Wired all standalone Wave 5/6 screens into the app via four new go_router routes, assembled the real Dashboard (metric cards, sparkline, quick insight, mode indicator, quick-log buttons, CO2 prompt card) on top of Phase 4's meal list, and added the root-level app-lifecycle observer that keeps biweekly/monthly weigh-in reminders fresh.**

## Performance

- **Duration:** ~50 min
- **Tasks:** 4
- **Files modified:** 11 (4 lib files touched across 3 tasks plus settings_screen.dart, 2 new test files, 3 existing test files fixed for new provider dependencies, pubspec.yaml/pubspec.lock)

## Accomplishments

- Four new top-level routes (`/co2-settings`, `/weight-tracking`, `/data-analysis`, `/backup-restore`) all resolve correctly with safe fallbacks on malformed query params
- `FoodSearchScreen` accepts `initialSlot`, pre-filling `PortionSlotForm`'s meal slot identically whether arriving from a Dashboard quick-log button or a meal-reminder notification tap
- Dashboard is fully composed: goal-emphasized `MetricCard` row, switchable `TrendSparkline` (tap-to-Data-Analysis), `QuickInsightLine`, `ModeIndicator`, per-slot quick-log buttons + Quick Add, and the bottom `Co2ProfilePromptCard` -- every DASH-0x requirement now genuinely reachable end-to-end
- `Co2DietApp` re-arms the weigh-in reminder on every `AppLifecycleState.resumed` event (in addition to, not instead of, the Weight screen's own screen-open re-arm), fixing the biweekly/monthly recurrence gap `flutter_local_notifications` cannot handle natively
- `SettingsScreen` links to all three newly-reachable screens plus the embedded `MealReminderSettingsSection`

## Task Commits

1. **Task 1: Router wiring and food-search slot pre-selection** - `85f58d4` (feat)
2. **Task 2: Dashboard metrics -- cards, sparkline, quick insight, mode indicator** - `86fbd48` (feat)
3. **Task 3: Dashboard quick-log actions + CO2 prompt card, and the weigh-in reminder app-lifecycle observer** - `a40864a` (feat)
4. **Task 4: Settings screen entry points and embedded meal reminder section** - `3f889e0` (feat)

## Files Created/Modified

- `lib/core/router/app_router.dart` - Four new routes with `firstWhereOrNull` safe fallbacks; `/food-search` now threads `?slot=` through
- `lib/features/food_search/screens/food_search_screen.dart` - `initialSlot` constructor param threaded to `showFoodDetailSheet`
- `lib/features/dashboard/screens/placeholder_dashboard_screen.dart` - Converted to `ConsumerStatefulWidget`; full Dashboard composition (metric cards, sparkline, quick insight, mode indicator, quick-log row, CO2 prompt card) around the unchanged Phase-4 meal list
- `lib/app.dart` - `Co2DietApp` converted to `ConsumerStatefulWidget` + `WidgetsBindingObserver`; re-arms weigh-in reminder on every foreground event
- `lib/features/settings/screens/settings_screen.dart` - Three new `ListTile` entry points plus embedded `MealReminderSettingsSection`
- `pubspec.yaml` / `pubspec.lock` - `collection` added as a direct dependency
- `test/features/dashboard/dashboard_composition_test.dart` - New: `emphasizedMetricFor`/`orderedMetrics`/`computeQuickInsight` unit tests plus metric-card/chart-tap navigation and CO2-prompt-card gating/dismiss widget tests
- `test/features/settings/settings_screen_test.dart` - New: tile presence, embedded-section presence, tap-through navigation for all three new routes
- `test/features/dashboard/dashboard_swipe_integration_test.dart`, `test/features/dashboard/metric_card_test.dart`, `test/features/dashboard/meal_entry_row_test.dart` - Fixed to mock the new `profileRepositoryProvider`/`co2SettingsRepositoryProvider` watches and widened test viewports; de-skipped the quick-log-button test

## Decisions Made

- QuickInsightLine's selection logic uses "largest single-meal-slot share" uniformly across CO2/calories/protein (see key-decisions above) rather than a per-metric target-deviation comparison, since CO2 has no numeric target anywhere in this codebase.
- `Co2DietApp`'s lifecycle observer reads `WeightState.settings` via `.value` (Riverpod 3.3.2 has no `valueOrNull`), correcting PLAN.md's action text during implementation.
- `collection` added directly to `pubspec.yaml` (was already a transitive dependency, no legitimacy checkpoint needed).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `AsyncValue.valueOrNull` doesn't exist in this Riverpod version**
- **Found during:** Task 3 (`lib/app.dart`)
- **Issue:** PLAN.md's action text specified `ref.read(weightProvider).valueOrNull?.settings`, but this project pins Riverpod 3.3.2, which has no `valueOrNull` getter (already documented as a [Phase 01-04] decision in STATE.md).
- **Fix:** Used `.value` instead, which returns `T?` (null in loading/error states) — the exact pattern STATE.md already establishes.
- **Files modified:** `lib/app.dart`
- **Verification:** `flutter analyze lib/app.dart` clean.
- **Committed in:** `a40864a` (Task 3 commit)

**2. [Rule 3 - Blocking] Existing Dashboard tests broke once the screen started watching `profileProvider`/`co2SettingsProvider`**
- **Found during:** Task 2 (`dashboard_swipe_integration_test.dart`) and Task 3 (`meal_entry_row_test.dart`)
- **Issue:** Both tests previously overrode only `mealEntryRepositoryProvider`; once the composed Dashboard also watches `profileProvider`/`co2SettingsProvider`, those tests would have hit the real `appDatabaseProvider` (drift_flutter/path_provider) with no platform-channel mocking, hanging or throwing.
- **Fix:** Added `_MockProfileRepository`/`_MockCo2SettingsRepository` mocks and overrode `profileRepositoryProvider`/`co2SettingsRepositoryProvider` in both tests, mirroring the existing `mealEntryRepositoryProvider` override pattern.
- **Files modified:** `test/features/dashboard/dashboard_swipe_integration_test.dart`, `test/features/dashboard/meal_entry_row_test.dart`
- **Verification:** Both tests pass; full `test/features/dashboard/` suite green.
- **Committed in:** `86fbd48`, `a40864a`

**3. [Rule 3 - Blocking] Test viewport too small for the composed header**
- **Found during:** Task 2/3 (multiple Dashboard/Settings test files)
- **Issue:** The default 800x600 test surface plus Flutter's sliver-list cache-extent hid rows/tiles past the now-larger composed header (mode indicator, metric cards, sparkline, quick insight, quick-log row) — same class of issue Plan 05-12 already hit and fixed for `Co2SettingsScreen`.
- **Fix:** Set `tester.view.physicalSize = const Size(1080, 4000)` / `devicePixelRatio = 1.0` with matching `addTearDown` resets in `dashboard_swipe_integration_test.dart`, `dashboard_composition_test.dart`, `metric_card_test.dart`, `meal_entry_row_test.dart`, and `settings_screen_test.dart`.
- **Files modified:** (same files as above, plus the two new test files)
- **Verification:** All affected tests pass.
- **Committed in:** `86fbd48`, `a40864a`, `3f889e0`

**4. [Rule 1 - Bug] `meal_entry_row_test.dart`'s "empty slot hides header" assertions no longer matched the new Dashboard behavior**
- **Found during:** Task 3
- **Issue:** The pre-existing test asserted `find.text('Breakfast')` etc. returned `findsNothing` for slots with zero entries. Once Task 3 added an unconditional per-slot quick-log button row, every slot's name now renders at least once (the button) regardless of entry count — only the *section header* is conditionally hidden.
- **Fix:** Updated assertions to `findsOneWidget` (button only, empty slot) vs. `findsNWidgets(2)` (button + header, populated slot), with an inline comment explaining the new visibility split.
- **Files modified:** `test/features/dashboard/meal_entry_row_test.dart`
- **Verification:** Test passes; assertion now documents the real DASH-02/DASH-03 interaction.
- **Committed in:** `a40864a`

---

**Total deviations:** 4 auto-fixed (1 bug in app.dart, 1 bug in a test assertion, 2 blocking-issue test fixes)
**Impact on plan:** All auto-fixes were necessary consequences of composing previously-standalone widgets into one screen for the first time; none represent scope creep or architectural changes.

## Issues Encountered

None beyond the deviations above.

## Known Gaps (not fixed by this plan — out of this plan's task scope)

- **`MacroSplitBar` (NUTR-04) remains built but unwired.** Plan 05-11 built this widget specifically for NUTR-04 ("Macro split viewable from Dashboard or Data Analysis"), but neither this plan's Dashboard-assembly task (Task 2) nor `DataAnalysisScreen` (Plan 05-15/05-17) ever imports/renders it. This plan's task list did not include wiring it in, and 05-CONTEXT.md's Dashboard Composition section never mentions macro split placement, so no wiring was added here to avoid scope creep beyond the plan's explicit tasks. `NUTR-04` is left `Pending` in REQUIREMENTS.md. Flagging for a future plan or a quick follow-up fix.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Every Wave 5/6 screen this phase built is now reachable end-to-end: Dashboard, CO2 Calculation Settings, Weight Tracking, Data Analysis, Backup & Restore, and the meal-reminder settings section.
- Plan 05-19 (offline-proof test + NFR-05 audit + full-suite regression) has no known blockers from this plan — full suite is green, `flutter analyze lib/` shows only 24 pre-existing info-level issues in files this plan never touched.
- `NUTR-04`'s `MacroSplitBar` wiring gap (see Known Gaps) is a candidate for a small follow-up if a future plan revisits Dashboard/Data Analysis composition.

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-28*

## Self-Check: PASSED

All files created/modified in this plan verified present on disk; all 4 task commits (`85f58d4`, `86fbd48`, `a40864a`, `3f889e0`) verified present in git history.

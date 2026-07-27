---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 01
subsystem: testing
tags: [flutter_test, wave-0-stubs, tdd-scaffolding, drift, riverpod]

requires:
  - phase: 04-meal-logging-core-10s-target
    provides: "Established Wave 0 stub convention (group-level skip for unit/widget tests, markTestSkipped() for integration) used verbatim here"
provides:
  - "25 Wave 0 test stub files covering every Phase 5 sub-domain: CO2 Settings, Dashboard, Weight, Insights/Data Analysis, Notifications, Backup/Export, plus two foundational fixes (nutrient-snapshot schema gap, CO2 cache-path gap)"
  - "Named test file targets in <verify> blocks for every subsequent Phase 5 execute plan"
affects: [05-02, 05-03, 05-04, 05-05, 05-06, 05-07, 05-08, 05-09, 05-10, 05-11, 05-12, 05-13, 05-14, 05-15, 05-16, 05-17, 05-18, 05-19]

tech-stack:
  added: []
  patterns:
    - "Group-level skip: group('ClassName', skip: 'ClassName not yet implemented', () { test/testWidgets(...) })"

key-files:
  created:
    - test/domain/services/daily_totals_calculator_test.dart
    - test/domain/services/personal_co2_multiplier_test.dart
    - test/domain/services/notification_service_test.dart
    - test/domain/services/backup_export_service_test.dart
    - test/domain/services/improvement_opportunity_finder_test.dart
    - test/domain/entities/meal_entry_nutrient_test.dart
    - test/data/local/co2_settings_dao_test.dart
    - test/data/local/weight_dao_test.dart
    - test/data/local/notification_prefs_dao_test.dart
    - test/data/local/backup_metadata_dao_test.dart
    - test/data/local/food_catalog_cache_co2_test.dart
    - test/data/repositories/co2_settings_repository_test.dart
    - test/data/repositories/weight_repository_test.dart
    - test/features/co2_settings/co2_settings_notifier_test.dart
    - test/features/weight/weight_notifier_test.dart
    - test/features/dashboard/metric_card_test.dart
    - test/features/dashboard/trend_sparkline_test.dart
    - test/features/co2_settings/co2_settings_screen_test.dart
    - test/features/weight/weight_screen_test.dart
    - test/features/notifications/notification_prefs_ui_test.dart
    - test/features/data_analysis/data_analysis_screen_test.dart
    - test/features/data_analysis/improvement_opportunities_test.dart
    - test/features/data_analysis/insights_timeline_test.dart
    - test/features/backup/backup_restore_screen_test.dart
    - test/core/offline_phase5_test.dart
  modified: []

key-decisions:
  - "Group-level skip pattern (Phase 2-4 precedent) reused verbatim for all 25 stubs, including testWidgets bodies wrapped inside a skipped group() rather than per-test skip args"

requirements-completed: [NUTR-01, NUTR-02, NUTR-03, NUTR-04, CO2-02, CO2-03, CO2-05, CO2-06, DASH-01, DASH-04, INS-01, INS-03, WT-01, WT-02, WT-03, WT-04, NOTIF-01, NOTIF-02, NOTIF-03, PRIV-01, PRIV-02, PRIV-03, PRIV-04, PRIV-08, AUTH-07]

duration: ~12min
completed: 2026-07-27
---

# Phase 5 Plan 01: Wave 0 Test Stubs Summary

**25 group-level-skip test stub files scaffolding every Phase 5 sub-domain (CO2 Settings, Dashboard, Weight, Insights, Notifications, Backup/Export) plus the two foundational Phase-4 gap fixes — zero production code touched, full suite exits 0.**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-07-27T20:52:00Z (approx, first commit d20f1c2)
- **Completed:** 2026-07-27T20:55:00Z (approx, final commit 5ca0c3e)
- **Tasks:** 5 completed
- **Files modified:** 25 created, 1 fixed (whitespace lint)

## Accomplishments
- All 25 stub files listed in the plan's `files_modified` frontmatter created at exact paths
- Every stub uses the established group-level `skip:` pattern (Phase 2-4 precedent) with zero imports beyond `flutter_test`
- `flutter test test/` passes with all 214 tests green/skipped, exit code 0
- `flutter analyze` on the new stub directories reports zero issues in the new files (one pre-existing lint fixed inline, see Deviations)
- No production code modified

## Task Commits

Each task was committed atomically:

1. **Task 1: Domain service stubs (6 files)** - `d20f1c2` (test)
2. **Task 2: DAO stubs (5 files)** - `2567128` (test)
3. **Task 3: Repository and notifier stubs (4 files)** - `3213ce8` (test)
4. **Task 4: Dashboard, CO2 Settings, Weight, and Notifications UI stubs (5 files)** - `df13721` (test)
5. **[Rule 1 fix] Whitespace lint in Task 4's trend_sparkline_test.dart** - `6ed0f21` (fix)
6. **Task 5: Data Analysis, Backup, and offline-proof stubs (5 files)** - `5ca0c3e` (test)

_All tasks are pure test-stub creation; no RED/GREEN/REFACTOR cycle applies since `autonomous: true` and `tdd` is not set on this plan._

## Files Created/Modified
- `test/domain/services/daily_totals_calculator_test.dart` - NUTR-01/CO2-02 aggregation stubs, null-snapshot handling
- `test/domain/services/personal_co2_multiplier_test.dart` - CO2-03 multiplier/dataQuality stubs
- `test/domain/services/notification_service_test.dart` - NOTIF-01/02 scheduling stubs
- `test/domain/services/backup_export_service_test.dart` - PRIV-01/02/03/04 export/restore stubs
- `test/domain/services/improvement_opportunity_finder_test.dart` - CO2-06 suggestion-engine stubs
- `test/domain/entities/meal_entry_nutrient_test.dart` - sugar/fiber/salt snapshot field stubs
- `test/data/local/co2_settings_dao_test.dart` - Co2SettingsDao single-row-convention stub
- `test/data/local/weight_dao_test.dart` - WeightDao entry/goal round-trip stubs
- `test/data/local/notification_prefs_dao_test.dart` - NotificationPrefsDao default/upsert stub
- `test/data/local/backup_metadata_dao_test.dart` - BackupMetadataDao round-trip stub
- `test/data/local/food_catalog_cache_co2_test.dart` - Phase-4 cache-path CO2 join regression stubs
- `test/data/repositories/co2_settings_repository_test.dart` - Co2SettingsRepository forward-only invariant stub
- `test/data/repositories/weight_repository_test.dart` - WeightRepository range/goal stubs
- `test/features/co2_settings/co2_settings_notifier_test.dart` - Co2SettingsNotifier build/save stub
- `test/features/weight/weight_notifier_test.dart` - WeightNotifier build/log stubs
- `test/features/dashboard/metric_card_test.dart` - MetricCard rendering/navigation stubs
- `test/features/dashboard/trend_sparkline_test.dart` - TrendSparkline metric-toggle stubs
- `test/features/co2_settings/co2_settings_screen_test.dart` - Co2SettingsScreen optional-fields stub
- `test/features/weight/weight_screen_test.dart` - WeightScreen chart/goal/reminder stubs
- `test/features/notifications/notification_prefs_ui_test.dart` - Meal reminder toggle/permission stubs
- `test/features/data_analysis/data_analysis_screen_test.dart` - DataAnalysisScreen breakdown/trend stubs
- `test/features/data_analysis/improvement_opportunities_test.dart` - CO2-06 widget placement/copy stubs
- `test/features/data_analysis/insights_timeline_test.dart` - InsightsTimeline pattern-detection stubs
- `test/features/backup/backup_restore_screen_test.dart` - BackupRestoreScreen danger-zone/restore stubs
- `test/core/offline_phase5_test.dart` - AUTH-07/PRIV-08 no-network-code-path proof stub

## Decisions Made
- Reused the Phase 2-4 group-level skip convention verbatim for both `test()` and `testWidgets()` bodies — `group('Name', skip: '...', () { testWidgets(...) })` compiles and skips cleanly, same as the existing `test()`-only precedent (`barcode_scan_notifier_test.dart`).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Missing whitespace between adjacent string literals**
- **Found during:** Task 5 verification (running `flutter analyze` across all new stub directories)
- **Issue:** `test/features/dashboard/trend_sparkline_test.dart`'s first `testWidgets` description used two adjacent string literals (`'...(CO2/Calories/'` + `'Protein)...'`) that concatenated without a space, triggering `missing_whitespace_between_adjacent_strings`
- **Fix:** Added a trailing space to the first literal so the concatenated string reads correctly
- **Files modified:** `test/features/dashboard/trend_sparkline_test.dart`
- **Verification:** `flutter analyze test/features/dashboard/trend_sparkline_test.dart` → "No issues found!"; `flutter test` on the file still skips cleanly
- **Committed in:** `6ed0f21`

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Cosmetic lint fix only, in a file this same plan created. No scope creep — all other analyzer findings in the verification run were pre-existing issues in unrelated Phase 1-4 test files (`food_catalog_dao_barcode_test.dart`, `food_catalog_dao_test.dart`, `food_item_test.dart`, `meal_entry_test.dart`, `mifflin_st_jeor_test.dart`, etc.) and are out of this plan's scope per the deviation-rules scope boundary.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Every Phase 5 execute plan (05-02 through 05-19) now has a named, compiling, skip-passing test file to target in its `<verify>` block — satisfies the Nyquist rule this plan set was designed for.
- `flutter test test/` baseline is green (214 tests, 0 failures) for the next plan to build on.
- No blockers.

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-27*

## Self-Check: PASSED

- All 25 stub files verified present on disk at exact `files_modified` paths
- All 6 commits (d20f1c2, 2567128, 3213ce8, df13721, 6ed0f21, 5ca0c3e) verified present in git log

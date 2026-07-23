---
phase: 04-meal-logging-core-10s-target
plan: 01
subsystem: testing
tags: [flutter, flutter_test, integration_test, drift, riverpod, tdd-stubs]

# Dependency graph
requires:
  - phase: 02-food-catalog-ingest-search
    provides: FoodItem entity, FoodCatalogDao, food_search feature scaffolding
  - phase: 03-barcode-scanning-co-factor-table
    provides: Wave-0 group-level-skip stub pattern, markTestSkipped() integration stub pattern
provides:
  - 16 Wave 0 test stub files covering every named test file referenced by subsequent Phase 4 execution plans (LOG-05 through LOG-13)
  - Concrete coverage map (test names + requirement tags) for the Phase 4 planner/executor to target
affects: [meal-logging-core Phase 4 plans 04-02 through 04-13]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Wave 0 unit/widget test stubs use group-level skip: 'ClassName not yet implemented' for atomic failure detection"
    - "Integration benchmark stubs use markTestSkipped() inside testWidgets body (not skip: arg) to exit cleanly without a device"

key-files:
  created:
    - test/data/local/meal_entry_dao_test.dart
    - test/data/local/user_food_dao_test.dart
    - test/data/local/food_catalog_dao_override_test.dart
    - test/data/repositories/meal_entry_repository_test.dart
    - test/data/repositories/user_food_repository_test.dart
    - test/domain/entities/meal_entry_test.dart
    - test/domain/entities/user_food_test.dart
    - test/domain/entities/serving_size_test.dart
    - test/features/meal_logging/meal_entry_notifier_test.dart
    - test/features/my_foods/user_food_notifier_test.dart
    - test/features/food_search/favorites_test.dart
    - test/features/my_foods/custom_food_form_test.dart
    - test/features/meal_logging/offline_logging_test.dart
    - test/features/food_search/portion_slot_form_test.dart
    - test/features/dashboard/meal_entry_row_test.dart
    - integration_test/meal_logging_benchmark_test.dart
  modified: []

key-decisions:
  - "Reused the Phase 2/3 Wave 0 stub conventions verbatim (group-level skip for unit/widget, markTestSkipped() body for integration) rather than inventing a new pattern"

patterns-established:
  - "Wave 0 stub plan pattern (established Phase 2, reused Phase 3, reused Phase 4): every execution plan in a phase must have a named test file with a concrete skip-labeled test list before Wave 1+ plans begin"

requirements-completed: [LOG-05, LOG-06, LOG-07, LOG-08, LOG-09, LOG-10, LOG-11, LOG-12, LOG-13]

# Metrics
duration: 9min
completed: 2026-07-23
---

# Phase 4 Plan 01: Meal Logging Core Wave 0 Test Stubs Summary

**16 Wave 0 test stub files (group-level-skip unit/widget stubs + one markTestSkipped() integration benchmark stub) giving every subsequent Phase 4 plan a concrete, named test target for LOG-05 through LOG-13 — zero production code changes.**

## Performance

- **Duration:** 9 min
- **Started:** 2026-07-23T12:57:00Z
- **Completed:** 2026-07-23T13:06:07Z
- **Tasks:** 2 completed
- **Files modified:** 16 created, 0 modified

## Accomplishments

- Created 8 data-layer test stubs (DAO, repository, domain entity) covering MealEntryDao merge/recent/favorites/soft-delete, UserFoodDao custom-food/override, FoodCatalogDao override search precedence, MealEntryRepository snapshot/undo/duplicate/restore, UserFoodRepository confidence-band persistence, and MealEntry/UserFood/ServingSize entity contracts
- Created 8 feature/UI/integration test stubs covering MealEntryNotifier, UserFoodNotifier, FavoriteNotifier, CustomFoodFormScreen, offline-logging invariant (LOG-12), PortionSlotForm, MealEntryRow, and the LOG-13 tap-to-saved <10s integration benchmark
- Full `flutter test test/` suite exits 0 with 87 tests passing and 65 newly-skipped labels reported (all Phase 1-3 tests remain green; all 16 new Phase 4 stubs skip atomically at the group level)
- `flutter analyze` on all seven touched directories reports zero issues in the 16 new files (pre-existing lint notes in unrelated Phase 2/3 files are out of scope and untouched)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create data-layer test stubs (DAO, repository, domain entity)** - `343a5f1` (test)
2. **Task 2: Create feature/UI/integration test stubs** - `689b9fa` (test)

**Plan metadata:** _pending final commit_

_Note: No TDD RED/GREEN cycle here — this plan only creates stubs (Wave 0), no implementation code._

## Files Created/Modified

- `test/data/local/meal_entry_dao_test.dart` - MealEntryDao stub (insert, merge, unit-mismatch, getRecent dedup/cap, re-log reorder, softDelete, favorites)
- `test/data/local/user_food_dao_test.dart` - UserFoodDao stub (required-field validation, override insert, findOverrideByFoodRef, revert, alphabetical listing)
- `test/data/local/food_catalog_dao_override_test.dart` - Override-aware search precedence stub (search, barcode lookup, revert-then-original-queryable)
- `test/data/repositories/meal_entry_repository_test.dart` - MealEntryRepository stub (snapshot capture, undo delta, duplicate bypasses merge, soft-delete/restore round-trip)
- `test/data/repositories/user_food_repository_test.dart` - UserFoodRepository stub (category-estimate vs manual CO2 confidence bands, override never mutates original, revert)
- `test/domain/entities/meal_entry_test.dart` - MealEntry entity stub (copyWith sentinel, live macro scaling, null-safe scaling)
- `test/domain/entities/user_food_test.dart` - UserFood entity stub (copyWith sentinel, isValid, reference-amount macro scaling)
- `test/domain/entities/serving_size_test.dart` - ServingSize entity stub (JSON round-trip, malformed-JSON safety)
- `test/features/meal_logging/meal_entry_notifier_test.dart` - MealEntryNotifier stub (build/logFood/editEntry/deleteEntry+undo/duplicate)
- `test/features/my_foods/user_food_notifier_test.dart` - UserFoodNotifier stub (saveCustomFood, saveOverride, revertOverride)
- `test/features/food_search/favorites_test.dart` - FavoriteNotifier stub (toggle, one-tap reuse, filled-star widget)
- `test/features/my_foods/custom_food_form_test.dart` - CustomFoodFormScreen widget stub (Save gating, serving-size row, manual-CO2 label, revert button visibility)
- `test/features/meal_logging/offline_logging_test.dart` - Offline core logging invariant stub (LOG-12: no OffApiClient/Connectivity calls)
- `test/features/food_search/portion_slot_form_test.dart` - PortionSlotForm widget stub (slot pre-selection, quantity chips, unit dropdown, live macro scaling, Save gating)
- `test/features/dashboard/meal_entry_row_test.dart` - MealEntryRow widget stub (swipe actions, row content, empty-slot header hiding)
- `integration_test/meal_logging_benchmark_test.dart` - LOG-13 tap-to-saved <10s benchmark stub (markTestSkipped body, awaits Plan 04-09 onward)

## Decisions Made

- Reused the exact Phase 2/3 Wave 0 stub conventions (group-level `skip:` for unit/widget groups, `markTestSkipped()` inside `testWidgets` body for the integration benchmark) rather than introducing a new pattern — keeps the codebase's stub idiom consistent across all three phases.

## Deviations from Plan

None - plan executed exactly as written. All 16 files created at the exact paths listed in `files_modified`, using only `flutter_test`/`integration_test` imports, with zero production code changes.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Every subsequent Phase 4 plan (04-02 through 04-13) now has a named, concrete test file with skip-labeled test cases in its `<verify>` block — satisfies the Nyquist rule for this phase.
- `flutter test test/` and `flutter analyze` both pass cleanly, confirming Wave 1+ plans can begin implementing production code against these stubs without pre-existing stub failures blocking their verification gates.
- No blockers identified.

---
*Phase: 04-meal-logging-core-10s-target*
*Completed: 2026-07-23*

## Self-Check: PASSED

All 16 created files verified present on disk. Both task commits (`343a5f1`, `689b9fa`) verified present in git log.

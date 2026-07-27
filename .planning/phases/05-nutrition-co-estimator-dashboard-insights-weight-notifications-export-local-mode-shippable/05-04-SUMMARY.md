---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 04
subsystem: database
tags: [drift, nutrition, meal-entry, food-item, sugar, fiber, salt]

# Dependency graph
requires:
  - phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable (05-03)
    provides: MealEntryTable sugar100gSnapshot/fiber100gSnapshot/saltSnapshot columns (schema-only)
provides:
  - FoodItem.sugar100g/fiber100g/salt100g nullable fields
  - MealEntry.sugar100gSnapshot/fiber100gSnapshot/saltSnapshot nullable fields
  - ScaledMacros.sugar/fiber/salt (live-scaled)
  - FoodCatalogDao._foodItemFromUserFoodRow mapping UserFoodRow.sugar/fiber/salt onto FoodItem
  - MealEntryRepository.logOrMerge persisting the three snapshot fields
affects: [dashboard, insights, nutrition-rollup]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Nullable-field end-to-end wiring: UserFoodRow -> FoodItem -> MealEntry draft -> MealEntryRow, honest-absence for off_ref/user_food_cache sources"

key-files:
  created: []
  modified:
    - lib/domain/entities/food_item.dart
    - lib/domain/entities/meal_entry.dart
    - lib/data/repositories/meal_entry_repository.dart
    - lib/data/local/daos/food_catalog_dao.dart
    - test/domain/entities/meal_entry_nutrient_test.dart

key-decisions:
  - "FoodItem.fromQueryRow deliberately never populates sugar100g/fiber100g/salt100g — off_ref/user_food_cache SQL queries have no such columns to select; fields stay null for every fromQueryRow-constructed instance (honest absence, not fabricated 0)"
  - "No referenceAmountG rescale added to _foodItemFromUserFoodRow for the new fields — mirrors this method's existing (non-rescaled) treatment of calories100g/protein100g/etc., a pre-existing Phase 4 simplification out of scope for this plan"

patterns-established:
  - "Sentinel copyWith pattern extended identically for FoodItem and MealEntry's three new nullable fields, matching the existing eight-field template exactly"

requirements-completed: [NUTR-01]

# Metrics
duration: ~5min
completed: 2026-07-27
---

# Phase 05 Plan 04: Nutrient Field Wiring (Sugar/Fiber/Salt) Summary

**FoodItem and MealEntry gain nullable sugar/fiber/salt fields end-to-end — personal overrides and custom foods now carry this data through logOrMerge into MealEntryTable, while off_ref/user_food_cache sources correctly persist null (no fabricated data).**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-07-27T21:15:29Z (immediately after 05-03 completion)
- **Completed:** 2026-07-27T21:18:45Z
- **Tasks:** 2
- **Files modified:** 4 (+ 1 test file de-skipped)

## Accomplishments
- `FoodItem` gains nullable `sugar100g`/`fiber100g`/`salt100g` (constructor, copyWith sentinel pattern, toString); documented as always-null for `fromQueryRow`-constructed instances
- `MealEntry` gains nullable `sugar100gSnapshot`/`fiber100gSnapshot`/`saltSnapshot` (constructor, `fromRow`, copyWith sentinel pattern, toString); `ScaledMacros` gains matching scaled `sugar`/`fiber`/`salt` fields computed via the existing pure `snapshot * gramsEquivalent / 100` rule
- `FoodCatalogDao._foodItemFromUserFoodRow` now maps `UserFoodRow.sugar/fiber/salt` onto the returned `FoodItem`
- `MealEntryRepository.logOrMerge` now persists `draft.sugar100gSnapshot`/`fiber100gSnapshot`/`saltSnapshot` into the constructed `MealEntryRow`
- `meal_entry_nutrient_test.dart` de-skipped with three real assertions covering scaling, null-propagation, and copyWith sentinel behavior

## Task Commits

Each task was committed atomically:

1. **Task 1: Add nutrient fields to FoodItem and MealEntry** - `2758ea4` (feat)
2. **Task 2: Wire the nutrient values through the override-mapping and repository write path** - `7014f3f` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified
- `lib/domain/entities/food_item.dart` - Added nullable sugar100g/fiber100g/salt100g fields (constructor, copyWith, toString); documented as never populated by fromQueryRow
- `lib/domain/entities/meal_entry.dart` - Added nullable sugar100gSnapshot/fiber100gSnapshot/saltSnapshot to MealEntry (constructor, fromRow, copyWith, toString); added matching scaled fields to ScaledMacros and the scaledMacros() function
- `lib/data/repositories/meal_entry_repository.dart` - logOrMerge now passes the three new snapshot fields into MealEntryRow
- `lib/data/local/daos/food_catalog_dao.dart` - _foodItemFromUserFoodRow now maps UserFoodRow.sugar/fiber/salt onto FoodItem
- `test/domain/entities/meal_entry_nutrient_test.dart` - De-skipped; three assertions replace the empty stub bodies

## Decisions Made
- `FoodItem.fromQueryRow` never touches the three new fields — off_ref/user_food_cache tables have no sugar/fiber/salt columns, so this is a documented permanent null, not an oversight
- No `referenceAmountG` rescale introduced in `_foodItemFromUserFoodRow` for the new fields — kept consistent with the method's existing non-rescaled treatment of every other macro field (pre-existing Phase 4 simplification, out of scope here)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `MealEntry`/`FoodItem` now carry sugar/fiber/salt end-to-end from write time; Phase 5 dashboard/insights plans can read `sugar100gSnapshot`/`fiber100gSnapshot`/`saltSnapshot` (and their scaled equivalents via `ScaledMacros`) directly without further plumbing
- No blockers identified

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-27*

## Self-Check: PASSED

All created/modified files verified present on disk; both task commit hashes (`2758ea4`, `7014f3f`) verified present in git log.

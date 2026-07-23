---
phase: 04-meal-logging-core-10s-target
plan: 06
subsystem: database
tags: [drift, sqlite, fts5, food-catalog, riverpod, merge-semantics]

# Dependency graph
requires:
  - phase: 04-04
    provides: "UserFoodDao.findOverrideByFoodRef/revert, FoodCatalogDao/FoodCatalogRepository (Phase 2/3)"
provides:
  - "FoodItem.source/sourceRowId/resolvedFoodRef — the single authoritative merge-key resolution rule"
  - "MealEntry.toFoodItem()/Favorite.toFoodItem() reverse-mapping extensions"
  - "FoodCatalogDao override precedence (LOG-11): searchLocalFoods and lookupByBarcodeWithCo2 both shadow catalog/cache rows with personal overrides"
affects: [04-09, 04-10, 04-11]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "FoodItem.resolvedFoodRef getter as the sole merge-key resolution rule (barcode ?? sourceRowId, never productName)"
    - "DAO-level override overlay: Step 0 override check runs before ATTACH-dependent state checks so overrides are independent of off_ref availability"

key-files:
  created:
    - lib/domain/entities/meal_entry_food_item_mapping.dart
    - test/domain/entities/meal_entry_food_item_mapping_test.dart
  modified:
    - lib/domain/entities/food_item.dart
    - lib/data/local/daos/food_catalog_dao.dart
    - lib/data/repositories/food_catalog_repository.dart
    - lib/core/di/app_providers.dart
    - test/domain/entities/food_item_test.dart
    - test/data/local/food_catalog_dao_override_test.dart

key-decisions:
  - "FoodItem.resolvedFoodRef throws StateError (never falls back to productName) when both barcode and sourceRowId are null"
  - "lookupByBarcodeWithCo2's Step 0 (personal override check) runs BEFORE the offRefPath null-check, since overrides live in co2diet.sqlite independent of off_ref ATTACH state"
  - "_foodItemFromUserFoodRow kept private to FoodCatalogDao (cross-domain off_ref-interop mapping concern, not part of UserFood's own domain contract)"

requirements-completed: [LOG-11]

duration: ~20min
completed: 2026-07-23
---

# Phase 4 Plan 06: FoodItem merge-key + override-aware food catalog Summary

**FoodCatalogDao now shadows catalog/cache rows with personal overrides in both search and barcode lookup, backed by a new `FoodItem.resolvedFoodRef` merge-key rule that never falls back to product-name matching.**

## Performance

- **Duration:** ~20 min
- **Tasks:** 2 completed
- **Files modified:** 8 (2 created, 6 modified)

## Accomplishments
- `FoodItem` gained `source`/`sourceRowId` (nullable, excluded from equality/hashCode) and a `resolvedFoodRef` getter implementing CONTEXT.md's Merge Semantics rule exactly: `barcode ?? sourceRowId`, throwing `StateError` when both are null — never falls back to `productName`.
- New `meal_entry_food_item_mapping.dart` provides `MealEntry.toFoodItem()`/`Favorite.toFoodItem()` extensions with a verified round-trip guarantee (`entry.toFoodItem().resolvedFoodRef == entry.foodRef` exactly), ready for Plans 04-10/04-11 to consume for edit-prefill.
- `FoodCatalogDao.searchLocalFoods` now overlays a personal override (from `UserFoodTable`) onto any off_ref/user_food_cache result that has one — the original row is only shadowed, never mutated.
- `FoodCatalogDao.lookupByBarcodeWithCo2` gained a Step 0 override check that runs *before* the `offRefPath` ATTACH null-check, so overrides resolve correctly even when off_ref isn't attached (unit-test isolation friendly) and take precedence over the existing high/medium-confidence chain.
- `app_providers.dart`'s `foodCatalogDaoProvider` now constructs `FoodCatalogDao` with `UserFoodDao` wired in explicitly (the generated `AppDatabase.foodCatalogDao` accessor can't pass the new named param).

## Task Commits

1. **Task 1: FoodItem.source/sourceRowId/resolvedFoodRef + MealEntry/Favorite → FoodItem mapping** - `ee168ad` (feat)
2. **Task 2: Override-aware search and barcode lookup** - `6905272` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified
- `lib/domain/entities/food_item.dart` - Added `source`/`sourceRowId` fields, `resolvedFoodRef` getter, updated `copyWith`/`fromQueryRow`/`toString`
- `lib/domain/entities/meal_entry_food_item_mapping.dart` - New file: `MealEntry.toFoodItem()`/`Favorite.toFoodItem()` extensions
- `lib/data/local/daos/food_catalog_dao.dart` - Optional `UserFoodDao` injection, override overlay in `searchLocalFoods`, Step 0 override check in `lookupByBarcodeWithCo2`, `_foodItemFromUserFoodRow` helper, `source`/`source_row_id` column aliases on all relevant SELECTs, plus a Rule-1 bugfix (see Deviations)
- `lib/data/repositories/food_catalog_repository.dart` - Doc-comment update noting override-transparency, no functional change
- `lib/core/di/app_providers.dart` - `foodCatalogDaoProvider` now wires `UserFoodDao` into `FoodCatalogDao`
- `test/domain/entities/food_item_test.dart` - New cases for `source`/`sourceRowId`/`resolvedFoodRef`
- `test/domain/entities/meal_entry_food_item_mapping_test.dart` - New file: round-trip tests for both extensions
- `test/data/local/food_catalog_dao_override_test.dart` - Replaced Wave-0 skip stub with 7 real tests (0 skips)

## Decisions Made
- `resolvedFoodRef` never falls back to `productName` under any circumstance — matches CONTEXT.md's Merge Semantics rule literally; a `StateError` on missing barcode+sourceRowId is treated as a query bug, not a legitimate state.
- Step 0 (personal override check) in `lookupByBarcodeWithCo2` was placed *before* the `offRefPath == null` early return (not strictly specified by the plan's task ordering language) — necessary so the override precedence is testable and functional independent of off_ref ATTACH state, matching the plan's own test-design guidance ("mock at the `_userFoodDao`-injection seam").
- Override test file (`food_catalog_dao_override_test.dart`) exercises the off_ref-override case (`overrideOfSource: 'off_ref'`) without requiring a real off_ref ATTACH, since Step 0 fires before ATTACH state is even checked — consistent with the plan's explicit "either... or mock at the seam" allowance and the file's "0 skips" done-criterion.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed wrong column names in the `user_food_cache_fts` SELECT (pre-existing, in the exact query this plan modifies)**
- **Found during:** Task 2 (writing `food_catalog_dao_override_test.dart`'s first real test with actual `user_food_cache_table` data)
- **Issue:** The `searchLocalFoods` query for `user_food_cache_fts` selected `t.calories_100g`, `t.protein_100g`, `t.carbs_100g`, `t.fat_100g` — but Drift's actual generated column names for `UserFoodCacheTable.calories100g`/`protein100g`/`carbs100g`/`fat100g` have no underscore before "100g" (Drift's camelCase→snake_case conversion only inserts an underscore before a capital letter; "100g" isn't capitalized). This caused a `SqliteException` ("no such column: t.calories_100g") on every real query against that table — silently swallowed by the existing `try/catch → debugPrint` pattern, so it never surfaced until this plan's tests were the first to insert real cache rows and query them (all prior Phase 2/3 unit tests exercised this path with an empty table, which never reaches the column-resolution step in a way that surfaces via a query result).
- **Fix:** Changed the four column references to `t.calories100g AS calories_100g`, `t.protein100g AS protein_100g`, `t.carbs100g AS carbs_100g`, `t.fat100g AS fat_100g` (correct source column, same output alias `FoodItem.fromQueryRow` expects).
- **Files modified:** `lib/data/local/daos/food_catalog_dao.dart`
- **Verification:** `food_catalog_dao_override_test.dart`'s `user_food_cache` search tests pass; full `test/data/local/ test/data/repositories/ test/domain/entities/` suite (115 tests) passes with zero regressions.
- **Committed in:** `6905272` (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Necessary for correctness — without this fix, `searchLocalFoods` would silently return empty results for every cached API food, masking a real data-loss-in-search bug that predates this plan. No scope creep — fix is confined to the exact query this plan's Task 2 was already modifying.

## Issues Encountered
None beyond the deviation documented above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `FoodItem.resolvedFoodRef` and `MealEntry.toFoodItem()`/`Favorite.toFoodItem()` are ready for Plan 04-09 (meal logging drafts keyed by `resolvedFoodRef`) and Plans 04-10/04-11 (edit-prefill from an existing entry/favorite).
- `FoodCatalogDao`'s override precedence (LOG-11) is fully wired through DI (`app_providers.dart`) — the UI-facing food search/barcode flows already consuming `foodCatalogDaoProvider`/`foodCatalogRepositoryProvider` get override-awareness automatically, no further plumbing needed.
- No blockers for subsequent Phase 4 plans.

---
*Phase: 04-meal-logging-core-10s-target*
*Completed: 2026-07-23*

## Self-Check: PASSED

All created/modified files verified present on disk; both task commits (`ee168ad`, `6905272`) verified present in `git log`.

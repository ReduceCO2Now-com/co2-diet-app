---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 02
subsystem: database
tags: [drift, sqlite, co2, food-catalog, off-api-cache]

requires:
  - phase: 04-meal-logging-core-10s-target
    provides: "FoodCatalogRepository/FoodCatalogDao cache-write and cache-read paths (Plan 02-04/03-05) that this plan closes a gap in"
provides:
  - "FoodCatalogRepository's two cache-write call sites store a real single-tag categoriesTags value instead of hardcoded NULL"
  - "FoodCatalogDao.searchLocalFoods' user_food_cache_fts branch LEFT JOINs off_ref.co2_factors on the cached categories_tags column, returning 'medium'-confidence CO2 estimates for previously API-cached products"
affects: [05-03, 05-04, 05-05, 05-06]

tech-stack:
  added: []
  patterns:
    - "Cache-write category tag: single most-specific tag (OFF API list order) stored via Value(item.categoriesTags?.first), never the full list"
    - "off_ref ATTACH guard mirrored on the user_food_cache_fts branch: two customSelect variants (joined vs. plain-NULL) selected by attachedDatabase.offRefPath != null, matching the existing off_ref.products branch convention"

key-files:
  created: []
  modified:
    - lib/data/repositories/food_catalog_repository.dart
    - lib/data/local/daos/food_catalog_dao.dart
    - test/data/local/food_catalog_cache_co2_test.dart

key-decisions:
  - "lookupByBarcode's macro-merge branch (local != null) reads apiResult.categoriesTags (not enriched.categoriesTags) as the cache-write tag source, since copyWith() never touches categoriesTags — enriched would always read null there"
  - "user_food_cache_fts join only ever reaches 'medium' confidence (CASE WHEN cf.co2e_median IS NOT NULL THEN 'medium' ELSE NULL END) since there is no per-cached-item override table, mirroring the off_ref.products branch's category-average tier"

requirements-completed: [CO2-02, NFR-05]

duration: ~10min
completed: 2026-07-27
---

# Phase 5 Plan 02: CO2 Cache-Path Gap Fix Summary

**Products fetched once via the OFF API fallback now show a `medium`-confidence CO2 estimate on later offline local searches, by storing the resolved category tag at cache-write time and joining `off_ref.co2_factors` on it at cache-read time.**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-07-27T20:58:00Z (approx)
- **Completed:** 2026-07-27T21:03:05Z
- **Tasks:** 2 completed
- **Files modified:** 3 (2 lib, 1 test)

## Accomplishments
- `FoodCatalogRepository.lookupByBarcode` (both its "no local match" and "merge API macros + local CO2" branches) and `.searchAndCache` now store the single most-specific category tag into `UserFoodCacheTableCompanion.categoriesTags`, instead of the previous unconditional `Value(null)`
- `FoodCatalogDao.searchLocalFoods`'s `user_food_cache_fts` query branch now `LEFT JOIN`s `off_ref.co2_factors` on `t.categories_tags`, populating `co2e_100g`/`confidence_band` exactly like the `off_ref.products` branch's category-average tier
- Join is guarded by `attachedDatabase.offRefPath != null` (two separate `customSelect` query strings), so every existing unit test that constructs `FoodCatalogDao` without an ATTACHed off_ref keeps getting plain `NULL` columns unchanged
- `test/data/local/food_catalog_cache_co2_test.dart` de-skipped with 3 real assertions (matched-tag → populated `medium`, unmatched-tag → null/null, no-ATTACH → null/null without erroring) — all passing
- Full plan verification green: `flutter test test/data/local/ test/data/repositories/food_catalog_repository_test.dart` — 62 passed, 9 skipped (pre-existing Wave-0/integration skips), 0 failed; `flutter analyze lib/data/` — 0 errors/warnings (6 pre-existing info-level lints, unrelated to this plan's changes, confirmed via before/after diff comparison)

## Task Commits

Each task was committed atomically:

1. **Task 1: Store the primary category tag at cache-write time** - `5216d2f` (fix)
2. **Task 2: Join co2_factors into the user_food_cache_fts search branch and de-skip the regression test** - `e2e33cd` (fix)

## Files Created/Modified
- `lib/data/repositories/food_catalog_repository.dart` - Both `UserFoodCacheTableCompanion.insert(...)` call sites (in `lookupByBarcode` and `searchAndCache`) now compute and store a real `categoriesTags` value
- `lib/data/local/daos/food_catalog_dao.dart` - `searchLocalFoods`'s `user_food_cache_fts` branch gains a guarded `LEFT JOIN off_ref.co2_factors`; doc comment updated to describe the new join instead of the old "NOT enriched" limitation
- `test/data/local/food_catalog_cache_co2_test.dart` - De-skipped; 3 real tests build a real off_ref.sqlite fixture (`co2_factors` only, following `food_catalog_dao_ranking_test.dart`'s pattern) and a directly-inserted cache row to assert the full write→read round trip

## Decisions Made
- `apiResult.categoriesTags` (not `enriched.categoriesTags`) is the correct source in the macro-merge branch of `lookupByBarcode`, because `FoodItem.copyWith()` never sets `categoriesTags` — using `enriched` there would silently always read `null`
- The `user_food_cache_fts` join is capped at `'medium'` confidence by construction (no override table exists for cached items) — this matches the plan's explicit expectation, not a limitation introduced here

## Deviations from Plan

None - plan executed exactly as written. Two minor local lint cleanups (cascade-invocation and redundant-argument-value fixes) were applied directly during test authoring, before the task commit, to keep the new test file at zero analyzer issues — not treated as a separate deviation since they never affected committed code correctness.

## Issues Encountered
None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- The Phase-4 CO2 cache-path gap (RESEARCH.md Pitfall 4) is fully closed; `FoodCatalogRepository`/`FoodCatalogDao` now round-trip category data end-to-end for API-cached products
- Plan 05-03 onward (CO2 Settings, Dashboard, Insights) can build on a complete, gap-free food-catalog CO2 data path with no known outstanding cache-path issues
- No blockers

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-27*

## Self-Check: PASSED

All files created/modified verified present; both task commits (5216d2f, e2e33cd) verified present in git log.

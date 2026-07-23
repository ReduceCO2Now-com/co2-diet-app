---
phase: 04-meal-logging-core-10s-target
plan: 04
subsystem: database
tags: [drift, sqlite, dao, meal-logging, custom-food]

# Dependency graph
requires:
  - phase: 04-meal-logging-core-10s-target plan 02
    provides: MealEntryTable/FavoriteTable/UserFoodTable sync-safe schema
  - phase: 04-meal-logging-core-10s-target plan 03
    provides: MealSlot/PortionUnit/UserFood domain entities and repository interfaces
provides:
  - MealEntryDao — insertOrMerge, getEntriesForToday, getRecent, softDelete/restore, adjustQuantity, duplicate, toggleFavorite/isFavorite/getFavorites/touchFavoriteUsage
  - UserFoodDao — insert (with defense-in-depth guard), updateFood, findOverrideByFoodRef, revert (hard delete), getAllAlphabetical
  - AppDatabase now exposes db.mealEntryDao and db.userFoodDao
affects: [04-05, 04-06, 04-07, 04-08, 04-09, 04-10, 04-11, 04-12, 04-13]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "TableInfo.map(QueryRow.data) converts raw customSelect rows to typed data classes without a second query round-trip"
    - "SQLite bare-column-in-aggregate idiom (SELECT *, MAX(col) ... GROUP BY) picks the full row for the max value per group — used for getRecent dedup"
    - "DAO methods that shadow a DatabaseAccessor base method name with an incompatible signature are an invalid_override compile error, not a harmless hide — renamed UserFoodDao's update to updateFood"

key-files:
  created:
    - lib/data/local/daos/meal_entry_dao.dart
    - lib/data/local/daos/user_food_dao.dart
    - test/data/local/meal_entry_dao_test.dart (filled in from Wave 0 stub)
    - test/data/local/user_food_dao_test.dart (filled in from Wave 0 stub)
  modified:
    - lib/data/local/app_database.dart (registered MealEntryDao/UserFoodDao)

key-decisions:
  - "UserFoodDao.insert guard uses .present checks (not .value == null) — Value<T>.value throws a TypeError when absent for a non-nullable T, so .present is the only safe way to detect a missing field"
  - "UserFoodDao's update method renamed to updateFood — DatabaseAccessor already declares a generic update<Tbl,R>(TableInfo) method; a same-named method with an incompatible signature is an invalid_override, not a shadow"
  - "MealEntryTableCompanion/UserFoodTableCompanion typed inserts already carry co2MethodologyVersionSnapshot/co2MethodologyVersion end-to-end via MealEntryRow.toCompanion(false) and the caller-provided Companion — no special-casing needed for the pre-04-04 gap-fix column"

patterns-established:
  - "Raw customSelect + TableInfo.map(row.data) pattern for merge-check reads that need the typed row back (not just booleans/counts)"

requirements-completed:
  - LOG-05
  - LOG-06
  - LOG-07
  - LOG-08
  - LOG-09
  - LOG-10
  - LOG-11

# Metrics
duration: ~20min
completed: 2026-07-23
---

# Phase 4 Plan 04: MealEntryDao + UserFoodDao Summary

**Query layer for meal logging (LOG-05/07/08/09) and custom foods/overrides (LOG-10/11) — parameterized `customSelect`/`customUpdate` plus typed Drift Companion inserts, both DAOs registered in `AppDatabase`.**

## Performance

- **Duration:** ~20 min
- **Completed:** 2026-07-23T18:21:49Z
- **Tasks:** 2 completed
- **Files modified:** 6 (2 DAOs created, 2 DAO test files filled in, app_database.dart + app_database.g.dart updated; 2 DAO `.g.dart` part files generated)

## Accomplishments

- `MealEntryDao` covers `MealEntryTable` + `FavoriteTable`: `insertOrMerge` merges on `(food_ref, food_ref_source, meal_slot, log_date, unit)` string equality (never a SQL date function), `getRecent` dedups via the SQLite bare-column-in-aggregate idiom, soft-delete/restore/adjustQuantity/duplicate for edit flows, favorite toggle + one-tap usage tracking.
- `UserFoodDao` covers `UserFoodTable`: DAO-level guard rejects missing/blank name or missing calories before any SQL runs, `findOverrideByFoodRef`/`revert` support the override lifecycle (hard delete, documented deviation from the sync-safe soft-delete convention), `getAllAlphabetical` with an optional case-insensitive substring filter.
- Both DAOs registered in `AppDatabase.daos`; `app_database.g.dart` regenerated — `db.mealEntryDao` and `db.userFoodDao` now available.
- 13 new tests (8 `MealEntryDao`, 5 `UserFoodDao`) replace the Wave 0 skip stubs; all pass with 0 skips. Full `test/data/local/` suite: 41 tests, 0 failures (7 pre-existing intentional skips unrelated to this plan).

## Task Commits

Each task was committed atomically:

1. **Task 1: MealEntryDao (meal entries + favorites)** - `823afff` (feat)
2. **Task 2: UserFoodDao + AppDatabase DAO registration** - `453f8c4` (feat)

**Plan metadata:** committed as part of this SUMMARY commit.

## Files Created/Modified

- `lib/data/local/daos/meal_entry_dao.dart` - `MealEntryDao`: insert/merge, recent, soft-delete/restore, adjustQuantity, duplicate, favorites
- `lib/data/local/daos/meal_entry_dao.g.dart` - generated `_$MealEntryDaoMixin`
- `lib/data/local/daos/user_food_dao.dart` - `UserFoodDao`: insert guard, updateFood, findOverrideByFoodRef, revert, getAllAlphabetical
- `lib/data/local/daos/user_food_dao.g.dart` - generated `_$UserFoodDaoMixin`
- `lib/data/local/app_database.dart` - registered `MealEntryDao`/`UserFoodDao` in `@DriftDatabase(daos: [...])`
- `lib/data/local/app_database.g.dart` - regenerated with `db.mealEntryDao`/`db.userFoodDao` accessors
- `test/data/local/meal_entry_dao_test.dart` - 8 tests against `AppDatabase(NativeDatabase.memory())`
- `test/data/local/user_food_dao_test.dart` - 5 tests against `AppDatabase(NativeDatabase.memory())`

## Decisions Made

- **`UserFoodDao.insert` guard uses `.present` checks, not `.value == null`:** the plan text specified `draft.calories.value == null`, but `calories`'s generated field type is `Value<double>` (non-nullable `T`) — calling `.value` on an absent `Value<double>` throws a `TypeError` (`null as double`) rather than returning `null`. Implemented as `!draft.name.present || draft.name.value.trim().isEmpty || !draft.calories.present` instead, which correctly detects "field never provided" without triggering the cast failure. [Rule 1 — bug fix in the plan's literal code.]
- **Renamed `UserFoodDao.update` to `updateFood`:** `DatabaseAccessor` (the DAO base class) already declares a generic `update<Tbl extends Table, R>(TableInfo<Tbl, R>)` method used to build typed update statements (`update(userFoodTable)`). Declaring a method literally named `update` with a different signature on the DAO subclass is not a harmless override/shadow — the analyzer reports it as `invalid_override` (a compile error), since Dart requires same-named methods in a subclass to be compatible overrides. Renamed to `updateFood(String id, UserFoodTableCompanion changes)` so the inherited `update(userFoodTable)` builder remains callable inside the method body. [Rule 1 — blocking compile error, avoided by picking a non-colliding name.]
- **No special-casing needed for `co2MethodologyVersionSnapshot`/`co2MethodologyVersion`:** both new columns from the pre-04-04 gap fix are ordinary fields on `MealEntryRow`/`UserFoodRow` and their generated Companions. `MealEntryDao.insertOrMerge`'s insert path uses `draft.toCompanion(false)`, which carries the snapshot column through automatically; `UserFoodDao.insert` accepts a caller-provided `UserFoodTableCompanion` directly, so the caller (Plan 04-05+ repository layer) is responsible for setting `co2MethodologyVersion` alongside `confidenceBand` — no DAO-side logic needed either way.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `UserFoodDao.insert` required-field guard corrected from `.value == null` to `.present`**
- **Found during:** Task 2 (`UserFoodDao.insert`)
- **Issue:** Plan's literal guard code (`draft.calories.value == null`) throws a `TypeError` instead of evaluating to a boolean when `calories` is absent, because `Value<double>.value` casts `null` to a non-nullable `double`.
- **Fix:** Guard checks `.present` on both `name` and `calories` before touching `.value`.
- **Files modified:** `lib/data/local/daos/user_food_dao.dart`
- **Verification:** `UserFoodDao.insert insert requires name and calories; throws or rejects when either is missing` test passes for all three missing-field cases (null name, null calories, blank name).
- **Committed in:** `453f8c4` (Task 2 commit)

**2. [Rule 1 - Bug] `UserFoodDao.update` renamed to `updateFood`**
- **Found during:** Task 2 (`UserFoodDao.update`)
- **Issue:** Plan specified a method named `update(String id, UserFoodTableCompanion changes)`, but this name collides with `DatabaseAccessor.update<Tbl,R>(TableInfo)` (the base class's typed update-statement builder) with an incompatible signature — `flutter analyze` reports `invalid_override`, a compile error, not just a lint.
- **Fix:** Renamed the DAO method to `updateFood`; body calls the inherited `update(userFoodTable)` builder directly (no longer shadowed).
- **Files modified:** `lib/data/local/daos/user_food_dao.dart`
- **Verification:** `flutter analyze lib/data/local/daos/` reports no issues; `dart run build_runner build` and `flutter test` both succeed.
- **Committed in:** `453f8c4` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (both Rule 1 — bugs in the plan's literal example code, not scope changes).
**Impact on plan:** Both fixes were required for the code to compile/behave correctly; the public DAO surface still matches the plan's intent (required-field rejection, typed update-by-id). No scope creep.

## Issues Encountered

- `dart run build_runner build --delete-conflicting-outputs` regenerated two unrelated generated files (`lib/core/router/app_router.g.dart`, `lib/features/barcode_scan/providers/barcode_scan_notifier.g.dart`) as a mechanical side effect — build_runner regenerates every stale generated file in the project, not just the ones touched by this plan. These are cosmetic-only diffs (a `@riverpod` hash bump and doc-comment bracket→backtick normalization) with no behavioral change, entirely unrelated to Plan 04-04's `[foodRef]`/DAO scope. Per the scope boundary rule, they were left uncommitted rather than folded into this plan's commits or reverted — logged here rather than fixed, since fixing/reverting either would itself be an out-of-scope action.
- The pre-existing `flutter analyze lib/data/local/daos/` output already carried 5 info-level lints in `food_catalog_dao.dart` (1 `comment_references`, 4 `lines_longer_than_80_chars`) predating this plan; `food_catalog_dao.dart` was read for precedent but never modified, so these were left as-is and logged to `.planning/phases/04-meal-logging-core-10s-target/deferred-items.md`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `db.mealEntryDao` and `db.userFoodDao` are available for the repository layer (Plan 04-05 onward) to build `IMealEntryRepository`/`IUserFoodRepository` implementations against.
- `MealEntryDao.insertOrMerge` accepts a fully-formed `MealEntryRow` (including `co2MethodologyVersionSnapshot`), so the repository layer is responsible for stamping that field (and `confidenceBandSnapshot`) at construction time from whatever produced the CO₂ value — no DAO-side derivation.
- `UserFoodDao.revert`'s hard-delete (vs. the `SyncSafeTable` soft-delete convention used everywhere else) is flagged in-code and in this summary as a Phase 7 sync follow-up: hard deletes on `user_food_table` will need their own propagation mechanism since there's no tombstone row left to sync.
- No blockers for Plan 04-05.

---
*Phase: 04-meal-logging-core-10s-target*
*Completed: 2026-07-23*

## Self-Check: PASSED

- FOUND: lib/data/local/daos/meal_entry_dao.dart
- FOUND: lib/data/local/daos/user_food_dao.dart
- FOUND: test/data/local/meal_entry_dao_test.dart
- FOUND: test/data/local/user_food_dao_test.dart
- FOUND: .planning/phases/04-meal-logging-core-10s-target/deferred-items.md
- FOUND commit: 823afff (Task 1)
- FOUND commit: 453f8c4 (Task 2)

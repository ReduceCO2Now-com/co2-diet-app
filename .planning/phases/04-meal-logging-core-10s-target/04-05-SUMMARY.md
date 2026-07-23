---
phase: 04-meal-logging-core-10s-target
plan: 05
subsystem: database
tags: [drift, riverpod, repository-pattern, mocktail, meal-logging, co2]

# Dependency graph
requires:
  - phase: 04-meal-logging-core-10s-target (Plan 04-04)
    provides: MealEntryDao (insertOrMerge/getEntriesForToday/getRecent/duplicate/softDelete/restore/favorites) and UserFoodDao (insert/updateFood/getById/findOverrideByFoodRef/revert/getAllAlphabetical), both registered on AppDatabase
provides:
  - MealEntryRepository — concrete IMealEntryRepository (meal-entry CRUD + favorites orchestration over MealEntryDao)
  - UserFoodRepository — concrete IUserFoodRepository (custom-food/override orchestration over UserFoodDao)
  - MealEntry.fromRow / Favorite.fromRow / UserFood.fromRow factory constructors (Drift-row-to-entity mapping, owned exclusively by this plan)
  - meal_logging_providers.dart — 4 keep-alive Riverpod providers (mealEntryDao, userFoodDao, mealEntryRepository, userFoodRepository)
affects: [04-06, 04-07, 04-08, 04-09, 04-10, 04-11, 04-12, 04-13]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Repository row<->entity mapping via fromRow factories on the domain entity itself (not a separate mapper class), matching the plan's explicit ownership decision"
    - "logOrMerge/saveCustomFood/saveOverride build the persisted Drift row/Companion directly from the caller-supplied domain entity's already-populated fields — repository never re-fetches or re-derives snapshot/CO2 data from a source product"
    - "mocktail mocking the concrete DAO class directly (`class _MockX extends Mock implements XDao {}`) rather than via a hand-rolled test-only interface, since assertions need to inspect the exact Drift Row/Companion passed through"

key-files:
  created:
    - lib/data/repositories/meal_entry_repository.dart
    - lib/data/repositories/user_food_repository.dart
    - lib/core/di/meal_logging_providers.dart
    - lib/core/di/meal_logging_providers.g.dart
  modified:
    - lib/domain/entities/meal_entry.dart
    - lib/domain/entities/favorite.dart
    - lib/domain/entities/user_food.dart
    - test/data/repositories/meal_entry_repository_test.dart
    - test/data/repositories/user_food_repository_test.dart

key-decisions:
  - "MealEntry.fromRow/Favorite.fromRow/UserFood.fromRow live directly on the domain entity classes (not a separate DTO/mapper file) — matches the plan's explicit exclusive-ownership instruction and mirrors the rest of the codebase's factory-constructor conventions (e.g. FoodItem)."
  - "co2MethodologyVersionSnapshot/co2MethodologyVersion are pure pass-through fields in this plan's mapping (both directions) — this repository layer does not compute/derive a methodology version string; it only carries whatever the caller already populated on the draft MealEntry/UserFood through to the Drift row and back. No new methodology-version constant was introduced."
  - "toggleFavorite returns the row it attempted to persist (the pre-toggle snapshot) rather than re-querying afterward — matches IMealEntryRepository's documented contract that callers must call isFavorite separately to disambiguate insert-vs-delete outcomes."
  - "`import 'package:drift/drift.dart' hide isNull;` used in user_food_repository_test.dart — drift's top-level isNull collides with flutter_test's isNull matcher when both packages are imported into the same test file (same class of issue as the existing Phase 01-07 `hide isNotNull` precedent, just the sibling matcher)."

requirements-completed: [LOG-05, LOG-06, LOG-07, LOG-08, LOG-09, LOG-10, LOG-11]

# Metrics
duration: 24min
completed: 2026-07-23
---

# Phase 4 Plan 5: Meal-Logging Repositories + DI Summary

**MealEntryRepository and UserFoodRepository implemented over Plan 04-04's DAOs, with fromRow row-to-entity mapping added to the domain entities and four keep-alive Riverpod DI providers wired in a new meal_logging_providers.dart.**

## Performance

- **Duration:** 24 min
- **Started:** 2026-07-23T20:27:21+02:00 (after 04-04 plan-metadata commit)
- **Completed:** 2026-07-23T20:51:05+02:00
- **Tasks:** 2
- **Files modified:** 9 (4 created, 5 modified)

## Accomplishments

- `MealEntryRepository` implements every `IMealEntryRepository` method (meal-entry CRUD + favorites), with `logOrMerge`/`toggleFavorite` building the persisted Drift row directly from the caller-supplied entity's snapshot fields — never re-fetching source data.
- `UserFoodRepository` implements every `IUserFoodRepository` method, with `saveCustomFood`/`saveOverride` re-validating `isValid`/`overrideOfRef` at the repository boundary (T-04-05-01 defense in depth) before ever calling the DAO.
- `MealEntry.fromRow`, `Favorite.fromRow`, and `UserFood.fromRow` factory constructors added to the three domain entities — the single, exclusive place the Drift-row-to-entity mapping direction lives (Plan 04-03 never imports `package:drift`).
- `meal_logging_providers.dart` exposes `mealEntryDaoProvider`, `userFoodDaoProvider`, `mealEntryRepositoryProvider`, `userFoodRepositoryProvider`, all `@Riverpod(keepAlive: true)`, mirroring `app_providers.dart`'s established pattern; codegen run via `dart run build_runner build --delete-conflicting-outputs`.
- Both repository test files filled in with mocktail-mocked DAOs (0 skips): 21 tests in `meal_entry_repository_test.dart`, 12 tests (+1 fromRow-specific) in `user_food_repository_test.dart`.

## Task Commits

Each task was committed atomically:

1. **Task 1: MealEntryRepository** - `7f6e2a9` (feat)
2. **Task 2: UserFoodRepository + DI providers** - `d15f431` (feat)

**Plan metadata:** (pending — this commit)

## Files Created/Modified

- `lib/data/repositories/meal_entry_repository.dart` - Concrete `IMealEntryRepository`: logOrMerge/getEntriesForToday/getRecent/editEntry/deleteEntry/restoreEntry/duplicateEntry/undoMergeDelta/isFavorite/toggleFavorite/getFavorites/touchFavoriteUsage, all row↔entity mapped, zero direct SQL
- `lib/data/repositories/user_food_repository.dart` - Concrete `IUserFoodRepository`: saveCustomFood/saveOverride (shared `_save` insert-or-update path)/revertOverride/findOverrideForFoodRef/getAllAlphabetical/getById
- `lib/core/di/meal_logging_providers.dart` - 4 keep-alive Riverpod providers wiring the DAOs and repositories into the DI graph
- `lib/core/di/meal_logging_providers.g.dart` - Generated Riverpod provider code
- `lib/domain/entities/meal_entry.dart` - Added `MealEntry.fromRow(MealEntryRow)` factory
- `lib/domain/entities/favorite.dart` - Added `Favorite.fromRow(FavoriteRow)` factory
- `lib/domain/entities/user_food.dart` - Added `UserFood.fromRow(UserFoodRow)` factory
- `test/data/repositories/meal_entry_repository_test.dart` - 21 tests covering snapshot capture, undo/duplicate/soft-delete/restore, fromRow mapping, favorites, read paths
- `test/data/repositories/user_food_repository_test.dart` - 12 tests covering validation guards, category-estimate vs. manual CO2 nullability, override independence, revert, fromRow mapping

## Decisions Made

- `MealEntry.fromRow`/`Favorite.fromRow`/`UserFood.fromRow` are factory constructors on the entities themselves (not a standalone mapper class) — this is what the plan's `<action>` sections explicitly specified, and it keeps the "exclusive ownership" property easy to verify (`grep fromRow` finds all three in one place).
- **CO2-04 methodology-version pass-through (see `important_context` investigation):** this plan's repository layer does not compute or derive `co2MethodologyVersionSnapshot`/`co2MethodologyVersion` — it only carries whatever value the caller already set on the domain entity through to the persisted Drift row (and back via `fromRow`), exactly mirroring how `confidenceBand(Snapshot)` is already handled. There is no separate methodology-version constant to introduce here because this plan never independently derives a CO2 estimate; that responsibility (setting `co2Source`/`confidenceBand`/`co2MethodologyVersion` on a `UserFood` from a category-estimate lookup, or a `confidenceBandSnapshot`/`co2MethodologyVersionSnapshot` on a `MealEntry` from the currently-displayed product) belongs to the callers in later plans (the CO2 estimate service and the portion/slot form notifier, Plan 04-07+). Verified this is a real pass-through, not an accidental drop, via the `logOrMerge`/`saveCustomFood` snapshot-fidelity tests, which assert every field — including these two — round-trips byte-for-byte.
- `toggleFavorite` returns the row it attempted to persist (matches the pre-toggle draft snapshot) rather than re-querying the DB afterward — `MealEntryDao.toggleFavorite` returns `void` and already performs the insert-vs-delete presence check internally; per `IMealEntryRepository`'s documented contract, callers must call `isFavorite` separately to disambiguate the resulting boolean state.
- Both repository tests mock the concrete DAO classes directly via mocktail (`class _MockMealEntryDao extends Mock implements MealEntryDao {}`), rather than the hand-rolled minimal-interface wrapper pattern used in `food_catalog_repository_test.dart` — the `<behavior>` spec requires asserting the exact `MealEntryRow`/`UserFoodTableCompanion` passed to the DAO byte-for-byte, which needs the real Drift types in scope.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `isNull` import collision in user_food_repository_test.dart**
- **Found during:** Task 2 (running `flutter test`)
- **Issue:** `package:drift/drift.dart` and `flutter_test`'s `matcher` both export a top-level `isNull` symbol; importing both unqualified causes a compile error ("'isNull' is imported from both ..."). Same class of issue as the existing Phase 01-07 precedent (`hide isNotNull`), just the sibling symbol.
- **Fix:** Changed the test's drift import to `import 'package:drift/drift.dart' hide isNull;` — then discovered the import wasn't even needed (no direct `Value`/`Expression` usage in the test body, since `.value` is a plain getter on the already-imported `UserFoodTableCompanion` type) and removed the import entirely.
- **Files modified:** test/data/repositories/user_food_repository_test.dart
- **Committed in:** d15f431 (Task 2 commit)

**2. [Rule 1 - Bug] Redundant default-value test arguments**
- **Found during:** Task 1 (running `flutter analyze`)
- **Issue:** Two test helper calls passed `id: 'entry-1'` explicitly even though it matched the helper's default value (`avoid_redundant_argument_values` lint).
- **Fix:** Removed the redundant named arguments.
- **Files modified:** test/data/repositories/meal_entry_repository_test.dart
- **Committed in:** 7f6e2a9 (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 lint/bug)
**Impact on plan:** Both fixes are test-file-only compile/lint corrections with no behavioral impact on the repositories. No scope creep.

## Issues Encountered

None beyond the deviations documented above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `IMealEntryRepository`/`IUserFoodRepository` are now concretely implemented and wired into DI (`mealEntryRepositoryProvider`/`userFoodRepositoryProvider`), unblocking Plan 04-06 (search/barcode override-precedence integration) and Plan 04-07 (portion/slot form notifiers) to consume them directly.
- Both `MealEntry.fromRow`/`Favorite.fromRow`/`UserFood.fromRow` are stable public factory constructors any later plan (04-09/04-10/04-11) can reuse if it needs to map a raw row without going through the full repository.
- No blockers. The "snapshot, not reference" invariant and the CO2-04 methodology-version pass-through are both verified by test, ready for Plan 04-07 to populate them from live product data at log time.

---
*Phase: 04-meal-logging-core-10s-target*
*Completed: 2026-07-23*

## Self-Check: PASSED

All created files verified present; both task commits (`7f6e2a9`, `d15f431`) verified in git log.

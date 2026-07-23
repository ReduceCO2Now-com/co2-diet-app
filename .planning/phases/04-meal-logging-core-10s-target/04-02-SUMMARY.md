---
phase: 04-meal-logging-core-10s-target
plan: 02
subsystem: database
tags: [drift, sqlite, schema-migration, sync-safe, json-type-converter]

# Dependency graph
requires:
  - phase: 04-meal-logging-core-10s-target (Plan 04-01)
    provides: Wave 0 test stubs for meal logging core (data-layer + feature/UI/integration)
provides:
  - MealEntryTable, FavoriteTable, UserFoodTable Drift tables (SyncSafeTable mixin)
  - AppDatabase.schemaVersion bumped 2 -> 3 with onUpgrade from<3 migration branch
  - Minimal stand-in domain types (MealSlot, PortionUnit, ServingSize) unblocking schema
    compilation ahead of Plan 04-03
affects: [04-03, 04-04, 04-05, 04-06, 04-07]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "SyncSafeTable mixin applied to all three new Phase 4 tables (matches UserFoodCacheTable precedent)"
    - "textEnum<T>() for MealSlot/PortionUnit columns (Enum.name storage, append-only)"
    - "TypeConverter.json2 (not deprecated .json()) for UserFoodTable.quickServingSizes"
    - "No .references() FK against off_ref — foodRef/overrideOfRef are plain text columns validated at app layer"

key-files:
  created:
    - lib/data/local/tables/meal_entry_table.dart
    - lib/data/local/tables/favorite_table.dart
    - lib/data/local/tables/user_food_table.dart
    - lib/domain/entities/meal_slot.dart (stand-in — Plan 04-03 owns authoritative version)
    - lib/domain/entities/portion_unit.dart (stand-in — Plan 04-03 owns authoritative version)
    - lib/domain/entities/serving_size.dart (stand-in — Plan 04-03 owns authoritative version)
  modified:
    - lib/data/local/app_database.dart
    - lib/data/local/app_database.g.dart
    - lib/data/local/migrations/migration_strategy.dart
    - tool/generate_schema_v1.dart

key-decisions:
  - "Created minimal stand-in MealSlot/PortionUnit/ServingSize domain files (Rule 3 — missing referenced file) because Plan 04-03 had not landed yet and the 2->3 migration branch cannot compile/verify without them"
  - "app_database.dart must import meal_slot.dart/portion_unit.dart/serving_size.dart directly — part files (app_database.g.dart) share the enclosing library's import scope and cannot declare their own imports; the Dart CFE (unlike the analyzer server) requires these types resolvable from app_database.dart's own imports"

patterns-established:
  - "Cross-plan schema/domain dependency: a table plan referencing not-yet-created domain enums is unblocked with a minimal stand-in rather than left uncompilable, since the alternative breaks the entire app's compilation (app_database.dart is imported everywhere)"

requirements-completed: [LOG-05, LOG-06, LOG-07, LOG-08, LOG-10, LOG-11]

# Metrics
duration: ~30min
completed: 2026-07-23
---

# Phase 04 Plan 02: Sync-Safe Meal Logging Schema Summary

**AppDatabase bumped to schemaVersion 3 with MealEntryTable/FavoriteTable/UserFoodTable (all SyncSafeTable), migration-tested via in-memory create + onUpgrade branch; unblocked with minimal MealSlot/PortionUnit/ServingSize stand-ins ahead of Plan 04-03.**

## Performance

- **Duration:** ~30 min
- **Completed:** 2026-07-23
- **Tasks:** 2 completed
- **Files modified:** 10 (3 created tables, 3 created domain stand-ins, 4 modified: app_database.dart, app_database.g.dart, migration_strategy.dart, tool/generate_schema_v1.dart)

## Accomplishments
- `MealEntryTable`, `FavoriteTable`, `UserFoodTable` created with the exact column layout specified in the plan, all `with SyncSafeTable`, matching `UserFoodCacheTable`'s style
- `AppDatabase.schemaVersion` bumped 2 → 3; three new tables registered in `@DriftDatabase(tables: [...])`
- `onUpgrade` `from < 3` branch creates the three new tables (parallel to the existing `from < 2` branch); `onCreate`/`createAll()` already covers fresh installs
- Verified in a fresh in-memory `AppDatabase`: `schemaVersion == 3` and `sqlite_master` contains `meal_entry_table`, `favorite_table`, `user_food_table`
- `tool/generate_schema_v1.dart` carries an explicit out-of-scope note (hardcoded to `schema_version: 1`, does not track the live schemaVersion)
- No `.references()` FK used against any `off_ref.*` table anywhere in the new tables

## Task Commits

1. **Task 1: Create MealEntryTable, FavoriteTable, UserFoodTable** - `88b1bcc` (feat)
2. **Task 2: Wire schemaVersion 2→3 migration and register tables in AppDatabase** - `5ed97ac` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified
- `lib/data/local/tables/meal_entry_table.dart` - MealEntryTable: sync-safe, snapshot columns (calories/protein/carbs/fat/co2e only, not sugar/fiber/salt), `logDate` for same-day merge/grouping
- `lib/data/local/tables/favorite_table.dart` - FavoriteTable: sync-safe, `UNIQUE(food_ref, food_ref_source)`, `lastQuantity`/`lastUnit` for one-tap re-log
- `lib/data/local/tables/user_food_table.dart` - UserFoodTable: custom foods + overrides in one table, `quickServingSizes` JSON via `TypeConverter.json2`
- `lib/domain/entities/meal_slot.dart` - Minimal `MealSlot` enum stand-in (breakfast/lunch/dinner/snack) — Plan 04-03 to extend with `displayLabel`/`detectMealSlotForTime`
- `lib/domain/entities/portion_unit.dart` - Minimal `PortionUnit` enum stand-in (g/ml/piece/cup/portion) — Plan 04-03 to extend with `displayLabel`/`isWeightBased`
- `lib/domain/entities/serving_size.dart` - Functionally complete `ServingSize` (`toJson`/`fromJson`/`encodeList`/`decodeList`) since `UserFoodTable`'s type converter directly invokes these methods, not just the type
- `lib/data/local/app_database.dart` - `schemaVersion` 2→3; three new tables registered; direct imports of `meal_slot.dart`/`portion_unit.dart`/`serving_size.dart` added (required for the generated part file to resolve those types)
- `lib/data/local/app_database.g.dart` - Regenerated via `dart run build_runner build --delete-conflicting-outputs`
- `lib/data/local/migrations/migration_strategy.dart` - `onUpgrade` `from < 3` branch creates the three new tables
- `tool/generate_schema_v1.dart` - Explicit out-of-scope doc-comment note added

## Decisions Made
- **Stand-in domain types (Rule 3):** Since Plan 04-03 (parallel Wave 2) had not landed, `MealSlot`, `PortionUnit`, `ServingSize` did not exist. Rather than leave Task 2 unverifiable (attempting `dart run build_runner build`/`flutter test` with these types missing broke compilation of `migration_strategy.dart` and therefore the entire app, since `app_database.dart` is imported everywhere), minimal stand-in files were created. `meal_slot.dart`/`portion_unit.dart` contain only the enum values (no `displayLabel`/`detectMealSlotForTime`/`isWeightBased` — those remain Plan 04-03's job). `serving_size.dart` is functionally complete (`decodeList`/`encodeList` are directly invoked by `UserFoodTable`'s type converter at runtime, not just referenced as a type), matching the round-trip/malformed-input behavior described in Plan 04-03's spec.
- **Direct imports required in `app_database.dart`:** `app_database.g.dart` is a `part of 'app_database.dart'` file. Part files share the enclosing library's import scope and cannot declare their own imports. Even though `meal_entry_table.dart`/`favorite_table.dart`/`user_food_table.dart` each import the domain types they need, that import is local to those files' own libraries and does not propagate into `app_database.dart`'s library. The Dart CFE (used by `flutter test`/`dart run`) requires `MealSlot`/`PortionUnit`/`ServingSize` resolvable from `app_database.dart`'s own import list for the generated code in `app_database.g.dart` to compile — confirmed by reproducing the failure (undefined type errors from CFE) before adding the imports, even though `flutter analyze`'s analyzer-server did not flag the same imports as unused.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Created minimal stand-in MealSlot/PortionUnit/ServingSize domain files**
- **Found during:** Task 2 (schemaVersion bump + migration wiring)
- **Issue:** `MealEntryTable`/`FavoriteTable` use `textEnum<MealSlot>()`/`textEnum<PortionUnit>()`, and `UserFoodTable`'s `quickServingSizes` type converter calls `ServingSize.decodeList`/`encodeList` — all three types are Plan 04-03's domain-layer deliverables (parallel Wave 2 plan) and had not landed in this repo. Attempting `dart run build_runner build` and `flutter test test/data/local/schema_test.dart` without them failed with unresolved-type errors in `migration_strategy.dart` (`db.mealEntryTable`/`db.favoriteTable`/`db.userFoodTable` getters absent from the un-regenerated `app_database.g.dart`), which broke compilation of the whole `app_database.dart` module (imported everywhere in the app).
- **Fix:** Created `lib/domain/entities/meal_slot.dart` (enum only), `lib/domain/entities/portion_unit.dart` (enum only), and `lib/domain/entities/serving_size.dart` (functionally complete — `toJson`/`fromJson`/`encodeList`/`decodeList`), each with a doc comment marking them as stand-ins and directing Plan 04-03's executor to extend/review rather than assume unimplemented.
- **Files modified:** `lib/domain/entities/meal_slot.dart`, `lib/domain/entities/portion_unit.dart`, `lib/domain/entities/serving_size.dart`
- **Verification:** `dart run build_runner build --delete-conflicting-outputs` completed cleanly; `flutter test test/` — full suite green (87 passed, 63 expected skips including the Wave 0 `meal_entry_test.dart`/`user_food_test.dart`/`serving_size_test.dart` stubs, which remain skipped as Plan 04-03 has not yet unskipped them); `flutter analyze lib/data/local/` — 0 errors (6 pre-existing info-level lints unrelated to this plan)
- **Committed in:** `5ed97ac` (Task 2 commit)

**2. [Rule 3 - Blocking] Added direct imports of the three domain files to `app_database.dart`**
- **Found during:** Task 2, after creating the stand-in domain files above
- **Issue:** Even with the stand-in files in place, `flutter test test/data/local/schema_test.dart` still failed to compile with "Type 'MealSlot'/'PortionUnit'/'ServingSize' not found" errors inside the generated `app_database.g.dart`, because that file is `part of 'app_database.dart'` and part files cannot declare their own imports — they rely entirely on the main library file's imports.
- **Fix:** Added direct imports of `meal_slot.dart`, `portion_unit.dart`, `serving_size.dart` to `app_database.dart` with a doc comment explaining why they appear unreferenced in this file's own source.
- **Files modified:** `lib/data/local/app_database.dart`
- **Verification:** `flutter test test/data/local/schema_test.dart` passes; `flutter analyze lib/data/local/app_database.dart` reports 0 issues
- **Committed in:** `5ed97ac` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (both Rule 3 — blocking, missing referenced file / cross-plan compile dependency)
**Impact on plan:** Both deviations were necessary to keep the codebase compiling and the full test suite green while Plan 04-02 executes ahead of its Wave-2 sibling Plan 04-03. No scope creep beyond the minimum needed for compilation — `displayLabel`, `isWeightBased`, `detectMealSlotForTime`, `Favorite`/`UserFood`/`MealEntry` entities, and the two repository interfaces remain entirely Plan 04-03's responsibility.

## Issues Encountered
- `dart run build_runner build --delete-conflicting-outputs` initially produced a broken `app_database.g.dart` (silently dropped `$MealEntryTableTable`/`$FavoriteTableTable` table classes due to unresolved `MealSlot`/`PortionUnit` types, while `$UserFoodTableTable` partially generated despite unresolved `ServingSize`). Caught before committing by backing up `app_database.g.dart` first and diffing/testing after the build_runner run; reverted immediately and re-ran only after creating the stand-in domain types.
- `dart run build_runner build` also produced unrelated cosmetic regeneration noise in `lib/core/router/app_router.g.dart` (provider hash change) and `lib/features/barcode_scan/providers/barcode_scan_notifier.g.dart` (doc-comment bracket→backtick style churn from a newer generator run). Both reverted via `git checkout --` since they are outside this plan's `files_modified` scope and not required for Task 2's own verification.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `AppDatabase` is ready for Plan 04-04 (DAOs) to add `MealEntryDao`, `FavoriteDao`, `UserFoodDao` referencing `db.mealEntryTable`/`db.favoriteTable`/`db.userFoodTable`.
- **Blocker for full correctness:** Plan 04-03 must land and its executor should review `lib/domain/entities/meal_slot.dart`, `portion_unit.dart`, and `serving_size.dart` against its own spec — extending the first two with `displayLabel`/`isWeightBased`/`detectMealSlotForTime`, and confirming `serving_size.dart`'s `decodeList`/`encodeList` behavior matches its test spec (recommend running `flutter test test/domain/entities/serving_size_test.dart` after unskipping to confirm no changes needed).
- `flutter analyze lib/` will show 0 issues (down from expected transient errors) once Plan 04-03 lands, since the stand-in files already satisfy the type requirements — no further action needed on the schema side.

---
*Phase: 04-meal-logging-core-10s-target*
*Completed: 2026-07-23*

## Self-Check: PASSED

All created files exist on disk; both task commits (`88b1bcc`, `5ed97ac`) verified present in `git log`.

---
phase: 02-food-catalog-ingest-search
plan: "03"
subsystem: data-layer
tags:
  - drift
  - fts5
  - food-catalog
  - domain-entities
  - attach-database
dependency_graph:
  requires:
    - 02-01 (build.yaml FTS5 config, integration test stubs)
    - 01-02 (SyncSafeTable mixin, AppDatabase pattern)
  provides:
    - FoodItem domain entity
    - IFoodCatalogRepository interface
    - UserFoodCacheTable (SyncSafeTable)
    - user_food_cache_fts FTS5 virtual table
    - FoodCatalogDao (UNION query across off_ref + user cache)
    - AppDatabase offRefPath + ATTACH DATABASE
    - FirstLaunchExtractor (GZip asset decompression)
  affects:
    - 02-04 (wires FirstLaunchExtractor into main; provides AppDatabase)
    - 02-05 (implements IFoodCatalogRepository against FoodCatalogDao)
tech_stack:
  added:
    - openfoodfacts: 3.30.2
    - archive: 4.0.9
    - shimmer: 3.0.0
    - connectivity_plus: 7.3.0
    - path: ^1.9.1 (direct dep per very_good_analysis)
  patterns:
    - SyncSafeTable mixin with getter syntax
    - Drift DAO with customSelect for FTS5 (no typed API available)
    - FTS5 sentinel: empty sanitized query → return []
    - Drift ATTACH DATABASE in beforeOpen
key_files:
  created:
    - lib/domain/entities/food_item.dart
    - lib/domain/repositories/i_food_catalog_repository.dart
    - lib/data/local/tables/user_food_cache_table.dart
    - lib/data/local/daos/user_food_cache_fts.drift
    - lib/data/local/daos/food_catalog_dao.dart
    - lib/core/assets/first_launch_extractor.dart
    - test/domain/entities/food_item_test.dart
  modified:
    - pubspec.yaml (4 new deps + path)
    - pubspec.lock
    - lib/data/local/app_database.dart (UserFoodCacheTable, FoodCatalogDao, offRefPath)
    - lib/data/local/migrations/migration_strategy.dart (ATTACH DATABASE, v1→2 migration)
decisions:
  - "FoodItem uses @immutable + sentinel copyWith pattern for nullable fields"
  - "FoodCatalogDao.sanitizeFts5QueryForTest exposes private sanitizer for unit tests"
  - "AppDatabase schemaVersion bumped to 2 for UserFoodCacheTable addition"
  - "ATTACH DATABASE skipped when offRefPath == null (unit test isolation)"
  - "Exception (not FlutterError) in first_launch_extractor catch clause — FlutterError is not catchable in Dart catch-on syntax"
  - "path: ^1.9.1 declared as direct dependency per very_good_analysis depend_on_referenced_packages rule"
metrics:
  duration: "11m 54s"
  completed: "2026-07-20"
  tasks_completed: 2
  files_created: 7
  files_modified: 5
---

# Phase 02 Plan 03: Dart Data Layer Foundation — FoodItem, FTS5 DAO, ATTACH DATABASE Summary

**One-liner:** Drift data layer for food catalog: FoodItem entity, FTS5 UNION DAO (off_ref + user cache), AppDatabase ATTACH DATABASE, and GZip asset decompression — all data contracts Plans 02-04/05 implement against.

---

## What Was Built

### Task 1: pubspec deps + FoodItem + IFoodCatalogRepository + UserFoodCacheTable

Four verified packages added to pubspec.yaml:
- `openfoodfacts: 3.30.2` — OFF API client for search fallback (VERIFIED: pub.dev)
- `archive: 4.0.9` — GZip decompression for bundled SQLite asset (VERIFIED: pub.dev)
- `shimmer: 3.0.0` — skeleton loading rows for API fallback (VERIFIED: pub.dev)
- `connectivity_plus: 7.3.0` — network gate before API calls (VERIFIED: pub.dev)
- `path: ^1.9.1` — direct dep per very_good_analysis rule

**FoodItem** (`lib/domain/entities/food_item.dart`): `@immutable` plain Dart class with `barcode`, `productName`, `productNameEn`, `brand`, `calories100g`, `protein100g`, `carbs100g`, `fat100g`. Sentinel-based `copyWith` supports explicit null overrides. Equality on `(barcode, productName)` for deduplication. `fromQueryRow` factory maps Drift `QueryRow` by column name.

**IFoodCatalogRepository** (`lib/domain/repositories/i_food_catalog_repository.dart`): abstract interface with `searchLocal(String query)` and `searchAndCache(String query)`. Domain layer depends only on this interface.

**UserFoodCacheTable** (`lib/data/local/tables/user_food_cache_table.dart`): Drift table extending `Table with SyncSafeTable`. 9 food columns (barcode, productName, productNameEn, brand, calories100g, protein100g, carbs100g, fat100g, categoriesTags) + 6 sync-safe columns inherited from mixin (id, hlcMillis, hlcCounter, hlcNodeId, dirty, deletedAt). Total: 15 columns. Primary key is `id` (UUID v7) from mixin. Getter syntax throughout per `very_good_analysis` `specify_nonobvious_property_types` rule.

### Task 2: AppDatabase ATTACH + user_food_cache_fts + FoodCatalogDao + FirstLaunchExtractor

**user_food_cache_fts.drift** (`lib/data/local/daos/user_food_cache_fts.drift`): FTS5 virtual table with `(product_name, product_name_en, brand)` columns, `content='user_food_cache_table'`, `tokenize='unicode61 remove_diacritics 2'`, `prefix='2 3 4'`. Column layout matches `off_ref.products_fts` exactly for UNION compatibility (D-API-FALLBACK: cached API results appear in future local searches without re-hitting the API).

**AppDatabase** updated: `UserFoodCacheTable` + `FoodCatalogDao` added to `@DriftDatabase`; `include: {'daos/user_food_cache_fts.drift'}` registers the FTS5 DDL; `offRefPath` parameter added; `connect()` named constructor accepts `offRefPath`; `schemaVersion` bumped to 2; `migration` passes `offRefPath` to `buildMigrationStrategy`.

**migration_strategy.dart** updated: `buildMigrationStrategy` accepts `offRefPath` named parameter; `onUpgrade` handles v1→v2 adding `UserFoodCacheTable` and `user_food_cache_fts`; `beforeOpen` runs `ATTACH DATABASE '$offRefPath' AS off_ref` when non-null (skipped in unit tests).

**FoodCatalogDao** (`lib/data/local/daos/food_catalog_dao.dart`): `@DriftAccessor(tables: [UserFoodCacheTable])`. `searchLocalFoods` queries `off_ref.products_fts` (BM25 ranked, skipped when offRefPath is null) and `user_food_cache_fts` (JOIN against `user_food_cache_table`), deduplicates by barcode, caps at 25. `_sanitizeFts5Query` strips `[^\w\s\-]`, appends `*` per term, returns empty string if no terms (T-02-03-01).

**FirstLaunchExtractor** (`lib/core/assets/first_launch_extractor.dart`): top-level `ensureOffReferenceDb()` function. Idempotent — returns `dbFile.path` immediately if file exists. Loads `assets/off_reference.sqlite.gz` from Flutter bundle, decompresses with `const GZipDecoder()` (archive package), writes to `getApplicationDocumentsDirectory()`. Throws `StateError` with developer-friendly message if asset missing. Path derived from `path_provider` only (T-02-03-02).

---

## Verification Results

```
flutter pub get             → OK (11 new transitive deps)
dart run build_runner build → Built in 19s; 0 errors (1 warning: content table
                              reference in user_food_cache_fts.drift not resolvable
                              statically — expected for cross-Dart/SQL FTS5 DDL)
flutter analyze             → 20 info issues total; 0 errors; all issues are in
                              pre-existing tool/generate_schema_v1.dart (not
                              modified in this plan)
```

Plan verification checks:
- `grep -c "ATTACH DATABASE" migration_strategy.dart` → 1 ✓
- `grep -c "off_ref.products_fts" food_catalog_dao.dart` → 6 ✓
- `grep -c "user_food_cache_fts" food_catalog_dao.dart` → 6 ✓
- `grep -c "user_food_cache_fts" user_food_cache_fts.drift` → 1 ✓

Test results:
- 8 FoodItem entity tests — all pass
- 10 FoodCatalogDao tests (sanitize + searchLocalFoods + ATTACH) — all pass
- 53 total suite tests — all pass (9 skipped stubs from Wave 0)

---

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] path package missing from direct dependencies**
- **Found during:** Task 2 flutter analyze
- **Issue:** `lib/core/assets/first_launch_extractor.dart` imports `package:path/path.dart` but `path` was only a transitive dependency; `very_good_analysis depend_on_referenced_packages` rule flags this as an error
- **Fix:** Added `path: ^1.9.1` to pubspec.yaml direct dependencies
- **Files modified:** `pubspec.yaml`, `pubspec.lock`
- **Commit:** f76b974

**2. [Rule 1 - Bug] FlutterError not valid in Dart on-catch clause**
- **Found during:** Task 2 flutter analyze
- **Issue:** Plan specified `on FlutterError catch` but `FlutterError` is not a catchable type in Dart's `on Type catch` syntax (it's a class but not recognized as an exception type by the Dart analyzer for catch clauses)
- **Fix:** Changed to `on Exception catch (e)` which correctly catches Flutter asset load failures
- **Files modified:** `lib/core/assets/first_launch_extractor.dart`
- **Commit:** f76b974

**3. [Rule 2 - Missing critical functionality] @immutable annotation for equality override**
- **Found during:** Task 1 flutter analyze
- **Issue:** `very_good_analysis avoid_equals_and_hash_code_on_mutable_classes` — overriding `==` and `hashCode` without `@immutable` is flagged as a code quality error
- **Fix:** Added `@immutable` annotation to `FoodItem` class; all fields are already `final`
- **Files modified:** `lib/domain/entities/food_item.dart`
- **Commit:** d750a63

---

## Threat Surface Scan

No new network endpoints, auth paths, or trust boundary surfaces introduced. Files created are:
- Pure domain entity (no I/O)
- Abstract interface (no I/O)
- Drift table definition (no I/O)
- FTS5 DDL (SQL only)
- DAO (reads from SQLite via Drift)
- Extractor function (reads from Flutter assets, writes to app documents dir)

All threat mitigations from the plan's threat model are implemented:
- T-02-03-01: `_sanitizeFts5Query` strips metacharacters, parameterized via `Variable.withString`
- T-02-03-02: `offRefPath` always from `path_provider`, never user input
- T-02-03-03: `searchLocalFoods` returns [] for empty sanitized query
- T-02-03-04: GZip asset from bundled APK/IPA — accepted per threat model

## Self-Check: PASSED

Files exist:
- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/lib/domain/entities/food_item.dart` ✓
- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/lib/domain/repositories/i_food_catalog_repository.dart` ✓
- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/lib/data/local/tables/user_food_cache_table.dart` ✓
- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/lib/data/local/daos/user_food_cache_fts.drift` ✓
- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/lib/data/local/daos/food_catalog_dao.dart` ✓
- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/lib/core/assets/first_launch_extractor.dart` ✓

Commits exist:
- f49765a: test(02-03): add failing RED tests for FoodItem domain entity
- d750a63: feat(02-03): add pubspec deps, FoodItem entity, IFoodCatalogRepository, UserFoodCacheTable
- 49b7e21: test(02-03): add failing RED tests for FoodCatalogDao, ATTACH support, sanitize
- f76b974: feat(02-03): AppDatabase ATTACH, user_food_cache_fts FTS5, FoodCatalogDao UNION query, FirstLaunchExtractor

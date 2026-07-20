---
phase: 02-food-catalog-ingest-search
plan: "04"
subsystem: data-layer
tags: [off-api, repository, di, riverpod, drift, fts5, caching]
dependency_graph:
  requires:
    - 02-03 (FoodCatalogDao, UserFoodCacheTable, AppDatabase ATTACH)
    - 01-02 (SyncSafeTable mixin, AppDatabase schema)
    - 01-04 (Riverpod DI pattern, providers.dart)
  provides:
    - OffApiClient (searchOff — OFF v3 API search)
    - FoodCatalogRepository (IFoodCatalogRepository implementation)
    - NetworkException (typed exception for API failures)
    - foodCatalogRepositoryProvider (Riverpod, keepAlive)
    - offRefPathProvider (Riverpod override for off_reference.sqlite path)
  affects:
    - 02-05 (FoodSearchNotifier reads foodCatalogRepositoryProvider)
    - lib/main.dart (startup sequence)
tech_stack:
  added:
    - openfoodfacts 3.30.2 (already in pubspec, now used for ProductSearchQueryConfiguration v3)
  patterns:
    - Repository pattern implementing abstract interface (IFoodCatalogRepository)
    - Riverpod keepAlive providers with overrideWithValue in ProviderScope
    - Drift Companion insert pattern for parameterized SQL (T-02-04-03)
    - FTS5 parameterized customStatement for cache index update (D-API-FALLBACK)
    - HLC Phase-1 placeholders: hlcNodeId='local', hlcCounter=0
key_files:
  created:
    - lib/data/remote/off_api_client.dart
    - lib/data/repositories/food_catalog_repository.dart
    - lib/core/di/app_providers.dart
    - lib/core/di/app_providers.g.dart
  modified:
    - lib/core/di/providers.dart (add offRefPathProvider, update appDatabase)
    - lib/core/di/providers.g.dart (regenerated)
    - lib/main.dart (configureOff + ensureOffReferenceDb before runApp)
    - test/data/repositories/food_catalog_repository_test.dart (replace Wave 0 stub with real tests)
decisions:
  - "app_providers.dart created as separate file from providers.dart — food catalog providers are cohesive unit, keeping base DI file focused on core infrastructure"
  - "offRefPathProvider added to providers.dart not app_providers.dart — AppDatabase provider is in providers.dart and needs the path at initialization time"
  - "NetworkException defined in food_catalog_repository.dart (same file) — simpler for Phase 2, avoids premature file proliferation"
  - "on Exception catch vs catch in main.dart — very_good_analysis requires typed catch clauses"
  - "Test uses _TestableRepository wrapper with abstract interfaces — avoids pulling Drift+AppDatabase into unit test scope; mocktail requires class types not functions (hence one_member_abstracts ignore)"
metrics:
  duration: "~15m"
  completed: "2026-07-20"
  tasks_completed: 2
  files_created: 4
  files_modified: 4
---

# Phase 02 Plan 04: Repository, API Client, and DI Wiring Summary

**One-liner:** OFF API v3 client + local-cache repository with FTS5 index update + Riverpod DI wiring + non-fatal first-launch extractor in main.

## What Was Built

### Task 1: OffApiClient and FoodCatalogRepository (TDD)

**TDD RED commit:** `4700a96` — Failing tests for `FoodCatalogRepository` and `NetworkException` (replaced Wave 0 stub).

**TDD GREEN commit:** `fb90b6f` — Implementation of both files, all 6 tests passing.

**`lib/data/remote/off_api_client.dart`:**
- `configureOff()` — one-time setup: UserAgent `name: 'CO2Diet'`, `url: 'https://reduceco2now.com'`, `globalCountry: GERMANY`, `globalLanguages: [ENGLISH, GERMAN]`. Mitigates T-02-04-05 (403 without User-Agent).
- `OffApiClient.searchOff(query)` — builds `ProductSearchQueryConfiguration` v3 with `SearchTerms([query])`, `PageSize(20)`, `PageNumber(1)`. Returns `result.products?.map(_productToFoodItem).toList() ?? []` (never throws on null products list).
- `_productToFoodItem(Product p)` — maps barcode, productName (fallback `'Unknown'`), brands, and nutriments via `Nutriments.getValue(Nutrient.energyKCal/proteins/carbohydrates/fat, PerSize.oneHundredGrams)`. All access is null-safe (`?.`). Mitigates T-02-04-01.

**`lib/data/repositories/food_catalog_repository.dart`:**
- `NetworkException implements Exception` — typed exception with `final String message`. Mitigates T-02-04-04.
- `FoodCatalogRepository implements IFoodCatalogRepository`:
  - `searchLocal(query)` — delegates to `_dao.searchLocalFoods(query)`, no API contact.
  - `searchAndCache(query)` — calls `_apiClient.searchOff(query)`, wraps `SocketException`/`Exception` as `NetworkException`. For each result: inserts `UserFoodCacheTableCompanion` via Drift `insertOnConflictUpdate` (HLC placeholders: `hlcNodeId='local'`, `hlcCounter=0`, `dirty=true`), then inserts into `user_food_cache_fts` via parameterized `customStatement` so future local searches find cached items without re-hitting the API (D-API-FALLBACK). Returns API items directly without extra DB round-trip.

### Task 2: DI Providers and main.dart Startup Wiring

**Commit:** `ee6de20`

**`lib/core/di/providers.dart` updates:**
- Added `offRefPathProvider` — `@riverpod String? offRefPath(Ref ref) => null`. Default is null; overridden in `main()` via `ProviderScope(overrides: [offRefPathProvider.overrideWithValue(path)])`.
- Updated `appDatabase` — now calls `AppDatabase.connect(offRefPath: ref.watch(offRefPathProvider))` so the database gets the reference DB path when available.

**`lib/core/di/app_providers.dart`** (new file):
- `foodCatalogDaoProvider` — `@Riverpod(keepAlive: true)` returns `appDatabaseProvider.foodCatalogDao`.
- `offApiClientProvider` — `@Riverpod(keepAlive: true)` returns `OffApiClient()`.
- `foodCatalogRepositoryProvider` — `@Riverpod(keepAlive: true)` returns `FoodCatalogRepository(foodCatalogDaoProvider, offApiClientProvider)`. Declared return type is `IFoodCatalogRepository` (interface, not concrete class).

**`lib/main.dart` updates:**
- `main()` is now `async`.
- `WidgetsFlutterBinding.ensureInitialized()` called first.
- `configureOff()` called once before runApp.
- `offRefPath = await ensureOffReferenceDb()` called with non-fatal `on Exception catch` — app continues in local-only mode if asset is absent.
- `ProviderScope(overrides: [if (offRefPath != null) offRefPathProvider.overrideWithValue(offRefPath)], child: Co2DietApp())`.

## Verification Results

```
dart run build_runner build              → exit 0, "wrote 8 outputs"
flutter analyze                          → 0 errors (23 pre-existing info/warning in test+script files)
grep foodCatalogRepositoryProvider       → 1 match in app_providers.dart
grep ensureOffReferenceDb                → 1 match in main.dart
grep configureOff                        → 1 match in main.dart
grep user_food_cache_fts                 → 2 matches in food_catalog_repository.dart
flutter test food_catalog_repository_test → 6/6 passing
```

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] UserFoodCacheTableCompanion.insert requires plain values, not Value-wrapped**
- **Found during:** Task 1 GREEN phase
- **Issue:** Plan said to use `hlcMillis: Value(BigInt.from(...))` but generated companion `.insert()` takes raw `BigInt hlcMillis`, `int hlcCounter`, `String hlcNodeId` (wraps them internally in the constructor body). Using `Value<>()` wrappers caused a compile error.
- **Fix:** Removed `Value()` wrappers from `hlcMillis`, `hlcCounter`, `hlcNodeId` in the companion insert — passed raw values as required.
- **Files modified:** `lib/data/repositories/food_catalog_repository.dart`
- **Commit:** `fb90b6f`

**2. [Rule 2 - Missing critical functionality] on Exception required for main.dart**
- **Found during:** Task 2 flutter analyze
- **Issue:** `catch (e)` without `on Exception` triggers `avoid_catches_without_on_clauses` in very_good_analysis.
- **Fix:** Changed to `on Exception catch (e)` — still catches all Dart exceptions (including StateError from ensureOffReferenceDb).
- **Files modified:** `lib/main.dart`
- **Commit:** `ee6de20`

**3. [Rule 1 - Bug] One-member abstract classes need lint ignore in test**
- **Found during:** Task 1 refactor phase
- **Issue:** `one_member_abstracts` lint warning on `_FoodCatalogDaoLike` and `_OffApiClientLike` test helper abstractions.
- **Fix:** Added `// ignore: one_member_abstracts` with explanatory comment — mocktail requires class types.
- **Files modified:** `test/data/repositories/food_catalog_repository_test.dart`
- **Commit:** `9154fc3`

## Known Stubs

None — no placeholder data or hardcoded UI values in this plan. The `offRefPath` provider defaults to `null` by design (the OFF reference DB is absent until the ingest pipeline is run), and the AppDatabase handles null gracefully via `ATTACH DATABASE skipped when offRefPath == null` (Plan 02-03 decision).

## Threat Surface Scan

No new threat surface introduced beyond what is documented in the plan's `<threat_model>`:
- OFF API call is already modeled as T-02-04-02 (accepted: non-PII food names)
- Cache insert is modeled as T-02-04-03 (mitigated: Companion + parameterized FTS5 insert)
- No new network endpoints, auth paths, or schema changes at trust boundaries

## TDD Gate Compliance

- RED gate: commit `4700a96` — `test(02-04): add failing tests for FoodCatalogRepository and NetworkException`
- GREEN gate: commit `fb90b6f` — `feat(02-04): implement OffApiClient and FoodCatalogRepository`
- REFACTOR gate: commit `9154fc3` — `refactor(02-04): clean up test lint warnings`

All three TDD gates present in git log. Compliant.

## Self-Check

Files created check:
- `lib/data/remote/off_api_client.dart` — FOUND
- `lib/data/repositories/food_catalog_repository.dart` — FOUND
- `lib/core/di/app_providers.dart` — FOUND
- `lib/core/di/app_providers.g.dart` — FOUND

Commits verified:
- `4700a96` — RED test commit
- `fb90b6f` — GREEN implementation commit
- `ee6de20` — Task 2 DI + main commit
- `9154fc3` — REFACTOR cleanup commit

## Self-Check: PASSED

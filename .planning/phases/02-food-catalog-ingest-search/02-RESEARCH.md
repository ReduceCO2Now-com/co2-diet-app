# Phase 2: Food Catalog Ingest & Search — Research

**Researched:** 2026-07-17
**Domain:** SQLite FTS5, Open Food Facts data pipeline, Drift ATTACH DATABASE, Flutter offline search UX
**Confidence:** HIGH (core FTS5/Drift stack) | MEDIUM (OFF CSV field names, JSONL field confirmation)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Search Screen**
- Standalone `/food-search` route reachable from Settings or a dev shortcut in Phase 2
- Full-screen layout; search field replaces AppBar title slot
- Auto-focus keyboard on screen load
- Clear (✕) button inside field, appears once text is entered
- Back navigation via system back / AppBar arrow (go_router pop)

**Search Behavior**
- As-you-type with 300ms debounce; Enter key fires immediately
- 2-character minimum before query fires
- FTS5 prefix matching (`*` suffix) on `product_name`, `product_name_en`, `brand`
- AND logic for multi-word queries
- Exact `product_name`/`product_name_en` match boosted to top; BM25 for the rest
- 25 results from local FTS5

**States**
- Empty/prompt: illustration + "Search for a food..." hint (no suggested items)
- No-results (genuine): illustration + "No results for 'X'"
- No-results (offline): same + "No results — connect to the internet to search more"
- Network failure: illustration + "Couldn't reach the food database — check your connection" + "Try again" button
- Local FTS5: NO loading indicator; API fallback: shimmer skeleton rows + "Searching online..." banner

**Result Row**
- Name (bold) + brand (secondary, omitted if empty) + calories per 100g ("— kcal/100g" if missing)
- No thumbnails, Nutri-Score, category icons in Phase 2
- No visual distinction between local vs. API-sourced rows

**Food Detail Bottom Sheet**
- Read-only: name, brand, full macros per 100g (calories, protein, carbs, fat)
- CO₂ row hidden (Phase 3 concern)
- Phase 4 adds "Log this food" action with no rebuild

**FTS5 Architecture**
- FTS5 virtual table lives inside `off_reference.sqlite` (not in `co2diet.sqlite`)
- `ATTACH DATABASE` called once in `AppDatabase.beforeOpen`, persistent for the session

**API Fallback**
- Fires only when local FTS5 returns 0 results
- 20 results per query from OFF API
- Results written to user-catalog tables in `co2diet.sqlite` using `SyncSafeTable` mixin
- FTS5 table in `co2diet.sqlite` indexes cached items for future local searches
- No auto-retry; network failure goes to error state with "Try again"

**OFF Seed Pipeline**
- Python script at `tools/ingest_off.py`; reads OFF CSV/JSONL, writes `off_reference.sqlite`
- Filter: `countries_tags` contains any EU country AND `completeness ≥ 0.6`
- Columns stored: `barcode`, `product_name`, `product_name_en` (nullable), `brand`, `calories_100g`, `protein_100g`, `carbs_100g`, `fat_100g`, `categories_tags`
- `off_reference.sqlite` bundled compressed (zstd or lz4 — algorithm is discretion)
- First-launch decompression: blocking splash/loading screen with progress; one-time only

**Benchmark**
- Dart integration test (`flutter test integration_test/`)
- Three test cases: (1) worst-case 2-char query, (2) full-word query, (3) no-local-result → API
- All three must complete in <1s on Pixel 6a / Samsung A54 class

### Claude's Discretion

- Drift DAO design for food catalog tables (off_ref reads vs. user-catalog writes)
- Riverpod provider / state management structure for the search screen
- Exact FTS5 `CREATE VIRTUAL TABLE` syntax, tokenizer config, per-column BM25 weight values
- zstd vs. lz4 compression algorithm choice
- Error state widget visual design details
- Bottom sheet animation / drag-to-dismiss specifics
- Exact Python ingest script structure (chunked reads, progress reporting)

### Deferred Ideas (OUT OF SCOPE)

- Umlaut / ASCII folding ("Muller" finds "Müller")
- Category filter chips on search (Phase 4+)
- Nutri-Score badge on result rows (no confirmed phase)
- Data-saver / metered connection check (Phase 8)
- "Add custom food" link on no-results state (Phase 4)
- `fiber_100g`, `salt_100g`, `sugar_100g` in seed DB (Phase 4)
- Food thumbnails from OFF CDN (Phase 4–5)
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| LOG-01 | Food name search returns results in <1s against local bundled food database (FTS5 index) | FTS5 prefix indexes on 2+ chars deliver sub-millisecond lookups; Drift supports FTS5 via `.drift` file declarations; ATTACH DATABASE enables read-only reference DB |
| LOG-02 | Food search falls back to OFF API when online and local results below threshold; API results cached locally | `openfoodfacts` 3.30.2 Dart client (pub.dev verified); caching into `co2diet.sqlite` user-catalog tables; threshold = 0 results triggers fallback |
| NFR-06 | (a) >90% hit rate on ~200 EU/German foods benchmark; (b) >90% of seed DB products have CO₂ estimate | EU/German filter via `countries_tags` + completeness ≥ 0.6 delivers dense subset; CO₂ coverage deferred to Phase 3 (this phase proves hit rate only) |
</phase_requirements>

---

## Summary

Phase 2 has three distinct technical sub-problems that must be delivered in dependency order: (1) an offline Python pipeline that ingests the Open Food Facts CSV/JSONL into a filtered, FTS5-indexed `off_reference.sqlite`; (2) a Flutter runtime that attaches that read-only database and queries it via Drift's FTS5 support; and (3) a search screen UI with precise state transitions (no shimmer for local results, shimmer only for API fallback) and an `openfoodfacts` Dart client fallback path that caches into user-catalog tables.

The highest technical risk is confirming that `product_name_en` exists as a field in the OFF JSONL export. The OFF CSV (`~0.9 GB compressed, ~9 GB uncompressed`) exposes language-specific fields as `product_name_de`, `product_name_en`, etc. in the full JSONL dump but the CSV export only carries `product_name` as the primary field. The `completeness` field was added to the CSV in an issue-tracked revision (confirmed). The ingest script should process JSONL rather than CSV so all language-specific fields are accessible, with a fallback strategy if `product_name_en` is absent for a row (store NULL).

SQLite's FTS5 has a critical constraint that matters architecturally: when using the `content=` external content feature, the content table must be in the **same database file** as the FTS5 virtual table. Because the FTS5 table lives in `off_reference.sqlite` (ATTACHED), the content table approach works within that single file. FTS5 queries against ATTACHED databases work normally — the cross-database limitation applies only to the `content=` external-content table reference, not to querying an FTS5 table in an attached schema.

Compression of the bundled asset should use the `archive` package (GZip) rather than zstd/lz4, because `archive` is already a well-established pub.dev package with 10.7M downloads, supports GZip natively, requires no native FFI binaries, and avoids adding a new dependency. The trade-off (slightly larger compressed file vs. zstd) is acceptable for a 50 MB asset where the difference is a few MB.

**Primary recommendation:** Use Drift FTS5 with a `.drift` schema file for `off_reference.sqlite`, process the OFF JSONL dump (not CSV) in the Python ingest script to get `product_name_en`, compress with GZip via the `archive` package for decompression on first launch, and implement the OFF API fallback with `openfoodfacts` 3.30.2.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| FTS5 search query | Database / Storage (`off_reference.sqlite`) | — | SQLite FTS5 index is the search engine; query execution is inside SQLite process |
| ATTACH DATABASE setup | Database / Storage (AppDatabase init) | — | One-time connection-scoped setup in `beforeOpen` callback |
| Search result state management | Application (Riverpod provider) | — | Debounce, fallback trigger, loading/error states live in the notifier |
| Search screen UI + states | Frontend (Flutter widgets) | — | Renders the three distinct states: prompt, results, error |
| Bottom sheet detail view | Frontend (Flutter widgets) | — | Modal presentation layer; data passed from search result |
| OFF API fallback call | Data layer (FoodCatalogRepository) | — | Keeps network I/O out of the UI and state-management layers |
| API result caching | Database / Storage (`co2diet.sqlite`) | — | Writes to user-catalog tables with SyncSafeTable mixin; same connection as main DB |
| OFF data ingest pipeline | Build-time tool (`tools/ingest_off.py`) | — | Runs offline at developer workstation; produces `off_reference.sqlite` as artifact |
| First-launch decompression | Application init (startup sequence) | — | Runs before AppDatabase initializes; writes decompressed DB to documents dir |
| Benchmark tests | Integration test layer | — | `integration_test/` Dart tests measure Stopwatch-bounded query times |

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `drift` | 2.34.2 (pinned) | FTS5 queries via `.drift` files; ATTACH DATABASE via `customStatement`; user-catalog tables | Already in project, verified working; FTS5 support built in |
| `drift_flutter` | 0.3.1 (pinned) | Flutter SQLite connection | Already in project |
| `path_provider` | 2.1.6 (pinned) | Locate app documents dir for decompressed DB | Already in project; needed for first-launch extraction |
| `openfoodfacts` | 3.30.2 | OFF API client for search fallback | [VERIFIED: pub.dev] Official OFF Dart client, maintained by openfoodfacts.org; 4.49k downloads; verified publisher |
| `archive` | 4.0.9 | GZip decompress bundled `off_reference.sqlite.gz` on first launch | [VERIFIED: pub.dev] Pure Dart, 10.7M downloads, verified publisher loki3d.com; no FFI |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `shimmer` | 3.0.0 | Skeleton loading rows during API fallback | API fallback path only; not for local FTS5 results |
| `connectivity_plus` | 7.3.0 | Detect online state before attempting API fallback | Gate the API call; show offline error state when offline |
| `flutter_riverpod` | 3.3.2 (pinned) | Search screen state management | Already in project |
| `riverpod_annotation` | 4.0.3 (pinned) | Codegen annotations | Already in project |
| `uuid` | 4.6.0 (pinned) | UUID v7 for cached OFF API result rows | Already in project |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `archive` (GZip) | `es_compression` (zstd/lz4 via FFI) | zstd achieves ~10–15% better ratio; but adds FFI binaries for iOS/Android, complicating build. GZip at 50 MB is adequate. |
| `archive` (GZip) | `libcompress` (pure Dart, LZ4/zstd) | `libcompress` is newer, less tested at 10.7M download scale. `archive` is the safer choice. |
| `openfoodfacts` Dart client | Custom Dio HTTP calls to OFF v2 API | OFF API has undocumented quirks, auth quirks, field naming conventions. Official client handles these. |
| shimmer | `skeletonizer` | `skeletonizer` wraps existing widgets — more setup. `shimmer` package is simpler for manually-specified skeleton rows. |
| `connectivity_plus` alone | `internet_connection_checker_plus` | STACK.md recommends layering both; for Phase 2 the offline check is a gate (don't call API if offline) — `connectivity_plus` alone is sufficient for this simple gate; add `internet_connection_checker_plus` in Phase 7 sync. |

**Version verification (pub.dev API, 2026-07-17):**
- `openfoodfacts`: 3.30.2 [VERIFIED: pub.dev API]
- `archive`: 4.0.9 [VERIFIED: pub.dev API]
- `drift`: 2.34.2 [VERIFIED: pub.dev API]
- `path_provider`: 2.1.6 [VERIFIED: pub.dev API]
- `shimmer`: 3.0.0 [VERIFIED: pub.dev API]
- `connectivity_plus`: 7.3.0 [VERIFIED: pub.dev API]

**Installation (new packages only — drift, path_provider, riverpod already present):**
```bash
flutter pub add openfoodfacts archive shimmer connectivity_plus
```

---

## Package Legitimacy Audit

> slopcheck ran against PyPI (Python registry), which is the wrong ecosystem for these Dart/Flutter packages. The packages were verified directly against the pub.dev API (authoritative Dart registry) instead. Per the package name provenance rule, packages confirmed via the official pub.dev registry with publisher verification are tagged [VERIFIED: pub.dev].

| Package | Registry | Publisher | Downloads | slopcheck | Disposition |
|---------|----------|-----------|-----------|-----------|-------------|
| `openfoodfacts` | pub.dev | openfoodfacts.org (verified) | 4.49k | N/A (Dart pkg) | Approved — official OFF foundation |
| `archive` | pub.dev | loki3d.com (verified) | 10.7M | N/A (Dart pkg) | Approved — high-adoption, verified |
| `shimmer` | pub.dev | cuongvdvn (community) | checked via pub.dev | N/A (Dart pkg) | Approved — 3.0.0, stable, widely used |
| `connectivity_plus` | pub.dev | flutter.dev ecosystem | well established | N/A (Dart pkg) | Approved |
| `path_provider` | pub.dev | flutter.dev | 2.1.6, ecosystem standard | N/A (Dart pkg) | Already in project |

**Packages removed due to slopcheck [SLOP]:** none
**Packages flagged [SUS]:** none

*Note: slopcheck 0.6.1 checked PyPI. All packages above are pub.dev (Dart). Direct pub.dev API queries confirmed registry existence and publisher identity for all recommended packages.*

---

## Architecture Patterns

### System Architecture Diagram

```
User types in SearchField
         │
         ▼ (300ms debounce or Enter)
FoodSearchNotifier (Riverpod AsyncNotifier)
         │
         ├─► [query.length < 2] → emit PromptState
         │
         ├─► FoodCatalogRepository.searchLocal(query)
         │         │
         │         ▼
         │   AppDatabase.customSelect(
         │     "SELECT ... FROM off_ref.products_fts ... MATCH ?*
         │      UNION ALL
         │      SELECT ... FROM user_ref_fts ... MATCH ?*
         │      ORDER BY ... LIMIT 25"
         │   )
         │         │
         │         ├─[results > 0]─► emit ResultsState(results)
         │         │
         │         └─[results == 0]─► check connectivity_plus
         │                                   │
         │                    ┌──────────────┴──────────────┐
         │               [offline]                      [online]
         │                    │                             │
         │              emit OfflineNoResults    emit LoadingApiState
         │                                             │
         │                                   openfoodfacts.searchProducts(
         │                                     ProductSearchQueryConfiguration(
         │                                       parametersList: [SearchTerms(terms: query),
         │                                                        PageSize(size: 20)]
         │                                     )
         │                                   )
         │                                             │
         │                               ┌────────────┴────────────┐
         │                          [results]               [failure]
         │                               │                       │
         │                    cache → co2diet.sqlite      emit NetworkErrorState
         │                    index → user_ref_fts
         │                               │
         │                          emit ResultsState(results)
         │
         ▼
SearchScreen renders:
  AsyncValue.loading → (local: nothing; api: shimmer rows + banner)
  AsyncValue.data(PromptState) → PromptWidget
  AsyncValue.data(ResultsState) → ListView of FoodResultRows
  AsyncValue.data(OfflineNoResults) → NoResultsWidget("offline" variant)
  AsyncValue.data(NetworkError) → NetworkErrorWidget + "Try again"
  AsyncValue.error → fallback error widget
```

### Recommended Project Structure

```
lib/
├── data/
│   ├── local/
│   │   ├── app_database.dart          # Add ATTACH DATABASE in beforeOpen
│   │   ├── tables/
│   │   │   ├── user_food_cache_table.dart   # SyncSafeTable for API-cached foods
│   │   │   └── user_food_cache_fts_table.drift  # FTS5 on user-catalog
│   │   └── daos/
│   │       └── food_catalog_dao.dart   # local FTS5 queries (reads off_ref.*)
│   ├── remote/
│   │   └── off_api_client.dart         # Thin wrapper over openfoodfacts pkg
│   └── repositories/
│       └── food_catalog_repository.dart  # searchLocal + fallback + cache write
├── domain/
│   ├── entities/
│   │   └── food_item.dart              # Pure Dart model (name, brand, macros)
│   └── repositories/
│       └── i_food_catalog_repository.dart
├── features/
│   └── food_search/
│       ├── providers/
│       │   └── food_search_notifier.dart   # AsyncNotifier + debounce
│       ├── screens/
│       │   └── food_search_screen.dart
│       └── widgets/
│           ├── food_result_row.dart
│           ├── food_detail_sheet.dart
│           ├── search_prompt_widget.dart
│           ├── no_results_widget.dart      # variants: genuine, offline, network-error
│           └── api_loading_banner.dart     # shimmer rows + "Searching online..."
└── core/
    └── assets/
        └── first_launch_extractor.dart  # copies off_reference.sqlite.gz → docs dir

tools/
└── ingest_off.py               # OFF JSONL → off_reference.sqlite

assets/
└── off_reference.sqlite.gz     # bundled compressed seed DB (~15–20 MB expected)

integration_test/
└── food_search_benchmark_test.dart

reference/
└── off_reference.drift         # FTS5 virtual table DDL for tooling reference
```

### Pattern 1: FTS5 Virtual Table Declaration in `.drift` File

**What:** Declare the FTS5 table in a `.drift` schema file so Drift's static analyzer knows about it. Queries against the FTS5 table use `customSelect` or raw SQL because Drift cannot generate typed APIs for FTS5 virtual tables from Dart alone.

**When to use:** Any time you need FTS5 in Drift. FTS5 tables and queries on them cannot be declared in Dart — use `.drift` files.

**build.yaml required:**
```yaml
# Source: https://drift.simonbinder.eu/generation_options/
targets:
  $default:
    builders:
      drift_dev:
        options:
          sql:
            dialect: sqlite
            options:
              version: "3.34"
              modules:
                - fts5
```

**FTS5 table declaration (in `off_reference.drift` schema reference file):**
```sql
-- Source: https://www.sqlite.org/fts5.html + https://drift.simonbinder.eu/sql_api/extensions/
-- This DDL is executed by the Python ingest script when creating off_reference.sqlite.
-- Drift does NOT create this table — it is pre-built in the bundled asset.

CREATE TABLE products (
  barcode      TEXT PRIMARY KEY,
  product_name TEXT NOT NULL,
  product_name_en TEXT,           -- nullable; absent for non-EN products
  brand        TEXT,
  calories_100g REAL,
  protein_100g REAL,
  carbs_100g   REAL,
  fat_100g     REAL,
  categories_tags TEXT
);

-- FTS5 virtual table: content= means it reads from products table.
-- prefix='2 3 4' adds prefix indexes for 2, 3, and 4-char prefixes —
-- critical for the 2-char worst-case benchmark query.
-- tokenize='unicode61 remove_diacritics 2' folds accented letters in Latin scripts.
-- Column order in bm25() weight calls: product_name, product_name_en, brand.
CREATE VIRTUAL TABLE products_fts USING fts5(
  product_name,
  product_name_en,
  brand,
  content='products',
  content_rowid='rowid',
  tokenize='unicode61 remove_diacritics 2',
  prefix='2 3 4'
);

-- Triggers are NOT needed: the ingest script populates products_fts once via
-- INSERT INTO products_fts(rowid, product_name, product_name_en, brand)
-- SELECT rowid, product_name, product_name_en, brand FROM products;
-- The DB is then read-only at runtime — no sync needed.
```

### Pattern 2: ATTACH DATABASE in Drift's beforeOpen

**What:** Attach the read-only `off_reference.sqlite` to the main `co2diet` connection so both are accessible in the same session.

**When to use:** Single app lifetime; attach once, use across all queries.

```dart
// Source: [CITED: https://drift.simonbinder.eu/examples/existing_databases/] + customStatement pattern
// In lib/data/local/migrations/migration_strategy.dart

MigrationStrategy buildMigrationStrategy(AppDatabase db, String offRefPath) {
  return MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // future migrations here
    },
    beforeOpen: (_) async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      // Attach the read-only reference DB under alias 'off_ref'
      // offRefPath = path to decompressed off_reference.sqlite in documents dir
      await db.customStatement(
        "ATTACH DATABASE '${offRefPath}' AS off_ref",
      );
      // Verify attach succeeded (optional sanity check)
      // await db.customStatement('PRAGMA off_ref.integrity_check');
    },
  );
}
```

**Key insight:** The `offRefPath` must be the path to the *decompressed* file, not the compressed asset. First-launch extraction must complete before `AppDatabase` initializes.

### Pattern 3: FTS5 Search Query via Drift customSelect

**What:** Drift cannot generate typed DAOs for FTS5 virtual tables. Use `customSelect` with the attached schema prefix `off_ref.`.

```dart
// Source: [CITED: https://drift.simonbinder.eu/sql_api/extensions/] +
//         [CITED: https://www.sqlite.org/fts5.html] (bm25 column weights)
// In FoodCatalogDao

Future<List<FoodItem>> searchLocalFoods(String query) async {
  // Sanitize: strip FTS5 metacharacters, append * for prefix match
  final sanitized = _sanitizeFts5Query(query);

  // Search off_ref first, then user-cached results.
  // bm25 weights: product_name=10.0, product_name_en=8.0, brand=3.0
  // ORDER BY bm25 ascending (bm25 returns negative — most relevant = most negative)
  final rows = await db.customSelect('''
    SELECT
      p.barcode,
      p.product_name,
      p.product_name_en,
      p.brand,
      p.calories_100g,
      p.protein_100g,
      p.carbs_100g,
      p.fat_100g,
      bm25(off_ref.products_fts, 10.0, 8.0, 3.0) AS rank
    FROM off_ref.products_fts
    JOIN off_ref.products p ON off_ref.products_fts.rowid = p.rowid
    WHERE off_ref.products_fts MATCH ?
    ORDER BY rank
    LIMIT 25
  ''', variables: [Variable.withString(sanitized)]).get();

  return rows.map(_rowToFoodItem).toList();
}

String _sanitizeFts5Query(String raw) {
  // Remove FTS5 special chars that cause parse errors.
  // Keep alphanumeric, spaces, hyphens; append * for prefix.
  final cleaned = raw.trim().replaceAll(RegExp(r'[^\w\s\-]'), '');
  // Multi-word: each term gets * suffix → AND logic is FTS5 default
  return cleaned.split(RegExp(r'\s+')).map((t) => '$t*').join(' ');
}
```

### Pattern 4: openfoodfacts API Search

**What:** Use `ProductSearchQueryConfiguration` with `SearchTerms` and `PageSize` parameters.

```dart
// Source: [CITED: https://pub.dev/documentation/openfoodfacts/latest/openfoodfacts/OpenFoodAPIClient/searchProducts.html]
// In OffApiClient

// One-time initialization (call at app startup, before any search)
void configureOFF() {
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'CO2Diet',
    url: 'https://reduceco2now.com',
  );
  OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.ENGLISH, OpenFoodFactsLanguage.GERMAN];
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.GERMANY;
}

Future<List<FoodItem>> searchOFF(String query) async {
  final config = ProductSearchQueryConfiguration(
    parametersList: [
      SearchTerms(terms: [query]),
      PageSize(size: 20),
      PageNumber(page: 1),
    ],
    language: OpenFoodFactsLanguage.ENGLISH,
    fields: [
      ProductField.BARCODE,
      ProductField.NAME,
      ProductField.BRANDS,
      ProductField.NUTRIMENTS,
    ],
    version: ProductQueryVersion.v3,
  );

  final result = await OpenFoodAPIClient.searchProducts(null, config);
  if (result.products == null) return [];
  return result.products!.map(_productToFoodItem).toList();
}
```

### Pattern 5: First-Launch Decompression

**What:** Extract `off_reference.sqlite.gz` from Flutter assets to the app documents directory before `AppDatabase` connects.

```dart
// Source: [CITED: https://drift.simonbinder.eu/examples/existing_databases/] — asset extraction pattern
// In lib/core/assets/first_launch_extractor.dart

Future<String> ensureOffReferenceDb(BuildContext context) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(docsDir.path, 'off_reference.sqlite'));

  if (await dbFile.exists()) {
    return dbFile.path; // Already extracted on a previous launch
  }

  // Load compressed asset
  final byteData = await rootBundle.load('assets/off_reference.sqlite.gz');
  final compressed = byteData.buffer.asUint8List();

  // Decompress using archive package (GZip)
  // Source: [CITED: pub.dev/packages/archive] — GZipDecoder
  final decompressed = GZipDecoder().decodeBytes(compressed);

  await dbFile.writeAsBytes(decompressed);
  return dbFile.path;
}
```

**First-launch UX:** Call `ensureOffReferenceDb` from the splash screen before `ProviderScope` creates `AppDatabase`. Show a `CircularProgressIndicator` with "Setting up food database..." text. Subsequent launches skip this entirely (file exists check).

### Pattern 6: Debounced Search Notifier

```dart
// Source: [ASSUMED] — Riverpod 3 AsyncNotifier + Timer debounce pattern
// (Pattern documented via multiple community references but not official Riverpod docs page)

@riverpod
class FoodSearchNotifier extends _$FoodSearchNotifier {
  Timer? _debounce;

  @override
  Future<FoodSearchState> build() async => const FoodSearchState.prompt();

  void onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.length < 2) {
      state = const AsyncData(FoodSearchState.prompt());
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
  }

  void onQuerySubmitted(String query) {
    _debounce?.cancel();
    if (query.length >= 2) _search(query);
  }

  Future<void> _search(String query) async {
    // Do NOT set state = loading here for local path — results appear instantly
    final repo = ref.read(foodCatalogRepositoryProvider);
    final local = await repo.searchLocal(query);

    if (local.isNotEmpty) {
      state = AsyncData(FoodSearchState.results(local));
      return;
    }

    // Check connectivity before API
    final connectivity = ref.read(connectivityResultProvider);
    if (connectivity == ConnectivityResult.none) {
      state = const AsyncData(FoodSearchState.offlineNoResults());
      return;
    }

    // API fallback — NOW show loading indicator
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.searchAndCache(query));
  }

  void retry(String query) => _search(query);
}
```

### Anti-Patterns to Avoid

- **FTS5 content table in a different file:** `content='other_db.table'` is not supported. The content table must be in the same database as the FTS5 virtual table. [VERIFIED: sqlite.org/fts5.html]
- **Shimmer on local FTS5 path:** Explicitly prohibited by UX decision. Local results appear without any loading indicator.
- **Calling OFF API when offline:** Always gate behind a `connectivity_plus` check first; avoid a failed network attempt before showing the offline error state.
- **Calling `customStatement` for ATTACH inside queries:** ATTACH must happen in `beforeOpen`, not per-query — ATTACH is connection-scoped.
- **Not sanitizing FTS5 query input:** FTS5 has metacharacters (`"`, `*`, `OR`, `AND`, `NOT`, `^`). User input must be sanitized or escaped before passing to `MATCH`.
- **Using CSS-like `ORDER BY rank` without bm25():** FTS5's default `rank` alias uses BM25 implicitly, but column weights require explicit `bm25(table, w0, w1, w2)`. Use explicit call for the boost behaviour.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| OFF API queries | Custom HTTP client for OFF REST v2 | `openfoodfacts` Dart client | OFF API has undocumented quirks; the official client handles User-Agent requirements, field normalization, taxonomy lookups, language handling |
| FTS5 search ranking | Custom relevance scoring in Dart | SQLite `bm25()` with column weights | BM25 is industry-standard; reimplementing it in Dart wastes time and produces worse results |
| GZip asset decompression | Platform channel to native zlib | `archive` package `GZipDecoder` | Pure Dart, no FFI, works on all platforms, proven at 10.7M download scale |
| Search debounce | Global singleton timer | `Timer` local to the Riverpod notifier | Timer lifetime tied to notifier lifecycle; no global state leak |
| OFF data filtering | Custom crawl of OFF API | Python ingest from JSONL dump | API throttling makes full crawl impractical; JSONL dump is the authoritative source |

**Key insight:** The hardest problem in this phase is getting FTS5 prefix search fast enough on low-end Android. SQLite's FTS5 prefix indexes (`prefix='2 3 4'`) solve this at the database layer — don't try to approximate it with Dart-side string matching.

---

## Common Pitfalls

### Pitfall 1: product_name_en Not in OFF CSV Export
**What goes wrong:** The Python ingest script reads the CSV export, finds no `product_name_en` column, and throws a `KeyError`. The seed DB ends up with NULL for all English names, breaking English-language search.
**Why it happens:** The OFF CSV export only carries `product_name` (the "primary" language name). Language-specific variants like `product_name_en`, `product_name_de` exist in the **JSONL** (full MongoDB) export but not in the CSV's column set. [MEDIUM confidence — confirmed by field documentation analysis; authoritative confirmation would require downloading and inspecting a current JSONL record]
**How to avoid:** Process the JSONL dump (`.gz`, ~5 GB compressed), not the CSV. In the Python script, extract `product_name` from the top-level field and `product_name_en` from the `product_name_languages` dict or directly from the `product_name_en` top-level key that exists in JSONL records. Use `.get('product_name_en')` with a None default.
**Warning signs:** After ingest, `SELECT count(*) FROM products WHERE product_name_en IS NOT NULL` returns 0.

### Pitfall 2: FTS5 content= Table Must Be in Same Database File
**What goes wrong:** The planner specifies `content='off_ref.products'` in the FTS5 DDL, hoping to reference the products table via the ATTACH alias. SQLite silently creates the FTS5 table but the content reference fails at rebuild time.
**Why it happens:** SQLite FTS5 external content mode resolves table names at runtime in the primary database schema. ATTACH aliases are not recognized for `content=`. [VERIFIED: sqlite.org/fts5.html]
**How to avoid:** The FTS5 table and the products table must both be in `off_reference.sqlite`. The Python ingest script creates both in the same file. At runtime, both are accessed through the `off_ref.` ATTACH alias.
**Warning signs:** `INSERT INTO products_fts(products_fts) VALUES('rebuild')` produces an error about table not found.

### Pitfall 3: Compressed Asset Too Large for Flutter Bundle
**What goes wrong:** `off_reference.sqlite` is 50–200 MB compressed. Adding it as a Flutter asset inflates APK/IPA size, potentially exceeding Google Play's 200 MB APK cap or App Store OTA download limits.
**Why it happens:** Flutter asset bundles are compiled directly into the APK. Large assets cause the APK to exceed platform limits.
**How to avoid:** Target ≤50 MB compressed. Verify with `flutter build apk --split-per-abi` and check `build/app/outputs/flutter-apk/` sizes. If the file exceeds 50 MB compressed: reduce the completeness threshold, restrict to DE/AT/CH instead of all EU, or strip additional columns. Consider Play Asset Delivery for the >50 MB case (Phase 6 concern if needed).
**Warning signs:** `flutter build apk` outputs a warning about asset bundle size; APK exceeds 150 MB.

### Pitfall 4: ATTACH DATABASE Path Hardcoded or Wrong
**What goes wrong:** `ATTACH DATABASE '/Users/ali/...'` with a hardcoded dev path baked in. The DB path is `null` on fresh install because first-launch decompression hasn't run yet.
**Why it happens:** `path_provider`'s `getApplicationDocumentsDirectory()` is async; if not awaited before `AppDatabase` initializes, the path is not available.
**How to avoid:** Run `ensureOffReferenceDb()` in the app startup sequence (in `main()` or a startup screen) and pass the resulting path into `AppDatabase` initialization. Never hardcode paths.
**Warning signs:** `DatabaseException: unable to open database file` or `no such table: off_ref.products_fts`.

### Pitfall 5: FTS5 Query Input Not Sanitized
**What goes wrong:** User types `"apple"` (with quotes) — FTS5 interprets this as a phrase query. User types `appl*` — double-star causes parse error. `OR` as a query causes a logic error.
**Why it happens:** FTS5 has its own query language with metacharacters.
**How to avoid:** Strip non-alphanumeric characters (except spaces and hyphens) from user input before building the FTS5 MATCH expression. Append `*` only after sanitization.
**Warning signs:** `SQLITE_ERROR: fts5: syntax error near...` in debug logs.

### Pitfall 6: `openfoodfacts` User-Agent Not Set
**What goes wrong:** OFF API returns 403 or rate-limits responses within minutes of first use.
**Why it happens:** OFF requires descriptive User-Agent strings. The default Dart HTTP UA is generic.
**How to avoid:** Call `OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'CO2Diet', url: 'https://reduceco2now.com')` in `main()` before any API call. [CITED: STACK.md initial research + openfoodfacts package documentation]
**Warning signs:** HTTP 403 responses or JSON parse errors on otherwise-valid queries.

### Pitfall 7: Python JSONL Ingest Memory Exhaustion
**What goes wrong:** The ingest script loads the full 5 GB JSONL into memory, causing OOM on developer machines with <16 GB RAM.
**Why it happens:** Naïve `json.load()` on a multi-GB file.
**How to avoid:** Stream the JSONL line-by-line with chunked `INSERT` batches (`executemany` every 10,000 rows). Use `gzip.open()` to stream the compressed file directly. Only decompress one record at a time.
**Warning signs:** Developer machine swap usage spikes; `MemoryError` in Python.

---

## Code Examples

### Building the FTS5 Index in Python Ingest Script

```python
# Source: [CITED: https://charlesleifer.com/blog/using-the-sqlite-json1-and-fts5-extensions-with-python/]
# tools/ingest_off.py (excerpt)

import gzip
import json
import sqlite3
from pathlib import Path

EU_COUNTRY_TAGS = {
    'en:france', 'en:germany', 'en:italy', 'en:spain', 'en:netherlands',
    'en:belgium', 'en:austria', 'en:switzerland',  # CH not EU but included
    'en:poland', 'en:sweden', 'en:denmark', 'en:finland', 'en:portugal',
    # ... add remaining EU countries
}
COMPLETENESS_THRESHOLD = 0.6

def ingest(jsonl_gz_path: Path, out_db_path: Path) -> None:
    conn = sqlite3.connect(out_db_path)
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS products (
            barcode TEXT PRIMARY KEY,
            product_name TEXT NOT NULL,
            product_name_en TEXT,
            brand TEXT,
            calories_100g REAL,
            protein_100g REAL,
            carbs_100g REAL,
            fat_100g REAL,
            categories_tags TEXT
        );
        CREATE VIRTUAL TABLE IF NOT EXISTS products_fts USING fts5(
            product_name,
            product_name_en,
            brand,
            content='products',
            content_rowid='rowid',
            tokenize='unicode61 remove_diacritics 2',
            prefix='2 3 4'
        );
    """)

    batch = []
    BATCH_SIZE = 10_000

    with gzip.open(jsonl_gz_path, 'rt', encoding='utf-8') as f:
        for line in f:
            p = json.loads(line)
            countries = set(p.get('countries_tags', []))
            if not countries.intersection(EU_COUNTRY_TAGS):
                continue
            if (p.get('completeness') or 0) < COMPLETENESS_THRESHOLD:
                continue
            name = p.get('product_name', '').strip()
            if not name:
                continue
            batch.append((
                p.get('code'),
                name,
                p.get('product_name_en'),   # None if absent
                p.get('brands'),
                p.get('nutriments', {}).get('energy-kcal_100g'),
                p.get('nutriments', {}).get('proteins_100g'),
                p.get('nutriments', {}).get('carbohydrates_100g'),
                p.get('nutriments', {}).get('fat_100g'),
                ','.join(p.get('categories_tags', [])),
            ))
            if len(batch) >= BATCH_SIZE:
                _flush(conn, batch)
                batch.clear()

    if batch:
        _flush(conn, batch)

    # Populate FTS index in one pass
    conn.executescript("""
        INSERT INTO products_fts(rowid, product_name, product_name_en, brand)
        SELECT rowid, product_name, product_name_en, brand FROM products;
    """)
    conn.execute('PRAGMA page_size = 4096')
    conn.execute('VACUUM')
    conn.commit()
    conn.close()

def _flush(conn, batch):
    conn.executemany("""
        INSERT OR IGNORE INTO products
          (barcode, product_name, product_name_en, brand,
           calories_100g, protein_100g, carbs_100g, fat_100g, categories_tags)
        VALUES (?,?,?,?,?,?,?,?,?)
    """, batch)
    conn.commit()
```

### Benchmark Integration Test

```dart
// Source: [CITED: https://docs.flutter.dev/cookbook/testing/integration/profiling]
// integration_test/food_search_benchmark_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
// import your app and providers

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BM-01: worst-case 2-char prefix query < 1s', (tester) async {
    // Initialize DB with off_reference.sqlite attached
    final repo = /* ... get FoodCatalogRepository from test container */;

    final sw = Stopwatch()..start();
    final results = await repo.searchLocal('mi');  // "mi" → Milch, Milchschokolade, etc.
    sw.stop();

    expect(sw.elapsedMilliseconds, lessThan(1000),
        reason: 'Worst-case 2-char query must complete in < 1s');
    expect(results, isNotEmpty,
        reason: 'High-frequency term must return results');
  });

  testWidgets('BM-02: full-word query < 1s', (tester) async {
    final repo = /* ... */;

    final sw = Stopwatch()..start();
    final results = await repo.searchLocal('banana');
    sw.stop();

    expect(sw.elapsedMilliseconds, lessThan(1000));
  });

  testWidgets('BM-03: no-local-result query triggers API path < 1s', (tester) async {
    // Use a query that produces 0 local results to exercise the fallback timing
    // (measures local search time only; API call time is excluded from this benchmark)
    final repo = /* ... */;

    final sw = Stopwatch()..start();
    final results = await repo.searchLocal('xyzzy_noresult_42');
    sw.stop();

    expect(sw.elapsedMilliseconds, lessThan(1000));
    expect(results, isEmpty, reason: 'This term must not match in local DB');
  });
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|-----------------|--------------|--------|
| FTS3/FTS4 in SQLite | FTS5 (default since 3.9.0) | SQLite 3.9.0 (2015) | BM25 ranking built-in; better prefix index performance; cleaner API |
| `sqflite` raw SQL | Drift with `.drift` file FTS5 | Drift v2 (2022+) | Static analysis of SQL queries; typed results |
| `openfoodfacts` v1/v2 API | v3 API (`ProductQueryVersion.v3`) | Package 3.x | Cleaner response structure; more fields exposed |
| Bundling full OFF database | Tiered starter pack (~50 MB) + API fallback | Architecture choice for Phase 2 | Feasible APK size; >90% hit-rate achievable |
| `moor` package name | `drift` package name | 2021 rename | Same library; old tutorials use `moor` — ignore them |

**Deprecated/outdated:**
- `moor`: Renamed to `drift` in 2021. Any tutorial referencing `moor` uses old APIs.
- FTS4: Superseded by FTS5. FTS5 is enabled by default in drift_flutter's bundled SQLite.
- `openid_client` for OFF auth: OFF API v3 for search is unauthenticated; no auth needed for public product search.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `product_name_en` exists as a top-level key in the OFF JSONL export | Code Examples / Pitfall 1 | Ingest script must fall back to `product_name_languages.en` or omit the column; search hits for English-only users degrade |
| A2 | OFF `completeness` field is present in the JSONL export (issue #2325 confirmed it was added to CSV; confirmed in JSONL too) | Architecture / Pipeline | Filter criterion unusable; must use alternative quality signal like `nutriments_n` or `states_tags` |
| A3 | EU-filtered + completeness ≥ 0.6 subset fits in ≤50 MB compressed SQLite | Standard Stack | If >50 MB, need Play Asset Delivery or reduced filter scope |
| A4 | `openfoodfacts` Dart `ProductSearchQueryConfiguration` accepts `PageSize(size: 20)` for controlling result count | Code Examples | May need alternative pagination parameter; check package changelog at implementation time |
| A5 | FTS5 prefix query on 2 chars with prefix indexes completes in <200 ms on Pixel 6a (leaving headroom for Flutter framework overhead) | Architecture | Benchmark may fail; would require reducing dataset or narrowing prefix index |
| A6 | `connectivity_plus` 7.3.0 remains compatible with the `flutter_riverpod` 3.3.2 and existing constraint set | Standard Stack | Pub dependency conflict; may need version pinning |
| A7 | Debounce with `Timer` inside Riverpod `AsyncNotifier` does not cause state leaks when notifier is disposed | Code Examples | Memory leak in search screen if notifier is auto-disposed mid-debounce; add `_debounce?.cancel()` in `dispose()` override |

---

## Open Questions

> Status key: **OPEN** = not yet answered; **RESOLVED** = decision made and implemented; **EXECUTION-GATED** = can only be answered by running something at a specific wave.

1. **OFF JSONL field name for English product name** — **OPEN**
   - What we know: OFF has multilingual names; JSONL contains more fields than CSV
   - What's unclear: Exact key — `product_name_en` vs. `product_name_languages.en` vs. nested structure
   - Why still open: The JSONL dump has not been downloaded and no sample has been inspected. Assumption A1 in the Assumptions Log marks this LOW confidence.
   - How the plan handles it: `ingest_off.py` uses `.get('product_name_en')` with a `None` default — silent on missing key either way. The post-ingest gate in 02-02 Task 2 checks `SELECT count(*) FROM products WHERE product_name_en IS NOT NULL`; a zero result is a red flag that triggers a script fix before full ingest.
   - Execution gate: **02-02 Task 2** — `tools/README.md` "Inspect a sample" step (`zcat ... | head -5 | python3 -m json.tool`) must be run by the developer before triggering the full ingest. Cannot be a Wave 0 task (requires the JSONL to be downloaded, which is a 5 GB pre-requisite outside the repo).

2. **Actual filtered DB size** — **OPEN**
   - What we know: Full OFF is ~9 GB uncompressed; EU subset is smaller; completeness ≥ 0.6 reduces further
   - What's unclear: Whether the filtered subset, with only the 9 specified columns, compresses to ≤50 MB
   - Why still open: The ingest script does not yet exist (it is created by 02-02 Task 1) and no sample ingest has run.
   - How the plan handles it: 02-02 Task 2 includes a "Size check" step — run `--sample` on 10% of records, extrapolate compressed size, adjust `--completeness-threshold` or country scope if projection exceeds 50 MB. `gzip -k assets/off_reference.sqlite` + `ls -lh` is the gate before the asset is committed.
   - Execution gate: **02-02 Task 2** — cannot precede 02-02 Task 1 (the ingest script must be created first). Cannot be a Wave 0 task for that reason.

3. **FTS5 query time on actual Pixel 6a hardware** — **EXECUTION-GATED**
   - What we know: FTS5 prefix indexes deliver sub-millisecond lookups for typical queries; `prefix='2 3 4'` handles worst-case 2-char query
   - What's unclear: Whether the 300 ms debounce timer plus SQLite round-trip through ATTACH fits within 1s on Android's single-threaded SQLite on the reference device class
   - Why still open: Cannot be answered without physical hardware.
   - Execution gate: **02-07 Task 3** — human-verify checkpoint on physical Pixel 6a or Samsung A54 class device. Benchmark `Stopwatch`-based assertions in `integration_test/food_search_benchmark_test.dart` are the automated signal; the human gate is the physical device confirmation. If the benchmark fails, 02-07 Task 3 blocks phase completion and requires investigation (likely: reduce dataset scope or adjust prefix indexes).

4. **User-catalog FTS5 table schema** — **RESOLVED**
   - Decision made: `user_food_cache_fts` uses the same column set as `off_ref.products_fts` — `(product_name, product_name_en, brand)` — for UNION query compatibility. A separate `.drift` file (`lib/data/local/daos/user_food_cache_fts.drift`) declares the virtual table with `content='user_food_cache_table'`.
   - Implemented in: **02-03 Task 2** (`user_food_cache_fts.drift` + `FoodCatalogDao.searchLocalFoods` UNION query).
   - Rationale: Identical column layout allows a single UNION ALL query without column aliasing. A simpler single-table approach was rejected because it would prevent UNION with `off_ref.products_fts` without schema adaptation overhead.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Python 3 | `tools/ingest_off.py` | Yes | 3.14.2 | — |
| pip3 | Python packages in ingest script | Yes | 25.3 | — |
| Flutter | App build | Yes | 3.44.6 (stable) | — |
| Dart SDK | Flutter / integration tests | Yes | 3.12.2 | — |
| Physical Android device (Pixel 6a / Samsung A54) | Benchmark tests | Unknown | — | Android emulator (not equivalent — emulator performance does not represent real device) |
| OFF JSONL dump (~5 GB compressed) | `tools/ingest_off.py` | Not yet downloaded | — | Must download before ingest pipeline can run; see openfoodfacts.org/data |

**Missing dependencies with no fallback:**
- Physical Android reference device — benchmark requires real hardware per SUCCESS criteria. Emulator results are NOT acceptable per the phase goal.

**Missing dependencies with fallback:**
- OFF JSONL dump — not downloaded yet; download step must be Wave 0 task before ingest can run.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (SDK) + `integration_test` (SDK) |
| Config file | none — uses `flutter test` and `flutter test integration_test/` |
| Quick run command | `flutter test test/` |
| Full suite command | `flutter test test/ && flutter test integration_test/` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| LOG-01 | Local FTS5 search returns results in <1s | integration (benchmark, physical device) | `flutter test integration_test/food_search_benchmark_test.dart` | No — Wave 0 |
| LOG-01 | FTS5 DAO searchLocal returns FoodItem list | unit (flutter test, in-memory DB) | `flutter test test/data/local/food_catalog_dao_test.dart` | No — Wave 0 |
| LOG-02 | API fallback fires when localResults is empty | unit (mock OFF client) | `flutter test test/data/repositories/food_catalog_repository_test.dart` | No — Wave 0 |
| LOG-02 | API results are written to co2diet.sqlite | unit (in-memory DB + mock) | included in repository test | No — Wave 0 |
| NFR-06a | >90% hit rate on 200-food benchmark list | integration (device or emulator as proxy) | `flutter test integration_test/food_search_benchmark_test.dart` | No — Wave 0 |
| NFR-06b | CO₂ coverage check | DEFERRED — CO₂ factor table built in Phase 3 | manual / Phase 3 | N/A |

### Sampling Rate

- **Per task commit:** `flutter test test/`
- **Per wave merge:** `flutter test test/ && flutter test integration_test/` (emulator acceptable for non-benchmark tests)
- **Phase gate:** Full suite green + benchmark passing on physical Android device before `/gsd-verify-work`

### Wave 0 Gaps

- [ ] `integration_test/food_search_benchmark_test.dart` — covers LOG-01, NFR-06a benchmarks
- [ ] `test/data/local/food_catalog_dao_test.dart` — covers FTS5 DAO queries
- [ ] `test/data/repositories/food_catalog_repository_test.dart` — covers fallback + caching
- [ ] `test/features/food_search/food_search_notifier_test.dart` — covers debounce, state transitions
- [ ] `integration_test/` directory must be created
- [ ] `build.yaml` must be created with FTS5 module configuration

---

## Security Domain

> `security_enforcement` is not set to false in config.json — section required.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No | Phase 2 is local-only; no auth required |
| V3 Session Management | No | No sessions in this phase |
| V4 Access Control | No | Read-only OFF DB access; no user ACL |
| V5 Input Validation | Yes | FTS5 query sanitization: strip metacharacters before MATCH |
| V6 Cryptography | No | No encryption needed for food catalog data |

### Known Threat Patterns for This Stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| FTS5 injection via unescaped user input | Tampering | Sanitize query string — remove `"`, `*`, `OR`, `AND`, `NOT`, `NEAR`; parameterize via Drift's `Variable.withString()` |
| Path traversal in ATTACH DATABASE path | Elevation of Privilege | Use `path_provider` to derive the path; never accept user input as ATTACH path |
| Large FTS5 query causing DoS (CPU spike) | Denial of Service | 2-char minimum before querying; LIMIT 25 on results |
| OFF API response injection (malformed JSON) | Tampering | `openfoodfacts` package handles JSON deserialization; validate non-null before writing to DB |

---

## Sources

### Primary (HIGH confidence)
- [VERIFIED: pub.dev API] `openfoodfacts` 3.30.2 — confirmed version, publisher openfoodfacts.org
- [VERIFIED: pub.dev API] `archive` 4.0.9, `drift` 2.34.2, `path_provider` 2.1.6, `shimmer` 3.0.0, `connectivity_plus` 7.3.0
- [CITED: https://www.sqlite.org/fts5.html] — FTS5 DDL syntax, prefix indexes, BM25 weights, content= restriction to same-database
- [CITED: https://drift.simonbinder.eu/sql_api/extensions/] — Drift FTS5 support, `.drift` file declaration requirement
- [CITED: https://drift.simonbinder.eu/examples/existing_databases/] — Asset extraction pattern for pre-populated SQLite
- [CITED: https://drift.simonbinder.eu/generation_options/] — build.yaml FTS5 module configuration
- [CITED: https://pub.dev/documentation/openfoodfacts/latest/openfoodfacts/OpenFoodAPIClient/searchProducts.html] — `ProductSearchQueryConfiguration`, `SearchTerms`, `PageSize`

### Secondary (MEDIUM confidence)
- [CITED: https://world.openfoodfacts.org/data] — OFF export sizes (CSV ~0.9 GB compressed, ~9 GB uncompressed; JSONL ~5 GB+); Parquet recommended for analytics
- [CITED: https://github.com/openfoodfacts/openfoodfacts-server/issues/2325] — `completeness` field confirmed as addition to CSV export
- [CITED: https://openfoodfacts.github.io/openfoodfacts-python/usage/] — `product_name` key in JSONL; language-specific variants exist

### Tertiary (LOW confidence)
- [ASSUMED] `product_name_en` as a flat top-level key in JSONL (inferred from multilingual field pattern; not directly confirmed by inspecting a current JSONL record)
- [ASSUMED] EU-filtered + completeness≥0.6 subset compresses to ≤50 MB SQLite (based on estimated row count reduction; must be verified by running ingest)

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all package versions verified via pub.dev API on 2026-07-17
- FTS5 / Drift architecture: HIGH — verified via official SQLite docs and Drift docs
- OFF data pipeline: MEDIUM — field names require verification against actual JSONL sample
- First-launch decompression: HIGH — `archive` package capabilities confirmed via pub.dev
- Pitfalls: HIGH for SQLite constraints (verified docs); MEDIUM for OFF field names

**Research date:** 2026-07-17
**Valid until:** 2026-09-17 (stable stack — 60 days); OFF data format changes are rare but check the JSONL field structure before coding

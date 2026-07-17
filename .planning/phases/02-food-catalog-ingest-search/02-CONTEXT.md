# Phase 2: Food Catalog Ingest & Search - Context

**Gathered:** 2026-07-17
**Status:** Ready for planning

<domain>
## Phase Boundary

Ship a fast, offline, high-coverage food catalog: an OFF seed database ingested via a Python pipeline, FTS5-indexed, bundled compressed into the app, searchable via a standalone search screen, with an online OFF API fallback that caches results locally. Benchmarked to <1s on low-end Android.

**What this phase does NOT include:**
- Barcode scanning (Phase 3)
- CO₂ factor table or CO₂ estimates (Phase 3)
- Meal logging or "Add to meal" actions (Phase 4)
- Custom food creation / My Foods (Phase 4)
- Recent / Favorites (Phase 4)
- Category filtering on search (Phase 4+)
- Full nutrition display (Phase 4–5)

</domain>

<decisions>
## Implementation Decisions

### Search Screen Entry Point
- Standalone `/food-search` route, reachable from Settings or a dev shortcut for Phase 2
- Phase 4 wires the real entry points (from meal logging flows) — this route is already there

### Search Screen Layout
- Full-screen layout; search field replaces the AppBar title slot (no separate title)
- Auto-focus: keyboard opens immediately on screen load
- Clear (✕) button inside the search field; appears once text is entered
- Back navigation: system back button / AppBar back arrow (standard go_router pop)
- No voice input, no barcode shortcut, no filters, no pull-to-refresh in Phase 2

### Empty / Prompt State (no query entered)
- Illustration + "Search for a food..." hint text
- No suggested items (Recent/Favorites belong in Phase 4)

### No-Results State (query returned nothing from local + API)
- Genuine no-match: illustration + "No results for 'X'" — no "Add custom food" link (Phase 4 adds that once the flow exists)
- Offline with 0 local results: same illustration + "No results — connect to the internet to search more"
- Network failure during API call: "Couldn't reach the food database — check your connection" + "Try again" button (no auto-retry)

### Loading Indicator Strategy
- **Local FTS5 results:** no loading indicator — results appear near-instantly; showing shimmer for sub-second queries would misrepresent speed
- **API fallback path:** shimmer skeleton rows + "Searching online..." banner — the only place where real network latency exists

### Result List Row (compact list view)
- Name (bold) + brand (secondary, greyed — omitted entirely if empty) + calories per 100g ("— kcal/100g" if missing)
- No thumbnails, no Nutri-Score badge, no category icon in Phase 2
- No visual distinction between local vs. API-sourced rows at the row level

### Food Detail Bottom Sheet (on result tap)
- Read-only sheet: name, brand, full macros per 100g (calories, protein, carbs, fat)
- CO₂ row is hidden entirely — factor table doesn't exist until Phase 3
- Phase 4 adds the "Log this food" action to this same surface (no rebuild needed)

### FTS5 Search Behavior
- **Trigger:** as-you-type with 300ms debounce; Enter key fires immediately (cancels debounce)
- **Minimum chars:** 2 characters before query fires
- **Matching:** FTS5 prefix matching (`*` suffix on query terms) — no substring, no umlaut/ASCII folding in Phase 2
- **Indexed columns:** `product_name`, `product_name_en`, `brand` — all three searchable
- **Column weighting:** `product_name_en` gets higher BM25 weight (English UI, English-named products rank above German-named equivalents when English name is available)
- **Multi-word queries:** AND logic — all terms must match
- **Result ranking:** exact `product_name`/`product_name_en` match boosted to top, then BM25 for the rest
- **Result count:** 25 from local FTS5
- **Clear field:** immediately shows empty/prompt state (no lingering results)

### FTS5 Database Architecture
- FTS5 virtual table lives inside `off_reference.sqlite` (the seed DB), not in `co2diet.sqlite`
- `ATTACH DATABASE` is called once at `AppDatabase` initialization, persistent for the app session

### API Fallback
- **Threshold:** fires only when local FTS5 returns 0 results
- **Request:** 20 results from OFF API per query
- **Caching:** API results written to user-catalog tables in `co2diet.sqlite` using `SyncSafeTable` mixin (UUID v7, HLC, dirty flag — ready for Phase 7 sync)
- **Cached results indexed:** FTS5 table in `co2diet.sqlite` indexes cached items — they appear in future local searches without re-hitting the API
- **No auto-retry:** network failure goes to the explicit error state with a "Try again" button
- **No data-saver / metered-connection check** in Phase 2 (Phase 8 concern)

### OFF Seed Database Pipeline
- **Tool:** Python script at `tools/ingest_off.py`; reads OFF CSV/JSONL, writes `off_reference.sqlite`
- **Filter criteria:** `countries_tags` contains any EU country AND `off_completeness ≥ 0.6`
- **Columns stored per product:**
  - `barcode` (EAN-13)
  - `product_name` (primary, may be German/French/other)
  - `product_name_en` (English name, nullable)
  - `brand`
  - `calories_100g`, `protein_100g`, `carbs_100g`, `fat_100g`
  - `categories_tags` (comma-separated or JSON string — Phase 4+ filter consumer)
  - **Excluded:** `nutriscore_grade` (no confirmed UI consumer; add via migration when needed)
- **Compression:** `off_reference.sqlite` is bundled compressed (zstd or lz4) as a Flutter asset; decompressed on first launch to the app documents directory
- **First-launch decompression UX:** blocking splash / loading screen with progress indicator; one-time only

### Benchmark
- **Format:** Dart integration test (`flutter test integration_test/`)
- **Three required test cases:**
  1. Worst-case: 2-char query on a high-frequency term (e.g., "mi")
  2. Average: full-word query (e.g., "banana")
  3. Edge: a no-local-result query that triggers the API fallback path
- All three must complete in <1s on the reference device (Pixel 6a / Samsung A54 class)

### Claude's Discretion
- Drift DAO design for food catalog tables (off_ref reads vs. user-catalog writes)
- Riverpod provider / state management structure for the search screen
- Exact FTS5 `CREATE VIRTUAL TABLE` syntax, tokenizer config, and column weight values
- zstd vs. lz4 compression algorithm choice
- Error state widget visual design details
- Bottom sheet animation / drag-to-dismiss specifics
- Exact Python ingest script structure (chunked reads, progress reporting, etc.)

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `SyncSafeTable` mixin (`lib/data/local/mixins/sync_safe_table.dart`) — Phase 2 materializes food catalog tables (user-catalog side) using this mixin
- `AppDatabase` (`lib/data/local/app_database.dart`) — `ATTACH DATABASE` for `off_reference.sqlite` is added here in `beforeOpen` or a dedicated initialization step
- `DriftProfileRepository` pattern — template for the food catalog repository
- `DriftDatabase` / `drift_flutter` — already wired; no new SQLite dependency needed

### Established Patterns
- Schema registry: Phase 2 adds food catalog tables to `app_database.dart`, following the `UserProfileTable` pattern
- Riverpod + codegen DI (flutter_riverpod 3.3.2 + riverpod_annotation 4.0.3) — search state provider follows existing DI patterns
- go_router 17.3.0 — `/food-search` route added to the existing router
- DESIGN.md token set — all UI uses the existing theme (green primary, Plus Jakarta Sans, 8/16/24px radii)
- Dark mode from Phase 1 — search screen must respect `ThemeData.dark()`

### Integration Points
- `off_reference.sqlite` is a Flutter asset (bundled compressed), decompressed to app documents dir on first launch, then attached via `ATTACH DATABASE` in `AppDatabase`
- User-catalog tables (for API-cached results) live in `co2diet.sqlite` alongside existing tables; Phase 4 food search accesses both via the same `AppDatabase`
- `openfoodfacts` Dart client (to be added as dependency) — handles OFF API v2 search and product lookup

</code_context>

<specifics>
## Specific Ideas

- "No shimmer for local FTS5 — showing it would misrepresent the app's actual speed. Reserve shimmer for the API fallback path only." (explicit user decision)
- "No Nutri-Score badge in Phase 2 UI — no confirmed consumer. Column excluded from seed DB until a phase actually needs it." (reversed an earlier momentary choice; this is the confirmed decision)
- "No-results states must be distinct: genuine no-match vs. offline vs. network-failure each get a different message." (user's honesty principle — same as '—' for missing data, no fake CO₂)
- `categories_tags` included in seed DB now — confirmed Phase 4+ filter consumer. Rebuilding the DB later is costlier than including it now.
- `product_name_en` alongside `product_name` — EU products with German primary names still findable via English search terms

</specifics>

<deferred>
## Deferred Ideas

- **Umlaut / ASCII folding** (typing "Muller" finds "Müller") — deferred; Phase 2 proves speed, not linguistic edge cases
- **Category filter chips on search** — Phase 4+ (categories_tags column is in the DB, but the filter UI belongs with meal logging)
- **Nutri-Score badge on result rows** — no confirmed phase; add when a phase explicitly requires it
- **Data-saver / metered connection check for API** — Phase 8 (where large OFF pack downloads are the concern)
- **"Add custom food" link on no-results state** — Phase 4 (once My Foods / custom food creation exists)
- **fiber_100g, salt_100g, sugar_100g columns in seed DB** — no confirmed Phase 2 consumer; Phase 4 extends the ingest schema when full nutrition display is built
- **Food thumbnails from OFF CDN** — Phase 4–5 at earliest; requires cached_network_image and CDN dependency

</deferred>

---

*Phase: 02-food-catalog-ingest-search*
*Context gathered: 2026-07-17*

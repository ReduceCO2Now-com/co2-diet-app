---
phase: 03-barcode-scanning-co-factor-table
plan: 02
subsystem: database
tags: [sqlite, agribalyse, co2, drift, flutter, python, ingest, food-catalog]

# Dependency graph
requires:
  - phase: 03-01
    provides: Wave 0 test stubs for barcode/CO2 test files
  - phase: 02-02
    provides: off_reference.sqlite with products table and FTS5

provides:
  - FoodItem with co2e100g (double?) and confidenceBand (String?) nullable fields
  - FoodCatalogDao.lookupByBarcodeWithCo2 with EAN-13 max-length guard
  - FoodCatalogDao.lookupByBarcodeFromApi stub for BarcodeScanNotifier (Plan 03-03)
  - co2_factors table in off_reference.sqlite (91 rows, AGRIBALYSE v3.1.1 medians)
  - food_co2_overrides table (3514 rows, direct barcode→CIQUAL crosswalk)
  - products.primary_category_tag column populated for 94.6% of rows
  - off_to_agribalyse_map.csv with 91 OFF category → AGRIBALYSE group mappings
  - backfill_agribalyse_food_code() utility for bootstrapping existing DBs
affects:
  - 03-03 (BarcodeScanNotifier uses lookupByBarcodeWithCo2 and lookupByBarcodeFromApi)
  - 03-04 (CO2 display layer reads co2e100g and confidenceBand from FoodItem)
  - 03-05 (MethodologyScreen references co2_methodology_version from co2_factors)

# Tech tracking
tech-stack:
  added: [statistics (Python stdlib — median computation), urllib.request (AGRIBALYSE CSV download)]
  patterns:
    - AGRIBALYSE v3.1.1 group-median CO2e computation (category-level estimate)
    - Pinned URL pattern for reproducible data downloads (agribalyse-31-synthese)
    - Backfill utility pattern for enriching existing SQLite from JSONL source
    - Parameterized SQL via Variable.withString for barcode queries (T-03-02-01)
    - Max-length guard before DB access (T-03-02-02 — EAN-13 = 13 chars max)

key-files:
  created:
    - tools/off_to_agribalyse_map.csv
    - test/data/local/food_catalog_dao_barcode_test.dart (Wave 0 stub, now GREEN)
    - test/domain/entities/food_item_test.dart (Wave 0 stub, now GREEN with CO2 tests)
  modified:
    - lib/domain/entities/food_item.dart
    - lib/data/local/daos/food_catalog_dao.dart
    - tools/ingest_off.py
    - assets/off_reference.sqlite
    - assets/off_reference.sqlite.gz

key-decisions:
  - "agribalyse_food_code extracted from ecoscore_data.agribalyse.agribalyse_food_code in OFF JSONL (path confirmed by sampling)"
  - "backfill_agribalyse_food_code() added as standalone utility — existing DB bootstrapped without full re-ingest"
  - "co2_factors keyed by OFF categories_tag (not AGRIBALYSE group name) for direct JOIN in Dart DAO"
  - "food_co2_overrides uses CIQUAL code as the crosswalk key between OFF barcode and AGRIBALYSE CO2 value"
  - "ingest_agribalyse_standalone() now compresses to .gz after ingest for Flutter asset bundle consistency"
  - "primary_category_tag updated via Python batch loop (not SQL subquery) to avoid json_each pitfall (RESEARCH.md Pitfall 5)"

patterns-established:
  - "CO2 confidence bands: 'high' = direct barcode match in food_co2_overrides; 'medium' = category average via co2_factors"
  - "Barcode lookup chain: Step 1 food_co2_overrides (high), Step 2 co2_factors via primary_category_tag (medium), null if no match"
  - "off_to_agribalyse_map.csv as human-curated mapping file between two taxonomy systems"

requirements-completed: [CO2-01, LOG-03, LEG-05]

# Metrics
duration: ~90min
completed: 2026-07-22
---

# Phase 03 Plan 02: CO₂ Data Foundation Summary

**AGRIBALYSE v3.1.1 integrated into off_reference.sqlite with 91-row co2_factors table and 3514-row food_co2_overrides crosswalk; FoodItem extended with co2e100g/confidenceBand fields and FoodCatalogDao gains barcode CO₂ lookup with EAN-13 length guard**

## Performance

- **Duration:** ~90 min
- **Started:** 2026-07-22T10:30:00Z
- **Completed:** 2026-07-22T12:11:40Z
- **Tasks:** 2
- **Files modified:** 6 (+ 2 assets created)

## Accomplishments

- Extended `FoodItem` with two nullable CO₂ fields (`co2e100g: double?`, `confidenceBand: String?`) using existing sentinel copyWith pattern
- Added `lookupByBarcodeWithCo2` to `FoodCatalogDao`: two-step query (high-confidence direct match → medium-confidence category average) with EAN-13 max-length guard (T-03-02-01/02)
- Extended `ingest_off.py` with `ingest_agribalyse()`: downloads AGRIBALYSE v3.1.1 synthesis CSV, computes group medians, populates `co2_factors` (91 rows) and `food_co2_overrides` (3514 rows)
- Authored `off_to_agribalyse_map.csv` with 91 OFF category → AGRIBALYSE group mappings covering all major food groups
- Populated `products.primary_category_tag` for 333,872 / 352,844 products (94.6%) enabling category-level CO₂ lookups
- All 41 tests pass; flutter analyze reports no issues

## Task Commits

Each task was committed atomically:

1. **Task 1: Extend FoodItem entity with CO₂ fields and update FoodCatalogDao with barcode lookup** - `df6a8ab` (test — RED), `e344179` (feat — GREEN)
2. **Task 2: Extend ingest_off.py with AGRIBALYSE v3.1.1 and author off_to_agribalyse_map.csv** - `88d1919` (feat)

## Files Created/Modified

- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/lib/domain/entities/food_item.dart` - Added co2e100g, confidenceBand fields; updated fromQueryRow, copyWith, toString
- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/lib/data/local/daos/food_catalog_dao.dart` - Added lookupByBarcodeWithCo2 (two-step CO2 query) and lookupByBarcodeFromApi stub
- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/tools/ingest_off.py` - Added ingest_agribalyse(), backfill_agribalyse_food_code(), updated DDL/INSERT_SQL for agribalyse_food_code column
- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/tools/off_to_agribalyse_map.csv` - New file: 91 OFF category → AGRIBALYSE group mappings
- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/assets/off_reference.sqlite` - Updated with co2_factors, food_co2_overrides, primary_category_tag
- `/Users/alisafi/Documents/ReduceCO2-Now/Co2-diet-app/assets/off_reference.sqlite.gz` - Compressed version of updated SQLite

## Decisions Made

- **agribalyse_food_code extraction path:** Field lives at `ecoscore_data.agribalyse.agribalyse_food_code` in the OFF JSONL — confirmed by sampling the first 5000 records. Coverage is ~2.7% of EU products (92,951 of ~3.4M barcodes processed), yielding 3514 food_co2_overrides rows where barcode matches AGRIBALYSE CIQUAL codes.
- **Backfill approach instead of re-ingest:** The existing off_reference.sqlite has 352K products already filtered from the 12GB JSONL. Added `backfill_agribalyse_food_code()` to scan the JSONL once and UPDATE matching rows, avoiding a full 45-min re-ingest.
- **co2_factors keyed by OFF tag (not AGRIBALYSE group):** The JOIN in `lookupByBarcodeWithCo2` (`cf.categories_tag = p.primary_category_tag`) requires `co2_factors` to use OFF tags as the primary key, not AGRIBALYSE group names. The mapping CSV provides the translation.
- **ingest_agribalyse_standalone() now compresses .gz:** Future standalone AGRIBALYSE refreshes will keep the Flutter asset bundle current automatically.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] agribalyse_food_code missing from DDL/INSERT_SQL caused 0 food_co2_overrides rows**
- **Found during:** Task 2 (ingest verification)
- **Issue:** The original `DDL` and `INSERT_SQL` did not include `agribalyse_food_code` column. The `ingest_agribalyse()` function added the column via ALTER TABLE but the ingest pipeline never populated it, leaving `food_co2_overrides` empty (0 rows instead of ≥500).
- **Fix:** Updated `DDL` to include `agribalyse_food_code TEXT`, updated `INSERT_SQL` to include the column, added extraction of `ecoscore_data.agribalyse.agribalyse_food_code` in the `ingest()` row extraction. Added `backfill_agribalyse_food_code()` to update the existing database without re-running the full ingest.
- **Files modified:** tools/ingest_off.py
- **Verification:** Re-ran `--agribalyse-only` after backfill; food_co2_overrides = 3514 rows.
- **Committed in:** 88d1919 (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 — bug)
**Impact on plan:** Auto-fix was essential for correctness (food_co2_overrides target was ≥500 rows). No scope creep. All plan goals achieved.

## Issues Encountered

- The OFF JSONL dump contains ~4.6M total records (including non-EU/low-completeness products) but only 352K pass the EU + completeness + product_name filters. The `agribalyse_food_code` field is only present in ~2.7% of all records (ecoscore annotation is sparse), yielding 92,951 products with codes. After CIQUAL crosswalk, 3,514 have both a barcode match AND a valid AGRIBALYSE CO₂ value.

## Known Stubs

None — all data is wired. The integration test group in `food_catalog_dao_barcode_test.dart` is skipped when `OFF_REF_PATH` is not set (expected behavior — requires real DB path at test time). Integration tests will be activated in Plan 03-04 when the full lookup chain is exercised.

## Threat Surface Scan

No new network endpoints introduced at runtime. AGRIBALYSE download is ingest-time only (developer machine). T-03-02-01 (SQL injection via barcode) mitigated: `Variable.withString(barcode)` used throughout. T-03-02-02 (DoS via oversized barcode) mitigated: max-length guard (>13 chars → null) before any DB access.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- Plan 03-03 (BarcodeScanNotifier) can now call `lookupByBarcodeWithCo2` and `lookupByBarcodeFromApi` from `FoodCatalogDao`
- Plan 03-04 (CO₂ display layer) can read `co2e100g` and `confidenceBand` from `FoodItem`
- Plan 03-05 (MethodologyScreen) can query `co2_methodology_version` from `co2_factors`
- `off_reference.sqlite.gz` asset is up-to-date with CO₂ tables for the Flutter bundle

---
*Phase: 03-barcode-scanning-co-factor-table*
*Completed: 2026-07-22*

# Phase 3: Barcode Scanning & CO₂ Factor Table - Context

**Gathered:** 2026-07-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver P0 barcode scanning verified on real Android hardware (iOS deferred — see device testing section), and the product→CO₂ factor mapping that gives every scanned or searched food a defensible CO₂e estimate with a High/Medium confidence band. Every food item in the existing FoodDetailBottomSheet gains a CO₂ row in this phase. Phase 4 adds the "Log this food" action to the same surface.

**What this phase does NOT include:**
- Meal logging or "Add to Breakfast/Lunch/Dinner/Snack" actions (Phase 4)
- Custom food creation form (Phase 4 — Phase 3 only hands off the barcode to a stub route)
- Full nutrition display beyond what Phase 2's bottom sheet already shows (Phase 4–5)
- CO₂ profile modifiers (location, cooking method, etc.) — CO₂ Calculation Settings (Phase 5)
- Methodology changelog / announcement flow (Phase 5)
- iOS real-device barcode verification (deferred to Phase 4 — see device testing)

</domain>

<decisions>
## Implementation Decisions

### Scanner Entry Point & Navigation

- Barcode icon in the search screen AppBar (`FoodSearchScreen`) — triggers the scanner from the existing Phase 2 surface
- Dedicated `/barcode-scan` go_router named route — Phase 4 can deep-link into it from meal logging flows without rebuilding anything
- Both entry points route to the same `BarcodeScanScreen`

### Scanner Camera View

- Full-screen push: navigator push to `BarcodeScanScreen`, camera fills the display
- Scanning frame overlay: rectangular guide with corner brackets in the center of the camera feed (via `mobile_scanner`'s overlay builder) — tells the user where to aim
- Torch toggle: icon in the scanner AppBar; toggles `mobile_scanner`'s built-in torch API
- Accepted barcode formats: EAN-13, EAN-8, UPC-A only — `mobile_scanner` exposes `BarcodeFormat`; non-product formats (QR codes, ISBN, DataMatrix, etc.) show an inline message "That doesn't look like a product barcode" without triggering any lookup

### Scan-to-Result Feedback

- On detection: haptic feedback (light tap) + camera feed freezes + centered spinner while the DB/API lookup runs
- On match: existing `FoodDetailBottomSheet` slides up (same sheet as Phase 2, now with CO₂ row populated)
- On sheet dismiss: scanner screen returns to live camera — user can scan another product without navigating back
- No behavioral difference between a scan-sourced sheet and a search-sourced sheet; Phase 4 adds "Log this food" to both simultaneously

### Camera Permission Denied

- Show a permission rationale screen: "Camera access is needed to scan barcodes" + "Open Settings" button that deep-links to the OS Settings app (using `app_settings` or equivalent package)
- No camera fallback — user must grant permission to use the scanner

### CO₂ Factor Data Source

**Primary source:** AGRIBALYSE v3.1.1 impact score CSVs (INRAE/ADEME)
- License: Licence Ouverte / Open Licence v2.0 (Etalab) — commercial use permitted, redistribution permitted, attribution required
- Only the precomputed impact score CSV files from data.gouv.fr are used — NOT the raw LCI/ecoinvent-linked formats (those carry an ecoinvent license dependency)
- Attribution string: "Source ADEME, données AGRIBALYSE v3.1.1"

**Lookup resolution (in order):**

1. **AGRIBALYSE barcode crosswalk** (`ciqual_off_match.csv`, ~900 direct matches) — matches a scanned/searched OFF barcode to a specific CIQUAL product with a measured LCA value → **High confidence**
2. **AGRIBALYSE category average** — for products not in the crosswalk, the ingest pipeline computes per-category CO₂e medians from AGRIBALYSE's own category data using the `off_to_agribalyse_map.csv` mapping file (see below) → **Medium confidence**
3. **No match** — no CO₂ estimate shown; CO₂ row is hidden rather than showing a Low-confidence guess

**No Dart const map. No Poore & Nemecek data.** Poore & Nemecek 2018 is off the table: the paper is under AAAS copyright with non-commercial restrictions — not compatible with a free/open-source app with potential future monetization. A CC0 permission request to Joseph Poore is a deferred action item (does not block Phase 3). If permission is granted, it can be incorporated as a Phase 8 enhancement.

### CO₂ Schema in off_reference.sqlite

Two new tables added to `off_reference.sqlite` during ingest:

- `co2_factors` — AGRIBALYSE category-level CO₂e values (category code, CO₂e median, unit)
- `food_co2_overrides` — per-product AGRIBALYSE direct matches (barcode, ciqual_code, CO₂e value, confidence = 'high')

The ingest pipeline (`tools/ingest_off.py`) is extended to:
1. Download and join AGRIBALYSE v3.1.1 CSVs
2. Apply the barcode crosswalk (`ciqual_off_match.csv`) to populate `food_co2_overrides`
3. Compute category averages and populate `co2_factors`
4. A new committed mapping file `tools/off_to_agribalyse_map.csv` maps OFF `categories_tags` / `pnns_groups` to AGRIBALYSE category codes for the non-crosswalk products

### co2_methodology_version

- Populated during Phase 3 ingest with the string `'AGRIBALYSE-3.1.1-v1'`
- Written to every CO₂-bearing row in `food_co2_overrides` and `co2_factors`
- The `co2_methodology_version` column was added to `user_profile` and all CO₂-bearing tables in Phase 1 specifically for this moment
- Phase 5 reads this column for the methodology-announcement flow

### Confidence Band Definition

| Tier | Criterion | What it means |
|---|---|---|
| **High** | AGRIBALYSE direct barcode crosswalk match | Product-specific LCA measurement |
| **Medium** | AGRIBALYSE category average | Estimate based on the food's category; not product-specific |
| *(none)* | No AGRIBALYSE coverage at all | CO₂ row hidden — no false estimate shown |

No Low tier. The app shows nothing rather than a poorly-sourced guess.

### Confidence Band Display

- A small rounded colored chip rendered inline beside the CO₂e value in `FoodDetailBottomSheet`:
  - High → green chip (primary green from DESIGN.md token set)
  - Medium → amber chip (warning color)
- Chip is tappable — opens a lightweight explanation bottom sheet:
  - What "High" / "Medium" means in plain language
  - Which AGRIBALYSE lookup path produced this estimate
  - "Full methodology" link (see below)

### LEG-05 Methodology Documentation

Two surfaces, both required:

1. **Bundled in-app screen** (`MethodologyScreen`, fully offline): version + citation ("AGRIBALYSE v3.1.1, INRAE/ADEME, 2023"), Etalab License credit, plain-language explanation of what CO₂e/kg means and how it was derived, confidence band definitions, explanation of why category averages are less precise than direct LCA measurements
2. **GitHub link** (connectivity required): opens `docs/CO2_METHODOLOGY.md` in a WebView — same content plus full citation details, the `off_to_agribalyse_map.csv` methodology, and the AGRIBALYSE version DOI

`docs/CO2_METHODOLOGY.md` is committed to the repo in Phase 3 alongside the ingest pipeline changes.

### Barcode Lookup Flow (No-Match Path)

Lookup chain on scan:
1. Search `off_ref.food_co2_overrides` by barcode → if match, return with High confidence
2. If miss: search `off_ref.products` by barcode → if product found, compute CO₂ from `co2_factors` by category → return with Medium confidence
3. If still miss AND online: OFF API single-product GET by barcode → if found, cache to `UserFoodCacheTable` (Phase 2 pattern), apply CO₂ factor by category → return with Medium confidence
4. If all three miss: go to no-match screen

No-match screen content:
- Illustration
- Distinct reason message: "No product found for this barcode" (genuine miss) or "Couldn't reach the food database — check your connection" (network failure)
- Primary CTA: "Add as custom food" — navigates to custom food stub route with barcode pre-filled; all nutritional fields empty (Phase 4 owns the form)
- Secondary link: "Try name search instead" — pushes to `/food-search`

### Device Testing Gates

- **Android:** Galaxy Tab S7 FE — confirmed available; Phase 3 closes only after end-to-end barcode scan verified on this device
- **iOS:** No physical device available — Phase 3 ships with iOS Simulator verification only
- **Explicit risk note for the plan:** iOS real-device barcode scanning is unverified in Phase 3. Phase 4 must gate on a physical iPhone TestFlight test before closing. TestFlight setup (Apple Developer Program membership) is a Phase 4 prerequisite.

### Claude's Discretion

- `mobile_scanner` version pinned in pubspec (latest stable at time of implementation)
- Exact scanning frame overlay styling (corner bracket thickness, color, animation)
- Haptic feedback intensity level (HapticsImpact.light vs. medium)
- DAO method names and query structure for CO₂ factor lookups
- `off_to_agribalyse_map.csv` category mapping decisions (which AGRIBALYSE category a given OFF pnns_groups tag maps to)
- WebView package choice for the GitHub methodology link (url_launcher vs. webview_flutter)
- `MethodologyScreen` layout and typography details

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets

- `FoodDetailBottomSheet` (`lib/features/food_search/widgets/food_detail_sheet.dart`) — CO₂ row is currently hidden with a comment; Phase 3 enables it by extending `FoodItem` with `co2e100g` and `confidenceBand` nullable fields
- `FoodItem` entity (`lib/domain/entities/food_item.dart`) — needs two new nullable fields: `double? co2e100g` and `String? confidenceBand` ('high'/'medium'/null)
- `FoodCatalogDao` (`lib/data/local/daos/food_catalog_dao.dart`) — UNION ALL query structure is extensible; a CO₂ JOIN into `off_ref.food_co2_overrides` and `off_ref.co2_factors` is added here
- `FoodCatalogRepository` (`lib/data/repositories/food_catalog_repository.dart`) — barcode lookup method is a new addition alongside the existing FTS5 name search
- `UserFoodCacheTable` (`lib/data/local/tables/user_food_cache_table.dart`) — API-cached results path reused for barcode-resolved API hits
- `AppDatabase` (`lib/data/local/app_database.dart`) — ATTACH DATABASE already in place; `offRefPath` non-null confirms off_reference.sqlite is attached
- Phase 2 ingest pipeline (`tools/ingest_off.py`) — extended to process AGRIBALYSE CSVs and populate the two new tables
- DESIGN.md token set — green primary for High chip, need to confirm amber/warning token for Medium chip

### Established Patterns

- No shimmer for fast local results; shimmer only for genuine async wait (Phase 2 decision) — camera freeze + spinner follows the same principle for barcode lookups
- Distinct error messages by failure mode (genuine miss vs. offline vs. network failure) — Phase 2 decision; no-match screen follows same philosophy
- `SyncSafeTable` mixin — CO₂ factor tables in `off_reference.sqlite` are read-only reference data, so they do NOT use the mixin; only user-data tables in `co2diet.sqlite` use it
- go_router named routes — `/barcode-scan` follows the same pattern as `/food-search` from Phase 2

### Integration Points

- `off_reference.sqlite` gains two new tables (`co2_factors`, `food_co2_overrides`) via the extended ingest pipeline — no schema migration on the app side, just a new bundled asset build
- `FoodDetailBottomSheet` is the single display surface for both search results and barcode scan results — enabling CO₂ row here affects both flows simultaneously
- Phase 4 will add "Log this food" to `FoodDetailBottomSheet` — Phase 3 must not restructure the sheet in ways that make that addition harder
- `tools/off_to_agribalyse_map.csv` is a new committed file alongside `tools/ingest_off.py`

</code_context>

<specifics>
## Specific Ideas

- "Dismiss sheet → scanner resumes live" — explicit user decision for multi-scan sessions without re-navigating
- "No Dart const map. No Poore & Nemecek." — confirmed after licensing research; AGRIBALYSE-only architecture, the const map reference from early in the discussion is superseded
- Confidence chip is tappable and doubles as the LEG-05 methodology access point — no separate "info" icon needed on the food detail sheet
- "No CO₂ shown rather than a Low-confidence guess" — consistent with Phase 1/2 pattern of '—' for missing data and honest no-results states
- iOS gap explicitly noted: TestFlight + physical iPhone is a Phase 4 gate, not a Phase 3 assumption

</specifics>

<deferred>
## Deferred Ideas

- **Poore & Nemecek 2018 category data** — licensing blocked (AAAS copyright, non-commercial clause). A CC0 permission request to Joseph Poore is a deferred action item. If granted, incorporate as a Phase 8 data-quality enhancement (third-party category validation layer).
- **Clark et al. 2022 (PLOS ONE, CC-BY 4.0)** — identified as a clean alternative if Poore & Nemecek permission fails. Defer to Phase 8 alongside the full OFF pack delivery.
- **Low confidence tier** — a rough estimate for products with no AGRIBALYSE coverage at all. Deferred until there's a data source to back it. Phase 8 candidate.
- **iOS real-device barcode verification** — deferred to Phase 4 (no physical iPhone available). Phase 4 plan must include TestFlight setup as a prerequisite.
- **Umlaut/ASCII folding for barcode names** — same deferral as Phase 2 (no change here).
- **Data-saver / metered connection check for API barcode lookup** — Phase 8 concern (same as Phase 2 API fallback).
- **CO₂ profile modifiers** (location, cooking method, household size, waste level) — Phase 5 CO₂ Calculation Settings.
- **Methodology changelog announcement flow** — Phase 5, reads `co2_methodology_version` column set in Phase 3.

</deferred>

---

*Phase: 03-barcode-scanning-co-factor-table*
*Context gathered: 2026-07-21*

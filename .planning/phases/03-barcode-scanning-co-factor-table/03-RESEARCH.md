# Phase 3: Barcode Scanning & CO₂ Factor Table — Research

**Researched:** 2026-07-21
**Domain:** Flutter camera/barcode scanning (mobile_scanner), AGRIBALYSE LCA data ingestion, SQLite CO₂ factor schema, confidence-band display
**Confidence:** HIGH (stack, API, data format all verified from authoritative sources)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Scanner Entry Point & Navigation**
- Barcode icon in the search screen AppBar (`FoodSearchScreen`) — triggers the scanner from the existing Phase 2 surface
- Dedicated `/barcode-scan` go_router named route — Phase 4 can deep-link into it from meal logging flows without rebuilding anything
- Both entry points route to the same `BarcodeScanScreen`

**Scanner Camera View**
- Full-screen push: navigator push to `BarcodeScanScreen`, camera fills the display
- Scanning frame overlay: rectangular guide with corner brackets in the center of the camera feed (via `mobile_scanner`'s `overlayBuilder`) — tells the user where to aim
- Torch toggle: icon in the scanner AppBar; toggles `mobile_scanner`'s built-in torch API
- Accepted barcode formats: EAN-13, EAN-8, UPC-A only — non-product formats show an inline message "That doesn't look like a product barcode" without triggering any lookup

**Scan-to-Result Feedback**
- On detection: haptic feedback (light tap) + camera feed freezes + centered spinner while the DB/API lookup runs
- On match: existing `FoodDetailBottomSheet` slides up (same sheet as Phase 2, now with CO₂ row populated)
- On sheet dismiss: scanner screen returns to live camera — user can scan another product without navigating back
- No behavioral difference between a scan-sourced sheet and a search-sourced sheet

**Camera Permission Denied**
- Show a permission rationale screen with "Open Settings" button (using `app_settings` or equivalent)
- No camera fallback — user must grant permission to use the scanner

**CO₂ Factor Data Source**
- Primary: AGRIBALYSE v3.1.1 synthesis CSV (INRAE/ADEME) — Licence Ouverte / Open Licence v2.0 (Etalab), commercial use and redistribution permitted, attribution required
- Only precomputed impact score CSV files — NOT the raw LCI/ecoinvent-linked formats
- Attribution string: "Source ADEME, données AGRIBALYSE v3.1.1"

**Lookup resolution (in order):**
1. AGRIBALYSE barcode crosswalk (`ciqual_off_match.csv`, ~900 direct matches) → High confidence
2. AGRIBALYSE category average (per-category CO₂e medians via `off_to_agribalyse_map.csv`) → Medium confidence
3. No match → CO₂ row hidden, no false estimate shown

**No Dart const map. No Poore & Nemecek data.**

**CO₂ Schema in off_reference.sqlite**
- Two new tables: `co2_factors` and `food_co2_overrides`
- `co2_methodology_version` = `'AGRIBALYSE-3.1.1-v1'` written to every CO₂-bearing row
- Ingest pipeline (`tools/ingest_off.py`) extended to process AGRIBALYSE CSVs

**Confidence Band**
- High → AGRIBALYSE direct barcode crosswalk match (green chip)
- Medium → AGRIBALYSE category average (amber chip)
- None → CO₂ row hidden (no Low tier)

**Barcode Lookup Flow**
1. Search `off_ref.food_co2_overrides` by barcode → High confidence
2. If miss: search `off_ref.products` by barcode → compute from `co2_factors` by category → Medium confidence
3. If still miss AND online: OFF API single-product GET → cache to `UserFoodCacheTable`, apply CO₂ factor by category → Medium confidence
4. If all miss → no-match screen

**LEG-05 Methodology Documentation**
- `MethodologyScreen` (offline, bundled)
- GitHub link in WebView for `docs/CO2_METHODOLOGY.md`
- `docs/CO2_METHODOLOGY.md` committed to repo in Phase 3

**Device Testing Gates**
- Android: Galaxy Tab S7 FE — Phase 3 closes only after end-to-end barcode scan verified here
- iOS: Simulator verification only in Phase 3. Real-device iPhone gate deferred to Phase 4 (TestFlight prerequisite)

### Claude's Discretion
- `mobile_scanner` version pinned in pubspec (latest stable at time of implementation)
- Exact scanning frame overlay styling (corner bracket thickness, color, animation)
- Haptic feedback intensity level (HapticsImpact.light vs. medium)
- DAO method names and query structure for CO₂ factor lookups
- `off_to_agribalyse_map.csv` category mapping decisions
- WebView package choice for the GitHub methodology link (`url_launcher` vs. `webview_flutter`)
- `MethodologyScreen` layout and typography details

### Deferred Ideas (OUT OF SCOPE)
- Poore & Nemecek 2018 — licensing blocked, Phase 8 candidate
- Clark et al. 2022 (PLOS ONE, CC-BY 4.0) — Phase 8
- Low confidence tier — no data source yet, Phase 8 candidate
- iOS real-device barcode verification — Phase 4 gate
- Umlaut/ASCII folding — same deferral as Phase 2
- Data-saver / metered connection check — Phase 8
- CO₂ profile modifiers — Phase 5
- Methodology changelog announcement flow — Phase 5
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| LOG-03 | User can scan a product barcode using the device camera; successful scan autofills food name, nutritional values, and CO₂e estimate; P0 acceptance criterion: verified on real Android device (iOS deferred to Phase 4) | `mobile_scanner` 7.4.0 confirmed for Android (CameraX/MLKit); BarcodeFormat.ean13, ean8, upcA verified; real-device gate documented |
| LOG-04 | When barcode scan finds no match (online or offline), user is offered the "Add as custom food" fallback — no dead-end UX | No-match screen pattern documented; stub route approach identified; distinct messages for genuine miss vs. network failure |
| CO2-01 | Each food item has an associated CO₂e estimate (g CO₂e per kg); displayed with a confidence band (High / Medium / Low), never as a single false-precision number | AGRIBALYSE v3.1.1 CSV structure confirmed; column names verified from raw data; confidence chip pattern documented |
| LEG-05 | CO₂ methodology and data sources are publicly documented; linked from the Estimate Transparency screen and Legal Hub | `MethodologyScreen` + `docs/CO2_METHODOLOGY.md` dual-surface approach; attribution string format confirmed; license verified |
</phase_requirements>

---

## Summary

Phase 3 installs two distinct capabilities: (1) a camera barcode scanner that resolves scanned EAN/UPC codes to food records, and (2) a CO₂ factor table that populates the CO₂e row in `FoodDetailBottomSheet` for every food item — both scanned and searched.

The barcode scanner is built on `mobile_scanner` 7.4.0, which uses CameraX/ML Kit on Android and AVFoundation/Apple Vision on iOS — no third-party SDKs beyond what the package ships. It provides `MobileScannerController.formats` for restricting to EAN-13, EAN-8, and UPC-A, `overlayBuilder` for drawing the scanning frame, and `toggleTorch()` for the flashlight icon. The package requires Flutter >= 3.29.0 and Dart >= 3.7.0, both of which are satisfied by this project's Flutter 3.44.6 / Dart 3.12.2.

The CO₂ factor data comes from AGRIBALYSE v3.1.1, an open-licence French LCA database covering ~2,500 food product categories. The synthesis CSV (`Changement climatique` column, unit: kg CO₂e per kg product) is downloaded from the ADEME API (`data.ademe.fr`) and two new tables (`co2_factors`, `food_co2_overrides`) are added to `off_reference.sqlite` by extending the existing Python ingest pipeline. No app-side schema migration is required — `off_reference.sqlite` is replaced as a bundled asset.

The highest-risk element is the AGRIBALYSE-to-OFF category mapping (`off_to_agribalyse_map.csv`): there is no authoritative pre-built crosswalk file. OFF's categories taxonomy contains `agribalyse_food_code` and `agribalyse_proxy_food_code` properties per category, but deriving the reverse mapping from `categories_tags` strings stored in `off_reference.sqlite` requires a hand-curated CSV. This mapping file is itself a Phase 3 deliverable and requires human review of OFF category tags vs. AGRIBALYSE food group names.

**Primary recommendation:** Use `mobile_scanner` 7.4.0, extend `tools/ingest_off.py` with AGRIBALYSE v3.1.1 CSV processing, create two new read-only tables in `off_reference.sqlite`, and add CO₂ fields to `FoodItem`. The `off_to_agribalyse_map.csv` is the primary research artifact that requires human authorship (not generated by the ingest pipeline alone).

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Camera permission request | Device OS / Platform | Flutter plugin (mobile_scanner) | Permission is OS-managed; the plugin calls the native API |
| Barcode format filtering | Flutter plugin (mobile_scanner) | — | `BarcodeFormat` enum controls ML Kit / AVFoundation scan targets |
| Scan overlay UI | Frontend (Flutter widget) | — | `overlayBuilder` callback renders Dart widgets over the camera preview |
| Barcode → food lookup (local) | Database / Storage (SQLite) | Data layer (Dart DAO) | `off_ref.food_co2_overrides` and `off_ref.products` queries; same ATTACH pattern as Phase 2 |
| Barcode → food lookup (API) | API / Remote | Data layer (Dart repository) | OFF API single-product GET; result cached to `UserFoodCacheTable` — mirrors Phase 2 fallback |
| CO₂ factor join | Database / Storage (SQLite) | — | JOIN in `FoodCatalogDao` against `off_ref.co2_factors` by `categories_tags` |
| CO₂ confidence band display | Frontend (Flutter widget) | — | Chip rendered in `FoodDetailBottomSheet`; tappable explanation sheet |
| AGRIBALYSE ingest | Tooling (Python script) | — | Extends `tools/ingest_off.py`; produces new asset — no runtime dependency |
| Methodology documentation | Frontend (Dart screen) | CDN / GitHub (WebView) | Offline screen always available; GitHub link requires connectivity |

---

## Standard Stack

### Core (Phase 3 additions)

| Library | Version | Purpose | Why Standard | Source |
|---------|---------|---------|--------------|--------|
| `mobile_scanner` | 7.4.0 | Barcode scanning via CameraX / MLKit (Android) and AVFoundation (iOS) | Dominant Flutter barcode package (1.06M downloads/month, 160/160 pub.dev score, 2283 likes); uses platform-native ML backends; no proprietary SDKs | [VERIFIED: pub.dev — 2026-07-20] |
| `permission_handler` | 12.0.3 | Camera permission request and status check | 2.84M downloads/month, 160/160 score, publisher `baseflow.com`; standard permission pattern in Flutter | [VERIFIED: pub.dev — 2026-06-01] |
| `app_settings` | 8.0.3 | Deep-link to OS Settings app for permission-denied recovery | 672K downloads/month, 160/160 score; used in the CONTEXT.md decision | [VERIFIED: pub.dev — 2026-07-20] |

### Supporting (in scope)

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `HapticFeedback.lightImpact()` | Flutter stdlib | Scan detection haptic | Built-in; no package needed — uses `UIImpactFeedbackGenerator` on iOS, `VIRTUAL_KEY` on Android |
| `url_launcher` or `webview_flutter` | TBD (Claude's discretion) | Open `docs/CO2_METHODOLOGY.md` via GitHub link | Choose at implementation time based on UX preference |

### Packages Already Present (no new installation)

| Package | Role in Phase 3 |
|---------|-----------------|
| `openfoodfacts` 3.30.2 | OFF API single-product GET by barcode (step 3 in lookup chain) |
| `connectivity_plus` 7.3.0 | Online/offline check before API barcode fallback |
| `drift` 2.34.2 + `drift_flutter` 0.3.1 | CO₂ DAO queries, existing ATTACH mechanism |
| `riverpod_annotation` 4.0.3 + `flutter_riverpod` 3.3.2 | BarcodeScanNotifier provider |
| `go_router` 17.3.0 | `/barcode-scan` named route |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `mobile_scanner` | `flutter_barcode_scanner`, `qr_code_scanner` | Both unmaintained or low score; mobile_scanner is the clear ecosystem standard |
| `permission_handler` | Direct `mobile_scanner` permission (`MobileScannerController.start()` auto-requests) | mobile_scanner does auto-request on `start()`, but `permission_handler` gives pre-check state for showing rationale UI before the native dialog fires |
| `app_settings` | `url_launcher` to open `app-settings:` URL scheme | `app_settings` abstracts the platform difference; `url_launcher` requires knowing the right URI per platform |

**Installation:**

```bash
flutter pub add mobile_scanner:7.4.0 permission_handler:12.0.3 app_settings:8.0.3
```

**Version verification (confirmed):**

```
mobile_scanner   7.4.0  — pub.dev 2026-07-20
permission_handler 12.0.3 — pub.dev 2026-06-01
app_settings     8.0.3  — pub.dev 2026-07-20
```

---

## Package Legitimacy Audit

> slopcheck was run but defaults to PyPI — these are pub.dev (Dart) packages. Manual pub.dev registry verification was performed instead via the pub.dev API.

| Package | Registry | Age | Downloads/30d | Source Repo | slopcheck | Disposition |
|---------|----------|-----|---------------|-------------|-----------|-------------|
| `mobile_scanner` | pub.dev | ~4 yrs (active) | 1,066,793 | github.com/juliansteenbakker/mobile_scanner | N/A (Dart) — pub.dev 160/160 | Approved |
| `permission_handler` | pub.dev | ~5 yrs (active) | 2,840,429 | github.com/Baseflow/flutter-permission-handler | N/A (Dart) — pub.dev 160/160, publisher:baseflow.com | Approved |
| `app_settings` | pub.dev | ~4 yrs (active) | 672,212 | github.com/spencerccf/app_settings | N/A (Dart) — pub.dev 160/160 | Approved |

**Packages removed due to slopcheck [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

*Note: slopcheck operates on PyPI only and incorrectly reported mobile_scanner and permission_handler as SLOP (they don't exist on PyPI). All three packages were manually verified on pub.dev with high download counts, perfect scores, and established source repositories. They are well-known packages in the Flutter ecosystem.*

---

## Architecture Patterns

### System Architecture Diagram

```
User taps barcode icon (FoodSearchScreen AppBar)
    │
    ▼
go_router.push('/barcode-scan')
    │
    ▼
BarcodeScanScreen (full-screen, ConsumerStatefulWidget)
    │
    ├── MobileScannerController (formats: [ean13, ean8, upcA])
    │       │
    │       ▼
    │   MobileScanner widget
    │       ├── overlayBuilder → ScanFrameOverlay (corner brackets)
    │       ├── errorBuilder  → CameraPermissionDeniedWidget
    │       └── onDetect callback
    │           │
    │           ▼ (barcode value + format)
    │       BarcodeScanNotifier.onBarcodeScan(barcode)
    │           │
    │           ├─ [non-EAN/UPC format] → inline "not a product barcode" banner
    │           │
    │           └─ [EAN-13 / EAN-8 / UPC-A]
    │               │
    │               ▼ camera freezes + spinner shown
    │           IFoodCatalogRepository.lookupByBarcode(barcode)
    │               │
    │               ├─ Step 1: FoodCatalogDao.findByBarcodeWithCo2(barcode)
    │               │       SQLite: off_ref.food_co2_overrides JOIN off_ref.products
    │               │       → FoodItem(co2e100g, confidenceBand='high') ✓ DONE
    │               │
    │               ├─ Step 2: FoodCatalogDao.findByBarcode(barcode)
    │               │       SQLite: off_ref.products + off_ref.co2_factors JOIN
    │               │       → FoodItem(co2e100g, confidenceBand='medium') ✓ DONE
    │               │
    │               ├─ Step 3: OffApiClient.fetchByBarcode(barcode) [online only]
    │               │       Cache → UserFoodCacheTable + co2_factors JOIN
    │               │       → FoodItem(co2e100g, confidenceBand='medium') ✓ DONE
    │               │
    │               └─ Step 4: no match
    │                       → BarcodeScanNoMatchScreen (stub route + search link)
    │
    ├─ [match found]
    │   HapticFeedback.lightImpact()
    │   showFoodDetailSheet(context, item)  ← SAME sheet as Phase 2
    │       │
    │       └── FoodDetailBottomSheet (Phase 2 widget, extended)
    │               ├── product name, brand, macros (Phase 2)
    │               └── CO₂ row: "~X.X kg CO₂e/kg" + ConfidenceChip
    │                                                       │
    │                                                       ▼ (tapped)
    │                                               ConfidenceExplanationSheet
    │                                               (+ "Full methodology" link)
    │                                                       │
    │                                                       ▼
    │                                               MethodologyScreen (offline)
    │                                               or GitHub WebView (online)
    │
    └── [sheet dismissed] → scanner resumes live camera
```

### Recommended Project Structure (Phase 3 additions)

```
lib/
├── features/
│   └── barcode_scan/
│       ├── providers/
│       │   ├── barcode_scan_notifier.dart    # @riverpod BarcodeScanNotifier
│       │   └── barcode_scan_notifier.g.dart  # generated
│       ├── screens/
│       │   ├── barcode_scan_screen.dart      # MobileScanner widget, controller lifecycle
│       │   ├── barcode_no_match_screen.dart  # no-match UX (genuine / offline / network)
│       │   └── methodology_screen.dart       # LEG-05 offline methodology doc
│       └── widgets/
│           ├── scan_frame_overlay.dart       # overlayBuilder corner-bracket widget
│           ├── camera_permission_denied_widget.dart
│           └── confidence_chip.dart          # High/Medium chip + tappable explanation
├── domain/
│   └── entities/
│       └── food_item.dart                   # MODIFIED: + co2e100g, confidenceBand fields
├── data/
│   └── local/
│       └── daos/
│           └── food_catalog_dao.dart        # MODIFIED: + lookupByBarcode, CO₂ JOIN queries
└── core/
    └── router/
        └── app_router.dart                  # MODIFIED: + /barcode-scan route + stub /custom-food-stub

tools/
├── ingest_off.py                            # MODIFIED: + AGRIBALYSE ingestion
└── off_to_agribalyse_map.csv               # NEW: categories_tags → agribalyse category code

docs/
└── CO2_METHODOLOGY.md                       # NEW: public methodology doc (LEG-05)
```

### Pattern 1: MobileScannerController Lifecycle

**What:** The scanner controller must be created, started, stopped, and disposed correctly in a `ConsumerStatefulWidget` to avoid camera resource leaks and permission race conditions.

**When to use:** Every time `BarcodeScanScreen` is in the widget tree.

```dart
// Source: github.com/juliansteenbakker/mobile_scanner (README + API docs)
// [VERIFIED: pub.dev mobile_scanner 7.4.0]

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
      ],
      torchEnabled: false,
      autoStart: true,   // starts camera on widget mount
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**Key constraint:** `MobileScannerController` requires `controller.dispose()` in `State.dispose()`. Forgetting this causes camera to stay locked after navigation.

### Pattern 2: overlayBuilder Scanning Frame

**What:** Renders a corner-bracket scanning guide centered in the camera preview using the `BoxConstraints` provided by `overlayBuilder`.

```dart
// Source: mobile_scanner README + API reference
// [VERIFIED: pub.dev mobile_scanner 7.4.0]

MobileScanner(
  controller: _controller,
  onDetect: _handleBarcode,
  overlayBuilder: (context, constraints) {
    // constraints.maxWidth / maxHeight = preview dimensions
    const frameSize = 240.0;
    return Center(
      child: ScanFrameOverlay(size: frameSize),
    );
  },
  errorBuilder: (context, exception, child) {
    if (exception.errorCode == MobileScannerErrorCode.permissionDenied) {
      return const CameraPermissionDeniedWidget();
    }
    return child ?? const SizedBox.shrink();
  },
);
```

### Pattern 3: Barcode Detection Handler

**What:** The `onDetect` callback fires on each frame where a barcode is detected. Guard against duplicate fires with a flag.

```dart
// Source: mobile_scanner onDetect API
// [VERIFIED: pub.dev mobile_scanner 7.4.0]

bool _processing = false;

void _handleBarcode(BarcodeCapture capture) {
  if (_processing) return;   // <-- critical: debounce duplicate detections
  final barcode = capture.barcodes.firstOrNull;
  if (barcode == null || barcode.rawValue == null) return;

  // Phase 3 format gate: only act on product formats
  // (controller.formats already filters at ML Kit level, but belt-and-suspenders)
  final productFormats = {
    BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA,
  };
  if (!productFormats.contains(barcode.format)) {
    // Show inline message; do NOT trigger lookup
    return;
  }

  _processing = true;
  // Freeze camera (stop auto-detect) + trigger lookup
  unawaited(_controller.stop());
  HapticFeedback.lightImpact();
  ref.read(barcodeScanProvider.notifier).lookupBarcode(barcode.rawValue!);
}
```

### Pattern 4: CO₂ JOIN Query in FoodCatalogDao

**What:** Extend `searchLocalFoods` to also support barcode lookup with CO₂ join, reusing the existing ATTACH DATABASE mechanism.

```dart
// [ASSUMED] — pattern derived from existing FoodCatalogDao structure;
// exact SQL not verified against Drift 2.34.2 customSelect API

Future<FoodItem?> lookupByBarcodeWithCo2(String barcode) async {
  if (attachedDatabase.offRefPath == null) return null;
  try {
    // Step 1: direct match in food_co2_overrides (High confidence)
    final overrideRows = await attachedDatabase.customSelect(
      '''
      SELECT
        p.barcode, p.product_name, p.product_name_en, p.brand,
        p.calories_100g, p.protein_100g, p.carbs_100g, p.fat_100g,
        ov.co2e_100g, 'high' AS confidence_band
      FROM off_ref.food_co2_overrides ov
      JOIN off_ref.products p ON p.barcode = ov.barcode
      WHERE ov.barcode = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(barcode)],
      readsFrom: {},
    ).get();
    if (overrideRows.isNotEmpty) return FoodItem.fromQueryRow(overrideRows.first);

    // Step 2: category average (Medium confidence)
    final catRows = await attachedDatabase.customSelect(
      '''
      SELECT
        p.barcode, p.product_name, p.product_name_en, p.brand,
        p.calories_100g, p.protein_100g, p.carbs_100g, p.fat_100g,
        cf.co2e_median AS co2e_100g, 'medium' AS confidence_band
      FROM off_ref.products p
      JOIN off_ref.co2_factors cf
        ON cf.categories_tag = (
          -- pick the first matching category tag
          SELECT value FROM json_each('["' || replace(p.categories_tags, ',', '","') || '"]')
          WHERE value IN (SELECT categories_tag FROM off_ref.co2_factors)
          LIMIT 1
        )
      WHERE p.barcode = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(barcode)],
      readsFrom: {},
    ).get();
    if (catRows.isNotEmpty) return FoodItem.fromQueryRow(catRows.first);
  } on Exception catch (e) {
    debugPrint('[FoodCatalogDao] barcode lookup error: $e');
  }
  return null;
}
```

> **Note:** The `json_each` approach for parsing `categories_tags` is SQLite-built-in (no extension needed). Alternatively the ingest pipeline can store a `primary_category_tag TEXT` column to avoid runtime parsing.

### Pattern 5: AGRIBALYSE Ingest Extension

**What:** The Python ingest pipeline downloads the AGRIBALYSE synthesis CSV and populates `co2_factors` and `food_co2_overrides`.

```python
# Source: raw CSV confirmed at data.ademe.fr/data-fair/api/v1/datasets/agribalyse-31-synthese/raw
# [VERIFIED: fetched live 2026-07-21 — 2519 rows, 34 columns]

AGRIBALYSE_URL = (
    "https://data.ademe.fr/data-fair/api/v1/datasets/agribalyse-31-synthese/raw"
)

# Confirmed column names from the live CSV:
#   "Code CIQUAL"         — CIQUAL code (= AGRIBALYSE code for finished products)
#   "Groupe d'aliment"    — Food group (maps to OFF categories_tags bucket)
#   "Sous-groupe d'aliment" — Sub-group
#   "Nom du Produit en Français" — French product name
#   "Changement climatique" — kg CO₂e per kg product (GWP)

CO2_FACTORS_DDL = """
CREATE TABLE IF NOT EXISTS co2_factors (
    categories_tag       TEXT PRIMARY KEY,  -- OFF categories_tags value (e.g. 'en:beverages')
    agribalyse_group     TEXT NOT NULL,     -- AGRIBALYSE "Groupe d'aliment"
    co2e_median          REAL NOT NULL,     -- median kg CO₂e per kg (from category average)
    co2_methodology_version TEXT NOT NULL DEFAULT 'AGRIBALYSE-3.1.1-v1',
    unit                 TEXT NOT NULL DEFAULT 'kg_co2e_per_kg'
);
"""

FOOD_CO2_OVERRIDES_DDL = """
CREATE TABLE IF NOT EXISTS food_co2_overrides (
    barcode              TEXT PRIMARY KEY,
    ciqual_code          TEXT NOT NULL,
    co2e_100g            REAL NOT NULL,     -- kg CO₂e per kg (direct LCA value)
    confidence           TEXT NOT NULL DEFAULT 'high',
    co2_methodology_version TEXT NOT NULL DEFAULT 'AGRIBALYSE-3.1.1-v1',
    unit                 TEXT NOT NULL DEFAULT 'kg_co2e_per_kg'
);
"""
```

### Anti-Patterns to Avoid

- **Starting scanner without stopping on result:** `onDetect` fires repeatedly; failing to call `_controller.stop()` on first hit causes multiple concurrent lookups.
- **Calling `controller.dispose()` before `controller.stop()`:** Stop first, then dispose — especially important in `initState`/`dispose` lifecycle.
- **Using `json_each` on comma-separated categories_tags with spaces after commas:** The `categories_tags` field uses comma-separated values without spaces — verify sample data before relying on `replace()` pattern.
- **Hardcoding the AGRIBALYSE CSV column names in German or other locale:** The CSV uses French column headers (`Changement climatique`, `Groupe d'aliment`) — do not confuse with English translations used in documentation.
- **Displaying CO₂ values with > 2 significant figures:** NFR-05 requires honest uncertainty display. Format `co2e_100g` as `~X.X kg CO₂e/kg` (1-2 significant figures), not `4.732 kg CO₂e/kg`.
- **Setting `permissionDenied` as an unrecoverable error:** The `errorBuilder` receives `MobileScannerException.errorCode == MobileScannerErrorCode.permissionDenied` — show the rationale screen with "Open Settings" button, not a crash or silent failure.
- **Adding `co2_factors` and `food_co2_overrides` to `co2diet.sqlite`:** These are read-only reference data in `off_reference.sqlite` (the ATTACHed DB). They must NOT use `SyncSafeTable` mixin and must NOT appear in `AppDatabase`'s `@DriftDatabase` table list.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Camera barcode detection | Custom camera frame analysis | `mobile_scanner` 7.4.0 | Platform ML backends (CameraX/MLKit + AVFoundation/Apple Vision) handle multi-format detection, camera lifecycle, preview rendering, and torch control — hundreds of edge cases |
| Permission request dialog | Custom AlertDialog before native dialog | `permission_handler` 12.0.3 | iOS and Android have diverging permission states (granted/denied/permanentlyDenied/restricted); `permission_handler` handles all states uniformly |
| "Open Settings" deep link | Manual URI construction | `app_settings` 8.0.3 | iOS settings URL scheme differs from Android's — `AppSettings.openAppSettings()` handles both |
| Haptic on scan | Third-party vibration package | `HapticFeedback.lightImpact()` from Flutter services | Flutter stdlib covers all needed levels (light/medium/heavy); no package needed |
| CO₂ number formatting | Custom precision logic | Dart's `toStringAsPrecision(2)` or `~${(val * 10).round() / 10} kg CO₂e/kg` | Built-in; rounding to 1-2 significant figures is straightforward with stdlib |

**Key insight:** The camera/barcode domain has profound device-specific edge cases (MLKit model download timing, camera orientation changes, torch hardware variation, permission state machine). `mobile_scanner` encapsulates 4+ years of community fixes for these. The CO₂ factor domain requires correct data sourcing — the complexity is in the ingest pipeline and mapping, not in Dart code that could be hand-rolled.

---

## Common Pitfalls

### Pitfall 1: mobile_scanner 7.x requires Flutter >= 3.29.0 (Dart ^3.7.0)

**What goes wrong:** Adding `mobile_scanner: ^7.x` to a project with an older Flutter/Dart SDK fails with a pub solve conflict.
**Why it happens:** mobile_scanner 7.0.0 introduced this constraint in its changelog.
**How to avoid:** This project uses Flutter 3.44.6 / Dart 3.12.2 — both satisfy the constraint. Pin `mobile_scanner: 7.4.0` (not `^7.0.0`) to avoid silent upgrades. No conflict exists here.
**Warning signs:** `pub get` output showing version solve failure mentioning `mobile_scanner` and SDK constraint.

### Pitfall 2: Double-fire of onDetect without debounce guard

**What goes wrong:** `onDetect` fires on every video frame where a barcode is detected (~30x/second). Without a `_processing` guard, the lookup fires 30 times, each spawning a DB query and potentially showing 30 bottom sheets.
**Why it happens:** ML Kit's frame-by-frame scanning has no built-in single-fire mode.
**How to avoid:** Set `_processing = true` before any async work; reset to `false` when the sheet is dismissed and `_controller.start()` is called again (the "dismiss → resume" flow).
**Warning signs:** Multiple identical bottom sheets appearing in quick succession; database query logs showing the same barcode queried many times within 100ms.

### Pitfall 3: Camera resource not released on navigation

**What goes wrong:** Navigating away from `BarcodeScanScreen` without calling `_controller.dispose()` leaves the camera active — the camera LED stays on, other apps cannot use the camera, and battery drains.
**Why it happens:** `MobileScannerController` holds a native camera session handle that is not automatically released when the widget is unmounted.
**How to avoid:** Always `dispose()` the controller in `State.dispose()` (see Pattern 1). The go_router `pop()` callback triggers Flutter's dispose lifecycle correctly.
**Warning signs:** Camera LED remains on after leaving the scanner screen; "Camera already in use" errors when trying to reopen the scanner.

### Pitfall 4: AGRIBALYSE CSV is now v3.2 on data.gouv.fr — the "agribalyse-synthese" dataset has been updated

**What goes wrong:** The generic `data.gouv.fr/datasets/agribalyse-synthese` URL now returns v3.2 data (as of January 2026). Using this URL in the ingest pipeline would populate the DB with v3.2 data while `co2_methodology_version` is set to `'AGRIBALYSE-3.1.1-v1'`.
**Why it happens:** ADEME updated the rolling dataset to v3.2.
**How to avoid:** Use the ADEME data-fair API endpoint that still serves the v3.1.1 CSV: `https://data.ademe.fr/data-fair/api/v1/datasets/agribalyse-31-synthese/raw` — confirmed live and returning v3.1.1 rows as of 2026-07-21. Alternatively: pin the exact dataset resource UUID `41397293-3e85-4959-8936-940bb79d91fc`. Document the URL in `tools/ingest_off.py` with a comment stating the version.
**Warning signs:** `co2_methodology_version` mismatch; or more than 2,519 rows in the synthesis CSV (v3.1.1 has 2,519 products; v3.2 likely has more).

### Pitfall 5: categories_tags is comma-separated text, not JSON

**What goes wrong:** Attempting to use SQLite `json_each` directly on `categories_tags` values like `en:beverages,en:sodas` without wrapping them in JSON array syntax will return a SQL error.
**Why it happens:** The `categories_tags` column stores raw comma-separated OFF taxonomy tags, not JSON.
**How to avoid:** Either (a) use `replace(categories_tags, ',', '","')` wrapped in `'["..."']` in the SQL query, or (b) have the ingest pipeline store the first/primary OFF category tag in a dedicated `primary_category_tag TEXT` column — cleaner and more performant.
**Warning signs:** SQLite `json_each` error: "malformed JSON"; zero rows returned from CO₂ join.

### Pitfall 6: off_to_agribalyse_map.csv is a human-authored artifact

**What goes wrong:** Assuming the AGRIBALYSE synthesis CSV has a column that directly maps to OFF `categories_tags` values. It does not. AGRIBALYSE uses its own French food group taxonomy (`Groupe d'aliment`); OFF uses English taxonomy tags (`en:beverages`, `en:dairy`, etc.).
**Why it happens:** The two databases evolved independently. OFF's server-side taxonomy file (`categories.result.txt`) does contain `agribalyse_food_code` properties per category, but parsing that 7MB+ file and computing a coverage-maximizing mapping is non-trivial.
**How to avoid:** Treat `tools/off_to_agribalyse_map.csv` as a committed, hand-curated mapping file. Use the OFF categories taxonomy reference at `raw.githubusercontent.com/openfoodfacts/openfoodfacts-server/main/taxonomies/categories.result.txt` for guidance on what AGRIBALYSE codes exist per category.
**Warning signs:** NFR-06(b) (>90% CO₂ coverage) failing benchmark after ingest — indicates category mapping gaps.

### Pitfall 7: permission_handler and mobile_scanner both request camera permission

**What goes wrong:** `mobile_scanner`'s `MobileScannerController.start()` auto-requests camera permission natively. If `permission_handler` also requests it (for the rationale screen), the native dialog may fire twice, or the second request may return `denied` even if the user just granted it.
**Why it happens:** Both packages interact with the same OS-level permission API.
**How to avoid:** Use `permission_handler` for the *pre-check only* (read current status before showing rationale UI). Let `mobile_scanner` own the actual permission request (via `start()`). The pattern: check status → if denied/undetermined, show rationale → start scanner (which triggers native dialog) → handle `permissionDenied` in `errorBuilder`.
**Warning signs:** User sees two back-to-back native camera permission dialogs.

### Pitfall 8: No amber/warning token in DESIGN.md

**What goes wrong:** The confidence chip for "Medium" confidence uses an amber/warning color, but DESIGN.md has no amber token — only the green primary palette, blue secondary, error red.
**Why it happens:** DESIGN.md was written before CO₂ confidence bands were designed.
**How to avoid:** Define a Material amber color constant in `color_tokens.dart` for the Medium chip: suggest `const Color warningAmber = Color(0xFFF59E0B)` (Tailwind amber-500, accessible, not in the existing palette). The Phase 6 accessibility audit will validate color-blind friendliness (not relying on red/green alone — this amber satisfies ACC-04 since it is distinct from both the green High chip and the error red).
**Warning signs:** Hard-coded color hex values in `confidence_chip.dart` without a token reference.

---

## Code Examples

### Verified: AGRIBALYSE CSV structure

```
# Source: data.ademe.fr/data-fair/api/v1/datasets/agribalyse-31-synthese/raw
# [VERIFIED: live fetch 2026-07-21]
# 2,519 rows, 34 columns. Key columns:

Code AGB        — integer: AGRIBALYSE internal code (= Code CIQUAL for finished products)
Code CIQUAL     — integer: CIQUAL product code
Groupe d'aliment — text: food group (e.g., "aides culinaires et ingrédients divers")
Sous-groupe d'aliment — text: sub-group
Nom du Produit en Français — text: French product name
LCI Name        — text: English product name (life cycle inventory name)
Changement climatique — real: kg CO₂e per kg product (Global Warming Potential)

# Example row:
# 11172,11172,aides culinaires et ingrédients divers,aides culinaires,
# "Court-bouillon pour poissons, déshydraté","Aromatic stock cube, for fish, dehydrated",
# 2,0,Ambiant (long),PACK PROXY,Pas de préparation,2.24,1.87,7.58,...
```

### Verified: BarcodeFormat enum values for target formats

```dart
// Source: pub.dev/documentation/mobile_scanner/latest/mobile_scanner/BarcodeFormat.html
// [VERIFIED: pub.dev 2026-07-21]

BarcodeFormat.ean13  // const BarcodeFormat(32)
BarcodeFormat.ean8   // const BarcodeFormat(64)
BarcodeFormat.upcA   // const BarcodeFormat(512)
```

### Verified: MobileScannerController constructor (key parameters)

```dart
// Source: github.com/juliansteenbakker/mobile_scanner/blob/master/lib/src/mobile_scanner_controller.dart
// [VERIFIED: pub.dev mobile_scanner 7.4.0]

MobileScannerController({
  this.formats = const <BarcodeFormat>[],  // empty = all formats
  this.torchEnabled = false,
  this.autoStart = true,
  this.facing = CameraFacing.back,
  this.detectionSpeed = DetectionSpeed.normal,
  // ... other params
})

// Torch toggle (call from AppBar icon):
await _controller.toggleTorch();

// Stop scanner (call before showing result):
await _controller.stop();

// Resume scanner (call when bottom sheet dismissed):
await _controller.start();
```

### Verified: MobileScannerErrorCode.permissionDenied

```dart
// Source: pub.dev/documentation/mobile_scanner/latest/mobile_scanner/MobileScannerErrorCode.html
// [VERIFIED: pub.dev 2026-07-21]

MobileScannerErrorCode.permissionDenied  // "The permission to use the camera was denied."
MobileScannerErrorCode.unsupported       // e.g., older Android without CameraX
MobileScannerErrorCode.genericError      // catch-all
```

### Verified: Haptic feedback (Flutter stdlib)

```dart
// Source: api.flutter.dev/flutter/services/HapticFeedback/lightImpact.html
// [VERIFIED: Flutter SDK 3.44.6]

import 'package:flutter/services.dart';

// iOS: UIImpactFeedbackGenerator with UIImpactFeedbackStyleLight
// Android: HapticFeedbackConstants.VIRTUAL_KEY
await HapticFeedback.lightImpact();
```

### Verified: app_settings open app settings

```dart
// Source: pub.dev/packages/app_settings
// [VERIFIED: pub.dev 8.0.3, 2026-07-20]

import 'package:app_settings/app_settings.dart';

await AppSettings.openAppSettings(); // opens general app settings (shows camera toggle on both iOS/Android)
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `qr_code_scanner` / `flutter_barcode_scanner` | `mobile_scanner` (CameraX/MLKit + AVFoundation) | 2022-2023 | Previous packages are unmaintained; mobile_scanner is now the ecosystem standard |
| `overlay` parameter on MobileScanner | `overlayBuilder` (v5.0.0+) | mobile_scanner 5.0.0 | `overlay` was removed; `overlayBuilder` receives `BoxConstraints` for responsive overlay sizing |
| `onPermissionSet` callback | `errorBuilder` with `MobileScannerErrorCode.permissionDenied` | mobile_scanner 5.0.0 | Unified error handling path instead of a separate permission callback |
| `autoStart` on controller | `autoStart: true` (default) in controller constructor | mobile_scanner 5.0.0 | `autoStart` moved to controller; widget no longer has it |
| AGRIBALYSE v3.0 / v3.1 on data.ademe.fr | v3.1.1 (v3.2 now on rolling dataset) | January 2026 | Use pinned v3.1.1 URL; the rolling `agribalyse-synthese` dataset now returns v3.2 |

**Deprecated/outdated:**
- `qr_code_scanner`: abandoned, known camera lifecycle crashes — do not use
- `MobileScannerErrorBuilder typedef`: removed in mobile_scanner 7.0.0 — use inline function directly
- `CameraFacing.unknown` initial state: now the default in mobile_scanner 7.0.0 (not `CameraFacing.back`)

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `off_to_agribalyse_map.csv` can be authored from OFF's `categories.result.txt` taxonomy to achieve >90% CO₂ coverage (NFR-06b) | Architecture Patterns / Pitfall 6 | If coverage is insufficient, the 90% threshold fails; plan must include benchmark verification step |
| A2 | The ADEME data-fair v3.1.1 URL (`agribalyse-31-synthese/raw`) will remain accessible for the duration of Phase 3 execution | Pitfall 4 | If URL goes offline, use the DATAVERSE DOI download as fallback |
| A3 | `ciqual_off_match.csv` (~900 direct barcode matches) is a file the planner assumes exists; this file is named in CONTEXT.md but was not found in any verified public repository during research | Standard Stack / Ingest section | If this file does not exist as a standalone download, the High-confidence path must be derived differently (e.g., from OFF's own EcoScore data or by querying the OFF API for `agribalyse_food_code` per barcode) |
| A4 | The `categories_tags` comma-separated format in `off_reference.sqlite` contains no embedded commas within individual tag values | Pitfall 5 | If a tag contains a comma, the `replace()` JSON wrapping approach breaks; use the `primary_category_tag` column approach instead |
| A5 | `warningAmber = Color(0xFFF59E0B)` is accessible for color-blind users when used as a chip background alongside the green High chip | Pitfall 8 | Phase 6 accessibility audit may require adjustment; color choice is Claude's discretion |

---

## Open Questions

1. **Does `ciqual_off_match.csv` exist as a public downloadable file?**
   - What we know: CONTEXT.md references it (~900 direct matches) and it is the basis for the High confidence path
   - What's unclear: No verified public URL or repository was found during research. OFF's EcoScore implementation contains per-product AGRIBALYSE matching, but the exact file format and source is unclear
   - Recommendation: Planner should include a Wave 0 research task to locate or reconstruct this file before the ingest pipeline plan begins. Options: (a) query OFF API for products with `ecoscore_data.agribalyse.agribalyse_food_code` field populated; (b) check `openfoodfacts/openfoodfacts-server` GitHub for a committed CSV; (c) generate from the existing JSONL dump by extracting `code` + `ecoscore_data.agribalyse.ciqual_food_code` pairs.

2. **Which URL launcher approach for MethodologyScreen GitHub link?**
   - What we know: CONTEXT.md defers to Claude's discretion (`url_launcher` vs `webview_flutter`)
   - What's unclear: `url_launcher` opens GitHub in the system browser (simpler, privacy-consistent); `webview_flutter` keeps the user in-app but adds 3–5MB and a WebView dependency
   - Recommendation: Use `url_launcher` — privacy-first design principle prefers using the system browser over embedded WebViews, and `url_launcher` is likely already a transitive dependency. Verify with `flutter pub deps` before adding explicitly.

3. **Android minSdkVersion compatibility with mobile_scanner 7.x**
   - What we know: mobile_scanner requires minSdkVersion >= 21; current `build.gradle.kts` uses `minSdk = flutter.minSdkVersion` (Flutter default is 21)
   - What's unclear: Whether Flutter 3.44.6's default `flutter.minSdkVersion` is exactly 21 or has been bumped
   - Recommendation: Planner should include a task to verify `flutter.minSdkVersion` value before running on Android; if below 21, set `minSdk = 21` explicitly.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All Flutter compilation | ✓ | 3.44.6 | — |
| Dart SDK | All Dart compilation | ✓ | 3.12.2 | — |
| Python 3.8+ | AGRIBALYSE ingest pipeline extension | ✓ | Python 3.13 (Anaconda) | — |
| SQLite3 CLI | Verifying off_reference.sqlite schema | ✓ | Confirmed via successful DB queries | — |
| Galaxy Tab S7 FE (Android) | LOG-03 real-device barcode verification | ✓ (stated in CONTEXT.md) | Android — model confirmed available | — |
| Physical iPhone | LOG-03 iOS real-device gate | ✗ | Not available | iOS Simulator (Phase 3); real device deferred to Phase 4 TestFlight |
| Internet access | AGRIBALYSE CSV download (ingest time) | ✓ | — | Use previously downloaded CSV from `tools/data/` if offline |

**Missing dependencies with no fallback:** None that block execution.

**Missing dependencies with fallback:**
- Physical iPhone: iOS Simulator covers all Phase 3 testing; real-device gate explicitly moved to Phase 4.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (included in Flutter SDK 3.44.6) |
| Config file | None — uses `flutter test` default discovery |
| Quick run command | `flutter test test/features/barcode_scan/` |
| Full suite command | `flutter test` |
| Integration tests | `flutter test integration_test/` (requires connected device) |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| LOG-03 | Barcode lookup chain: High-confidence path (co2_overrides hit) | unit | `flutter test test/features/barcode_scan/barcode_scan_notifier_test.dart` | ❌ Wave 0 |
| LOG-03 | Barcode lookup chain: Medium-confidence path (category average) | unit | `flutter test test/features/barcode_scan/barcode_scan_notifier_test.dart` | ❌ Wave 0 |
| LOG-03 | Barcode lookup chain: no-match path (all three steps miss) | unit | `flutter test test/features/barcode_scan/barcode_scan_notifier_test.dart` | ❌ Wave 0 |
| LOG-03 | FoodCatalogDao.lookupByBarcodeWithCo2: returns FoodItem with co2e100g/confidenceBand | unit | `flutter test test/data/local/food_catalog_dao_test.dart` | ❌ Wave 0 (extend existing) |
| LOG-03 | FoodItem.copyWith preserves sentinel pattern for new co2e100g/confidenceBand fields | unit | `flutter test test/domain/entities/food_item_test.dart` | ❌ Wave 0 (extend existing) |
| LOG-03 | Real-device end-to-end: scan EAN-13 → FoodDetailBottomSheet with CO₂ row | manual | `flutter run --release` + physical Android | — (human-verify checkpoint) |
| LOG-04 | No-match screen shown when all lookup steps return null | unit | `flutter test test/features/barcode_scan/barcode_scan_notifier_test.dart` | ❌ Wave 0 |
| CO2-01 | ConfidenceChip renders green for 'high', amber for 'medium' | widget | `flutter test test/features/barcode_scan/confidence_chip_test.dart` | ❌ Wave 0 |
| CO2-01 | CO₂ value formatted to 1-2 significant figures (not 4+ decimal places) | unit | `flutter test test/features/barcode_scan/co2_formatting_test.dart` | ❌ Wave 0 |
| LEG-05 | MethodologyScreen renders all required attribution fields | widget | `flutter test test/features/barcode_scan/methodology_screen_test.dart` | ❌ Wave 0 |
| NFR-06b | >90% of products in off_reference.sqlite have a CO₂e estimate (after ingest) | integration | `flutter test integration_test/co2_coverage_benchmark_test.dart` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/features/barcode_scan/ test/data/local/food_catalog_dao_test.dart test/domain/entities/food_item_test.dart`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green + human-verify checkpoint (Android device scan) before `/gsd-verify-work`

### Wave 0 Gaps

- [ ] `test/features/barcode_scan/barcode_scan_notifier_test.dart` — covers LOG-03 lookup chain, LOG-04 no-match
- [ ] `test/features/barcode_scan/confidence_chip_test.dart` — covers CO2-01 chip rendering
- [ ] `test/features/barcode_scan/co2_formatting_test.dart` — covers CO2-01 significant figures rule
- [ ] `test/features/barcode_scan/methodology_screen_test.dart` — covers LEG-05 attribution display
- [ ] `integration_test/co2_coverage_benchmark_test.dart` — covers NFR-06(b) ≥90% coverage

*(Existing `test/data/local/food_catalog_dao_test.dart` and `test/domain/entities/food_item_test.dart` should be extended, not replaced.)*

---

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | — |
| V3 Session Management | no | — |
| V4 Access Control | no | — |
| V5 Input Validation | yes | Barcode raw value: sanitize before SQL (same `_sanitizeFts5Query` pattern for barcode lookup; barcode is NOT used in FTS5 query but is used in parameterized WHERE clause — use `Variable.withString(barcode)`) |
| V6 Cryptography | no | — |

### Known Threat Patterns

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| SQL injection via barcode value | Tampering | All barcode values passed as `Variable.withString()` in `customSelect` — confirmed pattern from Phase 2's `FoodCatalogDao` |
| Path traversal via AGRIBALYSE CSV download | Tampering | Ingest pipeline runs at developer time (not at runtime); CSV URL is hardcoded constant, not user input |
| Camera permission bypass | Elevation of Privilege | `permission_handler` + `mobile_scanner` both use OS-level permission APIs; no bypass possible within app |
| Malformed barcode values (oversized, Unicode) | Denial of Service | Add max-length guard on barcode string before any DB query (EAN-13 = 13 chars; UPC-A = 12 chars; EAN-8 = 8 chars — reject longer strings) |

---

## Sources

### Primary (HIGH confidence)

- pub.dev/packages/mobile_scanner — version 7.4.0, BarcodeFormat enum, MobileScannerController API, overlayBuilder, MobileScannerErrorCode [verified 2026-07-21]
- pub.dev/packages/permission_handler — version 12.0.3, publisher baseflow.com [verified 2026-07-21]
- pub.dev/packages/app_settings — version 8.0.3, AppSettings.openAppSettings() [verified 2026-07-21]
- data.ademe.fr/data-fair/api/v1/datasets/agribalyse-31-synthese/raw — live CSV fetch, 2,519 rows confirmed, column headers confirmed [verified 2026-07-21]
- api.flutter.dev/flutter/services/HapticFeedback/lightImpact.html — HapticFeedback.lightImpact() platform behavior [verified]
- pub.dev/documentation/mobile_scanner/latest/mobile_scanner/BarcodeFormat.html — BarcodeFormat.ean13(32), ean8(64), upcA(512) [verified 2026-07-21]

### Secondary (MEDIUM confidence)

- github.com/juliansteenbakker/mobile_scanner — MobileScannerController constructor parameters, overlayBuilder signature, stop/start/dispose pattern [verified from source]
- entrepot.recherche.data.gouv.fr/dataset.xhtml?persistentId=doi:10.57745/B5DTRR — AGRIBALYSE 3.1.1 files on DATAVERSE (Excel format, Etalab 2.0 license) [verified]
- blog.openfoodfacts.org/en/news/the-agribalyse-3-1-update-and-its-impact-on-the-eco-score-in-open-food-facts — OFF/AGRIBALYSE integration history
- github.com/openfoodfacts/openfoodfacts-server issues #4287, #2997 — OFF categories taxonomy `agribalyse_food_code` property [multiple source cross-reference]

### Tertiary (LOW confidence / ASSUMED)

- The existence and format of `ciqual_off_match.csv` as a standalone public file — referenced in CONTEXT.md but not verified from an authoritative URL [ASSUMED — see Open Questions #1]
- The exact mapping content of `off_to_agribalyse_map.csv` — strategy derived from research but the actual category-level mapping requires human authorship [ASSUMED]

---

## Metadata

**Confidence breakdown:**
- Standard stack (mobile_scanner, permission_handler, app_settings): HIGH — all verified on pub.dev with download counts, scores, and API docs
- AGRIBALYSE data format: HIGH — CSV fetched live; column names and units confirmed
- Architecture patterns (Dart code patterns): MEDIUM — MobileScannerController API verified; CO₂ DAO queries are derived from existing Phase 2 patterns but not test-compiled
- ciqual_off_match.csv existence: LOW — referenced in CONTEXT.md but not independently verified from a public URL
- off_to_agribalyse_map.csv content: LOW — requires human domain expertise to author correctly

**Research date:** 2026-07-21
**Valid until:** 2026-08-21 (mobile_scanner 7.4.0 was published 2026-07-20 — verify no breaking patch before pinning; AGRIBALYSE URL stable for at least 30 days based on data.gouv.fr update history)

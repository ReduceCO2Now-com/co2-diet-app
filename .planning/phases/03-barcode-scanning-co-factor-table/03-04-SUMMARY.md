---
phase: 03-barcode-scanning-co-factor-table
plan: "04"
subsystem: ui
tags: [flutter, co2e, agribalyse, confidence-chip, methodology, url_launcher, tdd]

requires:
  - phase: 03-02
    provides: co2_factors table in off_reference.sqlite with primary_category_tag + food_co2_overrides
  - phase: 03-03
    provides: BarcodeScanScreen and FoodDetailBottomSheet shell

provides:
  - AppColors.warningAmber token (Color(0xFFF59E0B)) in color_tokens.dart
  - formatCo2Display(double?) public utility function in co2_formatter.dart
  - ConfidenceChip widget (high=green, medium=amber) with explanation sheet
  - MethodologyScreen with AGRIBALYSE v3.1.1 attribution and GitHub link button
  - /methodology route in app_router.dart
  - CO2 row enabled in FoodDetailBottomSheet (conditionally hidden when null)
  - docs/CO2_METHODOLOGY.md committed (LEG-05 public methodology doc)
  - NFR-06(b) integration benchmark activated (real SQL query, 94.6% coverage)

affects:
  - 03-05 (human verify checkpoint — CO2 display visible, MethodologyScreen navigable)
  - 06 (Legal Hub links to docs/CO2_METHODOLOGY.md)

tech-stack:
  added:
    - url_launcher ^6.3.1 (system browser for GitHub methodology link)
  patterns:
    - Public formatter function in dedicated utils file (not private in widget)
    - ConfidenceChip.showExplanation static helper for sheet presentation
    - Conditional CO2 row hidden entirely when null (no placeholder)
    - NFR benchmark self-skips when off_reference.sqlite absent

key-files:
  created:
    - lib/features/barcode_scan/utils/co2_formatter.dart
    - lib/features/barcode_scan/widgets/confidence_chip.dart
    - lib/features/barcode_scan/screens/methodology_screen.dart
    - docs/CO2_METHODOLOGY.md
    - test/features/barcode_scan/co2_formatting_test.dart (updated from stub)
    - test/features/barcode_scan/confidence_chip_test.dart (updated from stub)
    - test/features/barcode_scan/methodology_screen_test.dart (updated from stub)
  modified:
    - lib/core/theme/color_tokens.dart (warningAmber added)
    - lib/features/food_search/widgets/food_detail_sheet.dart (CO2 row enabled)
    - lib/core/router/app_router.dart (/methodology route added)
    - pubspec.yaml (url_launcher added)
    - integration_test/co2_coverage_benchmark_test.dart (stub replaced with real benchmark)

key-decisions:
  - "formatCo2Display lives in dedicated co2_formatter.dart (not inline in food_detail_sheet.dart) — public function importable from tests"
  - "CO2 row hidden entirely (not '—') when co2e100g is null — per plan design decision, no false-precision placeholders"
  - "ConfidenceChip.showExplanation static helper pattern — callers provide context, chip does not navigate itself"
  - "url_launcher opens system browser (LaunchMode.externalApplication) — privacy-safe over embedded WebView"
  - "NFR-06(b) benchmark self-skips when off_reference.sqlite absent via setUpAll try/on Object pattern (same as NFR-06a benchmark)"

patterns-established:
  - "formatCo2Display: values <10 use toStringAsPrecision(2); values >=10 use round().toString()"
  - "ConfidenceChip accepts band string and onTap VoidCallback? — caller provides sheet logic via static helper"
  - "CO2 row uses if (item.co2e100g != null) guard — no else branch, no placeholder"

requirements-completed:
  - CO2-01
  - LEG-05

duration: 7min
completed: "2026-07-21"
---

# Phase 03 Plan 04: CO₂ Display Wiring Summary

**CO2e display live in FoodDetailBottomSheet and BarcodeScanScreen via ConfidenceChip (high=green, medium=amber), formatCo2Display formatter, MethodologyScreen with AGRIBALYSE v3.1.1 attribution, and /methodology route — satisfying CO2-01 and LEG-05**

## Performance

- **Duration:** ~7 min
- **Started:** 2026-07-21T00:53:48Z
- **Completed:** 2026-07-21T01:00:39Z
- **Tasks:** 2
- **Files modified:** 11

## Accomplishments
- Implemented full CO2 display layer: warningAmber token, formatCo2Display utility, ConfidenceChip widget, MethodologyScreen, /methodology route
- Enabled CO2 row in FoodDetailBottomSheet with conditional rendering (hidden entirely when co2e100g is null)
- Committed docs/CO2_METHODOLOGY.md with full AGRIBALYSE v3.1.1 attribution, confidence band definitions, DOI, and license
- Replaced NFR-06(b) Wave 0 stub with real SQL benchmark confirming 94.6% CO2 coverage (above 90% threshold)
- All tests pass: 87 passing, 9 skipped (pre-existing Wave 0 stubs for BarcodeScanNotifier)

## Task Commits

Each task was committed atomically:

1. **TDD RED: failing tests for co2_formatting, confidence_chip, methodology_screen** - `2d5147a` (test)
2. **TDD GREEN: CO2 display wiring implementation** - `3f99098` (feat)
3. **Task 2: CO2_METHODOLOGY.md + NFR-06(b) benchmark** - `643dca2` (feat)

## Files Created/Modified
- `lib/core/theme/color_tokens.dart` - Added warningAmber = Color(0xFFF59E0B) token
- `lib/features/barcode_scan/utils/co2_formatter.dart` - Public formatCo2Display(double?) function
- `lib/features/barcode_scan/widgets/confidence_chip.dart` - ConfidenceChip widget and ConfidenceExplanationSheet
- `lib/features/barcode_scan/screens/methodology_screen.dart` - MethodologyScreen with attribution and GitHub link
- `lib/features/food_search/widgets/food_detail_sheet.dart` - CO2 row enabled with ConfidenceChip
- `lib/core/router/app_router.dart` - /methodology route added
- `pubspec.yaml` - url_launcher ^6.3.1 added
- `docs/CO2_METHODOLOGY.md` - Full methodology documentation (LEG-05)
- `integration_test/co2_coverage_benchmark_test.dart` - Real NFR-06(b) benchmark replacing stub
- `test/features/barcode_scan/co2_formatting_test.dart` - Real tests replacing stub
- `test/features/barcode_scan/confidence_chip_test.dart` - Real tests replacing stub
- `test/features/barcode_scan/methodology_screen_test.dart` - Real tests replacing stub

## Decisions Made
- `formatCo2Display` lives in dedicated `co2_formatter.dart` (not inline in food_detail_sheet.dart) — public function importable from tests
- CO2 row hidden entirely (not '—') when `co2e100g` is null — no false-precision placeholders per CONTEXT.md design decision
- `ConfidenceChip.showExplanation` static helper pattern — callers provide `BuildContext`, chip does not navigate itself
- `url_launcher` opens `LaunchMode.externalApplication` (system browser) — privacy-safe over embedded WebView
- NFR-06(b) benchmark uses `setUpAll` try/on Object pattern for graceful self-skip when off_reference.sqlite absent

## Deviations from Plan

None — plan executed exactly as written. The `url_launcher` package was not in pubspec.yaml (as expected per plan) and was added with CI blocklist check passing (153 packages, 0 violations).

## Issues Encountered

None — TDD flow proceeded smoothly. All three test files (co2_formatting, confidence_chip, methodology_screen) went RED → GREEN as expected.

## Known Stubs

None — all CO2 display functionality is wired to real data:
- `formatCo2Display` uses actual `double?` values from `FoodItem.co2e100g`
- `ConfidenceChip` renders based on actual `FoodItem.confidenceBand`
- `MethodologyScreen` contains static content (not data-driven, intentional)

## Threat Flags

No new threat surface beyond the plan's threat model. T-03-04-01 (url_launcher GitHub link) and T-03-04-02 (formatCo2Display false precision mitigation) are both addressed as designed.

## Next Phase Readiness
- CO2 display layer complete — ready for Phase 03-05 human verification checkpoint
- BarcodeScanScreen already showed basic CO2 from Plan 03-03; Plan 03-04 upgrades it with ConfidenceChip and proper formatting
- FoodDetailBottomSheet (food search flow) now also shows CO2 row
- docs/CO2_METHODOLOGY.md committed and ready for Phase 6 Legal Hub linkage

---
*Phase: 03-barcode-scanning-co-factor-table*
*Completed: 2026-07-21*

## Self-Check: PASSED

All created files exist:
- [x] lib/features/barcode_scan/utils/co2_formatter.dart
- [x] lib/features/barcode_scan/widgets/confidence_chip.dart
- [x] lib/features/barcode_scan/screens/methodology_screen.dart
- [x] docs/CO2_METHODOLOGY.md
- [x] integration_test/co2_coverage_benchmark_test.dart (real benchmark)

All commits exist:
- [x] 2d5147a (test RED)
- [x] 3f99098 (feat GREEN)
- [x] 643dca2 (feat Task 2)

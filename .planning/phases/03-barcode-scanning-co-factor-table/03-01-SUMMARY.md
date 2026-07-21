---
phase: 03-barcode-scanning-co-factor-table
plan: "01"
subsystem: test-infrastructure
tags: [wave-0-stubs, tdd, barcode-scan, co2-factors, test-only]
dependency_graph:
  requires: []
  provides:
    - test/features/barcode_scan/barcode_scan_notifier_test.dart
    - test/features/barcode_scan/confidence_chip_test.dart
    - test/features/barcode_scan/co2_formatting_test.dart
    - test/features/barcode_scan/methodology_screen_test.dart
    - test/data/local/food_catalog_dao_barcode_test.dart
    - integration_test/co2_coverage_benchmark_test.dart
  affects: []
tech_stack:
  added: []
  patterns:
    - "Phase 3 Wave 0: group-level skip for unit stubs (group skip: '...' arg)"
    - "Phase 3 integration stub: markTestSkipped() inside testWidgets body (no device required)"
key_files:
  created:
    - test/features/barcode_scan/barcode_scan_notifier_test.dart
    - test/features/barcode_scan/confidence_chip_test.dart
    - test/features/barcode_scan/co2_formatting_test.dart
    - test/features/barcode_scan/methodology_screen_test.dart
    - test/data/local/food_catalog_dao_barcode_test.dart
    - integration_test/co2_coverage_benchmark_test.dart
  modified: []
decisions:
  - "Phase 3 Wave 0 unit stubs follow same group-level skip pattern as Phase 2 (group skip: arg on group(), not individual tests)"
  - "Integration stub co2_coverage_benchmark_test.dart uses markTestSkipped() inside testWidgets body — same as food_search_benchmark_test.dart Wave 0 stub"
  - "Line-length lint (info) fixed in barcode_scan_notifier_test.dart using Dart adjacent string concatenation"
metrics:
  duration: "2m 13s"
  completed: "2026-07-21"
  tasks_completed: 2
  tasks_total: 2
  files_created: 6
  files_modified: 0
---

# Phase 3 Plan 01: Wave 0 Test Stubs Summary

Six Wave 0 test stub files created for all Phase 3 barcode scanning and CO₂ factor features — group-level skip unit stubs and markTestSkipped() integration stub — all compiling and exiting 0 with flutter test.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | barcode_scan_notifier, confidence_chip, co2_formatting stubs | 1aa97a9 | 3 created |
| 2 | methodology_screen, food_catalog_dao_barcode, co2_coverage_benchmark stubs | 191240a | 3 created (+1 line-length fix) |

## What Was Built

Six stub test files providing named targets for every Phase 3 execution plan:

**Unit stubs (group-level skip pattern):**
- `test/features/barcode_scan/barcode_scan_notifier_test.dart` — 4 tests covering LOG-03 lookup-chain paths and LOG-04 no-match emission
- `test/features/barcode_scan/confidence_chip_test.dart` — 3 testWidgets covering CO2-01 green/amber chip rendering and tap interaction
- `test/features/barcode_scan/co2_formatting_test.dart` — 3 tests covering CO2-01/NFR-05 significant-figures formatting with ~prefix
- `test/features/barcode_scan/methodology_screen_test.dart` — 3 testWidgets covering LEG-05 AGRIBALYSE v3.1.1 attribution and ADEME credit
- `test/data/local/food_catalog_dao_barcode_test.dart` — 3 tests covering LOG-03 barcode lookup with CO₂ fields (high/medium/null paths)

**Integration stub (markTestSkipped() pattern):**
- `integration_test/co2_coverage_benchmark_test.dart` — NFR-06(b) ≥90% CO₂ coverage benchmark; self-skips without a device

## Verification Results

- `flutter test test/features/barcode_scan/barcode_scan_notifier_test.dart confidence_chip_test.dart co2_formatting_test.dart` — 10 skipped, 0 failed, exit 0
- `flutter test test/features/barcode_scan/methodology_screen_test.dart test/data/local/food_catalog_dao_barcode_test.dart` — 6 skipped, 0 failed, exit 0
- `flutter test test/` — 66 passed, 17 skipped, 0 failed, exit 0
- `flutter analyze test/features/barcode_scan/ test/data/local/food_catalog_dao_barcode_test.dart` — No issues found

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Style] Fixed line-length lint in barcode_scan_notifier_test.dart**
- **Found during:** Task 2 verification (flutter analyze)
- **Issue:** Two test name strings exceeded 80-character limit (info-level lint)
- **Fix:** Split long string literals using Dart adjacent string concatenation across two lines
- **Files modified:** test/features/barcode_scan/barcode_scan_notifier_test.dart
- **Commit:** 191240a (included with Task 2)

## Known Stubs

All six files are intentional stubs by design (Wave 0 plan objective). They will be replaced by real tests in Plans 03-02 through 03-05 when production code is implemented.

| File | Stub Type | Resolved By |
|------|-----------|-------------|
| barcode_scan_notifier_test.dart | group-level skip | Plan 03-02 (BarcodeScanNotifier) |
| confidence_chip_test.dart | group-level skip | Plan 03-03 (ConfidenceChip widget) |
| co2_formatting_test.dart | group-level skip | Plan 03-03 (formatCo2Display) |
| methodology_screen_test.dart | group-level skip | Plan 03-04 (MethodologyScreen) |
| food_catalog_dao_barcode_test.dart | group-level skip | Plan 03-02 (barcode DAO) |
| co2_coverage_benchmark_test.dart | markTestSkipped() | Plan 03-05 (CO₂ ingest pipeline) |

## Threat Flags

None. No production code modified; no new network endpoints, auth paths, or trust boundary surfaces introduced.

## Self-Check: PASSED

Files exist:
- FOUND: test/features/barcode_scan/barcode_scan_notifier_test.dart
- FOUND: test/features/barcode_scan/confidence_chip_test.dart
- FOUND: test/features/barcode_scan/co2_formatting_test.dart
- FOUND: test/features/barcode_scan/methodology_screen_test.dart
- FOUND: test/data/local/food_catalog_dao_barcode_test.dart
- FOUND: integration_test/co2_coverage_benchmark_test.dart

Commits exist:
- FOUND: 1aa97a9 (Task 1)
- FOUND: 191240a (Task 2)

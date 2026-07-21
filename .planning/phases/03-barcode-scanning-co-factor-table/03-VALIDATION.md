---
phase: 3
slug: barcode-scanning-co-factor-table
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-07-21
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter test (dart test for pure-Dart units) |
| **Config file** | `flutter_test` (built-in); benchmarks in `integration_test/` |
| **Quick run command** | `flutter test test/` |
| **Full suite command** | `flutter test test/ && flutter analyze` |
| **Estimated runtime** | ~30–60 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/`
- **After every plan wave:** Run `flutter test test/ && flutter analyze`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 3-scan-notifier | BarcodeScanNotifier lookup chain | 1 | LOG-03, LOG-04 | unit | `flutter test test/features/barcode_scan/barcode_scan_notifier_test.dart` | ❌ W0 (Plan 01) | ⬜ pending |
| 3-CO2-band | Confidence chip rendering | 1 | CO2-01 | widget | `flutter test test/features/barcode_scan/confidence_chip_test.dart` | ❌ W0 (Plan 01) | ⬜ pending |
| 3-CO2-format | CO₂ significant-figures formatting | 1 | CO2-01 | unit | `flutter test test/features/barcode_scan/co2_formatting_test.dart` | ❌ W0 (Plan 01) | ⬜ pending |
| 3-leg-methodology | MethodologyScreen attribution display | 1 | LEG-05 | widget | `flutter test test/features/barcode_scan/methodology_screen_test.dart` | ❌ W0 (Plan 01) | ⬜ pending |
| 3-dao-barcode | FoodCatalogDao.lookupByBarcodeWithCo2 | 1 | LOG-03 | unit | `flutter test test/data/local/food_catalog_dao_barcode_test.dart` | ❌ W0 (Plan 01) | ⬜ pending |
| 3-nfr-coverage | ≥90% CO₂ coverage benchmark | 1 | CO2-01 | integration | `flutter test integration_test/co2_coverage_benchmark_test.dart` | ❌ W0 (Plan 01) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/features/barcode_scan/barcode_scan_notifier_test.dart` — stubs for LOG-03 lookup chain and LOG-04 no-match (Plan 01 Task 1)
- [ ] `test/features/barcode_scan/confidence_chip_test.dart` — stubs for CO2-01 confidence chip rendering (Plan 01 Task 1)
- [ ] `test/features/barcode_scan/co2_formatting_test.dart` — stubs for CO2-01 significant-figures rule (Plan 01 Task 1)
- [ ] `test/features/barcode_scan/methodology_screen_test.dart` — stubs for LEG-05 attribution display (Plan 01 Task 2)
- [ ] `test/data/local/food_catalog_dao_barcode_test.dart` — stubs for FoodCatalogDao barcode lookup with CO₂ fields (Plan 01 Task 2)
- [ ] `integration_test/co2_coverage_benchmark_test.dart` — stub for NFR-06(b) ≥90% coverage benchmark (Plan 01 Task 2)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Real barcode scan → autofill on real iOS device | LOG-03 (P0) | Requires physical device + camera hardware | Open scanner, scan EAN-13 product, verify name/macros/CO₂e autofill |
| Real barcode scan → autofill on real Android device | LOG-03 (P0) | Requires physical device + camera hardware | Open scanner, scan EAN-13 product, verify name/macros/CO₂e autofill |
| No-match scan → "Add as custom food" CTA visible | LOG-03 | Requires camera + a genuinely unknown barcode | Scan unrecognised barcode, verify fallback CTA appears |
| CO₂ methodology GitHub link opens correctly | LEG-05 | Deep-link behaviour varies by OS | Tap link in app, confirm browser opens correct URL |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

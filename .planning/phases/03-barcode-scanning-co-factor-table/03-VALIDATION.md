---
phase: 3
slug: barcode-scanning-co-factor-table
status: draft
nyquist_compliant: false
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
| 3-CO2-map | CO2 factor ingest | 1 | CO2-01 | unit | `flutter test test/co2/co2_factor_dao_test.dart` | ❌ W0 | ⬜ pending |
| 3-CO2-lookup | CO2 lookup service | 1 | CO2-01 | unit | `flutter test test/co2/co2_lookup_service_test.dart` | ❌ W0 | ⬜ pending |
| 3-CO2-band | Confidence band display | 1 | CO2-01 | widget | `flutter test test/co2/confidence_chip_test.dart` | ❌ W0 | ⬜ pending |
| 3-scan-permission | Camera permission flow | 2 | LOG-03 | widget | `flutter test test/scanner/scanner_permission_test.dart` | ❌ W0 | ⬜ pending |
| 3-scan-dedup | onDetect dedup guard | 2 | LOG-03 | unit | `flutter test test/scanner/scanner_dedup_test.dart` | ❌ W0 | ⬜ pending |
| 3-scan-miss | No-match fallback UX | 2 | LOG-03 | widget | `flutter test test/scanner/scanner_no_match_test.dart` | ❌ W0 | ⬜ pending |
| 3-scan-offline | Offline barcode lookup | 2 | LOG-03 | unit | `flutter test test/scanner/scanner_offline_test.dart` | ❌ W0 | ⬜ pending |
| 3-nfr-coverage | >90% category coverage | 3 | LOG-04 | unit | `flutter test test/co2/co2_coverage_test.dart` | ❌ W0 | ⬜ pending |
| 3-leg-link | Methodology link in app | 3 | LEG-05 | widget | `flutter test test/legal/methodology_link_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/co2/co2_factor_dao_test.dart` — stubs for CO2-01 factor table DAO
- [ ] `test/co2/co2_lookup_service_test.dart` — stubs for CO2-01 lookup service
- [ ] `test/co2/confidence_chip_test.dart` — stubs for CO2-01 confidence band widget
- [ ] `test/scanner/scanner_permission_test.dart` — stubs for LOG-03 permission flow
- [ ] `test/scanner/scanner_dedup_test.dart` — stubs for LOG-03 onDetect dedup guard
- [ ] `test/scanner/scanner_no_match_test.dart` — stubs for LOG-03 no-match fallback
- [ ] `test/scanner/scanner_offline_test.dart` — stubs for LOG-03 offline lookup
- [ ] `test/co2/co2_coverage_test.dart` — stubs for LOG-04 >90% coverage check
- [ ] `test/legal/methodology_link_test.dart` — stubs for LEG-05 methodology link

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

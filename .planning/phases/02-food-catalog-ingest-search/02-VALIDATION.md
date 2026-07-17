---
phase: 2
slug: food-catalog-ingest-search
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-17
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (SDK) + `integration_test` (SDK) |
| **Config file** | none — uses `flutter test` CLI |
| **Quick run command** | `flutter test test/` |
| **Full suite command** | `flutter test test/ && flutter test integration_test/` |
| **Estimated runtime** | ~30s (unit) + ~120s (integration, device) |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/`
- **After every plan wave:** Run `flutter test test/ && flutter test integration_test/`
- **Before `/gsd:verify-work`:** Full suite must be green + benchmark passing on physical Android device
- **Max feedback latency:** 30 seconds (unit suite)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 2-01-01 | 01 | 0 | LOG-01 | unit (stub) | `flutter test test/data/local/food_catalog_dao_test.dart` | ❌ W0 | ⬜ pending |
| 2-01-02 | 01 | 0 | LOG-02 | unit (stub) | `flutter test test/data/repositories/food_catalog_repository_test.dart` | ❌ W0 | ⬜ pending |
| 2-01-03 | 01 | 0 | LOG-01, NFR-06a | integration (stub) | `flutter test integration_test/food_search_benchmark_test.dart` | ❌ W0 | ⬜ pending |
| 2-01-04 | 01 | 1 | LOG-01 | unit | `flutter test test/data/local/food_catalog_dao_test.dart` | ❌ W0 | ⬜ pending |
| 2-01-05 | 01 | 1 | LOG-02 | unit | `flutter test test/data/repositories/food_catalog_repository_test.dart` | ❌ W0 | ⬜ pending |
| 2-02-01 | 02 | 1 | LOG-01, LOG-02 | unit | `flutter test test/features/food_search/food_search_notifier_test.dart` | ❌ W0 | ⬜ pending |
| 2-03-01 | 03 | 2 | LOG-01, NFR-06a | integration (physical device) | `flutter test integration_test/food_search_benchmark_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/data/local/food_catalog_dao_test.dart` — stubs for LOG-01 FTS5 DAO tests
- [ ] `test/data/repositories/food_catalog_repository_test.dart` — stubs for LOG-02 fallback + caching
- [ ] `test/features/food_search/food_search_notifier_test.dart` — stubs for debounce, state transitions
- [ ] `integration_test/food_search_benchmark_test.dart` — benchmark stubs for LOG-01, NFR-06a
- [ ] `integration_test/` directory must be created
- [ ] `build.yaml` must be created with FTS5 module (`modules: [fts5]`) under `drift_dev` builder options

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Benchmark queries complete in <1s on physical Pixel 6a / Samsung A54 | LOG-01 | Emulator performance is not representative; must be physical device | Connect device, run `flutter test integration_test/food_search_benchmark_test.dart --device-id <id>`; confirm all Stopwatch assertions pass |
| First-launch decompression splash shows and completes without freeze | LOG-01 (UX) | Visual/UX check, timing depends on device I/O | Install fresh app build; observe splash with "Setting up food database..." text; verify subsequent launch skips extraction |
| No-results offline state shows correct variant | LOG-02 | Requires toggling airplane mode | Put device in airplane mode, search a term with no local results; verify "No results — connect to the internet to search more" appears |
| NFR-06b CO₂ coverage | NFR-06 | CO₂ factor table not built until Phase 3 | Deferred to Phase 3 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

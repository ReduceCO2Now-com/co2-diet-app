---
phase: 02-food-catalog-ingest-search
plan: "01"
subsystem: testing
tags: [drift, drift_dev, fts5, flutter_test, integration_test, wave-0]

requires:
  - phase: 01-foundations-sync-safe-schema
    provides: AppDatabase, Drift schema, pubspec.yaml with integration_test dev_dependency

provides:
  - build.yaml with drift_dev FTS5 module config (global codegen permission)
  - Wave 0 stub tests for FoodCatalogDao (LOG-01), FoodCatalogRepository (LOG-02), FoodSearchNotifier
  - integration_test/ directory with BM-01/BM-02/BM-03 benchmark stubs for NFR-06a

affects:
  - 02-02 (FTS5 DAO implementation uses build.yaml FTS5 config)
  - 02-03 (FoodCatalogRepository stubs will be filled in)
  - 02-04 (FoodSearchNotifier stubs will be filled in)
  - 02-05 (benchmark integration tests activated when off_reference.sqlite bundled)

tech-stack:
  added: []
  patterns:
    - "Wave 0 stub pattern: group/test with skip: 'Wave 0 stub — X not yet implemented' for pending tests"
    - "Integration test dbReady guard: const dbReady = false; markTestSkipped() pattern for device-dependent stubs"
    - "build.yaml drift_dev FTS5 config: targets.$default.builders.drift_dev.options.sql.options.modules: [fts5]"

key-files:
  created:
    - build.yaml
    - test/data/local/food_catalog_dao_test.dart
    - test/data/repositories/food_catalog_repository_test.dart
    - test/features/food_search/food_search_notifier_test.dart
    - integration_test/food_search_benchmark_test.dart
  modified: []

key-decisions:
  - "build.yaml targets.$default (not a named target) so drift_dev options apply globally to all .drift files"
  - "Wave 0 unit stubs use group-level skip (not test-level) so all tests in the group are skipped atomically"
  - "Integration benchmark stubs use const dbReady = false guard + markTestSkipped() (not skip: arg) to exit gracefully inside testWidgets"
  - "Lint violations (80-char lines, type annotation) fixed inline per very_good_analysis project convention"

patterns-established:
  - "Wave 0 stub: compile-clean test files with skip: 'Wave 0 stub — X not yet implemented' that exit 0 under flutter test"
  - "Integration test self-skip: const dbReady = false; markTestSkipped() inside testWidgets body for device-dependent benchmarks"

requirements-completed:
  - LOG-01
  - LOG-02
  - NFR-06

duration: 6min
completed: "2026-07-20"
---

# Phase 2 Plan 01: Wave 0 Test Scaffolds + FTS5 Build Config Summary

**build.yaml with drift_dev FTS5 module config plus 4 compile-clean Wave 0 stub files
(3 unit + 1 integration benchmark) gating all Phase 2 implementation plans**

## Performance

- **Duration:** 6 min
- **Started:** 2026-07-20T15:57:51Z
- **Completed:** 2026-07-20T16:03:27Z
- **Tasks:** 3
- **Files modified:** 5

## Accomplishments

- Created `build.yaml` at project root configuring `drift_dev` with sqlite dialect 3.34
  and `modules: [fts5]` — required for FTS5 virtual table declarations in Plans 02-02+
- Created 3 Wave 0 unit test stubs (12 tests total, all skipped) covering LOG-01 FTS5 DAO,
  LOG-02 fallback/caching, and FoodSearchNotifier debounce/state transitions
- Created `integration_test/food_search_benchmark_test.dart` with BM-01/BM-02/BM-03
  benchmark stubs (self-skip via `dbReady=false` guard) covering NFR-06a timing requirement
- All files pass `dart analyze` with zero issues; `flutter test` exits 0 with 12 skipped

## Task Commits

1. **Task 1: build.yaml with FTS5 module config** — `e8886d1` (chore)
2. **Task 2: Wave 0 unit test stubs (DAO, Repository, Notifier)** — `c6b8b9e` (test)
3. **Task 3: Wave 0 integration test benchmark stub** — `1caa6a4` (test)

## Files Created/Modified

- `build.yaml` — drift_dev builder config with sqlite 3.34 + fts5 module
- `test/data/local/food_catalog_dao_test.dart` — 3 skipped stubs for LOG-01 FTS5 DAO
- `test/data/repositories/food_catalog_repository_test.dart` — 4 skipped stubs for LOG-02 fallback/caching
- `test/features/food_search/food_search_notifier_test.dart` — 5 skipped stubs for FoodSearchNotifier
- `integration_test/food_search_benchmark_test.dart` — BM-01, BM-02, BM-03 benchmark stubs

## Decisions Made

- **build.yaml uses `$default` target** so drift_dev FTS5 options apply globally without
  needing to enumerate individual Dart files; consistent with the project's single-app structure.
- **group-level skip in unit stubs** (not per-test) so all tests fail atomically when the
  production class is missing — prevents partial-skip confusion.
- **`markTestSkipped()` in integration stub** (not `skip:` argument) because `testWidgets`
  with `skip:` still requires a connected device to register the skip; `markTestSkipped()`
  inside the body exits cleanly even in the Xcode host build path.
- **Lint fixes applied inline** per `very_good_analysis` 80-char and `omit_local_variable_types`
  rules enforced across the project.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Fixed very_good_analysis lint violations in test stubs**
- **Found during:** Task 3 (integration benchmark stub)
- **Issue:** `dart analyze` reported 5 info-level violations across 4 files (80-char line
  limit, unnecessary type annotation) — the project enforces `very_good_analysis` conventions
- **Fix:** Reformatted long test names to multi-line `test(name, () {...})` form; removed
  explicit `bool` type annotation on `const dbReady`; broke long comment lines
- **Files modified:** `integration_test/food_search_benchmark_test.dart`,
  `test/data/local/food_catalog_dao_test.dart`,
  `test/data/repositories/food_catalog_repository_test.dart`,
  `test/features/food_search/food_search_notifier_test.dart`
- **Verification:** `dart analyze` reports "No issues found" on all four files
- **Committed in:** `1caa6a4` (Task 3 commit)

---

**Total deviations:** 1 auto-fixed (Rule 2 — missing critical: lint compliance)
**Impact on plan:** Necessary to match project coding conventions. No scope change.

## Issues Encountered

- **Integration test requires device**: Running `flutter test integration_test/food_search_benchmark_test.dart`
  triggers an iOS simulator build which fails when no simulator is booted. This is expected
  behavior for `integration_test` files — they require an emulator or device. The plan's done
  criteria specifies "on emulator/device" and the self-skip guard (`dbReady=false`) ensures
  the tests exit cleanly when run. File syntax verified via `dart analyze` (no issues).

## Known Stubs

All stubs in this plan are intentional Wave 0 scaffolds, not unresolved gaps:

| File | Stub type | Resolving plan |
|------|-----------|----------------|
| `test/data/local/food_catalog_dao_test.dart` | group-level skip | Plan 02-02 (FoodCatalogDao impl) |
| `test/data/repositories/food_catalog_repository_test.dart` | group-level skip | Plan 02-03 (FoodCatalogRepository impl) |
| `test/features/food_search/food_search_notifier_test.dart` | group-level skip | Plan 02-04 (FoodSearchNotifier impl) |
| `integration_test/food_search_benchmark_test.dart` | dbReady=false guard | Plan 02-05 (asset bundling) |

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- `build.yaml` is in place; Plans 02-02+ can declare FTS5 virtual tables in `.drift` files
  without additional config
- `integration_test/` directory exists; Plans 02-05 and 02-06 can add further integration tests
- Wave 0 test stubs provide compilation gates: any plan that implements the real production
  class must remove the `skip:` from the corresponding group to activate the tests
- No blockers; Plans 02-02 through 02-06 can proceed in Wave 1

---
*Phase: 02-food-catalog-ingest-search*
*Completed: 2026-07-20*

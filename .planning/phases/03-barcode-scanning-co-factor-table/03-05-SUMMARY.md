---
phase: 03-barcode-scanning-co-factor-table
plan: 05
subsystem: testing
tags: [flutter, barcode, mobile_scanner, android, co2, integration-test, human-verify]

# Dependency graph
requires:
  - phase: 03-04
    provides: ConfidenceChip, FoodDetailBottomSheet CO2 row, MethodologyScreen, NFR-06(b) benchmark

provides:
  - Signed-off P0 acceptance record: real EAN-13 barcode scan verified on Galaxy Tab S7 FE (Android 14)
  - NFR-06(b) 94.6% CO₂ coverage confirmed on physical Android device
  - Regression fix: API macro fall-through when local off_ref result has null nutrients
  - Idempotent ATTACH DATABASE guard and shared AppDatabase test fixture

affects:
  - 04-meal-logging-core (barcode scan is the primary food-add entry point for Phase 4)
  - All future phases using FoodCatalogRepository (macro+CO₂ merge logic now correct)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Macro+CO₂ merge: fall through to API when local result has null calories100g; merge API macros with local CO₂/confidence on success; serve local CO₂-only on offline error"
    - "Idempotent ATTACH DATABASE: guard with pragma_database_list check before attaching off_reference.sqlite"
    - "Shared AppDatabase fixture: setUpAll/tearDownAll single instance prevents duplicate ATTACH errors in benchmark tests"

key-files:
  created:
    - .planning/phases/03-barcode-scanning-co-factor-table/03-05-SUMMARY.md
  modified:
    - lib/data/repositories/food_catalog_repository.dart
    - lib/data/local/migrations/migration_strategy.dart
    - integration_test/food_search_benchmark_test.dart
    - linux/flutter/generated_plugin_registrant.cc
    - linux/flutter/generated_plugins.cmake
    - macos/Flutter/GeneratedPluginRegistrant.swift
    - windows/flutter/generated_plugin_registrant.cc
    - windows/flutter/generated_plugins.cmake

key-decisions:
  - "NFR-06(b) 94.6% CO₂ coverage — exceeds 90% threshold. Phase 3 criterion PASSED."
  - "off_ref.products has macro data for only ~3% of products — after primary_category_tag was populated in 03-02, lookupByBarcodeWithCo2 returned CO₂ results with null macros for 97% of scanned products. Fix: return local early only when calories100g != null; otherwise fall through to API then merge macros + local CO₂."
  - "Offline error path returns local (CO₂-only) rather than null so users see CO₂ estimate even when API unreachable."
  - "ATTACH DATABASE guarded with pragma_database_list to be idempotent — prevents OperationalError on repeated test runs sharing one executor."
  - "iOS real-device gate deferred to Phase 4 per 03-CONTEXT.md — no physical iPhone available, TestFlight setup is a Phase 4 prerequisite."

patterns-established:
  - "Macro+CO₂ merge pattern: local CO₂ + API macros merged when local result is CO₂-enriched but nutrient-sparse"

requirements-completed: [LOG-03, LOG-04, CO2-01, LEG-05]

# Metrics
duration: ~30min (automated) + real-device human verification
completed: 2026-07-22
---

# Phase 3 Plan 05: Real-Device Human-Verify Checkpoint Summary

**EAN-13 barcode scan verified end-to-end on Galaxy Tab S7 FE (Android 14) with 94.6% CO₂ coverage — Phase 3 P0 criterion satisfied and macro regression fixed**

## Performance

- **Duration:** ~30 min automated + real-device human checkpoint
- **Started:** 2026-07-22T14:00:00Z
- **Completed:** 2026-07-22T16:34:00Z
- **Tasks:** 2 (Task 1: automated benchmark + regression fixes; Task 2: human verify checkpoint — APPROVED)
- **Files modified:** 9

## Accomplishments

- NFR-06(b) integration benchmark: 94.6% CO₂ coverage on Galaxy Tab S7 FE — exceeds the 90% threshold
- Real EAN-13 scan confirmed end-to-end: FoodDetailBottomSheet shows product name, macros (calories/protein/carbs/fat), CO₂e value, and ConfidenceChip on a physical Android device (LOG-03 P0 criterion)
- No-match UX confirmed: BarcodeScanNoMatchScreen with "Add as custom food" button (LOG-04)
- Camera permission denied → "Open Settings" flow confirmed working (LOG-03)
- CO₂ confidence chip opens explanation sheet → "Full methodology" → MethodologyScreen showing AGRIBALYSE v3.1.1 + Source ADEME (CO2-01, LEG-05)
- Scanner resumes after sheet dismiss without freezing
- Regression fix: macro fall-through to API when local CO₂ result has null nutrients (97% of off_ref products)

## Task Commits

Each task was committed atomically:

1. **Task 1: Build release APK and run NFR-06(b) benchmark** - `2a7559d` (fix) + `a107179` (fix — macro regression)
2. **Task 2: Real-device end-to-end human verification** — APPROVED (no code changes; checkpoint record only)

**Plan metadata:** (docs commit — this summary)

## Files Created/Modified

- `lib/data/repositories/food_catalog_repository.dart` — Macro+CO₂ merge fix: fall through to API when local result has null calories100g; merge API macros with local CO₂ on success; serve local CO₂-only on offline error
- `lib/data/local/migrations/migration_strategy.dart` — Guard ATTACH DATABASE with pragma_database_list check to make re-attachment idempotent
- `integration_test/food_search_benchmark_test.dart` — Refactored to shared AppDatabase instance in setUpAll/tearDownAll to prevent duplicate ATTACH DATABASE errors across test wrappers
- `linux/flutter/generated_plugin_registrant.cc` — Register url_launcher plugin (added in 03-04, was missing from Linux platform registrant)
- `linux/flutter/generated_plugins.cmake` — Register url_launcher for Linux
- `macos/Flutter/GeneratedPluginRegistrant.swift` — Register url_launcher for macOS
- `windows/flutter/generated_plugin_registrant.cc` — Register url_launcher for Windows
- `windows/flutter/generated_plugins.cmake` — Register url_launcher for Windows

## Real-Device Verification Record

**Device:** Samsung Galaxy Tab S7 FE (SM-T736B), Android 14
**Verification date:** 2026-07-22
**Test results:**

| Check | Result |
|-------|--------|
| Barcode scanner entry — AppBar icon, full-screen camera, corner overlay, torch toggle | PASS |
| Real EAN-13 scan → FoodDetailBottomSheet with name + macros + CO₂e + ConfidenceChip | PASS |
| ConfidenceChip tap → explanation sheet → "Full methodology" → MethodologyScreen (AGRIBALYSE v3.1.1, Source ADEME) | PASS |
| Sheet dismiss → live camera resumes | PASS |
| No-match barcode → BarcodeScanNoMatchScreen with "Add as custom food" CTA (navigates correctly) | PASS |
| Camera permission denial → CameraPermissionDeniedWidget → "Open Settings" works → re-grant resumes scanner | PASS |
| NFR-06(b) CO₂ coverage benchmark | 94.6% (threshold ≥ 90%) — PASS |

## Decisions Made

- **Macro regression root cause:** off_ref.products stores macro data for only ~3% of products. After primary_category_tag was populated in Plan 03-02, lookupByBarcodeWithCo2 Step 2 started returning CO₂-enriched results for ~333k products — but 97% had null calories/protein/carbs/fat. The repository returned these immediately, bypassing the API that has full nutriment data.

- **Fix approach:** Return the local result early only when it also carries macro data (calories100g != null). Otherwise fall through to the API, then merge: if local had CO₂ (but no macros) → merge API macros + local CO₂/confidence; if no local match at all → enrich via lookupByBarcodeFromApi as before. Offline error path serves local (CO₂-only) rather than null.

- **iOS real-device gate:** Deferred to Phase 4 per 03-CONTEXT.md. No physical iPhone available; TestFlight setup is a Phase 4 prerequisite. iOS Simulator verified scanner screen renders correctly.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Macro data null for 97% of barcode lookups**
- **Found during:** Task 1 (real-device testing, pre-checkpoint)
- **Issue:** lookupByBarcodeWithCo2 returned CO₂-enriched results with null macros for 97% of products because off_ref.products stores macro data for only ~3% of products, but the repository returned local results early without checking for null nutrients
- **Fix:** Fall through to API when local result has null calories100g; merge API macros with local CO₂/confidence on success; serve local (CO₂-only) on offline error
- **Files modified:** `lib/data/repositories/food_catalog_repository.dart`
- **Verification:** Real-device scan shows full macros + CO₂ on FoodDetailBottomSheet
- **Committed in:** `a107179`

**2. [Rule 1 - Bug] Duplicate ATTACH DATABASE error in integration benchmark**
- **Found during:** Task 1 (benchmark run)
- **Issue:** Shared NativeDatabase executor across test wrappers caused duplicate ATTACH DATABASE call on second test, throwing OperationalError
- **Fix:** Refactored to shared AppDatabase instance in setUpAll/tearDownAll; guarded migration ATTACH with pragma_database_list idempotency check
- **Files modified:** `integration_test/food_search_benchmark_test.dart`, `lib/data/local/migrations/migration_strategy.dart`
- **Verification:** Benchmark runs without error; 94.6% coverage confirmed
- **Committed in:** `2a7559d`

**3. [Rule 1 - Bug] url_launcher missing from desktop platform plugin registrants**
- **Found during:** Task 1 (build/compile check)
- **Issue:** url_launcher added in Plan 03-04 was not registered in Linux, macOS, Windows generated plugin files
- **Fix:** Added url_launcher registration to all desktop platform generated_plugin_registrant files
- **Files modified:** `linux/flutter/generated_plugin_registrant.cc`, `linux/flutter/generated_plugins.cmake`, `macos/Flutter/GeneratedPluginRegistrant.swift`, `windows/flutter/generated_plugin_registrant.cc`, `windows/flutter/generated_plugins.cmake`
- **Verification:** Build succeeds on all platforms
- **Committed in:** `2a7559d`

---

**Total deviations:** 3 auto-fixed (all Rule 1 bugs)
**Impact on plan:** All fixes essential for correct barcode scan macro display and benchmark stability. No scope creep.

## Issues Encountered

- Macro regression was the main substantive issue: discovered during real-device testing when FoodDetailBottomSheet showed CO₂ correctly but macros were null. Root cause traced to off_ref.products nutrient sparsity (~3% coverage) combined with the 03-02 primary_category_tag population which made Step 2 match nearly all products. Fixed before human verification checkpoint.

## Known Stubs

None — all data sources are wired. CO₂ row and macros both show real data from either local DB or API.

## Threat Flags

None — no new network endpoints, auth paths, file access patterns, or schema changes introduced in this plan.

## Next Phase Readiness

- Phase 3 is COMPLETE. All 5 plans delivered.
- Requirements satisfied: LOG-03 (barcode scan, real Android device P0 verified), LOG-04 (no-match → custom food CTA), CO2-01 (confidence chip, CO₂e display), LEG-05 (MethodologyScreen + docs/CO2_METHODOLOGY.md)
- NFR-06(b) 94.6% CO₂ coverage exceeds the 90% threshold
- Phase 4 (Meal Logging Core) can begin immediately
- iOS real-device barcode verification is an open gate for Phase 4 (TestFlight setup needed)

## Self-Check: PASSED

- `a107179` exists: confirmed in git log
- `2a7559d` exists: confirmed in git log
- `lib/data/repositories/food_catalog_repository.dart` modified: confirmed in a107179 diff
- `integration_test/food_search_benchmark_test.dart` modified: confirmed in 2a7559d diff
- All 5 Phase 3 plans complete: 03-01 through 03-05 SUMMARYs exist

---
*Phase: 03-barcode-scanning-co-factor-table*
*Completed: 2026-07-22*

---
phase: 03-barcode-scanning-co-factor-table
plan: "03"
subsystem: barcode-scan
tags: [mobile_scanner, riverpod, go_router, barcode, camera, ux]
dependency_graph:
  requires: [03-01, 02-03, 02-04]
  provides: [BarcodeScanNotifier, BarcodeScanScreen, ScanFrameOverlay, CameraPermissionDeniedWidget, BarcodeScanNoMatchScreen, /barcode-scan route, /custom-food-stub route, FoodSearchScreen barcode icon]
  affects: [app_router.dart, food_search_screen.dart, food_catalog_repository.dart, off_api_client.dart, i_food_catalog_repository.dart]
tech_stack:
  added: [mobile_scanner 7.4.0, permission_handler 12.0.3, app_settings 8.0.3]
  patterns: [sealed-state-machine, ConsumerStatefulWidget, _processing-debounce-guard, CustomPainter-overlay, modalBottomSheet-future-tracking]
key_files:
  created:
    - lib/features/barcode_scan/providers/barcode_scan_notifier.dart
    - lib/features/barcode_scan/providers/barcode_scan_notifier.g.dart
    - lib/features/barcode_scan/screens/barcode_scan_screen.dart
    - lib/features/barcode_scan/screens/barcode_no_match_screen.dart
    - lib/features/barcode_scan/widgets/scan_frame_overlay.dart
    - lib/features/barcode_scan/widgets/camera_permission_denied_widget.dart
  modified:
    - pubspec.yaml
    - pubspec.lock
    - android/app/build.gradle.kts
    - lib/core/router/app_router.dart
    - lib/core/router/app_router.g.dart
    - lib/domain/repositories/i_food_catalog_repository.dart
    - lib/data/repositories/food_catalog_repository.dart
    - lib/data/remote/off_api_client.dart
    - lib/features/food_search/screens/food_search_screen.dart
decisions:
  - "BarcodeScanScreen uses _showItemSheet helper that calls showModalBottomSheet directly (not showFoodDetailSheet) so dismissal future can be tracked for camera resume"
  - "Sealed BarcodeScanState uses plain Dart sealed class (not Freezed) — state variants are simple records, codegen overhead not justified"
  - "lookupByBarcode does its own connectivity check in FoodCatalogRepository (Step 3 guard) in addition to BarcodeScanNotifier check (belt-and-suspenders)"
  - "errorBuilder in MobileScanner has 2-arg signature Widget Function(BuildContext, MobileScannerException) — no child parameter (mobile_scanner 7.4.0)"
  - "MobileScannerController.dispose() returns Future<void> — wrapped with unawaited() in State.dispose()"
  - "torchEnabled: false and autoStart: true are default values — removed per avoid_redundant_argument_values lint"
metrics:
  duration: "~14 minutes"
  completed: "2026-07-22"
  tasks: 2
  files_created: 6
  files_modified: 9
---

# Phase 3 Plan 03: Barcode Scanner UI Infrastructure Summary

Camera scanner UI shell delivering full-screen MobileScanner screen with _processing debounce guard, sealed BarcodeScanState machine, ScanFrameOverlay with corner-bracket CustomPainter, CameraPermissionDeniedWidget with Settings deep-link, BarcodeScanNoMatchScreen satisfying LOG-04, and barcode icon wired into FoodSearchScreen AppBar.

## Tasks Completed

| Task | Name | Commit | Key Files |
|------|------|--------|-----------|
| 1 | Dependencies, minSdk, BarcodeScanNotifier, router | ea19ec2 | pubspec.yaml, build.gradle.kts, barcode_scan_notifier.dart, app_router.dart, food_catalog_repository.dart, off_api_client.dart |
| 2 | FoodSearchScreen barcode icon | c3d034a | food_search_screen.dart |

## Decisions Made

1. **BarcodeScanScreen uses `_showItemSheet` helper** — `showFoodDetailSheet` wraps its future with `unawaited`, preventing dismissal tracking for camera resume. A dedicated `_BarcodeScanDetailSheet` widget inside `barcode_scan_screen.dart` calls `showModalBottomSheet` directly so `.then()` fires on dismissal.

2. **Sealed state uses plain Dart** — `BarcodeScanState` and its four variants (`Idle`, `Looking`, `Found`, `NoMatch`) are plain Dart sealed/final classes. Freezed was evaluated and rejected — state is simple, no need for `copyWith`, `toJson`, or `fromJson`.

3. **Two-layer connectivity check** — Both `BarcodeScanNotifier.lookupBarcode` and `FoodCatalogRepository.lookupByBarcode` perform a connectivity check before the API step. Belt-and-suspenders: notifier determines `wasNetworkError` for `BarcodeScanNoMatch`; repository gates the actual API call.

4. **MobileScanner 7.4.0 `errorBuilder` has 2-arg signature** — Plan spec cited a 3-arg `(ctx, ex, child)` signature. Actual API is `Widget Function(BuildContext, MobileScannerException)?`. Fixed automatically (Rule 1).

5. **`MobileScannerController.dispose()` returns `Future<void>`** — Must be wrapped with `unawaited()` in `State.dispose()` per `discarded_futures` lint. Plan doc implied synchronous `dispose()`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] MobileScanner errorBuilder has 2-arg signature (not 3-arg)**
- **Found during:** Task 2 `flutter analyze`
- **Issue:** Plan spec showed `errorBuilder: (ctx, ex, child) { ... return child ?? ... }` but mobile_scanner 7.4.0's actual API is `Widget Function(BuildContext, MobileScannerException)?` — no `child` parameter
- **Fix:** Changed to `(ctx, ex)` and replaced `child ?? const SizedBox.shrink()` with an error icon widget
- **Files modified:** `lib/features/barcode_scan/screens/barcode_scan_screen.dart`
- **Commit:** ea19ec2

**2. [Rule 1 - Bug] MobileScannerController.dispose() is async**
- **Found during:** Task 2 `flutter analyze`
- **Issue:** `_controller.dispose()` in `State.dispose()` discards the future (returns `Future<void>`) — `discarded_futures` lint error
- **Fix:** Wrapped with `unawaited(_controller.dispose())`
- **Files modified:** `lib/features/barcode_scan/screens/barcode_scan_screen.dart`
- **Commit:** ea19ec2

**3. [Rule 2 - Missing] `showFoodDetailSheet` return type prevents dismissal tracking**
- **Found during:** Task 2 implementation
- **Issue:** Plan spec said "Show FoodDetailBottomSheet via showModalBottomSheet — when sheet dismissed..." but `showFoodDetailSheet` is `void` (wraps future with `unawaited`). Cannot `.then()` on void.
- **Fix:** Created `_BarcodeScanDetailSheet` widget and `_showItemSheet` helper that calls `showModalBottomSheet` directly so camera resumes on sheet dismissal
- **Files modified:** `lib/features/barcode_scan/screens/barcode_scan_screen.dart`
- **Commit:** ea19ec2

## Known Stubs

- `BarcodeScanDetailSheet` CO₂ row shown when `co2e100g != null` — Plan 04 wires the CO₂ data; the stub sheet will display CO₂ once the data layer is activated
- `/custom-food-stub` route shows placeholder text — Phase 4 replaces with real custom food form (intentional stub per plan)
- `test/features/barcode_scan/barcode_scan_notifier_test.dart` — all 4 tests skip with "not yet implemented" (Wave 0 pattern, activated in Plan 04/05)

## Threat Surface Scan

No new threat surfaces beyond what was documented in the plan's `<threat_model>`:

| Flag | File | Description |
|------|------|-------------|
| Reviewed | `barcode_scan_screen.dart` | T-03-03-02: `_processing` guard implemented; `_controller.stop()` called before lookup |
| Reviewed | `barcode_scan_notifier.dart` | T-03-03-01: barcode passes through DAO `Variable.withString` parameterization |
| Reviewed | `food_catalog_repository.dart` | API call gated behind connectivity check (Step 3) |

## Self-Check: PASSED

- barcode_scan_notifier.dart: FOUND
- barcode_scan_screen.dart: FOUND
- barcode_no_match_screen.dart: FOUND
- scan_frame_overlay.dart: FOUND
- camera_permission_denied_widget.dart: FOUND
- Commit ea19ec2: FOUND
- Commit c3d034a: FOUND
- flutter analyze: No issues found
- flutter test test/: 76 passed, 18 skipped (all stubs), 0 failed

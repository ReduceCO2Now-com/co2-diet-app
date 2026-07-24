---
phase: 04-meal-logging-core-10s-target
plan: 08
subsystem: ui
tags: [flutter, riverpod, go_router, drift, custom-food, LOG-10, LOG-11]

# Dependency graph
requires:
  - phase: 04-meal-logging-core-10s-target (Plan 04-07)
    provides: UserFoodNotifier (saveCustomFood/saveOverride/revertOverride/findOverrideForFoodRef), generated as userFoodProvider
  - phase: 04-meal-logging-core-10s-target (Plan 04-06)
    provides: IFoodCatalogRepository.lookupByBarcode, FoodItem.resolvedFoodRef merge-key rule
provides:
  - CustomFoodFormScreen at /custom-food-stub — real create/edit/override form replacing the Phase 3 placeholder, owning the 5-variant route contract (blank, barcode, name, overrideOf+overrideOfSource, userFoodId)
  - ServingSizeEditor — reusable dynamic label+grams row list widget
  - MyFoodsScreen at /my-foods — alphabetical, client-side-filtered custom food list, reachable from Settings
  - FoodCatalogDao.getAvailableCo2Categories()/getCo2ForCategory() — category dropdown source + save-time CO2 resolution
affects: [04-09 (FoodDetailBottomSheet "Edit this food" wiring), 04-10 (search no-results "Add as custom food" link)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Route-param-driven form prefill: CustomFoodFormScreen resolves 5 mutually-exclusive query-param combinations in a single _initialize() async method, gated behind a _loading flag"
    - "Save-time CO2 resolution: form stores no computed co2e100g until Save is tapped — category mode resolves it fresh via FoodCatalogDao.getCo2ForCategory(selectedCategory) at that moment, avoiding stale/duplicated lookup state"

key-files:
  created:
    - lib/features/my_foods/screens/custom_food_form_screen.dart
    - lib/features/my_foods/widgets/serving_size_editor.dart
    - lib/features/my_foods/screens/my_foods_screen.dart
  modified:
    - lib/core/router/app_router.dart
    - lib/features/settings/screens/settings_screen.dart
    - lib/data/local/daos/food_catalog_dao.dart
    - test/features/my_foods/custom_food_form_test.dart

key-decisions:
  - "CustomFoodFormScreen takes barcode/name/overrideOf/overrideOfSource/userFoodId as constructor params (not GoRouterState reads inside build) — router builder passes state.uri.queryParameters through, keeping the screen unit/widget-testable without a GoRouter in the test tree"
  - "Revert-to-original visibility gated purely on _overrideOfRef != null (set whenever either an existing override row or a fresh overrideOf param resolves) — the actual delete-on-tap only fires when a concrete userFoodId/existing id is known; tapping Revert on a not-yet-saved override just pops"
  - "co2MethodologyVersion left null on category_estimate saves — no methodology-version constant exists anywhere in the codebase yet (confirmed via repo-wide search); this is consistent with the field's current all-null state across every other plan, not a Plan 04-08 regression"

requirements-completed: [LOG-06, LOG-10, LOG-11]

# Metrics
duration: ~25min
completed: 2026-07-24
---

# Phase 4 Plan 08: Custom Food Form + My Foods List Summary

**Custom-food/override authoring form (name+calories required, everything else optional) and an alphabetical My Foods list reachable only from Settings, closing the Phase 2/3 "Add as custom food" dead ends.**

## Performance

- **Duration:** ~25 min
- **Completed:** 2026-07-24
- **Tasks:** 2/2 completed
- **Files modified:** 7 (3 created, 4 modified)

## Accomplishments

- `/custom-food-stub` now builds `CustomFoodFormScreen` for all five route-contract variants (blank, barcode, name, override, userFoodId edit), replacing the Phase 3 placeholder text while leaving `BarcodeScanNoMatchScreen`'s existing `?barcode=...` navigation untouched.
- Save button correctly gates on name+calories only; every other field (brand, category, macros, CO2, barcode, serving sizes) is optional per LOG-10.
- CO2 input toggle: category mode previews a `ConfidenceChip(band: 'medium')` and resolves the actual value from `off_ref.co2_factors` at save time; manual mode shows a "user-provided" labeled field with no chip, matching the "no false-precision" invariant.
- "Revert to original" renders only when editing an override (LOG-11), never for a plain custom food.
- `MyFoodsScreen` (`/my-foods`) added: alphabetical, client-side-filtered list with an honest empty state, "Override" badge on override rows, and a "+ Add Custom Food" action. Reachable only from Settings, not from food search, per CONTEXT.md.

## Task Commits

1. **Task 1: Custom Food Form screen + serving size editor + route** - `5dea41b` (feat)
2. **Task 2: My Foods list screen + navigation entry point** - `834b0d2` (feat)

**Plan metadata:** (this commit, `docs(04-08): complete plan`)

## Files Created/Modified

- `lib/features/my_foods/screens/custom_food_form_screen.dart` - Create/edit/override form; resolves all 5 route-contract variants in `_initialize()`; resolves CO2 estimate at save time
- `lib/features/my_foods/widgets/serving_size_editor.dart` - Dynamic label+grams row list with add/remove, keyed rows for testability
- `lib/features/my_foods/screens/my_foods_screen.dart` - Alphabetical My Foods list, client-side filter, empty state, row tap → edit form
- `lib/core/router/app_router.dart` - `/custom-food-stub` now builds `CustomFoodFormScreen`; new `/my-foods` top-level route
- `lib/features/settings/screens/settings_screen.dart` - New "My Foods" `ListTile` between "Search foods" and "Open source licenses"
- `lib/data/local/daos/food_catalog_dao.dart` - Added `getAvailableCo2Categories()` and `getCo2ForCategory()`, both guarded by the existing `offRefPath == null` unit-test-isolation convention
- `test/features/my_foods/custom_food_form_test.dart` - 4 widget tests replacing the Wave 0 skip stub, 0 skips

## Decisions Made

- `CustomFoodFormScreen` reads route params via constructor fields (router builder passes `state.uri.queryParameters[...]` through) rather than `GoRouterState.of(context)` inside `build()` — keeps the screen directly widget-testable with a plain `MaterialApp` host, no `GoRouter`/mock-route setup needed in tests.
- Revert-button visibility is driven by `_overrideOfRef != null` (set by either an existing override row's `overrideOfRef` or a fresh `overrideOf` route param); the button's tap handler only calls `revertOverride` when a concrete id (`widget.userFoodId` or a resolved existing row id) exists, otherwise it just pops — this covers both "editing a saved override" and "about to save a first-time override but changed your mind" without a crash or no-op repository call.
- Left `co2MethodologyVersion` null for category-estimate saves: no methodology-version constant/provider exists anywhere in the codebase yet (verified via repo-wide search across `lib/`), so this mirrors the current all-null state of that field everywhere else rather than inventing a value not backed by an actual methodology source.
- Widget tests override `foodCatalogDaoProvider`, `foodCatalogRepositoryProvider`, and `userFoodRepositoryProvider` unconditionally (with unstubbed default mocks when unused) — Riverpod forbids adding/removing overrides across `pumpWidget` calls that reuse the same `ProviderScope`/tester, so all three tests keep an identical override-list shape.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking issue] Widget-test `pumpWidget` reuse with a differing override count**
- **Found during:** Task 1 (widget test authoring, "Revert to original" test)
- **Issue:** The revert-visibility test called `tester.pumpWidget` twice in one test (blank form, then override form) with different `ProviderScope` override lists (1 vs 3 entries) — Riverpod's `ProviderContainer.updateOverrides` asserts the override count cannot change across an update, causing a hard crash unrelated to the screen under test.
- **Fix:** `_wrap()` now always supplies all three provider overrides (defaulting to unstubbed mocks when a test doesn't need them), keeping the override-list shape identical across both `pumpWidget` calls in that test.
- **Files modified:** `test/features/my_foods/custom_food_form_test.dart`
- **Verification:** `flutter test test/features/my_foods/custom_food_form_test.dart` — all 4 tests pass
- **Committed in:** `5dea41b` (part of Task 1 commit)

**2. [Rule 1 - Bug] Second `pumpWidget` call reconciled into the same State instead of remounting**
- **Found during:** Task 1 (widget test authoring, "Revert to original" test)
- **Issue:** Flutter Test's `pumpWidget` reconciles a widget with the same runtime type/position via `didUpdateWidget` rather than a fresh `initState` — the second pump (with `overrideOf` set) never re-ran `_initialize()`, so the resolved override never appeared.
- **Fix:** Gave the second `CustomFoodFormScreen` instance a distinct `Key`, forcing Flutter to unmount/remount (fresh `initState`) rather than reconcile in place.
- **Files modified:** `test/features/my_foods/custom_food_form_test.dart`
- **Verification:** `flutter test test/features/my_foods/custom_food_form_test.dart` — "Revert to original" test passes
- **Committed in:** `5dea41b` (part of Task 1 commit)

**3. [Rule 1 - Bug] Off-screen tap targets in scrollable form during widget tests**
- **Found during:** Task 1 (widget test authoring, serving-size and manual-CO2 tests)
- **Issue:** "+ Add serving size" and the "Enter manually" segment sit below the default 800×600 test viewport inside the form's `SingleChildScrollView`; `tester.tap()` computed an offset outside the render tree bounds and failed the hit test.
- **Fix:** Added `tester.ensureVisible(finder)` + a settle pump before each affected `tap()` call.
- **Files modified:** `test/features/my_foods/custom_food_form_test.dart`
- **Verification:** `flutter test test/features/my_foods/custom_food_form_test.dart` — all 4 tests pass
- **Committed in:** `5dea41b` (part of Task 1 commit)

No deviations required user input — all three were mechanical test-infrastructure fixes with no production-code behavior change.

## Issues Encountered

None beyond the auto-fixed items above.

## User Setup Required

None.

## Next Steps

- Plan 04-09 wires `FoodDetailBottomSheet`'s "Edit this food" action to `/custom-food-stub?overrideOf=...&overrideOfSource=...`, using `UserFoodNotifier.findOverrideForFoodRef` first to redirect to `?userFoodId=...` when an override already exists.
- Plan 04-10 wires the search no-results screen's "Add as custom food" link to `/custom-food-stub?name=...`.

## Self-Check: PASSED

All created files verified present on disk; both task commit hashes (`5dea41b`, `834b0d2`) verified present in git log.

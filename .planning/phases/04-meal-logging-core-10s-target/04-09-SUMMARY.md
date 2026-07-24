---
phase: 04-meal-logging-core-10s-target
plan: 09
subsystem: ui
tags: [flutter, riverpod, food-detail-sheet, portion-form, LOG-05, LOG-06, LOG-08, LOG-11, LOG-13]

# Dependency graph
requires:
  - phase: 04-meal-logging-core-10s-target (Plan 04-03)
    provides: detectMealSlotForTime (shared time-of-day auto-detect), MealSlot/PortionUnit/ServingSize entities
  - phase: 04-meal-logging-core-10s-target (Plan 04-06)
    provides: FoodItem.resolvedFoodRef merge-key rule
  - phase: 04-meal-logging-core-10s-target (Plan 04-07)
    provides: MealEntryNotifier.logFood/undoMerge/deleteEntry, FavoriteNotifier.toggle/isFavorite, UserFoodNotifier.findOverrideForFoodRef (generated as mealEntryProvider/favoriteProvider/userFoodProvider)
  - phase: 04-meal-logging-core-10s-target (Plan 04-08)
    provides: /custom-food-stub route contract (overrideOf/overrideOfSource/userFoodId query params)
provides:
  - "showFoodDetailSheet(context, item, {initialSlot, initialQuantity, initialUnit}) -> Future<void> — single shared sheet for search AND barcode-scan entry points, real dismissal Future, optional pre-fill contract for Plans 04-10/04-11"
  - "PortionSlotForm — meal-slot picker + quantity/unit input + live-scaled macro/CO2 table + Log button (LOG-05/06/13), embedded in _FoodDetailContent"
  - "_FoodDetailContent favorite star (FavoriteNotifier) + Edit this food action (redirects to existing override via userFoodId, or creates a new one via overrideOf/overrideOfSource)"
affects: [04-10, 04-11]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Single shared bottom-sheet content widget for two entry points (search tap, barcode-scan result) — no per-entry-point widget divergence"
    - "ref.watch(provider) with an intentionally unused value, purely to keep an autoDispose AsyncNotifier alive across an async mutation's post-await ref.invalidateSelf() call"
    - "Undo/Retry SnackBarAction callbacks read through a captured ProviderContainer (ProviderScope.containerOf(context, listen: false)) rather than the initiating ConsumerState's ref, since the sheet (and its state) is already disposed by the time the snackbar action fires"
    - "Free-text ServingSize.label -> PortionUnit inference via keyword match (cup/piece/slice), falling back to PortionUnit.portion — ServingSize has no explicit unit field (CONTEXT.md's dynamic label+grams list, not fixed unit slots)"

key-files:
  created:
    - lib/features/food_search/widgets/portion_slot_form.dart
  modified:
    - lib/features/food_search/widgets/food_detail_sheet.dart
    - lib/features/barcode_scan/screens/barcode_scan_screen.dart
    - test/features/food_search/portion_slot_form_test.dart

key-decisions:
  - "showFoodDetailSheet returns the real Future<void> from showModalBottomSheet (unawaited() swallow removed) — the search screen's onTap simply doesn't await it (Dart permits a Future-returning callback where VoidCallback is expected); the barcode scanner awaits it directly, replacing its own duplicate showModalBottomSheet call"
  - "_BarcodeScanDetailSheet and its private _MacroRow deleted entirely — both entry points now render the same _FoodDetailContent, restoring Phase 3's original no-divergence intent"
  - "'Edit this food' resolves any existing override via UserFoodNotifier.findOverrideForFoodRef first: redirects to /custom-food-stub?userFoodId=<id> when one exists, else /custom-food-stub?overrideOf=&overrideOfSource= to create a first override — avoids creating a second, duplicate override row on repeat edits (flagged as a follow-up in 04-08-SUMMARY.md, implemented here)"
  - "ServingSize -> PortionUnit inference: label containing 'cup' -> PortionUnit.cup, 'piece'/'slice' -> PortionUnit.piece, anything else -> PortionUnit.portion (the app's generic user-configured-serving catch-all) — a necessary interpretation since ServingSize (Plan 04-02/04-03) stores only label+grams, no unit tag"
  - "Quantity-chip selection state is computed at build time (unit == _selectedUnit && parsed quantity == chip.quantity) rather than tracked as separate state — keeps manual field edits and chip taps in sync automatically without a redundant _selectedChipLabel field"
  - "Fixed two Riverpod autoDispose pitfalls this new call path exposed: (1) mealEntryProvider has no keepAlive and nothing in Phase 4 yet watches it (PlaceholderDashboardScreen is still a placeholder), so without ref.watch(mealEntryProvider) in PortionSlotForm's build(), the notifier could be disposed mid-flight before logFood's post-await ref.invalidateSelf() runs, throwing 'Cannot use the Ref ... after it has been disposed'; (2) the Undo SnackBarAction fires after the sheet (and PortionSlotForm's State) is already disposed, so its callback reads mealEntryProvider.notifier through a captured ProviderContainer instead of the State's own (by-then-invalid) ref"

requirements-completed: [LOG-05, LOG-06, LOG-08, LOG-11, LOG-13]

# Metrics
duration: ~21min
completed: 2026-07-24
---

# Phase 4 Plan 09: Sheet Reconciliation + Portion/Slot Logging Form Summary

**Deleted the duplicated `_BarcodeScanDetailSheet`, restored a single shared `_FoodDetailContent` for search and scan, and built `PortionSlotForm` — the meal-slot/quantity/unit picker with locale-aware defaults, live-scaled macros, and the "Log this food" action that is the core `<10s` logging UI.**

## Performance

- **Duration:** ~21 min
- **Started:** 2026-07-24T12:20Z (Task 1 commit)
- **Completed:** 2026-07-24T12:42Z (Task 2 commit)
- **Tasks:** 2/2 completed
- **Files modified:** 4 (1 created, 3 modified)

## Accomplishments

- `showFoodDetailSheet` now returns the real `Future<void>` from `showModalBottomSheet` and accepts optional `initialSlot`/`initialQuantity`/`initialUnit` pre-fill overrides for Plans 04-10/04-11's edit-prefill flow.
- `_BarcodeScanDetailSheet` and its private `_MacroRow` deleted from `barcode_scan_screen.dart` — `BarcodeScanScreen._showItemSheet` now awaits the shared `showFoodDetailSheet` helper directly, restoring Phase 3's "no behavioral difference between scan and search sheets" intent.
- `_FoodDetailContent` converted to `ConsumerStatefulWidget`: favorite star (`FavoriteNotifier.toggle`/`isFavorite`) and an "Edit this food" action that redirects to an existing override (`?userFoodId=`) when one already exists, else creates a new one (`?overrideOf=&overrideOfSource=`).
- `PortionSlotForm`: time-of-day auto-detected (overridable) meal-slot `SegmentedButton`, quantity chips sourced from `UserFood.quickServingSizes` (generic 100g/200g/Custom fallback otherwise), an editable quantity field + unit dropdown gated to g/ml unless a configured serving size backs piece/cup/portion, a live-scaled macro/CO₂ table (`snapshot * gramsEquivalent / 100`), and a disabled-until-valid "Log this food" `FilledButton` with success (Added to `<Slot>` + Undo) and failure (Retry) snackbars.
- LOG-06 locale-aware default: an imperial-locale device with a configured non-metric quick serving size defaults to that chip; a metric-locale device (or any device with no configured non-metric serving) always keeps the gram default — applied once via `didChangeDependencies`, entirely bypassed when `initialQuantity`/`initialUnit` are supplied.
- Every constructed `foodRef` (Log, Favorite, Edit-this-food) uses `FoodItem.resolvedFoodRef` — verified directly in a test.
- `portion_slot_form_test.dart`: 10 widget tests, 0 skips, covering all `<behavior>` cases plus the edit-prefill override tests.

## Task Commits

Each task was committed atomically:

1. **Task 1: Sheet reconciliation — single shared sheet content, pre-fill contract** - `33a4a6a` (feat)
2. **Task 2: PortionSlotForm — meal slot, quantity/unit, locale-aware defaults, live scaling, Log button** - `818f273` (feat)

**Plan metadata:** (this commit, made immediately after this SUMMARY)

## Files Created/Modified

- `lib/features/food_search/widgets/portion_slot_form.dart` - `PortionSlotForm` widget: slot/quantity/unit state, chip-derived + locale-aware defaults, live-scaled macro table, Log/Undo/Retry flow (Task 2)
- `lib/features/food_search/widgets/food_detail_sheet.dart` - `showFoodDetailSheet` signature fix + pre-fill params; `_FoodDetailContent` converted to `ConsumerStatefulWidget` hosting `PortionSlotForm`, favorite star, "Edit this food" (Task 1)
- `lib/features/barcode_scan/screens/barcode_scan_screen.dart` - Deleted `_BarcodeScanDetailSheet`/`_MacroRow`; `_showItemSheet` now awaits the shared `showFoodDetailSheet` helper (Task 1)
- `test/features/food_search/portion_slot_form_test.dart` - 10 widget tests replacing the Wave 0 skip stub, 0 skips (Task 2)

## Decisions Made

See `key-decisions` in frontmatter — summarized: sheet-reconciliation fix (real `Future<void>`, `_BarcodeScanDetailSheet` deletion), "Edit this food" override-redirect logic, `ServingSize`-label-to-`PortionUnit` inference, computed (not stored) chip-selection state, and the two Riverpod autoDispose fixes (`ref.watch(mealEntryProvider)` keep-alive + captured-`ProviderContainer` Undo callback).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `mealEntryProvider` autoDispose race crashing `logFood`**
- **Found during:** Task 2 (widget test authoring — "logging uses FoodItem.resolvedFoodRef" test)
- **Issue:** `MealEntryNotifier` is a plain `@riverpod` (autoDispose) class. Nothing in Phase 4 yet establishes a persistent `ref.watch(mealEntryProvider)` (the real Dashboard that will do this doesn't exist until Phase 5). `PortionSlotForm` only ever called `ref.read(mealEntryProvider.notifier).logFood(draft)`, a one-off read with no active listener — Riverpod is free to dispose the provider as soon as the synchronous frame ends, and `MealEntryNotifier.logFood`'s `ref.invalidateSelf()` (called after the repository write's `await`) then throws `Bad state: Cannot use the Ref of mealEntryProvider after it has been disposed.` This reproduced deterministically in the widget test and would affect real usage identically, since Phase 4 currently has no other watcher of this provider.
- **Fix:** Added `ref.watch(mealEntryProvider)` (value intentionally unused) at the top of `PortionSlotForm.build()`, establishing a live listener for the widget's full mounted lifetime — covers the `_handleLogPressed` await window.
- **Files modified:** `lib/features/food_search/widgets/portion_slot_form.dart`
- **Verification:** `flutter test test/features/food_search/portion_slot_form_test.dart` — "logging uses FoodItem.resolvedFoodRef" now passes (previously hit the error/Retry snackbar branch instead of the success/Undo branch)
- **Committed in:** `818f273` (Task 2 commit)

**2. [Rule 1 - Bug] Undo `SnackBarAction` reading a disposed `ConsumerState.ref`**
- **Found during:** Task 2 (same test, same debugging session)
- **Issue:** The original Undo callback closed over `ref` (the `ConsumerState`'s own `WidgetRef`) to call `undoMerge`/`deleteEntry` after the user taps "Undo". By the time Undo can be tapped, `PortionSlotForm`'s State is already disposed (`Navigator.pop()` already ran to dismiss the sheet) — using a disposed `ConsumerState`'s `ref` throws.
- **Fix:** Captured `final container = ProviderScope.containerOf(context, listen: false);` before popping; the Undo callback now reads `container.read(mealEntryProvider.notifier)` instead of the State's `ref`, remaining valid after the widget disposes.
- **Files modified:** `lib/features/food_search/widgets/portion_slot_form.dart`
- **Verification:** Manual code-path review (no automated test taps "Undo" itself — verified the button exists and is wired; the underlying `container.read` pattern is a standard Riverpod-documented technique for post-dispose callback safety)
- **Committed in:** `818f273` (Task 2 commit)

**3. [Rule 2 - Missing critical] "Edit this food" duplicate-override prevention**
- **Found during:** Task 1 (implementing `_editThisFood`)
- **Issue:** The plan's literal action text always builds `/custom-food-stub?overrideOf=&overrideOfSource=`. 04-08-SUMMARY.md's "Next Steps" section explicitly flagged that this plan should use `UserFoodNotifier.findOverrideForFoodRef` first and redirect to `?userFoodId=` when an override already exists, to avoid creating a second duplicate override row on repeat edits.
- **Fix:** `_FoodDetailContent` resolves the existing override in `initState` and `_editThisFood` branches on its presence.
- **Files modified:** `lib/features/food_search/widgets/food_detail_sheet.dart`
- **Verification:** `flutter analyze` clean; manual code review against `CustomFoodFormScreen`'s documented route contract (Plan 04-08)
- **Committed in:** `33a4a6a` (Task 1 commit)

---

**Total deviations:** 3 auto-fixed (2 Rule 1 bugs, 1 Rule 2 missing-critical addition)
**Impact on plan:** All three were necessary for correctness (the two Riverpod fixes prevent a real crash in the core Log flow; the override-redirect prevents duplicate override rows). No scope creep — all changes stayed within this plan's declared files.

## Issues Encountered

- Widget-test-only: `MaterialApp(locale: ...)` without an explicit `supportedLocales` list silently ignores the requested locale and falls back to the framework default (`en_US`), which broke the "metric locale keeps the gram default" test (it was actually running under an imperial-resolved locale). Fixed by adding `supportedLocales: [Locale('en','DE'), Locale('en','US')]` to the test wrapper. No production code affected.
- Widget-test-only: the first version of the "logging..." test called `Navigator.of(context).pop()` from a `PortionSlotForm` placed directly as `MaterialApp.home` (no underlying route to pop back to), silently failing to render the snackbar. Fixed by wrapping that test in a real `showModalBottomSheet` flow (`_wrapAsModalSheet`), matching production usage.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `showFoodDetailSheet`'s `initialSlot`/`initialQuantity`/`initialUnit` contract and `PortionSlotForm`'s matching constructor are ready for Plan 04-10 (Recent/Favorites edit icon) and Plan 04-11 (dashboard edit) to consume without modifying this plan's files or depending on each other, per this plan's explicit design goal.
- `_FoodDetailContent`'s favorite star and "Edit this food" action are live on both entry points (search and scan).
- No blockers for Phase 4's remaining UI plans.

---
*Phase: 04-meal-logging-core-10s-target*
*Completed: 2026-07-24*

## Self-Check: PASSED

All created/modified files verified present on disk; both task commit hashes (`33a4a6a`, `818f273`) verified present in git log.

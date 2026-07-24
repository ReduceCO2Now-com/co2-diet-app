---
phase: 04-meal-logging-core-10s-target
plan: 07
subsystem: state-management
tags: [riverpod, riverpod_generator, asyncnotifier, meal-logging, favorites, my-foods]

# Dependency graph
requires:
  - phase: 04-05
    provides: IMealEntryRepository (MealEntryRepository) — logOrMerge/getEntriesForToday/getRecent/editEntry/deleteEntry/restoreEntry/duplicateEntry/undoMergeDelta/isFavorite/toggleFavorite/getFavorites/touchFavoriteUsage
  - phase: 04-06
    provides: FoodItem.resolvedFoodRef merge-key rule + FoodCatalogDao override precedence (LOG-11), consumed transitively by the repository layer these notifiers sit on
provides:
  - MealEntryNotifier — today's-entries AsyncNotifier with logFood/undoMerge/editEntry/deleteEntry/undoDelete/duplicateEntry/getRecent (the UI-facing mutation surface for LOG-05/07/09)
  - FavoriteNotifier — favorites-list AsyncNotifier with toggle/isFavorite/logFromFavorite (LOG-08 one-tap-log)
  - UserFoodNotifier — My Foods list AsyncNotifier with saveCustomFood/saveOverride/revertOverride/findOverrideForFoodRef (LOG-10/LOG-11)
affects: [04-08, 04-09, 04-10, 04-11]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "@riverpod class AsyncNotifier: build() reads the repository; every mutation method calls the repository then ref.invalidateSelf()"
    - "MealLogResult value object (defined in meal_entry_notifier.dart) carries wasMerge/loggedDelta so the UI's Undo snackbar can pick deleteEntry vs. undoMerge without re-deriving merge state"
    - "Single-slot pending-undo-delete (_pendingUndoDelete) — no unbounded undo history, matches CONTEXT.md's single-level Undo pattern"
    - "getRecent()/isFavorite()/findOverrideForFoodRef() are plain pass-through reads outside the build()/invalidateSelf() cycle — documented in each notifier as deliberately not part of watched state"
    - "logFromFavorite() cross-notifier composition: FavoriteNotifier reads ref.read(mealEntryProvider.notifier).logFood(draft) so 'one tap = instant log' write logic lives in exactly one place"

key-files:
  created:
    - lib/features/meal_logging/providers/meal_entry_notifier.dart
    - lib/features/food_search/providers/favorite_notifier.dart
    - lib/features/my_foods/providers/user_food_notifier.dart
  modified:
    - test/features/meal_logging/meal_entry_notifier_test.dart
    - test/features/food_search/favorites_test.dart
    - test/features/my_foods/user_food_notifier_test.dart

key-decisions:
  - "UserFoodNotifier.build() is parameterless (returns the full unfiltered alphabetical list), not a @riverpod family taking {String? filter} — keeps the generated provider name predictable (userFoodProvider); My Foods screen (Plan 04-08) filters client-side with a local TextEditingController, per the plan's explicitly sanctioned alternative"
  - "FavoriteNotifier.logFromFavorite delegates the actual persistence write to MealEntryNotifier.logFood via ref.read(mealEntryProvider.notifier) rather than calling the repository directly a second time — avoids duplicating merge/undo-result logic across two notifiers"
  - "generated provider names strip the Notifier suffix (mealEntryProvider, favoriteProvider, userFoodProvider) — consistent with the Phase 02-06/01-05 @riverpod class codegen convention already established in this codebase"

patterns-established:
  - "Cross-notifier composition via ref.read(otherNotifierProvider.notifier) for a single-source-of-truth write path (logFromFavorite -> MealEntryNotifier.logFood)"

requirements-completed: [LOG-05, LOG-07, LOG-08, LOG-09, LOG-10, LOG-11]

# Metrics
duration: ~35min (Task 1 recovered/verified + Task 2 executed)
completed: 2026-07-24
---

# Phase 4 Plan 07: Meal-Logging/Favorites/My-Foods Notifiers Summary

**Three `@riverpod class` AsyncNotifiers (MealEntryNotifier, FavoriteNotifier, UserFoodNotifier) giving the UI layer its exclusive mutation surface for logging, one-tap favorites, and custom-food/override management — no widget touches the repository or DAO layers directly.**

## Performance

- **Duration:** ~35 min total (Task 1 was completed and tested by a prior executor session that hit its API limit before committing; the orchestrator verified and committed it, then this session executed Task 2)
- **Started:** 2026-07-24T11:42:00+02:00 (Task 1 commit time, recovered)
- **Completed:** 2026-07-24T11:48:05+02:00 (Task 2 commit time)
- **Tasks:** 2 (both complete)
- **Files modified:** 10 (3 notifier files + 3 generated `.g.dart` files + 3 test files touched across both tasks, plus this SUMMARY)

## Accomplishments

- `MealEntryNotifier` (Task 1): today's-entries AsyncNotifier with a `MealLogResult` value object exposing `wasMerge`/`loggedDelta` so the UI's Undo snackbar can distinguish "undo a fresh insert" (`deleteEntry`) from "undo a merge" (`undoMerge`); single-slot `_pendingUndoDelete` restore path; `getRecent()` kept deliberately outside the watched `build()` state
- `FavoriteNotifier` (Task 2): favorites-list AsyncNotifier with `toggle()`, `isFavorite()`, and `logFromFavorite()` — the one-tap-log path that builds a `MealEntry` draft from a favorite's snapshot + remembered `lastQuantity`/`lastUnit` (100g/g fallback), delegates the write to `MealEntryNotifier.logFood`, and updates the favorite's usage memory via `touchFavoriteUsage`
- `UserFoodNotifier` (Task 2): My Foods list AsyncNotifier with `saveCustomFood`/`saveOverride`/`revertOverride` (each invalidates the list) and a pass-through `findOverrideForFoodRef` for the "Edit this food" pre-fill flow
- All three notifier test files filled in from Wave 0 skip stubs to real `ProviderContainer` + mocktail unit tests — 0 skips remaining across all three

## Task Commits

Each task was committed atomically:

1. **Task 1: MealEntryNotifier** - `d328fcf` (feat) — recovered from an interrupted prior session; orchestrator verified (flutter analyze clean, 9/9 tests passing, full suite green) before committing
2. **Task 2: FavoriteNotifier + UserFoodNotifier** - `f071300` (feat)

**Plan metadata:** (this commit, made immediately after this SUMMARY)

## Files Created/Modified

- `lib/features/meal_logging/providers/meal_entry_notifier.dart` - `MealEntryNotifier` + `MealLogResult` value object (Task 1)
- `lib/features/food_search/providers/favorite_notifier.dart` - `FavoriteNotifier`: `build`/`toggle`/`isFavorite`/`logFromFavorite` (Task 2)
- `lib/features/my_foods/providers/user_food_notifier.dart` - `UserFoodNotifier`: `build`/`saveCustomFood`/`saveOverride`/`revertOverride`/`findOverrideForFoodRef` (Task 2)
- `test/features/meal_logging/meal_entry_notifier_test.dart` - 9 tests covering build/logFood (fresh + merge)/undoMerge/editEntry/deleteEntry+undoDelete/duplicateEntry/getRecent (Task 1)
- `test/features/food_search/favorites_test.dart` - 5 tests covering build/toggle/isFavorite/logFromFavorite (last-used quantity + 100g fallback) (Task 2)
- `test/features/my_foods/user_food_notifier_test.dart` - 5 tests covering build/saveCustomFood/saveOverride/revertOverride/findOverrideForFoodRef (Task 2)

## Decisions Made

- `UserFoodNotifier.build()` kept parameterless (no `@riverpod` family `{String? filter}` parameter) — the plan explicitly sanctioned this alternative to keep the generated provider name (`userFoodProvider`) predictable for `ref.watch` call sites; the My Foods screen (Plan 04-08) is expected to filter the returned list client-side with a local `TextEditingController`
- `FavoriteNotifier.logFromFavorite` composes with `MealEntryNotifier` via `ref.read(mealEntryProvider.notifier).logFood(draft)` rather than re-implementing the merge/persist logic against `IMealEntryRepository` directly — keeps "one tap = instant log" in exactly one code path, as directed by the plan
- Confirmed (via generated `.g.dart` inspection) that `@riverpod class` strips the `Notifier` suffix from the generated provider variable name for all three notifiers: `mealEntryProvider`, `favoriteProvider`, `userFoodProvider` — consistent with the `FoodSearchNotifier` → `foodSearchProvider` precedent from Phase 02-06

## Deviations from Plan

None — plan executed exactly as written, including the explicitly-sanctioned `UserFoodNotifier.build()` parameterless alternative (not a deviation; it's a plan-authorized choice, not an unplanned change).

## Issues Encountered

- Test-authoring only: an initial version of `favorites_test.dart`'s one-tap-log tests hit a mocktail `registerFallbackValue` gap for `PortionUnit` (used via `any()`/`captureAny()` on `MealEntry.unit`), which also left mocktail's internal matcher-stack in a bad state that cascaded into an unrelated second test failure. Fixed by adding `registerFallbackValue(PortionUnit.g)` to `setUpAll()`; both tests then passed cleanly. No production code was affected — this was purely a test-harness gap, not a Rule 1-4 deviation against the plan's implementation.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- All three notifiers (`MealEntryNotifier`, `FavoriteNotifier`, `UserFoodNotifier`) are ready for Plans 04-08 through 04-11 to consume via `ref.watch`/`ref.read(...).notifier` — no widget code has touched `IMealEntryRepository`/`IUserFoodRepository` directly, preserving the plan's stated layering boundary.
- `MealLogResult` (in `meal_entry_notifier.dart`) is the shared contract both the dashboard's "Log this food" sheet and Favorites' one-tap-log path will use to drive the Undo snackbar — both already return it consistently (`MealEntryNotifier.logFood` and `FavoriteNotifier.logFromFavorite`).
- No blockers for Phase 4's remaining UI plans.

---
*Phase: 04-meal-logging-core-10s-target*
*Completed: 2026-07-24*

## Self-Check: PASSED

All created files verified present on disk; both task commits (`d328fcf`, `f071300`) verified present in git history.

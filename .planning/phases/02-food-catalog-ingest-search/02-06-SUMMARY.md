---
phase: 02-food-catalog-ingest-search
plan: "06"
subsystem: ui
tags: [flutter, riverpod, go_router, shimmer, food_search, bottom_sheet, dark_mode]

# Dependency graph
requires:
  - phase: 02-05
    provides: FoodSearchState sealed class and FoodSearchNotifier AsyncNotifier
  - phase: 02-04
    provides: FoodCatalogRepository, OffApiClient, DI providers
  - phase: 02-03
    provides: FoodItem domain entity, FoodCatalogDao

provides:
  - FoodSearchScreen (ConsumerStatefulWidget, auto-focused TextField in AppBar)
  - SearchPromptWidget, NoResultsWidget (3 variants), ApiLoadingBanner (shimmer)
  - FoodResultRow (compact list row with name/brand/calories)
  - FoodDetailSheet (read-only macros per 100g, CO2 and Log stubs for Phase 3/4)
  - /food-search route registered in app_router.dart as top-level GoRoute
  - Settings screen "Search foods" tile navigating to /food-search

affects: [04-meal-logging, 03-barcode-scanning, 06-accessibility]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - ConsumerStatefulWidget with TextEditingController + FocusNode lifecycle
    - AsyncValue.when() for Riverpod state rendering with explicit loading/error arms
    - showModalBottomSheet() as read-only detail surface (no DraggableScrollableSheet needed for Phase 2)
    - Dart 3 exhaustive switch on sealed FoodSearchState variants in _buildBody
    - Top-level GoRoute before StatefulShellRoute to cover bottom nav bar

key-files:
  created:
    - lib/features/food_search/screens/food_search_screen.dart
    - lib/features/food_search/widgets/search_prompt_widget.dart
    - lib/features/food_search/widgets/no_results_widget.dart
    - lib/features/food_search/widgets/api_loading_banner.dart
    - lib/features/food_search/widgets/food_result_row.dart
    - lib/features/food_search/widgets/food_detail_sheet.dart
  modified:
    - lib/core/router/app_router.dart
    - lib/features/settings/screens/settings_screen.dart

key-decisions:
  - "foodSearchProvider is the generated name (not foodSearchNotifierProvider) — @riverpod on class FoodSearchNotifier strips the Notifier suffix for the provider variable"
  - "No shimmer for local FTS5 path — only ApiLoadingBanner is shown during AsyncLoading (API fallback only); locked in CONTEXT.md"
  - "CO2 row hidden in FoodDetailSheet — Phase 3 adds CO2 factor table; TODO(phase-3) comment left as placeholder"
  - "Log button deferred — TODO(phase-4) comment in FoodDetailSheet; Phase 4 adds meal logging flow"
  - "go_router import added to settings_screen.dart for context.push('/food-search')"

patterns-established:
  - "Pattern: FoodSearchScreen uses ref.read(provider.notifier) in build() (not initState) for notifier access"
  - "Pattern: onChanged rebuilds widget via setState to show/hide the clear IconButton suffix"
  - "Pattern: _buildBody typed as Widget-returning method with explicit FoodSearchState + FoodSearchNotifier parameters"

requirements-completed:
  - LOG-01
  - LOG-02

# Metrics
duration: ~20min
completed: 2026-07-20
---

# Phase 02 Plan 06: Food Search UI Summary

**Full search UI wired to FoodSearchNotifier: screen with auto-focused TextField, 5 state widgets (prompt, 3 no-results variants, shimmer API banner), FoodResultRow, FoodDetailSheet, /food-search route, and Settings entry point**

## Performance

- **Duration:** ~20 min
- **Started:** 2026-07-20T~17:00Z
- **Completed:** 2026-07-20T~17:20Z
- **Tasks:** 2 (Task 1 widget files pre-committed from prior session; Task 2 screen + router + settings implemented and committed)
- **Files modified:** 8 (6 new widget/screen files + 2 modified)

## Accomplishments

- `FoodSearchScreen` ConsumerStatefulWidget wired to `foodSearchProvider` with deferred auto-focus, clear button, and exhaustive Dart 3 switch over all four `FoodSearchState` variants
- All 5 state widgets (`SearchPromptWidget`, `NoResultsWidget`, `ApiLoadingBanner`, `FoodResultRow`, `FoodDetailSheet`) using `Theme.of(context).colorScheme` tokens — dark mode safe, no hardcoded hex
- `/food-search` registered as a top-level `GoRoute` in `app_router.dart` before the `StatefulShellRoute` so it covers the bottom nav bar
- Settings screen "Search foods" tile provides the Phase 2 entry point; Phase 4 will add meal-logging entry points

## Task Commits

1. **Task 1: All state widgets + FoodResultRow + FoodDetailSheet** - `b1334fb` (feat) — committed in prior session
2. **Task 2: FoodSearchScreen + router wiring** - `f1f28b1` (feat) — screen, route, settings tile + Rule 1 bug fix

**Plan metadata:** (committed below via gsd-sdk)

## Files Created/Modified

- `lib/features/food_search/screens/food_search_screen.dart` — Full-screen search screen; ConsumerStatefulWidget; builds body from FoodSearchState variants
- `lib/features/food_search/widgets/search_prompt_widget.dart` — SizedBox.expand centered icon + hint; shown before any query
- `lib/features/food_search/widgets/no_results_widget.dart` — Three variants (genuine/offline/networkError) with Try again button when onRetry provided
- `lib/features/food_search/widgets/api_loading_banner.dart` — "Searching online..." banner + 5 shimmer rows; shown only on API fallback (AsyncLoading)
- `lib/features/food_search/widgets/food_result_row.dart` — ListTile with bold name, optional brand, calories/100g with `—` fallback
- `lib/features/food_search/widgets/food_detail_sheet.dart` — showFoodDetailSheet() modal; per-100g macros; CO2/Log stubs for Phase 3/4
- `lib/core/router/app_router.dart` — /food-search GoRoute added before StatefulShellRoute
- `lib/features/settings/screens/settings_screen.dart` — Search foods ListTile; go_router import added

## Decisions Made

- `foodSearchProvider` (not `foodSearchNotifierProvider`) is the correct provider name — Riverpod code generation from `@riverpod class FoodSearchNotifier` strips the "Notifier" suffix. The screen was referencing the wrong name causing undefined_identifier errors; corrected as Rule 1 bug fix.
- `NoResultsVariant` references fixed in doc comment (was `NoResultsWidget.genuine` which is invalid — the enum is `NoResultsVariant`).
- `avoid_types_on_closure_parameters` lint in this project forbids explicit closure parameter types; `inference_failure_on_untyped_parameter` from very_good_analysis does not apply when the type is inferrable from the provider's type argument.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed wrong provider name in FoodSearchScreen**
- **Found during:** Task 2 (FoodSearchScreen compile)
- **Issue:** The screen used `foodSearchNotifierProvider` but the generated code in `food_search_notifier.g.dart` declares `foodSearchProvider` (Riverpod drops "Notifier" suffix from the class name when generating the provider variable name). This caused `undefined_identifier` errors and cascading type errors throughout the build method.
- **Fix:** Changed both `ref.read(foodSearchNotifierProvider.notifier)` and `ref.watch(foodSearchNotifierProvider)` to use `foodSearchProvider` instead.
- **Files modified:** `lib/features/food_search/screens/food_search_screen.dart`
- **Verification:** `flutter analyze` reports 0 errors on all changed files
- **Committed in:** `f1f28b1` (Task 2 commit)

**2. [Rule 1 - Bug] Fixed invalid doc comment references in FoodSearchScreen**
- **Found during:** Task 2 analyze pass
- **Issue:** Doc comment referenced `[NoResultsWidget.genuine]` etc. which are not valid Dart symbol references (the enum is `NoResultsVariant`, not members of `NoResultsWidget`)
- **Fix:** Corrected to `[NoResultsVariant.genuine]`, `[NoResultsVariant.offline]`, `[NoResultsVariant.networkError]`
- **Files modified:** `lib/features/food_search/screens/food_search_screen.dart`
- **Verification:** 0 `comment_references` info items
- **Committed in:** `f1f28b1` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (2 Rule 1 bugs)
**Impact on plan:** Both fixes necessary for compilation and correctness. No scope creep.

## Known Stubs

| Stub | File | Line | Reason |
|------|------|------|--------|
| CO2e row omitted | `lib/features/food_search/widgets/food_detail_sheet.dart` | 88 | Phase 3 adds CO2 factor table; comment: `// TODO(phase-3): Add CO₂e row` |
| "Log this food" button omitted | `lib/features/food_search/widgets/food_detail_sheet.dart` | 94 | Phase 4 adds meal logging; comment: `// TODO(phase-4): Add 'Log this food' FilledButton` |

Both stubs are intentional per locked decisions in CONTEXT.md. They do not prevent the Phase 2 goal (search + display macros). The stubs have explicit phase labels to guide later execution.

## Issues Encountered

- Widget files (Task 1) were already committed in a prior session as `b1334fb` before this execution began. Task 1 was verified as complete and execution started from Task 2.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- Phase 2 is fully functional: food catalog ingest pipeline (02-01, 02-02), Dart data layer (02-03), repository + DI (02-04), state management (02-05), and search UI (02-06) are all complete.
- Phase 3 can wire the CO2 factor table and unhide the CO2 row in `FoodDetailSheet` by removing the TODO comment and adding the `_MacroRow` for CO2.
- Phase 4 can add the "Log this food" FilledButton in `FoodDetailSheet` and wire additional entry points to `/food-search` from meal logging flows.
- Barcode scanning (Phase 3) will integrate with the existing `FoodDetailSheet` — no rebuild needed.

## Self-Check

---
*Phase: 02-food-catalog-ingest-search*
*Completed: 2026-07-20*

---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 17
subsystem: data-analysis
tags: [co2-06, ins-03, improvement-opportunities, insights-timeline, riverpod]
dependency-graph:
  requires:
    - lib/features/data_analysis/screens/data_analysis_screen.dart (05-15)
    - lib/data/local/daos/food_catalog_dao.dart (Phase 3, getCo2ForCategory)
    - lib/domain/entities/meal_entry.dart
  provides:
    - lib/domain/services/improvement_opportunity_finder.dart
    - lib/domain/services/insights_timeline_rule_engine.dart
    - lib/features/data_analysis/widgets/improvement_opportunities.dart
    - lib/features/data_analysis/widgets/insights_timeline.dart
  affects:
    - lib/features/data_analysis/screens/data_analysis_screen.dart
    - lib/core/di/app_providers.dart
tech-stack:
  added: []
  patterns:
    - "Hand-authored protein-substitution clusters keyed by off_ref.co2_factors.categories_tag, tiered red-meat -> poultry -> fish -> legumes"
    - "Keyword-based category inference from MealEntry.productNameSnapshot (no schema change) since MealEntry has no persisted category-tag field"
    - "Bounded rule-set domain service (InsightsTimelineRuleEngine) mirroring DailyTotalsCalculator's pure-Dart, zero-I/O convention"
key-files:
  created:
    - lib/domain/services/improvement_opportunity_finder.dart
    - lib/domain/services/insights_timeline_rule_engine.dart
    - lib/features/data_analysis/widgets/improvement_opportunities.dart
    - lib/features/data_analysis/widgets/insights_timeline.dart
  modified:
    - lib/features/data_analysis/screens/data_analysis_screen.dart
    - lib/core/di/app_providers.dart
    - lib/core/di/app_providers.g.dart
    - test/domain/services/improvement_opportunity_finder_test.dart
    - test/features/data_analysis/improvement_opportunities_test.dart
    - test/features/data_analysis/insights_timeline_test.dart
    - test/features/data_analysis/data_analysis_screen_test.dart
decisions:
  - "MealEntry has no persisted category-tag snapshot field, so ImprovementOpportunityFinder infers a co2_factors category tag via documented keyword substring matching on productNameSnapshot rather than a schema change (out of this plan's files_modified scope)"
  - "Significant-CO2 threshold: single entry must contribute >= 0.3 kg CO2e (documented constant) before a substitution suggestion fires -- avoids nudging over a small side dish"
  - "Substitution clusters: en:beef/en:lamb-and-goat/en:pork -> [en:poultry, en:fishes, en:legumes]; en:poultry -> [en:fishes, en:legumes]; en:fishes -> [en:legumes]; legumes has no key (already lowest tier, never suggests up)"
  - "InsightsTimelineRuleEngine.evaluate takes an optional proteinTargetG parameter (not baked into the historicalEntries list) -- the protein rule never fires when no target is set, avoiding a fabricated threshold"
  - "Rule 1 (weekday-dinner) requires >=2 occurrences of a weekday's dinner entries and a >20% margin over the overall daily CO2 average; Rule 2 (protein) requires >=4 distinct days and a strict majority below target; Rule 3 (trend) requires >=4 distinct days with a non-null CO2e total and a linear-regression slope magnitude > 0.05 kg/day"
metrics:
  duration: ~20min
  completed: 2026-07-28
---

# Phase 5 Plan 17: Improvement Opportunities & Insights Timeline Summary

Hand-authored protein-substitution suggestions (CO2-06) and a bounded 3-rule pattern-observation engine (INS-03), both surfaced exclusively inside the still-unreachable `DataAnalysisScreen` via two new pure domain services and two presentation widgets.

## What Was Built

**`ImprovementOpportunityFinder`** (`lib/domain/services/improvement_opportunity_finder.dart`): a pure Dart service, constructor-injected with `FoodCatalogDao`, that scans today's `MealEntry` list for weight-based-unit entries whose logged product name matches a documented keyword list for a red-meat/poultry/fish/legumes tier, whose CO2e contribution is >= 0.3 kg, and returns the same-cluster alternative with the largest quantified CO2e delta (never a cross-cluster or "swap up" suggestion). Cluster membership and thresholds are all documented inline via doc comments, sourced from `tools/off_to_agribalyse_map.csv`'s existing `off_category_tag` vocabulary (e.g. `en:beef`, `en:poultry`, `en:fishes`, `en:legumes`) — the same tags `FoodCatalogDao.getCo2ForCategory`/`getAvailableCo2Categories` already query. Because `MealEntry` has no persisted category-tag snapshot field, category is inferred from `productNameSnapshot` via a documented keyword-substring heuristic rather than a schema change (out of this plan's declared `files_modified` scope).

**`InsightsTimelineRuleEngine`** (`lib/domain/services/insights_timeline_rule_engine.dart`): a pure Dart service implementing three independent, bounded rules over a historical `MealEntry` window — (1) a weekday's average dinner-slot CO2 total consistently exceeding the overall daily average, (2) protein below target on a majority of days (only fires when a `proteinTargetG` is supplied), (3) a linear-regression CO2 trend over the window. Returns `[]` when zero rules fire; never forces or fabricates an observation.

**`ImprovementOpportunities`/`InsightsTimeline` widgets**: both `StatelessWidget`s rendering `SizedBox.shrink()` on an empty list, otherwise factual, non-judgmental copy assembled entirely at the widget layer (the domain services return data only, no phrasing).

**Wiring**: both widgets are added to `DataAnalysisScreen`'s `_NutritionBody`, positioned after the Food Details / `DetailedFoodAnalysisPanel` section, each backed by a dedicated `autoDispose` `FutureProvider` (`_improvementOpportunitiesProvider` over today's entries, `_insightsTimelineProvider` over a second, distinct trailing-7-day pooled query). A new keepAlive `improvementOpportunityFinderProvider` was added to `app_providers.dart` (mirrors `foodCatalogDaoProvider`'s convention). A code comment plus a dedicated static-scan test confirm neither widget is ever referenced anywhere under `lib/features/dashboard/` — satisfying CO2-06's Data-Analysis-screen-only invariant.

## Requirements

CO2-06 and INS-03 are functionally implemented but **deliberately left Pending in REQUIREMENTS.md** — per this plan's important_note, `DataAnalysisScreen` is not yet reachable from `app_router.dart` or the Dashboard (Plan 05-18 wires that). Marking these complete now would misrepresent end-to-end delivery, repeating the mistake corrected in commit `746dbf8`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Widget tests opened a real `AppDatabase` via the new provider chain**
- **Found during:** Task 2, running `flutter test test/features/data_analysis/`
- **Issue:** `_improvementOpportunitiesProvider` resolves through `improvementOpportunityFinderProvider` -> `foodCatalogDaoProvider` -> `appDatabaseProvider`, none of which `data_analysis_screen_test.dart` previously overrode (only `mealEntryRepositoryProvider`/`profileRepositoryProvider`/`weightRepositoryProvider` were mocked). Every `DataAnalysisScreen` widget test now triggered a real native SQLite connection, producing a drift "database class instantiated multiple times" race-condition warning per test run.
- **Fix:** Added a mocktail `_MockFoodCatalogDao` (mirroring the existing `custom_food_form_test.dart` precedent) and overrode `improvementOpportunityFinderProvider` with `ImprovementOpportunityFinder(mockFoodCatalogDao)` in `_buildTestable`, stubbing `getCo2ForCategory` to return `null` unconditionally.
- **Files modified:** `test/features/data_analysis/data_analysis_screen_test.dart`
- **Commit:** `145220f`

**2. [Rule 1 - Lint] Redundant default-matching arguments in the new finder test**
- **Found during:** Task 2, running `flutter analyze` across the whole project
- **Issue:** Several `_entry(...)` calls in `improvement_opportunity_finder_test.dart` explicitly passed default parameter values, tripping `avoid_redundant_argument_values`.
- **Fix:** Removed the redundant arguments; behavior unchanged.
- **Files modified:** `test/domain/services/improvement_opportunity_finder_test.dart`
- **Commit:** `145220f`

## Known Stubs

None — every field returned by both services is either a real computed value or the entry is excluded entirely (no fabricated placeholder values).

## Threat Flags

None — both new services are pure in-memory computation over already-local data (per this plan's threat model), and the two widgets render only already-computed strings/numbers with no new I/O, network, or persistence surface.

## Self-Check: PASSED

- FOUND: `lib/domain/services/improvement_opportunity_finder.dart`
- FOUND: `lib/domain/services/insights_timeline_rule_engine.dart`
- FOUND: `lib/features/data_analysis/widgets/improvement_opportunities.dart`
- FOUND: `lib/features/data_analysis/widgets/insights_timeline.dart`
- FOUND commit `7e81825` (Task 1)
- FOUND commit `145220f` (Task 2)
- All 20 tests across `test/domain/services/improvement_opportunity_finder_test.dart` and `test/features/data_analysis/` pass
- `flutter analyze` clean on every file this plan touches (one pre-existing, out-of-scope `comment_references` info in `app_providers.dart` line 23, predating this plan)

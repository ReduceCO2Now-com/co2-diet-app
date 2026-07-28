---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 15
subsystem: ui
tags: [flutter, riverpod, fl_chart, data-analysis, co2, nutrition]

# Dependency graph
requires:
  - phase: 05-10
    provides: DailyTotalsCalculator (weight-based-unit aggregation, single source of truth)
  - phase: 05-06
    provides: Co2Settings domain layer (dataQuality classification, referenced conceptually; not directly consumed)
provides:
  - "DataAnalysisScreen: stacked-bar today's breakdown, explicit weekly total, ranked contributors, goal comparison, independently-toggleable metric x range trend, aggregate confidence-mix transparency panel, per-entry expandable detail, and a Weight metric entry"
  - "IMealEntryRepository.getEntriesInRange(from, to): new multi-day pooled-entry read, backing the weekly-total and 7d/30d trend queries"
  - "Self-contained AnalysisMetric enum (co2/calories/protein/weight), deliberately decoupled from Dashboard's DashboardMetric"
affects: [05-17, 05-18]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "fl_chart BarChartRodStackItem per-entry stacking (one visually distinct segment per contributing MealEntry within a slot)"
    - "Screen-owned FutureProvider.autoDispose for one-shot multi-day aggregation, kept separate from the reactive per-day mealEntryProvider"
    - "TrendSpotFetcher callback pattern: chart widget stays a pure presentation component, screen owns the repository query"

key-files:
  created:
    - lib/features/data_analysis/widgets/analysis_metric.dart
    - lib/features/data_analysis/widgets/today_breakdown_bar_chart.dart
    - lib/features/data_analysis/widgets/weekly_total_summary.dart
    - lib/features/data_analysis/widgets/ranked_contributors_list.dart
    - lib/features/data_analysis/widgets/estimate_transparency_panel.dart
    - lib/features/data_analysis/widgets/goal_comparison_bar.dart
    - lib/features/data_analysis/widgets/trend_section.dart
    - lib/features/data_analysis/widgets/detailed_food_analysis_panel.dart
    - lib/features/data_analysis/screens/data_analysis_screen.dart
  modified:
    - lib/data/local/daos/meal_entry_dao.dart
    - lib/domain/repositories/i_meal_entry_repository.dart
    - lib/data/repositories/meal_entry_repository.dart
    - test/features/data_analysis/data_analysis_screen_test.dart

key-decisions:
  - "AnalysisMetric is a screen-local enum, never importing/extending Dashboard's DashboardMetric (same-wave Plan 05-11, no depends_on edge)"
  - "IMealEntryRepository.getEntriesInRange(from, to) added (Rule 2) -- no existing repository/DAO method could pool entries across multiple days; getEntriesForToday and getRecent are single-day/recency-scoped only"
  - "Weight metric mode reuses the existing WeightChart widget verbatim rather than teaching TrendSection to plot weight -- a genuinely distinct chart type satisfies the must-have more directly than branching one widget's internals"
  - "Metric-list section generalizes 'tap to re-enter this screen pre-set to a metric' to all four metrics (not just Weight) via Navigator.push(DataAnalysisScreen(initialMetric: ...)) -- one consistent navigation pattern"
  - "GoalComparisonBar's CO2 target always renders 'no target set' honestly -- CalcTargets.co2GTarget is never populated by TargetCalculator anywhere in the codebase (confirmed by grep), so this is not a bug, just an accurate reflection of current app state"

requirements-completed: []  # Deliberately empty -- see "Requirements" note below.

# Metrics
duration: ~25min
completed: 2026-07-28
---

# Phase 5 Plan 15: Data Analysis Screen Core Summary

**DataAnalysisScreen with a genuine fl_chart stacked-bar today's-breakdown, an explicit trailing-7-day total, ranked contributors, goal comparison, an independently-toggleable CO2/Calories/Protein x 7d/30d trend chart, an aggregate confidence-mix transparency panel, and a Weight metric entry that swaps in the existing WeightChart.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 2
- **Files modified:** 10 (6 created widgets + 1 created screen + 1 new test file content + 3 modified data-layer files for the range query)

## Accomplishments

- `TodayBreakdownBarChart`: a real `fl_chart` `BarChart` with `BarChartRodStackItem` per contributing entry (not a plain grouped list) -- satisfies REQUIREMENTS.md's literal "today's breakdown by meal (stacked bar)"
- `WeeklyTotalSummary`: an explicit trailing-7-day total, computed via a second, distinct `DailyTotalsCalculator.compute()` call over pooled multi-day entries -- satisfies CO2-02's "weekly total" success criterion alongside the existing day-by-day trend charts
- `TrendSection`: metric and range segmented controls are independent local-state values (verified: switching metric never resets range, and vice versa)
- `EstimateTransparencyPanel`: aggregate High/Medium confidence-mix summary + proportional bar + methodology link -- distinct from the single-food `ConfidenceChip`
- `DataAnalysisScreen`'s Weight metric mode renders the existing `WeightChart`, a genuinely different chart (not calorie/protein/CO2 data), satisfying WT-05's "Weight entry" requirement within this screen's own metric list
- Added `IMealEntryRepository.getEntriesInRange` (+ DAO/repository implementations) to make the weekly-total and 7d/30d trend views possible at all

## Task Commits

1. **Task 1: TodayBreakdownBarChart, WeeklyTotalSummary, RankedContributorsList, EstimateTransparencyPanel, GoalComparisonBar** - `5f6c9de` (feat)
2. **Task 2: TrendSection and DetailedFoodAnalysisPanel, screen assembly** - `4a69a3b` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified

- `lib/features/data_analysis/widgets/analysis_metric.dart` - Self-contained co2/calories/protein/weight enum + displayLabel extension
- `lib/features/data_analysis/widgets/today_breakdown_bar_chart.dart` - Stacked bar chart, one bar per MealSlot, one stack segment per weight-based entry
- `lib/features/data_analysis/widgets/weekly_total_summary.dart` - Pure presentation of a pre-computed trailing-7-day `DailyTotals`
- `lib/features/data_analysis/widgets/ranked_contributors_list.dart` - Reusable per-metric descending-sorted list
- `lib/features/data_analysis/widgets/estimate_transparency_panel.dart` - Aggregate High/Medium confidence-mix panel + methodology link
- `lib/features/data_analysis/widgets/goal_comparison_bar.dart` - Progress bar + factual message, honest "no target set" fallback
- `lib/features/data_analysis/widgets/trend_section.dart` - Independent metric/range segmented controls + interactive `LineChart`
- `lib/features/data_analysis/widgets/detailed_food_analysis_panel.dart` - Per-entry `ExpansionTile` revealing per-serving/per-100g values for all 8 nutrient/CO2 fields
- `lib/features/data_analysis/screens/data_analysis_screen.dart` - Assembles every section; branches to a Weight-only body (`WeightChart`) vs. the full nutrition body
- `lib/data/local/daos/meal_entry_dao.dart` - Added `getEntriesInRange(fromLogDate, toLogDate)`
- `lib/domain/repositories/i_meal_entry_repository.dart` - Added `getEntriesInRange(DateTime from, DateTime to)` to the interface
- `lib/data/repositories/meal_entry_repository.dart` - Implements `getEntriesInRange`, delegating to the DAO
- `test/features/data_analysis/data_analysis_screen_test.dart` - Fully de-skipped: widget-level + full-screen assertions

## Decisions Made

- `AnalysisMetric` kept fully independent of Dashboard's `DashboardMetric` per the plan's round-2 revision (no `depends_on` edge on same-wave Plan 05-11)
- Weight-mode reuses `WeightChart` directly rather than extending `TrendSection` to understand a fourth metric -- simpler, and inherently satisfies "genuinely distinct, not calorie/protein/CO2 data"
- `co2GTarget` is confirmed dead/unpopulated code path (`TargetCalculator.derive` never sets it) -- `GoalComparisonBar`'s CO2 target will always show "no target set" until a future plan wires one up; this is accurate, not a gap introduced here

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical Functionality] Added `IMealEntryRepository.getEntriesInRange`**
- **Found during:** Task 2 (screen assembly)
- **Issue:** The plan requires `WeeklyTotalSummary` (trailing 7 days pooled) and `TrendSection`'s 7d/30d range views, both of which need multi-day entry aggregation. `IMealEntryRepository` only exposed `getEntriesForToday()` (single day) and `getRecent()` (recency-scoped, deduped by food, not date-scoped) -- neither can pool a date range. Without this method, the plan's core CO2-02 "weekly total" and trend-range must-haves are structurally impossible to implement.
- **Fix:** Added `MealEntryDao.getEntriesInRange(fromLogDate, toLogDate)` (log_date string comparison, matching `insertOrMerge`'s established string-equality convention -- `yyyy-MM-dd` strings sort identically to chronological order), exposed via `IMealEntryRepository.getEntriesInRange(DateTime from, DateTime to)`, implemented in `MealEntryRepository`.
- **Files modified:** `lib/data/local/daos/meal_entry_dao.dart`, `lib/domain/repositories/i_meal_entry_repository.dart`, `lib/data/repositories/meal_entry_repository.dart`
- **Verification:** `flutter analyze` clean on all three files; every existing `_MockMealEntryRepository extends Mock implements IMealEntryRepository` fake in the test suite is unaffected (mocktail's `noSuchMethod` fallback tolerates the new interface method); full `flutter test` suite (308 tests) still green.
- **Committed in:** `4a69a3b` (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (Rule 2 - missing critical functionality)
**Impact on plan:** Necessary for the plan's own explicitly-stated must-haves (CO2-02 weekly total, 7d/30d trend) to be achievable at all. No scope creep beyond what those must-haves require.

## Issues Encountered

None beyond the deviation above.

## Requirements

Per this plan's explicit instruction (round-3 revision note), **no requirement IDs were marked complete** in REQUIREMENTS.md, even though this plan's frontmatter lists INS-01, INS-02, CO2-02, CO2-05, NUTR-04, and WT-05. `DataAnalysisScreen` is not yet wired into `app_router.dart` or reachable from the Dashboard (Plan 05-18 does that), and INS-01 additionally requires Improvement Opportunities + Insights Timeline (Plan 05-17, next wave) before the full requirement text is satisfied end-to-end. All six IDs remain `Pending` in REQUIREMENTS.md, verified unchanged after this plan's execution.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `DataAnalysisScreen` is fully built and tested standalone, accepting `initialMetric` so Plan 05-18 can wire `state.uri.queryParameters['metric']` through once the route exists.
- Plan 05-17 (next wave, same file) will add Improvement Opportunities and Insights Timeline sections into this same `data_analysis_screen.dart` -- no conflicting section ordering assumed.
- `IMealEntryRepository.getEntriesInRange` is now available for any future plan needing multi-day pooled meal-entry reads.

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-28*

## Self-Check: PASSED

All 9 created files verified present on disk; both task commits (`5f6c9de`, `4a69a3b`) verified present in git log.

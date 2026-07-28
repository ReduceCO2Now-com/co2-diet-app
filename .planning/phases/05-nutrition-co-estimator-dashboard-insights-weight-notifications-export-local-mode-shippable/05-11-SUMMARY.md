---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 11
subsystem: ui
tags: [flutter, fl_chart, riverpod-conventions, dashboard, widgets]

# Dependency graph
requires:
  - phase: 05-10
    provides: "DailyTotalsCalculator / DailyTotals.macroSplit (MacroSplit)"
  - phase: 05-08
    provides: "fl_chart dependency installed in pubspec.yaml"
provides:
  - "MetricCard -- value/target display widget with no-fake-precision '-' fallback and isEmphasized goal-priority visual hook"
  - "ModeIndicator -- Local/Account Mode text widget, ready for Phase 7's Account Mode"
  - "QuickInsightLine -- pure display of a pre-computed factual insight sentence"
  - "MacroSplitBar -- proportional protein/carbs/fat bar + legend, empty-state aware (NUTR-04)"
  - "TrendSparkline -- controlled-component segmented CO2/Calories/Protein toggle over a compact axis-free fl_chart LineChart"
  - "Co2ProfilePromptCard -- dismissible 'Complete your CO2 profile' prompt card"
affects: [05-18]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Controlled-component pattern for TrendSparkline (selectedMetric/onMetricChanged owned by parent) instead of local StatefulWidget state, since the parent screen needs the selected metric for DASH-08's tap-to-navigate behavior"
    - "RESEARCH.md Pattern 2 fl_chart compact-sparkline config applied verbatim: titlesData/gridData/borderData all show:false, lineTouchData disabled, belowBarData alpha 0.12"

key-files:
  created:
    - lib/features/dashboard/widgets/metric_card.dart
    - lib/features/dashboard/widgets/mode_indicator.dart
    - lib/features/dashboard/widgets/quick_insight_line.dart
    - lib/features/dashboard/widgets/macro_split_bar.dart
    - lib/features/dashboard/widgets/trend_sparkline.dart
    - lib/features/dashboard/widgets/co2_profile_prompt_card.dart
  modified:
    - test/features/dashboard/metric_card_test.dart
    - test/features/dashboard/trend_sparkline_test.dart

key-decisions:
  - "Co2ProfilePromptCard's exact copy uses the subscript '₂' character ('Complete your CO₂ profile for better estimates'), matching CONTEXT.md's literal specified string and this codebase's existing CO₂-subscript convention (ConfidenceExplanationSheet, etc.) rather than the plain-'2' rendering that appeared in the PLAN.md prose"
  - "MacroSplitBar legend colors reuse existing AppColors tokens (primaryContainer/secondaryContainer/warningAmber) rather than inventing new brand colors, keeping it consistent with ConfidenceChip's existing high/medium color usage"
  - "TrendSparkline built as a StatelessWidget (controlled component), not StatefulWidget -- selectedMetric/onMetricChanged are parent-owned per the plan's explicit preference for this codebase's Riverpod-driven state conventions"

requirements-completed: []

# Metrics
duration: ~10min
completed: 2026-07-28
---

# Phase 5 Plan 11: Dashboard Widgets (MetricCard, TrendSparkline, MacroSplitBar, etc.) Summary

**Six standalone, independently-testable Dashboard widgets (MetricCard, ModeIndicator, QuickInsightLine, MacroSplitBar, TrendSparkline with fl_chart, Co2ProfilePromptCard) built with zero changes to the placeholder Dashboard screen or router -- Plan 05-18 assembles them later.**

## Performance

- **Duration:** ~10 min
- **Tasks:** 2
- **Files modified:** 6 created, 2 test files de-skipped

## Accomplishments
- `MetricCard`: value-vs-target display with the established "no fake precision" `'—'` fallback and an `isEmphasized` hook for goal-matching-metric ordering/sizing
- `TrendSparkline`: a compact, axis-free 7-day `fl_chart` sparkline with a segmented CO2/Calories/Protein toggle, built as a controlled component so the parent screen can read the selected metric for DASH-08's tap-to-navigate-to-Data-Analysis behavior
- `MacroSplitBar`: NUTR-04's macro-split visualization (protein/carbs/fat proportional bar + legend), null-safe empty state
- `Co2ProfilePromptCard`: dismissible "Complete your CO₂ profile for better estimates" card, renders nothing when `show` is false
- `ModeIndicator` and `QuickInsightLine`: small pure-display widgets ready for Plan 05-18's Dashboard assembly
- Both previously-skipped Wave 0 test stubs (`metric_card_test.dart`, `trend_sparkline_test.dart`) now have real `pumpWidget` assertions and pass

## Task Commits

Each task was committed atomically:

1. **Task 1: MetricCard, MacroSplitBar, ModeIndicator, QuickInsightLine** - `82de507` (feat)
2. **Task 2: TrendSparkline (fl_chart) and CO2 profile prompt card** - `29d2e20` (feat)

**Plan metadata:** (this commit, following SUMMARY/STATE/ROADMAP updates)

## Files Created/Modified
- `lib/features/dashboard/widgets/metric_card.dart` - Value/target metric card with emphasis hook
- `lib/features/dashboard/widgets/mode_indicator.dart` - Local/Account Mode text indicator
- `lib/features/dashboard/widgets/quick_insight_line.dart` - Pure display of pre-computed insight sentence
- `lib/features/dashboard/widgets/macro_split_bar.dart` - NUTR-04 macro split visualization
- `lib/features/dashboard/widgets/trend_sparkline.dart` - fl_chart compact 7-day sparkline with metric toggle
- `lib/features/dashboard/widgets/co2_profile_prompt_card.dart` - Dismissible CO2-profile-completion prompt
- `test/features/dashboard/metric_card_test.dart` - De-skipped, real assertions for MetricCard/ModeIndicator
- `test/features/dashboard/trend_sparkline_test.dart` - De-skipped, real assertions for TrendSparkline/Co2ProfilePromptCard

## Decisions Made
- Used the subscript "CO₂" character in `Co2ProfilePromptCard`'s copy (matching CONTEXT.md's literal source string and existing app convention), not the plain "CO2" that appeared in one place in PLAN.md's prose.
- Kept the pre-existing but out-of-scope "quick-log buttons push /food-search" test individually skipped inside `metric_card_test.dart` (documented reason: Plan 05-18 Dashboard-assembly wiring, not a widget built by this plan) rather than deleting it, preserving the Wave-0 test-coverage tracking for that future plan.

## Deviations from Plan

None — plan executed exactly as written. Both tasks' `<action>` and `<verify>` steps were followed as specified; only cosmetic lint fixes were needed (explicit `Color` type annotations for `static const` fields per `very_good_analysis`'s `specify_nonobvious_property_types`, and a doc-comment reference fix), both trivial Rule 1 auto-fixes with no behavioral impact.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Requirements Note

Per this plan's `<important_note>`, none of DASH-01/04/05/06 or NUTR-02/03/04 are marked complete in REQUIREMENTS.md despite being listed in this plan's frontmatter `requirements` field — those requirements describe the *assembled, wired* Dashboard screen, which does not exist until Plan 05-18 integrates these six standalone widgets into `placeholder_dashboard_screen.dart`/`app_router.dart`. NFR-05 was already marked Complete by an earlier plan and needed no change. REQUIREMENTS.md and STATE.md are left unmodified for these IDs; ROADMAP.md's Phase 5 plan-progress row is updated to reflect this plan's completion count only.

## Next Phase Readiness
- All six widgets compile, render correctly in isolation, and pass their de-skipped tests — ready for Plan 05-18 to import and wire into the real Dashboard screen alongside other Wave 5 plans' outputs (Weight/Notifications/Insights widgets, etc.).
- No blockers.

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-28*

## Self-Check: PASSED

All 6 created widget files and the SUMMARY.md file verified present on disk. Both task commit hashes (`82de507`, `29d2e20`) verified present in git log.

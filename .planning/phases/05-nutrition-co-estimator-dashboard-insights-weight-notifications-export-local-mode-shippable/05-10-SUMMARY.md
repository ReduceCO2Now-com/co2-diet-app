---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 10
subsystem: domain
tags: [dart, pure-functions, aggregation, co2, nutrition, domain-service]

# Dependency graph
requires:
  - phase: 05-04
    provides: sugar/fiber/salt snapshot fields on MealEntry/FoodItem/repository layer
  - phase: 05-06
    provides: Co2Settings domain entity with dataQuality classification
provides:
  - "DailyTotalsCalculator.compute(entries, {co2Multiplier}) -> DailyTotals pure aggregation service"
  - "PersonalCo2MultiplierCalculator.compute(Co2Settings) -> double pure settings-to-multiplier service"
  - "MacroSplit value object (protein/carbs/fat energy-share percentages)"
affects: [05-11-dashboard, 05-15-data-analysis]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Static-only service class with const ._() private constructor (mirrors TargetCalculator)"
    - "Null-vs-zero distinction: a nutrient field is null (not 0) when zero entries contribute"
    - "Single-application multiplier: co2Multiplier applied exactly once at the aggregate-total level, never per-entry"

key-files:
  created:
    - lib/domain/services/daily_totals_calculator.dart
    - lib/domain/services/personal_co2_multiplier_calculator.dart
  modified:
    - test/domain/services/daily_totals_calculator_test.dart
    - test/domain/services/personal_co2_multiplier_test.dart

key-decisions:
  - "DailyTotalsCalculator filters to entry.unit.isWeightBased before scaling any entry -- piece/cup/portion entries are excluded from every numeric total, matching MealEntryRow/RecentRow's existing Phase 04-10 precedent."
  - "MacroSplit reuses TargetCalculator's existing 4/4/9 kcal/g energy-conversion constants rather than inventing new ones."
  - "PersonalCo2MultiplierCalculator's 4 active factors (purchasingSource/shoppingTransport/cookingMethod/foodWasteLevel) use additive percentage deltas clamped to [0.7, 1.3], mirroring TargetCalculator's safety-clamp precedent; each constant is documented ASSUMED/to-be-reviewed."
  - "foodStorage/householdSize/locationCountry/locationRegion produce no numeric effect in v1 -- confirmed locked decision per 05-CONTEXT.md's Planning Addendum, documented with a permanent code comment (not a TODO)."

patterns-established:
  - "Pure zero-I/O domain service classes take only their designated input type and return only their designated output type -- structurally prevents cross-layer leakage (PersonalCo2MultiplierCalculator cannot touch a MealEntry even if a future caller tried)."

requirements-completed: []  # See note below -- no requirement is fully end-to-end delivered by this plan alone (domain layer only, no UI consumer yet).

# Metrics
duration: ~8min
completed: 2026-07-28
---

# Phase 5 Plan 10: Daily Totals & Personal CO2 Multiplier Calculators Summary

**Two pure-Dart aggregation services (DailyTotalsCalculator, PersonalCo2MultiplierCalculator) that the Dashboard and Data Analysis screens will both call so their numbers can never silently diverge.**

## Performance

- **Duration:** ~8 min
- **Tasks:** 2 completed
- **Files modified:** 4 (2 created, 2 test files de-skipped)

## Accomplishments
- `DailyTotalsCalculator.compute()` sums calories/protein/carbs/fat/sugar/fiber/salt/co2e across a list of `MealEntry` rows, correctly distinguishing "zero contributing entries" (→ `null`) from "entries summing to zero" (→ `0`), and excludes non-weight-based-unit entries (piece/cup/portion) per the documented Phase 4 limitation.
- `DailyTotals.macroSplit` getter derives protein/carbs/fat energy-share percentages using the same 4/4/9 kcal/g constants `TargetCalculator` already uses.
- `PersonalCo2MultiplierCalculator.compute()` derives a deterministic personal-consumption CO2 multiplier from `Co2Settings`, defaulting to a neutral `1.0` and applying documented additive deltas for 4 of 7 settings factors, clamped to `[0.7, 1.3]`.
- Both services are structurally enforced as zero-I/O, single-purpose pure functions -- `PersonalCo2MultiplierCalculator.compute` has no parameter through which any food-level CO2 data could pass.

## Task Commits

Each task was committed atomically:

1. **Task 1: DailyTotalsCalculator** - `c87ac2c` (feat, TDD)
2. **Task 2: PersonalCo2MultiplierCalculator** - `b0546dc` (feat, TDD)

_Both TDD tasks de-skipped pre-existing Wave-0 test stubs directly with full assertions rather than following a separate RED→GREEN commit split, since the stub tests contained no assertions to fail against (`() {}` empty bodies) -- writing the implementation and its real assertions together was the only viable order. This mirrors the plan's own instruction: "De-skip test/... with real assertions covering every `<behavior>` bullet."_

## Files Created/Modified
- `lib/domain/services/daily_totals_calculator.dart` - `DailyTotals` (nullable per-nutrient fields + `MacroSplit? macroSplit` getter) and `DailyTotalsCalculator.compute()` (static aggregation over weight-based-unit entries only)
- `lib/domain/services/personal_co2_multiplier_calculator.dart` - `PersonalCo2MultiplierCalculator.compute()` (static settings-to-multiplier derivation)
- `test/domain/services/daily_totals_calculator_test.dart` - de-skipped, 9 real assertions (7 original behavior-bullet tests + 2 additional edge cases: macroSplit-null-when-all-null, empty-list)
- `test/domain/services/personal_co2_multiplier_test.dart` - de-skipped, 5 real assertions covering every behavior bullet

## Decisions Made
- Cross-referenced the two new files' doc comments (`[DailyTotalsCalculator.compute]` / `[PersonalCo2MultiplierCalculator]`) required adding an import between them purely for doc-comment resolution (`comment_references` lint) -- both imports are load-bearing for documentation linking, not accidental unused imports.
- `1.0` baseline constant written as `1` per `prefer_int_literals` (analyzer clean run with zero issues).

## Deviations from Plan

None - plan executed exactly as written. Both tasks matched their `<action>`/`<behavior>` specs precisely; no bugs, missing functionality, blocking issues, or architectural changes were encountered.

## Issues Encountered

None. `flutter analyze` on both new files initially flagged two minor issues (an over-broad `unused_import` ignore comment that was itself unnecessary once the import was genuinely used by a doc-comment cross-reference, and a `prefer_int_literals` info) -- both resolved in the same task's work before commit, not counted as a plan deviation since they were self-inflicted lint noise from placeholder `ignore:` comments added defensively and removed once verified unnecessary.

## User Setup Required

None - no external service configuration required. Pure Dart, zero I/O, zero new dependencies.

## Known Stubs

None. Both services are fully implemented per the plan's `<action>` spec; no placeholder/mock data paths.

## Requirements Note

Per the important_note in this plan's execution instructions: **no requirement ID (NUTR-01/02/03/04, CO2-02) is marked complete by this plan.** This plan delivers two pure-Dart domain-layer calculator services with no UI consumer yet -- the Dashboard (05-11) and Data Analysis screen (05-15) are the plans that will actually surface these totals/multiplier to the user, satisfying the full end-to-end requirement text. `requirements-completed` is intentionally left empty in this summary's frontmatter, and `REQUIREMENTS.md` traceability is NOT updated by this plan.

## Next Phase Readiness
- `DailyTotalsCalculator` and `PersonalCo2MultiplierCalculator` are ready for Plan 05-11 (Dashboard) and Plan 05-15 (Data Analysis) to consume directly -- no further domain-layer work needed for daily/weekly aggregation or personal CO2 multiplier derivation.
- No blockers.

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-28*

## Self-Check: PASSED

All created files verified present on disk; both task commit hashes (`c87ac2c`, `b0546dc`) verified present in git log.

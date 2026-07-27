---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 07
subsystem: database
tags: [drift, riverpod, weight-tracking, domain-layer]

requires:
  - phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
    provides: "WeightDao (Plan 05-05) — WeightEntryTable/WeightSettingsTable Drift access"
provides:
  - "WeightEntry/WeightSettings immutable domain entities"
  - "WeightRange enum resolving 7d/30d/90d/1yr/all to a concrete [from, to] window"
  - "IWeightRepository / WeightRepository (logWeight, getEntriesInRange, deleteEntry, getSettings, saveGoal, saveReminderSettings)"
  - "weightDaoProvider / weightRepositoryProvider (keepAlive DI)"
  - "WeightNotifier (weightProvider) exposing combined WeightState (entries + settings)"
affects: [05-13-weight-tracking-screen, 05-15-data-analysis-weight-metric]

tech-stack:
  added: []
  patterns:
    - "Single repository/notifier owning multiple closely-related concerns (entries + settings), mirroring IMealEntryRepository"
    - "Read-modify-write settings row so saveGoal/saveReminderSettings never clobber each other's fields"
    - "Named-range-to-date-window resolution lives in the repository layer, not the DAO"

key-files:
  created:
    - lib/domain/entities/weight_entry.dart
    - lib/domain/entities/weight_settings.dart
    - lib/domain/repositories/i_weight_repository.dart
    - lib/data/repositories/weight_repository.dart
    - lib/core/di/weight_providers.dart
    - lib/features/weight/providers/weight_notifier.dart
  modified:
    - test/data/repositories/weight_repository_test.dart
    - test/features/weight/weight_notifier_test.dart

key-decisions:
  - "WeightSettings has no derived pace/on-track/projection field — CONTEXT.md explicitly rejects deriving one; entity shape makes it impossible to add by accident"
  - "saveGoal/saveReminderSettings each read the current settings row first (read-modify-write) before writing, so neither ever clobbers the other's fields"
  - "WeightRange enum lives in weight_entry.dart alongside WeightEntry (not a separate file) since it's tightly coupled to getEntriesInRange's contract"
  - "entriesForRange() on WeightNotifier bypasses build()'s full-state reload — re-queries the repository directly so changing the chart's visible window doesn't refetch settings unnecessarily"

patterns-established:
  - "Settings singleton-row repositories always read-modify-write when persisting a subset of fields (established by Co2SettingsRepository in 05-06, now confirmed twice)"

requirements-completed: []

duration: ~10min
completed: 2026-07-27
---

# Phase 5 Plan 07: Weight Tracking Domain Layer Summary

**WeightEntry/WeightSettings entities, IWeightRepository + Drift-backed WeightRepository, DI providers, and WeightNotifier — the data layer the Weight Tracking screen (Plan 05-13) will consume, with zero derived pace/projection field anywhere in the stack.**

## Performance

- **Duration:** ~10 min
- **Tasks:** 2
- **Files modified:** 9 (6 created, 2 test files rewritten with real assertions, 1 generated `.g.dart` from Task 1 codegen run folded into Task 2's build)

## Accomplishments

- `WeightEntry`/`WeightSettings` immutable domain entities with sentinel `copyWith`, following `MealEntry`/`Co2Settings`'s established conventions
- `WeightRange` enum (`sevenDay, thirtyDay, ninetyDay, oneYear, all`) with a `startDate(DateTime now)` extension resolving WT-02's named filter to a concrete lower bound
- `IWeightRepository`/`WeightRepository`: `logWeight`, `getEntriesInRange`, `deleteEntry`, `getSettings`, `saveGoal`, `saveReminderSettings` — the latter two are independent read-modify-write operations verified never to clobber each other's fields
- DI providers (`weightDaoProvider`, `weightRepositoryProvider`, both keepAlive) mirroring `meal_logging_providers.dart`/`co2_settings_providers.dart`
- `WeightNotifier` (generated provider `weightProvider`) exposing a combined `WeightState` (all entries + settings), with `logWeight`/`saveGoal`/`saveReminderSettings` mutation methods and a standalone `entriesForRange` for chart-window queries
- De-skipped both `weight_repository_test.dart` (12 tests) and `weight_notifier_test.dart` (5 tests) with real mocktail-based assertions

## Task Commits

1. **Task 1: WeightEntry/WeightSettings entities and WeightRepository** - `9814229` (feat)
2. **Task 2: DI providers and WeightNotifier** - `f82e228` (feat)

## Files Created/Modified

- `lib/domain/entities/weight_entry.dart` - `WeightEntry` entity + `WeightRange` enum/extension
- `lib/domain/entities/weight_settings.dart` - `WeightSettings` entity (goal + reminder, no pace field)
- `lib/domain/repositories/i_weight_repository.dart` - Repository contract
- `lib/data/repositories/weight_repository.dart` - Drift-backed implementation
- `lib/core/di/weight_providers.dart` - `weightDaoProvider`/`weightRepositoryProvider`
- `lib/features/weight/providers/weight_notifier.dart` - `WeightState` + `WeightNotifier`
- `test/data/repositories/weight_repository_test.dart` - De-skipped, 12 real tests
- `test/features/weight/weight_notifier_test.dart` - De-skipped, 5 real tests

## Decisions Made

- `saveReminderSettings`'s parameter order was changed from the plan's literal
  `{required String frequency, int? weekday, String? time, required bool enabled}`
  to `{required String frequency, required bool enabled, int? weekday, String? time}`
  to satisfy `very_good_analysis`'s `always_put_required_named_parameters_first`
  lint. This is a pure named-parameter reordering with zero call-site impact
  (named args are order-independent at call sites) — not a deviation from the
  plan's actual contract.
- All other implementation choices matched the plan directly (mirrored
  `MealEntryRepository`/`Co2SettingsRepository`/`Co2SettingsNotifier`
  precedents as instructed).

## Deviations from Plan

None — plan executed exactly as written, aside from the cosmetic parameter-order fix noted above (Rule 1 — lint compliance, no behavior change).

## Issues Encountered

None.

## Requirements Note (IMPORTANT — read before marking anything complete)

This plan builds the **domain/repository/DI/notifier layer only** for WT-01
through WT-04. Per the phase's explicit guardrail (after the 05-06 CO2-02/
CO2-03 over-marking incident), **WT-01 through WT-04 are NOT marked complete
in REQUIREMENTS.md** — the actual Weight Tracking screen doesn't exist until
Plan 05-13, and WT-05 (not touched by this plan at all) also remains
Pending. `requirements-completed: []` in this summary's frontmatter reflects
that intentionally. No `requirements mark-complete` call was made for this
plan's `requirements:` frontmatter IDs.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `weightProvider`/`IWeightRepository` are ready for Plan 05-13 (Weight
  Tracking screen UI) and Plan 05-15 (Data Analysis's Weight metric) to
  consume directly — neither future plan needs to touch `WeightDao` or
  Drift directly.
- No blockers. The entity-level absence of any pace/projection field means
  Plan 05-13's screen literally cannot render one without adding a new field
  first, which would itself need to pass through this repository/entity
  layer and would be visible in review.

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-27*

## Self-Check: PASSED

All 6 created files verified present on disk. Both task commits (`9814229`, `f82e228`) verified present in git log.

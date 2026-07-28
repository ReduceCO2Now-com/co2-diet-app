---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 12
subsystem: ui
tags: [flutter, riverpod, co2-settings, form, data-quality]

# Dependency graph
requires:
  - phase: 05-06
    provides: Co2Settings domain entity, ICo2SettingsRepository, Co2SettingsNotifier/co2SettingsProvider
provides:
  - Co2SettingsScreen -- 7 optional fields (location country/region, purchasing source, shopping transport, cooking method, food storage, household size, food waste level), auto-save on change
  - DataQualityIndicator widget -- Basic/Good/Detailed Estimate chip sourced from Co2Settings.dataQuality
affects: [05-18]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Dropdown fields include an explicit 'Not set' item mapping to null, keeping enum-valued settings genuinely optional (not defaulted to the first enum value)"
    - "TextFormField key: ValueKey('field-$value') + initialValue rebuild pattern (no TextEditingController) -- reused verbatim from ProfileForm for the two free-text location fields and the household-size number field"

key-files:
  created:
    - lib/features/co2_settings/widgets/data_quality_indicator.dart
    - lib/features/co2_settings/screens/co2_settings_screen.dart
  modified:
    - test/features/co2_settings/co2_settings_screen_test.dart

key-decisions:
  - "DataQualityIndicator is a separate sibling widget to ConfidenceChip, not a shared/reused widget -- per 05-CONTEXT.md these are 'a different concept' (settings-completeness vs. per-food CO2 confidence)"
  - "Co2SettingsScreen NOT wired into app_router.dart or linked from Settings -- Plan 05-18 adds the route and entry points once every Wave 5 screen exists; CO2-03 intentionally left unchecked in REQUIREMENTS.md since the screen is not yet reachable in the app"

patterns-established:
  - "Co2SettingsScreen mirrors ProfileScreen/ProfileForm's exact auto-save shape: ConsumerWidget + AsyncValue.when(loading/error/data), onChanged builds an updated entity via copyWith and calls notifier.saveSettings unawaited"

requirements-completed: []

# Metrics
duration: ~12min
completed: 2026-07-28
---

# Phase 5 Plan 12: CO2 Calculation Settings Screen Summary

**Co2SettingsScreen with 7 genuinely-optional auto-saving fields and a live Basic/Good/Detailed Data Quality Indicator, standalone and not yet routed**

## Performance

- **Duration:** ~12 min
- **Tasks:** 2 completed
- **Files modified:** 3 (2 created, 1 test file completed)

## Accomplishments
- `DataQualityIndicator` widget renders `'Basic Estimate'` / `'Good Estimate'` / `'Detailed Estimate'` from a `dataQuality` string param, with a distinct 3-state color mapping (neutral gray / `AppColors.warningAmber` / `AppColors.primaryContainer`) — deliberately not sharing implementation with `ConfidenceChip`
- `Co2SettingsScreen` renders all 7 CO2 Calculation Settings fields (location country/region as text, purchasing source/shopping transport/cooking method/food storage/food waste level as dropdowns with an explicit "Not set" option, household size as a number field) — none has a required-field validator
- Every field auto-saves immediately on change via `Co2SettingsNotifier.saveSettings`, matching `ProfileScreen`'s established no-blocking-validation convention
- De-skipped `test/features/co2_settings/co2_settings_screen_test.dart`: asserts saving with every field empty succeeds, and that the Data Quality Indicator's rendered label progresses Basic → Good → Detailed as fields are filled in via a widget test against an in-memory fake repository

## Task Commits

Each task was committed atomically:

1. **Task 1: DataQualityIndicator widget** - `9267cab` (feat)
2. **Task 2: Co2SettingsScreen** - `3ab4bf1` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified
- `lib/features/co2_settings/widgets/data_quality_indicator.dart` - Presentational chip widget for the 3 data-quality states
- `lib/features/co2_settings/screens/co2_settings_screen.dart` - The CO2 Calculation Settings screen (`ConsumerWidget`), 7 optional fields + auto-save
- `test/features/co2_settings/co2_settings_screen_test.dart` - De-skipped: `DataQualityIndicator` rendering tests + full `Co2SettingsScreen` widget tests (empty-save succeeds, indicator updates live)

## Decisions Made
- Used a `_FakeCo2SettingsRepository` (in-memory, implements `ICo2SettingsRepository`) rather than a mocktail `Mock` for the screen widget test, since the test needs realistic read-your-own-write persistence across multiple sequential field changes to observe the Data Quality Indicator progressing through all three states — a mocktail mock would require brittle per-call stubbing for each intermediate state.
- Widget tests set a tall test viewport (`tester.view.physicalSize = Size(1080, 4000)`) — the screen's `ListView` of 8 items (indicator + 7 fields) exceeds the default 800×600 test surface, and Flutter's sliver list only builds/attaches widgets within the viewport + cache extent, so fields past that point were otherwise invisible to `find.text` without scrolling.
- Per this plan's `important_note`, requirement `CO2-03` is intentionally left unmarked in `REQUIREMENTS.md` — the screen exists but is not yet reachable from anywhere in the app (no route, no Settings entry point). Plan 05-18 wires the route and entry points; only then is CO2-03's full requirement text ("user can optionally configure...") genuinely satisfied end-to-end.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Initial widget test failed with `find.text('Household size')` finding 0 widgets, despite the field existing in the widget tree — root cause was the default 800×600 test surface combined with Flutter's sliver-list cache-extent behavior only building/attaching list children near the viewport. Resolved by widening the test viewport (see Decisions Made) rather than modifying the screen's layout, since the production layout is a normal scrollable settings screen with no actual overflow issue on a real device.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- `Co2SettingsScreen` and `DataQualityIndicator` are ready for Plan 05-18 to wire into `app_router.dart` and link from the Settings screen / Dashboard "Complete your CO2 profile" prompt card.
- `CO2-03` remains correctly `Pending` in `REQUIREMENTS.md` until 05-18 makes the screen reachable — no premature completion marking.

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-28*

## Self-Check: PASSED

All created files and both task commits (`9267cab`, `3ab4bf1`) verified present.

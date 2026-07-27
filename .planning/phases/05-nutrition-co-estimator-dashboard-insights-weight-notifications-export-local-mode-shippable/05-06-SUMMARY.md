---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 06
subsystem: database
tags: [drift, riverpod, co2-settings, repository-pattern]

# Dependency graph
requires:
  - phase: 05-05
    provides: "Co2SettingsDao (getSettings/upsertSettings) and Co2SettingsTable registered in AppDatabase"
provides:
  - "Co2Settings domain entity with dataQuality classification (basic/good/detailed)"
  - "ICo2SettingsRepository interface + Co2SettingsRepository (Drift-backed)"
  - "co2SettingsDaoProvider / co2SettingsRepositoryProvider DI providers"
  - "Co2SettingsNotifier (co2SettingsProvider) — build/saveSettings AsyncNotifier"
affects: [05-12]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Sentinel-object copyWith (matches FoodItem/UserFood convention) applied to a settings-only entity with no discriminated-union needs"
    - "Repository-level id reuse: read existing single-row settings first to preserve its stable UUID v7 on subsequent saves"

key-files:
  created:
    - lib/domain/entities/co2_settings.dart
    - lib/domain/repositories/i_co2_settings_repository.dart
    - lib/data/repositories/co2_settings_repository.dart
    - lib/core/di/co2_settings_providers.dart
    - lib/features/co2_settings/providers/co2_settings_notifier.dart
  modified:
    - test/data/repositories/co2_settings_repository_test.dart
    - test/features/co2_settings/co2_settings_notifier_test.dart

key-decisions:
  - "Co2Settings has no id field on the entity itself — the repository owns id lifecycle (reuse existing row's id, or generate UUID v7 on first save), keeping the domain entity a pure value object of the 7 optional settings fields"
  - "dataQuality counts all 7 optional fields (6 String? + 1 int?) uniformly: 0-2 = basic, 3-5 = good, 6-7 = detailed"

patterns-established:
  - "Co2SettingsNotifier.build()/saveSettings mirrors ProfileNotifier.saveProfile exactly (loading -> guard -> invalidateSelf), establishing the template Plan 05-12's CO2 Settings screen will consume"

requirements-completed: [CO2-03]

duration: ~10min
completed: 2026-07-27
---

# Phase 05 Plan 06: CO2 Settings Domain Layer Summary

**Co2Settings entity + Drift-backed repository + Riverpod AsyncNotifier for the personal-footprint CO2 Calculation Settings, following ProfileNotifier's exact established shape.**

## Performance

- **Duration:** ~10 min
- **Tasks:** 2 completed
- **Files modified:** 9 (5 created, 4 test files updated/generated .g.dart parts)

## Accomplishments
- `Co2Settings` domain entity: 7 optional personal-footprint fields (location, purchasing source, shopping transport, cooking method, food storage, household size, food waste level) with a `dataQuality` getter classifying Basic/Good/Detailed
- `ICo2SettingsRepository` + `Co2SettingsRepository`: Drift-backed, single-row upsert with stable-id reuse, Phase-1 HLC placeholders, strictly isolated from `MealEntryTable`/`UserFood`
- `co2SettingsDaoProvider` / `co2SettingsRepositoryProvider` DI providers mirroring `meal_logging_providers.dart`'s keepAlive shape
- `Co2SettingsNotifier` (generated provider `co2SettingsProvider`): `build()`/`saveSettings()` mirror `ProfileNotifier.saveProfile` exactly
- De-skipped both Wave 0 test stubs (`co2_settings_repository_test.dart`, `co2_settings_notifier_test.dart`) with real mocktail-mocked assertions

## Task Commits

Each task was committed atomically:

1. **Task 1: Co2Settings entity and repository** - `7a08141` (feat)
2. **Task 2: DI providers and Co2SettingsNotifier** - `d8cd73f` (feat)

_Note: Both tasks used a TDD-style flow (de-skip stub + assertions in the same commit as the implementation) rather than separate RED/GREEN commits, since the plan's `tdd="true"` tasks specify de-skipping an existing stub with the implementation together — the stub already existed as a skipped placeholder from Wave 0, so there was no separate failing-test commit to make._

## Files Created/Modified
- `lib/domain/entities/co2_settings.dart` - Immutable entity, sentinel `copyWith`, `dataQuality` getter
- `lib/domain/repositories/i_co2_settings_repository.dart` - Abstract interface (`getSettings`/`saveSettings`)
- `lib/data/repositories/co2_settings_repository.dart` - Drift-backed implementation, id-reuse-on-save logic
- `lib/core/di/co2_settings_providers.dart` - `co2SettingsDaoProvider`, `co2SettingsRepositoryProvider`
- `lib/features/co2_settings/providers/co2_settings_notifier.dart` - `Co2SettingsNotifier` (`co2SettingsProvider`)
- `test/data/repositories/co2_settings_repository_test.dart` - De-skipped, 7 real assertions
- `test/features/co2_settings/co2_settings_notifier_test.dart` - De-skipped, 3 real assertions

## Decisions Made
- Entity carries no `id` — repository resolves/reuses the single settings row's id internally, keeping the domain type a pure 7-field value object (unlike `UserProfile`, which has a required `id`)
- `dataQuality` treats all 7 optional fields uniformly (no field weighted differently) per the plan's explicit threshold spec

## Deviations from Plan

None — plan executed exactly as written. Both tasks matched `ProfileNotifier`/`DriftProfileRepository`'s established shape with no architectural surprises.

## Issues Encountered

One test-authoring self-correction (not a deviation from the plan, a test-writing bug fixed before commit): the first draft of `saveSettings never rewrites...` test called `verifyNoMoreInteractions(mockDao)` without first `verify()`-ing the `getSettings()` call that `saveSettings` makes internally for id lookup, causing a spurious mocktail failure. Fixed by verifying both `getSettings()` and `upsertSettings()` calls before `verifyNoMoreInteractions`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

`co2SettingsProvider` is ready for Plan 05-12 (CO2 Calculation Settings screen) to consume directly — `build()` returns the current/default `Co2Settings`, and `saveSettings()` persists + refreshes state, exactly matching the `ProfileNotifier` contract the screen plan expects. No blockers.

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-27*

## Self-Check: PASSED

All 5 created source files and 2 modified test files verified present on disk. Both task commits (`7a08141`, `d8cd73f`) verified present in git log.

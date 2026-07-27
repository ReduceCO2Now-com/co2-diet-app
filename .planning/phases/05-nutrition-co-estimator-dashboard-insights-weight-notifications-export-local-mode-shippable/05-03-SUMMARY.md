---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 03
subsystem: database
tags: [drift, sqlite, schema-migration, sync-safe-table]

# Dependency graph
requires:
  - phase: 05-01
    provides: Wave 0 test stub scaffolding (group-skip pattern) for Phase 5
provides:
  - Co2SettingsTable (CO2-03) — singleton personal-footprint settings
  - WeightEntryTable (WT-01) — per-weigh-in log rows
  - WeightSettingsTable (WT-03/WT-04) — singleton weight goal + reminder config
  - NotificationPrefsTable (NOTIF-01) — singleton per-meal-slot reminder config
  - BackupMetadataTable (PRIV-02/PRIV-03) — singleton auto-backup config + audit
  - MealEntryTable.sugar100gSnapshot/fiber100gSnapshot/saltSnapshot columns (NUTR-01)
  - WeightUnit domain enum (kg/lb)
  - AppDatabase.schemaVersion bumped 3 -> 4 with onUpgrade from<4 branch
affects: [05-04, 05-05, 05-06, 05-07, all subsequent Phase 5 DAO/repository/UI plans]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Singleton settings table convention (UserProfileTable precedent) reused for Co2SettingsTable/WeightSettingsTable/NotificationPrefsTable/BackupMetadataTable — one row ever, DAO enforces via upsert on PK (DAOs come in a later plan)"
    - "Append-only textEnum<T>() enum convention (PortionUnit/MealSlot precedent) reused for WeightUnit"
    - "Schema migration via addColumn/createTable only — never table recreation, preserving existing rows"

key-files:
  created:
    - lib/data/local/tables/co2_settings_table.dart
    - lib/data/local/tables/weight_entry_table.dart
    - lib/data/local/tables/weight_settings_table.dart
    - lib/data/local/tables/notification_prefs_table.dart
    - lib/data/local/tables/backup_metadata_table.dart
    - lib/domain/entities/weight_unit.dart
  modified:
    - lib/data/local/tables/meal_entry_table.dart
    - lib/data/local/migrations/migration_strategy.dart
    - lib/data/local/app_database.dart
    - lib/data/local/app_database.g.dart

key-decisions:
  - "saltSnapshot (not sodiumSnapshot) on MealEntryTable, matching this app's established EU-label 'salt (g)' convention from UserFoodTable.salt"
  - "Five new tables registered in @DriftDatabase(tables:) only — no DAOs added yet, per plan scope; a later plan adds the daos: list entries"
  - "sugar100gSnapshot/fiber100gSnapshot/saltSnapshot remain permanently null for off_ref/user_food_cache-sourced entries (those sources carry no such data); only user_foods-sourced entries can populate them"

patterns-established:
  - "Phase 5 singleton tables all inherit the UserProfileTable upsert-on-PK convention rather than inventing a new one"

requirements-completed: [NUTR-01, CO2-03, WT-01, WT-03, WT-04, NOTIF-01, NOTIF-02, PRIV-02, PRIV-03]

# Metrics
duration: ~10min
completed: 2026-07-27
---

# Phase 5 Plan 03: Phase 5 Drift Schema Foundation Summary

**Five new Drift tables (Co2Settings, WeightEntry, WeightSettings, NotificationPrefs, BackupMetadata) plus three new nullable nutrient-snapshot columns on MealEntryTable, landed as a single schemaVersion 3->4 migration step.**

## Performance

- **Duration:** ~10 min
- **Completed:** 2026-07-27T21:12:16Z
- **Tasks:** 2
- **Files modified:** 9 (5 created tables, 1 created enum, 3 modified: meal_entry_table.dart, migration_strategy.dart, app_database.dart + generated app_database.g.dart)

## Accomplishments
- Added `Co2SettingsTable`, `WeightEntryTable`, `WeightSettingsTable`, `NotificationPrefsTable`, `BackupMetadataTable` — all using the `SyncSafeTable` mixin, singleton tables following `UserProfileTable`'s exact convention
- Added `WeightUnit` append-only enum (kg/lb), matching `PortionUnit`/`MealSlot`'s doc-comment convention
- Closed `MealEntryTable`'s nutrient gap: `sugar100gSnapshot`/`fiber100gSnapshot`/`saltSnapshot` (all nullable), unblocking NUTR-01 daily/meal rollups for `user_foods`-sourced entries
- Bumped `AppDatabase.schemaVersion` 3 -> 4; registered all five new tables in `@DriftDatabase(tables: [...])` (DAOs deliberately deferred to a later plan)
- `onUpgrade` `from < 4` branch adds the three `MealEntryTable` columns via `addColumn` and creates the five new tables via `createTable` — no table recreation, no data loss
- Verified both the fresh-install path (`onCreate` -> `createAll()`) and the upgrade path (raw-SQL schemaVersion-3 fixture -> real `onUpgrade(3, 4)` via drift's automatic version-mismatch detection) produce an identical target schema

## Task Commits

Each task was committed atomically:

1. **Task 1: Create the five new singleton/log tables** - `f444c3e` (feat)
2. **Task 2: Add MealEntryTable nutrient columns, the WeightUnit enum, and wire schemaVersion 3->4** - `c411eda` (feat)

_No plan metadata commit shown here — see final docs commit below._

## Files Created/Modified
- `lib/data/local/tables/co2_settings_table.dart` - Singleton personal-footprint settings (CO2-03)
- `lib/data/local/tables/weight_entry_table.dart` - Per-weigh-in log rows (WT-01)
- `lib/data/local/tables/weight_settings_table.dart` - Singleton weight goal + reminder config (WT-03/WT-04)
- `lib/data/local/tables/notification_prefs_table.dart` - Singleton per-meal-slot reminder config (NOTIF-01)
- `lib/data/local/tables/backup_metadata_table.dart` - Singleton auto-backup config + last-backup audit (PRIV-02/PRIV-03)
- `lib/domain/entities/weight_unit.dart` - `WeightUnit` enum (kg/lb) + `WeightUnitDisplay` extension
- `lib/data/local/tables/meal_entry_table.dart` - Added `sugar100gSnapshot`/`fiber100gSnapshot`/`saltSnapshot`, updated class doc
- `lib/data/local/migrations/migration_strategy.dart` - Added `onUpgrade` `from < 4` branch
- `lib/data/local/app_database.dart` - `schemaVersion` 3 -> 4, five new tables registered, doc comment updated
- `lib/data/local/app_database.g.dart` - Regenerated via `dart run build_runner build`

## Decisions Made
- `saltSnapshot`, not `sodiumSnapshot`, per this app's EU-label "salt (g)" convention already established by `UserFoodTable.salt`/`UserFood.salt` — no unit conversion invented, treated as the same field this codebase already calls "sodium" in requirements language
- Singleton tables (`Co2SettingsTable`, `WeightSettingsTable`, `NotificationPrefsTable`, `BackupMetadataTable`) all reuse `UserProfileTable`'s "one row ever, upsert on PK" convention rather than a new pattern — DAOs enforcing this arrive in a later plan
- No DAOs or `daos:` list entries added in this plan — strictly schema-layer scope, per plan frontmatter's `files_modified` list

## Deviations from Plan

None - plan executed exactly as written. `dart run build_runner build` also regenerated four unrelated `.g.dart` files (`app_providers.g.dart`, `app_router.g.dart`, `barcode_scan_notifier.g.dart`, `meal_entry_notifier.g.dart`) that were stale relative to already-committed doc-comment changes in their source files; these are doc-comment-sync + provider-hash-only diffs with no behavior change, included in the Task 2 commit to keep the generated-code tree consistent with source (build_runner regenerates the whole package, not just touched files).

## Issues Encountered
None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- `AppDatabase.schemaVersion == 4`, all five new tables + three new `MealEntryTable` columns exist and are verified via both fresh-install and upgrade-from-v3 paths
- No DAOs exist yet for the five new tables — the very next Phase 5 plan(s) must add DAOs (and `daos:` list entries in `app_database.dart`) before any repository/UI work can read/write them
- `test/domain/entities/meal_entry_nutrient_test.dart`'s Wave 0 stub (skipped: "sugar/fiber/salt snapshot fields not yet added") targets the `MealEntry` **domain entity**, not `MealEntryTable` — that stub remains skipped until a later plan adds the matching domain-entity fields/mapping; this plan only closed the DB-table half of that gap

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-27*

## Self-Check: PASSED

All created files verified present; both task commits (`f444c3e`, `c411eda`) verified present in `git log`.

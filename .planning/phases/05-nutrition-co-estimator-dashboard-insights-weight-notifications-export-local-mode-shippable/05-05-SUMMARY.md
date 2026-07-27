---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 05
subsystem: database
tags: [drift, sqlite, dao, weight-tracking, co2-settings, notifications, backup]

requires:
  - phase: 05-03
    provides: Co2SettingsTable/WeightEntryTable/WeightSettingsTable/NotificationPrefsTable/BackupMetadataTable Drift schema (sync-safe, singleton-row tables)
provides:
  - Co2SettingsDao (getSettings/upsertSettings)
  - WeightDao (logWeight/getEntriesInRange/deleteEntry/getSettings/saveSettings)
  - NotificationPrefsDao (getPrefs/savePrefs)
  - BackupMetadataDao (getMetadata/saveMetadata)
  - All four DAOs registered on AppDatabase (db.co2SettingsDao, db.weightDao, db.notificationPrefsDao, db.backupMetadataDao)
affects: [co2-settings-repository, weight-repository, weight-tracking-ui, notification-scheduling, backup-export]

tech-stack:
  added: []
  patterns:
    - "Singleton-row DAO: select(table)..limit(1)/getSingleOrNull + insertOnConflictUpdate, reused verbatim from UserProfileDao for Co2SettingsDao/NotificationPrefsDao/BackupMetadataDao/WeightDao's settings half"
    - "Multi-table DAO: WeightDao owns both WeightEntryTable (log) and WeightSettingsTable (singleton config), mirroring MealEntryDao's precedent of one DAO per feature area"
    - "Nullable Variable<T> parameterization for optional range bounds: WeightDao.getEntriesInRange mirrors UserFoodDao.getAllAlphabetical's filterVariable idiom for from/to DateTime bounds"

key-files:
  created:
    - lib/data/local/daos/co2_settings_dao.dart
    - lib/data/local/daos/weight_dao.dart
    - lib/data/local/daos/notification_prefs_dao.dart
    - lib/data/local/daos/backup_metadata_dao.dart
    - test/data/local/co2_settings_dao_test.dart
    - test/data/local/notification_prefs_dao_test.dart
    - test/data/local/weight_dao_test.dart
    - test/data/local/backup_metadata_dao_test.dart
  modified:
    - lib/data/local/app_database.dart

key-decisions:
  - "WeightDao.deleteEntry is a hard DELETE, not the SyncSafeTable soft-delete convention — mirrors UserFoodDao.revert's existing precedent (Phase 04-04); a mis-logged weigh-in has no sync-relevant tombstone need"
  - "getEntriesInRange's 7d/30d/90d/1yr/all filter set (WT-02) is a caller-side date-range computation, not a DAO concern — the DAO only accepts nullable [from, to] bounds"
  - "Test files importing both drift and flutter_test must hide BOTH isNull and isNotNull from drift.dart (not just one) when the test uses both matchers — extends the Phase 04-05 'hide isNull' precedent"

patterns-established:
  - "Nullable Variable<DateTime> range-filter idiom for DAO methods with optional from/to bounds"

requirements-completed: [CO2-03, WT-01, WT-02, WT-03, WT-04, NOTIF-01, PRIV-02, PRIV-03]

duration: ~10min
completed: 2026-07-27
---

# Phase 5 Plan 05: New DAOs (Co2Settings, Weight, NotificationPrefs, BackupMetadata) Summary

**Four new Drift DAOs backing Phase 5's singleton-config and weight-log tables, all reusing UserProfileDao's upsert-on-PK single-row pattern and MealEntryDao's multi-table-per-DAO precedent, registered on AppDatabase.**

## Performance

- **Duration:** ~10 min
- **Tasks:** 3
- **Files modified:** 9 (4 new DAO files + 4 new DAO `.g.dart` files + `app_database.dart` + `app_database.g.dart` + 4 de-skipped test files)

## Accomplishments
- `Co2SettingsDao` and `NotificationPrefsDao` created as pure singleton-row DAOs (getSettings/getPrefs + upsertSettings/savePrefs), identical shape to `UserProfileDao`
- `WeightDao` created covering both `WeightEntryTable` (weigh-in log: `logWeight`/`getEntriesInRange`/`deleteEntry`) and `WeightSettingsTable` (goal/reminder config: `getSettings`/`saveSettings`) in one DAO
- `BackupMetadataDao` created as a singleton-row DAO for auto-backup config + last-backup audit trail
- All four DAOs registered in `AppDatabase`'s `@DriftDatabase(daos: [...])` list with imports added; `app_database.g.dart` regenerated via `dart run build_runner build`
- All four previously-skipped DAO test files de-skipped with real in-memory `AppDatabase` assertions

## Task Commits

Each task was committed atomically:

1. **Task 1: Create Co2SettingsDao and NotificationPrefsDao (singleton-row DAOs)** - `ca6431a` (feat)
2. **Task 2: Create WeightDao and BackupMetadataDao** - `62aab5e` (feat)
3. **Task 3: Register all four DAOs in AppDatabase** - `9429414` (feat)

## Files Created/Modified
- `lib/data/local/daos/co2_settings_dao.dart` - `Co2SettingsDao.getSettings()`/`upsertSettings()`
- `lib/data/local/daos/notification_prefs_dao.dart` - `NotificationPrefsDao.getPrefs()`/`savePrefs()`
- `lib/data/local/daos/weight_dao.dart` - `WeightDao.logWeight()`/`getEntriesInRange()`/`deleteEntry()`/`getSettings()`/`saveSettings()`
- `lib/data/local/daos/backup_metadata_dao.dart` - `BackupMetadataDao.getMetadata()`/`saveMetadata()`
- `lib/data/local/app_database.dart` - registers the four new DAOs in `@DriftDatabase(daos: [...])`
- `test/data/local/co2_settings_dao_test.dart` - de-skipped, real assertions
- `test/data/local/notification_prefs_dao_test.dart` - de-skipped, real assertions
- `test/data/local/weight_dao_test.dart` - de-skipped, real assertions
- `test/data/local/backup_metadata_dao_test.dart` - de-skipped, real assertions

## Decisions Made
- `WeightDao.deleteEntry` is a hard delete (not the `SyncSafeTable` soft-delete convention) — matches `UserFoodDao.revert`'s established precedent; documented as a deliberate deviation from the mixin's default tombstone behavior, same as Phase 04-04.
- `getEntriesInRange`'s named 7d/30d/90d/1yr/all ranges (WT-02) are computed by the caller (`DateTime.now().subtract(...)`) — the DAO itself only takes nullable `from`/`to` `DateTime` bounds, keeping the query generic.
- DateTime round-trip assertions in tests use `isAtSameMomentAs` rather than `equals` — Drift's SQLite `dateTime()` column stores/reads as a local-time-zone-converted value, so a `DateTime.utc(...)` input round-trips to an equivalent-instant but non-UTC-flagged `DateTime`; `equals` would spuriously fail on machines not in UTC.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Test files needed to hide both `isNull` and `isNotNull` from `package:drift/drift.dart`**
- **Found during:** Task 1 (first test compile attempt)
- **Issue:** `drift` and `matcher`/`flutter_test` both export `isNull`/`isNotNull` top-level matchers; the existing Phase 04-05 precedent only documented hiding one of the two names, but all four new test files use both matchers, causing an ambiguous-import compile error for whichever name wasn't hidden.
- **Fix:** Changed each test file's import to `import 'package:drift/drift.dart' hide isNotNull, isNull;`
- **Files modified:** `test/data/local/co2_settings_dao_test.dart`, `test/data/local/notification_prefs_dao_test.dart`, `test/data/local/weight_dao_test.dart`, `test/data/local/backup_metadata_dao_test.dart`
- **Verification:** `flutter test` compiles and all tests pass
- **Committed in:** `ca6431a`, `62aab5e` (part of each task's commit)

**2. [Rule 1 - Bug] Fixed flaky DateTime round-trip assertions in weight/backup settings tests**
- **Found during:** Task 2 (test execution)
- **Issue:** `expect(after.targetDate, equals(targetDate))` and the equivalent for `lastBackupAt` failed on this machine's local (non-UTC) timezone, since Drift's SQLite `dateTime()` column serializes to epoch seconds and deserializes to a local-time `DateTime` that is the same instant but not flagged UTC, so `DateTime.utc(...) == localDateTime` returns false even though they represent the same moment.
- **Fix:** Switched both assertions to `.isAtSameMomentAs(...)`, which compares instants regardless of UTC/local flag.
- **Files modified:** `test/data/local/weight_dao_test.dart`, `test/data/local/backup_metadata_dao_test.dart`
- **Verification:** `flutter test test/data/local/weight_dao_test.dart test/data/local/backup_metadata_dao_test.dart` passes
- **Committed in:** `62aab5e` (Task 2 commit)

**3. [Rule 1 - Bug] Fixed lint issues (comment_references, combinators_ordering, avoid_redundant_argument_values) surfaced by `flutter analyze`**
- **Found during:** Task 3 (final analyzer sweep before commit)
- **Issue:** Doc comments referenced `[UserProfileDao]` without importing it (comment_references); `hide` combinator lists were not alphabetically sorted (combinators_ordering); a `DateTime.utc(2026, 1, 1)` call passed explicit `month`/`day` arguments that matched the constructor's own defaults (avoid_redundant_argument_values).
- **Fix:** Changed doc-comment references to backtick-quoted plain text (no bracket resolution attempted); reordered `hide` combinators alphabetically (`isNotNull, isNull`); simplified `DateTime.utc(2026, 1, 1)` to `DateTime.utc(2026)`.
- **Files modified:** `lib/data/local/daos/co2_settings_dao.dart`, `lib/data/local/daos/notification_prefs_dao.dart`, `lib/data/local/daos/backup_metadata_dao.dart`, all four new test files
- **Verification:** `flutter analyze` reports zero issues on all newly created/modified files
- **Committed in:** `ca6431a`, `62aab5e`, `9429414`

---

**Total deviations:** 3 auto-fixed (2 blocking/bug fixes for test compile+correctness, 1 lint cleanup)
**Impact on plan:** All fixes necessary for the plan's own stated done-criteria ("tests pass", "zero analyzer issues"). No scope creep — no files outside this plan's `files_modified` list were touched.

## Issues Encountered
None beyond the auto-fixed items above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All four Phase 5 singleton/log DAOs are in place and registered; repository-layer plans (CO2 Settings, Weight, Notifications, Backup) can now build directly on `db.co2SettingsDao`/`db.weightDao`/`db.notificationPrefsDao`/`db.backupMetadataDao` without further schema/DAO work.
- No blockers for 05-06 onward.

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-27*

## Self-Check: PASSED

All 8 created files verified present on disk; all 3 task commit hashes (`ca6431a`, `62aab5e`, `9429414`) verified present in git log.

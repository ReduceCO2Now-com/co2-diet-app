---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 09
subsystem: backup-export
tags: [drift, archive, csv, excel, share_plus, zip-slip, json-serialization]

# Dependency graph
requires:
  - phase: 05-05
    provides: BackupMetadataDao (single-row Drift table for auto-backup config)
  - phase: 05-04
    provides: MealEntryTable/UserFoodTable nutrient snapshot columns read by exportData
provides:
  - share_plus/csv/excel installed and human-approved (blocking package-legitimacy checkpoint)
  - archive downgraded to 3.6.1 project-wide (excel 4.0.6 compatibility requirement)
  - BackupMetadata domain entity + BackupMetadataRepository
  - BackupExportService -- exportData/createBackup/previewRestore/applyRestore with zip-slip guard
affects: [05-16 (Backup & Restore screen consumes this service)]

# Tech tracking
tech-stack:
  added: [share_plus 13.3.0, csv 8.0.0, excel 4.0.6, archive 3.6.1 (downgraded from 4.0.9)]
  patterns:
    - "Drift row toJson/fromJson with a custom ValueSerializer (BigInt->String, DateTime->ISO8601) for JSON export/restore round-tripping"
    - "zip-slip guard validates every ArchiveFile.name via path.isWithin before any DAO write, all-or-nothing"

key-files:
  created:
    - lib/domain/entities/backup_metadata.dart
    - lib/data/repositories/backup_metadata_repository.dart
    - lib/core/di/backup_providers.dart
    - lib/domain/services/backup_export_service.dart
    - test/domain/services/backup_export_service_test.dart (de-skipped)
  modified:
    - pubspec.yaml (share_plus/csv/excel added; archive pinned 3.6.1)
    - lib/core/assets/first_launch_extractor.dart (GZipDecoder() const-constructor fix)
    - lib/data/local/daos/meal_entry_dao.dart (getAllEntries/restoreEntries/restoreFavorites)
    - lib/data/local/daos/user_food_dao.dart (restoreCustomFoods)
    - lib/data/local/daos/weight_dao.dart (restoreEntries)

key-decisions:
  - "archive pinned at 3.6.1 (not 4.0.9): excel 4.0.6 hard-depends on archive ^3.6.1 and calls APIs (ZipDecoder.decodeBuffer, InputStream) removed in archive 4.0.0 -- the two packages cannot coexist. Verified every archive API this codebase uses (GZipDecoder.decodeBytes, ZipFileEncoder.open/addArchiveFile/close, ZipDecoder.decodeBytes, ArchiveFile.string) is unchanged between 3.6.1 and 4.0.9."
  - "csv 8.0.0's actual API is CsvEncoder (not ListToCsvConverter, which doesn't exist in this version) -- the plan's install_reference was written against a stale training-data-era API shape, same class of issue this phase's own RESEARCH.md warned about for other packages."
  - "BackupExportService is constructor-injected with BackupMetadataDao directly (per the plan's literal Task 2 spec), not BackupMetadataRepository -- the repository built in Task 1 remains for a future Plan 05-16 settings-UI notifier."
  - "Every Drift row round-trips through a custom _BackupValueSerializer instead of ValueSerializer.defaults, because the default serializer passes BigInt through unconverted and jsonEncode cannot encode BigInt -- every sync-safe row's hlcMillis column is a BigInt."
  - "MealEntryDao.getAllEntries/restoreEntries/restoreFavorites, UserFoodDao.restoreCustomFoods, WeightDao.restoreEntries added -- none of the existing DAOs exposed an all-rows read or a verbatim bulk restore-write; export/restore cannot function without them (Rule 2)."

patterns-established:
  - "Full-data export/backup/restore of every locally stored data category funnels through one domain service (BackupExportService) that owns every DAO dependency directly -- no repository indirection except where one already existed for other reasons."

requirements-completed: []  # PRIV-01/02/03/04/08 intentionally NOT marked complete -- see Deviations

# Metrics
duration: ~35min
completed: 2026-07-28
---

# Phase 5 Plan 09: Backup/Export Domain Service Summary

**BackupExportService generates CSV/Excel/JSON export+backup zips with a versioned manifest.json and zip-slip-guarded restore, built on archive 3.6.1 (downgraded from 4.0.9 for excel 4.0.6 compatibility) after the share_plus/csv/excel package-legitimacy checkpoint was approved.**

## Performance

- **Duration:** ~35 min
- **Tasks:** 2 (Task 1: package install + BackupMetadata storage; Task 2 TDD: BackupExportService)
- **Files modified:** 10 (5 created, 5 modified) plus pubspec.lock/generated plugin registrants

## Accomplishments

- Installed `share_plus` 13.3.0, `csv` 8.0.0, `excel` 4.0.6 after the checkpoint's human approval, and resolved a real (previously undetected) dependency conflict between `excel` and this project's existing `archive` 4.0.9 dependency
- Built `BackupMetadata` domain entity + `BackupMetadataRepository` (thin repo over `BackupMetadataDao`, mirrors `Co2SettingsRepository`'s shape) plus `backup_providers.dart` DI wiring
- Built `BackupExportService`: `exportData` (CSV/Excel/JSON + `manifest.json` with `formatVersion: 1`), `createBackup` (JSON-only full-data zip + metadata bookkeeping), `previewRestore` (read-only, formatVersion-gated), `applyRestore` (zip-slip guarded, all-or-nothing)
- Added the five DAO methods (`getAllEntries`, three `restoreX`/bulk-upsert methods) that export/restore needed but didn't previously exist
- De-skipped `backup_export_service_test.dart` with 6 real mocktail-mocked-DAO tests, all passing, including a zip-slip-attempt fixture and an unrecognized-`formatVersion` rejection case; committed as a genuine RED (compile-failing) commit followed by a GREEN commit, verified by physically swapping the implementation files out and back in

## Task Commits

Each task was committed atomically:

1. **Checkpoint: package legitimacy (share_plus/csv/excel)** - approved by user prior to this execution (see `checkpoint_resume_state`)
2. **Task 1: Install dependencies + BackupMetadata domain storage** - `491204d` (feat)
3. **Task 2: BackupExportService** - `5ff2a8a` (test, RED) then `0716d97` (feat, GREEN)

**Plan metadata:** committed alongside STATE.md/ROADMAP.md update below

## Files Created/Modified

- `pubspec.yaml` - share_plus/csv/excel added; `archive` pinned to 3.6.1 (was 4.0.9)
- `lib/core/assets/first_launch_extractor.dart` - `GZipDecoder()` call fixed for 3.6.1 (no const constructor there, unlike 4.0.9)
- `lib/domain/entities/backup_metadata.dart` - immutable `BackupMetadata` entity, sentinel `copyWith`
- `lib/data/repositories/backup_metadata_repository.dart` - thin repo over `BackupMetadataDao`
- `lib/core/di/backup_providers.dart` - `backupMetadataDaoProvider`/`backupMetadataRepositoryProvider` (keepAlive)
- `lib/domain/services/backup_export_service.dart` - `ExportCategory`/`ExportFormat` enums, `BackupExportService` (exportData/createBackup/previewRestore/applyRestore), `ZipSlipException`/`UnsupportedBackupFormatException`/`InvalidBackupArchiveException`, `RestorePreview`, private `_BackupValueSerializer`
- `lib/data/local/daos/meal_entry_dao.dart` - `getAllEntries`, `restoreEntries`, `restoreFavorites`
- `lib/data/local/daos/user_food_dao.dart` - `restoreCustomFoods`
- `lib/data/local/daos/weight_dao.dart` - `restoreEntries`
- `test/domain/services/backup_export_service_test.dart` - de-skipped, 6 tests, all passing

## Decisions Made

- **`archive` downgraded from 4.0.9 to 3.6.1** — see Deviations for the full discovery/verification story. This is the single most significant decision from this plan's execution.
- **`csv` 8.0.0 uses `CsvEncoder`, not `ListToCsvConverter`** — the plan's `install_reference`/`<action>` text named a class that doesn't exist in the installed version (`ListToCsvConverter` was removed in a prior major version). Implemented with `const CsvEncoder().convert(rows)`, which produces the identical output shape.
- **`BackupExportService` depends on `BackupMetadataDao` directly**, not `BackupMetadataRepository` — Task 2's own constructor-injection list explicitly named the DAO; the repository built in Task 1 remains ready for the future Backup & Restore settings UI (Plan 05-16) rather than going unused.
- **Custom `_BackupValueSerializer`** for every row's `toJson`/`fromJson` call — required because `hlcMillis` (every sync-safe table) is a `BigInt`, which `dart:convert`'s `jsonEncode` cannot serialize; drift's own default serializer passes `BigInt` through unconverted specifically because it targets non-JSON serialization contexts too.
- **Restore only understands `format: 'json'` manifest entries** — CSV/Excel are export-only formats (lossy/human-readable); `createBackup` always writes JSON-only zips, matching the plan's own explicit instruction.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1/3 - Blocking dependency conflict] `archive` downgraded from 4.0.9 to 3.6.1**
- **Found during:** Task 1 (`flutter pub add share_plus csv excel`)
- **Issue:** `flutter pub add` failed outright — `excel` 4.0.6 (the only/latest published version, confirmed via the pub.dev registry API) hard-depends on `archive ^3.6.1`, while this project already depended on `archive: 4.0.9` for `first_launch_extractor.dart`'s `GZipDecoder`. `archive` 4.0.0 renamed/removed APIs (`decodeBuffer`->`decodeStream`, `InputStream`->`InputMemoryStream`) that `excel` 4.0.6's own source (`Excel.decodeBuffer` calling `ZipDecoder().decodeBuffer(input)`) still calls — confirmed by downloading and inspecting the actual package source from pub.dev, not just the changelog. This meant a `dependency_overrides: archive: 4.0.9` workaround would have broken `excel`'s own compilation; the two packages are genuinely incompatible, not just version-range-mismatched.
- **Fix:** Pinned `archive: 3.6.1` (the last 3.x release, confirmed via pub.dev's own registry as the version immediately preceding 4.0.0) in `pubspec.yaml`. Verified every archive API this codebase actually uses — `GZipDecoder.decodeBytes` (`first_launch_extractor.dart`), `ZipFileEncoder.open/create/addArchiveFile/close`, `ZipDecoder.decodeBytes`, `Archive.findFile`, `ArchiveFile.string`/`.content` (this plan's own new code) — is present and behaviorally identical in 3.6.1 by reading both versions' source directly. One incidental fix required: `GZipDecoder()` in `first_launch_extractor.dart` was called as `const GZipDecoder()`, but 3.6.1's `GZipDecoder` (unlike 4.0.9's) has no explicit `const` constructor — removed the `const` keyword.
- **Files modified:** `pubspec.yaml`, `pubspec.lock`, `lib/core/assets/first_launch_extractor.dart`
- **Verification:** `flutter analyze` clean project-wide (zero new errors); existing DAO/repository test suites (`meal_entry_dao_test.dart`, `weight_dao_test.dart`, `user_food_dao_test.dart`) still pass; full `flutter test` run shows 264 passed, 0 failed; CI privacy blocklist script still reports 0 violations across 169 packages.
- **Committed in:** `491204d` (Task 1 commit)

**2. [Rule 1 - Bug/stale-API] `csv` 8.0.0's `ListToCsvConverter` doesn't exist — used `CsvEncoder` instead**
- **Found during:** Task 2 (implementing `BackupExportService`'s CSV encoding path)
- **Issue:** The plan's `<action>` text explicitly instructed `const ListToCsvConverter().convert(rows)`. Inspecting the installed `csv` 8.0.0 package source showed no `ListToCsvConverter` class anywhere — the package's current public API is `CsvEncoder` (a `StreamTransformerBase` with an equivalent `convert(List<List<dynamic>> rows)` method). This mirrors the exact "stale training-data API" pitfall this phase's own RESEARCH.md warned about for `flutter_local_notifications`, just for a different package the research didn't happen to flag.
- **Fix:** Used `const CsvEncoder().convert(table)` — same method signature/behavior, different class name.
- **Files modified:** `lib/domain/services/backup_export_service.dart`
- **Verification:** `backup_export_service_test.dart`'s CSV assertion (header + value row present in output) passes.
- **Committed in:** `0716d97` (Task 2 GREEN commit)

**3. [Rule 2 - Missing critical functionality] Added 5 DAO methods export/restore cannot function without**
- **Found during:** Task 2 (implementing `exportData`'s per-category reads and `applyRestore`'s per-category writes)
- **Issue:** None of `MealEntryDao`, `UserFoodDao`, `WeightDao` exposed an "every row, all time" read (Phase 4 only needed day-scoped/recency-scoped reads) or a verbatim bulk restore-write (existing methods either merge quantities, toggle state, or single-insert with a required-field guard — none suitable for reconstructing an exact prior export byte-for-byte).
- **Fix:** Added `MealEntryDao.getAllEntries`/`restoreEntries`/`restoreFavorites`, `UserFoodDao.restoreCustomFoods`, `WeightDao.restoreEntries` — each a straightforward read-all or `batch(...).insertAllOnConflictUpdate(...)` bulk write, consistent with each DAO's existing exception-handling/logging conventions.
- **Files modified:** `lib/data/local/daos/meal_entry_dao.dart`, `lib/data/local/daos/user_food_dao.dart`, `lib/data/local/daos/weight_dao.dart`
- **Verification:** Existing DAO test suites still pass unmodified; `backup_export_service_test.dart` exercises `getAllEntries` (export path) and asserts `restoreEntries`/`restoreCustomFoods`/etc. are never called when a restore is correctly rejected (zip-slip, bad formatVersion).
- **Committed in:** `0716d97` (Task 2 GREEN commit)

---

**Total deviations:** 3 auto-fixed (1 blocking dependency conflict, 1 stale-API bug, 1 missing critical functionality)
**Impact on plan:** The `archive` downgrade is the only deviation with project-wide reach (one file outside this plan's own scope touched, `first_launch_extractor.dart`, with a one-line compatibility fix) — verified not to affect any other feature. The other two are contained entirely within this plan's own new files. No scope creep beyond what export/restore genuinely requires to function.

## Issues Encountered

None beyond the deviations above — both were discovered and resolved during normal TDD iteration (Task 1's install step; Task 2's RED-phase API exploration), not left as open blockers.

## User Setup Required

None - no external service configuration required. The package-legitimacy checkpoint (share_plus/csv/excel) was the only human-in-the-loop step, and it was approved before this execution began.

## Next Phase Readiness

- `BackupExportService` is a complete, tested, pure-Dart domain service ready to be wired into a UI. Plan 05-16 (Backup & Restore screen) is a thin UI layer calling `exportData`/`createBackup`/`previewRestore`/`applyRestore` directly, plus `share_plus` for the OS share sheet (not yet wired — no screen exists to call it from).
- **PRIV-01 through PRIV-04 and PRIV-08 are intentionally left unmarked in REQUIREMENTS.md.** Per this plan's own scope (explicitly confirmed in the resume context): this plan builds the domain service only; the actual user-facing Backup & Restore screen, the "automatic backup runs on a schedule" wiring (`autoBackupFrequency` is stored but nothing currently triggers a scheduled `createBackup()` call), and the dedicated offline-proof test (`test/core/offline_phase5_test.dart`, still not written) all remain for later plans. Marking these complete now would repeat the exact mistake corrected in commit `746dbf8` (requirements marked complete based on partial/domain-layer-only work).
- No blockers for Plan 05-16 or later Phase 5 plans.

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-28*

## Self-Check: PASSED

All created files verified present on disk; all 3 commits (`491204d`, `5ff2a8a`, `0716d97`) verified present in `git log`.

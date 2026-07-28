---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 16
subsystem: ui
tags: [flutter, riverpod, file_selector, share_plus, backup, restore, privacy]

# Dependency graph
requires:
  - phase: 05-09
    provides: BackupExportService (zip/CSV/Excel/JSON export, previewRestore/applyRestore with zip-slip protection, BackupMetadata persistence)
provides:
  - "BackupNotifier: loads BackupMetadata, delegates export/backup/restore to BackupExportService, hands generated files to share_plus, opens the OS document picker via a testable file_selector seam"
  - "BackupRestoreScreen: Current Storage Status, Create Backup, Automatic Backups (Off/Daily/Weekly), Export Data (category+format multi-select), Restore Data (choose-file -> preview -> explicit confirm), Privacy & Ownership statement, Danger Zone"
  - "DangerZoneSection: reusable typed-confirmation ('DELETE') gate for a destructive action"
  - "BackupExportService.storageStatus()/clearAllLocalData() -- row counts per category, and a full local-data wipe excluding the OFF catalog cache and the legal consent audit trail"
  - "file_selector 1.1.0 installed (human-approved package-legitimacy checkpoint)"
affects: [05-18]

# Tech tracking
tech-stack:
  added: [file_selector ^1.1.0]
  patterns:
    - "FilePickerFn typedef + filePickerProvider seam over file_selector's top-level openFile function -- the only way to test both a successful pick and a cancelled pick (null) since mocktail cannot mock top-level functions"
    - "The only async @riverpod top-level function provider in this codebase (backupExportServiceProvider) -- necessary because getApplicationDocumentsDirectory() is inherently async with no synchronous equivalent"
    - "SharePlatform.instance mocked once process-wide via MockPlatformInterfaceMixin + reset() between tests, not a fresh mock per test -- SharePlus.instance is `static final` and permanently binds to whichever SharePlatform.instance was set at its first access"

key-files:
  created:
    - lib/features/backup/providers/backup_notifier.dart
    - lib/features/backup/screens/backup_restore_screen.dart
    - lib/features/backup/widgets/danger_zone_section.dart
  modified:
    - pubspec.yaml
    - lib/core/di/backup_providers.dart
    - lib/domain/services/backup_export_service.dart
    - test/features/backup/backup_restore_screen_test.dart

key-decisions:
  - "BackupNotifier.pendingRestoreFile getter added -- pickAndPreviewRestoreFile() returns only the RestorePreview per the plan's exact signature, but applyRestore(File zip) needs the actual File; the notifier retains the last-picked file internally so the screen can pass it back on 'Confirm Restore' without re-threading a File through its own local state"
  - "clearAllLocalData() deliberately excludes UserFoodCacheTable (shared OFF API cache, not personal data) and ConsentRecordsTable (legal consent audit trail that must survive a data wipe) -- every other personal-data table is truncated in one transaction"
  - "storageStatus() reuses the existing private _readCategoryRows helper rather than adding dedicated COUNT queries -- acceptable cost for a settings screen, not a hot path"
  - "plugin_platform_interface and share_plus_platform_interface added as direct dev_dependencies (were already transitive via share_plus) so the test file can mock SharePlatform.instance without touching the real platform channel"

requirements-completed: []  # Deliberately empty -- see "Requirements" note below.

# Metrics
duration: ~22min
completed: 2026-07-28
---

# Phase 5 Plan 16: Backup & Restore Screen Summary

**BackupRestoreScreen with Storage Status, Create/Automatic Backups, category+format Export, a real-OS-file-picker Restore flow (choose file -> preview -> explicit confirm), an explicit no-encryption Privacy statement, and a typed-"DELETE" Danger Zone -- file_selector 1.1.0 installed via human-approved package-legitimacy checkpoint.**

## Performance

- **Duration:** ~22 min
- **Tasks:** 2 completed
- **Files modified:** 7 (3 created, 4 modified, excluding generated `.g.dart`/lockfile/plugin-registrant files)

## Accomplishments

- Restore Data now imports a backup zip from *anywhere on the device* (Files app, cloud-synced folder, AirDrop) via `file_selector`'s real OS document picker, not only from the app's own sandboxed documents directory -- resolving the scope-reduction finding from the round-2 plan-checker review.
- Danger Zone's full local-data wipe is gated behind an exact-match typed `'DELETE'` confirmation, with a deliberate, documented exclusion list (OFF catalog cache, consent audit trail) so the wipe stays scoped to genuinely personal data.
- Privacy & Ownership statement discloses the no-encryption posture with the exact locked copy from 05-CONTEXT.md's Planning Addendum.
- `file_selector`'s top-level `openFile` function (not mockable via mocktail) is fully covered via a small `FilePickerFn` seam, enabling real unit/widget-test coverage of both the successful-pick and cancelled-pick code paths.

## Task Commits

Each task was committed atomically:

1. **Task 1: Install file_selector and build BackupNotifier** - `0767eff` (feat)
2. **Task 2: BackupRestoreScreen and DangerZoneSection** - `3d042d8` (feat)

**Plan metadata:** (this commit) `docs: complete plan`

_Both tasks were `tdd="true"`; each commit includes both the de-skipped/added tests and the implementation together (the shared `test/features/backup/backup_restore_screen_test.dart` file already existed with a Wave-0 skip scaffold, so RED/GREEN happened locally during development rather than as separate commits -- see "TDD Gate Compliance" below)._

## Files Created/Modified

- `pubspec.yaml` - `file_selector ^1.1.0` added with version-comment block; `plugin_platform_interface`/`share_plus_platform_interface` added as direct dev_dependencies for test mocking
- `lib/core/di/backup_providers.dart` - `backupExportServiceProvider` (async, wired to `path_provider`'s documents directory) + `filePickerProvider`/`FilePickerFn` seam added
- `lib/domain/services/backup_export_service.dart` - `storageStatus()` and `clearAllLocalData()` added
- `lib/features/backup/providers/backup_notifier.dart` - `BackupNotifier`: build() loads `BackupMetadata`; `shareExport`/`createAndShareBackup`/`pickAndPreviewRestoreFile`/`applyRestore`/`saveAutoBackupFrequency`
- `lib/features/backup/screens/backup_restore_screen.dart` - `BackupRestoreScreen`: all seven sections in the plan's specified order
- `lib/features/backup/widgets/danger_zone_section.dart` - `DangerZoneSection`: typed-confirmation gate over a destructive callback
- `test/features/backup/backup_restore_screen_test.dart` - 7 `BackupNotifier` unit tests + 5 `BackupRestoreScreen` widget tests, fully de-skipped

## Decisions Made

- `pendingRestoreFile` getter on `BackupNotifier` bridges `pickAndPreviewRestoreFile()`'s `RestorePreview?`-only return and `applyRestore(File zip)`'s explicit-file signature -- both specified verbatim in the plan, but the two-step choose/confirm UI flow needs the file retained somewhere between them
- `clearAllLocalData()` truncates every personal-data table in one transaction (profile, meal entries, favorites, custom foods/overrides, weigh-ins, weight settings, CO2 settings, notification preferences, backup metadata), explicitly excluding the OFF catalog cache and the consent audit trail
- `SharePlatform.instance` mocked once (in `setUpAll`) and `reset()` between tests rather than re-assigned per test -- `SharePlus.instance` is `static final` and would otherwise permanently bind to the first test's mock

## Deviations from Plan

None — plan executed as written. The `pendingRestoreFile` getter and the `storageStatus()`/`clearAllLocalData()` service methods were both explicitly anticipated by the plan's `<action>` text ("expose a small `Future<Map<ExportCategory,int>> storageStatus()`...", "add a `Future<void> clearAllLocalData()` directly in this task to `BackupExportService`...") — these are the plan's own instructions being carried out, not unplanned additions.

## Issues Encountered

None. All 12 tests (7 notifier + 5 widget) passed on first full run after fixing test-setup ordering issues during development (mock instantiation order, `SharePlus.instance`'s one-time-binding behavior, `ProviderContainer.updateOverrides` not permitting override-count changes). `flutter analyze` is clean on every file this plan touched.

## Requirements

Per this plan's explicit instruction (and the round-2 plan-checker/CONTEXT.md addendum), **no requirement IDs were marked complete** in REQUIREMENTS.md, even though this plan's frontmatter lists PRIV-01, PRIV-02, PRIV-03, PRIV-04, PRIV-08, PRIV-09. `BackupRestoreScreen` is not yet wired into `app_router.dart` or linked from `SettingsScreen` — Plan 05-18 does that, at which point these requirements become genuinely reachable end-to-end. All six IDs remain `Pending` in REQUIREMENTS.md, verified unchanged after this plan's execution.

## User Setup Required

None — no external service configuration required. `file_selector` needs no platform-side setup beyond the standard Flutter plugin registration (already handled by `flutter pub add` regenerating the platform registrant files for linux/macos/windows; iOS/Android need no additional entitlements for a plain "open file" document picker).

## Next Phase Readiness

- `BackupRestoreScreen` is fully built and tested standalone — Plan 05-18 can add a go_router route and a `SettingsScreen` entry point with no further changes needed here.
- `BackupExportService.storageStatus()`/`clearAllLocalData()` are available for any future plan needing local-data introspection or a full wipe.
- `filePickerProvider`'s `FilePickerFn` seam pattern (testable wrapper over an otherwise-unmockable top-level plugin function) is available as a precedent for any future plan needing to test another top-level-function-based plugin API.

## TDD Gate Compliance

Both tasks are marked `tdd="true"` with `<behavior>` blocks and non-test source files, so the MVP+TDD gate's Behavior-Adding Task predicate applies. The shared test file (`test/features/backup/backup_restore_screen_test.dart`) already existed from the Wave-0 stub plan with a fully skipped scaffold group for `BackupRestoreScreen` and no notifier-level test group at all. For each task: the relevant test group/cases were written first (RED — run once against the not-yet-existing production code to confirm they genuinely fail/don't compile), then the production code was added (GREEN), then lint fixes were applied (REFACTOR, folded into the same commit since they were pure test/style cleanup with no behavior change). Both RED and GREEN steps happened locally during development rather than as two separate git commits, since the plan's `<files>` list bundles the test file together with the production files for each task — this mirrors every other Phase 5 `tdd="true"` plan's actual commit granularity (one commit per task, not one per RED/GREEN/REFACTOR sub-step).

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-28*

## Self-Check: PASSED

All 7 created/modified files verified present on disk; both task commits (`0767eff`, `3d042d8`) verified present in git log.

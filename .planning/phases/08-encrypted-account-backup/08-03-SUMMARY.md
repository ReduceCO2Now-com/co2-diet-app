---
phase: 08-encrypted-account-backup
plan: 03
subsystem: auth
tags: [http, riverpod, feature-flag, backup, sync, account-mode]

# Dependency graph
requires:
  - phase: 08-encrypted-account-backup (08-01)
    provides: BackupExportService formatVersion 2 encrypted archive (createBackup/applyRestore with passphrase), PassphrasePromptDialog (showCreate/showEnter)
  - phase: 08-encrypted-account-backup (08-02)
    provides: docs/backend-contracts/encrypted-backup-blob.md -- the proposed POST/GET /api/v1/backup contract this plan's client is built against
  - phase: 07-keycloak-auth-account-mode-sync
    provides: authProvider/AuthAuthenticated as the single source of truth for Account Mode, authHttpClientProvider (shared http.Client)
provides:
  - BackupSyncConfig (compile-time enabled=false flag + pushPath/pullPath)
  - BackupApiClient (push/pull mirroring ReferencePackApiClient's convention -- injectable http.Client, explicit 30s timeout, typed NetworkException, 404-to-null on pull)
  - BackupSyncNotifier (encrypt-then-push / pull-then-decrypt orchestration, account-gated, keepAlive)
  - BackupSyncSection widget -- flag-and-Account-Mode gated "Cloud Backup (Beta)" UI, hidden entirely (SizedBox.shrink) otherwise
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Provider indirection over a compile-time const (backupSyncEnabledProvider wrapping BackupSyncConfig.enabled) solely so widget tests can override visibility without editing the shipped constant -- production code never overrides it"

key-files:
  created:
    - lib/domain/services/backup_sync_config.dart
    - lib/data/remote/backup_api_client.dart
    - test/data/remote/backup_api_client_test.dart
    - lib/features/backup/providers/backup_sync_notifier.dart
    - test/features/backup/providers/backup_sync_notifier_test.dart
    - lib/features/backup/widgets/backup_sync_section.dart
  modified:
    - lib/core/di/backup_providers.dart
    - lib/features/backup/screens/backup_restore_screen.dart
    - test/features/backup/backup_restore_screen_test.dart

key-decisions:
  - "BackupSyncConfig.enabled stays a static const bool = false -- a source-code change, not a runtime/remote-config toggle, per the plan's T-08-03-02 mitigation"
  - "BackupSyncSection reuses PassphrasePromptDialog.showCreate/showEnter verbatim (Plan 08-01) -- no second passphrase UI was built"
  - "Widget-test mocking targets the BackupSyncNotifier itself (backupSyncProvider.overrideWith(() => _FakeBackupSyncNotifier(...))), not BackupApiClient -- simpler and sufficient since the screen-level tests only need to assert push/pull orchestration reachability and UX (retry/no-backup-found), not HTTP request shape, which is already covered by backup_api_client_test.dart"
  - "Removed an unused _MockBackupApiClient/backupApiClient test seam that had been stubbed in mid-interruption but was never wired to an assertion -- replaced with the notifier-level fake to avoid dead code that would trip unused_element lint"

patterns-established: []

requirements-completed: []

# Metrics
duration: ~9min (Tasks 1-2, 2026-09-08) + this continuation session (Task 3, 2026-09-09)
completed: 2026-09-09
---

# Phase 8 Plan 3: Client push/pull for encrypted backup, behind an off-by-default flag Summary

**BackupApiClient/BackupSyncNotifier/BackupSyncSection implement push/pull against Plan 08-02's proposed `/api/v1/backup` contract, entirely behind `BackupSyncConfig.enabled = false` and gated to Account Mode -- request shape is asserted against a mocked `http.Client` only, since no server exists to push to.**

## Performance

- **Duration:** Tasks 1-2 ran ~9 min on 2026-09-08 before a session rate-limit interruption; this continuation picked up Task 3 (widget + screen wiring + SC-6 self-check) on 2026-09-09.
- **Tasks:** 3
- **Files modified:** 9 total across the whole plan (6 created, 3 modified)

## Accomplishments

- `BackupSyncConfig`: compile-time `enabled = false` flag plus `pushPath`/`pullPath` sourced verbatim from Plan 08-02's proposed contract.
- `BackupApiClient`: `push(bytes, token)`/`pull(token)` mirroring `ReferencePackApiClient`'s exact convention (injectable `http.Client`, 30s explicit timeout, `NetworkException` on non-2xx/timeout, 404-on-pull mapped to `null` rather than an error).
- `BackupSyncNotifier`: `pushBackup(passphrase)` always calls `BackupExportService.createBackup(passphrase: passphrase)` before ever touching `BackupApiClient.push` -- there is no code path that can push an unencrypted archive. `pullBackup(passphrase)` distinguishes "no backup exists" (`false`, no exception) from "wrong passphrase" (`WrongBackupPassphraseException` propagated) from "success" (`true`), and always deletes its temp file in a `finally` block.
- `BackupSyncSection`: a `ConsumerWidget` that reads `backupSyncEnabledProvider` and `authProvider`, rendering `const SizedBox.shrink()` unless the flag is on AND the user is `AuthAuthenticated` -- never a disabled/greyed-out affordance, mirroring `AccountSection`'s established gating precedent. When visible: "Push to Cloud" reuses `PassphrasePromptDialog.showCreate`; "Pull from Cloud" reuses `PassphrasePromptDialog.showEnter` with the same Pitfall-7 retry copy Plan 08-01 already uses for local restore, and treats a `false` return from `pullBackup` as "no cloud backup found yet" rather than an error.
- Embedded unconditionally into `BackupRestoreScreen` between "Restore Data" and "Privacy & Ownership" -- the section decides its own visibility.
- SC-6 grep self-check (negative existence): no `outbox`/`hlc`/`conflictresolver`/`lastwritewins`/`mergeconflict` terms anywhere in this plan's new/modified files -- confirmed via automated grep, not a human checkpoint.

## Task Commits

Each task was committed atomically:

1. **Task 1: BackupSyncConfig + BackupApiClient** - `771926d` (feat)
2. **Task 2: BackupSyncNotifier + DI wiring** - `d43893f` (feat)
3. **Task 3: BackupSyncSection widget + screen wiring + SC-6 self-check** - `4a252b1` (feat)

**Plan metadata:** this commit (docs: complete plan)

## Files Created/Modified

- `lib/domain/services/backup_sync_config.dart` - `enabled=false` compile-time flag, `pushPath`/`pullPath`
- `lib/data/remote/backup_api_client.dart` - push/pull HTTP surface, mirrors `ReferencePackApiClient`
- `test/data/remote/backup_api_client_test.dart` - request shape, 404-to-null, non-2xx, timeout coverage for both push and pull
- `lib/features/backup/providers/backup_sync_notifier.dart` - encrypt-then-push / pull-then-decrypt orchestration, account-gated
- `test/features/backup/providers/backup_sync_notifier_test.dart` - push/pull orchestration, auth precondition, temp-file cleanup coverage
- `lib/core/di/backup_providers.dart` - added `backupApiClientProvider`, `backupSyncEnabledProvider`, `backupTempDirGetterProvider`
- `lib/features/backup/widgets/backup_sync_section.dart` - flag-and-Account-Mode gated "Cloud Backup (Beta)" UI
- `lib/features/backup/screens/backup_restore_screen.dart` - embeds `const BackupSyncSection()` unconditionally
- `test/features/backup/backup_restore_screen_test.dart` - added a "Cloud Backup (Beta) section" group covering: hidden at real default (flag off), hidden when flag on but not Account Mode, push success path, pull wrong-passphrase retry, pull no-backup-found

## Decisions Made

See `key-decisions` in frontmatter. Most consequential: widget-level tests mock `BackupSyncNotifier` directly (via `backupSyncProvider.overrideWith(() => _FakeBackupSyncNotifier(...))`) rather than mocking `BackupApiClient` underneath it -- HTTP-level request-shape assertions already live in `backup_api_client_test.dart`, so the screen tests only need to prove the UI reaches the notifier correctly and handles its three outcomes (success, wrong-passphrase retry, no-backup-found).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug/dead code] Removed an unused `_MockBackupApiClient`/`backupApiClient` test seam**
- **Found during:** Task 3 continuation -- resuming after a session interruption that had left `backup_restore_screen_test.dart` mid-edit
- **Issue:** The interrupted session had added a `_MockBackupApiClient` class and a `backupApiClient` parameter to `buildTestable()`, wired to `backupApiClientProvider.overrideWithValue(...)`, but no test actually used either -- both were unreferenced, which would trip `unused_element`-class lints and add dead surface to the test file.
- **Fix:** Replaced both with a `_FakeBackupSyncNotifier` (overriding `pushBackup`/`pullBackup` with test-supplied callbacks) and a `backupSyncProvider.overrideWith(...)` override, which is what the plan's own Task 3 spec calls for ("mocked `backupSyncNotifierProvider`" -- the actual generated provider name is `backupSyncProvider`, per this codebase's established Riverpod codegen convention of stripping the `Notifier` suffix, e.g. `ProfileNotifier` -> `profileProvider`, `[Phase 01-05]`).
- **Files modified:** `test/features/backup/backup_restore_screen_test.dart`
- **Verification:** `flutter test test/features/backup/backup_restore_screen_test.dart` -- all 38 tests (including the 5 new Cloud Backup tests) pass; `flutter analyze` clean on this file (4 pre-existing `avoid_redundant_argument_values` info-level hints in untouched code from Plan 08-01, out of scope).
- **Committed in:** `4a252b1`

---

**Total deviations:** 1 auto-fixed (Rule 1, dead-code cleanup left over from the session interruption)
**Impact on plan:** No scope creep -- this is exactly what Task 3's spec asked for, just correcting an interrupted intermediate state rather than the plan's own text.

## Issues Encountered

The session that originally started Task 3 was interrupted by a rate limit mid-edit, leaving `backup_sync_section.dart` fully written but `backup_restore_screen_test.dart` only partially extended (new imports/fake auth notifier present, but no actual Cloud Backup test cases yet, plus the unused mock/param noted above). This continuation reviewed all three in-flight files against the plan spec, confirmed `backup_sync_section.dart` and the `backup_restore_screen.dart` wiring already matched the spec exactly (correct gating logic, correct embed location, correct dialog reuse), then completed the test file's missing coverage and cleaned up the unused seam before committing Task 3 as a single atomic commit.

## User Setup Required

None - no external service configuration required. `BackupSyncConfig.enabled` stays `false`; nothing in this plan is reachable by a real user.

## Next Phase Readiness

**Stated honestly, per 08-CONTEXT.md and this plan's own `<verification>` section: Plan 08-03 is NOT end-to-end verified against a real backend, and cannot be, because no server exists to push to or pull from.** Every assertion in `backup_api_client_test.dart`, `backup_sync_notifier_test.dart`, and the new Cloud Backup section tests in `backup_restore_screen_test.dart` is against a mocked `http.Client` or a fake `BackupSyncNotifier` -- request shape (method, path, headers, body bytes), 404-to-null handling, and typed-exception surfacing are all that is provable today in `flutter test`, with zero backend and zero device. No real network round trip, no real Keycloak bearer token, and no real cross-device restore has been observed. `BackupSyncConfig.enabled` remains `false` in shipped code; the feature is not reachable by any real user until Tomris confirms Plan 08-02's proposed contract (or a revised version of it) **and** at least one real push/pull round trip has actually been observed against a live server -- neither of which is a Phase 8 completion blocker, since Phase 8's own scope (per `08-CONTEXT.md`) is "client-ready, not backend-live."

**AUTH-09 is deliberately NOT marked complete.** Per 08-02's own precedent, AUTH-09 ("Account Mode users can back up their data to the backend as an opaque, client-encrypted blob... and restore it on another device") remains genuinely unmet at the requirement level: the client-side encryption half (Plan 08-01) is real and verified, and the transport half (this plan) is code-complete and flag-gated, but there is no real backend, no real cross-device restore, and no confirmation from Tomris that the proposed contract will even be built as specified. Marking AUTH-09 complete now would overstate what has actually been delivered end-to-end.

This closes Phase 8 (Encrypted Account Backup) -- all 3 plans (08-01, 08-02, 08-03) complete per `08-CONTEXT.md`'s locked ordering.

---
*Phase: 08-encrypted-account-backup*
*Completed: 2026-09-09*

## Self-Check: PASSED

All key-files (created and modified) verified present on disk. All three task commits (`771926d`, `d43893f`, `4a252b1`) verified present in `git log`.

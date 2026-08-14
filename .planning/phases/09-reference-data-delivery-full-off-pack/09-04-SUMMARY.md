---
phase: 09-reference-data-delivery-full-off-pack
plan: 04
subsystem: database
tags: [drift, sqlite, fts5, riverpod, mocktail, background_downloader]

# Dependency graph
requires:
  - phase: 09-03
    provides: ReferencePackApiClient, ReferencePackExtractor, DownloadManager, FoodCatalogDao.countProducts
provides:
  - DeltaApplier (real-SQLite-integration-tested FTS5-sync-safe delta apply)
  - ReferencePackRepository (full-pack AND delta orchestration behind IReferencePackRepository)
  - reference_pack_providers.dart (DI wiring for every Reference Pack collaborator)
affects: [09-05, 09-06]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "In-flight-download-kind tracking (_InFlightDownload) so a single shared DownloadManager.updates stream never routes a full-pack completion through DeltaApplier.apply or a delta completion through ReferencePackExtractor.swapIn"
    - "Documented compressed-vs-decompressed disk-space estimate via a named, provenance-commented constant (never reusing one manifest field for both DiskSpaceChecker.hasEnoughSpace parameters)"

key-files:
  created:
    - lib/data/local/reference_pack/delta_applier.dart
    - integration_test/reference_pack_delta_apply_test.dart
    - lib/data/repositories/reference_pack_repository.dart
    - lib/core/di/reference_pack_providers.dart
    - lib/domain/services/reference_pack_config.dart
  modified:
    - lib/data/local/reference_pack/download_manager.dart
    - test/data/local/reference_pack/reference_pack_repository_test.dart

key-decisions:
  - "DeltaApplier's ATTACH/DETACH run outside the write transaction (real SQLite refuses DETACH while a still-open transaction has touched that attached database) -- only the INSERT OR REPLACE + tombstone DELETE are wrapped in db.transaction()"
  - "checkDiskSpace()'s decompressed-size estimate uses a documented 3.5x gzip-ratio constant (provenance: this repo's own bundled seed measures ~3.17x; 3.5x is a deliberate conservative round-up)"
  - "DownloadManager.activeTaskId() added (not in the original Plan 09-03 API) so ReferencePackRepository.cancelDownload/resumeDownload have a concrete task ID to act on"
  - "revertToSeed() leaves a documented TODO seam for Plan 09-06's schedule-reset-to-manual call, since ReferencePackScheduleNotifier doesn't exist at this wave"
  - "Test-only: sub.cancel() on an async* watchStatus() stream suspended inside await-for on an idle broadcast stream never resolves its Future until the generator reaches a yield point -- fixed by using unawaited(sub.cancel())/unawaited(updatesController.close()) rather than awaiting them, a genuine Dart async* cancellation quirk, not a repository bug"

patterns-established:
  - "Repository-level tests that receive a checksum/manifest-validation error from a mocked collaborator via thenThrow must reference the arrow-bodied method as a tearoff (repository.fetchManifest, not repository.fetchManifest()) with throwsA, since an arrow-bodied delegate re-throws synchronously rather than returning a rejected Future"

requirements-completed: []

# Metrics
duration: ~55min (Task 2 portion of this continuation; Task 1 was completed and committed in a prior session)
completed: 2026-08-14
---

# Phase 09 Plan 04: DeltaApplier + ReferencePackRepository Summary

**ReferencePackRepository composes every Plan 09-02/09-03 primitive into one checksum-gated preflight->download->verify->swap/apply orchestration for both full-pack and delta downloads, with DeltaApplier proven to keep off_ref.products_fts in sync via a real SQLite integration test.**

## Performance

- **Duration:** ~55 min (this continuation session, Task 2 only -- Task 1 was completed and committed in an earlier, interrupted session)
- **Tasks:** 2 (both complete)
- **Files modified:** 9 (this session's Task 2 commit) + 2 (Task 1's earlier commit)

## Accomplishments

- `DeltaApplier.apply(db, deltaFile)`: ATTACH -> explicit-column `INSERT OR REPLACE` into `off_ref.products` -> tombstone `DELETE` -> DETACH -> `products_fts` rebuild, all proven against a real SQLite fixture (zero mocks) in `integration_test/reference_pack_delta_apply_test.dart` (Task 1, prior session).
- `ReferencePackRepository` implements `IReferencePackRepository` end-to-end: `fetchManifest`, `localProductCount`, `installedVersion`, `isDownloadInProgress`, `checkDiskSpace`, `startFullDownload`, `startDeltaDownload`, `watchStatus`, `cancelDownload`, `resumeDownload`, `revertToSeed`.
- Full-pack completion path: `ChecksumVerifier.verify` against the still-compressed download always gates `ReferencePackExtractor.swapIn` -- a mismatch discards the file and surfaces `ReferencePackFailed`, `swapIn` is never reached.
- Delta completion path: `ChecksumVerifier.verify` against the downloaded delta file always gates `DeltaApplier.apply(appDatabase, deltaFile)` -- a mismatch discards the file and surfaces `ReferencePackFailed`, `apply` is never reached. On success, `apply` runs exactly once, `ReferencePackVersionStore.write` persists the new version, and `watchStatus()` resolves to `ReferencePackFull` without ever touching `ReferencePackExtractor.swapIn`.
- `checkDiskSpace()` always passes `DiskSpaceChecker.hasEnoughSpace` two distinct byte values: the manifest's raw compressed `packSizeBytes`, and a separately-computed, documented decompressed estimate.
- `reference_pack_providers.dart`: `@Riverpod(keepAlive: true)` DI wiring for every collaborator plus the top-level `referencePackRepositoryProvider`, mirroring `backup_providers.dart`.
- `reference_pack_repository_test.dart`: Plan 09-01's Wave 0 skip stub replaced with 19 real, passing tests (zero skips) -- every `IReferencePackRepository` method, the two new must-have cases (distinct disk-space byte values; delta completion wiring including the checksum-mismatch `verifyNever` case), and `isReferencePackUpdateAvailable`'s version-comparison rule.

## Task Commits

Each task was committed atomically:

1. **Task 1: DeltaApplier + FTS5-sync integration test** - `f48b5c9` (feat) -- completed and committed in a prior, interrupted session; not redone here.
2. **Task 2: ReferencePackRepository (full-pack AND delta orchestration) + DI wiring** - `2865fb7` (feat) -- completed this session.

**Plan metadata:** (this commit)

## Files Created/Modified

- `lib/data/local/reference_pack/delta_applier.dart` - ATTACH/apply/DETACH/rebuild against `off_ref.products` + `products_fts` (Task 1, prior session)
- `integration_test/reference_pack_delta_apply_test.dart` - real-SQLite-fixture proof of FTS5 sync after delta apply (Task 1, prior session)
- `lib/data/repositories/reference_pack_repository.dart` - full preflight->manifest->download->verify->swap/apply orchestration for both download kinds
- `lib/core/di/reference_pack_providers.dart` - DI wiring for every Reference Pack collaborator + `referencePackRepositoryProvider`
- `lib/core/di/reference_pack_providers.g.dart` - generated Riverpod codegen output
- `lib/domain/services/reference_pack_config.dart` - `[ASSUMED]` CDN manifest URL placeholder
- `lib/data/local/reference_pack/download_manager.dart` - adds `activeTaskId()` (needed by `cancelDownload`/`resumeDownload`, not present in Plan 09-03's original API)
- `test/data/local/reference_pack/reference_pack_repository_test.dart` - 19 real tests replacing the Wave 0 skip stub
- `lib/core/router/app_router.g.dart`, `lib/features/auth/providers/auth_provider.g.dart`, `lib/features/dashboard/providers/methodology_banner_provider.g.dart` - incidental full-project `build_runner build` codegen-hash refresh (triggered by generating `reference_pack_providers.g.dart`); verified unbroken, no logic changes, only hash literals and one non-semantic doc-comment link-syntax normalization

## Decisions Made

- **DeltaApplier's ATTACH/DETACH deliberately run outside the write transaction** -- a deviation from the plan's literal "single `db.transaction()`" prose, made necessary because real SQLite refuses `DETACH DATABASE` while a still-open transaction has touched that attached database (`SqliteException(1): database ref_delta is locked`), verified empirically. Only the `INSERT OR REPLACE` and tombstone `DELETE` are wrapped in the transaction; a malformed row still leaves `off_ref.products` untouched (no partial writes), and DETACH always runs via `finally`. (Decided and documented in Task 1's prior session; verified still correct this session.)
- **`checkDiskSpace()`'s decompressed-size estimate**: `const _gzipDecompressionRatioEstimate = 3.5` with the provenance doc-commented directly above it (this repo's own bundled seed: 129,134,592 bytes decompressed vs. 40,703,629 bytes compressed = ~3.17x; 3.5x is a deliberate conservative round-up so the preflight never underestimates required space).
- **`DownloadManager.activeTaskId(taskGroup)` added** -- not part of Plan 09-03's original API surface, but required by `ReferencePackRepository.cancelDownload`/`resumeDownload` (declared with no task-ID parameter in `IReferencePackRepository`) to resolve a concrete task ID to act on. Verified as a legitimate, narrowly-scoped, well-documented addition (Rule 3 -- blocking issue for completing Task 2) rather than accidental drift.
- **`revertToSeed()` leaves a documented TODO seam** for Plan 09-06's schedule-reset-to-manual call, since `ReferencePackScheduleNotifier` doesn't exist yet at this wave -- matches `09-CONTEXT.md`'s revert-to-seed decision without inventing schedule persistence prematurely.
- **Test-only fix**: `StreamSubscription.cancel()` on the `Stream<ReferencePackStatus>` returned by `watchStatus()` (an `async*` generator) does not resolve its `Future` while the generator is suspended inside `await for` on an idle broadcast stream (`downloadManager.updates`) -- a genuine Dart async* cancellation quirk (confirmed via a minimal pure-Dart reproduction outside this codebase), not a bug in `ReferencePackRepository`. Fixed in the test file by using `unawaited(sub.cancel())`/`unawaited(updatesController.close())` instead of awaiting them.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Full-download-success test never observed the post-swap installed version**
- **Found during:** Task 2 test-writing (full download completion path test)
- **Issue:** `ReferencePackExtractor.swapIn` is mocked in the repository test, so its real side effect (persisting the new version via `ReferencePackVersionStore.write`) never happens; `watchStatus()`'s post-completion `_currentInstalledStatus()` kept reading the pre-download `null` version, so the test assertion `expect(statuses.last, isA<ReferencePackFull>())` failed with `ReferencePackSeed` instead.
- **Fix:** The `swapIn` mock's `thenAnswer` callback now re-stubs `mockVersionStore.read()` to return the new version, simulating the real extractor's documented side effect.
- **Files modified:** `test/data/local/reference_pack/reference_pack_repository_test.dart`
- **Verification:** Test passes; `flutter test` green.
- **Committed in:** `2865fb7` (Task 2 commit)

**2. [Rule 1 - Bug] `any()` used for `AppDatabase`-typed mock arguments without a registered fallback**
- **Found during:** Task 2 test-writing (revertToSeed, full-download-mismatch, delta-success, delta-mismatch tests)
- **Issue:** Several `when()`/`verifyNever()` calls used `any()` for the `AppDatabase db` parameter of `ReferencePackExtractor.swapIn`/`revertToSeed` and `DeltaApplier.apply`. Since every call in this repository always passes the exact same injected `appDatabase` instance, `mocktail` requires either a registered fallback value or (preferably, since the value is always the same real object) an exact-value matcher.
- **Fix:** Replaced every such `any()` with the test's own `db` variable (the single `AppDatabase(NativeDatabase.memory())` instance injected into the repository under test), avoiding the need to register an `AppDatabase` fallback value at all.
- **Files modified:** `test/data/local/reference_pack/reference_pack_repository_test.dart`
- **Verification:** `flutter test` green, zero mocktail "Bad state: fallback value" errors.
- **Committed in:** `2865fb7` (Task 2 commit)

**3. [Rule 1 - Bug] `expectLater(repository.fetchManifest(), throwsA(...))` failed because the arrow-bodied delegate throws synchronously**
- **Found during:** Task 2 test-writing (fetchManifest error-propagation tests)
- **Issue:** `ReferencePackRepository.fetchManifest()` is arrow-bodied (`=> apiClient.fetchManifest()`); when the mocked `apiClient.fetchManifest()` is stubbed with `.thenThrow(...)`, mocktail throws synchronously from within the mocked call, which propagates synchronously out of the arrow-bodied wrapper before `expectLater` ever receives a `Future` to match against -- the test failed with the raw exception uncaught rather than a matcher failure.
- **Fix:** Changed `expectLater(repository.fetchManifest(), throwsA(...))` to `expectLater(repository.fetchManifest, throwsA(...))` (passing the method tearoff, unevaluated), which `throwsA` correctly invokes and catches regardless of sync-vs-async throw behavior.
- **Files modified:** `test/data/local/reference_pack/reference_pack_repository_test.dart`
- **Verification:** All 3 fetchManifest error-propagation tests pass.
- **Committed in:** `2865fb7` (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (all Rule 1 -- test-only bugs discovered while turning the Wave 0 stub green; zero changes to production code beyond what was already substantially complete from the prior interrupted session).
**Impact on plan:** All fixes are test-file-only corrections needed to make the specified test suite genuinely pass; no production logic (`reference_pack_repository.dart`, `reference_pack_providers.dart`, `reference_pack_config.dart`) required changes beyond what a prior session had already written -- that implementation was verified against the plan's Task 2 spec and found correct as-is.

## Issues Encountered

- **`flutter test integration_test/reference_pack_delta_apply_test.dart` could not be re-run in this environment**: fails with `Target Integrity (Xcode): The package product 'background-downloader' requires minimum platform version 14.0 for the iOS platform, but this target supports 13.0`. This is a pre-existing iOS deployment-target/Xcode Swift Package Manager configuration gap from Plan 09-03's `background_downloader` dependency, unrelated to this plan's DeltaApplier/ReferencePackRepository code, and out of this plan's scope to fix (logged to `deferred-items.md` consideration, not actioned). Task 1's integration test was already verified green and committed (`f48b5c9`) in the prior session before this gap was hit; the test file itself is unchanged this session.
- **Unintended `ios/` project file changes from the above build attempt**: the failed Xcode/SPM build modified `ios/Runner.xcodeproj/project.pbxproj`, `ios/Runner.xcworkspace/contents.xcworkspacedata`, and generated an untracked `ios/Podfile.lock`. These were reverted (`git checkout --`) and the untracked lockfile deleted before committing Task 2, since they were incidental side effects of a failed diagnostic build attempt, not intentional plan work.

## User Setup Required

None - no external service configuration required. `ReferencePackConfig.manifestUrl` remains an `[ASSUMED]` placeholder pending a real CDN owner, consistent with `09-CONTEXT.md`'s explicit out-of-scope coordination point.

## Next Phase Readiness

- `IReferencePackRepository` is now a stable, fully-tested contract via `referencePackRepositoryProvider` -- Plan 09-05 (UI) and Plan 09-06 (automatic weekly/monthly refresh) can consume it directly with no further orchestration-layer work needed.
- Plan 09-06 must wire the schedule-reset-to-manual call into `revertToSeed()` at the documented `TODO(Plan 09-06)` seam once `ReferencePackScheduleNotifier` exists.
- The `integration_test/reference_pack_delta_apply_test.dart` real-device/simulator re-verification is blocked on an iOS deployment-target fix for the `background_downloader` Swift Package (pre-existing from Plan 09-03, not introduced here) -- flagged for whoever picks up real-device verification of this phase, not a Plan 09-04 completion blocker since the test was already green and committed prior to this gap surfacing.

---
*Phase: 09-reference-data-delivery-full-off-pack*
*Completed: 2026-08-14*

## Self-Check: PASSED

All 7 claimed files found on disk; both task commit hashes (`f48b5c9`, `2865fb7`) found in git log.

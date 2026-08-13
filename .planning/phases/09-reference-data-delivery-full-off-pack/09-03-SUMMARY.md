---
phase: 09-reference-data-delivery-full-off-pack
plan: 03
subsystem: data
tags: [background_downloader, archive, gzip, sqlite-attach-detach, http, mocktail]

# Dependency graph
requires:
  - phase: 09-reference-data-delivery-full-off-pack (Plan 09-02)
    provides: background_downloader/crypto/storage_space packages, ChecksumVerifier, DiskSpaceChecker, ReferencePackManifest, ReferencePackVersionStore, IReferencePackRepository contract
provides:
  - ReferencePackApiClient.fetchManifest() -- manifest.json GET over an injectable http.Client
  - ReferencePackExtractor.swapIn/revertToSeed -- live DETACH/decompress(gzip)/replace-file/ATTACH swap against an already-open AppDatabase, with a dedicated real-fixture test proving decompress-before-ATTACH ordering
  - DownloadManager -- background_downloader wrapper (enqueueFullPack/enqueueDelta/updates/cancel/pause/resume/hasActiveTask) with unit-tested pure helpers (sanitizedFilename/statusFromTaskStatus/estimateBytesDownloaded)
  - FoodCatalogDao.countProducts() -- off_ref.products row count for the product-count comparison UI
affects: [09-04 (ReferencePackRepository composing these three primitives), 09-05 (Revert screen/Settings row consuming DownloadManager.hasActiveTask), 09-06 (delta-apply flow)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Seam-injection for platform-channel-backed values extended to path_provider: ReferencePackExtractor.DocumentsDirectoryPath, mirroring DiskSpaceChecker.FreeBytesQuery (Plan 09-02) -- lets a real-fixture test exercise real DETACH/ATTACH SQL without mocking path_provider's platform channel"
    - "Live (not startup-only) SQLite DETACH/decompress/rename/ATTACH cycle against an already-open AppDatabase connection -- first instance of this pattern in the codebase, extending first_launch_extractor.dart's startup-only atomic swap"
    - "Streaming gzip decompression via archive_io's InputFileStream/OutputFileStream + GZipDecoder().decodeStream (file-to-file, never decodeBytes) for large (300-800MB) downloads, contrasted with first_launch_extractor.dart's decodeBytes-on-a-small-bundled-asset approach"
    - "Exhaustive switch over a third-party plugin enum (TaskStatus) mapped 1:1 to an app-owned enum -- compiler-enforced against silent fallthrough on a future plugin upgrade adding new states"

key-files:
  created:
    - lib/data/remote/reference_pack_api_client.dart
    - lib/data/local/reference_pack/reference_pack_extractor.dart
    - lib/data/local/reference_pack/download_manager.dart
    - test/data/remote/reference_pack_api_client_test.dart
    - test/data/local/reference_pack/reference_pack_extractor_test.dart
    - test/data/local/reference_pack/download_manager_test.dart
  modified:
    - lib/data/local/daos/food_catalog_dao.dart

key-decisions:
  - "DownloadManager.enqueueFullPack/enqueueDelta take a version string (not a raw filename) and derive the on-disk filename internally via sanitizedFilename() -- the plan's public-surface signature blurb said `required String filename`, but its detailed description, done criteria, and threat model (T-09-03-01) all require the filename to be built from a version string DownloadManager owns, never taken verbatim from a manifest/server field. The detailed spec + threat model win over the terser signature line (Rule 1 -- contradiction resolved in favor of the security-correct, testable interpretation)."
  - "ReferencePackExtractor.revertToSeed keeps the plan's literal 2-arg signature (db, bundledSeedPath) with no separate downloadedPackPath parameter -- the file to delete is always the same fixed getApplicationDocumentsDirectory()/off_reference.sqlite path swapIn already renames the decompressed download into, so no extra parameter is needed to locate it."
  - "ReferencePackDownloadStatus mirrors TaskStatus 1:1 (8 values: enqueued/running/paused/complete/notFound/failed/canceled/waitingToRetry) rather than the plan prose's shorter 6-value list -- the done criteria explicitly required every TaskStatus value mapped with no default fallthrough, and the real installed background_downloader 9.5.8 package's TaskStatus enum has 8 values, not 6."

patterns-established:
  - "DocumentsDirectoryPath seam: constructor-injectable Future<String> Function() defaulting to the real path_provider call, letting real-fixture SQLite/file-system tests run without a platform-channel mock"

requirements-completed: []

# Metrics
duration: ~12min
completed: 2026-08-13
---

# Phase 9 Plan 3: Reference Pack Data-Layer Primitives Summary

**ReferencePackApiClient (manifest GET), ReferencePackExtractor (live DETACH/gzip-decompress/ATTACH swap with a real-fixture test proving decompression precedes ATTACH), and a DownloadManager wrapping background_downloader 9.5.8 -- the three independent, unit-tested primitives Plan 09-04's repository will compose.**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-08-13T20:10:58+08:00 (immediately after 09-02's completion commit)
- **Completed:** 2026-08-13T20:22:01+08:00
- **Tasks:** 2/2 completed
- **Files modified:** 7 (6 created, 1 modified)

## Accomplishments
- `ReferencePackApiClient.fetchManifest()` fetches and parses `manifest.json` over an injectable `http.Client`, matching this app's `_MockHttpClient extends Mock implements http.Client` mocktail convention; throws `NetworkException` on non-200, propagates `FormatException` from `ReferencePackManifest.fromJson`'s own https-only/sanity-bound-size validation
- `ReferencePackExtractor.swapIn` performs the live `DETACH DATABASE off_ref` → streaming gzip decompression (`archive_io`'s `InputFileStream`/`OutputFileStream`, never buffering the full 300-800MB→1-2GB payload) → delete-old/rename-new → `ATTACH DATABASE ... AS off_ref` → version-marker-write sequence against an already-open `AppDatabase` connection -- the app's first in-place ATTACH/DETACH cycle that isn't startup-only
- `reference_pack_extractor_test.dart` proves decompress-before-ATTACH with a **real gzip fixture** against a **real in-memory `AppDatabase`**: a still-compressed file makes SQLite's `ATTACH DATABASE` throw immediately, so a passing `SELECT` against the swapped-in fixture is itself the hard proof
- `DownloadManager` wraps `background_downloader`'s `FileDownloader` singleton: `enqueueFullPack`/`enqueueDelta` (Wi-Fi-gated, `allowPause: true` for native Range-based resume, `retries: 0`), `updates` (mapped `TaskStatusUpdate`/`TaskProgressUpdate` stream), `cancel` (explicit partial-file delete, doesn't trust undocumented plugin cleanup), `pause`/`resume`, `hasActiveTask` (queries the plugin's own persistent task registry, not in-memory state)
- `FoodCatalogDao.countProducts()` returns `off_ref.products`'s row count for the "50,000 (starter pack)" vs "2.5M (full catalog)" comparison UI

## Task Commits

Each task was committed atomically:

1. **Task 1: ReferencePackApiClient + ReferencePackExtractor + FoodCatalogDao.countProducts** - `081a19c` (feat)
2. **Task 2: DownloadManager (background_downloader wrapper) + pure-logic unit tests** - `6085d4b` (feat)

**Plan metadata:** committed alongside this SUMMARY (docs: complete plan)

## Files Created/Modified
- `lib/data/remote/reference_pack_api_client.dart` - manifest GET client over injectable `http.Client`
- `lib/data/local/reference_pack/reference_pack_extractor.dart` - live swap/revert (DETACH/decompress/ATTACH)
- `lib/data/local/reference_pack/download_manager.dart` - `background_downloader` wrapper + pure helpers
- `lib/data/local/daos/food_catalog_dao.dart` - added `countProducts()`
- `test/data/remote/reference_pack_api_client_test.dart` - 5 tests (200/404/500/2 validation-failure cases)
- `test/data/local/reference_pack/reference_pack_extractor_test.dart` - 2 tests, real gzip fixture + real in-memory `AppDatabase`
- `test/data/local/reference_pack/download_manager_test.dart` - 10 tests, pure-helper coverage only

## Decisions Made
- Investigated the installed `background_downloader` 9.5.8 package's actual source (`~/.pub-cache`) rather than relying on training-data assumptions about `TaskStatus`/`TaskProgressUpdate`/`FileDownloader`'s API shape -- confirmed `TaskProgressUpdate` has no raw byte-count field (only `progress` + `expectedFileSize`), confirming the `estimateBytesDownloaded` fallback is required, not optional; confirmed `TaskStatus` has 8 values; confirmed `FileDownloader().allTasks(group:)` already aggregates native enqueued/running + `waitingToRetry` + `paused` tasks, making it the correct single call for `hasActiveTask`.
- See frontmatter `key-decisions` for the two interpretation calls made where the plan's terse public-surface prose conflicted with its own detailed description/threat model/done criteria (`enqueueFullPack`/`enqueueDelta` parameter naming; `ReferencePackDownloadStatus`'s value count).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Contradiction resolved] `enqueueFullPack`/`enqueueDelta` take `version`, not a raw `filename`, parameter**
- **Found during:** Task 2 (DownloadManager)
- **Issue:** The plan's public-surface signature blurb read `enqueueFullPack({required Uri url, required String filename, required bool requiresWifi})`, but the same paragraph's detailed description and this plan's own threat model (T-09-03-01) require every on-disk filename to be built by `sanitizedFilename()` from a version string `DownloadManager` owns, "never taken verbatim from any manifest field." Taking a raw `filename` parameter directly would let a caller pass an unsanitized string straight through, defeating the stated mitigation.
- **Fix:** `enqueueFullPack`/`enqueueDelta` take `required String version`; `sanitizedFilename(version, isDelta: ...)` is called internally to build the actual on-disk filename.
- **Files modified:** `lib/data/local/reference_pack/download_manager.dart`
- **Verification:** `download_manager_test.dart`'s `sanitizedFilename` tests directly exercise path-traversal-style inputs (`../../etc/passwd`, `..\windows\system32`, SQL-injection-style strings) and assert no separator survives into the constructed filename.
- **Committed in:** `6085d4b` (Task 2 commit)

**2. [Rule 1 - Contradiction resolved] `ReferencePackDownloadStatus` has 8 values, mirroring the real `TaskStatus` enum, not the plan prose's 6-value list**
- **Found during:** Task 2 (DownloadManager)
- **Issue:** The plan text described `statusFromTaskStatus` as "mirroring TaskStatus's enqueued/running/paused/complete/failed/canceled values" (6 values), but the done criteria required "every TaskStatus value" mapped "with no case falling through to a default/unknown state." Direct inspection of the installed `background_downloader` 9.5.8 package's `TaskStatus` enum showed 8 values (also `notFound`, `waitingToRetry`).
- **Fix:** `ReferencePackDownloadStatus` defines all 8 values; `statusFromTaskStatus` is an exhaustive switch (compiler-enforced, no `default` case) covering every `TaskStatus` value.
- **Files modified:** `lib/data/local/reference_pack/download_manager.dart`
- **Verification:** `download_manager_test.dart` asserts `expected.keys.toSet() == TaskStatus.values.toSet()` before checking individual mappings -- this assertion itself fails if a future package upgrade adds an unmapped `TaskStatus` value.
- **Committed in:** `6085d4b` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (both Rule 1 -- plan-prose/detailed-spec contradictions resolved in favor of the more specific, security/correctness-relevant description)
**Impact on plan:** Both resolutions make the implementation match the plan's own stated threat model and done criteria more precisely than a literal reading of the shorter prose would have. No scope creep -- no new files, no new packages, no behavior beyond what Plan 09-03 already specified.

## Issues Encountered
None -- `background_downloader` 9.5.8, `archive` 3.6.1, and all other dependencies were already installed from Plan 09-02/earlier phases; no new package installs were needed for this plan, so no package-legitimacy checkpoint was required.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `ReferencePackApiClient`, `ReferencePackExtractor`, `DownloadManager`, and `FoodCatalogDao.countProducts()` all exist as clean, independently-compiling, unit-tested primitives ready for Plan 09-04 to compose into `ReferencePackRepository`.
- `ReferencePackExtractor`'s `DocumentsDirectoryPath` seam and `DownloadManager`'s pure-helper extraction (`sanitizedFilename`/`statusFromTaskStatus`/`estimateBytesDownloaded`) both give Plan 09-04's own tests a clean mocking surface without needing platform-channel mocks.
- No blockers. `DownloadManager.enqueueFullPack`/`enqueueDelta`/`cancel`/`pause`/`resume`/`hasActiveTask` themselves remain unverified against a real platform channel/real CDN -- consistent with `09-RESEARCH.md`'s Validation Architecture, which flags that class of behavior as real-device-only (Plan 09-08), not a gap introduced by this plan.

---
*Phase: 09-reference-data-delivery-full-off-pack*
*Completed: 2026-08-13*

## Self-Check: PASSED

All 7 created/modified source and test files verified present on disk. Both task commits (`081a19c`, `6085d4b`) verified present in git history.

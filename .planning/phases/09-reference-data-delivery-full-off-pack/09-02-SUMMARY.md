---
phase: 09-reference-data-delivery-full-off-pack
plan: 02
subsystem: infra
tags: [background_downloader, crypto, storage_space, sealed-class, reference-pack, checksum, disk-space]

# Dependency graph
requires:
  - phase: 09-reference-data-delivery-full-off-pack (Plan 09-01)
    provides: Wave 0 stub test files (checksum_verifier_test.dart, disk_space_check_test.dart, reference_pack_repository_test.dart, etc.) and CONTEXT.md/RESEARCH.md decisions this plan implements against
  - phase: 09-reference-data-delivery-full-off-pack (Plan 09-07)
    provides: docs/data-contracts/reference-pack-manifest.md — the authoritative manifest.json shape ReferencePackManifest.fromJson parses against
provides:
  - background_downloader/crypto/storage_space installed and human-approved (blocking package-legitimacy checkpoint)
  - ChecksumVerifier — real, tested SHA-256 chunked-stream verification
  - DiskSpaceChecker — real, tested disk-space preflight with Pitfall-4-aware sizing
  - ReferencePackStatus/ReferencePackSchedule, ReferencePackManifest/ReferencePackDeltaInfo, IReferencePackRepository, ReferencePackVersionStore — shared contracts every later Phase 9 plan builds against
affects: [09-03 (DownloadManager), 09-04 (ReferencePackRepository/DeltaApplier), 09-05, 09-06]

# Tech tracking
tech-stack:
  added: [background_downloader 9.5.8, crypto 3.0.7, storage_space 1.2.0]
  patterns: [plain-Dart-sealed-class state entities (AuthState/FoodSearchState precedent), constructor-injectable function seam for platform-channel-backed values (filePickerProvider precedent)]

key-files:
  created:
    - lib/data/local/reference_pack/checksum_verifier.dart
    - lib/data/local/reference_pack/disk_space_checker.dart
    - lib/domain/entities/reference_pack_status.dart
    - lib/domain/entities/reference_pack_manifest.dart
    - lib/domain/repositories/i_reference_pack_repository.dart
    - lib/data/local/reference_pack/reference_pack_version_store.dart
  modified:
    - pubspec.yaml
    - test/data/local/reference_pack/checksum_verifier_test.dart
    - test/data/local/reference_pack/disk_space_check_test.dart

key-decisions:
  - "background_downloader resolved to 9.5.8 (not the reviewed 9.5.7) via flutter pub add — same publisher/repo, latest compatible patch, no re-review needed"
  - "DiskSpaceChecker wraps storage_space's top-level getStorageSpace function behind a constructor-injectable FreeBytesQuery typedef seam, since storage_space has no class to subclass/mock"
  - "ReferencePackManifest.fromJson validates against docs/data-contracts/reference-pack-manifest.md (completed one plan earlier, in 09-07) rather than only 09-RESEARCH.md's earlier proposal — the two shapes matched exactly, no rework needed"

patterns-established:
  - "ReferencePackStatus/ReferencePackSchedule are the canonical shapes — no later Phase 9 plan should invent its own status shape"
  - "IReferencePackRepository is the sole contract 09-04's ReferencePackRepository implements and 09-05/09-06's UI consumes"

requirements-completed: []

# Metrics
duration: 10min
completed: 2026-08-13
---

# Phase 9 Plan 2: Reference Pack Contracts + Local Safety Utilities Summary

**Installed background_downloader/crypto/storage_space behind a human-approved package-legitimacy checkpoint, then built ChecksumVerifier (SHA-256 chunked-stream verification) and DiskSpaceChecker (Pitfall-4-aware disk preflight) as real tested implementations, plus the ReferencePackStatus/ReferencePackManifest/IReferencePackRepository/ReferencePackVersionStore contracts every later Phase 9 plan builds against.**

## Performance

- **Duration:** ~10 min (resumed after checkpoint approval; excludes checkpoint wait time)
- **Started:** 2026-08-13T19:58:00+08:00 (approx, resuming after checkpoint)
- **Completed:** 2026-08-13T20:07:14+08:00
- **Tasks:** 2 (checkpoint task preceded both, already approved before this session)
- **Files modified:** 12 (6 created, 3 modified, plus pubspec.lock + iOS CocoaPods scaffolding)

## Accomplishments
- background_downloader 9.5.8, crypto 3.0.7, storage_space 1.2.0 installed, human-approved, and privacy-blocklist-clean
- ChecksumVerifier and DiskSpaceChecker are real, on-device implementations (not stubs) — checksum_verifier_test.dart and disk_space_check_test.dart both fully green, zero skips
- ReferencePackStatus (5 variants) + ReferencePackSchedule, ReferencePackManifest + ReferencePackDeltaInfo (with HTTPS-only and sanity-bound validation), IReferencePackRepository (11-method contract), and ReferencePackVersionStore all exist as pure, dependency-free contracts ready for Plan 09-03/09-04

## Task Commits

Each task was committed atomically:

1. **Task 1: Install packages + ChecksumVerifier + DiskSpaceChecker** - `ee57d19` (feat)
2. **Task 2: Domain contracts + version store** - `ca97d87` (feat)

_Plan metadata commit follows this Summary._

## Files Created/Modified
- `pubspec.yaml` - Added background_downloader/crypto/storage_space with version-comment blocks matching the project's existing convention
- `lib/data/local/reference_pack/checksum_verifier.dart` - SHA-256 chunked-stream verification (crypto's sha256.bind), returns false (never throws) on missing file
- `lib/data/local/reference_pack/disk_space_checker.dart` - Free-disk-space preflight wrapping storage_space behind a FreeBytesQuery seam; required-bytes = (compressed + decompressed) * safety margin
- `test/data/local/reference_pack/checksum_verifier_test.dart` - 3 tests: match/mismatch/missing-file, now green
- `test/data/local/reference_pack/disk_space_check_test.dart` - 3 tests: sufficient/insufficient/Pitfall-4-aware sizing, now green
- `lib/domain/entities/reference_pack_status.dart` - ReferencePackStatus sealed class (Seed/Downloading/Full/UpdateAvailable/Failed) + ReferencePackSchedule enum
- `lib/domain/entities/reference_pack_manifest.dart` - ReferencePackManifest + ReferencePackDeltaInfo with fromJson, HTTPS-only + 2GB sanity-bound validation
- `lib/domain/repositories/i_reference_pack_repository.dart` - IReferencePackRepository 11-method contract, each doc-commented against its 09-CONTEXT.md decision
- `lib/data/local/reference_pack/reference_pack_version_store.dart` - reference_pack_full.version on-disk marker, mirrors first_launch_extractor.dart's pattern

## Decisions Made
- background_downloader resolved to 9.5.8 (patch newer than the 9.5.7 reviewed at the checkpoint) — same publisher/repo/github URL, `flutter pub add` picked the latest compatible patch automatically; no re-review needed since the checkpoint approved the package itself, not a pinned exact version
- DiskSpaceChecker's seam is a plain `typedef FreeBytesQuery = Future<int> Function()` injected via constructor, since `storage_space`'s API is a top-level function (`getStorageSpace`) with no class to mock — this is the closest equivalent to the project's existing `filePickerProvider`-style seam pattern for a non-Riverpod, non-provider context
- ReferencePackManifest.fromJson was written against `docs/data-contracts/reference-pack-manifest.md` (the authoritative spec, completed one plan earlier by 09-07) rather than only 09-RESEARCH.md's earlier proposal shape — both documents describe the identical field set, so no rework was needed

## Deviations from Plan

None — plan executed exactly as written. The background_downloader patch-version drift (9.5.7 reviewed → 9.5.8 installed) is not a deviation from the plan's intent (same publisher, same package, checkpoint approval covers the package's legitimacy, not an exact patch pin) and is documented above for traceability.

## Issues Encountered
- `flutter pub get` auto-generated `ios/Podfile` and added CocoaPods `#include?` lines to `ios/Flutter/Debug.xcconfig`/`Release.xcconfig` — this is the project's first plugin with iOS native platform-channel code (background_downloader), so this scaffolding was necessary and expected, not a bug. Included in the Task 1 commit.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
Plan 09-03 (DownloadManager) can now build directly against `IReferencePackRepository`, `ReferencePackStatus`, `ReferencePackManifest`, `ChecksumVerifier`, and `DiskSpaceChecker` without inventing any of these shapes itself. Plan 09-04 (ReferencePackRepository/DeltaApplier) has its full contract surface and version-store already in place. No blockers.

---
*Phase: 09-reference-data-delivery-full-off-pack*
*Completed: 2026-08-13*

## Self-Check: PASSED

All 6 created files verified present on disk. Both task commits (ee57d19, ca97d87) verified present in git log.

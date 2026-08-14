---
phase: 09-reference-data-delivery-full-off-pack
plan: 05
subsystem: ui
tags: [riverpod, go_router, connectivity_plus, intl, path_provider]

# Dependency graph
requires:
  - phase: 09-04
    provides: IReferencePackRepository (referencePackRepositoryProvider) -- full preflight->manifest->download->verify->swap/apply orchestration
provides:
  - ReferencePackNotifier (referencePackProvider) -- AsyncNotifier presentation-layer surface composing referencePackRepositoryProvider + a dedicated referencePackStatusStreamProvider
  - referencePackInstalledSizeBytesProvider -- reactive installed-pack on-disk size
  - ReferenceDataRow -- Settings entry point (live status subtitle, navigates to /reference-data)
  - ReferenceDataScreen -- download/progress/cancel/revert screen at /reference-data
affects: [09-06, 09-07, 09-08]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "AsyncNotifier composing a sibling @riverpod StreamProvider via ref.listen(streamProvider, ...) inside build() + ref.watch(streamProvider.future) for the initial value -- lets a keepAlive AsyncNotifier stay live-updated across every subsequent stream event (download progress ticks) while still exposing mutation methods, which a plain ref.watch(stream.future) alone (single resolution) cannot do"
    - "Presentation-layer notifier reads a DI-scoped collaborator provider directly (diskSpaceCheckerProvider) for a display-only estimate, bypassing the repository interface, when the real repository-owned calculation is a private implementation detail not part of the public contract"

key-files:
  created:
    - lib/features/reference_data/providers/reference_pack_notifier.dart
    - lib/features/reference_data/providers/reference_pack_notifier.g.dart
    - lib/features/settings/widgets/reference_data_row.dart
    - lib/features/reference_data/screens/reference_data_screen.dart
  modified:
    - lib/features/settings/screens/settings_screen.dart
    - lib/core/router/app_router.dart
    - lib/core/router/app_router.g.dart
    - test/features/settings/reference_data_row_test.dart
    - test/features/reference_data/reference_data_screen_test.dart

key-decisions:
  - "@riverpod strips the 'Notifier' suffix from the class name -- the generated provider is referencePackProvider, not referencePackNotifierProvider as PLAN.md's action-block prose stated (same pitfall documented at [Phase 06-05]/[Phase 06-07]/[Phase 06-09])"
  - "ReferencePackNotifier.build() watches a dedicated referencePackStatusStream @riverpod StreamProvider via ref.watch(...future) for the initial value, then ref.listen(...)s it to keep state in sync with every subsequent event -- an AsyncNotifier alone can't stay live-updated off a continuously-emitting stream"
  - "installedSizeBytes()/referencePackInstalledSizeBytesProvider added to ReferencePackNotifier -- neither ReferencePackStatus.ReferencePackFull (Plan 09-02) nor IReferencePackRepository (Plan 09-04) expose an installed-byte-count, but the Settings row/screen/revert-dialog's locked 'N MB' copy needs one computed from the real on-disk off_reference.sqlite file, never hardcoded"
  - "freeDiskSpaceBytes()/estimatedRequiredDiskSpaceBytes() added to ReferencePackNotifier for the disk-space blocking message's two numbers -- hasEnoughDiskSpace() only returns a bool; the display-only estimate duplicates DiskSpaceChecker's formula (documented, not the real gating decision)"
  - "Product-count comparison formatted via intl NumberFormat.compact() ('50K'/'2.5M') per the plan's 'locale-aware compact formatter, not a raw digit string' instruction -- not itself CONTEXT.md-locked copy (only the disk-space/Wi-Fi/revert strings are), so exact shape was Claude's discretion"
  - "Revert action's disabled-during-download requirement satisfied by architecture, not a separate flag: ReferenceDataScreen's top-level switch on ReferencePackStatus renders an entirely different body for Downloading vs. Full, so the Revert button is structurally absent (not merely visually disabled) whenever a download is active -- reads the same live status the Row uses, per 09-RESEARCH.md Pitfall 5"

patterns-established:
  - "isOnWifi() is the one Reference Data file that calls Connectivity().checkConnectivity() directly (UI-facing 'should I prompt' decision), mirroring but extending food_search_notifier.dart/auth_screen.dart's existing online/offline-only connectivity pattern with a new positive Wi-Fi-vs-cellular check"

requirements-completed: []

# Metrics
duration: ~55min
completed: 2026-08-14
---

# Phase 09 Plan 05: Reference Data UI (Settings Row + Download Screen) Summary

**ReferencePackNotifier (AsyncNotifier composing a live status stream), a Settings row with real-time status subtitles, and a dedicated ReferenceDataScreen implementing the full disk-space-preflight -> Wi-Fi-override -> progress -> revert flow exactly as locked in 09-CONTEXT.md.**

## Performance

- **Duration:** ~55 min
- **Tasks:** 3 (all complete)
- **Files created:** 4
- **Files modified:** 5

## Accomplishments

- `ReferencePackNotifier` (`referencePackProvider`, keepAlive): thin `AsyncNotifier<ReferencePackStatus>` composing a sibling `referencePackStatusStreamProvider` for live updates, plus every mutation method the Row/Screen need (`checkForUpdate`, `hasEnoughDiskSpace`, `freeDiskSpaceBytes`, `estimatedRequiredDiskSpaceBytes`, `localProductCount`, `installedSizeBytes`, `isOnWifi`, `startFullDownload`, `cancelDownload`, `resumeDownload`, `revertToSeed`) -- zero direct `background_downloader`/`http`/`storage_space` usage; everything routes through `referencePackRepositoryProvider` except the two narrow, documented exceptions (`isOnWifi()` via `connectivity_plus`, `installedSizeBytes()` via direct file-size read).
- `ReferenceDataRow`: Settings `ListTile` (leading `Icons.cloud_download_outlined`, "Download full food database") inserted directly below Backup & Restore, subtitle switches on live status matching every one of 09-CONTEXT.md's exact copy examples verbatim ("Using starter pack" / "Downloading… X/Y MB" / "Full catalog installed — N MB" / "Update available[ — connect to Wi-Fi]" / "Download paused — tap to resume"); tap navigates to `/reference-data` unconditionally.
- `app_router.dart`: new `/reference-data` route.
- `ReferenceDataScreen`: Seed/UpdateAvailable/Failed states render a product-count comparison plus Download/Resume button; Download runs manifest fetch -> disk-space preflight (blocks with the exact locked "Not enough storage — need ~NMB, only MMB free" message, `startFullDownload` never called) -> Wi-Fi check (immediate start on Wi-Fi, an explicit "Not on Wi-Fi — download over cellular anyway?" confirmation dialog off Wi-Fi, `startFullDownload(allowCellular: true)` only on confirm). Downloading state shows a determinate `LinearProgressIndicator` + percent/MB text + Cancel button, with a brief SnackBar success confirmation on the Downloading -> Full transition. Full state shows installed version/size, the product-count comparison, and a Revert `TextButton` gated by the live status (absent entirely during an active download) opening the exact locked revert-confirmation copy with the real installed size interpolated.
- `reference_data_row_test.dart`: 5 real widget tests replacing the Wave 0 skip stub, zero skips.
- `reference_data_screen_test.dart`: 8 real widget tests replacing the Wave 0 skip stub (7 named cases from the stub, split into 8 for test isolation), zero skips.

## Task Commits

Each task was committed atomically:

1. **Task 1: ReferencePackNotifier** - `4dd6377` (feat)
2. **Task 2: ReferenceDataRow + Settings/router wiring** - `b65cb89` (feat)
3. **Task 3: ReferenceDataScreen** - `d9557d5` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified

- `lib/features/reference_data/providers/reference_pack_notifier.dart` - `ReferencePackNotifier` + `referencePackStatusStreamProvider` + `referencePackInstalledSizeBytesProvider`
- `lib/features/reference_data/providers/reference_pack_notifier.g.dart` - generated Riverpod codegen output
- `lib/features/settings/widgets/reference_data_row.dart` - the Settings entry point row
- `lib/features/reference_data/screens/reference_data_screen.dart` - the dedicated download/progress/revert screen
- `lib/features/settings/screens/settings_screen.dart` - `ReferenceDataRow` inserted below Backup & Restore
- `lib/core/router/app_router.dart` - new `/reference-data` `GoRoute`
- `lib/core/router/app_router.g.dart` - incidental codegen-hash refresh (no logic changes)
- `test/features/settings/reference_data_row_test.dart` - 5 real tests replacing the Wave 0 skip stub
- `test/features/reference_data/reference_data_screen_test.dart` - 8 real tests replacing the Wave 0 skip stub

## Decisions Made

- **Generated provider name is `referencePackProvider`, not `referencePackNotifierProvider`** -- `@riverpod` strips the `Notifier` suffix from the class name; PLAN.md's action-block prose (and this plan's own must-haves' `key_links` pattern) used the wrong name, same class of pitfall already documented at Phases 06-05/06-07/06-09. Followed the actual generated code, not the prose.
- **`ReferencePackNotifier.build()` composes a sibling `@riverpod Stream<ReferencePackStatus> referencePackStatusStream`** via `ref.listen(...)` (for every later event) + `ref.watch(...future)` (for the initial value) -- the plan's Task 1 action explicitly recommended this shape over a plain `AsyncNotifier` awaiting a single `Future`, since `IReferencePackRepository.watchStatus()` is a continuously-updating download-progress stream.
- **`installedSizeBytes()` and `referencePackInstalledSizeBytesProvider` added** (see Deviations) -- required by this plan's own must-haves (`Full catalog installed — N MB` computed from a real file, never hardcoded), not present anywhere in the locked Plan 09-02/09-04 domain/repository surface.
- **`freeDiskSpaceBytes()`/`estimatedRequiredDiskSpaceBytes()` added** (see Deviations) -- required for the disk-space blocking message's two numbers; `hasEnoughDiskSpace()` (the real gating decision) only returns a `bool`.
- **Product-count comparison uses `NumberFormat.compact()`** ('50K products (starter pack)' / '2.5M products (full catalog)') rather than CONTEXT.md's illustrative comma-separated '50,000' example -- the plan's own action text instructs "format large counts with a locale-aware compact formatter, not a raw digit string", and the product-count comparison is not among the plan's explicitly "locked copy" strings (only the disk-space block, Wi-Fi prompt, and revert confirmation are).
- **Revert-disabled-during-download implemented structurally, not via a boolean flag** -- `ReferenceDataScreen`'s top-level `switch` on `ReferencePackStatus` renders `_buildDownloading()` (no Revert button at all) whenever status is `ReferencePackDownloading`, and `_buildFull()` (with an enabled Revert button) only when status is `ReferencePackFull` -- satisfies 09-CONTEXT.md's "disabled/hidden mid-transfer" wording (both explicitly permitted) while reading the same live status the Row uses, never a separate local flag, per 09-RESEARCH.md Pitfall 5.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Added installed-pack byte-size surface (`installedSizeBytes()` + `referencePackInstalledSizeBytesProvider`) to `ReferencePackNotifier`**
- **Found during:** Task 2 (`ReferenceDataRow`'s subtitle) and Task 3 (`ReferenceDataScreen`'s Full-state body and revert-confirmation copy)
- **Issue:** The plan's action text requires "Full catalog installed — N MB" and the revert dialog's real interpolated size, both "compute[d] from the installed file size, not a hardcoded number." But neither `ReferencePackStatus.ReferencePackFull` (Plan 09-02, locked) nor `IReferencePackRepository` (Plan 09-04, locked) expose an installed-byte-count -- `ReferencePackFull` only carries `installedVersion`/`productCount`/`installedAt`.
- **Fix:** Added `ReferencePackNotifier.installedSizeBytes()`, which reads `getApplicationDocumentsDirectory()/off_reference.sqlite`'s real on-disk length directly (the one other narrow direct-I/O exception besides `isOnWifi()`, since that path is the same well-known swap-in target `ReferencePackExtractor`/`first_launch_extractor.dart` already use regardless of whether the seed or full pack is currently attached), plus a reactive `referencePackInstalledSizeBytesProvider` that recomputes whenever `referencePackProvider`'s status changes. Did not modify the locked Plan 09-02 entity or Plan 09-04 repository interface/implementation at all -- kept entirely within this plan's own file.
- **Files modified:** `lib/features/reference_data/providers/reference_pack_notifier.dart`
- **Verification:** `flutter analyze` clean; both widget test suites assert on the real interpolated MB values.
- **Committed in:** `b65cb89` (Task 2 commit; extended further, same file, no new deviation, in `d9557d5`'s Task 3)

**2. [Rule 2 - Missing Critical] Added `freeDiskSpaceBytes()`/`estimatedRequiredDiskSpaceBytes()` to `ReferencePackNotifier`**
- **Found during:** Task 3 (`ReferenceDataScreen`'s disk-space-preflight blocking message)
- **Issue:** The locked blocking-message copy ("Not enough storage — need ~650MB, only 200MB free") requires both a needed-bytes and a free-bytes number, but `IReferencePackRepository.checkDiskSpace()` (the real go/no-go decision, correctly reused unchanged) only returns a `bool` -- neither number is exposed anywhere in the public contract.
- **Fix:** `freeDiskSpaceBytes()` reads `diskSpaceCheckerProvider.freeBytes()` directly (already a public Plan 09-04 DI provider, not a new dependency). `estimatedRequiredDiskSpaceBytes(manifest)` is a pure, documented duplication of `ReferencePackRepository.checkDiskSpace`'s private `(compressed + decompressed) * 1.15` formula, used only to render the display-only number -- the real go/no-go decision remains `hasEnoughDiskSpace()`, unchanged.
- **Files modified:** `lib/features/reference_data/providers/reference_pack_notifier.dart`
- **Verification:** Widget test asserts the exact locked message string with real interpolated numbers.
- **Committed in:** `b65cb89` (Task 2 commit's file, exercised first by Task 3's `d9557d5`)

---

**Total deviations:** 2 auto-fixed (both Rule 2 -- missing critical functionality needed to satisfy this plan's own locked-copy must-haves; neither touches a prior plan's locked domain entity or repository interface).
**Impact on plan:** Both additions are narrowly scoped, fully contained within this plan's own new file, and documented as deliberate exceptions to the "everything routes through the repository" rule. No scope creep into Plan 09-02/09-04's territory.

## Issues Encountered

None beyond the deviations above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `ReferencePackNotifier`/`referencePackProvider` is now the stable presentation-layer surface Plan 09-06 (automatic weekly/monthly refresh scheduling) can read/drive without further UI-layer plumbing.
- `ReferenceDataRow`/`ReferenceDataScreen` are both reachable and fully wired (`SettingsScreen` -> `/reference-data`), closing out this plan's must-haves end-to-end.
- Real-device verification of the actual download/Wi-Fi-override/disk-space flows (vs. this plan's mocked-notifier widget tests) remains open, consistent with Plan 09-04's already-flagged `background_downloader` iOS deployment-target gap -- not a blocker for this plan's completion, but relevant context for whoever runs Phase 9's eventual real-device pass.

---
*Phase: 09-reference-data-delivery-full-off-pack*
*Completed: 2026-08-14*

## Self-Check: PASSED

All 9 claimed files found on disk; all 3 task commit hashes (`4dd6377`, `b65cb89`, `d9557d5`) found in git log.

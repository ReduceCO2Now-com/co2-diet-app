---
phase: 09-reference-data-delivery-full-off-pack
plan: 01
subsystem: testing
tags: [flutter_test, wave-0-stubs, reference-pack, off-full-pack, delta-refresh, revert-to-seed]

# Dependency graph
requires: []
provides:
  - Seven skipped Wave 0 stub test files covering the full OFF reference-pack delivery surface (manifest fetch/parse, version comparison, disk preflight, checksum verification, Settings row, dedicated download/revert screen, scheduled lifecycle check, delta-apply FTS sync)
  - Nyquist-contract scaffolding so every later Phase 9 plan's `<verify>` command has a target file to turn green
affects: [09-02, 09-04, 09-05, 09-06]

# Tech tracking
tech-stack:
  added: []
  patterns: [group-level skip: pattern for test() and testWidgets(), reused verbatim from Phase 2-7 Wave 0 precedent]

key-files:
  created:
    - test/data/local/reference_pack/reference_pack_repository_test.dart
    - test/data/local/reference_pack/disk_space_check_test.dart
    - test/data/local/reference_pack/checksum_verifier_test.dart
    - test/features/settings/reference_data_row_test.dart
    - test/features/reference_data/reference_data_screen_test.dart
    - test/app_lifecycle_reference_pack_test.dart
    - integration_test/reference_pack_delta_apply_test.dart
  modified:
    - .gitignore

key-decisions:
  - "Group-level skip: arg on group() (not per-test skip:) reused verbatim from Phase 2-7 Wave 0 precedent for both test() and testWidgets() bodies"
  - "Each stub case carries a // TODO(Plan 09-0X): comment naming the exact future behavior, matching the auth_provider_test.dart / account_section_test.dart Phase 07-01 precedent"
  - "reference_pack_delta_apply_test.dart uses testWidgets (not markTestSkipped()-in-body) wrapped in a skipped group(), per this plan's explicit spec — a deliberate departure from the older co2_coverage_benchmark_test.dart self-skip-at-runtime convention, matching the plan's stated rationale that this project's integration_test files are testWidgets-based"

requirements-completed: []

# Metrics
duration: ~20min
completed: 2026-08-13
---

# Phase 9 Plan 1: Wave 0 Test Stubs Summary

**Seven skipped Wave 0 stub test files (ReferencePackRepository, DiskSpaceChecker, ChecksumVerifier, ReferenceDataRow, ReferenceDataScreen, scheduled lifecycle check, DeltaApplier FTS-sync) unblocking every later Phase 9 plan's verify command**

## Performance

- **Duration:** ~20 min
- **Started:** 2026-08-13T11:20:00Z
- **Completed:** 2026-08-13T11:40:24Z
- **Tasks:** 3 completed
- **Files modified:** 7 created, 1 modified (`.gitignore`)

## Accomplishments
- Created `reference_pack_repository_test.dart` with 8 `ReferencePackRepository` cases + 2 `version comparison` cases (→ filled by Plan 09-04)
- Created `disk_space_check_test.dart` with 3 `DiskSpaceChecker` cases (→ filled by Plan 09-02)
- Created `checksum_verifier_test.dart` with 3 `ChecksumVerifier` cases (→ filled by Plan 09-02)
- Created `reference_data_row_test.dart` with 5 `ReferenceDataRow` testWidgets cases (→ filled by Plan 09-05)
- Created `reference_data_screen_test.dart` with 7 `ReferenceDataScreen` testWidgets cases (→ filled by Plan 09-05)
- Created `app_lifecycle_reference_pack_test.dart` with 5 `Reference pack scheduled check` cases (→ filled by Plan 09-06)
- Created `reference_pack_delta_apply_test.dart` with 3 `DeltaApplier` testWidgets cases under `integration_test/` (→ filled by Plan 09-04)
- Verified `flutter test` discovers all 33 unit/widget stub cases across the six non-integration files, reports 0 failures, all skipped with an informative reason string
- Verified the integration stub file via `flutter analyze` (0 errors) since this environment cannot build any `integration_test/` target on macOS or the iOS Simulator (pre-existing Xcode codesign/SwiftPM issue affecting every existing integration test file, not specific to this new file — see Issues Encountered)

## Task Commits

Each task was committed atomically:

1. **Task 1: Data-layer unit-test Wave 0 stubs** - `3b9a2f3` (test)
2. **Task 2: Widget-layer Wave 0 stubs** - `8295893` (test)
3. **Task 3: Lifecycle unit stub + delta-apply integration stub** - `83e2539` (test)

**Plan metadata:** pending (this commit)

## Files Created/Modified
- `test/data/local/reference_pack/reference_pack_repository_test.dart` - Wave 0 stub for manifest fetch/parse, version comparison, disk preflight orchestration, revert (10 cases across 2 groups)
- `test/data/local/reference_pack/disk_space_check_test.dart` - Wave 0 stub for DiskSpaceChecker preflight logic (3 cases)
- `test/data/local/reference_pack/checksum_verifier_test.dart` - Wave 0 stub for SHA-256 match/mismatch verification (3 cases)
- `test/features/settings/reference_data_row_test.dart` - Wave 0 stub for the Settings row subtitle states (5 testWidgets cases)
- `test/features/reference_data/reference_data_screen_test.dart` - Wave 0 stub for the dedicated download/revert screen (7 testWidgets cases)
- `test/app_lifecycle_reference_pack_test.dart` - Wave 0 stub for the foreground-triggered Weekly/Monthly throttle check (5 cases)
- `integration_test/reference_pack_delta_apply_test.dart` - Wave 0 stub proving products_fts stays in sync after a delta apply (3 testWidgets cases)
- `.gitignore` - added `**/xcshareddata/swiftpm/` to ignore build-generated SwiftPM cache dirs surfaced while verifying the integration stub locally

## Decisions Made
- Extended the Phase 2-7 group-level `skip:` pattern verbatim to all seven Phase 9 Wave 0 files — no new convention introduced.
- `reference_pack_delta_apply_test.dart` follows this plan's explicit instruction to use `testWidgets` wrapped in a skipped `group()`, matching this project's testWidgets-based `integration_test` convention rather than the older `markTestSkipped()`-in-body pattern used by Phase 2-6's self-skipping hardware benchmarks (those self-skip at runtime because they conditionally need a real asset; this stub is unconditionally skipped pending Plan 09-04).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed `prefer_single_quotes` lint in `app_lifecycle_reference_pack_test.dart`**
- **Found during:** Task 3 (`flutter analyze` pass before commit)
- **Issue:** One stub case's multi-line string literal used double quotes on a line that (after concatenation) contained no single quotes, triggering the project's `prefer_single_quotes` lint.
- **Fix:** Changed the redundant double-quoted line segment to single quotes.
- **Files modified:** `test/app_lifecycle_reference_pack_test.dart`
- **Verification:** `flutter analyze test/app_lifecycle_reference_pack_test.dart` → 0 `prefer_single_quotes` issues (only the expected `flutter_style_todos` info-level lints remain, matching every prior phase's `TODO(Plan XX-YY)` convention)
- **Committed in:** `83e2539` (Task 3 commit)

**2. [Rule 3 - Blocking] Added `**/xcshareddata/swiftpm/` to `.gitignore`**
- **Found during:** Task 3 (post-commit `git status --short` check)
- **Issue:** Attempting to verify `reference_pack_delta_apply_test.dart` via `flutter test -d macos` / `-d <iOS simulator>` triggered Xcode's Swift Package Manager dependency resolution, which wrote `Package.resolved` and related cache files under `ios/Runner.xcworkspace/xcshareddata/swiftpm/` and `macos/Runner.xcworkspace/xcshareddata/swiftpm/` (and `macos/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/`) — none matched by the existing `.swiftpm/` gitignore entry (different path shape) and would otherwise have been left untracked.
- **Fix:** Added `**/xcshareddata/swiftpm/` to `.gitignore`.
- **Files modified:** `.gitignore`
- **Verification:** `git status --short` no longer lists the three swiftpm cache directories as untracked.
- **Committed in:** `83e2539` (Task 3 commit)

---

**Total deviations:** 2 auto-fixed (1 bug, 1 blocking/gitignore hygiene)
**Impact on plan:** Both fixes are housekeeping only — no production code, no test-case content changes. No scope creep.

## Issues Encountered

**Integration test build environment limitation (not a code defect):** `flutter test integration_test/reference_pack_delta_apply_test.dart` cannot complete in this environment on either target:
- `-d macos`: fails at `CodeSign` with "resource fork, Finder information, or similar detritus not allowed" against `build/macos/Build/Products/Debug/co2diet.app`.
- `-d <iOS Simulator>`: Xcode build reports "Exited with status code 255" / "Could not build the application for the simulator" after a successful `xcodebuild` step.

Both failures were reproduced identically against the pre-existing, already-passing `integration_test/co2_coverage_benchmark_test.dart` (unrelated to this plan's changes), confirming this is a local Xcode/codesign/SwiftPM environment issue affecting every `integration_test/` file, not something introduced by this plan. Per the deviation rules' scope boundary, this is out of scope to fix in this plan (pre-existing, unrelated to the current task's changes) and is not a Rule 1/3 auto-fix candidate — it requires local Xcode/simulator environment repair, not a code change.

Verification for the new stub file was instead done via `flutter analyze integration_test/reference_pack_delta_apply_test.dart` (0 errors, only the expected `flutter_style_todos` info-level lints) plus manual code review confirming the file mirrors the already-passing `reference_data_row_test.dart`/`reference_data_screen_test.dart` group-skip structure. The file's actual `flutter test` execution (0 failures, all skipped) will need to be confirmed the first time a real device/working simulator build is available — flagged here for whoever executes Plan 09-04 (which fills this stub in) to double-check as part of that plan's own `<verify>` step.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- All seven Wave 0 stub files exist, are discovered by `flutter test` (or `flutter analyze` for the one blocked-by-environment integration file), and are cleanly skipped — every later Phase 9 plan (09-02, 09-04, 09-05, 09-06) now has a target file whose `<verify>` command will find real content instead of "file not found".
- No blockers for Plan 09-02 (DiskSpaceChecker + ChecksumVerifier implementation) to start next.

---
*Phase: 09-reference-data-delivery-full-off-pack*
*Completed: 2026-08-13*

## Self-Check: PASSED

All 7 created files verified present on disk; all 3 task commit hashes (`3b9a2f3`, `8295893`, `83e2539`) verified present in `git log`.

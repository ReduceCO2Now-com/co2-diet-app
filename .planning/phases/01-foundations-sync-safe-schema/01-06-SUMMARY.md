---
phase: 01-foundations-sync-safe-schema
plan: "06"
subsystem: infra
tags: [ci, github-actions, dart, privacy, blocklist, flutter, pubspec]

requires:
  - phase: 01-foundations-sync-safe-schema
    plan: "01"
    provides: pubspec.lock with approved Phase 1 packages that the blocklist script audits

provides:
  - .privacy-blocklist.yaml with 14 blocked SDK prefixes (firebase_, crashlytics, amplitude_, mixpanel_, sentry_, segment_, datadog_, onesignal_, appsflyer_, adjust_, braze_, clevertap, leanplum, moengage)
  - scripts/check_privacy_deps.dart standalone Dart audit script (dart:io only; exits 0/1)
  - .github/workflows/ci.yml two-job CI pipeline (ubuntu analyze+test+build-apk, macos build-ios) pinned to Flutter 3.44.6

affects:
  - all future phases (CI runs on every PR; blocklist gate enforced from plan 01-06 forward)
  - plan 01-07 (blocklist_test.dart tests the check_privacy_deps.dart script exit paths)

tech-stack:
  added:
    - subosito/flutter-action@v2 (GitHub Actions Flutter setup)
    - actions/checkout@v4
    - actions/cache@v4
  patterns:
    - Privacy SDK blocklist enforced via pubspec.lock audit before flutter analyze on every PR
    - Standalone Dart script (no pub dependencies) for CI tooling — runs without pub get completing first
    - Flutter version pinned in CI via flutter-version field (not channel-only) for reproducibility

key-files:
  created:
    - .privacy-blocklist.yaml
    - scripts/check_privacy_deps.dart
    - .github/workflows/ci.yml

key-decisions:
  - "Blocklist uses prefix matching (not exact names) to catch transitive firebase_* packages automatically"
  - "CI blocklist audit step runs BEFORE flutter analyze so blocked deps fail fast without running compilation"
  - "check_privacy_deps.dart uses manual YAML parsing (no yaml package) so it can run before pub get completes"
  - "14 prefixes committed (plan required >=8): adds appsflyer_, adjust_, braze_, clevertap, leanplum, moengage beyond the minimum 8"
  - "xattr workaround included in iOS job for Xcode 26 compatibility"

patterns-established:
  - "Privacy gate pattern: blocklist audit → analyze → test → build (never after analyze)"
  - "Manual YAML parsing pattern for CI tooling that must run before pub get"

requirements-completed:
  - PRIV-07

duration: 2min
completed: "2026-07-17"
---

# Phase 01 Plan 06: CI Privacy Pipeline Summary

**PRIV-07 automated SDK blocklist gate: standalone Dart auditor (dart:io only) + two-job GitHub Actions pipeline pinned to Flutter 3.44.6 that fails any PR importing firebase/analytics/ad SDKs**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-07-17T08:52:47Z
- **Completed:** 2026-07-17T08:54:xx Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- .privacy-blocklist.yaml at repo root with 14 blocked prefix patterns — covers all common analytics, crash-reporting, ad, and behavioral tracking SDKs
- scripts/check_privacy_deps.dart: standalone Dart script (dart:io + dart:core only, zero pub dependencies) that manually parses pubspec.lock and the blocklist YAML; exits 0 with "OK: N packages checked, 0 violations" on clean deps; exits 1 with "BLOCKED: package (matches prefix ...)" on any match; verified against Phase 1 pubspec.lock (126 packages, 0 violations) and confirmed exit 1 against injected firebase_core and sentry_flutter entries
- .github/workflows/ci.yml: two parallel jobs — analyze-test-android (ubuntu-latest: pub cache, pub get, blocklist audit, flutter analyze, dart test, build cache, build apk --debug) and build-ios (macos-latest: pub cache, pub get, xattr Xcode 26 workaround, build ios --no-codesign) — both pinned to Flutter 3.44.6 via subosito/flutter-action@v2

## Task Commits

1. **Task 1: .privacy-blocklist.yaml + check_privacy_deps.dart** - `8d869f7` (feat)
2. **Task 2: .github/workflows/ci.yml — two-job CI pipeline** - `6f60154` (feat)

## Files Created/Modified

- `.privacy-blocklist.yaml` — 14 blocked package name prefixes; YAML config read by the audit script
- `scripts/check_privacy_deps.dart` — standalone Dart audit script; parses pubspec.lock via RegExp on 2-space-indented package names; parses blocklist via 2-space-indented list items; exits 0 or 1
- `.github/workflows/ci.yml` — two-job GitHub Actions workflow triggered on push/PR to main; Flutter 3.44.6 in both jobs

## Decisions Made

- Blocklist YAML list items use 2-space indent (standard YAML convention); script regex updated from `^ {4}- ` to `^ {2}- ` after discovering the mismatch during verification — the inline fix was caught before commit
- 14 prefixes instead of the minimum 8 required by PRIV-07: added appsflyer_, adjust_, braze_, clevertap, leanplum, moengage at zero additional cost since they are equally common analytics/ad SDKs
- Blocklist audit placed before flutter analyze in the ubuntu job so any blocked dependency fails the CI fast without wasting compile time

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed blocklist YAML parser regex indent mismatch**

- **Found during:** Task 1 (check_privacy_deps.dart implementation + verification)
- **Issue:** Script used `^ {4}- (.+)$` (4-space indent) to parse blocklist list items, but the YAML file uses 2-space indent (`  - firebase_`); blockedPrefixes array was always empty so exit(1) path never triggered
- **Fix:** Changed regex to `^ {2}- (.+)$` to match the actual 2-space indented YAML list items
- **Files modified:** scripts/check_privacy_deps.dart
- **Verification:** After fix: exit-0 on Phase 1 pubspec.lock (126 packages, 0 violations); exit-1 with "BLOCKED: firebase_core (matches prefix "firebase_")" on injected test entry; exit-1 with "BLOCKED: sentry_flutter (matches prefix "sentry_")" on second test
- **Committed in:** 8d869f7 (Task 1 commit, fix incorporated before first commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 — bug)
**Impact on plan:** Essential correctness fix caught during local verification before commit. No scope creep.

## Issues Encountered

None — dart parsing logic debugged and fixed before first commit; both verification paths (exit 0 and exit 1) confirmed working.

## User Setup Required

Branch protection rules must be configured manually in GitHub Settings after CI runs green on first push:

1. Go to GitHub repository Settings → Branches → Add rule for `main`
2. Enable "Require status checks to pass before merging"
3. Add required checks: `analyze-test-android` and `build-ios`
4. Save — no required reviewer needed (sole Flutter dev)

This cannot be automated via workflow files; it is a manual one-time step.

## Next Phase Readiness

- Plan 01-07 (blocklist_test.dart) can now import and test scripts/check_privacy_deps.dart
- Every future PR will automatically run the SDK blocklist audit before analyzing or building
- No blockers; PRIV-07 requirement fully satisfied

---

*Phase: 01-foundations-sync-safe-schema*
*Completed: 2026-07-17*

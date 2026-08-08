---
phase: 07-keycloak-auth-account-mode-sync
plan: 01
subsystem: testing
tags: [flutter_test, wave-0-stubs, keycloak, auth, gdpr-deletion, co2-methodology]

# Dependency graph
requires: []
provides:
  - Five skipped Wave 0 stub test files covering AUTH-01 through AUTH-06, PRIV-05, and the CO2 methodology-announcement mechanism
  - Nyquist-contract scaffolding so every later Phase 7 plan's `<verify>` command has a target file to turn green
affects: [07-02, 07-03, 07-04, 07-05, 07-06, 07-07, 07-08]

# Tech tracking
tech-stack:
  added: []
  patterns: [group-level skip: pattern for test() and testWidgets(), reused verbatim from Phase 2-6 Wave 0 precedent]

key-files:
  created:
    - test/features/auth/providers/auth_provider_test.dart
    - test/domain/services/methodology_version_checker_test.dart
    - test/features/auth/auth_screen_test.dart
    - test/features/settings/widgets/account_section_test.dart
    - test/features/dashboard/widgets/co2_methodology_banner_test.dart
  modified: []

key-decisions:
  - "Group-level skip: arg on group() (not per-test skip:) reused verbatim from Phase 2-6 Wave 0 precedent for both test() and testWidgets() bodies"
  - "Each stub case carries a // TODO(Plan 07-0X): comment naming the exact future behavior, matching the ed_safety_net_checker_test.dart / legal_consent_screen_test.dart Phase 06-01 precedent"

patterns-established:
  - "Wave 0 stub convention (group-level skip, TODO(Plan XX-YY) per case) applied unchanged for the 7th consecutive phase"

requirements-completed: [AUTH-01, AUTH-02, AUTH-03, AUTH-04, AUTH-05, AUTH-06, PRIV-05]

# Metrics
duration: ~5min
completed: 2026-08-08
---

# Phase 7 Plan 1: Wave 0 Test Stubs Summary

**Five skipped Wave 0 stub test files (AuthNotifier, realm discovery, methodology version checker, AuthScreen, AccountSection, Co2MethodologyBanner) unblocking every later Phase 7 plan's verify command**

## Performance

- **Duration:** ~5 min
- **Tasks:** 2 completed
- **Files modified:** 5 created

## Accomplishments
- Created `auth_provider_test.dart` with 12 `AuthNotifier` cases + 2 `realmDiscoveryReadyProvider` cases (→ filled by Plan 07-03)
- Created `methodology_version_checker_test.dart` with 3 `isStale` cases + 4 `hasAnyStale` cases (→ filled by Plan 07-04)
- Created `auth_screen_test.dart` with 11 widget cases covering combined sign-in/create-account + Check Email screen (→ filled by Plan 07-05)
- Created `account_section_test.dart` with 8 widget cases covering Settings Account section, including GDPR delete-account confirmation flow (→ filled by Plan 07-06)
- Created `co2_methodology_banner_test.dart` with 5 widget cases covering the dismissible Dashboard banner + per-version dismissal persistence (→ filled by Plan 07-07)
- Verified `flutter test` discovers all 45 stub cases across 5 files, reports 0 failures, all skipped with informative reason strings

## Task Commits

Each task was committed atomically:

1. **Task 1: Domain/provider-layer Wave 0 stubs** - `2c878cf` (test)
2. **Task 2: Widget-layer Wave 0 stubs** - `05abd50` (test)

**Plan metadata:** pending (docs: complete plan)

## Files Created/Modified
- `test/features/auth/providers/auth_provider_test.dart` - AuthNotifier (silent refresh, network-vs-invalidation distinction, signIn/signUp/signInWithIdp, logout, deleteAccount) + realmDiscoveryReadyProvider stubs
- `test/domain/services/methodology_version_checker_test.dart` - isStale/hasAnyStale stubs for the CO2 methodology-announcement mechanism
- `test/features/auth/auth_screen_test.dart` - combined sign-in/create-account screen + Check Email screen widget stubs
- `test/features/settings/widgets/account_section_test.dart` - Settings Account section widget stubs (sign-in/out, password change, GDPR deletion)
- `test/features/dashboard/widgets/co2_methodology_banner_test.dart` - dismissible Dashboard banner widget stubs

## Decisions Made
- Group-level `skip:` argument on `group()` (not per-test `skip:`) reused verbatim from the Phase 2-6 Wave 0 precedent, for both `test()` and `testWidgets()` bodies — matches STATE.md's `[Phase 02-01]`/`[Phase 05-01]`/`[Phase 06-01]` decisions
- Each stub case carries a `// TODO(Plan 07-0X):` comment immediately above it naming the exact future behavior, mirroring the Phase 06-01 `ed_safety_net_checker_test.dart`/`legal_consent_screen_test.dart` precedent read directly from git history before writing new files

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Requirements Status

`requirements.mark-complete` was intentionally NOT run for AUTH-01 through AUTH-06 / PRIV-05. This plan only creates skipped Wave 0 test stubs — no production behavior exists yet. These requirement IDs remain "Pending" in `REQUIREMENTS.md`'s traceability table and will be marked complete by whichever later Phase 7 plan (07-03 through 07-07) turns the corresponding stub file green.

## Next Phase Readiness

All five Wave 0 stub files exist, are discovered by `flutter test`, and cleanly skip (0 failures). Plans 07-02 through 07-08 can each target one of these files, implement the corresponding production code, and remove its `skip:` marker as part of turning the stub green — satisfying the Nyquist contract established in this plan.

---
*Phase: 07-keycloak-auth-account-mode-sync*
*Completed: 2026-08-08*

## Self-Check: PASSED

All 5 created files found on disk. Both task commits (2c878cf, 05abd50) found in git history.

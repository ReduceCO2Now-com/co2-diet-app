---
phase: 07-keycloak-auth-account-mode-sync
plan: 04
subsystem: domain
tags: [dart, tdd, co2-methodology]

# Dependency graph
requires:
  - phase: 07-keycloak-auth-account-mode-sync
    provides: Plan 07-01's Wave 0 skipped test stub for methodology_version_checker_test.dart
provides:
  - "currentCo2MethodologyVersion constant (app-binary CO2 methodology version, pinned at '1.0' this phase)"
  - "MethodologyVersionChecker.isStale/hasAnyStale -- pure, DB-free staleness comparison logic"
affects: [07-07]

# Tech tracking
tech-stack:
  added: []
  patterns: ["Pure comparison-logic domain services with zero Drift/DB imports, unit-testable without a database"]

key-files:
  created:
    - lib/domain/services/methodology_version_checker.dart
  modified:
    - test/domain/services/methodology_version_checker_test.dart

key-decisions:
  - "currentCo2MethodologyVersion intentionally stays '1.0' this phase per 07-CONTEXT.md's explicit scope boundary -- this plan builds the comparison mechanism only, not a version bump"
  - "isStale is plain string inequality, not semver comparison -- versions in this codebase are simple decimal strings"

patterns-established:
  - "MethodologyVersionChecker takes plain version strings as input (no Drift row types, no DAOs) so it composes cleanly with real DB reads in a later plan without ever needing a mocked database in its own tests"

requirements-completed: [CO2-04]

# Metrics
duration: ~2min
completed: 2026-08-09
---

# Phase 7 Plan 04: MethodologyVersionChecker Summary

**Pure, DB-free `MethodologyVersionChecker` (isStale/hasAnyStale) built via TDD against a `currentCo2MethodologyVersion` constant pinned at '1.0', ready for Plan 07-07 to wire against real DB reads for the Dashboard methodology-update banner.**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-08-09T15:23:25Z
- **Completed:** 2026-08-09T15:24:46Z
- **Tasks:** 1 (TDD: RED -> GREEN)
- **Files modified:** 2

## Accomplishments
- `currentCo2MethodologyVersion` constant added (`'1.0'`, doc-commented as deliberately not bumped this phase)
- `MethodologyVersionChecker.isStale` -- null-safe, string-inequality staleness check with an optional `currentVersion` override for testing future-version scenarios
- `MethodologyVersionChecker.hasAnyStale` -- composes profile/meal/food version lists into a single staleness verdict
- Removed the `skip:` marker and placeholder cases from `methodology_version_checker_test.dart` (created in Plan 07-01), replaced with the 8 real behavior-case tests from the plan spec, all green with zero skips

## Task Commits

Each task was committed atomically (TDD RED -> GREEN, no REFACTOR needed -- `flutter analyze` was clean on first pass):

1. **Task 1: MethodologyVersionChecker** (RED) - `88e7d6c` (test)
2. **Task 1: MethodologyVersionChecker** (GREEN) - `ba15afe` (feat)

**Plan metadata:** pending (this commit)

## Files Created/Modified
- `lib/domain/services/methodology_version_checker.dart` - `currentCo2MethodologyVersion` constant + `MethodologyVersionChecker` class (isStale, hasAnyStale)
- `test/domain/services/methodology_version_checker_test.dart` - Real TDD test suite replacing Plan 07-01's skipped stub; 8 tests covering every behavior case from the plan spec

## Decisions Made
- `currentCo2MethodologyVersion` stays `'1.0'` this phase -- per 07-CONTEXT.md's explicit scope boundary, this plan builds the comparison mechanism only, never touching CO2 factor data or bumping the constant
- `isStale` uses plain string inequality (not semver parsing) -- this codebase's version strings are simple decimals (`'1.0'`, `'0.9'`), and the mechanism only ever needs "differs from the constant", not ordered comparison

## Deviations from Plan

None - plan executed exactly as written. `flutter analyze` flagged one `public_member_api_docs` info-level issue on the const constructor (no doc comment); fixed inline as part of the same GREEN commit since it's a pre-existing project-wide lint convention (very_good_analysis), not a new deviation category.

## Issues Encountered
None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

`MethodologyVersionChecker` is a pure, fully-tested unit ready for Plan 07-07 to compose with real Drift DAO reads (profile/meal/food version columns) to drive the Dashboard's local-only CO2 methodology-update announcement (CO2-04's "surfaces a non-intrusive announcement" clause). No blockers.

---
*Phase: 07-keycloak-auth-account-mode-sync*
*Completed: 2026-08-09*

## Self-Check: PASSED

- FOUND: lib/domain/services/methodology_version_checker.dart
- FOUND: test/domain/services/methodology_version_checker_test.dart
- FOUND commit: 88e7d6c (test)
- FOUND commit: ba15afe (feat)

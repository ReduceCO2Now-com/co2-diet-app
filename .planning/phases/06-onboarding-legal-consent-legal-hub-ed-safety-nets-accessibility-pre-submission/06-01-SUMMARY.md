---
phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
plan: 01
subsystem: testing
tags: [flutter_test, wave-0-stubs, group-skip, tdd-scaffolding]

# Dependency graph
requires:
  - phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
    provides: Established group-level skip Wave 0 stub convention (25 stubs, all replaced by real tests during Phase 5 execution)
provides:
  - Six Wave 0 skipped test-file stubs covering all of Phase 6's core requirement surfaces (NFR-07, LEGAL-01/02/03, PRIV-06, ONBD-01/05)
  - Unblocked `<verify>` commands for every later Phase 6 plan (06-02 through 06-09), each of which fills in exactly one of these files
affects: [06-02, 06-03, 06-04, 06-05, 06-07, 06-08, 06-09]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Group-level skip: single top-level group('<ClassName>', skip: '<reason>', () { ... }) wrapping empty test()/testWidgets() cases named after exact future behavior — no production imports in stub files"

key-files:
  created:
    - test/domain/services/ed_safety_net_checker_test.dart
    - test/data/repositories/consent_repository_test.dart
    - test/domain/services/legal_document_loader_test.dart
    - test/features/legal/legal_consent_screen_test.dart
    - test/features/legal/consent_history_screen_test.dart
    - test/features/onboarding/onboarding_gate_test.dart
  modified: []

key-decisions:
  - "Reused Phase 2-5 Wave 0 group-level skip convention verbatim, including testWidgets bodies wrapped inside a skipped group() (mirrors [Phase 05-01] decision extended to testWidgets)"

patterns-established:
  - "Wave 0 stub files import only package:flutter_test/flutter_test.dart — zero production-code imports until the implementing plan turns each stub green"

requirements-completed: []  # No requirement is fully satisfied by stub scaffolding alone — each ID is closed out by its implementing plan (06-02 through 06-09), not this Wave 0 plan.

# Metrics
duration: 5min
completed: 2026-08-04
---

# Phase 6 Plan 01: Wave 0 Test Stub Scaffolding Summary

**Six skipped test-file stubs (22 named test cases) scaffolding NFR-07 ED safety net thresholds, LEGAL-01/02/03 consent domain + screen, PRIV-06 consent history, and ONBD-01/05 onboarding redirect gating — zero production code, zero failures.**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-08-04T08:31:00Z (approx)
- **Completed:** 2026-08-04T08:32:00Z (approx)
- **Tasks:** 2
- **Files modified:** 6 (all new)

## Accomplishments
- Created the six Wave 0 stub test files flagged as missing by `06-RESEARCH.md`/`06-VALIDATION.md`, using the verbatim group-level `skip:` pattern established in every prior phase (Phase 2-5 Wave 0 plans)
- Every later Phase 6 plan's `<verify>` command (`flutter test <file>`) now runs cleanly against a real file instead of failing with "file not found"
- `flutter test` across all six files together reports 22 skipped test cases, 0 failures, exit code 0

## Task Commits

Each task was committed atomically:

1. **Task 1: Domain/data-layer Wave 0 stubs** - `f392146` (test)
2. **Task 2: Widget-layer Wave 0 stubs** - `1b5159c` (test)

**Plan metadata:** (pending — this commit)

## Files Created/Modified
- `test/domain/services/ed_safety_net_checker_test.dart` - 6 cases stubbing `calorieTargetIsUnsafe` (1200/1199/500 kcal boundaries) and `bmiIsUnsafe` (null-height, <17.5, >=17.5) for NFR-07, filled by Plan 06-03
- `test/data/repositories/consent_repository_test.dart` - 4 cases stubbing `recordConsent` (id/appVersion/policyVersion/consentsGiven write + DAO isolation) and `watchConsents` (row-to-entity mapping, empty case) for LEGAL-03, filled by Plan 06-04
- `test/domain/services/legal_document_loader_test.dart` - 3 cases stubbing the frontmatter `version:` round-trip (well-formed, missing, malformed), filled by Plan 06-02
- `test/features/legal/legal_consent_screen_test.dart` - 5 cases stubbing checkbox gating, no-precheck, Terms/Privacy/Disclaimer links, ACC-02 text-scale overflow, ACC-03 semantics, for LEGAL-01/02, filled by Plan 06-07
- `test/features/legal/consent_history_screen_test.dart` - 2 cases stubbing per-ConsentEvent row rendering and empty state for PRIV-06, filled by Plan 06-08
- `test/features/onboarding/onboarding_gate_test.dart` - 3 cases stubbing first-launch redirect, post-onboarding redirect-away-from-/welcome, and deep-link-before-onboarding redirect for ONBD-01/05, filled by Plan 06-09 (with a unit-level supplement from Plan 06-05)

## Decisions Made
None beyond reapplying the existing convention — see `patterns-established` above.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

All six Wave 0 stub files exist, are discovered by `flutter test`, and are cleanly skipped (0 failures). Wave 1 plans (06-02: legal docs + loader, 06-03: ED safety net checker) can now proceed — each will turn exactly one stub file green and remove its `skip:` marker per the Nyquist contract.

## Known Stubs

All six files created by this plan are intentional Wave 0 stubs by design — this is the plan's entire purpose, not an oversight. Each is tracked to a specific later plan:

| File | Filled by |
|------|-----------|
| `test/domain/services/ed_safety_net_checker_test.dart` | Plan 06-03 |
| `test/data/repositories/consent_repository_test.dart` | Plan 06-04 |
| `test/domain/services/legal_document_loader_test.dart` | Plan 06-02 |
| `test/features/legal/legal_consent_screen_test.dart` | Plan 06-07 |
| `test/features/legal/consent_history_screen_test.dart` | Plan 06-08 |
| `test/features/onboarding/onboarding_gate_test.dart` | Plan 06-09 |

---
*Phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission*
*Completed: 2026-08-04*

## Self-Check: PASSED

All 6 created test files found on disk. Both task commits (`f392146`, `1b5159c`) found in git log.

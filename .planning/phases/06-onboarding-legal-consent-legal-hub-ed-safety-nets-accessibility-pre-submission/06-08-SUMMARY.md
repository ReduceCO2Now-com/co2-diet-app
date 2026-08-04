---
phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
plan: 08
subsystem: ui
tags: [flutter, riverpod, legal, gdpr, consent, streambuilder, intl]

# Dependency graph
requires:
  - phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission plan 04
    provides: "ConsentEvent domain entity, IConsentRepository.watchConsents(), consentRepositoryProvider"
  - phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission plan 03
    provides: "showHelplineResourcesSheet() standalone ED-resources sheet"
  - phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
    provides: "BackupRestoreScreen (/backup-restore) with Export Data + Danger Zone sections reused by Your Rights"
provides:
  - "LegalHubScreen -- About, Legal Documents, Your Rights (redirect-only GDPR explainer), consent history entry, ED-resources entry, contact email"
  - "ConsentHistoryScreen -- read-only, plain-language rendering of every ConsentEvent via IConsentRepository.watchConsents()"
affects: [phase-06 plan 09 router wiring, phase-06 plan 10 accessibility/tone checkpoints]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Legal Hub route slugs kept snake_case (health_disclaimer) via a private _LegalDocRouteSlug extension, matching LegalConsentScreen's already-committed doc= query convention rather than LegalDocId.name's camelCase"
    - "ConsentHistoryScreen uses ref.watch(consentRepositoryProvider) + widget-level StreamBuilder rather than a dedicated @riverpod StreamProvider -- avoids an extra codegen surface for a single-consumer read"

key-files:
  created:
    - lib/features/legal/screens/legal_hub_screen.dart
    - lib/features/legal/screens/consent_history_screen.dart
  modified:
    - test/features/legal/consent_history_screen_test.dart

key-decisions:
  - "Legal Hub's Your Rights section redirects every action tile to the existing /backup-restore screen (Export Data + Danger Zone) -- no new mutation/action screen built, per 06-CONTEXT.md's locked Anti-Pattern list"
  - "Contact email uses docs/legal/impressum.md's placeholder-but-plausible contact@reduceco2now.example, not a different invented address"
  - "consentsGiven raw identifiers (terms/privacy/not_medical_advice/user_responsibility/age_16_plus) translated via a private lookup map -- raw JSON keys never reach the UI"

patterns-established:
  - "Route slug extensions decouple internal enum naming (LegalDocId.name, camelCase) from URL query-param conventions (snake_case) when a prior plan already committed to a specific string set"

requirements-completed: [LEG-01, LEG-02, LEG-03, PRIV-06]

# Metrics
duration: ~15min
completed: 2026-08-04
---

# Phase 06 Plan 08: Legal Hub + Consent History Summary

**LegalHubScreen (About/Legal Documents/Your Rights/consent-history entry/ED-resources entry/contact) and ConsentHistoryScreen, the first real UI consumer of Phase 1's `ConsentRecordsDao.watchConsents()`, rendering every past consent event in plain language.**

## Performance

- **Duration:** ~15 min
- **Started:** 2026-08-04T08:01:21Z (session start)
- **Completed:** 2026-08-04T08:07:07Z
- **Tasks:** 2 completed
- **Files modified:** 3 (2 created, 1 modified)

## Accomplishments
- LegalHubScreen: About, 4 Legal Documents tiles (Terms/Privacy/Health Disclaimer/Impressum), a GDPR "Your Rights" section that redirects to the existing Export Data and Danger Zone sections of `/backup-restore` (no new data-mutation screen), a "View my consent history" entry, a standalone "Concerned about eating?" entry point (independent of the reactive ED safety-net dialog), and a real contact email
- ConsentHistoryScreen: reads `IConsentRepository.watchConsents()` via a `StreamBuilder`, rendering one `Card` per `ConsentEvent` (formatted UTC timestamp, app version, policy version, plain-language translation of accepted checkboxes) with a dedicated empty-state message
- Zero FAQ section, zero Discord/community link anywhere in the Legal Hub, per 06-CONTEXT.md's Deferred Ideas

## Task Commits

Each task was committed atomically:

1. **Task 1: LegalHubScreen** - `fa9f7fb` (feat)
2. **Task 2: ConsentHistoryScreen** - `e9895cd` (test, RED) → `7b519ff` (feat, GREEN)

**Plan metadata:** (this commit)

_Note: Task 2 followed TDD RED/GREEN — the RED commit intentionally fails to compile since `ConsentHistoryScreen` did not yet exist._

## Files Created/Modified
- `lib/features/legal/screens/legal_hub_screen.dart` - LegalHubScreen: About, Legal Documents, Your Rights (redirect-only), consent history entry, ED-resources entry, contact
- `lib/features/legal/screens/consent_history_screen.dart` - ConsentHistoryScreen: read-only StreamBuilder over `IConsentRepository.watchConsents()`
- `test/features/legal/consent_history_screen_test.dart` - Removed `skip:` marker; real widget tests for populated (2 events) and empty-state cases

## Decisions Made
- Kept Legal Hub → Legal Document route slugs snake_case (`health_disclaimer`) via a private extension, rather than using `LegalDocId.name` verbatim as the plan's action text literally showed — `LegalDocId.healthDisclaimer.name` is camelCase (`healthDisclaimer`), which would have silently diverged from `LegalConsentScreen`'s already-committed `doc=health_disclaimer` query convention that Plan 06-09's router wiring must parse uniformly for both screens. Classified as a Rule 3 blocking-issue auto-fix (prevents a future router-wiring inconsistency, not a scope change).
- Used a widget-level `StreamBuilder` directly against `ref.watch(consentRepositoryProvider).watchConsents()` rather than adding a dedicated `@riverpod` `StreamProvider` — plan explicitly allowed either; this avoids an extra codegen surface for a screen with a single stream consumer.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Legal document route slugs kept snake_case instead of `LegalDocId.name`**
- **Found during:** Task 1 (LegalHubScreen)
- **Issue:** The plan's action text specified `context.push('/legal-hub/document?doc=${docId.name}')`, but `LegalDocId.healthDisclaimer.name` evaluates to `'healthDisclaimer'` (camelCase), while `LegalConsentScreen` (Plan 06-07, already committed) pushes the same route with `doc=health_disclaimer` (snake_case) for its two Health Disclaimer links. Left as written, the two screens would produce divergent query strings for the same document, which Plan 06-09's future router `doc=` parser would need to special-case rather than parse uniformly.
- **Fix:** Added a private `_LegalDocRouteSlug` extension on `LegalDocId` mapping each variant to the exact snake_case slug `LegalConsentScreen` already uses (`terms`, `privacy`, `health_disclaimer`, `impressum`), and used `docId.routeSlug` instead of `docId.name` in the Legal Documents tiles' `onTap`.
- **Files modified:** `lib/features/legal/screens/legal_hub_screen.dart`
- **Verification:** `flutter analyze lib/features/legal/screens/legal_hub_screen.dart` — no issues
- **Committed in:** `fa9f7fb` (Task 1 commit)

**2. [Rule 1 - Bug] Test date-substring assertion loosened**
- **Found during:** Task 2 (ConsentHistoryScreen TDD GREEN run)
- **Issue:** The first widget test asserted `findsOneWidget` for the substring `'2026-07-16'`, but the test fixture's `policyVersion` ('2026-07-16') legitimately shares that exact date substring with the row's own formatted timestamp — both are correct, expected UI text, not a screen defect. The over-tight assertion caused a false test failure against a correctly implemented screen.
- **Fix:** Changed the assertion to `findsWidgets` (at least one match) with an inline comment explaining the legitimate overlap, for both the `2026-07-16` and `2026-08-01` substring checks.
- **Files modified:** `test/features/legal/consent_history_screen_test.dart`
- **Verification:** `flutter test test/features/legal/consent_history_screen_test.dart` — 2/2 passing
- **Committed in:** `7b519ff` (Task 2 GREEN commit)

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug — in the executor's own test)
**Impact on plan:** Both fixes necessary for correctness (route-convention consistency for the next plan's router wiring; a non-buggy test that previously asserted an overly strict substring uniqueness). No scope creep — no new screens, mutations, or features added beyond the plan's spec.

## Issues Encountered
None beyond the two auto-fixed deviations above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `LegalHubScreen` and `ConsentHistoryScreen` exist and are fully self-contained/testable, but neither is yet reachable from `app_router.dart` or `SettingsScreen` — Plan 06-09 (Wave 4) is explicitly responsible for router/redirect/Settings wiring, mirroring Phase 5's `Co2SettingsScreen`/`BackupRestoreScreen` precedent (`[Phase 05-12]`/`[Phase 05-16]` decisions).
- LEG-01/02/03 and PRIV-06 requirement content is now fully built; REQUIREMENTS.md traceability will mark them complete via this plan's `requirements` frontmatter, but end-user reachability still depends on Plan 06-09.
- No blockers for Plan 06-09.

---
*Phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission*
*Completed: 2026-08-04*

## Self-Check: PASSED

All created files verified present on disk; all 3 task commit hashes (`fa9f7fb`, `e9895cd`, `7b519ff`) verified present in `git log --oneline --all`.

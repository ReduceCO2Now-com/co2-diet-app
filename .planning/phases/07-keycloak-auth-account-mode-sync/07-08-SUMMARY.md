---
phase: 07-keycloak-auth-account-mode-sync
plan: 08
subsystem: auth
tags: [go_router, riverpod, flutter, keycloak, gdpr, legal]

# Dependency graph
requires:
  - phase: 07-keycloak-auth-account-mode-sync
    provides: "AuthNotifier/authProvider (AuthState sealed class, deleteAccount, /auth+/check-email routes already wired by Plan 07-06), AccountSection Settings wiring (07-06), Co2MethodologyBanner (07-07)"
provides:
  - "ModeIndicator wired to real AuthState -- Dashboard now tells the truth about Account Mode's zero-sync status instead of the old hardcoded 'Synced across devices' placeholder"
  - "Legal Hub 'Your Rights' cross-references the in-app Delete Account flow (Settings -> Account)"
  - "terms.md Section 9 'Account Mode & Data' -- optional/separate, zero data movement, separate account_mode_terms consent, immediate/irreversible in-app deletion per GDPR Art. 17"
  - "docs/backend-contracts/gdpr-account-deletion.md -- concrete written [ASSUMED] API contract spec for Tomris covering DELETE /me/account"
affects: [08-user-data-sync-engine]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Written backend-contract spec docs (docs/backend-contracts/*.md) as the hand-off artifact for cross-team API assumptions, with every field explicitly [ASSUMED -- not yet confirmed with X] rather than presented as agreed"

key-files:
  created:
    - docs/backend-contracts/gdpr-account-deletion.md
  modified:
    - lib/features/dashboard/widgets/mode_indicator.dart
    - lib/features/dashboard/screens/placeholder_dashboard_screen.dart
    - lib/features/legal/screens/legal_hub_screen.dart
    - docs/legal/terms.md
    - test/features/dashboard/metric_card_test.dart
    - test/domain/services/legal_document_loader_test.dart

key-decisions:
  - "/auth and /check-email routes were already registered in app_router.dart by Plan 07-06 (a Rule 2 deviation documented in 07-06-SUMMARY.md) -- verified present, no router changes needed in this plan despite the plan text describing them as this plan's job"
  - "terms.md's existing Contact section was numbered '## 8. Contact' in the actual file (not '## 9. Contact' as PLAN.md's prose assumed) -- new Account Mode & Data section inserted as '## 9.', Contact renumbered to '## 10.'"
  - "terms.md version bumped to the actual host machine's local date (2026-08-10, per `date +%Y-%m-%d`) rather than the UTC-based date referenced in conversation context, since the plan's own automated verify step shells out to `date +%Y-%m-%d` and must match byte-for-byte"

requirements-completed: [AUTH-01, AUTH-02, AUTH-03, AUTH-05, AUTH-06, PRIV-05, AUTH-10]

# Metrics
duration: ~15min
completed: 2026-08-10
---

# Phase 7 Plan 08: Phase 7 Close-Out -- Router Wiring, ModeIndicator, Legal Hub, Terms, GDPR Contract Summary

**Wired Dashboard's ModeIndicator to real AuthNotifier state with the locked "Account Mode: Data still stored locally (sync coming soon)" copy, cross-referenced Delete Account from the Legal Hub, shipped terms.md's Account Mode & Data section, and handed Tomris a concrete written GDPR account-deletion API-contract spec -- closing out Phase 7 end-to-end.**

## Performance

- **Duration:** ~15 min
- **Tasks:** 2 completed
- **Files modified:** 6 modified, 1 created

## Accomplishments

- `ModeIndicator`'s Account Mode copy replaced: `'Synced across devices'` (a false claim -- no sync exists yet) -> the locked `'Account Mode: Data still stored locally (sync coming soon)'`
- `PlaceholderDashboardScreen`'s `ModeIndicator` call site now reads live auth state: `ModeIndicator(isLocalMode: ref.watch(authProvider) is! AuthAuthenticated)`, no longer a hardcoded `const ModeIndicator()`
- Verified `/auth` and `/check-email` routes are reachable (registered by Plan 07-06, confirmed present in `app_router.dart`, no re-registration needed) -- neither route requires an onboarding-gate allowlist entry, since Account Mode is Settings-initiated and post-onboarding-only
- Legal Hub's "Your Rights" section gained a "Delete Account (Account Mode)" `ListTile` cross-referencing Settings' Account section, per the "Your Rights never builds a new mutation screen" anti-pattern rule
- `docs/legal/terms.md`: frontmatter `version` bumped, new `## 9. Account Mode & Data` section covering optionality, zero data movement on login, the separate `account_mode_terms` consent event, and immediate/irreversible in-app deletion (GDPR Art. 17); existing Contact section renumbered `## 8.` -> `## 10.`
- `docs/backend-contracts/gdpr-account-deletion.md` created: concrete `DELETE {baseUrl}/me/account` contract spec for Tomris, every field marked `[ASSUMED -- not yet confirmed with Tomris]`, citing PRIV-05/GDPR Art. 17 and the June-2022 App Store account-deletion requirement, pointing at `AuthNotifier.deleteAccount()` as the single client-side isolation point for any future contract change
- Full `flutter test` suite green: 473 tests passed (9 pre-existing skips), zero regressions
- `dart run scripts/check_privacy_deps.dart` still passes (196 packages, 0 violations) with `flutter_appauth`/`flutter_secure_storage` installed (AUTH-10)

## Task Commits

Each task was committed atomically:

1. **Task 1: ModeIndicator real-state wiring + full regression** - `8eed349` (feat)
2. **Task 2: Legal Hub cross-reference + terms.md Account Mode section + GDPR contract spec** - `3228db0` (feat)

## Files Created/Modified

- `lib/features/dashboard/widgets/mode_indicator.dart` - Account Mode copy updated to the locked "sync coming soon" wording; doc comment updated to reflect real wiring
- `lib/features/dashboard/screens/placeholder_dashboard_screen.dart` - `ModeIndicator` call site reads `ref.watch(authProvider)` instead of a hardcoded `const` construction
- `lib/features/legal/screens/legal_hub_screen.dart` - Added "Delete Account (Account Mode)" `ListTile` to Your Rights, navigating to `/settings`
- `docs/legal/terms.md` - Version bump, new Section 9 "Account Mode & Data", Contact renumbered to Section 10
- `docs/backend-contracts/gdpr-account-deletion.md` - New: written `[ASSUMED]` GDPR account-deletion API contract for Tomris
- `test/features/dashboard/metric_card_test.dart` - `ModeIndicator` test updated to assert the new locked copy
- `test/domain/services/legal_document_loader_test.dart` - Real-file version assertions updated to match `terms.md`'s bumped frontmatter version

## Decisions Made

- `/auth`/`/check-email` router wiring: already done by Plan 07-06 (documented there as a Rule 2 deviation since `AccountSection`'s CTA had no route without it). This plan verified the routes are present and functioning rather than duplicating the work.
- terms.md's actual section numbering (`## 8. Contact`) differed from PLAN.md's prose assumption (`## 9. Contact`) -- followed the real file's numbering, inserting the new section as `## 9.` and renumbering Contact to `## 10.`.
- terms.md's version bump uses the host shell's local `date +%Y-%m-%d` output (2026-08-10) rather than the UTC-based date mentioned in surrounding conversation context, since the plan's own automated verify step (`grep -c "^version: $(date +%Y-%m-%d)$"`) runs in the same local shell and must match exactly.

## Deviations from Plan

None beyond the documented decisions above -- Task 1's router-wiring sub-step was already satisfied by Plan 07-06 (confirmed via `07-06-SUMMARY.md` and a direct read of `app_router.dart` before starting, per this plan's `<additional_context>` instruction), so no code change was needed there; everything else was implemented exactly as specified.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required. `docs/backend-contracts/gdpr-account-deletion.md` is a hand-off artifact for Tomris to review, not a configuration step for this repo.

## Next Phase Readiness

Phase 7 is fully wired end-to-end: every screen built across Plans 07-02 through 07-07 (Keycloak auth, AuthScreen, AccountSection, methodology banner) is reachable from the app's navigation graph, the Dashboard's Account Mode messaging is honest about the current zero-sync state, and Legal Hub/terms.md reflect the new Account Mode surface. `docs/backend-contracts/gdpr-account-deletion.md` gives Tomris a concrete starting point to build/confirm the deletion endpoint against. Phase 8 (User Data Sync Engine) can proceed once a resolved backend data-ownership agreement with Tomris is in place, per the `07-CONTEXT.md` roadmap-evolution note.

---
*Phase: 07-keycloak-auth-account-mode-sync*
*Completed: 2026-08-10*

## Self-Check: PASSED

All 7 created/modified files verified present on disk; both task commits (`8eed349`, `3228db0`) verified present in git history.

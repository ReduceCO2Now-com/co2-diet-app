---
phase: 07-keycloak-auth-account-mode-sync
plan: 06
subsystem: auth
tags: [riverpod, go_router, flutter, url_launcher, keycloak, settings, gdpr]

# Dependency graph
requires:
  - phase: 07-keycloak-auth-account-mode-sync
    provides: "AuthNotifier/authProvider (logout/deleteAccount/acknowledgeSessionExpired), realmDiscoveryReadyProvider, AuthState sealed class (Plan 07-03/07-04)"
provides:
  - "AccountSection widget: signed-out CTA, signed-in email/change-password/logout/delete-account rows, delete confirmation dialog, one-time session-expired notice"
  - "SettingsScreen wired to gate AccountSection behind realmDiscoveryReadyProvider, positioned after Backup & Restore/meal-reminders and before Legal & Privacy"
  - "/auth and /check-email routes registered in app_router.dart (AuthScreen/CheckEmailScreen now reachable)"
affects: [07-07, 07-08]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "ConsumerWidget-owned confirmation AlertDialog returning Future<bool> via showDialog<bool> + '?? false' (mirrors showEdSafetyNetDialog's non-null-bool contract, but deliberately without its typed-word gate)"
    - "Fake-Notifier widget-test override: extend the real generated Notifier class, override only the public surface under test (build/logout/deleteAccount/acknowledgeSessionExpired), never touch its private fields"

key-files:
  created:
    - lib/features/settings/widgets/account_section.dart
  modified:
    - lib/features/settings/screens/settings_screen.dart
    - lib/core/router/app_router.dart
    - test/features/settings/widgets/account_section_test.dart
    - test/features/settings/settings_screen_test.dart

key-decisions:
  - "AccountSection is a single ConsumerWidget returning either a ListTile (signed-out) or a Column of rows (signed-in) -- embedded as one ListView child in SettingsScreen, mirroring MealReminderSettingsSection's existing embedding pattern"
  - "Delete-account confirmation dialog is a private instance method on AccountSection (not a standalone exported function like showEdSafetyNetDialog) -- scoped tightly to this widget since no other screen needs it"
  - "/auth and /check-email routes added to app_router.dart as a Rule 2 deviation -- 07-05-SUMMARY.md explicitly named this plan as owner of that wiring; without it, AccountSection's primary CTA had no route to navigate to"
  - "settings_screen_test.dart's pre-existing suite mocks authHttpClientProvider to fail fast -- keeps that suite fully offline/deterministic now that SettingsScreen depends on realmDiscoveryReadyProvider (a real network check)"

requirements-completed: [AUTH-02, AUTH-03, PRIV-05]

# Metrics
duration: ~20min
completed: 2026-08-09
---

# Phase 7 Plan 06: Account Mode Settings Wiring Summary

**AccountSection widget wired into SettingsScreen behind realmDiscoveryReadyProvider, covering the full signed-out -> signed-in -> logged-out lifecycle plus a deliberately simple (no typed-word) GDPR account-deletion confirmation flow.**

## Performance

- **Duration:** ~20 min
- **Tasks:** 2 completed
- **Files modified:** 4 (1 created, 3 modified) + 1 pre-existing test fixed as a direct consequence

## Accomplishments

- `AccountSection`: signed-out "Sign in / Create account" CTA navigating to `/auth`; signed-in email/change-password/log-out/delete-account rows
- Log out is immediate (no confirmation dialog, per CONTEXT.md's "low-stakes, nothing to lose" decision)
- Delete-account confirmation dialog uses the exact locked copy, a destructive-styled confirm button, and deliberately has no typed-`DELETE`-word field (distinct from `DangerZoneSection`'s local-data-wipe pattern)
- Post-deletion success shows a confirmation SnackBar ("Your account has been deleted.") before the widget reverts to signed-out — proven by a dedicated test asserting the SnackBar is visible via a single `pump()` before the next `pumpAndSettle()`
- Failed deletion shows an inline error SnackBar and leaves the signed-in UI completely intact (no state mutation on `AccountDeletionException`)
- One-time "You've been signed out" notice on `sessionExpired: true`, immediately acknowledged so it never reappears on rebuild
- `SettingsScreen` converted to `ConsumerWidget`; `AccountSection` is entirely absent (no skeleton) until `realmDiscoveryReadyProvider` resolves `true`, positioned after Backup & Restore/meal-reminders and before Legal & Privacy per the locked placement decision
- `account_section_test.dart`: skip marker removed, all 9 real widget tests green, zero skips

## Task Commits

Each task was committed atomically:

1. **Task 1: AccountSection widget** - `af0a207` (feat)
2. **Task 2: SettingsScreen wiring + turn account_section_test.dart green** - `f5c1da5` (feat)

## Files Created/Modified

- `lib/features/settings/widgets/account_section.dart` - New `AccountSection` ConsumerWidget: signed-out/signed-in views, delete confirmation dialog, session-expired notice
- `lib/features/settings/screens/settings_screen.dart` - `StatelessWidget` -> `ConsumerWidget`; watches `realmDiscoveryReadyProvider`, conditionally inserts `Divider` + `AccountSection`
- `lib/core/router/app_router.dart` - Added `/auth` (`AuthScreen`) and `/check-email` (`CheckEmailScreen`) top-level routes
- `test/features/settings/widgets/account_section_test.dart` - Skip marker removed; 9 real widget tests covering every case in the plan's `<verify>` block, using a `_FakeAuthNotifier` override and mocked `url_launcher`
- `test/features/settings/settings_screen_test.dart` - Mocked `authHttpClientProvider` (fails fast) so this pre-existing suite stays offline-deterministic against the new `realmDiscoveryReadyProvider` watch

## Decisions Made

- `AccountSection` is a single `ConsumerWidget` returning either a `ListTile` (signed-out) or a `Column` of rows (signed-in), inserted as one `ListView` child in `SettingsScreen` — mirrors `MealReminderSettingsSection`'s existing embedding convention rather than introducing a new composition pattern.
- The delete-confirmation `AlertDialog` is a private instance method on `AccountSection`, not a standalone exported function (unlike `showEdSafetyNetDialog`) — no other screen needs this specific dialog, so it stays scoped.
- Test doubles for `AuthNotifier` extend the real class and override only the public methods under test (`build`, `logout`, `deleteAccount`, `acknowledgeSessionExpired`) — avoids re-mocking `FlutterAppAuth`/`FlutterSecureStorage`/`http.Client`/`IConsentRepository` for a widget test that only cares about `AccountSection`'s own UI logic, while still exercising the real `AccountDeletionException` type from `auth_provider.dart`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Added `/auth` and `/check-email` routes to `app_router.dart`**
- **Found during:** Task 2 (SettingsScreen wiring)
- **Issue:** `AccountSection`'s signed-out row calls `context.push('/auth')`, but `AuthScreen`/`CheckEmailScreen` (built in Plan 07-05) were never registered in `app_router.dart` — `07-05-SUMMARY.md` explicitly flagged this as Plan 07-06's responsibility ("Plan 07-06 owns adding the `/auth` and `/check-email` routes and Settings' 'Sign in / Create account' entry point"). Without this, tapping the CTA would throw a `GoException` at runtime.
- **Fix:** Added two top-level `GoRoute`s (`/auth` -> `AuthScreen()`, `/check-email` -> `CheckEmailScreen(email: ...)`) alongside the existing top-level routes, matching `AuthScreen`'s already-established constructor/query-param contract from `auth_screen_test.dart`.
- **Files modified:** `lib/core/router/app_router.dart`
- **Verification:** `account_section_test.dart`'s signed-out test taps the CTA and asserts navigation to a stub `/auth` route; full `flutter test` suite (468 tests) still green.
- **Committed in:** `f5c1da5` (Task 2 commit)

**2. [Rule 1 - Bug] Fixed `settings_screen_test.dart`'s new real-network dependency**
- **Found during:** Task 2 (SettingsScreen wiring)
- **Issue:** Converting `SettingsScreen` to a `ConsumerWidget` watching `realmDiscoveryReadyProvider` gave the pre-existing `settings_screen_test.dart` (Plan 05-18) an unmocked dependency on `authHttpClientProvider`, which would attempt a real HTTP GET against `KeycloakConfig.issuer` (`http://localhost:8081/...`) on every test run — non-deterministic and network-dependent.
- **Fix:** Overrode `authHttpClientProvider` with a mocked `http.Client` that throws immediately, so `realmDiscoveryReadyProvider` resolves `false` fast and deterministically (no `AccountSection` rendered, matching the test's original unaffected assertions).
- **Files modified:** `test/features/settings/settings_screen_test.dart`
- **Verification:** `flutter test test/features/settings/settings_screen_test.dart` — 4/4 tests pass, no real network call attempted.
- **Committed in:** `f5c1da5` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (1 missing critical functionality, 1 bug fix)
**Impact on plan:** Both fixes were required for the plan's stated deliverable (a fully working Account Mode entry point) to actually function and for the existing test suite to stay green/offline. No scope creep beyond what the plan's own linked context (07-05-SUMMARY.md) already called out as this plan's responsibility.

## Issues Encountered

None beyond the two deviations above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `AccountSection` and its full test coverage are in place; Plan 07-07/07-08 (sync engine / mode-choice work in Phase 8) can build on `authProvider`'s established `logout()`/`deleteAccount()` contract without further Settings-UI changes.
- `KeycloakConfig`'s realm/client values remain `[ASSUMED]` placeholders (07-RESEARCH.md) — the eventual real-realm handoff from Tomris is still the only remaining blocker for this flow working against a live backend; no code changes needed on this app's side when that happens (single-source-of-truth `KeycloakConfig` class).

---
*Phase: 07-keycloak-auth-account-mode-sync*
*Completed: 2026-08-09*

## Self-Check: PASSED

All created/modified files exist on disk and both task commits (`af0a207`, `f5c1da5`) are present in git history.

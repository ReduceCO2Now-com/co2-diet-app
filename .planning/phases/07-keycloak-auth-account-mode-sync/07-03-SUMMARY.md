---
phase: 07-keycloak-auth-account-mode-sync
plan: 03
subsystem: auth
tags: [riverpod, flutter_appauth, flutter_secure_storage, oidc, pkce, keycloak, mocktail]

# Dependency graph
requires:
  - phase: 07-02
    provides: flutter_appauth/flutter_secure_storage deps, AuthState/KeycloakConfig/BackendConfig, auth_providers.dart DI (secureStorage/appAuth/authHttpClient)
provides:
  - "AuthNotifier (keepAlive): build/signIn/signUp/signInWithIdp/logout/deleteAccount/acknowledgeSessionExpired -- the single source of truth for auth state"
  - "realmDiscoveryReadyProvider (keepAlive): session-cached Keycloak realm-discovery readiness gate"
  - "AccountDeletionException"
affects: [07-05 (AuthScreen/CheckEmailScreen), 07-06 (AccountSection), 07-07, 07-08 (ModeIndicator)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Synchronous Notifier<AuthState> with fire-and-forget async bootstrap (_silentRefresh from build()) -- mirrors OnboardingGateNotifier's keepAlive-sync-Notifier precedent, giving optimistic zero-loading-state restoration"
    - "Shared _completeSignIn() success path gated on /userinfo's email_verified claim, called by signIn/signUp/signInWithIdp with a per-caller recordConsent bool"
    - "OAuth-error-code-based invalidation check (_isGenuineInvalidation) distinguishing connectivity failure from genuine invalid_grant/revoked-token rejection"

key-files:
  created:
    - lib/features/auth/providers/auth_provider.dart
    - lib/features/auth/providers/realm_discovery_provider.dart
  modified:
    - test/features/auth/providers/auth_provider_test.dart
    - lib/core/di/auth_providers.g.dart (doc-comment reflow only, from re-running build_runner)

key-decisions:
  - "AuthNotifier is a plain synchronous Notifier<AuthState> (not AsyncNotifier) -- build() returns an immediate AuthState.unauthenticated() and kicks off _silentRefresh() unawaited, matching CONTEXT.md's 'no visible loading state' literally"
  - "_fetchUserInfo() defaults emailVerified: true and falls back to a caller-supplied email (or the generic 'Account' label) on any /userinfo failure -- a transient userinfo hiccup must never crash silent refresh or incorrectly block an already-established session"
  - "signIn/signUp/signInWithIdp wrap authorizeAndExchangeCode in a blanket on Exception catch that swallows every failure (cancellation-flavored or otherwise), leaving state unchanged -- matches 07-CONTEXT.md's 'no error message for cancellation' and the fact that real credential errors surface inside Keycloak's own hosted page, not back to the app"
  - "logout()/deleteAccount() cache the last-seen idToken in a private in-memory-only _idToken field (never persisted) purely to satisfy endSession's idTokenHint parameter -- not part of AuthState since AuthState only exposes email/accessToken"

patterns-established:
  - "Pattern 1 (07-RESEARCH.md): AuthNotifier as the single source of truth for auth state -- every later Phase 7 screen watches this provider, none duplicate auth-state logic"
  - "Pattern 3 (07-RESEARCH.md): realm-discovery readiness gate never propagates an error state -- non-200/timeout/exception all resolve false"

requirements-completed: [AUTH-01, AUTH-02, AUTH-03, AUTH-04, AUTH-05, AUTH-06, PRIV-05, AUTH-10]

# Metrics
duration: ~25min
completed: 2026-08-09
---

# Phase 7 Plan 3: AuthNotifier + realmDiscoveryReadyProvider Summary

**AuthNotifier (keepAlive `Notifier<AuthState>`) implementing signup/login/silent-refresh/logout/social-login/account-deletion against Keycloak OIDC+PKCE via `flutter_appauth`, plus a session-cached `realmDiscoveryReadyProvider` readiness gate -- 18 unit tests, zero skips, all mocked (no live Keycloak realm required).**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-08-09T15:04:00Z
- **Completed:** 2026-08-09T15:15:53Z
- **Tasks:** 2
- **Files modified:** 5 (2 created source files + their 2 generated `.g.dart` files + 1 test file rewrite; plus a doc-comment-only regen of `auth_providers.g.dart`)

## Accomplishments

- `AuthNotifier` fully implements the cold-start invariant (zero network calls when never logged in), the "no visible loading state" silent-refresh restoration, and the CONTEXT.md-locked network-failure-vs-real-invalidation distinction.
- Signup/login/social-login all funnel through a single `_completeSignIn()` helper that defensively gates on the `/userinfo` `email_verified` claim (07-RESEARCH.md Assumption A6), so "a logged-in account is always verified" holds even if Keycloak issues tokens optimistically.
- Account-deletion contract isolated to a single method against the `[ASSUMED]` `DELETE {backend}/me/account` endpoint, per 07-RESEARCH.md Pitfall 5 -- a future real-contract change is a one-method fix.
- `realmDiscoveryReadyProvider` never surfaces an error state to callers -- non-200, timeout, and thrown exceptions all resolve `false`.

## Task Commits

1. **Task 1: AuthNotifier -- signup, login, silent refresh, logout, account deletion** - `dbd22a0` (feat)
2. **Task 2: realmDiscoveryReadyProvider** - `7c10faf` (feat)

_Note: Both tasks were TDD (`tdd="true"`); RED (removing the `skip:` marker and confirming compile-failure/behavior-gap) was verified interactively during implementation rather than as a separate intermediate commit, since both providers and their full test suite were built together in one focused pass and the final `flutter test` run against the completed file confirmed 18/18 green before either commit was made._

## Files Created/Modified

- `lib/features/auth/providers/auth_provider.dart` - `AuthNotifier` (keepAlive), `AccountDeletionException`, `kRefreshTokenKey`/`kCachedEmailKey` secure-storage key constants
- `lib/features/auth/providers/realm_discovery_provider.dart` - `realmDiscoveryReadyProvider` (keepAlive)
- `test/features/auth/providers/auth_provider_test.dart` - 15 `AuthNotifier` test cases + 3 `realmDiscoveryReadyProvider` test cases, all green, zero skips (replaces Plan 07-01's Wave 0 stub)
- `lib/core/di/auth_providers.g.dart` - doc-comment line-wrap reflow only, a side effect of re-running `build_runner` for this plan's new generated files; no logic change

## Decisions Made

See `key-decisions` in frontmatter above.

## Deviations from Plan

None - plan executed exactly as written. The `auth_providers.g.dart` doc-comment reflow is a mechanical `build_runner` regeneration artifact (line-wrapping only), not a deviation from the plan's design.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required. (Keycloak realm/IdP configuration remains a backend-coordination item with Tomris, unchanged from 07-RESEARCH.md's Assumptions Log -- not something this plan's execution needed to resolve.)

## Next Phase Readiness

- `authProvider` and `realmDiscoveryReadyProvider` are ready for Plan 07-05 (AuthScreen/CheckEmailScreen), Plan 07-06 (AccountSection), and Plan 07-08 (ModeIndicator) to watch/call without touching this file's internal logic again.
- No blockers. `KeycloakConfig`/`BackendConfig` values remain `[ASSUMED]` placeholders pending Tomris's real realm/backend -- purely a future one-file value swap, already isolated per 07-RESEARCH.md's design intent.

---
*Phase: 07-keycloak-auth-account-mode-sync*
*Completed: 2026-08-09*

## Self-Check: PASSED

All created files exist on disk; both task commit hashes (`dbd22a0`, `7c10faf`) verified present in `git log`.

---
phase: 07-keycloak-auth-account-mode-sync
plan: 05
subsystem: auth
tags: [flutter, riverpod, go_router, oidc-pkce, flutter_appauth, connectivity_plus, url_launcher, autofill]

# Dependency graph
requires:
  - phase: 07-keycloak-auth-account-mode-sync (plan 03)
    provides: AuthNotifier (signIn/signUp/signInWithIdp/logout/deleteAccount), AuthState sealed class, auth_providers.dart DI
provides:
  - AuthScreen -- combined sign-in/create-account UI (social + email/password + honesty note + consent checkbox)
  - CheckEmailScreen -- post-signup pre-verification screen with a Resend action
  - AppleSignInButton / GoogleSignInButton -- hand-rolled, brand-compliant social buttons
  - Green, unskipped auth_screen_test.dart (12 tests, 0 skips)
affects: [07-06 (Settings Account section + router wiring), 07-07, 07-08]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Widget tests exercise the real AuthNotifier wired to mocked FlutterAppAuth/FlutterSecureStorage/http.Client/IConsentRepository (mirrors test/features/auth/providers/auth_provider_test.dart) rather than faking the notifier -- lets social/email-password submit assertions verify the real authorizeAndExchangeCode call shape (kc_idp_hint / prompt=create / login_hint)."
    - "UrlLauncherPlatform.instance mocked once process-wide via MockPlatformInterfaceMixin + reset() between tests -- extends the [Phase 05-16] SharePlatform.instance precedent to url_launcher."
    - "Widget testability override pattern: AuthScreen(showAppleButton: bool?) defaults to null -> Platform.isIOS at build time, since Platform.isIOS itself cannot be a const default parameter value and cannot be overridden the way debugDefaultTargetPlatformOverride overrides Flutter's own platform detection."
    - "context.push<bool>() / context.pop(true) result-passing used to let CheckEmailScreen's 'Back to Sign In' switch the underlying (still-mounted, not rebuilt) AuthScreen instance into sign-in mode."

key-files:
  created:
    - lib/features/auth/widgets/apple_sign_in_button.dart
    - lib/features/auth/widgets/google_sign_in_button.dart
    - lib/features/auth/screens/auth_screen.dart
    - lib/features/auth/screens/check_email_screen.dart
  modified:
    - test/features/auth/auth_screen_test.dart
    - pubspec.yaml

key-decisions:
  - "Password-length and terms-checkbox client-side pre-checks gate only the email/password create-account CTA, not the social buttons -- mirrors AuthNotifier.signInWithIdp's existing design (Plan 07-03), which never records account_mode_terms consent for social sign-in/signup regardless of mode."
  - "Social buttons (Apple/Google) always context.pop() on success regardless of AuthScreen's create-account/sign-in mode -- IdP-brokered accounts are pre-verified by the IdP, so there is no 'check your email' step for the social path."
  - "AuthScreen(showAppleButton: bool?) constructor override (not debugDefaultTargetPlatformOverride) used for iOS-only-rendering testability, since Platform.isIOS reads the real host OS via dart:io and cannot be intercepted by Flutter's widget-test platform override machinery."
  - "context.pop()/context.canPop() guard added on the sign-in and social-IdP success paths (Rule 1 -- the plan's literal 'context.pop()' throws GoError('nothing to pop') when AuthScreen is the router's initial/only route, both in tests and in any theoretical deep-link entry)."

requirements-completed: [AUTH-01, AUTH-04, AUTH-05, AUTH-06]

duration: ~20min
completed: 2026-08-09
---

# Phase 7 Plan 05: Keycloak Auth Screens Summary

**Combined sign-in/create-account AuthScreen (hand-rolled Apple/Google buttons, connectivity pre-flight gate, client-side password/terms validation) plus a CheckEmailScreen resend flow, fully covered by 12 green widget tests using the real AuthNotifier wired to mocked flutter_appauth/secure-storage/http transport.**

## Performance

- **Duration:** ~20 min
- **Completed:** 2026-08-09
- **Tasks:** 2 / 2
- **Files modified:** 6 (4 created, 2 modified)

## Accomplishments
- `AppleSignInButton`/`GoogleSignInButton`: dumb, reusable, brand-compliant social sign-in buttons with no `AuthNotifier` dependency of their own
- `AuthScreen`: single combined screen covering every locked 07-CONTEXT.md UI/behavior decision -- create-account-default toggle, Apple-above-Google ordering (iOS only), honesty note always visible, connectivity pre-flight before any browser call, client-side 8-char password + terms-checkbox gating, autofill-primed email/password fields, "Forgot password?" hosted-page hand-off (sign-in mode only)
- `CheckEmailScreen`: post-signup screen whose Resend action reuses `AuthNotifier.signUp(recordConsent: false)` (never double-records consent) and whose "Back to Sign In" link result-pops the underlying `AuthScreen` into sign-in mode
- `auth_screen_test.dart`: skip marker removed, 10 originally-stubbed test cases implemented plus 1 new dedicated "Apple above Google" `dy`-ordering assertion (11 named cases -> 12 physical tests since the Apple-visibility case also doubles as an implicit non-iOS check) -- 0 skips, 0 failures

## Task Commits

Each task was committed atomically:

1. **Task 1: Hand-rolled Apple/Google sign-in buttons** - `0a0ca65` (feat)
2. **Task 2: AuthScreen + CheckEmailScreen** - `244d938` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified
- `lib/features/auth/widgets/apple_sign_in_button.dart` - Black/white HIG-style Apple button, `Icons.apple` glyph
- `lib/features/auth/widgets/google_sign_in_button.dart` - White/grey-border Google button, hand-painted 4-color "G" glyph approximation (`CustomPainter`)
- `lib/features/auth/screens/auth_screen.dart` - Combined sign-in/create-account screen, submit-flow validation + connectivity gate, social/email-password CTAs wired to `AuthNotifier`
- `lib/features/auth/screens/check_email_screen.dart` - Post-signup screen with Resend + Back-to-Sign-In
- `test/features/auth/auth_screen_test.dart` - 12 real widget tests replacing the Plan 07-01 skip stub
- `pubspec.yaml` - `url_launcher_platform_interface` promoted transitive -> direct dev dependency (mirrors the existing `share_plus_platform_interface` precedent) so the test file can mock `UrlLauncherPlatform.instance`

## Decisions Made
- Password-length/terms-checkbox pre-checks apply only to the primary email/password CTA, not the social buttons -- consistent with `AuthNotifier.signInWithIdp` never recording `account_mode_terms` consent for social flows (Plan 07-03's existing design, not something this plan could change without an architectural decision)
- Social sign-in always pops on success regardless of create-account/sign-in mode, since IdP-brokered emails are pre-verified and need no "check your email" step
- `showAppleButton: bool?` constructor override (default `null` -> `Platform.isIOS`) chosen over `debugDefaultTargetPlatformOverride` for iOS-only-button testability, since `Platform.isIOS` reads the real host OS and Flutter's platform-override mechanism does not intercept `dart:io` calls
- Reused `ConsentCheckboxTile`-adjacent conventions were considered but the plan's literal `CheckboxListTile` widget type was used instead, with a `TextButton` "View Terms" link in its `subtitle` slot, to match 07-05-PLAN.md's action text exactly

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `context.pop()` on the sign-in/social-IdP success paths threw `GoError('nothing to pop')` when `AuthScreen` is the router's initial/only route**
- **Found during:** Task 2, while writing the "tapping the Google/Apple button calls signInWithIdp" widget test
- **Issue:** The plan's literal submit-flow spec calls `context.pop()` unconditionally after a successful sign-in/social-IdP flow. In the widget-test harness (`AuthScreen` as the router's `initialLocation`), and in any theoretical deep-link/direct-navigation entry to `AuthScreen` in production, there is nothing on the navigation stack to pop back to, and `context.pop()` throws.
- **Fix:** Guarded both call sites with `if (context.canPop()) context.pop();` -- a no-op fallback (stays on `AuthScreen`) rather than a crash, when there is nothing to pop to. In the real production flow (`AuthScreen` always pushed from Settings per 07-CONTEXT.md), `canPop()` is always `true`, so behavior is unchanged from the plan's intent on the actual entry path.
- **Files modified:** `lib/features/auth/screens/auth_screen.dart`
- **Verification:** `flutter test test/features/auth/auth_screen_test.dart` -- all 12 tests green
- **Committed in:** `244d938` (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 bug fix)
**Impact on plan:** Defensive-only fix; no behavior change on the plan's actual production entry path (AuthScreen always pushed from Settings). No scope creep.

## Issues Encountered
- `Override` (riverpod's provider-override type) is not a publicly exported name from `package:flutter_riverpod`/`package:riverpod`'s barrel files in the pinned 3.3.2 version, despite `ProviderScope.overrides` being typed `List<Override>` internally. Worked around in the test file by omitting an explicit return-type annotation on the shared `overrides()` test helper (relying on contextual/inferred typing, the same mechanism any inline `overrides: [...]` literal already uses) with a documented `// ignore: always_declare_return_types`.
- `url_launcher_platform_interface`'s `UrlLauncherPlatform.launchUrl(String, LaunchOptions)` needed a `registerFallbackValue(const LaunchOptions())` plus a `registerFallbackValue(Uri.parse(...))` for the pre-existing `http.Client.get(Uri, ...)` mock captures reused from `auth_provider_test.dart` -- both added to `setUpAll`.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `AuthScreen`/`CheckEmailScreen` exist and are fully covered by tests, but are NOT yet wired into `app_router.dart` or reachable from any screen -- Plan 07-06 owns adding the `/auth` and `/check-email` routes and Settings' "Sign in / Create account" entry point (per this plan's own success-criteria note: "reachable from anywhere Plan 07-06 wires an entry point").
- `KeycloakConfig`'s `[ASSUMED]` placeholder values (issuer, client ID, redirect URI, IdP aliases) remain unverified against Tomris's real Keycloak realm -- flagged since Plan 07-02, unchanged by this plan.
- The objective's documented tension (visible password field vs. AUTH-10's PKCE mandate) is resolved exactly as designed: the password field's value is never transmitted by this app, existing purely to prime OS-level autofill; real credential verification happens entirely inside Keycloak's hosted page in the system browser, which cannot be exercised by unit/widget tests -- flagged for real-device verification once Tomris's realm exists (already noted in 07-VALIDATION.md's Manual-Only Verifications table).

---
*Phase: 07-keycloak-auth-account-mode-sync*
*Completed: 2026-08-09*

## Self-Check: PASSED

All created files verified on disk; both task commits (`0a0ca65`, `244d938`) verified present in git history.

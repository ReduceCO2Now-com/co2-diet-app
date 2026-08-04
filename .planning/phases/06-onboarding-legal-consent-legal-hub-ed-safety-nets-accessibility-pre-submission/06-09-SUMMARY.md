---
phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
plan: 09
subsystem: ui
tags: [go_router, riverpod, flutter, accessibility, onboarding, legal-consent]

# Dependency graph
requires:
  - phase: 06-05
    provides: OnboardingGateNotifier/onboardingGateProvider + Splash/Welcome/Carousel screens
  - phase: 06-07
    provides: LegalConsentScreen + consentProvider
  - phase: 06-08
    provides: LegalHubScreen + ConsentHistoryScreen + LegalDocId route-slug convention
provides:
  - Full onboarding-gated route tree wired into app_router.dart (7 new routes)
  - Top-level GoRouter redirect enforcing "consent is never skippable" (ONBD-01/05)
  - App-wide ACC-02 text-scale clamp (1.0x-1.6x) via MaterialApp.router builder
  - Settings "Legal & Privacy" entry point into the Legal Hub (LEG-01)
  - Profile Setup's onboarding-only "Continue to Carousel" button
affects: [phase-07-account-mode, phase-06-10-manual-a11y-checkpoints]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Top-level GoRouter redirect callback as the single enforcement point for a gated flow (reads a Riverpod bool via ref.read, evaluated on every navigation including initialLocation)"
    - "MediaQuery.withClampedTextScaling in MaterialApp.router's builder for app-wide Dynamic Type clamping"

key-files:
  created: []
  modified:
    - lib/core/router/app_router.dart
    - lib/app.dart
    - lib/features/settings/screens/settings_screen.dart
    - lib/features/profile/screens/profile_screen.dart
    - test/features/onboarding/onboarding_gate_test.dart
    - test/widget_test.dart
    - test/features/profile/profile_screen_crash_test.dart
    - test/features/profile/profile_screen_full_app_crash_test.dart

key-decisions:
  - "Router redirect uses onboardingGateProvider (not onboardingGateNotifierProvider as PLAN.md's prose stated) -- matches the actual @riverpod-generated name, consistent with the established [Phase 06-05]/[Phase 06-07] convention that @riverpod strips the 'Notifier' suffix"
  - "/legal-hub/document's doc= query param is parsed via a private _legalDocIdFromSlug switch, not LegalDocId.values.firstWhereOrNull(name==...) as PLAN.md's prose specified -- LegalDocId.name is camelCase (healthDisclaimer) but LegalHubScreen/LegalConsentScreen already committed to the snake_case slug health_disclaimer, so the literal plan instruction would have 404'd that one deep link"

requirements-completed: [ONBD-01, ONBD-04, ONBD-05, LEG-01, ACC-02]

# Metrics
duration: ~25min
completed: 2026-08-04
---

# Phase 6 Plan 09: Onboarding gate router wiring + Settings/Profile integration Summary

**Wired all six Wave 1-3 onboarding/legal screens into `app_router.dart` behind a single top-level redirect gate, added the ACC-02 1.6x text-scale clamp app-wide, and gave Settings/Profile their new entry points -- turning six previously-unreachable screens into one navigable, consent-enforced flow.**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-08-04T10:56:00Z
- **Completed:** 2026-08-04T11:07:06Z
- **Tasks:** 3 completed
- **Files modified:** 8 (4 plan-scoped source/test files + 4 test files fixed under Rule 1)

## Accomplishments
- `app_router.dart` now has 7 new top-level routes (`/splash`, `/welcome`, `/legal-consent`, `/onboarding-carousel`, `/legal-hub`, `/legal-hub/document`, `/legal-hub/consent-history`) plus a top-level `redirect:` callback that is the single enforcement point for "consent is never skippable" (T-06-09-01), and `initialLocation` moved from `/profile` to `/splash`.
- `app.dart`'s `MaterialApp.router` now clamps system text scaling to `[1.0, 1.6]` everywhere via `MediaQuery.withClampedTextScaling` (ACC-02).
- `SettingsScreen` gained a "Legal & Privacy" entry point (`context.push('/legal-hub')`), satisfying LEG-01's within-2-taps requirement end-to-end.
- `ProfileScreen` gained a persistent onboarding-only "Continue" button (visible only while `!hasOnboarded`) that advances to the Carousel; it is completely absent once onboarding completes.
- `test/features/onboarding/onboarding_gate_test.dart`'s previously-skipped router-redirect group is now fully implemented and green (5 new widget tests), exercising the real `Co2DietApp`/`appRouterProvider` end-to-end rather than a duplicate test-only router.

## Task Commits

Each task was committed atomically:

1. **Task 1: Router wiring -- new routes + onboarding redirect gate** - `07381f1` (feat)
2. **Task 2: ACC-02 text-scale clamp, Settings entry point, Profile Continue button** - `0d3d84b` (feat, includes 3 Rule-1 test fixes)
3. **Task 3: Onboarding redirect-gate test** - `97cc69d` (test)

**Plan metadata:** (this commit, docs: complete plan)

## Files Created/Modified
- `lib/core/router/app_router.dart` - 7 new routes, top-level onboarding-gate `redirect:` callback, `initialLocation: '/splash'`, private `_legalDocIdFromSlug` slug parser
- `lib/app.dart` - `MediaQuery.withClampedTextScaling(1.0-1.6x)` in `MaterialApp.router`'s `builder` (ACC-02)
- `lib/features/settings/screens/settings_screen.dart` - "Legal & Privacy" `ListTile` → `/legal-hub`
- `lib/features/profile/screens/profile_screen.dart` - onboarding-only "Continue" `FilledButton` → `/onboarding-carousel`
- `test/features/onboarding/onboarding_gate_test.dart` - router-redirect group implemented (5 widget tests against the real app), skip removed
- `test/widget_test.dart` - `sharedPreferencesProvider` override added (Rule 1 fix)
- `test/features/profile/profile_screen_crash_test.dart` - `sharedPreferencesProvider` override added (Rule 1 fix)
- `test/features/profile/profile_screen_full_app_crash_test.dart` - `sharedPreferencesProvider` override + explicit Profile-tab navigation added (Rule 1 fix)

## Decisions Made
- Used `onboardingGateProvider` (the actual generated provider name) instead of PLAN.md's literal `onboardingGateNotifierProvider` -- verified against `onboarding_gate_provider.g.dart` and every existing caller (`OnboardingCarouselScreen`).
- `/legal-hub/document`'s slug parsing uses a dedicated `_legalDocIdFromSlug` function (snake_case `terms`/`privacy`/`health_disclaimer`/`impressum`) instead of `LegalDocId.name`, to stay consistent with `LegalHubScreen`'s and `LegalConsentScreen`'s already-committed slug convention.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `/legal-hub/document` route would have 404'd the Health Disclaimer deep link**
- **Found during:** Task 1
- **Issue:** PLAN.md's literal action text specified `LegalDocId.values.firstWhereOrNull((d) => d.name == ...)`, but `LegalDocId.name` is camelCase (`healthDisclaimer`) while `LegalHubScreen`'s `_LegalDocRouteSlug` extension and `LegalConsentScreen`'s `context.push` calls already committed to the snake_case slug `health_disclaimer` -- following the plan literally would have silently fallen back to Terms for every Health Disclaimer link.
- **Fix:** Added a private `_legalDocIdFromSlug(String? slug)` switch matching the snake_case convention, with the same safe-fallback-to-Terms behavior for malformed input.
- **Files modified:** `lib/core/router/app_router.dart`
- **Verification:** `flutter analyze` clean; manually traced every `doc=` caller (`LegalHubScreen`, `LegalConsentScreen` x4) against the new slug mapping.
- **Committed in:** `07381f1` (Task 1 commit)

**2. [Rule 1 - Bug] Wrong onboarding-gate provider name in PLAN.md's prose**
- **Found during:** Task 1
- **Issue:** PLAN.md's action text and `must_haves.key_links` both said `onboardingGateNotifierProvider`, but `@riverpod` strips the `Notifier` suffix from the class name -- the generated variable is `onboardingGateProvider` (confirmed in `onboarding_gate_provider.g.dart` and already used by `OnboardingCarouselScreen`).
- **Fix:** Used `onboardingGateProvider` throughout the redirect callback and Task 2's `ProfileScreen` watch.
- **Files modified:** `lib/core/router/app_router.dart`, `lib/features/profile/screens/profile_screen.dart`
- **Verification:** `flutter analyze` clean, no undefined-identifier errors.
- **Committed in:** `07381f1`, `0d3d84b`

**3. [Rule 1 - Bug] Three pre-existing tests broken by the router/ProfileScreen changes**
- **Found during:** Task 2 (post-implementation full test sweep)
- **Issue:** `ProfileScreen` now reads `onboardingGateProvider` (→ `sharedPreferencesProvider`, which throws `UnimplementedError` if not overridden) and `appRouterProvider`'s redirect does the same; additionally `initialLocation` moving from `/profile` to `/splash` meant `profile_screen_full_app_crash_test.dart`'s assumption of landing directly on `ProfileScreen` no longer held.
- **Fix:** Added `sharedPreferencesProvider.overrideWithValue(prefs)` (via `SharedPreferences.setMockInitialValues`) to all three tests; `profile_screen_full_app_crash_test.dart` additionally marks onboarding complete and taps the Profile bottom-nav destination to reach `ProfileScreen` through the real shell, matching how a real completed user would navigate there.
- **Files modified:** `test/widget_test.dart`, `test/features/profile/profile_screen_crash_test.dart`, `test/features/profile/profile_screen_full_app_crash_test.dart`
- **Verification:** Full `flutter test` run -- 417 tests passed, 9 skipped (pre-existing skip pattern), zero failures.
- **Committed in:** `0d3d84b` (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (2 bugs in plan prose, 1 regression from this plan's own changes)
**Impact on plan:** All three fixes were necessary for correctness (a silently-broken deep link and an undefined-identifier compile error would have shipped) and to keep the existing test suite green. No scope creep -- no files outside the plan's direct blast radius were touched.

## Issues Encountered
None beyond the deviations documented above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All six Wave 1-3 onboarding/legal screens (Splash, Welcome, Legal Consent, Onboarding Carousel, Legal Hub, Consent History) are now reachable end-to-end from a cold start, gated behind onboarding completion.
- LEG-01 (within-2-taps), ACC-02 (text-scale clamp), ONBD-01/04/05 (onboarding sequencing + gate) are all satisfied and traced complete in REQUIREMENTS.md.
- Plan 06-10 (Wave 5: manual a11y/tone checkpoints) is next -- it can now be executed against a fully navigable app rather than isolated screens.
- Pre-existing device-crash reproduction tests (`profile_screen_crash_test.dart`/`profile_screen_full_app_crash_test.dart`) remain unresolved investigations (real root cause still unknown, per their own doc comments) -- this plan only kept them compiling/passing for the reasons they were already passing before, it did not investigate the underlying crash further.

---
*Phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission*
*Completed: 2026-08-04*

## Self-Check: PASSED

All 9 claimed files exist on disk; all 3 task commit hashes (`07381f1`, `0d3d84b`, `97cc69d`) verified present in `git log`.

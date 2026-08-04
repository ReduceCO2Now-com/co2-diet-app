---
phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
plan: 05
subsystem: ui
tags: [riverpod, go_router, shared_preferences, onboarding, flutter]

requires:
  - phase: 06-02
    provides: legalDocumentLoaderProvider (not consumed here, but Legal Consent route this plan links to depends on it)

provides:
  - OnboardingGateNotifier + sharedPreferencesProvider (SharedPreferences-backed onboarding-complete flag)
  - SplashScreen (2s auto-advance, no buttons)
  - WelcomeScreen (single "Continue" CTA)
  - OnboardingCarouselScreen (3-slide swipeable carousel, Skip intro / Go to Dashboard)
  - main.dart preloads SharedPreferences.getInstance() before runApp

affects: [06-09 (router/redirect wiring), Phase 7 (Account Mode / Mode Choice screen)]

tech-stack:
  added: []
  patterns:
    - "Plain synchronous Notifier<bool> (not AsyncNotifier) for state backed by an already-loaded external instance overridden via ProviderScope"
    - "Hand-rolled 3-dot PageView indicator (no new package) for small fixed-count carousels"

key-files:
  created:
    - lib/features/onboarding/providers/onboarding_gate_provider.dart
    - lib/features/onboarding/providers/onboarding_gate_provider.g.dart
    - lib/features/onboarding/screens/splash_screen.dart
    - lib/features/onboarding/screens/welcome_screen.dart
    - lib/features/onboarding/screens/onboarding_carousel_screen.dart
  modified:
    - lib/main.dart
    - test/features/onboarding/onboarding_gate_test.dart

key-decisions:
  - "Generated provider variable is onboardingGateProvider, not onboardingGateNotifierProvider -- @riverpod strips the 'Notifier' suffix from the class name (consistent with STATE.md's existing [Phase 02-06] decision); the PLAN.md action text's literal `ref.read(onboardingGateNotifierProvider.notifier)` was adjusted accordingly in the actual carousel screen implementation"
  - "OnboardingCarouselScreen's 'Go to Dashboard' button is fully absent from the widget tree on slides 1-2 (conditional build, not Visibility/Offstage) so widget-tree-searching tests correctly find it only on slide 3"

requirements-completed: [ONBD-01, ONBD-02, ONBD-05]

duration: ~15min
completed: 2026-08-04
---

# Phase 06 Plan 05: Onboarding Screens (Splash/Welcome/Carousel) + Gate Provider Summary

**SharedPreferences-backed OnboardingGateNotifier plus SplashScreen, WelcomeScreen, and a 3-slide OnboardingCarouselScreen, all router-independent and ready for Plan 06-09 to wire in.**

## Performance

- **Duration:** ~15 min
- **Tasks:** 3
- **Files modified:** 6 (4 created, 2 modified, plus 1 generated .g.dart)

## Accomplishments
- `OnboardingGateNotifier` (sync `Notifier<bool>`) + `sharedPreferencesProvider`, overridden in `main.dart` before `runApp`
- `SplashScreen`: 2s auto-advance to `/welcome`, zero buttons, tagline reverted to original spec framing per `06-CONTEXT.md`
- `WelcomeScreen`: single "Continue" CTA to `/legal-consent` — no "Get Started"/"Use Without Account" pair (ONBD-02 explicitly moot this phase per locked decision)
- `OnboardingCarouselScreen`: 3 fixed slides (impact → CO₂ scoring methodology → what-you-can-do), swipeable `PageView`, hand-rolled dot indicator, "Skip intro" on every slide, "Go to Dashboard" on slide 3 only — both exit paths persist `hasCompletedOnboarding=true` before navigating
- Confirmed no Mode Choice screen exists anywhere in the codebase (grep across `lib/` and `app_router.dart` — zero matches)

## Task Commits

Each task was committed atomically:

1. **Task 1: OnboardingGateNotifier + main.dart wiring** - `d6d117d` (feat)
2. **Task 2: SplashScreen + WelcomeScreen** - `1ec8951` (feat)
3. **Task 3: OnboardingCarouselScreen** - `39de6d5` (feat)

_TDD task 1: RED/GREEN combined into a single commit since the provider-level test cases and the production provider were written and verified green together (the plan did not require a separate failing-test commit for this narrower unskip)._

## Files Created/Modified
- `lib/features/onboarding/providers/onboarding_gate_provider.dart` - `sharedPreferencesProvider` + `OnboardingGateNotifier` (build/completeOnboarding)
- `lib/features/onboarding/providers/onboarding_gate_provider.g.dart` - generated Riverpod codegen output
- `lib/features/onboarding/screens/splash_screen.dart` - auto-advancing splash, no buttons
- `lib/features/onboarding/screens/welcome_screen.dart` - single-CTA welcome screen
- `lib/features/onboarding/screens/onboarding_carousel_screen.dart` - 3-slide carousel with Skip intro / Go to Dashboard
- `lib/main.dart` - preloads `SharedPreferences.getInstance()`, overrides `sharedPreferencesProvider`
- `test/features/onboarding/onboarding_gate_test.dart` - provider-level slice unskipped and green; router-redirect group remains skipped for Plan 06-09

## Decisions Made
- Generated provider name is `onboardingGateProvider` (not `onboardingGateNotifierProvider` as literally written in PLAN.md's action text) — `@riverpod` strips the `Notifier` suffix, matching the existing `[Phase 02-06]` project convention. Used the correct generated name throughout.
- `OnboardingCarouselScreen`'s "Go to Dashboard" button is conditionally built (present in the tree only on the last slide) rather than hidden via `Visibility`, so widget tests searching the tree by text correctly find it only on slide 3.
- No app logo/icon asset exists in `assets/` yet — both Splash and Welcome fall back to `Icons.eco` + a `Text('CO₂ Diet', ...)` per the plan's documented fallback instruction.

## Deviations from Plan

None — plan executed exactly as written, aside from the provider-naming correction documented above (Rule 1: bug — the plan's literal code snippet referenced a provider name that Riverpod's codegen does not actually produce; corrected to the real generated symbol so the code compiles).

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All three screens (`SplashScreen`, `WelcomeScreen`, `OnboardingCarouselScreen`) and the `OnboardingGateNotifier`/`sharedPreferencesProvider` pair compile and pass their own tests independently of routing.
- Plan 06-09 can now wire `/splash`, `/welcome`, and the carousel route into `app_router.dart`, plus implement the router-redirect logic the still-skipped `OnboardingGate (router-redirect)` test group in `onboarding_gate_test.dart` expects.
- No Mode Choice screen exists anywhere in the codebase, confirmed via grep — ONBD-03's absence-based requirement for this phase is satisfied.

---
*Phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission*
*Completed: 2026-08-04*

## Self-Check: PASSED

All 7 created/modified files verified present on disk. All 3 task commits (`d6d117d`, `1ec8951`, `39de6d5`) verified present in git history.

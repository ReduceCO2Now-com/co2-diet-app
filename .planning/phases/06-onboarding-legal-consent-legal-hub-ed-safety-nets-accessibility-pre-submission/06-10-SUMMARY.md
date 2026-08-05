---
phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
plan: 10
subsystem: ui
tags: [flutter, dark-mode, accessibility, riverpod, go_router, material3, theming]

requires:
  - phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
    provides: All Wave 1-4 screens (Splash/Welcome/Legal Consent/Legal Hub/Consent History/Onboarding Carousel/router integration) built and wired
provides:
  - Real-device-verified accessibility pass across dark mode, color-blind simulation, tap-target sizing, VoiceOver/TalkBack, and tone/SAM audit
  - Working onboarding-completion flow (fixed 3 real bugs surfaced only by real-device testing, not catchable by widget tests alone)
  - App-wide theme-aware color retrofit (buildDarkTheme() now actually applies consistently, not just Dashboard)
affects: [any future phase touching Scaffold backgrounds, Text colors, or the onboarding-gate/router-redirect flow]

tech-stack:
  added: []
  patterns:
    - "Theme.of(context).colorScheme.X over hardcoded AppColors.X for all surface-family roles (surface/onSurface/onSurfaceVariant/surfaceContainer*/outline*/inverseSurface/inverseOnSurface/surfaceTint) -- verified byte-identical to AppColors in light mode via buildLightTheme()'s ColorScheme.light mapping, so this substitution is always safe going forward"
    - "keepAlive: true for any Riverpod provider read via a bare ref.read() from a callback with no active ref.watch (e.g. go_router's redirect callback, or a provider mutated from a screen that never watches it) -- autoDispose silently drops state changes mid-await"
    - "AppShell-style bottom nav / shell UI must be conditionally hidden during any pre-completion flow that shares a route with the post-completion shell, or users will discover and use the shortcut"

key-files:
  created: []
  modified:
    - lib/core/router/app_router.dart
    - lib/features/onboarding/providers/onboarding_gate_provider.dart
    - lib/features/legal/screens/legal_document_screen.dart
    - lib/features/dashboard/screens/placeholder_dashboard_screen.dart
    - lib/features/dashboard/widgets/co2_profile_prompt_card.dart
    - lib/features/dashboard/widgets/macro_split_bar.dart
    - lib/features/dashboard/widgets/nutrient_totals_row.dart
    - "+30 more files retrofitted to theme-aware colors (full list in commit e8b9613)"
    - test/features/onboarding/onboarding_gate_test.dart

key-decisions:
  - "Dark mode fixed via a genuine app-wide theme-aware color retrofit (36 files), not a light-only themeMode lock -- buildDarkTheme() was already correctly designed pre-Phase-6, the bug was ~90 call sites hardcoding AppColors.X instead of Theme.of(context).colorScheme.X"
  - "Onboarding-complete state loss root-caused to autoDispose provider disposal mid-await (UnmountedRefException), not a SharedPreferences persistence bug -- fixed with keepAlive: true"
  - "The 'loops back to onboarding' symptom was actually the bottom nav bar rendering during pre-onboarding Profile Setup, letting users bypass the Carousel (the only completeOnboarding() call site) via the Dashboard/Settings tabs -- fixed by hiding the nav bar until onboarding is genuinely complete"
  - "SAM test (NFR-03) cannot be self-certified by the developer -- it specifically measures a naive user's emotional reaction. Approved Phase 6 conditionally with this flagged as a pre-launch (not pre-Phase-6-closure) item, tracked in STATE.md alongside the existing legal-review and Impressum blockers"
  - "Reordering onboarding flow (Carousel before Profile Setup) explicitly deferred as a flagged todo, not changed ad hoc -- current locked order (06-CONTEXT.md:26) confirmed working exactly as spec'd"

patterns-established:
  - "Real-device manual verification checkpoints are not just a rubber stamp -- this single checkpoint surfaced 3 genuine, previously-undetected bugs (redirect allowlist gap, provider disposal, bottom-nav shortcut) plus a systemic dark-mode gap spanning 36 files, none of which any existing widget test caught"

requirements-completed: [ACC-01, ACC-03, ACC-04, ACC-05, NFR-01, NFR-02, NFR-04]

duration: ~5h (across 3 sessions/pauses)
completed: 2026-08-05
---

# Phase 6, Plan 10: Manual Accessibility & Pre-Submission Verification Summary

**Real-device dark mode, color-blind, tap-target, screen-reader, and tone verification across both platforms — surfaced and fixed 3 genuine navigation/state bugs plus an app-wide dark-theme retrofit that a checkpoint-as-rubber-stamp approach would have missed entirely.**

## Performance

- **Duration:** ~5h across 3 pause/resume cycles
- **Tasks:** 3 checkpoints, all approved (Checkpoint 3 conditional — see below)
- **Files modified:** 40+ across 7 commits (this plan) + earlier phase commits

## Accomplishments

- **Checkpoint 1 (ACC-01/04/05 — dark mode / color-blind / tap targets):** Approved on both Android and iOS, after fixing:
  1. A real navigation bug: the pre-onboarding redirect allowlist omitted `/legal-hub`, bouncing every "View Terms/Privacy/Disclaimer" tap back to `/splash`.
  2. An iOS local-toolchain code-signing issue (stale `CODE_SIGN_IDENTITY[sdk=iphoneos*] = "iPhone Developer"`, a pre-Xcode-8 wildcard matching nothing in modern keychains) — unrelated to app code, blocking real-device testing entirely until fixed.
  3. A genuine onboarding-completion bug: `OnboardingGateNotifier`/`sharedPreferencesProvider` were plain `@riverpod` (autoDispose); `OnboardingCarouselScreen` never watches `onboardingGateProvider`, so `completeOnboarding()` hit `UnmountedRefException` mid-`await`, silently dropping the completion signal. Fixed with `keepAlive: true`.
  4. The actual root cause of the reported "loops back to onboarding" symptom: `AppShell`'s bottom nav bar rendered unconditionally, even during pre-onboarding Profile Setup — letting users tap "Dashboard" directly and bypass the Carousel (the only `completeOnboarding()` call site) entirely. Fixed by hiding the nav bar until `onboardingGateProvider` is true.
  5. Illegible dark-mode text on Dashboard (empty states, CO2 profile prompt, nutrient dash values) — root-caused to a mix of hardcoded-light `AppColors` and theme-derived-default colors landing inconsistently against each other.
  6. Discovering (5) was the tip of a much larger iceberg: retrofitted 36 files app-wide to use `Theme.of(context).colorScheme.X` instead of hardcoded `AppColors.X` for all surface-family color roles, making the already-correctly-designed `buildDarkTheme()` actually apply consistently everywhere (Profile, Settings, Legal Hub, bottom nav, Dashboard, Legal Document screen).
- **Checkpoint 2 (ACC-03 — VoiceOver/TalkBack):** Approved on both platforms — every interactive element announced clearly, focus order matched visual order, across the full onboarding flow, Legal Hub, Legal Document screens, Consent History, and both ED safety-net modals.
- **Checkpoint 3 (NFR-01/02/03/04 — tone audit + SAM test):** Tone audit and gamification check both passed by inspection. SAM test (NFR-03) explicitly **not** self-certified — flagged as a genuine pre-launch item requiring an independent tester, tracked in STATE.md.

## Task Commits

1. `d198fad` — fix: pre-onboarding redirect allowlist missing /legal-hub
2. `8b68714` — fix: onboarding-complete state lost mid-flight + illegible legal document text
3. `0eb1896` — fix: hide bottom nav during onboarding to remove the Carousel-skip shortcut
4. `f5e6e83` — fix: illegible Dashboard text in dark mode
5. `e8b9613` — fix: retrofit theme-aware colors app-wide for real dark mode support
6. `5742c55` — docs: capture todo - reconsider onboarding flow order

**Plan metadata:** this commit (docs: complete 06-10)

## Files Created/Modified

See `key-files` frontmatter above and the 6 commits' full diffs — 40+ files total, dominated by the app-wide theme retrofit (commit `e8b9613`, 36 files).

## Decisions Made

See `key-decisions` frontmatter above.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 — Bug] Pre-onboarding redirect allowlist missing `/legal-hub`**
- **Found during:** Checkpoint 1, real-device testing
- **Fix:** Added `/legal-hub` to `allowedPreOnboarding` in `app_router.dart`
- **Verification:** New regression test + full suite green; confirmed on-device both platforms
- **Committed in:** `d198fad`

**2. [Rule 1 — Bug] `OnboardingGateNotifier`/`sharedPreferencesProvider` autoDispose crash**
- **Found during:** Checkpoint 1, real-device testing
- **Fix:** `keepAlive: true` on both providers
- **Verification:** New regression test reproducing the exact mid-session `completeOnboarding()` call pattern; full suite green
- **Committed in:** `8b68714`

**3. [Rule 1 — Bug] Bottom nav bar visible during pre-onboarding Profile Setup**
- **Found during:** Live `adb logcat` instrumentation after (2) didn't fully resolve the reported symptom
- **Fix:** `AppShell`'s `bottomNavigationBar` conditional on `onboardingGateProvider`
- **Verification:** 2 new regression tests (bar hidden pre-onboarding / visible post); confirmed on-device both platforms
- **Committed in:** `0eb1896`

**4. [Rule 1 — Bug] Illegible dark-mode text (Dashboard, then app-wide)**
- **Found during:** Checkpoint 1, real-device dark-mode pass
- **Fix:** Dashboard-scoped fix first (`f5e6e83`), then discovered the pattern was systemic and retrofitted 36 files app-wide (`e8b9613`)
- **Verification:** `flutter analyze` clean, `flutter test` 421/421 passing after each commit; confirmed on-device both platforms after final retrofit
- **Committed in:** `f5e6e83`, `e8b9613`

**5. [Rule 3 — Blocking] iOS code-signing toolchain issue**
- **Found during:** Attempting to launch on the iPhone for Checkpoint 1
- **Fix:** `CODE_SIGN_IDENTITY[sdk=iphoneos*]` changed from stale `"iPhone Developer"` to `"Apple Development"` in `ios/Runner.xcodeproj/project.pbxproj`
- **Verification:** Successful `flutter run`/Xcode launch on real device
- **Committed in:** `d198fad` (bundled with the first fix commit)

---

**Total deviations:** 5 auto-fixed (4 real bugs, 1 blocking toolchain issue)
**Impact on plan:** All fixes were necessary corrections surfaced by the checkpoint's own real-device verification process — exactly what manual verification exists to catch. No scope creep beyond what testing revealed.

## Issues Encountered

- Extensive iOS local-toolchain debugging (signing identity, provisioning profile directory location) before real-device testing could even begin — resolved, documented in commit `d198fad`'s message and STATE.md decisions.
- Initial hypothesis (autoDispose provider crash) was a real bug and necessary fix, but did not fully explain the reported symptom on its own — required live `adb logcat` instrumentation to find the actual remaining cause (bottom nav visibility). Both fixes were needed.

## User Setup Required

None — no external service configuration required. (Two pre-launch items — SAM test with an independent tester, and the pre-existing external legal review / Impressum identity data — are tracked in STATE.md's "Pre-Launch Blockers" section, not app configuration.)

## Next Phase Readiness

Phase 6 is functionally complete and verified on real hardware, both platforms, across all 3 manual checkpoints. Local Mode remains shippable per the project's delivery principle. Three items explicitly deferred to pre-launch (not blocking): external legal review, Impressum identity data, and an independent-tester SAM test. One UX preference (onboarding flow order) logged as a todo for future reconsideration, deliberately not acted on this phase.

---
*Phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission*
*Completed: 2026-08-05*

---
status: resolved
resolved: not-reproducible-on-current-main
deferred: false
trigger: "profile-daily-targets-crash: Flutter app (co2diet, real device) crashes with a framework assertion every time the user taps a card in the Daily Targets section of the Profile screen (lib/features/profile/screens/profile_screen.dart)."
created: 2026-07-29T00:00:00Z
updated: 2026-09-07T23:35:00Z
---

## Current Focus

status_note: RESOLVED 2026-09-07 — no longer reproducible. Re-tested on the
original device (Samsung SM-T733, Android 14) against current main. All four
Daily Targets cards open the override dialog normally. No further action; this
session is closed.

outcome: The bug was real and is now gone, but it was never directly fixed —
no change was ever made against a confirmed root cause. It stopped reproducing
as a side effect of correctness work done for other reasons, most plausibly
06-10's `keepAlive: true` conversion of `sharedPreferencesProvider` /
`OnboardingGateNotifier` and the wider audit of autoDispose providers read via
bare `ref.read`, combined with c6697a3's gating of the locale-detection
auto-save loop. The `_dependents.isEmpty` assertion class is consistent with an
element being torn down out of band, which an autoDispose provider disposing
mid-`await` can produce — so the fix and the symptom are plausibly related, but
this is an inference from disappearance, not a demonstrated causal chain.

caveat: Because the root cause was never identified, this cannot be called
"fixed" with confidence — only "not reproducible under the conditions that
previously reproduced it 100% of the time." If it returns, reopen this file
rather than starting fresh: the three eliminated hypotheses below still hold.


## Symptoms

expected: Tapping a Daily Targets card (Calories / Protein / Carbs / Fat) opens the "Set custom target" override AlertDialog without crashing.
actual: The app crashes. Captured error so far is only the one-line Flutter framework assertion message: `assert(_dependents.isEmpty)` failing inside `InheritedElement.debugDeactivated()` (framework.dart, around line 6268 in this project's Flutter 3.44.6 SDK at /opt/homebrew/share/flutter/packages/flutter/lib/src/widgets/framework.dart). That assertion fires when an `InheritedElement` is deactivated while it still has dependent Elements registered — i.e. something in the tree is being torn down/reparented out of the normal top-down deactivation order while a descendant still depends on it. No fuller stack trace has been captured yet.
errors: "`assert(_dependents.isEmpty)` framework assertion (see above). Full frame list above/below this line has NOT yet been captured."
reproduction: On a real device, open Profile screen, tap ANY card in the Daily Targets grid (Calories/Protein/Carbs/Fat). Crashes on EVERY tap, unconditionally, regardless of whether height/weight/target data has been entered yet (both empty-state and filled-value cards crash identically — this rules out any theory specific to the empty-state `MissingTargetDash`/`Tooltip` path).
started: Found during real-device manual UAT pass for Phase 5.

## Eliminated

- hypothesis: Theory A — infinite locale-detection auto-save loop in `_ProfileScreenState._buildBody` was tearing down/rebuilding ProfileScreen's Element at high frequency underneath `showDialog`'s context.
  evidence: Fixed for real at commit c6697a3 (gated the postFrameCallback block behind `profile == null`). User re-tested on-device after the fix and got the IDENTICAL crash. Additionally, the new information that the crash also occurs when `profile != null` (filled-value cards) means that postFrameCallback block doesn't even execute in those repro cases, since it's gated by `if (profile == null)` — doubly confirms this is not the cause.
  timestamp: prior session (see .continue-here.md)

- hypothesis: Theory B — `MissingTargetDash`'s `Tooltip` wrapper (only rendered on the empty/null-value path) conflicts with `showDialog`'s route insertion.
  evidence: Widget test `test/features/profile/profile_screen_crash_test.dart` reproduces the real interaction (tall viewport, real ProfileScreen, confirmed tap lands on an empty-value card) and does NOT throw. Falsified. Additionally, new info that filled-value cards (which never render `MissingTargetDash`/`Tooltip` at all) crash identically means Theory B is doubly ruled out.
  timestamp: prior session (see .continue-here.md)

## Evidence

- timestamp: 2026-07-29T00:00:00Z
  checked: lib/core/router/app_router.dart, lib/app.dart, lib/main.dart
  found: ProfileScreen is nested inside `StatefulShellRoute.indexedStack` (go_router 17.x), wrapped by `AppShell` (Scaffold + NavigationBar + IndexedStack branch content). `Co2DietApp` uses `MaterialApp.router(routerConfig: ref.watch(appRouterProvider))`. `appRouterProvider` is `@Riverpod(keepAlive: true)` with no upstream `ref.watch` dependencies, so the GoRouter instance is built once and stable — rules out the router itself being recreated as a trigger.
  implication: showDialog's default `useRootNavigator: true` means the dialog route in `_showOverrideDialog` is inserted on a DIFFERENT (root) Navigator than the one hosting ProfileScreen's own Element (the branch Navigator inside IndexedStack). This structural split does not exist in the prior widget test's bare `MaterialApp(home: ProfileScreen())` harness — a plausible explanation for why that test failed to reproduce.

- timestamp: 2026-07-29T00:00:00Z
  checked: test/features/profile/profile_screen_crash_test.dart (existing, non-reproducing test)
  found: Confirmed it wraps `ProfileScreen` directly in `MaterialApp(home: ProfileScreen())` — no go_router, no StatefulShellRoute, no IndexedStack, no NavigationBar, no root/branch Navigator split.
  implication: This is a real structural gap vs. production. Built a new test (`profile_screen_full_app_crash_test.dart`) pumping the REAL `Co2DietApp` widget (same pattern as existing `test/widget_test.dart`, which already proves `Co2DietApp` can be pumped in a widget test with an in-memory drift DB override) to close this gap.

- timestamp: 2026-07-29T00:00:00Z
  checked: lib/features/profile/providers/profile_notifier.dart, lib/features/profile/screens/profile_screen.dart
  found: `profileProvider` (AsyncNotifier) is the provider actually watched by ProfileScreen (confirmed via generated `profile_notifier.g.dart`: `name: r'profileProvider'`). A separate `profileStreamProvider` exists but is dead code — not watched anywhere in lib/.
  implication: Rules out a background Stream re-emission from `profileStreamProvider` as a trigger (it isn't wired to any UI). The AsyncNotifier's state only changes via explicit `saveProfile`/`updateField` calls, which don't happen before `showDialog` is invoked in `_showOverrideDialog` (dialog opens on a pure read, no write before it).

- timestamp: 2026-07-29T00:01:00Z
  checked: Ran `flutter test test/features/profile/profile_screen_full_app_crash_test.dart` (full Co2DietApp widget, real go_router StatefulShellRoute.indexedStack navigation shell, in-memory drift DB).
  found: Test PASSED — tapping the Calories Daily Target card inside the full app harness did NOT throw the `_dependents.isEmpty` assertion. `tester.takeException()` was null.
  implication: The root-navigator-vs-branch-navigator structural hypothesis is ELIMINATED as the sole/direct cause — the full production widget tree (go_router shell included) still doesn't reproduce the crash via `flutter_test`'s synthetic `tester.tap()`. This is now the THIRD reproduction attempt (Theory B's test, and now this one) that fails to trigger the assertion despite covering different structural theories. Strongly suggests the trigger is a REAL-DEVICE-ONLY condition that `flutter_test`'s fake/synthetic environment cannot simulate — most likely candidates: real IME/keyboard-inset animation triggering a `MediaQuery.viewInsets` change concurrently with `showDialog`'s route insertion (autofocus:true on the dialog's TextFormField requests the real keyboard, which `flutter_test`'s TestTextInput does not physically animate/resize the view for), or a real-engine Overlay/gesture-arena timing difference not reproducible under `pumpAndSettle`'s fake clock.

- timestamp: 2026-07-29T00:02:00Z
  checked: Flutter SDK framework.dart source (/opt/homebrew/share/flutter/packages/flutter/lib/src/widgets/framework.dart), specifically `_InactiveElements._deactivateRecursively` (~line 2133), `Element._ensureDeactivated`/`deactivate` (~line 4797-4822), and `InheritedElement.removeDependent`/`_dependents`/`debugDeactivated` (~line 6256-6387). Also grepped the whole `lib/` tree for `GlobalKey` usage.
  found: Deactivation is depth-first top-down: for a torn-down subtree, `element.deactivate()` runs, then children are recursively deactivated, and only after ALL descendants finish does `element.debugDeactivated()` run and assert `_dependents.isEmpty`. A dependent element normally removes itself from its InheritedElement's `_dependents` map via `_ensureDeactivated()` at the moment IT is deactivated. This means the assertion can only fail if some Element that depends on the InheritedElement being torn down is NOT part of the same deactivation pass (i.e. was not deactivated as a descendant in this subtree) — the classic real-world trigger for this is `GlobalKey`-based element reparenting (an element with a GlobalKey moves to a new tree location within the same frame via `Element.activate()`, which per the source comment does NOT eagerly clear the old `_dependencies` list). Grepping `lib/` found only ONE `GlobalKey` in the entire codebase: `rootNavigatorKey = GlobalKey<NavigatorState>()` in `app_router.dart`, used as go_router's root `navigatorKey` — a completely standard, single-instance usage, not itself under suspicion. No GlobalKey usage found anywhere in `ProfileScreen`, `ProfileForm`, `TargetDisplayCard`, or `MissingTargetDash`.
  implication: The framework mechanics point strongly at GlobalKey-driven reparenting (or an equivalent element-identity-preserving move) as the general cause of this exact assertion class, but no first-party GlobalKey usage in this codebase's Profile feature explains it. If pursued further, the next place to look would be go_router 17.3.0's own internals (`StatefulShellRoute.indexedStack`'s branch-Navigator GlobalKeys, which co2diet doesn't control directly) rather than app-level code — this is a credible but UNTESTED lead, not a confirmed root cause.

- timestamp: 2026-09-07T23:32:00Z
  checked: Live device run on the original hardware (Samsung SM-T733 / gts7fewifi, Android 14, API 34) against current main (05548f1). `flutter run -d R52RB0FSSAX`, debug build, driven over adb: Profile tab -> scroll to Daily Targets -> tap each of the four cards in turn, dismissing the dialog between taps.
  found: NO CRASH on any of the four cards (Calories, Protein, Carbs, Fat). The app process (pid 16832) survived every tap unchanged. Zero occurrences of `_dependents`, `debugDeactivated`, or any framework assertion of that class in either the Flutter console output or logcat. The "Set custom target" dialog rendered correctly with its value pre-filled, the numeric keyboard opened, and Reset/Save were both present.
  implication: RESOLVED — not reproducible. Notably, the run also exercised the leading untested theory directly: logcat shows the real IME animating its insets from `mFrame=[0,1498][2560,1600]` to `[0,842][2560,1600]` concurrently with the dialog's route insertion, with `FlutterJNI: Sending viewport metrics to the engine` firing repeatedly through the transition. That is exactly the real-keyboard-inset condition `flutter_test` could never simulate, and it did not trigger the assertion. The keyboard-inset theory is therefore also eliminated, on real hardware.

- timestamp: 2026-09-07T23:32:00Z
  checked: Same run, incidental observations on the Profile screen.
  found: Two unrelated live defects, both filed separately as todos: (1) `A RenderFlex overflowed by 5.6 pixels on the right` at `target_display_card.dart:66`, thrown during layout on Profile render — before any tap, so unrelated to the dialog; (2) an Imperial-units display/conversion fault showing "Height: 156 ft", which drives `[TargetCalculator] WARN: rawKcal=40855.68718 clamped to [500.0, 10000.0]` at startup.
  implication: The overflow is very likely a downstream symptom of the units fault — the clamped 10000 kcal target is a five-digit string in a `Row` with `MainAxisSize.min` and no `Flexible`. Worth fixing the units fault first and re-checking whether the overflow persists.

## Resolution

root_cause: NEVER IDENTIFIED. Four hypotheses were eliminated with evidence — (A) locale-detection auto-save loop, (B) Tooltip/showDialog conflict, (C) root-navigator vs. branch-navigator dialog insertion, and (D) real IME keyboard-inset animation racing the dialog's route insertion, which was the last standing theory and was eliminated on real hardware on 2026-09-07 by observing the inset animation occur without the crash.

fix: NONE APPLIED DIRECTLY. The crash stopped reproducing as a side effect of unrelated correctness work — most plausibly 06-10's autoDispose-to-keepAlive provider audit plus c6697a3's gating of the locale-detection loop. This is an inference from the symptom disappearing, not a demonstrated causal chain, and the file records it as such.

verification: Re-tested 2026-09-07 on the original device (Samsung SM-T733, Android 14) against main at 05548f1. All four Daily Targets cards open the override dialog normally; process survives; no assertion of any kind in console or logcat. Previously this reproduced on 100% of taps.

status: CLOSED as not-reproducible. Reopen this file rather than starting a new session if it returns — the four eliminated hypotheses remain eliminated and are worth not re-testing.

files_changed: []
files_added_this_session:
  - test/features/profile/profile_screen_full_app_crash_test.dart (reproduction attempt from the July session; never reproduced the crash. Retained as a regression harness — it now passes for the right reason rather than the wrong one, but note it passed even while the bug was live, so it is not evidence of the fix.)

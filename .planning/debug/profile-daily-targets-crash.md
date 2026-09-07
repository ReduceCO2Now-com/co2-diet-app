---
status: resolved
resolved: root-cause-found-and-fixed
deferred: false
trigger: "profile-daily-targets-crash: Flutter app (co2diet, real device) crashes with a framework assertion every time the user taps a card in the Daily Targets section of the Profile screen (lib/features/profile/screens/profile_screen.dart)."
created: 2026-07-29T00:00:00Z
updated: 2026-09-08T00:05:00Z
---

## Current Focus

status_note: RESOLVED 2026-09-08 — ROOT CAUSE FOUND AND FIXED. An earlier
entry today closed this as "not reproducible"; that was WRONG and is corrected
below.

root_cause: `ProfileScreen._showOverrideDialog` created the dialog's
`TextEditingController` itself and disposed it on the line immediately after
`await showDialog(...)`. That await completes when the route is **popped**, not
when it is **gone** — so the controller was destroyed while the dialog's exit
transition was still running and its `TextFormField` was still rebuilding. The
device log, captured 2026-09-07:

    A TextEditingController was used after being disposed.
      The relevant error-causing widget was: TextFormField
      profile_screen.dart:184:18
    #4  _AnimatedState.didUpdateWidget (transitions.dart:119:25)
    ...
    Another exception: '_dependents.isEmpty': is not true
    Another exception: Tried to build dirty widget in the wrong build scope.

The `_dependents.isEmpty` assertion every prior session chased is SECOND-ORDER
cascade, not the fault. That is why reading framework source around
`InheritedElement.debugDeactivated` and hunting GlobalKey reparenting led
nowhere — the primary exception was never captured, only the noisier one that
followed it.

why_it_took_four_sessions: The reproduction step recorded in this file was
"tap ANY Daily Targets card", which is where the crash APPEARS to originate.
But opening the dialog is harmless. The trigger is **completing** it — tapping
Save or Reset, which pops the route and lets the caller's `dispose()` run while
the exit animation is still going. Every prior reproduction attempt, and the
first verification pass on 2026-09-07, only opened the dialog and dismissed it
with the back button. The bug was reachable in a plain `flutter_test` widget
test the whole time; it was never real-device-only.

correction_note: On 2026-09-07 this file was briefly marked "not reproducible"
after a device pass that tapped all four cards and saw no crash. That pass
never tapped Save. A conclusion of "cannot reproduce" is only as good as the
actions the reproduction attempt actually performed — that is the durable
lesson here, and it is why the reproduction steps below now name the trigger
explicitly.


## Symptoms

expected: Tapping a Daily Targets card (Calories / Protein / Carbs / Fat) opens the "Set custom target" override AlertDialog without crashing.
actual: The app crashes. Captured error so far is only the one-line Flutter framework assertion message: `assert(_dependents.isEmpty)` failing inside `InheritedElement.debugDeactivated()` (framework.dart, around line 6268 in this project's Flutter 3.44.6 SDK at /opt/homebrew/share/flutter/packages/flutter/lib/src/widgets/framework.dart). That assertion fires when an `InheritedElement` is deactivated while it still has dependent Elements registered — i.e. something in the tree is being torn down/reparented out of the normal top-down deactivation order while a descendant still depends on it. No fuller stack trace has been captured yet.
errors: "`assert(_dependents.isEmpty)` framework assertion (see above). Full frame list above/below this line has NOT yet been captured."
reproduction: Open Profile, tap any Daily Targets card, **then tap Save or Reset to calculated** and let the dialog animate out. Opening and dismissing the dialog does NOT crash — completing it does. Reproducible in `flutter_test`, not device-only (see 2026-09-08 evidence). Crashes on EVERY tap, unconditionally, regardless of whether height/weight/target data has been entered yet (both empty-state and filled-value cards crash identically — this rules out any theory specific to the empty-state `MissingTargetDash`/`Tooltip` path).
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

- timestamp: 2026-09-08T00:01:00Z
  checked: Fix verified on the original device (Samsung SM-T733, Android 14). Profile -> Daily Targets -> Calories -> entered 99999 -> tapped **Save** — the exact action that crashed the app 20 minutes earlier on the previous build.
  found: No crash. App process survived (pid unchanged). Zero occurrences of `EXCEPTION CAUGHT`, `Another exception`, `_dependents`, or `used after being disposed` in the console from the moment the test began.
  implication: FIXED. The dialog now owns its `TextEditingController` in a `StatefulWidget` (`lib/features/profile/widgets/target_override_dialog.dart`), so disposal happens in `State.dispose()` — after the route's exit transition, not when the route is merely popped.

- timestamp: 2026-09-08T00:02:00Z
  checked: Whether the pre-fix pattern is catchable in `flutter_test`. Wrote a temporary test replicating the old caller-owned-controller code exactly, tapped Save, and pumped 12 frames of 20ms through the exit transition.
  found: It FAILS with `A TextEditingController was used after being disposed` in under a second, with no device involved.
  implication: The "real-device-only" conclusion recorded in this file across three sessions was wrong. The bug was always reproducible in a widget test — every attempt simply opened the dialog and dismissed it instead of completing it. The distinguishing action was Save/Reset, not the hardware.

- timestamp: 2026-09-08T00:03:00Z
  checked: Whether the override actually persists after the crash was removed (`SELECT kcal_target, kcal_is_overridden FROM user_profile_table` after saving 99999).
  found: `kcal_target` empty, `kcal_is_overridden` 0. `DriftProfileRepository.saveProfile` builds its companion without any of the target columns, and `_rowToProfile` does not read them back, though the columns exist in the schema.
  implication: A SECOND, pre-existing bug the crash was masking — manual target overrides (PROF-05) have never persisted. Out of scope for this session; filed as its own todo.

## Resolution

root_cause: FOUND 2026-09-08. `ProfileScreen._showOverrideDialog` created the dialog's `TextEditingController` and disposed it on the line after `await showDialog(...)`. That await completes when the route is popped, not when it is gone, so the controller was destroyed while the dialog's exit transition was still running and its `TextFormField` was still rebuilding — `A TextEditingController was used after being disposed`, cascading into `'_dependents.isEmpty': is not true` and `Tried to build dirty widget in the wrong build scope`.

why_earlier_sessions_missed_it: Two reasons, both worth carrying forward. (1) The primary exception was never captured — only the noisier `_dependents.isEmpty` cascade that followed it — so three sessions investigated a second-order symptom, which is what sent the search toward `InheritedElement.debugDeactivated` and GlobalKey reparenting. (2) The recorded reproduction step, "tap ANY Daily Targets card", named the wrong action. Opening the dialog is harmless; **completing** it is the trigger. Every reproduction attempt opened and dismissed.

fix: The dialog is now `TargetOverrideDialog`, a `StatefulWidget` in `lib/features/profile/widgets/` that owns its controller and disposes it in `State.dispose()`, which Flutter calls once the element is genuinely unmounted. The ED safety-net check also moved out of the dialog's own button callback into the caller, so a second dialog is never pushed from inside the first one's handler mid-teardown.

verification: Device (SM-T733, Android 14): the exact crashing action — Calories card, 99999, Save — completes cleanly with zero exceptions. Tests: `test/features/profile/target_override_dialog_disposal_test.dart`, four cases covering Save, Reset, dismissal and reopening, each pumping the exit transition frame by frame rather than relying on `pumpAndSettle`. The test method was validated by temporarily restoring the old pattern and confirming it fails.

follow_up: Removing the crash exposed a second, pre-existing bug — target overrides do not persist at all, because `DriftProfileRepository.saveProfile` never writes the target columns. Filed separately; PROF-05 should not be considered met until that is fixed.

files_changed:
  - lib/features/profile/screens/profile_screen.dart (dialog extracted; ED check moved out of the dialog callback)
files_added:
  - lib/features/profile/widgets/target_override_dialog.dart
  - test/features/profile/target_override_dialog_disposal_test.dart
note_on_older_harnesses: `profile_screen_crash_test.dart` and `profile_screen_full_app_crash_test.dart` both passed while the bug was live, because neither completed the dialog. They are not evidence of anything and should not be treated as regression cover for this crash.

---
status: investigating
deferred: true
trigger: "profile-daily-targets-crash: Flutter app (co2diet, real device) crashes with a framework assertion every time the user taps a card in the Daily Targets section of the Profile screen (lib/features/profile/screens/profile_screen.dart)."
created: 2026-07-29T00:00:00Z
updated: 2026-07-29T00:03:00Z
---

## Current Focus

status_note: DEFERRED BY USER DECISION (2026-07-29) — investigation paused, tracked as debt rather than continuing to burn budget on further theories. Do NOT resume without new evidence (e.g. a fuller real-device stack trace) or explicit instruction.

hypothesis (last one tested, ALSO now eliminated): The crash is a structural go_router navigation-shell issue, not something reproducible from a bare `MaterialApp(home: ProfileScreen())` harness. Production nests ProfileScreen inside `StatefulShellRoute.indexedStack` (branch Navigator, inside an `IndexedStack`, inside `AppShell`), while `showDialog` (default `useRootNavigator: true`) inserts the dialog route on the ROOT Navigator from `MaterialApp.router`. Built `test/features/profile/profile_screen_full_app_crash_test.dart` to test this (pumps the REAL `Co2DietApp` widget with the full go_router shell, in-memory drift DB) — it PASSED (no exception), so this hypothesis is ALSO eliminated (see Eliminated section). Three independent reproduction attempts (Theory B's test, this test) have now failed to trigger the assertion via `flutter_test`.

next_action (when resumed): Do not re-attempt Theory B, Theory A, or the root/branch-navigator theory. Highest-value next steps, in order: (1) get the FULL real-device stack trace (frames above/below the one-line assertion — only the assertion message has been captured so far across the whole investigation); (2) if a full trace isn't obtainable, try a true `integration_test` (device/emulator-run, not `flutter_test`'s fake harness) since `flutter_test`'s synthetic `tester.tap()` / fake clock / TestTextInput cannot simulate real IME keyboard-inset animation, which is the leading untested theory (autofocus:true on the dialog's TextFormField requests the real keyboard on-device; `flutter_test` never physically resizes the view for it) — real keyboard insets changing `MediaQuery.viewInsets` concurrently with `showDialog`'s route insertion is a plausible trigger not yet tested; (3) read Flutter framework source at `_deactivateRecursively`/`InheritedElement.removeDependent`/`Element.activate()` (framework.dart ~2133-2165, ~4797-4822, ~6376-6387) to understand exactly which non-descendant-dependent scenario can leave `_dependents` non-empty — this was read this session (see Evidence) and points at GlobalKey-driven reparenting as the classic cause of this exact assertion, but no GlobalKey usage was found anywhere near ProfileScreen/ProfileForm/TargetDisplayCard (only `rootNavigatorKey` for go_router's root Navigator, which is standard and not itself under suspicion) — so if this route is pursued, look further afield (e.g. go_router/StatefulShellRoute internals' own GlobalKey usage for branch Navigators, which co2diet code doesn't control directly).

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

## Resolution

root_cause: NOT FOUND — investigation deferred by explicit user decision on 2026-07-29 after three independent reproduction attempts (Theory B's Tooltip test, the full-app go_router-shell test) both failed to trigger the assertion via `flutter_test`. Two theories (A: locale-detection loop; B: Tooltip/showDialog conflict) and one additional structural theory (root-navigator vs. branch-navigator dialog insertion) are all eliminated with evidence. Root cause remains unknown. Bug is real, reproduces on every real-device tap of any Daily Targets card, but has resisted reproduction in any `flutter_test` harness so far — likely requires either a fuller real-device stack trace or a true device/emulator `integration_test` to make further progress (see next_action above).
fix: none applied — no fix attempted without a failing test first, per explicit user-mandated discipline.
verification: n/a — not fixed.
files_changed: []
files_added_this_session:
  - test/features/profile/profile_screen_full_app_crash_test.dart (new reproduction attempt via full Co2DietApp + real go_router StatefulShellRoute shell — does NOT reproduce the crash; kept as a regression-harness scaffold for future attempts, not as a passing confirmation the bug is fixed)

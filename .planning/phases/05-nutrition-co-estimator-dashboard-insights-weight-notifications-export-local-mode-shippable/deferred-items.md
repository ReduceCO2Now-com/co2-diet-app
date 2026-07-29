# Deferred Items — Phase 05

Items discovered during plan execution that are out of scope for the
discovering plan's task (per the Scope Boundary rule: only auto-fix issues
directly caused by the current task's changes) and therefore deferred
rather than fixed inline.

## From Plan 05-19

**24 pre-existing `flutter analyze lib/` info-level lint issues**, confirmed
present at commit `36218e7` (the last commit of Plan 05-18, before 05-19
started) and unrelated to any file 05-19 touched:

- `comment_references` (name not visible in scope inside a doc comment) in:
  `lib/core/di/app_providers.dart:23`, `lib/data/local/daos/food_catalog_dao.dart`
  (lines 292, 396, 526), `lib/data/local/tables/favorite_table.dart:12`,
  `lib/domain/entities/food_item.dart` (lines 100, 101, 102, 110, 119, 128),
  `lib/domain/repositories/i_food_catalog_repository.dart:38`,
  `lib/features/barcode_scan/screens/methodology_screen.dart:10`,
  `lib/features/barcode_scan/widgets/confidence_chip.dart:90`
- `lines_longer_than_80_chars` in: `lib/data/remote/off_api_client.dart:112`,
  `lib/domain/repositories/i_food_catalog_repository.dart:36`,
  `lib/features/barcode_scan/screens/methodology_screen.dart` (lines 47, 70),
  `lib/features/barcode_scan/widgets/confidence_chip.dart` (lines 7, 15, 37, 90)
- `prefer_initializing_formals` in `lib/data/local/daos/food_catalog_dao.dart:43`
- `avoid_positional_boolean_parameters` in
  `lib/features/notifications/providers/notification_prefs_notifier.dart:49`

All 24 are `info` severity (not `warning`/`error`) and span Phases 2-5 code
that 05-19's own tasks never modified. Plan 05-19's own verification block
asks for "zero analyzer issues project-wide," but per this executor's Scope
Boundary rule, pre-existing issues in unrelated files are out of scope for
a single plan's fix — flagged here for a future cleanup pass (e.g. a
dedicated lint-debt plan) rather than fixed opportunistically mid-plan.

Two *new* issues 05-19 itself introduced (one `lines_longer_than_80_chars`
in `metric_card.dart`, one `avoid_types_on_closure_parameters` in
`detailed_food_analysis_panel.dart`) were fixed inline before committing —
not deferred.

## From Phase 5 real-device UAT — Profile "Daily Targets" crash (bug #4)

**Status: formally deferred 2026-07-29.** Four separate investigation
attempts (two fix theories in the original UAT session, plus a dedicated
follow-up `gsd-debugger` session) did not find a root cause. Per this
project's established discipline ("never fix a theory without first
proving a test fails against current code"), no fix has been applied —
this is being deferred as tracked debt rather than forced to a guessed
resolution.

**Where:** `lib/features/profile/screens/profile_screen.dart`
(`_ProfileScreenState._showOverrideDialog`), triggered from
`_TargetsSection`/`TargetDisplayCard` (`lib/features/profile/widgets/target_display_card.dart`)
in the Profile screen's "Daily Targets" grid. This is **Phase 1 code**
(requirements PROF-01–05, delivered in Plan 01-05) — it is not part of
Phase 5's own requirement set (NUTR/CO2/DASH/INS/WT/NOTIF/PRIV/AUTH-07/NFR-05),
and was only encountered because this UAT session exercised the whole app,
not just Phase 5 surfaces.

**Symptom / reproduction:** On a real device, tapping **any** card in the
Daily Targets grid (Calories/Protein/Carbs/Fat) crashes the app, every
single time, unconditionally — confirmed to happen identically whether the
profile has real height/weight/target data entered or is still empty (this
was the key new data point that closed off the leading theory). The crash
is a Flutter framework assertion: `assert(_dependents.isEmpty)` failing in
`InheritedElement.debugDeactivated()` (`framework.dart` ~line 6268 in
Flutter 3.44.6) — this fires when some `InheritedElement` ancestor is
deactivated while a descendant `Element` still depends on it, i.e. tree
teardown happening out of the normal top-down order somewhere between the
tap and `showDialog`'s route insertion.

**Theories investigated and ruled out:**
1. *Infinite locale-detection auto-save loop* in `_buildBody` — a real,
   separate bug (fixed at commit `c6697a3`, see the explanatory comment in
   `profile_screen.dart` lines ~46–61) that was tearing down/rebuilding
   `ProfileScreen`'s Element at high frequency underneath `showDialog`.
   Re-tested on-device after the fix and got the identical crash, so this
   was not the cause. Doubly ruled out now: that code path only runs when
   `profile == null`, but the crash also reproduces when `profile != null`.
2. *`MissingTargetDash`'s `Tooltip` wrapper* (rendered only on the
   empty-value path) conflicting with `showDialog`'s route insertion. A
   widget test (`test/features/profile/profile_screen_crash_test.dart`)
   reproduces the real tap interaction on an empty-value card but does
   **not** throw — falsified. Doubly ruled out now: filled-value cards
   (which never render `MissingTargetDash`/`Tooltip` at all) crash
   identically to empty ones.

**Still unknown:** the actual root cause. The full crash stack trace/frame
list has never been captured — only the single-line assertion message.
Notably, the widget-test harness cannot reproduce the crash even for the
theoretically simplest case (a plain tap on an empty-value card on a real
`ProfileScreen`), which suggests either an Overlay/Route timing gap
specific to `flutter_test`'s harness vs. a real device/engine, or that the
true trigger still hasn't been isolated.

3. *Follow-up widget-test structure gap* — theorized that the earlier
   widget test's bare `MaterialApp(home: ProfileScreen())` harness was
   missing real navigation-shell structure. Built
   `test/features/profile/profile_screen_full_app_crash_test.dart`, which
   pumps the actual `Co2DietApp` (full go_router
   `StatefulShellRoute.indexedStack` shell) instead. Still does **not**
   reproduce the crash — three separate widget-test structures have now
   all failed to trigger it, reinforcing that this looks like a
   real-device-only condition rather than something achievable in
   `flutter_test`.

Framework-source analysis (`framework.dart` ~2133–2165, ~4797–4822,
~6376–6387) narrowed the *class* of bug: this exact assertion is
classically caused by `GlobalKey`-driven element reparenting leaving a
dependent Element outside the normal deactivation pass. A full-codebase
grep found only one `GlobalKey` in the app (`rootNavigatorKey` in
`app_router.dart`, standard go_router usage) — nothing app-level explains
it, so the next place to look, if pursued, would be go_router 17.3.0's own
internals (route-transition element handling), or real IME
keyboard-inset-animation timing concurrent with `showDialog`'s route
insertion (a real-device-only condition `flutter_test` cannot simulate,
and the current leading untested candidate).

**Next steps for whoever picks this back up:**
- Get the **full** real-device stack trace (ask for more of the
  logcat/Xcode console output above and below the assertion line — only
  the one-line message has been captured so far).
- Try an `integration_test` (real device/emulator) reproduction instead of
  a `flutter_test` widget test, since three widget-test structures have
  now all failed to reproduce it.
- If pursued, look at go_router 17.3.0's route-transition/element handling,
  and/or real IME keyboard-inset animation timing concurrent with
  `showDialog`'s route insertion — both are untested leads from this
  session's framework-source analysis.
- Do not attempt a fix without first getting a test to fail against
  current code — this discipline is why 3+ plausible-looking theories were
  correctly *not* turned into unverified fixes.

**Investigation notes:** `.planning/debug/profile-daily-targets-crash.md`
(debug session left in paused/inconclusive state, not resolved).

**Why safe to defer:** confirmed not blocking any Phase 5 in-scope
requirement — see `ROADMAP.md`'s Phase 5 requirement list. It is Phase 1
functionality that already shipped; Phase 5's goal-verification and
checkpoint do not depend on the Daily Targets override dialog working.

## From Phase 5 real-device UAT — Weight chart has no visible axis labels

**Status: deferred as minor polish, 2026-07-29.** Flagged by the user
during Test 4 (Weight Tracking) as a non-blocking note, not a bug —
explicitly not requesting a fix now.

**Where:** `lib/features/weight/widgets/weight_chart.dart` — the
`LineChart`'s `titlesData: const FlTitlesData(show: false)` hides all
axis labels entirely (no dates on the X-axis, no kg/lb values on the
Y-axis).

**Why it's not urgent:** the underlying data and interactions are all
correct and user-confirmed working (range switching, touch-and-drag
tooltip, goal reference line) — this is purely a readability polish
item. It did cause some confusion during UAT (Test 4's range-switching
concern was partly this: with axis labels hidden, there was no visual
way to confirm a range change actually took effect even when the
underlying data was identical across ranges for otherwise-legitimate
reasons).

**Suggested future fix:** add a minimal `titlesData` config (mirroring
`today_breakdown_bar_chart.dart`/`trend_section.dart`'s already-fixed
patterns elsewhere in Data Analysis) — Y-axis kg/lb value labels and
X-axis date labels for the visible range, formatted appropriately per
range length (e.g. day-of-week for 7d, date for longer ranges, matching
`trend_section.dart`'s established `DateFormat('E')`/`DateFormat('d/M')`
convention from this same session).

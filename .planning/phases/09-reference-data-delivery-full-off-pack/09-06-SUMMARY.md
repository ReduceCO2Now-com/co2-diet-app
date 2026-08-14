---
phase: 09-reference-data-delivery-full-off-pack
plan: 06
subsystem: ui
tags: [riverpod, shared_preferences, connectivity_plus, mocktail]

# Dependency graph
requires:
  - phase: 09-05
    provides: ReferencePackNotifier (referencePackProvider) -- AsyncNotifier presentation-layer surface, IReferencePackRepository (referencePackRepositoryProvider)
provides:
  - ReferencePackScheduleNotifier (referencePackScheduleProvider) -- SharedPreferences-backed schedule + lastCheckedAt, isCheckDue pure helper
  - ReferencePackNotifier.checkForUpdateIfDue() -- the automatic-refresh-only manifest-check + delta-download-or-Wi-Fi-wait path
  - Co2DietApp AppLifecycleState.resumed hook driving the throttled foreground delta-refresh check
  - ReferenceDataScreen's Automatic Refresh SegmentedButton + revert-resets-schedule wiring
affects: [09-07, 09-08]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Foreground-only 'scheduling': no workmanager/background_fetch/Timer.periodic anywhere in this app -- AppLifecycleState.resumed + a throttled interval check (isCheckDue, recomputed fresh from DateTime.now() every call, never a persisted next-fire-time) is the sole mechanism, mirroring Plan 05-13/05-18's weigh-in reminder re-arm exactly"
    - "Sibling, not nested, AppLifecycleState.resumed checks: didChangeAppLifecycleState calls two independent private methods rather than chaining a second check inside the first block's body, so one feature's early returns can never silently swallow the other's"
    - "mocktail `when()`/`verify()` require the stubbed call to actually execute inside the closure (Mock.noSuchMethod interception) -- a bare tearoff never invokes the method and silently skips stub registration, producing a hang, not a compile/runtime error"

key-files:
  created:
    - lib/features/reference_data/providers/reference_pack_schedule_provider.dart
    - lib/features/reference_data/providers/reference_pack_schedule_provider.g.dart
  modified:
    - lib/app.dart
    - lib/features/reference_data/providers/reference_pack_notifier.dart
    - lib/features/reference_data/screens/reference_data_screen.dart
    - test/app_lifecycle_reference_pack_test.dart
    - test/features/reference_data/reference_data_screen_test.dart

key-decisions:
  - "ReferencePackScheduleState is a Dart record typedef ({schedule, lastCheckedAt}), not a class -- plan called for 'a small record/class'; a record needed no equality/copyWith boilerplate for a 2-field read-mostly value"
  - "isCheckDue is a free top-level function (not a method), taking (schedule, lastCheckedAt, now) explicitly -- easily unit-testable with zero SharedPreferences/widget setup, matching the plan's explicit requirement"
  - "checkForUpdateIfDue() swallows Exception silently -- it's a best-effort fire-and-forget background check triggered from a lifecycle callback with no user-visible error surface; a network failure must never crash or spam anything"
  - "Delta downloads are exclusively started by checkForUpdateIfDue() -- ReferenceDataScreen's manual Download button only ever calls startFullDownload(), never startDeltaDownload(); this means checkForUpdateIfDue() never needs to branch on 'did this call originate from the automatic path' since it structurally IS the only automatic-path caller"
  - "revertToSeed()'s schedule-reset happens at the screen layer (ReferenceDataScreen._handleRevert calls referencePackScheduleProvider.notifier.resetToManual() immediately after a successful revertToSeed()), not inside ReferencePackRepository.revertToSeed() itself -- matches the plan's explicit Task 2 instruction; the repository's pre-existing TODO comment referencing this was left in place as a pointer to the presentation-layer-owned schedule store, not a bug"

patterns-established:
  - "Extracting an existing lifecycle-observer block into its own private method (_rearmWeighInReminderIfNeeded) the moment a second independent concern needs to share the same AppLifecycleState.resumed callback -- prevents one block's early `return`s from silently gating unrelated logic added later in the same method body"

requirements-completed: []

# Metrics
duration: ~70min
completed: 2026-08-14
---

# Phase 09 Plan 06: Automatic Weekly/Monthly Delta-Refresh Scheduling Summary

**ReferencePackScheduleNotifier (SharedPreferences-backed schedule + throttled isCheckDue), wired into Co2DietApp's existing AppLifecycleState.resumed observer as an independent sibling check that drives ReferencePackNotifier.checkForUpdateIfDue() -- honest foreground-only "scheduling," no background scheduler invented.**

## Performance

- **Duration:** ~70 min
- **Tasks:** 2 (all complete)
- **Files created:** 2
- **Files modified:** 5

## Accomplishments

- `ReferencePackScheduleNotifier` (`referencePackScheduleProvider`, keepAlive): persists `ReferencePackSchedule` (manual/weekly/monthly, default manual) + `lastCheckedAt` (nullable ISO8601) through `SharedPreferences`, mirroring `MethodologyBannerDismissalNotifier`'s exact pattern. `setSchedule`/`recordCheckedNow`/`resetToManual` all persist-then-update-state synchronously.
- `isCheckDue(schedule, lastCheckedAt, now)`: pure, side-effect-free top-level function -- `manual` never due; `weekly`/`monthly` due when never-checked or the elapsed gap has reached 7/30 days respectively. Recomputed fresh every call, never a persisted "next fire time," matching the weigh-in reminder's established honesty framing.
- `Co2DietApp.didChangeAppLifecycleState`: the pre-existing weigh-in reminder block was extracted into `_rearmWeighInReminderIfNeeded()` and is now called as a **sibling**, not a parent, of the new `_checkReferencePackIfDue()` call -- so the weigh-in block's own early returns (e.g. `weightProvider` still loading) can never short-circuit the reference-pack check. This was caught by the plan's own widget tests, not assumed correct by inspection (see Deviations).
- `ReferencePackNotifier.checkForUpdateIfDue()`: fetches the manifest, compares against `installedVersion()` via the already-existing `isReferencePackUpdateAvailable` helper (reused, not re-derived). If a newer version exists: on Wi-Fi, starts `startDeltaDownload(allowCellular: false)` directly with no per-refresh confirmation dialog; off Wi-Fi, only sets state to `ReferencePackUpdateAvailable(waitingForWifi: true)` and never touches the network for the actual payload. Swallows `Exception` silently -- a best-effort background check, not a user-initiated action with visible error feedback. This is the sole call site in the whole feature that ever starts a delta download (the manual Download button always uses `startFullDownload`).
- `ReferenceDataScreen`'s Full state gained an "Automatic Refresh" `SegmentedButton<ReferencePackSchedule>` (Manual/Weekly/Monthly), bound to `referencePackScheduleProvider`, visible only once the full catalog is installed. The Revert confirmation handler now also calls `resetToManual()` immediately after a successful `revertToSeed()`.
- `app_lifecycle_reference_pack_test.dart` turned green with **zero skips** (replacing the 5-test skip stub with 12 real tests across 3 groups): pure `isCheckDue` unit tests (7), `Co2DietApp` lifecycle-observer integration tests via `tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed)` against a `_FakeReferencePackNotifier` call-counter (4), and a Wi-Fi-off `checkForUpdateIfDue` behavior test against a mocktail-mocked `IReferencePackRepository` + mocked `connectivity_plus` channel (1).

## Task Commits

Each task was committed atomically:

1. **Task 1: ReferencePackScheduleNotifier** - `99e9abe` (feat)
2. **Task 2: app.dart wiring + notifier/screen extensions + turn lifecycle stub green** - `fe7e6f6` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified

- `lib/features/reference_data/providers/reference_pack_schedule_provider.dart` - `ReferencePackScheduleNotifier`, `ReferencePackScheduleState` record typedef, `isCheckDue`
- `lib/features/reference_data/providers/reference_pack_schedule_provider.g.dart` - generated Riverpod codegen output
- `lib/app.dart` - `didChangeAppLifecycleState` now dispatches two independent sibling checks; weigh-in block extracted into `_rearmWeighInReminderIfNeeded()`, new `_checkReferencePackIfDue()` added
- `lib/features/reference_data/providers/reference_pack_notifier.dart` - `checkForUpdateIfDue()` added
- `lib/features/reference_data/screens/reference_data_screen.dart` - Automatic Refresh `SegmentedButton` in `_buildFull()`; revert handler resets schedule to manual
- `test/app_lifecycle_reference_pack_test.dart` - 12 real tests replacing the Wave 0 skip stub
- `test/features/reference_data/reference_data_screen_test.dart` - `_wrap` helper now overrides `sharedPreferencesProvider` (Full state now watches `referencePackScheduleProvider`)

## Decisions Made

See `key-decisions` in frontmatter above for the full rationale on each. In short: record typedef over a class for `ReferencePackScheduleState`; `isCheckDue` as a pure top-level function per the plan's explicit testability requirement; silent exception-swallowing in `checkForUpdateIfDue()` since it's a fire-and-forget background check; delta downloads exclusively originate from `checkForUpdateIfDue()`; and the revert-resets-schedule rule is implemented at the screen layer (per the plan's Task 2 instruction), not inside the Plan 09-04 repository.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Reference-pack check was silently unreachable when the weigh-in reminder block's own early return fired first**
- **Found during:** Task 2, while running the new `app_lifecycle_reference_pack_test.dart` widget tests
- **Issue:** The plan's Task 2 action described adding the new check "after the weigh-in reminder re-arm block already there" as sequential code inside the same `didChangeAppLifecycleState` method. Written that way, the pre-existing weigh-in block's `if (settings == null) return;` (true whenever `weightProvider`'s async build hasn't resolved yet -- the common case in any freshly-composed widget test, and a real possibility on a cold app-resume before the DB read completes) returned out of the entire method, permanently skipping the new reference-pack check underneath it. This violated the plan's own explicit constraint: "this feature must not depend on or interfere with the weigh-in reminder logic already present."
- **Fix:** Extracted the existing weigh-in reminder logic into its own private method `_rearmWeighInReminderIfNeeded()`. `didChangeAppLifecycleState` now calls it and `unawaited(_checkReferencePackIfDue())` as two independent, sequential top-level statements -- neither can short-circuit the other via an early `return` buried inside a helper method's own body.
- **Files modified:** `lib/app.dart`
- **Verification:** All 4 `Co2DietApp lifecycle observer` tests in `app_lifecycle_reference_pack_test.dart` pass (2 initially failed with this bug present, confirming it was a real defect, not test-only flakiness).
- **Committed in:** `fe7e6f6` (Task 2 commit)

**2. [Rule 3 - Blocking] `reference_data_screen_test.dart`'s `_wrap` helper needed a `sharedPreferencesProvider` override**
- **Found during:** Task 2, after adding the Automatic Refresh `SegmentedButton` (which watches `referencePackScheduleProvider`, itself backed by `sharedPreferencesProvider`) to `ReferenceDataScreen`'s Full state
- **Issue:** `reference_data_screen_test.dart` (not in this plan's `files_modified` list) only overrode `referencePackProvider`; without a `sharedPreferencesProvider` override, the Full-state "Revert" widget test would hit `sharedPreferencesProvider`'s default `throw UnimplementedError('overridden in main.dart via ProviderScope')`.
- **Fix:** `_wrap` is now `async`, calls `SharedPreferences.setMockInitialValues({})` + `SharedPreferences.getInstance()`, and overrides `sharedPreferencesProvider` alongside the existing `referencePackProvider` override -- same pattern already established in `test/widget_test.dart`. All call sites updated to `await _wrap(...)`.
- **Files modified:** `test/features/reference_data/reference_data_screen_test.dart`
- **Verification:** All 8 `ReferenceDataScreen` tests pass, including the Full-state Revert test that now exercises the schedule provider's real default (manual) state.
- **Committed in:** `fe7e6f6` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (1 Rule 1 -- a real control-flow bug caught by the plan's own test requirements; 1 Rule 3 -- a blocking test-setup gap surfaced by wiring the new provider into an existing screen).
**Impact on plan:** Both fixes were necessary for the plan's own must-haves to actually hold (the independence requirement, and a screen that renders without crashing). No scope creep beyond what the plan's Task 2 already specified.

## Issues Encountered

- Initial `ProviderContainer`-based test for `checkForUpdateIfDue`'s off-Wi-Fi behavior hung for 30s and threw "provider ... was disposed during loading state, yet no value could be emitted." Root cause: `container.read(referencePackProvider.future)` alone, with no active `container.listen(...)` on `referencePackProvider`, does not keep its non-keepAlive dependency (`referencePackStatusStreamProvider`) alive long enough for `Stream.value`'s single event to actually be delivered -- the autoDispose scheduler wins the race. Fixed by adding `container.listen(referencePackProvider, (_, _) {})` before the `await`, the same class of pitfall as the already-documented [Phase 02-07] `ProviderContainer.listen`-over-bare-`read` precedent, now extended to stream-backed providers specifically.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Every remaining locked decision in `09-CONTEXT.md`'s "Delta Refresh: Schedule & Prompting" section is now closed out end-to-end: Manual/Weekly/Monthly scheduling works through the same honest foreground-check mechanism the weigh-in reminder already established; reverting always resets the schedule to Manual; no Dashboard-level banner exists for this feature.
- `ReferencePackScheduleNotifier`/`referencePackScheduleProvider` is now the stable schedule surface any later plan (e.g. Plan 09-07/09-08, or a future Settings audit) can read without further plumbing.
- Real-device verification of the actual `AppLifecycleState.resumed` foreground trigger (vs. this plan's widget-test simulation via `tester.binding.handleAppLifecycleStateChanged`) remains open, consistent with the same class of gap already flagged for Plan 09-04's `background_downloader` real-device pass -- not a blocker for this plan's completion.

---
*Phase: 09-reference-data-delivery-full-off-pack*
*Completed: 2026-08-14*

## Self-Check: PASSED

All 7 claimed files found on disk (plus the generated `.g.dart` file); both task commit hashes (`99e9abe`, `fe7e6f6`) found in git log.

---
phase: 04-meal-logging-core-10s-target
plan: 12
subsystem: testing
tags: [flutter, integration_test, mocktail, riverpod, drift, connectivity_plus, offline-first]

# Dependency graph
requires:
  - phase: 04-10
    provides: Recent one-tap-log path (MealEntryNotifier.logFromRecent)
  - phase: 04-11
    provides: MealEntryRow swipe actions + real PlaceholderDashboardScreen body
provides:
  - "integration_test/meal_logging_benchmark_test.dart: real WidgetTester-driven LOG-13 tap-to-saved <10s benchmark (Dart-level proxy, self-skips without off_reference.sqlite)"
  - "test/features/meal_logging/offline_logging_test.dart: runtime proof (real in-memory-DB-backed repositories, not mocked) that the full log/edit/delete/duplicate + custom-food/override sequence never touches OffApiClient or Connectivity"
affects: [04-13]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Bounded tester.pump(fixedDuration) loop (_pumpUntilFound helper) instead of pumpAndSettle() for any UI wait that races an open-ended timer (Undo snackbar auto-dismiss, swipe-reveal animations) — RESEARCH.md Pitfall 3"
    - "Offline-path proof at the concrete-repository level: override appDatabaseProvider with an in-memory AppDatabase and offApiClientProvider with a throw-on-any-call mocktail mock, then run the real notifier/repository/DAO stack end-to-end — stronger guarantee than asserting a mocked repository method wasn't called"
    - "connectivity_plus platform-channel mock inverted to assert absence: handler calls fail() on any invocation, rather than returning a canned online/offline result (STATE.md Phase 02-07's channel-mocking convention, applied in the opposite direction)"

key-files:
  created: []
  modified:
    - integration_test/meal_logging_benchmark_test.dart
    - test/features/meal_logging/offline_logging_test.dart

key-decisions:
  - "Stopwatch window starts immediately before the tap on the first search-result row (not at food-search-screen entry), matching this plan's task spec literally — screen navigation happens before the timed window"
  - "Dashboard-visibility check (LOG-13's 'saved and visible on dashboard' chain) asserts on MealEntryRow's widget type rather than exact product-name text, since the OFF-derived display name for the 'banana' query isn't guaranteed verbatim across dataset refreshes"
  - "Offline test builds its ProviderContainer by overriding appDatabaseProvider (in-memory) and offApiClientProvider (throwing mock) rather than mealEntryRepositoryProvider/userFoodRepositoryProvider directly — the real MealEntryRepository/UserFoodRepository/DAOs run unmocked, so the test proves the concrete implementation's offline safety, not just that a mock method went uncalled"
  - "Post-mutation assertions re-read container.read(xProvider.future) rather than the synchronous .value — every mutation calls ref.invalidateSelf(), which reruns build() asynchronously; reading .value immediately after can race a still-loading rebuild and observe stale/empty data"

patterns-established:
  - "_pumpUntilFound(tester, finder): shared bounded-pump-loop helper pattern for any future integration_test file needing to wait for async UI state without pumpAndSettle()'s open-ended-timer risk"

requirements-completed: [LOG-12, LOG-13]

# Metrics
duration: ~10min
completed: 2026-07-24
---

# Phase 4 Plan 12: Wave 0 Stub Backfill (LOG-12 Offline Assertion + LOG-13 Benchmark) Summary

**Filled in the two Wave-0 test stubs that could only be completed once the full logging flow existed: a real WidgetTester-driven tap-to-saved timing benchmark, and a runtime proof (against unmocked repositories) that the core logging path never touches the network.**

## Performance

- **Duration:** ~10min
- **Completed:** 2026-07-24
- **Tasks:** 2/2 completed
- **Files modified:** 2

## Accomplishments

- `integration_test/meal_logging_benchmark_test.dart` now pumps the real app (`Co2DietApp` inside a `ProviderScope`), navigates to `/food-search`, searches "banana", taps the first result, logs it with the default quantity, and asserts the tap-to-saved window (measured via `Stopwatch`, never `pumpAndSettle()`) completes in under 10 seconds — then optionally confirms the entry is visible on `/dashboard`.
- `test/features/meal_logging/offline_logging_test.dart` now runs the full `MealEntryNotifier` (log/edit/delete/undo/duplicate) and `UserFoodNotifier` (save/save-override/revert) sequences against a real in-memory `AppDatabase`-backed repository stack, with `OffApiClient` mocked to throw and the `connectivity_plus` platform channel mocked to `fail()` on any call — 0 skips, both groups pass.
- Both files pass `flutter analyze` clean and the plan's literal verification command (`flutter test test/features/meal_logging/offline_logging_test.dart && flutter analyze integration_test/meal_logging_benchmark_test.dart`).

## Task Commits

Each task was committed atomically:

1. **Task 1: LOG-13 tap-to-saved benchmark** - `ed25b30` (feat)
2. **Task 2: LOG-12 offline logging assertion** - `12be67e` (test)

**Plan metadata:** (this commit)

## Files Created/Modified

- `integration_test/meal_logging_benchmark_test.dart` - Real WidgetTester-driven LOG-13 benchmark: pumps the app, searches, taps a result, logs it, times tap-to-saved with `Stopwatch` + bounded `pump()`, asserts <10s, self-skips when `off_reference.sqlite` is absent.
- `test/features/meal_logging/offline_logging_test.dart` - Runtime LOG-12 proof: real in-memory-DB-backed `MealEntryRepository`/`UserFoodRepository` run the full log/edit/delete/duplicate + custom-food/override sequence with `OffApiClient` and `connectivity_plus` both wired to fail loudly if invoked.

## Decisions Made

- Stopwatch starts immediately before the tap on the first search-result row, not at food-search-screen entry — matches the task spec's literal instruction and keeps the measured window scoped to "tap to saved," not "navigate to search to saved."
- Dashboard-visibility check uses `find.byType(MealEntryRow)` rather than matching the logged food's exact product-name text, since the OFF-sourced display name for "banana" isn't a stable literal to assert against.
- The offline test overrides `appDatabaseProvider` (in-memory `NativeDatabase.memory()`) and `offApiClientProvider` (throwing mocktail mock) rather than overriding the repository providers directly — this runs the real `MealEntryRepository`/`UserFoodRepository`/DAO implementations unmocked, which is a stronger proof of offline-safety than verifying a mocked repository method was never called.
- Every post-mutation assertion re-reads `container.read(xProvider.future)` instead of the synchronous `.value`, since each mutation method calls `ref.invalidateSelf()` and reading synchronously immediately afterward can race the still-in-flight rebuild (initially caused two flaky test failures during development, both fixed before commit — see Deviations).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Offline test's post-mutation assertions raced the async rebuild triggered by `ref.invalidateSelf()`**
- **Found during:** Task 2, first local test run
- **Issue:** Reading `container.read(mealEntryProvider).value` / `container.read(userFoodProvider).value` immediately after a sequence of notifier mutations returned stale/empty data (`[]` instead of the expected persisted rows), because each mutation's `ref.invalidateSelf()` reruns `build()` asynchronously and the synchronous `.value` read raced that in-flight rebuild.
- **Fix:** Changed both final assertions to `await container.read(xProvider.future)`, which deterministically awaits the settled post-mutation state (same pattern already established in `meal_entry_notifier_test.dart`'s `_waitForListMatching` helper, applied here via the simpler `.future` re-read since no intermediate predicate-matching was needed).
- **Files modified:** `test/features/meal_logging/offline_logging_test.dart`
- **Verification:** `flutter test test/features/meal_logging/offline_logging_test.dart` — both groups pass with 0 skips.
- **Committed in:** `12be67e` (part of Task 2's commit — caught and fixed before the task was committed, not a follow-up)

**2. [Rule 3 - Blocking] `unawaited_futures` lint on the benchmark's `GoRouter.push` call**
- **Found during:** Task 1, `flutter analyze` verification
- **Issue:** `GoRouter.of(context).push('/food-search')` returns a `Future<T?>` that the test doesn't need to await (the bounded pump loop that follows already waits for the navigation to complete); very_good_analysis's `unawaited_futures` lint flagged the un-awaited expression.
- **Fix:** Wrapped the call in `unawaited(...)` (added `dart:async` import).
- **Files modified:** `integration_test/meal_logging_benchmark_test.dart`
- **Verification:** `flutter analyze integration_test/meal_logging_benchmark_test.dart` — no issues found.
- **Committed in:** `ed25b30` (part of Task 1's commit)

## Known Stubs

None — both files are real, fully-unskipped implementations per this plan's `must_haves`.

## Threat Flags

None — this plan only adds test files; no new production trust boundaries, endpoints, or schema changes were introduced.

## Self-Check: PASSED

- `integration_test/meal_logging_benchmark_test.dart` — FOUND
- `test/features/meal_logging/offline_logging_test.dart` — FOUND
- `ed25b30` — FOUND in git log
- `12be67e` — FOUND in git log

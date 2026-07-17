---
phase: 01-foundations-sync-safe-schema
plan: "07"
subsystem: testing
tags: [drift, flutter_test, sqlite, mifflin, tdee, dao, schema, blocklist, theme, color-tokens]

# Dependency graph
requires:
  - phase: 01-foundations-sync-safe-schema/01-02
    provides: "Drift schema: UserProfileTable with SyncSafeTable mixin, ConsentRecordsTable without mixin, AppDatabase, generated companions"
  - phase: 01-foundations-sync-safe-schema/01-03
    provides: "Domain services: calculateTdee function, Gender enum, ActivityLevel enum"
  - phase: 01-foundations-sync-safe-schema/01-04
    provides: "DriftProfileRepository wiring through AppDatabase DAOs"
  - phase: 01-foundations-sync-safe-schema/01-06
    provides: "CI script check_privacy_deps.dart + .privacy-blocklist.yaml"
  - phase: 01-foundations-sync-safe-schema/01-01
    provides: "Theme layer: AppColors, buildLightTheme(), buildDarkTheme()"
provides:
  - "All 6 Wave 0 test files green — automated proof of schema correctness, formula accuracy, and CI script behavior"
  - "TDEE formula correctness: 9 tests covering exact outputs, null guards, and activity multipliers"
  - "Drift DAO round-trips: upsert+retrieve, kcalIsOverridden flag, single-row invariant"
  - "Schema structural tests: co2_methodology_version defaults to 1.0 (CO2-04); all 6 SyncSafeTable columns confirmed; consent_records isolation confirmed"
  - "Blocklist subprocess tests: exit-0 clean lock, exit-1 firebase_core/sentry_flutter injection"
  - "12 theme color token spot-checks + ThemeData build-without-throw assertions"
affects: [phase-02, phase-03, wave-0-gate, verification]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "flutter_test for all Drift DAO tests (app_database.dart pulls dart:ui via drift_flutter — pure dart test cannot load these)"
    - "NativeDatabase.memory() + DatabaseConnection(closeStreamsSynchronously: true) as standard in-memory Drift test setup"
    - "import 'package:drift/drift.dart' hide isNotNull to avoid matcher name collision with flutter_test"
    - "sqlite_master SELECT sql pattern for structural column-presence checks"
    - "Process.run subprocess test pattern with addTearDown(lockFile.deleteSync) for temp file cleanup"

key-files:
  created:
    - test/data/local/user_profile_dao_test.dart
    - test/data/local/consent_records_dao_test.dart
    - test/data/local/schema_test.dart
    - test/ci/blocklist_test.dart
  modified:
    - test/core/theme/theme_token_test.dart

key-decisions:
  - "flutter test required for Drift DAO tests: app_database.dart imports drift_flutter which imports dart:ui — 5 of 6 test files need flutter test; mifflin test (pure Dart) still runs under dart test"
  - "Drift table names include _table suffix: user_profile_table and consent_records_table (not user_profile / consent_records) — Drift converts class name to snake_case verbatim"
  - "hide isNotNull from drift import: Drift re-exports matcher.isNotNull which conflicts with flutter_test's isNotNull when both are imported; resolved with hide clause on drift import"
  - "addTearDown(lockFile.deleteSync) as tearoff (not lambda): very_good_analysis unnecessary_lambdas requires tearoff syntax"

patterns-established:
  - "Drift in-memory test: AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true))"
  - "Structural schema check: db.customSelect('SELECT sql FROM sqlite_master WHERE ...').getSingle() then result.read<String>('sql')"
  - "Subprocess CI test: Process.run with workingDirectory set to repo root; await result; assert exitCode and stdout"

requirements-completed:
  - PROF-01
  - PROF-02
  - PROF-03
  - PROF-04
  - PROF-05
  - PRIV-07
  - CO2-04

# Metrics
duration: 18min
completed: "2026-07-17"
---

# Phase 01 Plan 07: Wave 0 Test Suite Summary

**34 passing tests across 6 files proving TDEE formula precision, Drift DAO correctness, sync-safe schema structure, CI blocklist script behavior, and Material 3 color token fidelity**

## Performance

- **Duration:** 18 min
- **Started:** 2026-07-17T10:43:07Z
- **Completed:** 2026-07-17T11:01:00Z
- **Tasks:** 3 (Tasks 1+2 committed together; Task 3 verification-only)
- **Files modified:** 5 (4 created + 1 updated)

## Accomplishments

- Created 4 new test files (DAO, consent, schema, blocklist) and updated theme test to full 12-test spec
- All 34 tests green under `flutter test test/domain/ test/data/ test/ci/ test/core/`
- `flutter analyze --no-fatal-warnings` exits 0 with 0 errors (16 pre-existing info items, none from new files)
- Wave 0 gap closed: VALIDATION.md's 6 missing test files now exist and pass

## Task Commits

1. **Tasks 1+2: Write all 6 Wave 0 test files** - `ef88db0` (test)
2. **Task 3: Full suite verification** - no separate commit (verification-only task, no file changes)

## Files Created/Modified

- `test/data/local/user_profile_dao_test.dart` — 4 tests: upsert+retrieve round-trip, kcalIsOverridden flag, units='imperial', single-row invariant via COUNT(*)
- `test/data/local/consent_records_dao_test.dart` — 3 tests: insert+retrieve, append-only 2-row check, structural no-dirty-column assertion via sqlite_master
- `test/data/local/schema_test.dart` — 3 tests: co2_methodology_version defaults to '1.0', 6 SyncSafeTable columns in user_profile_table, no hlc_millis in consent_records_table
- `test/ci/blocklist_test.dart` — 3 tests: subprocess exit-0 for clean pubspec.lock, exit-1 with firebase_core named in stdout, exit-1 with sentry_flutter named in stdout
- `test/core/theme/theme_token_test.dart` — 12 tests: 8 AppColors hex assertions (primary, onPrimary, primaryContainer, onPrimaryContainer, surface, error, secondary, inverseSurface), colorScheme.primary, colorScheme.surface, buildLightTheme() returns normally, buildDarkTheme() returns normally

## Decisions Made

- **flutter test required for all Flutter-dependent tests:** `app_database.dart` imports `drift_flutter` which imports `dart:ui`. Drift DAO tests, schema tests, and theme tests cannot compile under `dart test`. The pure-Dart Mifflin test (`package:test`) still works with `dart test`. Full suite uses `flutter test test/domain/ test/data/ test/ci/ test/core/`.
- **Drift table name suffix:** Actual SQLite table names are `user_profile_table` and `consent_records_table` (not `user_profile`/`consent_records`) — Drift generates snake_case from the Dart class name verbatim, including the "Table" suffix.
- **`hide isNotNull` on drift import:** `package:drift/drift.dart` re-exports `matcher.isNotNull` which conflicts with `flutter_test`'s `isNotNull` when both are in scope. All DAO tests use `import 'package:drift/drift.dart' hide isNotNull;`.
- **Pre-existing `widget_test.dart` failure excluded:** The scaffold widget test expects `find.text('CO2 Diet')` which doesn't exist in the current app — this failure predates plan 01-07 (committed in 01-01). Out of scope per scope boundary rule.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] dart test incompatible with Flutter-dependent test files**
- **Found during:** Task 1 (initial test run)
- **Issue:** Plan specified `dart test` as the runner, but `app_database.dart` imports `drift_flutter/drift_flutter.dart` which conditionally exports `native.dart` → `dart:ui`. The `dart test` runner lacks Flutter's UI layer, causing `dart:ui is not available on this platform` compile errors for all DAO/schema/theme tests.
- **Fix:** Used `flutter test` for the full Wave 0 suite. `dart test test/domain/` still works for the pure-Dart Mifflin test.
- **Files modified:** None (test runner selection, not file change)
- **Verification:** `flutter test test/domain/ test/data/ test/ci/ test/core/` exits 0 with 34 tests green

**2. [Rule 1 - Bug] `isNotNull` naming conflict between drift and flutter_test**
- **Found during:** Task 1 (flutter test run)
- **Issue:** Both `package:drift/drift.dart` and `package:flutter_test/flutter_test.dart` export `isNotNull`. Ambiguous import causes compile error: "'isNotNull' is imported from both..."
- **Fix:** Added `hide isNotNull` to the drift import in all 3 DAO/schema test files.
- **Files modified:** test/data/local/user_profile_dao_test.dart, test/data/local/consent_records_dao_test.dart, test/data/local/schema_test.dart
- **Verification:** Compile errors resolved; all tests pass

**3. [Rule 1 - Bug] Drift table names include `_table` suffix**
- **Found during:** Task 1 (consent_records_dao_test.dart Test 3 failure: "Bad state: No element")
- **Issue:** Plan's schema test queried `sqlite_master WHERE name='consent_records'` but Drift generates the table as `consent_records_table` (class `ConsentRecordsTable` → snake_case verbatim). `getSingle()` threw because no row matched.
- **Fix:** Updated all sqlite_master queries to use `user_profile_table` and `consent_records_table`.
- **Files modified:** test/data/local/consent_records_dao_test.dart, test/data/local/schema_test.dart
- **Verification:** All 3 schema tests and all 3 consent DAO tests pass

---

**Total deviations:** 3 auto-fixed (all Rule 1 - Bug)
**Impact on plan:** All fixes necessary for compilation and correct behavior. No scope creep. All plan goals achieved.

## Issues Encountered

- Pre-existing `widget_test.dart` failure (expects `find.text('CO2 Diet')` text not present in app since 01-01 scaffold): excluded from full suite run by targeting specific directories (`flutter test test/domain/ test/data/ test/ci/ test/core/`).

## Known Stubs

None — all 6 test files test real production code with no placeholder assertions.

## Threat Flags

No new security surface introduced. All tests are read-only (in-memory DB, temp files, subprocess with read-only args).

## Next Phase Readiness

- Wave 0 complete: all 6 required test files exist and are green
- VALIDATION.md `wave_0_complete` can be updated to `true`
- Phase 1 is complete — all 7 plans executed
- Ready for Phase 2 planning (food search + barcode scanning + meal logging)

---

## Self-Check: PASSED

- All 7 files found on disk (6 test files + SUMMARY.md)
- Commit ef88db0 exists in git log

---

*Phase: 01-foundations-sync-safe-schema*
*Completed: 2026-07-17*

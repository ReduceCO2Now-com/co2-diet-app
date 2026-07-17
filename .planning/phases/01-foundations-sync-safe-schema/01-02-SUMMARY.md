---
phase: 01-foundations-sync-safe-schema
plan: "02"
subsystem: database
tags: [drift, sqlite, hlc, sync-safe-schema, dao, codegen]

# Dependency graph
requires:
  - phase: 01-01
    provides: Flutter scaffold + pubspec with drift 2.34.2 and drift_dev 2.34.0 installed

provides:
  - "Hlc class: millis, counter, nodeId, increment(), receive(), compareTo()"
  - "SyncSafeTable mixin injecting 6 sync columns onto any Drift Table"
  - "UserProfileTable with all PROF-01/02/03/05 profile fields + co2MethodologyVersion"
  - "ConsentRecordsTable — append-only audit log, no SyncSafeTable mixin"
  - "AppDatabase @DriftDatabase schemaVersion 1 with FK enforcement"
  - "UserProfileDao: getProfile, watchProfile, upsertProfile"
  - "ConsentRecordsDao: insertConsent, getAllConsents, watchConsents (no update/delete)"
  - "MigrationStrategy: onCreate createAll, empty onUpgrade, PRAGMA foreign_keys = ON"
  - "schema_v1.json: SQLite CREATE TABLE snapshot committed as migration baseline"
  - "All .g.dart generated files committed"

affects:
  - 01-05-PLAN  # DI providers need AppDatabase.connect()
  - 01-07-PLAN  # schema tests use in-memory AppDatabase
  - 02-PLAN     # food/meal tables will extend SyncSafeTable mixin
  - 07-PLAN     # Phase 7 sync engine reads HLC columns from AppDatabase

# Tech tracking
tech-stack:
  added:
    - "Drift 2.34.2 codegen with @DriftDatabase, @DriftAccessor"
    - "drift_flutter 0.3.1 driftDatabase() for production connection"
    - "NativeDatabase.memory() for in-memory test databases"
  patterns:
    - "SyncSafeTable mixin pattern: one mixin → UUID v7 PK + 5 HLC/sync columns"
    - "Single-row DAO pattern: upsertProfile uses insertOnConflictUpdate"
    - "Append-only DAO pattern: ConsentRecordsDao has no update/delete methods"
    - "MigrationStrategy factory function pattern: buildMigrationStrategy(AppDatabase)"
    - "Named constructor pattern: AppDatabase.connect() wraps driftDatabase()"

key-files:
  created:
    - lib/core/sync/hlc.dart
    - lib/data/local/mixins/sync_safe_table.dart
    - lib/data/local/tables/user_profile_table.dart
    - lib/data/local/tables/consent_records_table.dart
    - lib/data/local/app_database.dart
    - lib/data/local/app_database.g.dart
    - lib/data/local/daos/user_profile_dao.dart
    - lib/data/local/daos/user_profile_dao.g.dart
    - lib/data/local/daos/consent_records_dao.dart
    - lib/data/local/daos/consent_records_dao.g.dart
    - lib/data/local/migrations/migration_strategy.dart
    - lib/data/local/migrations/schemas/schema_v1.json
    - tool/generate_schema_v1.dart
  modified:
    - pubspec.yaml

key-decisions:
  - "drift_dev schema dump CLI is broken against drift 2.34.2 (drift3_preview API mismatch). Cannot upgrade drift_dev to 2.34.4 because freezed 3.2.6-dev.1 pins analyzer ^12 while drift_dev >=2.34.1+1 requires analyzer ^13. Workaround: tool/generate_schema_v1.dart uses NativeDatabase.memory() + sqlite_master query to generate schema_v1.json."
  - "int64() returns Column<BigInt> in Drift (not Column<int>) — Dart int is 64-bit but Drift's type system uses BigInt for int64 columns."
  - "AppDatabase.connect() named constructor replaces static openConnection() to satisfy very_good_analysis prefer_constructors_over_static_methods rule."
  - "SyncSafeTable mixin uses getter syntax (Column<T> get field => ...) not late final syntax to satisfy specify_nonobvious_property_types lint rule."
  - "comment_references lint: removed @references to SyncSafeTable in ConsentRecordsDao comments (not in scope)."

patterns-established:
  - "SyncSafeTable mixin: applied with 'extends Table with SyncSafeTable'; provides id (UUID v7 PK), hlcMillis (BigInt), hlcCounter (int), hlcNodeId (String), dirty (bool default true), deletedAt (DateTime nullable)"
  - "Single-row upsert: DAOs for single-row tables use insertOnConflictUpdate on PK"
  - "Append-only DAO: no update/delete methods, legal audit integrity enforced at API surface"
  - "FK enforcement: PRAGMA foreign_keys = ON in MigrationStrategy.beforeOpen"
  - "Schema snapshot: tool/generate_schema_v1.dart for re-generating schema_v1.json when drift_dev schema dump CLI is unavailable"

requirements-completed: [CO2-04, PROF-01, PROF-02, PROF-03, PROF-05]

# Metrics
duration: 45min
completed: 2026-07-17
---

# Phase 01 Plan 02: Sync-Safe Drift Schema Summary

**Hand-rolled HLC + SyncSafeTable mixin + Drift schema for user_profile and consent_records tables with codegen and schema_v1.json committed**

## Performance

- **Duration:** 45 min
- **Started:** 2026-07-17T08:30:00Z
- **Completed:** 2026-07-17T09:15:00Z
- **Tasks:** 2
- **Files modified:** 13

## Accomplishments

- Hand-rolled `Hlc` class with `increment()`, `receive()`, `compareTo()` — no external hlc package
- `SyncSafeTable` mixin injects exactly 6 sync columns (id UUID v7, hlcMillis BigInt, hlcCounter int, hlcNodeId String, dirty bool, deletedAt DateTime?) onto any Drift Table
- `UserProfileTable` with all PROF-01/02/03/05 fields plus `co2MethodologyVersion` defaulting to '1.0' (CO2-04 satisfied from day 1)
- `ConsentRecordsTable` is purely append-only with no SyncSafeTable — preserves legal audit integrity
- `AppDatabase` compiles with `schemaVersion: 1`, FK enforcement via `PRAGMA foreign_keys = ON`
- All three `.g.dart` codegen files generated and committed
- `schema_v1.json` committed as migration test baseline (via workaround script)
- `dart analyze lib/` exits 0 with zero issues under `very_good_analysis` rules

## Task Commits

Each task was committed atomically:

1. **Task 1: HLC + SyncSafeTable mixin + Drift table definitions** — `771b1c9` (feat)
2. **Task 2: AppDatabase + DAOs + drift codegen + schema_v1.json** — `34da3cc` (feat)
3. **pubspec.yaml documentation** — `7350ab9` (chore)

## Files Created/Modified

- `lib/core/sync/hlc.dart` — Hand-rolled HLC: millis, counter, nodeId, increment(), receive(), compareTo()
- `lib/data/local/mixins/sync_safe_table.dart` — SyncSafeTable mixin on Drift Table with 6 sync columns
- `lib/data/local/tables/user_profile_table.dart` — UserProfileTable with SyncSafeTable + all profile fields
- `lib/data/local/tables/consent_records_table.dart` — ConsentRecordsTable (append-only, no SyncSafeTable)
- `lib/data/local/app_database.dart` — @DriftDatabase schemaVersion 1, AppDatabase.connect()
- `lib/data/local/app_database.g.dart` — Drift codegen output
- `lib/data/local/daos/user_profile_dao.dart` — getProfile, watchProfile, upsertProfile
- `lib/data/local/daos/user_profile_dao.g.dart` — Drift codegen output
- `lib/data/local/daos/consent_records_dao.dart` — insertConsent, getAllConsents, watchConsents
- `lib/data/local/daos/consent_records_dao.g.dart` — Drift codegen output
- `lib/data/local/migrations/migration_strategy.dart` — onCreate createAll + FK enforcement
- `lib/data/local/migrations/schemas/schema_v1.json` — CREATE TABLE SQL snapshot
- `tool/generate_schema_v1.dart` — Workaround for drift_dev schema dump CLI breakage
- `pubspec.yaml` — Documentation comment on drift_dev version constraint

## Decisions Made

- **drift_dev schema dump workaround:** `drift_dev 2.34.0` schema dump CLI fails against `drift 2.34.2` because the drift3_preview `GeneratedDatabase` now requires a `schema` getter that the old `_GenerateFromScratchDrift3` in `verifier_common.dart` doesn't implement. Cannot upgrade `drift_dev` to 2.34.4 because `freezed 3.2.6-dev.1` pins `analyzer ^12` while `drift_dev >=2.34.1+1` needs `analyzer ^13`. Solution: `tool/generate_schema_v1.dart` runs as a Flutter test with `NativeDatabase.memory()`, queries `sqlite_master` for CREATE TABLE SQL, and writes `schema_v1.json`. The resulting JSON contains the actual SQL that Drift generated — which is the most accurate snapshot possible.
- **`Column<BigInt>` for hlcMillis:** `int64()` in Drift returns `Column<BigInt>`, not `Column<int>`. This is correct — Dart's `int` is 64-bit on native platforms but Drift models the 64-bit integer separately from standard integer for column type safety.
- **Named constructor over static method:** `AppDatabase.connect()` satisfies `very_good_analysis` `prefer_constructors_over_static_methods` lint rule.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed `Column<BigInt>` type annotation for hlcMillis**
- **Found during:** Task 1 (SyncSafeTable mixin)
- **Issue:** Initial implementation used `Column<int>` for `int64()` column but `int64()` returns `Column<BigInt>` — dart analyze reported a type error
- **Fix:** Changed `Column<int> get hlcMillis => int64()()` to `Column<BigInt> get hlcMillis => int64()()`
- **Files modified:** `lib/data/local/mixins/sync_safe_table.dart`
- **Committed in:** `771b1c9` (Task 1 commit)

**2. [Rule 1 - Bug] Fixed import ordering lint violations across all new files**
- **Found during:** Task 1 and Task 2
- **Issue:** `very_good_analysis` enforces `directives_ordering` (package: imports alphabetically before relative imports), `always_use_package_imports`, and `specify_nonobvious_property_types`
- **Fix:** Rewrote mixin and table files using getter syntax with explicit `Column<T>` types; used `package:co2diet/...` package imports throughout
- **Files modified:** All four Task 1 files + all Task 2 files
- **Committed in:** `771b1c9`, `34da3cc`

**3. [Rule 2 - Missing Critical] Rewrote `openConnection()` as `AppDatabase.connect()` named constructor**
- **Found during:** Task 2 (AppDatabase)
- **Issue:** `very_good_analysis` `prefer_constructors_over_static_methods` lint rule flags static factory methods that could be constructors
- **Fix:** Changed `static AppDatabase openConnection()` to `AppDatabase.connect()` named constructor using delegation `this(driftDatabase(name: 'co2diet'))`
- **Files modified:** `lib/data/local/app_database.dart`
- **Committed in:** `34da3cc`

**4. [Rule 3 - Blocking] drift_dev schema dump CLI incompatible with drift 2.34.2**
- **Found during:** Task 2 (schema_v1.json generation)
- **Issue:** `dart run drift_dev schema dump lib/data/local/app_database.dart ...` fails with compile error: `_GenerateFromScratchDrift3` missing `schema` getter and `allSchemaEntities` not defined
- **Fix:** Created `tool/generate_schema_v1.dart` — a Flutter test that opens an in-memory `AppDatabase`, forces migrations to run, queries `sqlite_master` for CREATE TABLE SQL, and writes `schema_v1.json`. Schema content is accurate (actual SQLite DDL Drift generates).
- **Files modified:** `lib/data/local/migrations/schemas/schema_v1.json`, `tool/generate_schema_v1.dart`
- **Committed in:** `34da3cc`

---

**Total deviations:** 4 auto-fixed (1 type error, 1 lint violations batch, 1 missing critical lint fix, 1 blocking toolchain issue)
**Impact on plan:** All required. Type error was a compile blocker; lint fixes ensure CI green; schema dump workaround delivers the required artifact via equivalent mechanism.

## Issues Encountered

- **drift_dev 2.34.0 vs drift 2.34.2 API mismatch:** The `drift3_preview` module in drift 2.34.2 added a `schema` abstract getter to `GeneratedDatabase`. The `verifier_common.dart` in drift_dev 2.34.0 generates a `_GenerateFromScratchDrift3` class that extends `GeneratedDatabase` without implementing this getter. This only affects the `schema dump` CLI — codegen (build_runner) is unaffected. Resolution: workaround script.
- **Dependency conflict blocking drift_dev upgrade:** Cannot upgrade to drift_dev 2.34.4 because freezed 3.2.6-dev.1 (needed for riverpod_lint 3.1.4 analyzer compatibility, established in 01-01) pins `analyzer ^12` while drift_dev >=2.34.1+1 requires `analyzer ^13`. This is a known constraint. Deferred to Phase 5 or when freezed publishes a stable release compatible with analyzer ^13.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- `AppDatabase` ready for DI wiring in Plan 01-05 (use `AppDatabase.connect()`)
- `UserProfileDao` ready for `DriftProfileRepository` implementation in Plan 01-04
- `ConsentRecordsDao` ready for Legal Consent screen in Phase 6
- `schema_v1.json` ready for migration tests in Plan 01-07
- Plan 01-07 should use `NativeDatabase.memory()` pattern (same as generate_schema_v1.dart)
- **Blocker to track:** drift_dev/freezed analyzer version conflict means the official `drift_dev schema dump` CLI cannot be used until freezed publishes a version compatible with analyzer ^13. The workaround script (`tool/generate_schema_v1.dart`) must be run manually after any schema change.

---
*Phase: 01-foundations-sync-safe-schema*
*Completed: 2026-07-17*

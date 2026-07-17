---
phase: 01-foundations-sync-safe-schema
plan: "04"
subsystem: data-layer / presentation-layer
tags:
  - riverpod
  - drift
  - repository
  - async-notifier
  - di
dependency_graph:
  requires:
    - 01-02  # Drift schema + UserProfileDao
    - 01-03  # Domain entities + IProfileRepository + TargetCalculator
  provides:
    - DriftProfileRepository
    - appDatabaseProvider
    - profileRepositoryProvider
    - ProfileNotifier
    - profileStreamProvider
  affects:
    - 01-05  # Profile screen consumes profileNotifierProvider + profileStreamProvider
tech_stack:
  added:
    - "DriftProfileRepository (final class, data layer, implements IProfileRepository)"
    - "appDatabaseProvider (@Riverpod keepAlive: true)"
    - "profileRepositoryProvider (@riverpod, returns IProfileRepository)"
    - "ProfileNotifier (@riverpod AsyncNotifier<UserProfile?>)"
    - "profileStreamProvider (@riverpod Stream<UserProfile?>)"
  patterns:
    - "Repository pattern: DriftProfileRepository maps UserProfileRow <-> UserProfile"
    - "Riverpod 3.x: unified Ref; no AutoDisposeRef; @riverpod lowercase annotation"
    - "keepAlive: true on AppDatabase provider (DB lifetime = ProviderScope lifetime)"
    - "ref.invalidateSelf() in saveProfile forces build() re-run with fresh data"
    - "AsyncValue.guard wraps saveProfile mutation for automatic error propagation"
key_files:
  created:
    - lib/data/repositories/drift_profile_repository.dart
    - lib/core/di/providers.dart
    - lib/core/di/providers.g.dart
    - lib/features/profile/providers/profile_notifier.dart
    - lib/features/profile/providers/profile_notifier.g.dart
decisions:
  - "valueOrNull absent in Riverpod 3.3.2 AsyncValue — use state.value (returns T? = null in loading/error states)"
  - "DriftProfileRepository imports app_database.dart (not just daos/user_profile_dao.dart) because UserProfileTableCompanion and UserProfileRow live in the generated app_database.g.dart part file"
  - "AppDatabase.connect() named constructor used (not static openConnection()) per very_good_analysis prefer_constructors_over_static_methods rule from Plan 01-02"
  - "HLC Phase-1 placeholders: hlcNodeId='local', hlcCounter=0; Phase 7 replaces with full HLC increment using stable device UUID"
metrics:
  duration: "3 minutes"
  completed: "2026-07-17T09:38:53Z"
  tasks_completed: 2
  files_created: 5
  verifications_passed: 7
---

# Phase 01 Plan 04: Repository Layer + Riverpod DI + ProfileNotifier Summary

**One-liner:** DriftProfileRepository implements IProfileRepository via UserProfileDao; Riverpod codegen providers wire AppDatabase to the domain interface; ProfileNotifier AsyncNotifier loads + enriches profile with CalcTargets on every build.

---

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | DriftProfileRepository + appDatabaseProvider + profileRepositoryProvider | 5a27f9f | lib/data/repositories/drift_profile_repository.dart, lib/core/di/providers.dart, lib/core/di/providers.g.dart |
| 2 | ProfileNotifier AsyncNotifier + locale-to-units detection | 7f64bf9 | lib/features/profile/providers/profile_notifier.dart, lib/features/profile/providers/profile_notifier.g.dart |

---

## What Was Built

### Task 1: Data Repository + Core DI

**`lib/data/repositories/drift_profile_repository.dart`**

`DriftProfileRepository` is a `final class` implementing `IProfileRepository`. It:
- Takes `UserProfileDao` via constructor injection
- `getProfile()` calls `_dao.getProfile()` and maps `UserProfileRow? -> UserProfile?` via `_rowToProfile()`
- `saveProfile(UserProfile)` assigns a UUID v7 if `profile.id.isEmpty`, sets HLC Phase-1 placeholders (`hlcNodeId='local'`, `hlcCounter=0`, `dirty=true`), and calls `_dao.upsertProfile()`
- `watchProfile()` pipes the Drift stream through `_rowToProfile()` via `Stream.map()`
- `_rowToProfile()` maps each column by name; does NOT compute `CalcTargets` (that belongs to the notifier layer)

All `package:drift` imports are confined to this file. No Drift leaks into DI or UI layers.

**`lib/core/di/providers.dart`**

Two Riverpod codegen providers:
- `appDatabaseProvider` — `@Riverpod(keepAlive: true)`: constructs `AppDatabase.connect()`, registers `ref.onDispose(db.close)`. keepAlive prevents the DB being disposed during navigation.
- `profileRepositoryProvider` — `@riverpod`: watches `appDatabaseProvider` and returns `DriftProfileRepository(db.userProfileDao)` typed as `IProfileRepository`.

This file has zero Drift imports — it only imports `AppDatabase` (which imports Drift internally).

### Task 2: ProfileNotifier + profileStreamProvider

**`lib/features/profile/providers/profile_notifier.dart`**

`ProfileNotifier extends _$ProfileNotifier` (`AsyncNotifier<UserProfile?>`):
- `build()`: watches `profileRepositoryProvider`, calls `getProfile()`, runs `TargetCalculator.derive()` with the profile fields, returns enriched `UserProfile?` with targets attached.
- `saveProfile(UserProfile)`: sets `state = AsyncValue.loading()`, calls `repo.saveProfile()` inside `AsyncValue.guard()`, then calls `ref.invalidateSelf()` to re-run `build()` with the freshly persisted row.
- `updateField(fn)`: reads `state.value` (null-safe, returns placeholder `UserProfile(id: '')` for new profiles), applies the updater function, calls `saveProfile()`.
- `setLocaleUnits(BuildContext)`: static helper; reads `Localizations.localeOf(context).countryCode`; returns `'imperial'` for US/LR/MM, `'metric'` for all others.

`profileStreamProvider` (`@riverpod Stream<UserProfile?>`): watches `profileRepositoryProvider`, calls `repo.watchProfile()`, maps each emission through `TargetCalculator.derive()`. Plan 01-05 uses this for reactive UI updates.

Zero Drift imports in this file.

---

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `valueOrNull` not available in Riverpod 3.3.2**
- **Found during:** Task 2 — `dart analyze` after writing `profile_notifier.dart`
- **Issue:** The plan specified `state.valueOrNull` but `AsyncValue` in Riverpod 3.3.2 does not expose a `valueOrNull` getter. The available API is `state.value` which returns `T?` (`null` in loading/error states).
- **Fix:** Changed `state.valueOrNull` to `state.value` in the `updateField` method.
- **Files modified:** `lib/features/profile/providers/profile_notifier.dart`
- **Commit:** 7f64bf9

**2. [Rule 2 - Missing critical import] `UserProfileTableCompanion`/`UserProfileRow` not in scope without `app_database.dart`**
- **Found during:** Task 1 — `dart analyze` after writing `drift_profile_repository.dart`
- **Issue:** The plan listed only `user_profile_dao.dart` as the import for the DAO. However, `UserProfileTableCompanion` and `UserProfileRow` are defined in the generated `app_database.g.dart` (a `part of app_database.dart`). They are not re-exported by the DAO file alone.
- **Fix:** Added `import 'package:co2diet/data/local/app_database.dart'` to `drift_profile_repository.dart`. This is correct — the data layer is the appropriate place for this import.
- **Files modified:** `lib/data/repositories/drift_profile_repository.dart`
- **Commit:** 5a27f9f (within same task)

---

## Verification Results

| Check | Result |
|-------|--------|
| `build_runner build` exits 0 | PASS |
| `providers.g.dart` exists | PASS |
| `profile_notifier.g.dart` exists | PASS |
| `dart analyze` on repositories/ core/di/ features/profile/providers/ | PASS — No issues found |
| No Drift import in `lib/features/profile/providers/` | PASS — CLEAN |
| No Drift import in `lib/core/di/providers.dart` | PASS — CLEAN |
| `implements IProfileRepository` in DriftProfileRepository | PASS |
| `keepAlive: true` on appDatabaseProvider | PASS |
| `setLocaleUnits` returns 'imperial' for US, 'metric' for DE | PASS (code logic verified) |

---

## Known Stubs

None. All methods are fully implemented. HLC placeholders (`hlcNodeId='local'`, `hlcCounter=0`) are intentional Phase-1 values documented in the plan and in code comments — they will be replaced in Phase 7 with real HLC clock logic.

---

## Threat Flags

None. All threat model mitigations from the plan are applied:
- T-04-01 (Tampering — profile field values): `TargetCalculator.derive()` handles pathological inputs with null returns and 500–10000 kcal clamp.
- T-04-03 (Drift import leak): `dart analyze` enforces zero Drift imports in `providers.dart` and `profile_notifier.dart`.
- T-04-SC (package installs): No new packages introduced in this plan.

---

## Self-Check: PASSED

Files verified:
- `lib/data/repositories/drift_profile_repository.dart` — FOUND
- `lib/core/di/providers.dart` — FOUND
- `lib/core/di/providers.g.dart` — FOUND
- `lib/features/profile/providers/profile_notifier.dart` — FOUND
- `lib/features/profile/providers/profile_notifier.g.dart` — FOUND

Commits verified:
- `5a27f9f` — FOUND (feat(01-04): add DriftProfileRepository + appDatabaseProvider + profileRepositoryProvider)
- `7f64bf9` — FOUND (feat(01-04): add ProfileNotifier AsyncNotifier + profileStreamProvider + setLocaleUnits)

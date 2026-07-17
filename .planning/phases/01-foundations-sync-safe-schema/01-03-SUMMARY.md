---
phase: 01-foundations-sync-safe-schema
plan: "03"
subsystem: domain
tags: [dart, freezed, mifflin-st-jeor, tdee, macro-calculator, domain-layer, pure-dart]

requires:
  - phase: 01-01
    provides: Flutter scaffold, pubspec with freezed/freezed_annotation pinned
  - phase: 01-02
    provides: Drift schema and SyncSafeTable mixin patterns (domain mirrors schema columns)

provides:
  - "calculateTdee() pure Dart function with Gender/ActivityLevel enums"
  - "CalcTargets Freezed abstract class: nullable kcal/protein/carbs/fat/co2 fields + override flags"
  - "UserProfile Freezed abstract class: mirrors user_profile table with zero Drift imports"
  - "TargetCalculator.derive(): goal-specific macro ratios, TDEE safety clamp 500-10000 kcal"
  - "IProfileRepository abstract interface: getProfile()/saveProfile()/watchProfile()"
  - "9 unit tests for TDEE calculator passing"

affects:
  - phase-04-profile-screen (consumes TargetCalculator + IProfileRepository)
  - phase-05-dashboard (consumes CalcTargets for macro display)
  - phase-07-sync (data layer implements IProfileRepository)

tech-stack:
  added: []
  patterns:
    - "pure-dart-domain: domain layer has zero Flutter/Drift/Riverpod imports — testable with plain dart test"
    - "freezed-abstract-class: Freezed 3.2.6-dev.1 requires 'abstract class' with mixin (not plain 'class')"
    - "package-imports: very_good_analysis requires package: URI imports (no relative imports for lib/ files)"
    - "tdd-pure-dart: test/domain uses package:test/test.dart (not flutter_test) for platform-agnostic tests"

key-files:
  created:
    - lib/domain/services/mifflin_st_jeor.dart
    - lib/domain/services/target_calculator.dart
    - lib/domain/entities/calc_targets.dart
    - lib/domain/entities/calc_targets.freezed.dart
    - lib/domain/entities/user_profile.dart
    - lib/domain/entities/user_profile.freezed.dart
    - lib/domain/repositories/i_profile_repository.dart
    - test/domain/services/mifflin_st_jeor_test.dart
  modified: []

key-decisions:
  - "Freezed 3.2.6-dev.1 requires 'abstract class CalcTargets with _$CalcTargets' (not 'class') — mixin generates abstract getters that require abstract class or concrete subclass"
  - "TDD test file uses package:test/test.dart (not flutter_test) — pure Dart domain tests must run without Flutter engine; flutter_test pulls in dart:ui which is unavailable in plain dart test runner"
  - "TargetCalculator clamps TDEE to 500-10000 kcal (T-03-01 mitigation) — physiologically extreme inputs silently accept without clamp; Phase 6 adds visible ED safety warning (NFR-07)"
  - "avoid_print suppressed in target_calculator.dart with documented rationale — domain layer has no dart:developer without Flutter; Phase 6 replaces with structured logging"
  - "TDEE test values computed from formula (not from plan placeholder): male 75kg/175cm/30y/low = 2335.78125 (not the incorrect 2336.875 in plan)"

patterns-established:
  - "Domain layer pattern: lib/domain/ has zero Flutter/Drift imports; tested with plain dart test"
  - "Freezed 3.x abstract class pattern: source files use 'abstract class X with _$X'"
  - "Null-means-missing pattern: CalcTargets fields are nullable; null rendered as — in UI (D-07)"

requirements-completed:
  - PROF-01
  - PROF-02
  - PROF-03
  - PROF-04
  - PROF-05

duration: 8min
completed: "2026-07-17"
---

# Phase 01 Plan 03: Domain Layer (TDEE Calculator + Entities) Summary

**Pure Dart domain layer: Mifflin-St Jéor TDEE calculator (9 tests, exact formula), Freezed CalcTargets + UserProfile entities, TargetCalculator with goal-specific macro ratios and safety clamping, IProfileRepository abstract interface**

## Performance

- **Duration:** 8 min
- **Started:** 2026-07-17T09:22:47Z
- **Completed:** 2026-07-17T09:30:39Z
- **Tasks:** 2 (Task 1: TDD — 3 commits; Task 2: 1 commit)
- **Files created:** 8

## Accomplishments

- `calculateTdee()` implements Mifflin-St Jéor exactly against reference paper: male 75kg/175cm/30y/low = 2335.78125 kcal/day; 9 unit tests verify formula, null guards, gender averaging, and all 3 activity level factors
- `CalcTargets` and `UserProfile` are Freezed 3.x abstract classes with zero non-Dart imports; Freezed codegen succeeds with `dart analyze lib/domain/` clean (0 issues)
- `TargetCalculator.derive()` maps 7 goal strings to AMDR-based macro ratios, preserves D-06 override flags, and clamps output to 500–10,000 kcal (T-03-01 threat mitigation)
- `IProfileRepository` abstract interface defines the port; data layer (Phase 7) provides the adapter

## Task Commits

Each task was committed atomically:

1. **Task 1 RED: Mifflin-St Jéor tests** — `ca80377` (test)
2. **Task 1 GREEN: calculateTdee() implementation** — `12e2b4b` (feat)
3. **Task 2: Entities + TargetCalculator + IProfileRepository** — `df7c64b` (feat)

## Files Created/Modified

- `lib/domain/services/mifflin_st_jeor.dart` — Zero-import TDEE calculator; Gender and ActivityLevel enums
- `lib/domain/services/target_calculator.dart` — Goal-to-macro-ratio mapping; TDEE safety clamp (T-03-01)
- `lib/domain/entities/calc_targets.dart` — Freezed entity with nullable macro fields + override flags
- `lib/domain/entities/calc_targets.freezed.dart` — Generated by Freezed 3.2.6-dev.1
- `lib/domain/entities/user_profile.dart` — Freezed entity mirroring user_profile table columns
- `lib/domain/entities/user_profile.freezed.dart` — Generated by Freezed 3.2.6-dev.1
- `lib/domain/repositories/i_profile_repository.dart` — Abstract interface (port); no implementation
- `test/domain/services/mifflin_st_jeor_test.dart` — 9 tests using package:test (no flutter_test)

## Decisions Made

- **Freezed 3.x requires `abstract class`**: Freezed 3.2.6-dev.1 generates `mixin _$CalcTargets` with abstract getters. Declaring source class as plain `class CalcTargets with _$CalcTargets` fails analysis with "Missing concrete implementations" because the class is non-abstract but inherits abstract members. Fix: `abstract class CalcTargets with _$CalcTargets`.
- **package:test not package:flutter_test for domain tests**: `flutter_test` imports `dart:ui` which is unavailable in the plain `dart test` runner. Domain tests must use `package:test/test.dart` to remain framework-free.
- **TDEE formula correction**: Plan placeholder said 2336.875 for Test 1; manual computation gives 2335.78125. Used the correct value (750 + 1093.75 − 150 + 5 = 1698.75 BMR; × 1.375 = 2335.78125 TDEE).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] TDEE output clamped to 500–10,000 kcal (T-03-01)**
- **Found during:** Task 2 (TargetCalculator implementation)
- **Issue:** Plan's threat model T-03-01 assigns `mitigate` disposition to TargetCalculator; without a clamp, extreme anthropometric inputs (e.g., height=300cm, weight=200kg) produce physiologically implausible TDEE values silently accepted by the domain
- **Fix:** `TargetCalculator.derive()` clamps computed TDEE to [500, 10000] with a `print()` warning. Phase 6 will replace the log with a visible ED safety warning per NFR-07
- **Files modified:** `lib/domain/services/target_calculator.dart`
- **Committed in:** df7c64b

**2. [Rule 2 - Missing Critical] package:test substituted for package:flutter_test in domain test**
- **Found during:** Task 1 TDD RED phase
- **Issue:** Test initially imported `flutter_test`, causing a compile crash ("Dart library 'dart:ui' is not available on this platform") when run with `dart test`; the plan mandates `dart test` as the verification command and the domain layer must have zero Flutter dependencies
- **Fix:** Replaced import with `package:test/test.dart` — already a transitive dependency; test file remains framework-free
- **Files modified:** `test/domain/services/mifflin_st_jeor_test.dart`
- **Committed in:** ca80377 (RED), 12e2b4b (GREEN)

---

**Total deviations:** 2 auto-fixed (both Rule 2 — missing critical)
**Impact on plan:** TDEE safety clamp required by plan's own threat model; flutter_test fix required to satisfy plan's `dart test` verification command. No scope creep.

## Issues Encountered

- **Freezed 3.2.6-dev.1 abstract class requirement**: Not documented in the plan; discovered during `dart analyze`. Fixed inline (see deviations above). Pattern documented in `key-decisions` for Phase 4+ plans.
- **very_good_analysis `always_use_package_imports`**: Relative imports in `user_profile.dart` (importing `calc_targets.dart`) and `i_profile_repository.dart` (importing `user_profile.dart`) flagged as `info`. Fixed to `package:co2diet/...` URIs. No behavioral change.

## User Setup Required

None — pure Dart domain layer; no external services, no credentials, no device setup.

## Next Phase Readiness

- Domain layer is complete and clean; `dart analyze lib/domain/` exits 0 with no issues
- `IProfileRepository` port is defined; Phase 4 (Profile screen) provides the Riverpod provider; Phase 7 provides the Drift adapter
- `TargetCalculator.derive()` is ready for use by Phase 4's profile form save flow
- Remaining Phase 1 plans: 01-04 (vertical slice), 01-05 (Profile screen UI)

## Self-Check: PASSED

All 8 created files confirmed present on disk. All 3 task commits (ca80377, 12e2b4b, df7c64b) confirmed in git log.

---
*Phase: 01-foundations-sync-safe-schema*
*Completed: 2026-07-17*

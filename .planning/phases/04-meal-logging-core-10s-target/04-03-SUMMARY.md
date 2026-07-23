---
phase: 04-meal-logging-core-10s-target
plan: 03
subsystem: domain
tags: [pure-dart, sentinel-copyWith, meal-logging, domain-interfaces]

# Dependency graph
requires:
  - phase: 04-meal-logging-core-10s-target (Plan 04-02)
    provides: Minimal MealSlot/PortionUnit/ServingSize stand-in domain files to unblock Drift schema compilation
provides:
  - MealSlot/PortionUnit enums extended with displayLabel/isWeightBased extension getters + detectMealSlotForTime auto-detect function
  - MealEntry entity with pure scaledMacros/ScaledMacros live-scaling calculation (LOG-06)
  - Favorite entity for one-tap re-logging (LOG-11)
  - ServingSize finalized as authoritative round-trip JSON value object
  - UserFood entity with isValid (name + calories required, LOG-10) and per-100g rescaling getters
  - IMealEntryRepository and IUserFoodRepository domain interface contracts
affects: [04-04, 04-05, 04-06, 04-07, 04-09, 04-10]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Sentinel copyWith pattern (matching FoodItem) applied to MealEntry/Favorite/UserFood"
    - "Pure top-level function + instance-method wrapper (scaledMacros / MealEntry.scaled) for testable, DB-free live macro scaling"
    - "abstract interface class for domain repository contracts (IMealEntryRepository, IUserFoodRepository)"

key-files:
  created:
    - lib/domain/entities/meal_entry.dart
    - lib/domain/entities/favorite.dart
    - lib/domain/entities/user_food.dart
    - lib/domain/repositories/i_meal_entry_repository.dart
    - lib/domain/repositories/i_user_food_repository.dart
  modified:
    - lib/domain/entities/meal_slot.dart (extended Plan 04-02 stand-in)
    - lib/domain/entities/portion_unit.dart (extended Plan 04-02 stand-in)
    - lib/domain/entities/serving_size.dart (dropped stand-in note; already matched spec)
    - test/domain/entities/meal_entry_test.dart
    - test/domain/entities/user_food_test.dart
    - test/domain/entities/serving_size_test.dart

key-decisions:
  - "detectMealSlotForTime boundaries: <11:00 breakfast, 11:00-15:00 lunch, 15:00-18:00 snack, >=18:00 dinner (Claude's discretion per CONTEXT.md, documented in doc comment)"
  - "IMealEntryRepository.toggleFavorite contract: returns the Favorite row that now exists when newly favorited; callers must call isFavorite separately to disambiguate insert-vs-delete outcomes"
  - "ServingSize required no changes vs Plan 04-02's stand-in — only the stand-in doc-comment note was removed since this plan now owns it"

patterns-established:
  - "Cross-plan stand-in extension: when a parallel-wave plan pre-creates minimal stand-in domain files to unblock its own compilation, the owning plan reviews and extends (not overwrites) them to preserve any behavior already wired to committed schema (e.g. ServingSize's TypeConverter usage)"

requirements-completed: [LOG-05, LOG-06, LOG-08, LOG-10, LOG-11]

# Metrics
duration: ~15min
completed: 2026-07-23
---

# Phase 04 Plan 03: Meal Logging Domain Layer Summary

**Pure-Dart MealEntry/Favorite/ServingSize/UserFood entities (sentinel copyWith, no Drift/Flutter-widget imports) plus IMealEntryRepository/IUserFoodRepository domain interfaces, extending Plan 04-02's minimal MealSlot/PortionUnit/ServingSize stand-ins into their authoritative versions.**

## Performance

- **Duration:** ~15 min
- **Completed:** 2026-07-23
- **Tasks:** 2 completed
- **Files modified:** 11 (5 created, 6 modified/extended)

## Accomplishments
- Extended Plan 04-02's `MealSlot`/`PortionUnit` stand-ins with `displayLabel` extension getters, `isWeightBased` getter, and the shared `detectMealSlotForTime` time-of-day auto-detect function (single implementation reused by later Plan 04-09/04-10)
- `MealEntry` entity mirrors `FoodItem`'s sentinel `copyWith` pattern, with a pure `scaledMacros`/`ScaledMacros` live-scaling calculation — null snapshot fields always scale to `null`, never a fabricated `0`
- `Favorite` and `UserFood` entities added with the same sentinel `copyWith` pattern; `UserFood.isValid` enforces LOG-10 (name + calories only); per-100g rescaling getters correctly account for `referenceAmountG != 100`
- `ServingSize` reviewed against this plan's spec — Plan 04-02's stand-in already fully matched the round-trip + malformed-input contract, so only the stand-in doc-comment note was removed
- `IMealEntryRepository` (meal-entry + favorite concerns) and `IUserFoodRepository` (custom food + override concerns) domain interfaces added exactly matching the plan's method contracts
- All three Wave 0 test stubs (`meal_entry_test.dart`, `user_food_test.dart`, `serving_size_test.dart`) unskipped and now pass with 0 skips
- Verified no file in this plan imports `package:drift` or any Flutter widget package

## Task Commits

1. **Task 1: MealSlot, PortionUnit enums, MealEntry entity, IMealEntryRepository** - `37d71de` (feat)
2. **Task 2: Favorite, ServingSize, UserFood entities, IUserFoodRepository** - `c504a7e` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified
- `lib/domain/entities/meal_slot.dart` - Extended: `displayLabel` extension getter + `detectMealSlotForTime` function
- `lib/domain/entities/portion_unit.dart` - Extended: `displayLabel` + `isWeightBased` extension getters
- `lib/domain/entities/meal_entry.dart` - `MealEntry` entity (sentinel copyWith, id-based equality) + `ScaledMacros` value object + pure `scaledMacros` function
- `lib/domain/entities/favorite.dart` - `Favorite` entity (sentinel copyWith, id-based equality)
- `lib/domain/entities/serving_size.dart` - Finalized (stand-in note removed; behavior unchanged)
- `lib/domain/entities/user_food.dart` - `UserFood` entity with `isValid`, `isOverride`, per-100g rescaling getters
- `lib/domain/repositories/i_meal_entry_repository.dart` - `IMealEntryRepository` (logOrMerge, getEntriesForToday, getRecent, editEntry, deleteEntry, restoreEntry, duplicateEntry, undoMergeDelta, isFavorite, toggleFavorite, getFavorites, touchFavoriteUsage)
- `lib/domain/repositories/i_user_food_repository.dart` - `IUserFoodRepository` (saveCustomFood, saveOverride, revertOverride, findOverrideForFoodRef, getAllAlphabetical, getById)
- `test/domain/entities/meal_entry_test.dart` - Real tests replacing Wave 0 skip (copyWith sentinel, scaled macros incl. null-safety, id equality)
- `test/domain/entities/user_food_test.dart` - Real tests replacing Wave 0 skip (copyWith sentinel, isValid, per-100g rescaling, id equality)
- `test/domain/entities/serving_size_test.dart` - Real tests replacing Wave 0 skip (round-trip, null/malformed-input handling)

## Decisions Made
- **`detectMealSlotForTime` boundaries:** before 11:00 → breakfast, 11:00–15:00 → lunch, 15:00–18:00 → snack, 18:00 onward → dinner. Documented directly on the function's doc comment per the plan's instruction that exact cutoffs were Claude's discretion.
- **`IMealEntryRepository.toggleFavorite` contract:** returns the `Favorite` row that now exists after the toggle (i.e. the row when newly inserted); the boolean insert-vs-delete outcome is left to a separate `isFavorite` call, documented in the interface's doc comment per the plan's explicit ambiguity-resolution instruction.
- **`ServingSize` required no code changes:** Plan 04-02's stand-in already implemented `toJson`/`fromJson`/`encodeList`/`decodeList` with the exact round-trip and malformed-input (`FormatException` → `[]`) behavior this plan's `<behavior>` block specifies. Only the "STAND-IN NOTE" doc comment was removed since this plan now owns the file.

## Deviations from Plan

None - plan executed exactly as written. The cross-plan stand-in review (explicitly anticipated by the plan's `<important_context>`) required extending `meal_slot.dart`/`portion_unit.dart` (as expected) and confirmed `serving_size.dart` needed no behavioral changes (also anticipated).

## Issues Encountered
- `flutter analyze` initially flagged `comment_references` info-level lints for doc-comment brackets referencing not-yet-imported types (`[FoodItem]`, `[UserFood]`, `[MealEntryTable]`, `[MealEntry]` in `favorite.dart`) and two `lines_longer_than_80_chars` info lints. Fixed by converting cross-file type references in doc comments to backticks (non-linked) instead of square brackets, and wrapping long lines — resolved within the same task commits, not a separate fix-up commit.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `IMealEntryRepository`/`IUserFoodRepository` are ready for Plan 04-04 (DAOs) and Plan 04-05 (repository implementations) to implement against.
- `MealEntry.scaled`/`scaledMacros` and `detectMealSlotForTime` are ready for Plan 04-07 (notifiers) and Plan 04-09/04-10 (UI) to consume directly.
- No blockers. `flutter analyze lib/domain/` shows 0 issues in all files this plan created/modified; the 5 remaining info-level lints in `lib/domain/` belong to pre-existing `food_item.dart`/`i_food_catalog_repository.dart`, outside this plan's scope.

---
*Phase: 04-meal-logging-core-10s-target*
*Completed: 2026-07-23*

## Self-Check: PASSED

All created/modified files exist on disk; both task commits (`37d71de`, `c504a7e`) verified present in `git log`.

---
resolved: 2026-09-08
created: 2026-09-08T00:05:00Z
title: Manual target overrides never persist (PROF-05 has never worked)
area: data
severity: high
requirement: PROF-05
files:
  - lib/data/repositories/drift_profile_repository.dart
  - lib/data/local/tables/user_profile_table.dart
  - lib/features/profile/screens/profile_screen.dart
---

## Problem

`PROF-05` — "User can manually edit any auto-calculated target" — is marked
`[x]` complete in `REQUIREMENTS.md` and `Complete` in the traceability table.
It has never worked.

Setting a custom target through the Daily Targets override dialog updates the
in-memory `UserProfile`, but the value is never written to the database. On the
next `ref.invalidateSelf()` — which `saveProfile` calls immediately — `build()`
re-reads the row and recomputes targets from height/weight/age/goal, discarding
the override.

Verified on device 2026-09-08: entering `99999` for Calories and tapping Save
leaves the card reading `1800 kcal`, and the row reads:

```
kcal_target  kcal_is_overridden
-----------  ------------------
(empty)      0
```

## Cause

`DriftProfileRepository.saveProfile` builds its `UserProfileTableCompanion`
from only the anthropometric and lifestyle fields:

```dart
final companion = UserProfileTableCompanion(
  id: ..., age: ..., gender: ..., heightCm: ..., weightKg: ...,
  activityLevel: ..., dietaryPreference: ..., goal: ..., units: ...,
  co2MethodologyVersion: ..., localeTag: ..., updatedAt: ...,
  // HLC placeholders
);
```

No `kcalTarget`, `proteinGTarget`, `carbsGTarget`, `fatGTarget`, and none of
the four `*IsOverridden` flags. `_rowToProfile` does not read them back either.

The columns **do** exist in `user_profile_table.dart` — so the schema
anticipated this and the persistence layer was never wired to it.

## Why it went unnoticed

The crash masked it. Until `e1f0fd7`/the dialog fix on 2026-09-08, tapping Save
crashed the app with a `TextEditingController` disposal fault, so nobody ever
got far enough to observe that the value failed to stick. Fixing the crash is
what exposed this.

## What to decide before fixing

1. **Write and read the columns** in `DriftProfileRepository` — the mechanical
   part.
2. **What happens to an override when the inputs change?** If the user
   overrides Calories to 2200 and later edits their weight, does the override
   survive, or does the recalculation win? The `*IsOverridden` flags exist
   precisely to answer this, so the intended semantics are presumably "override
   wins until explicitly reset" — but that should be confirmed, not assumed.
3. **Where does the merge happen?** `build()` currently computes targets from
   scratch. It needs to compute, then re-apply any stored overrides on top.
   `_applyOverride`/`_clearOverride` in `profile_screen.dart` already encode the
   shape.

## Test first

A repository round-trip test would fail today: save a profile with
`kcalTarget: 2200, kcalIsOverridden: true`, read it back, assert both survive.
Then a notifier test asserting an override survives `invalidateSelf()` and is
not overwritten by recalculation.

## Requirement status

`PROF-05` should not read Complete until this is fixed. It is currently
asserting a capability the app does not have.

---

## Resolved — 2026-09-08

**Smaller than it looked.** Two of the three pieces already existed:

- The schema had every column (`kcal_target`, `kcal_is_overridden`, and the
  macro equivalents) from Phase 1.
- `TargetCalculator.derive` already implemented the merge — its step 8 keeps
  the user's value for any field whose override flag is set, and recalculates
  the rest.

Only the persistence layer between them was missing.
`DriftProfileRepository.saveProfile` built its companion without the target
columns, and `_rowToProfile` did not read them back — so the
`existingTargets` argument that `derive()` depends on was permanently null.
The feature was wired at both ends and disconnected in the middle.

**Fix.** `saveProfile` now writes all five target values and all four override
flags; `_rowToProfile` reads them back into a `CalcTargets` and attaches it to
the returned `UserProfile`. No schema change, no migration, no change to
`derive()`.

**The open question in the section above answered itself.** `CalcTargets`'
own doc comment already specifies the semantics — *"When an override is
active the value must be preserved even if other profile fields change"* —
and `derive()` implements exactly that. Nothing needed deciding.

**Tests.** `test/data/repositories/profile_targets_persistence_test.dart` —
six cases: single override round trip, all macros independently (including
that a *false* flag round-trips as false, so recalculation is not permanently
suppressed), a profile with no targets, clearing an override, an override
surviving a weight change while non-overridden macros track it, and a direct
guard on the read path that was broken. Four of the six failed before the fix.

**Requirement.** PROF-05 is now genuinely met rather than nominally complete.

---

## Second defect, found on device after the first fix

Persisting the columns was necessary but **not sufficient**. Setting a 2200 kcal
override succeeded and stored correctly — then editing the weight field wiped
it: `kcal_target` empty, `kcal_is_overridden` back to 0.

Cause was upstream, in `TargetCalculator.derive` step 4:

```dart
if (rawKcal == null) {
  return const CalcTargets();   // discards existingTargets entirely
}
```

`ProfileForm` auto-saves on **every keystroke**, so while retyping a weight the
field is legitimately empty for at least one frame. On that frame `weightKg` is
null, TDEE is uncomputable, `derive()` returned a blank `CalcTargets`, and the
next keystroke persisted the blank. The override was destroyed by the act of
editing any other field.

**Fix.** The early return now preserves overridden values and their flags while
still dropping calculated ones — a stale computed figure for a body the profile
no longer describes would be false precision (D-07), but a manual override is
the user's own data and is not derived from the missing input.

**Why the unit tests missed it.** The first round of tests exercised
save → read → derive with *complete* inputs. The failure only appears in the
transient state during typing, which no test simulated. Three cases now cover
it, including one that replays the actual keystroke sequence
(cleared → partial → complete) through storage.

**Lesson worth keeping:** the device found this within a minute of the unit
tests going green. Both fixes in this todo were verified as correct by tests
that were asking the wrong question — the first about whether columns persist,
the second about whether they persist under realistic input timing.

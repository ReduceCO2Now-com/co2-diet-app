---
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

---
created: 2026-09-07T23:35:00Z
title: Imperial units — height not converted, every calculated target is wrong
area: domain
severity: high
files:
  - lib/features/profile/widgets/profile_form.dart
  - lib/features/profile/screens/profile_screen.dart
  - lib/domain/services/mifflin_st_jeor.dart
  - lib/domain/services/target_calculator.dart
  - lib/domain/entities/user_profile.dart
---

## Problem

With units set to **Imperial (lb, ft+in)**, the Profile screen shows:

```
Height:  156  ft     (plus a separate "0 in" field)
Weight:  62.0 lb
```

156 feet. The stored value is being labelled with the imperial unit without
being converted into it — the number is displayed raw while the unit symbol
changes underneath it.

The consequence is not cosmetic. At app start, on a real device:

```
I/flutter: [TargetCalculator] WARN: rawKcal=40855.68718
           clamped to [500.0, 10000.0]. Phase 6 will surface ED safety
           warning (NFR-07).
```

A BMR of ~40,855 kcal, clamped to the 10,000 ceiling. So the Daily Targets
shown to an Imperial user are not merely mis-labelled — they are **computed
from a body roughly 30× too tall**, then silently clamped. Every downstream
number inherits it: calories, protein, carbs, fat, and the CO₂ budget derived
from the calorie target.

Observed on Samsung SM-T733 (Android 14), main @ 05548f1, 2026-09-07, during
the device re-test of the Daily Targets crash session.

## Why it matters

- **PROF-02** ("user can select metric or imperial units; default auto-detected
  from device locale") is marked complete but is not correct for imperial.
- **PROF-04** (auto-calculated daily targets) produces garbage for these users.
- The clamp *hides* the failure. Instead of an obviously-wrong 40,855 the user
  sees a plausible-looking 10,000 — wrong, but not self-evidently so.
- It trips the ED safety net (NFR-07) for a reason that has nothing to do with
  the user's actual intent, which is the worst kind of false positive in a
  feature designed around not alarming people.
- US locale auto-detection means real users land in this state without ever
  choosing imperial.

## What to check

1. Where the unit toggle is applied — is the conversion at display time, at
   save time, at read time, or inconsistently split across them?
2. Whether `UserProfile` stores canonical metric with conversion at the
   boundary (the correct design) or stores whatever the active unit produced.
3. The `ft` + `in` pair: two fields feeding one canonical height. Confirm both
   are read and combined, not just the `ft` field.
4. Whether weight has the same fault. "62.0 lb" for this profile looks like the
   same raw-number-relabelled pattern, but it wasn't independently verified.
5. Whether the clamp should log louder — a value 4× above the ceiling is a bug
   signal, not a user with unusual targets.

## Likely related

The `RenderFlex` overflow on the Calories card (separate todo, same date) is
probably downstream of this: the clamped **10000** is a five-digit string in a
`Row` that fits four. Fix the units first, then re-check whether the overflow
still reproduces with a realistic target.

## Not yet done

No fix attempted. No failing test written yet — a unit test over the
conversion boundary (metric in → imperial display → metric out, round-trip)
would be the natural first step and would fail today.

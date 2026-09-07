---
created: 2026-09-07T23:35:00Z
title: TargetDisplayCard Row overflows on wide values
area: ui
severity: low
files:
  - lib/features/profile/widgets/target_display_card.dart:66
---

## Problem

Rendering the Profile screen throws during layout:

```
══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞════════════════════════════
The following assertion was thrown during layout:
A RenderFlex overflowed by 5.6 pixels on the right.

The relevant error-causing widget was:
  Row
  Row:.../lib/features/profile/widgets/target_display_card.dart:66:15
```

On-device this shows as the yellow/black overflow banner across the Calories
card in the Daily Targets grid. It fires on render, before any interaction.

Observed on Samsung SM-T733 (Android 14), main @ 05548f1, 2026-09-07.

## Cause

The value `Row` uses `mainAxisSize: MainAxisSize.min` with an unconstrained
`Text` child:

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    if (value != null)
      Text('${value!.toStringAsFixed(0)} $unit', ...)
```

Nothing constrains the text to the card's width, so a long enough value string
pushes past it. The card was presumably sized against three- and four-digit
targets.

## Fix

Wrap the `Text` in `Flexible` (with `overflow: TextOverflow.ellipsis`, or
`FittedBox` if truncating a number is unacceptable — a partially shown calorie
figure is arguably worse than a shrunken one).

## Check the cause before fixing the symptom

The value that overflows today is **10000 kcal**, and that number is itself a
bug — see the imperial-units todo of the same date. An Imperial profile has its
height mis-converted, producing a BMR of ~40,855 kcal which is clamped to the
10,000 ceiling.

So there are two questions, and they want answering in this order:

1. Does a realistic target still overflow? Fix the units bug, re-check.
2. Regardless, should this card survive an unexpectedly wide value at all?
   Probably yes — the card should not be able to throw during layout because a
   number was larger than expected.

Worth doing (2) anyway as defence, but don't let it mask (1).

## Test

A widget test pumping `TargetDisplayCard` with a deliberately wide value
(`99999` at a large text scale) inside a narrow constraint would fail today and
guard the fix. The project has an established ACC-02 overflow-test pattern —
see `legal_consent_screen_test.dart` and
`connectivity_choice_screen_test.dart`.

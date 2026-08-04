---
phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
plan: 03
subsystem: safety
tags: [ed-safety-net, nfr-07, bmi, calorie-target, alertdialog, url_launcher, profile, weight-tracking]

# Dependency graph
requires:
  - phase: 06-01
    provides: ed_safety_net_checker_test.dart Wave 0 skipped stub (group-level skip, 6 placeholder cases)
provides:
  - "EdSafetyNetChecker (pure Dart) — calorieTargetIsUnsafe/bmiIsUnsafe threshold logic, unit-tested"
  - "EdSafetyNetResources — const BZgA/ANAD e.V./international helpline entries"
  - "showEdSafetyNetDialog() shared blocking modal (calorieTarget/bmi trigger types)"
  - "showHelplineResourcesSheet() standalone always-visible info sheet for Legal Hub (Plan 06-08 consumer)"
  - "ProfileScreen kcal-override save flow gated by the ED safety-net check, with re-warn-on-different-value semantics"
  - "WeightScreen target-weight field gated by the same check, reading heightCm from profileProvider"
  - "ProfileScreen's unconditional 'stored only on this device' footer"
affects: [06-08-legal-hub-consent-history, 06-09-router-settings-integration]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Shared threshold+dialog component consumed from two independent screens (RESEARCH.md Pattern 4) rather than duplicating logic"
    - "Submit-on-blur/submit TextEditingController pattern with an in-flight guard to prevent EditableText's dual onEditingComplete+onFieldSubmitted firing from double-invoking an async handler"
    - "In-memory 'last confirmed unsafe value' re-warn tracking (no persistence, zero-analytics)"

key-files:
  created:
    - lib/domain/services/ed_safety_net_checker.dart
    - lib/core/widgets/ed_safety_net_dialog.dart
  modified:
    - lib/features/profile/screens/profile_screen.dart
    - lib/features/weight/screens/weight_screen.dart
    - test/domain/services/ed_safety_net_checker_test.dart

key-decisions:
  - "showEdSafetyNetDialog returns bool (never null) — declining/dismissing both resolve to false so callers never null-check"
  - "barrierDismissible: false on the safety-net AlertDialog — tapping outside must not silently skip the warning without an explicit choice"
  - "WeightScreen's target-weight field switched from raw onChanged auto-save to a TextEditingController + submit-in-flight guard, since Flutter's EditableText fires both onEditingComplete and onFieldSubmitted for one 'Done' action"

patterns-established:
  - "EdSafetyNetChecker/EdSafetyNetResources as the single source of truth for ED safety thresholds and helpline data — any future trigger point must call through this service, never duplicate the 1200 kcal / 17.5 BMI constants"

requirements-completed: [NFR-07, ONBD-04]

# Metrics
duration: ~15min
completed: 2026-08-04
---

# Phase 6 Plan 03: ED Safety Net Checker + Dialog Summary

**Shared EdSafetyNetChecker/EdSafetyNetDialog component wired into ProfileScreen's calorie-target override and WeightScreen's target-weight field, with re-warn-once semantics and zero trigger logging.**

## Performance

- **Duration:** ~15 min
- **Started:** 2026-08-04T07:08:59Z
- **Completed:** 2026-08-04T07:17:37Z
- **Tasks:** 3
- **Files modified:** 5

## Accomplishments
- Pure-Dart `EdSafetyNetChecker` with a 1200 kcal calorie floor and 17.5 BMI floor, unit-tested with 6 passing cases (zero skips)
- `EdSafetyNetResources` const helpline data (BZgA, ANAD e.V., international `findahelpline.com` fallback) — correctly distinguishing German `anad.de` from the unrelated US `anad.org` per RESEARCH.md Pitfall 7
- One shared `showEdSafetyNetDialog()` blocking modal + `showHelplineResourcesSheet()` standalone info sheet, both consuming the same resource list
- `ProfileScreen`'s calorie-target override save flow now gated by the checker; re-saving an already-confirmed unsafe value doesn't re-prompt, a different unsafe value does
- `WeightScreen`'s target-weight field converted from per-keystroke auto-save to a submit/blur-triggered save gated by the same checker, reading height from `profileProvider` (missing height silently skips the BMI check)
- `ProfileScreen`'s unconditional "Your profile is stored only on this device." footer

## Task Commits

1. **Task 1: EdSafetyNetChecker + helpline resources** - `2e9bc4d` (feat)
2. **Task 2: EdSafetyNetDialog widget + wire into ProfileScreen** - `de6d8e3` (feat)
3. **Task 3: Wire BMI check into WeightScreen's target-weight field** - `4023eea` (feat)

**Plan metadata:** (this commit)

## Files Created/Modified
- `lib/domain/services/ed_safety_net_checker.dart` - `EdSafetyNetChecker.calorieTargetIsUnsafe`/`bmiIsUnsafe` + `EdSafetyNetResources` const helpline entries
- `lib/core/widgets/ed_safety_net_dialog.dart` - `showEdSafetyNetDialog()` shared modal + `showHelplineResourcesSheet()` standalone sheet + `_HelplineResourceList` tappable resource rows (tel:/url_launcher)
- `lib/features/profile/screens/profile_screen.dart` - `_lastConfirmedUnsafeKcal` state, async override-save flow gated by the checker, unconditional Local Mode footer
- `lib/features/weight/screens/weight_screen.dart` - `TextEditingController`-based target-weight field, `_handleTargetWeightSubmit`/`_doHandleTargetWeightSubmit` with a submit-in-flight guard, `_lastConfirmedUnsafeWeightKg` state, `profileProvider` read for `heightCm`
- `test/domain/services/ed_safety_net_checker_test.dart` - Un-skipped Plan 06-01's stub group, 6 real behavior cases

## Decisions Made
- `showEdSafetyNetDialog` always returns a non-null `bool` (declining or dismissing the barrier both resolve to `false`) — simplifies every call site to `if (!confirmed) return;` with no null-check needed.
- `barrierDismissible: false` on the safety-net dialog — an accidental outside-tap must not silently bypass the warning without recording an explicit choice (still not a hard block per NFR-07's "warning + resource" wording — "Go back and revise" or "I understand, continue" are the only two ways to close it).
- Discovered during Task 3 that Flutter's `EditableText._finalizeEditing` invokes **both** `onEditingComplete` and `onFieldSubmitted` for a single keyboard "Done" action (verified directly in the Flutter SDK source, `editable_text.dart`). Wiring both to `_handleTargetWeightSubmit()` as the plan specified would have shown the modal twice per submit. Fixed with a `_submitInFlight` guard (Rule 1 — bug auto-fixed, not a plan deviation requiring a separate write-up since it's within Task 3's own scope).

## Deviations from Plan

None requiring a written deviation — the one behavioral fix (submit-in-flight guard against Flutter's dual onEditingComplete/onFieldSubmitted firing) was applied inline within Task 3's own implementation before commit, per Rule 1 (auto-fix bugs), and is documented above under Decisions Made since it doesn't change any file outside Task 3's declared scope.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `EdSafetyNetResources`/`showHelplineResourcesSheet()` are ready for Plan 06-08's Legal Hub "Concerned about eating or your relationship with food?" standalone entry point — no further plumbing needed, just a tap target calling `showHelplineResourcesSheet(context)`.
- **Pre-launch blocker (not a Phase 6 completion blocker):** BZgA/ANAD e.V./`findahelpline.com` phone numbers and URLs were verified via WebSearch against apparent official domains this session but not independently confirmed by phone call (RESEARCH.md Assumption A4 / Pitfall 7). Flagged in the source file's doc comment; needs human verification before real store submission — a wrong crisis-line number is a real-world harm vector.
- `ProfileScreen`/`WeightScreen` are still not reachable from `app_router.dart`'s onboarding flow or bottom nav in this plan's scope — that wiring is Plan 06-09's job, consistent with every other Phase 5/6 screen built ahead of its router integration plan.

---
*Phase: 06-onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission*
*Completed: 2026-08-04*

## Self-Check: PASSED

All 5 created/modified files verified present on disk; all 3 task commits (`2e9bc4d`, `de6d8e3`, `4023eea`) verified present in git history.

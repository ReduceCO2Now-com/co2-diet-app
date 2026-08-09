---
phase: 07-keycloak-auth-account-mode-sync
plan: 07
subsystem: ui
tags: [riverpod, drift, shared_preferences, flutter, dashboard, co2-methodology]

# Dependency graph
requires:
  - phase: 07-keycloak-auth-account-mode-sync (Plan 07-04)
    provides: MethodologyVersionChecker (pure staleness comparison) + currentCo2MethodologyVersion constant
provides:
  - hasStaleMethodologyEntriesProvider (real DB reads across profile/meal/food tables composed with the pure checker)
  - MethodologyBannerDismissalNotifier (keepAlive, per-version SharedPreferences dismissal)
  - showMethodologyBannerProvider (single composed bool the banner watches)
  - Co2MethodologyBanner widget wired into PlaceholderDashboardScreen, above ModeIndicator
affects: [dashboard, co2-methodology]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Whole-table DB scans composed at the provider layer (not a dedicated repository method) mirroring BackupExportService's established precedent for cross-table reads with no single-feature home"
    - "keepAlive Notifier for dismissal state mutated from a widget callback that may outlive its watcher (OnboardingGateNotifier precedent, [Phase 06-05])"

key-files:
  created:
    - lib/features/dashboard/providers/methodology_banner_provider.dart
    - lib/features/dashboard/widgets/co2_methodology_banner.dart
  modified:
    - lib/features/dashboard/screens/placeholder_dashboard_screen.dart
    - test/features/dashboard/widgets/co2_methodology_banner_test.dart

key-decisions:
  - "Generated provider name is methodologyBannerDismissalProvider, not methodologyBannerDismissalNotifierProvider -- @riverpod strips the Notifier suffix from the class name (same convention as [Phase 06-05]/[Phase 06-07]/[Phase 06-09]'s onboardingGateProvider/consentProvider)"
  - "Banner copy uses the subscript CO2 character ('CO₂ estimates updated...') matching this codebase's established display convention ([Phase 05-11] precedent), not the plain-2 ASCII rendering in PLAN.md prose"
  - "Test helper `wrap()` takes named optional params (showBanner/hasStaleEntries) rather than a raw override list -- `Override` is not a publicly exported riverpod type usable as an explicit parameter type (established [Phase 07-05] auth_screen_test.dart precedent, extended to this test's two independent staleness axes)"

requirements-completed: [CO2-04]

duration: ~15min
completed: 2026-08-09
---

# Phase 07 Plan 07: CO2 Methodology-Update Announcement Banner Summary

**Wired `MethodologyVersionChecker` to real Drift DB reads (profile/meal/food DAOs) and a dismissible, per-version-persisted Dashboard banner -- completing CO2-04's local-only mechanism end-to-end while staying dormant this phase since `currentCo2MethodologyVersion` is never bumped.**

## Performance

- **Duration:** ~15 min
- **Tasks:** 2 completed
- **Files modified:** 5 (2 created, 1 generated, 2 modified)

## Accomplishments

- `hasStaleMethodologyEntriesProvider` scans `UserProfileDao.getProfile()`, `MealEntryDao.getAllEntries()`, and `UserFoodDao.getAllAlphabetical()`, feeding all three version fields into `MethodologyVersionChecker().hasAnyStale(...)`
- `MethodologyBannerDismissalNotifier` persists the last-dismissed methodology version to `SharedPreferences` (per-version, not global -- a future real version bump reopens the banner)
- `showMethodologyBannerProvider` composes both into the single bool `Co2MethodologyBanner` needs
- `Co2MethodologyBanner` widget built (Material card + InkWell + dismiss IconButton, mirroring `Co2ProfilePromptCard`), wired into `PlaceholderDashboardScreen` above `ModeIndicator`
- `co2_methodology_banner_test.dart`'s `skip:` marker removed; all 5 named test cases from the Plan 07-01 stub implemented and green (dormant-state, staleness render, dismiss persistence, per-version reappear, Learn-more navigation)

## Task Commits

Each task was committed atomically:

1. **Task 1: methodology_banner_provider.dart (DB reads + per-version dismissal)** - `2fe78d5` (feat)
2. **Task 2: Co2MethodologyBanner widget + Dashboard wiring + turn test green** - `701d7c9` (feat)

**Plan metadata:** committed in this same response (see below)

## Files Created/Modified

- `lib/features/dashboard/providers/methodology_banner_provider.dart` - `hasStaleMethodologyEntriesProvider`, `MethodologyBannerDismissalNotifier`, `showMethodologyBannerProvider`
- `lib/features/dashboard/providers/methodology_banner_provider.g.dart` - riverpod codegen output
- `lib/features/dashboard/widgets/co2_methodology_banner.dart` - the dismissible banner widget
- `lib/features/dashboard/screens/placeholder_dashboard_screen.dart` - `Co2MethodologyBanner()` wired in above `ModeIndicator`
- `test/features/dashboard/widgets/co2_methodology_banner_test.dart` - 5 green widget tests, zero skips

## Decisions Made

- Generated provider name is `methodologyBannerDismissalProvider` (Notifier suffix stripped by `@riverpod`), not `methodologyBannerDismissalNotifierProvider` as PLAN.md's prose named it -- consistent with the established [Phase 06-05]/[Phase 06-07]/[Phase 06-09] Notifier-suffix-stripping convention.
- Banner body copy uses `CO₂` (subscript character) rather than the ASCII `CO2` used in PLAN.md's literal prose -- matches every other user-facing CO2 label in this codebase ([Phase 05-11] precedent).
- Test file's `wrap()` helper uses named optional params (`showBanner`, `hasStaleEntries`) instead of accepting a raw `List<Override>` -- `Override` isn't a publicly exported riverpod type, so an explicit parameter type isn't possible (established `auth_screen_test.dart` / `legal_consent_screen_test.dart` precedent).

## Deviations from Plan

None - plan executed exactly as written. All three decisions above are direct applications of pre-existing project conventions (Notifier-suffix-stripping, CO₂ display convention, non-exported-type test-authoring pattern), not corrections to broken/missing functionality.

## Issues Encountered

- Initial widget test draft hit two easily-resolved authoring issues before reaching green: (1) `List<Override>` isn't a valid explicit parameter type since `Override` isn't publicly exported by `riverpod`/`flutter_riverpod` -- resolved via named optional params; (2) `tester.tap(find.byType(InkWell))` was ambiguous (Flutter's `InkWell`/`InkResponse` internals register two matching elements) -- resolved by tapping the banner's own text content instead. Both fixed during Task 2's RED/GREEN iteration, no production code impact.

## User Setup Required

None - no external service configuration required. Entirely local (SQLite + SharedPreferences), zero network.

## Next Phase Readiness

- CO2-04's local-only methodology-announcement mechanism is fully built and tested end-to-end: DB scan → staleness check → dismissible banner → per-version persistence. Dormant for real users until a future release bumps `currentCo2MethodologyVersion` -- at that point no new screens or plumbing are needed, just the constant change.
- This was the last plan in Phase 7's Wave 3 depending on Plan 07-04's `MethodologyVersionChecker`. No blockers for subsequent Phase 7 plans or Phase 8.

---
*Phase: 07-keycloak-auth-account-mode-sync*
*Completed: 2026-08-09*

## Self-Check: PASSED

All created/modified files verified present on disk; both task commit hashes (`2fe78d5`, `701d7c9`) verified present in git history.

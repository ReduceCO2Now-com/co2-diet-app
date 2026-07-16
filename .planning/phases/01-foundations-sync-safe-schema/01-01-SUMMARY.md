---
phase: 01-foundations-sync-safe-schema
plan: "01"
subsystem: ui
tags: [flutter, drift, riverpod, go_router, theme, fonts, pubspec, material3]

requires: []
provides:
  - Flutter project skeleton (com.reduceco2now.co2diet) with all Phase 1 deps
  - pubspec.yaml at verified versions; drift 2.34.2, flutter_riverpod 3.3.2, go_router 17.3.0
  - Plus Jakarta Sans and Inter bundled as local TTF assets (6 files)
  - ThemeData.light() and ThemeData.dark() from DESIGN.md tokens verbatim
  - ProviderScope at MaterialApp root
  - lib/core/theme/ module with 4 files: app_theme, color_tokens, text_tokens, spacing_tokens
affects:
  - 01-02-PLAN (imports from lib/core/theme; adds Drift schema on top of this scaffold)
  - all subsequent Phase 1 plans (consume pubspec + theme)

tech-stack:
  added:
    - drift 2.34.2 + drift_flutter 0.3.1
    - flutter_riverpod 3.3.2 + riverpod_annotation 4.0.3
    - go_router 17.3.0
    - uuid 4.6.0, intl 0.20.2, freezed_annotation 3.1.0, path_provider ^2.1.6
    - very_good_analysis 10.3.0 (strict lint rules)
    - freezed 3.2.6-dev.1, drift_dev 2.34.0, build_runner 2.15.1, riverpod_generator 4.0.4
    - riverpod_lint 3.1.4 (via analysis_server_plugin, no custom_lint)
  patterns:
    - "ProviderScope at root: runApp(const ProviderScope(child: Co2DietApp()))"
    - "Package imports everywhere: always_use_package_imports enforced by very_good_analysis"
    - "Token files use // ignore_for_file: public_member_api_docs with reason comment"
    - "Material 3 dark mode: inverseSurface as primary canvas, inversePrimary as accent"

key-files:
  created:
    - pubspec.yaml
    - pubspec.lock
    - analysis_options.yaml
    - lib/main.dart
    - lib/app.dart
    - lib/core/theme/app_theme.dart
    - lib/core/theme/color_tokens.dart
    - lib/core/theme/text_tokens.dart
    - lib/core/theme/spacing_tokens.dart
    - assets/fonts/PlusJakartaSans-{Regular,Medium,SemiBold,Bold}.ttf
    - assets/fonts/Inter-{Regular,SemiBold}.ttf
    - test/core/theme/theme_token_test.dart
  modified:
    - test/widget_test.dart (updated from default counter test to Co2DietApp smoke test)

key-decisions:
  - "freezed 3.2.6-dev.1 selected over 3.2.5 stable — 3.2.5 requires analyzer >=9 <11 which conflicts with riverpod_lint 3.1.4 (^12); dev.1 aligns with ^12"
  - "custom_lint removed — riverpod_lint 3.1.4 migrated from custom_lint to analysis_server_plugin; the two packages analyzer constraints (^8 vs ^12) are mutually exclusive"
  - "drift_dev 2.34.0 used (not 2.34.4) — 2.34.4 requires analyzer ^13 conflicting with riverpod_generator 4.0.4 (^12)"
  - "build_runner 2.15.1 used (not 2.15.2) — 2.15.2 requires analyzer >=13.3 conflicting with riverpod_generator 4.0.4 (^12)"
  - "intl pinned to 0.20.2 — flutter_localizations SDK pins it there; the RESEARCH.md 0.20.3 is unavailable when flutter_localizations is present"
  - "Font TTFs downloaded via fonts.googleapis.com CSS API + gstatic static URLs and committed to git (privacy: no google_fonts network calls at runtime)"
  - "themeMode: ThemeMode.system removed as a redundant argument (very_good_analysis avoid_redundant_argument_values); ThemeMode.system is the Flutter default"

patterns-established:
  - "Token files use // ignore_for_file with a reason comment one line above the pragma"
  - "ColorScheme constructors: explicit on-color args even when matching defaults, suppressed via ignore_for_file: avoid_redundant_argument_values with reason"
  - "Material 3 dark theme: inverseSurface (0xFF2F3133) as surface, inverseOnSurface (0xFFF0F0F3) as onSurface, inversePrimary (0xFF7FDA8F) as primary"

requirements-completed: [PROF-01, PROF-02, PROF-03, PROF-04, PROF-05]

duration: 17min
completed: "2026-07-16"
---

# Phase 01 Plan 01: Flutter Scaffold + Theme Summary

**Flutter project scaffolded (com.reduceco2now.co2diet) with all Phase 1 deps, Plus Jakarta Sans/Inter bundled as local TTF assets, and Material 3 ThemeData light+dark built verbatim from DESIGN.md color tokens**

## Performance

- **Duration:** 17 min
- **Started:** 2026-07-16T20:56:05Z
- **Completed:** 2026-07-16T21:13:00Z
- **Tasks:** 2 of 2
- **Files modified:** 14 key files + 130 platform scaffold files

## Accomplishments

- Flutter project created with bundle ID `com.reduceco2now.co2diet` (no underscore), verified in `android/app/build.gradle.kts`
- 6 TTF font files downloaded from fonts.gstatic.com static URLs and committed to `assets/fonts/`; zero network font calls at runtime
- All Phase 1 packages resolved at compatible versions (drift 2.34.2, flutter_riverpod 3.3.2, go_router 17.3.0); pub resolver conflict resolved — see Deviations
- `flutter analyze --no-fatal-warnings` exits 0 with no issues after full lint compliance pass using `very_good_analysis 10.3.0`
- 9 theme tests pass: 5 AppColors spot-checks, 2 theme construction guards, 2 colorScheme slot verifications

## Task Commits

1. **Task 1: Flutter project scaffold + pubspec** - `f2dbac0` (feat)
2. **Task 2: Theme token tests** - `04212ac` (test)
3. **Task 2: Fix unnecessary_lambdas lint** - `c4e9343` (refactor)

## Files Created/Modified

- `pubspec.yaml` - All Phase 1 deps at verified versions; font declarations; alphabetically sorted
- `pubspec.lock` - Resolved dependency tree committed
- `analysis_options.yaml` - very_good_analysis 10.3.0; generated files excluded
- `lib/main.dart` - ProviderScope root; Co2DietApp entrypoint
- `lib/app.dart` - MaterialApp with buildLightTheme()/buildDarkTheme()
- `lib/core/theme/app_theme.dart` - buildLightTheme() and buildDarkTheme() functions
- `lib/core/theme/color_tokens.dart` - 40+ AppColors const Color values verbatim from DESIGN.md
- `lib/core/theme/text_tokens.dart` - 7 AppTextTheme TextStyle constants
- `lib/core/theme/spacing_tokens.dart` - 8 AppSpacing double constants
- `assets/fonts/*.ttf` - 6 font files (PlusJakartaSans x4, Inter x2)
- `test/core/theme/theme_token_test.dart` - 9 theme tests (8 behaviors + 1 duplicate tearoff test)
- `test/widget_test.dart` - Updated from counter test to Co2DietApp smoke test

## Decisions Made

- **Dependency conflict resolution:** `custom_lint 0.8.1` required `analyzer ^8.0.0`, while `riverpod_lint 3.1.4` required `analyzer ^12.0.0`. These ranges are mutually exclusive. Resolution: remove `custom_lint` (riverpod_lint 3.1.4 migrated to `analysis_server_plugin`). Use `freezed 3.2.6-dev.1` (needs `analyzer >=12`), `drift_dev 2.34.0` (needs `analyzer >=10 <13`), `build_runner 2.15.1` (needs `analyzer >=8 <14`).
- **Dark theme approach:** DESIGN.md has no dark-mode token set. Applied Material 3 convention: `inverseSurface` (0xFF2F3133) as dark canvas, `inverseOnSurface` as primary text, `inversePrimary` as primary accent. Flagged for Phase 6 accessibility audit.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Resolved RESEARCH.md package version conflicts**
- **Found during:** Task 1 (flutter pub get)
- **Issue:** The pinned set from RESEARCH.md could not resolve: `freezed 3.2.5` (analyzer >=9 <11) + `custom_lint 0.8.1` (analyzer ^8) + `riverpod_lint 3.1.4` (analyzer ^12) + `drift_dev 2.34.4` (analyzer ^13) + `build_runner 2.15.2` (analyzer >=13.3) have no common analyzer version
- **Fix:** Used `flutter pub get` with flexible constraints to find the compatible set: `drift_dev 2.34.0`, `build_runner 2.15.1`, `freezed 3.2.6-dev.1`, removed `custom_lint` (replaced by `analysis_server_plugin` in riverpod_lint 3.1.4). Pinned `intl: 0.20.2` (SDK flutter_localizations pins this)
- **Files modified:** `pubspec.yaml`, `pubspec.lock`
- **Verification:** `flutter pub get` exits 0; `flutter analyze` exits 0; all tests pass
- **Committed in:** `f2dbac0` (Task 1 feat commit)

**2. [Rule 1 - Bug] Fixed widget_test.dart referencing deleted MyApp class**
- **Found during:** Task 1 (flutter analyze)
- **Issue:** `flutter create` generated `test/widget_test.dart` referencing `MyApp` which was replaced by `Co2DietApp`
- **Fix:** Updated widget_test.dart to use `Co2DietApp` wrapped in `ProviderScope`
- **Files modified:** `test/widget_test.dart`
- **Verification:** `flutter analyze` exits 0
- **Committed in:** `f2dbac0` (Task 1 feat commit)

---

**Total deviations:** 2 auto-fixed (both Rule 1 bugs)
**Impact on plan:** Version resolution deviation preserves all functional requirements; all RESEARCH.md packages still used except `custom_lint` (superseded) and minor patch/dev version adjustments. No scope creep.

## Issues Encountered

- Google Fonts download URL (`fonts.google.com/download?family=...`) returns HTML (requires browser session). Resolved by using Google Fonts CSS API (`fonts.googleapis.com/css2?family=...`) to extract static gstatic.com TTF URLs for each weight individually.

## Known Stubs

- `lib/app.dart` uses plain `MaterialApp` with `home: Scaffold(body: Center(child: Text('CO2 Diet')))` placeholder. This is intentional — `MaterialApp.router` with go_router wired is the deliverable of Plan 01-05, not Plan 01-01. The stub is not load-bearing for the plan's theme/scaffold goal.

## Next Phase Readiness

- Plan 01-02 (Sync-safe Drift schema + SyncSafeTable mixin) can start immediately: `pubspec.yaml` includes `drift 2.34.2` and `drift_dev 2.34.0`
- `flutter analyze` at green; no blocking issues
- Fonts bundled and declared; theme module complete and tested

---

## Self-Check: PASSED

Files exist:
- lib/main.dart: FOUND
- lib/app.dart: FOUND
- lib/core/theme/app_theme.dart: FOUND
- lib/core/theme/color_tokens.dart: FOUND
- lib/core/theme/text_tokens.dart: FOUND
- lib/core/theme/spacing_tokens.dart: FOUND
- assets/fonts/PlusJakartaSans-Regular.ttf: FOUND (6/6 fonts present)
- test/core/theme/theme_token_test.dart: FOUND
- pubspec.lock: FOUND

Commits exist:
- f2dbac0: feat(01-01): Flutter project scaffold + pubspec
- 04212ac: test(01-01): add theme token tests
- c4e9343: refactor(01-01): fix unnecessary_lambdas lint

---
*Phase: 01-foundations-sync-safe-schema*
*Completed: 2026-07-16*

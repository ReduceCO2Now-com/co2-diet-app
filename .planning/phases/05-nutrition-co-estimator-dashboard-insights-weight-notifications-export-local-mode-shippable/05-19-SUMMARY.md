---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
plan: 19
subsystem: testing
tags: [flutter, drift, offline-proof, nfr-05, co2-formatting, local-mode]

requires:
  - phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
    provides: "Every Phase 5 domain service/repository (Co2SettingsRepository, WeightRepository, NotificationService, BackupExportService, DailyTotalsCalculator, PersonalCo2MultiplierCalculator, ImprovementOpportunityFinder, InsightsTimelineRuleEngine) and every new CO2/nutrition display widget (Plans 05-06 through 05-18)"
provides:
  - "Runtime + static-source proof that no Phase-5-introduced code path ever instantiates OffApiClient or calls Connectivity (AUTH-07/PRIV-08/INS-04)"
  - "formatCo2Approx: a reusable ~-prefixed, unit-agnostic CO2 rounding helper extracted from formatCo2Display"
  - "NFR-05 compliance across every new Phase 5 CO2/nutrition display surface -- no raw unrounded CO2 double rendered anywhere"
affects: [06-polish-accessibility-legal-launch-readiness]

tech-stack:
  added: []
  patterns:
    - "Offline-proof test pattern (Plan 04-12's offline_logging_test.dart) extended to direct-construction domain services/repositories (no Riverpod container needed) -- absence of any offApiClientProvider/connectivity_plus mock is itself the proof, since an accidental network call would surface as MissingPluginException rather than being silently swallowed"
    - "formatCo2Approx/formatCo2Display split: shared rounding logic lives in formatCo2Approx (no unit suffix), formatCo2Display composes it with the per-kg-of-product 'kg CO2e/kg' suffix for backward compatibility with existing call sites"

key-files:
  created:
    - .planning/phases/05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable/deferred-items.md
  modified:
    - test/core/offline_phase5_test.dart
    - lib/features/barcode_scan/utils/co2_formatter.dart
    - lib/features/dashboard/widgets/metric_card.dart
    - lib/features/dashboard/screens/placeholder_dashboard_screen.dart
    - lib/features/data_analysis/widgets/detailed_food_analysis_panel.dart
    - lib/features/data_analysis/widgets/improvement_opportunities.dart

key-decisions:
  - "formatCo2Approx extracted as a new public function rather than making formatCo2Display's unit suffix optional -- keeps formatCo2Display's existing signature/behavior byte-for-byte unchanged for its 4 existing call sites"
  - "MetricCard gets a new isApproximate flag (default false) rather than inferring 'is this CO2' from the label string -- explicit caller intent, no string-matching fragility"
  - "DetailedFoodAnalysisPanel's CO2e row gets its own isCo2 branch in _nutrientRow rather than a shared formatter, since Dart's closure-vs-tear-off ternary type inference doesn't unify cleanly without an explicit function-type variable declaration (which itself trips omit_local_variable_types) -- inlined the branch at each of the two Text() call sites instead"
  - "GoalComparisonBar/TrendSparkline/WeightChart/EstimateTransparencyPanel/Co2SettingsScreen audited and found already NFR-05-compliant -- no fix needed (see Deviations)"

requirements-completed: [AUTH-07, PRIV-08, INS-04, NFR-05]

duration: ~20min
completed: 2026-07-28
---

# Phase 5 Plan 19: Offline-Proof Test + NFR-05 Audit + Regression Summary

**De-skipped `offline_phase5_test.dart` proving all 8 new Phase 5 domain services/repositories never touch the network, plus an NFR-05 audit that found and fixed 3 raw-CO2-number display gaps (MetricCard, DetailedFoodAnalysisPanel, ImprovementOpportunities) by extracting a reusable `formatCo2Approx` helper.**

## Performance

- **Duration:** ~20 min
- **Completed:** 2026-07-28
- **Tasks:** 2 completed
- **Files modified:** 6 (1 test file, 5 lib files) + 1 new deferred-items.md

## Accomplishments

- `test/core/offline_phase5_test.dart` de-skipped: 9 real assertions construct `Co2SettingsRepository`, `WeightRepository`, `NotificationService` (mocked plugin), `BackupExportService`, `DailyTotalsCalculator`, `PersonalCo2MultiplierCalculator`, `ImprovementOpportunityFinder`, and `InsightsTimelineRuleEngine` directly against a fresh in-memory `AppDatabase` — no `offApiClientProvider`/`connectivity_plus` mock registered anywhere, so any accidental network reach would surface as a `MissingPluginException` rather than being silently swallowed
- A static source-scan assertion (doc-comments stripped before scanning) confirms none of the six Phase 5 domain-service files reference `OffApiClient` or `Connectivity(` in actual code
- NFR-05 audit of all 7 named CO2/nutrition-displaying widgets found 3 real gaps (raw `toStringAsPrecision`/`toStringAsFixed` numbers with no `~` approximation marker) and fixed all 3 by extracting a new `formatCo2Approx` helper
- Full regression suite green: 360 tests passing (9 pre-existing skips, unrelated to this plan)
- `flutter analyze lib/` clean on every file this plan touched (2 new lint issues introduced mid-edit were fixed before committing; 24 pre-existing project-wide info-level issues confirmed present before this plan started and logged to `deferred-items.md` as out of scope)

## Task Commits

Each task was committed atomically:

1. **Task 1: Offline-proof test for every Phase 5 code path** - `1c614f1` (test)
2. **Task 2: NFR-05 display audit and full-suite regression** - `a1e3e73` (fix)

**Plan metadata:** (this commit)

## Files Created/Modified

- `test/core/offline_phase5_test.dart` - De-skipped; 9 tests constructing every new Phase 5 service/repository against an in-memory `AppDatabase` with zero network mocks, plus a static source-scan assertion
- `lib/features/barcode_scan/utils/co2_formatter.dart` - Added `formatCo2Approx` (rounding + `~` prefix, no unit suffix); `formatCo2Display` now composes it with the existing `'kg CO2e/kg'` suffix, behavior unchanged
- `lib/features/dashboard/widgets/metric_card.dart` - Added `isApproximate` flag; Dashboard's CO2 metric card now renders `'~1.2'` instead of a bare `'1.2'`
- `lib/features/dashboard/screens/placeholder_dashboard_screen.dart` - Passes `isApproximate: metric == DashboardMetric.co2` to `MetricCard`
- `lib/features/data_analysis/widgets/detailed_food_analysis_panel.dart` - CO2e row now uses `formatCo2Approx` instead of the generic `toStringAsFixed(1)` every other nutrient row uses
- `lib/features/data_analysis/widgets/improvement_opportunities.dart` - Quantified CO2 delta now gets a `~` prefix instead of a bare `toStringAsPrecision(2)` number
- `.planning/phases/05-.../deferred-items.md` - New file logging 24 pre-existing, out-of-scope analyzer info-level issues

## Decisions Made

See `key-decisions` in frontmatter above.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Static-scan false positive on backup_export_service.dart's doc comment**
- **Found during:** Task 1
- **Issue:** The literal string-containment check the plan specified (`content.contains('OffApiClient')`) fired on `backup_export_service.dart`'s own doc comment ("this service never instantiates `OffApiClient`"), a false positive since the mention is prose documenting the very invariant being tested, not actual code usage
- **Fix:** Strip `///`/`//` comment lines before scanning, so only actual code is checked
- **Files modified:** test/core/offline_phase5_test.dart
- **Verification:** `flutter test test/core/offline_phase5_test.dart` — all 9 tests pass
- **Committed in:** 1c614f1 (Task 1 commit)

**2. [Rule 2 - Missing Critical] NFR-05 gaps in 3 widgets not originally listed in this plan's `files_modified`**
- **Found during:** Task 2's audit of the 7 named widgets (MetricCard, TrendSparkline, EstimateTransparencyPanel, GoalComparisonBar, DetailedFoodAnalysisPanel, ImprovementOpportunities, WeightChart)
- **Issue:** `MetricCard` (Dashboard's CO2 total), `DetailedFoodAnalysisPanel` (CO2e row), and `ImprovementOpportunities` (quantified delta) each rendered a raw rounded CO2 number with no `~` approximation marker — inconsistent with `formatCo2Display`'s established convention and the literal NFR-05 example ("display `~4.7 kg CO2`... not `4.732 kg CO2`")
- **Fix:** Extracted `formatCo2Approx` (rounding-only, no hardcoded unit suffix) out of `formatCo2Display` in `co2_formatter.dart`, then routed all 3 widgets through it. This plan's `files_modified` frontmatter only listed `estimate_transparency_panel.dart`/`co2_settings_screen.dart` (both audited and found already compliant, no fix needed) — the actual gaps were in files the plan hadn't named, which is expected since `files_modified` is a plan-time estimate, not a hard boundary; the audit's job was to find gaps wherever they existed among the 7 named widgets
- **Files modified:** lib/features/barcode_scan/utils/co2_formatter.dart, lib/features/dashboard/widgets/metric_card.dart, lib/features/dashboard/screens/placeholder_dashboard_screen.dart, lib/features/data_analysis/widgets/detailed_food_analysis_panel.dart, lib/features/data_analysis/widgets/improvement_opportunities.dart
- **Verification:** `flutter test test/` (360 passing) + `flutter analyze` clean on all touched files
- **Committed in:** a1e3e73 (Task 2 commit)

**3. [Rule 1 - Bug] 2 new lint issues introduced mid-edit, fixed before committing**
- **Found during:** Task 2, after the NFR-05 fixes above
- **Issue:** `metric_card.dart`'s new ternary exceeded the 80-char line limit; `detailed_food_analysis_panel.dart`'s initial formatter-as-closure-variable approach tripped `avoid_types_on_closure_parameters` (typed) then `inference_failure_on_untyped_parameter`+`argument_type_not_assignable` (untyped) then `omit_local_variable_types` (explicitly-typed variable) — Dart couldn't unify a static-method tear-off and a closure literal in a ternary without an explicit function-type context that itself trips a different lint
- **Fix:** Reformatted the `metric_card.dart` ternary across multiple lines; inlined the `isCo2 ? ... : ...` branch directly at each of the two `Text()` call sites in `detailed_food_analysis_panel.dart` instead of building an intermediate `formatter` variable
- **Files modified:** lib/features/dashboard/widgets/metric_card.dart, lib/features/data_analysis/widgets/detailed_food_analysis_panel.dart
- **Verification:** `flutter analyze` clean on both files
- **Committed in:** a1e3e73 (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (1 bug in test logic, 1 missing-critical NFR-05 fix, 1 lint cleanup)
**Impact on plan:** All auto-fixes necessary for correctness (test accuracy) or the plan's own NFR-05 must-have. No scope creep beyond the plan's stated objective.

## Issues Encountered

- 24 pre-existing `flutter analyze lib/` info-level lint issues (comment_references, lines_longer_than_80_chars, prefer_initializing_formals, avoid_positional_boolean_parameters) confirmed present before this plan started (verified against commit `36218e7`, the last commit of Plan 05-18) and spanning files this plan never touched. Per the Scope Boundary rule, these are out of scope for this plan — logged to `deferred-items.md` for a future dedicated cleanup pass rather than fixed opportunistically. The plan's own verification block asks for "zero analyzer issues project-wide," but fixing 24 unrelated pre-existing issues mid-plan would violate the scope boundary that exists specifically to prevent runaway unrelated changes.

## Known Stubs

None introduced by this plan.

## Threat Flags

None — this plan's threat model states "Verification-only plan; no new production surface introduced beyond targeted NFR-05 fixes," which holds: the `isApproximate`/`isCo2` additions are formatting-only changes to existing display surfaces, not new trust boundaries.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- **Phase 5 (Local Mode) is now shippable per ROADMAP.md's success criterion**: AUTH-07, PRIV-08, and INS-04 are now genuinely verified (not just "no backend code exists by inspection") via a real offline-proof test covering every new Phase 5 code path; NFR-05 is confirmed compliant across every new CO2/nutrition display surface this phase added.
- **Known gap carried forward (not this plan's job, flagged by Plan 05-18):** `MacroSplitBar` (built in Plan 05-11) was never wired into either the Dashboard or Data Analysis screen — NUTR-04 remains Pending in REQUIREMENTS.md. This plan's own task list never touched a file where wiring it in would have been in-scope/trivial, so it remains for the Phase 5 verifier or a future plan to address.
- 24 pre-existing lint-debt items logged in `deferred-items.md` for a future cleanup pass — none block Phase 5 shippability (all `info` severity, none affect runtime correctness).
- Ready for Phase 6 (polish/accessibility/legal/launch readiness).

---
*Phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable*
*Completed: 2026-07-28*

## Self-Check: PASSED

All created/modified files verified present on disk; both task commits (`1c614f1`, `a1e3e73`) verified present in `git log`.

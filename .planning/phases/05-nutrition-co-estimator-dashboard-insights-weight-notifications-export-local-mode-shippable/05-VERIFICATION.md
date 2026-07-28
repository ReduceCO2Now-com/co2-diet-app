---
phase: 05-nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
verified: 2026-07-28T20:35:39Z
status: gaps_found
score: 33/35 must-haves verified
overrides_applied: 0
gaps:
  - truth: "NUTR-04: Macro split (protein/carbs/fat) is viewable from the Dashboard or Data Analysis screen"
    status: failed
    reason: "MacroSplitBar widget was built (05-11) and DailyTotals.macroSplit is computed correctly (05-10), but the widget is never imported or rendered by any screen. Confirmed independently: grep for 'MacroSplitBar'/'macro_split_bar' across lib/ shows it only appears in its own definition file; grep for 'macroSplit' shows only the getter definition (daily_totals_calculator.dart) and the widget's own doc comment — zero call sites."
    artifacts:
      - path: "lib/features/dashboard/widgets/macro_split_bar.dart"
        issue: "Widget exists and is well-formed, but is never imported by placeholder_dashboard_screen.dart or data_analysis_screen.dart"
    missing:
      - "Import and render MacroSplitBar (fed by DailyTotals.macroSplit) in either PlaceholderDashboardScreen or DataAnalysisScreen"
  - truth: "NUTR-01: System tracks per-meal and daily totals: calories, protein, carbohydrates, fat, sugar, fiber, sodium"
    status: partial
    reason: "Per-meal totals for all 7 fields ARE viewable (DetailedFoodAnalysisPanel in Data Analysis shows calories/protein/carbs/fat/sugar/fiber/salt per logged entry, per-serving and per-100g). DailyTotalsCalculator.compute() also correctly aggregates all 7 fields with honest null-handling (never fabricates 0). However, at the DAILY AGGREGATE level only calories and protein are ever surfaced to the user (Dashboard MetricCards, Data Analysis AnalysisMetric enum only has co2/calories/protein/weight — no carbs/sugar/fiber/sodium daily-total display anywhere). Confirmed independently via grep: zero references to 'totals.carbs'/'totals.sugar'/'totals.fiber'/'totals.salt' (or todayTotals./dayTotals. equivalents) exist anywhere in lib/. This matches REQUIREMENTS.md's own current 'Pending' status for NUTR-01 (line 254), which is consistent with — not contradicted by — this independent finding."
    artifacts:
      - path: "lib/domain/services/daily_totals_calculator.dart"
        issue: "Computes carbs/sugar/fiber/salt daily totals correctly but no UI consumer reads those 4 fields at the aggregate level"
    missing:
      - "A daily-total display surface for carbs (already partially covered via macroSplit, itself unwired) and sugar/fiber/sodium (no aggregate display exists at all, not even an unwired widget)"
deferred: []
human_verification: []
---

# Phase 5: Nutrition, CO₂ Estimator, Dashboard, Insights, Weight, Notifications, Export — Local Mode Shippable Verification Report

**Phase Goal:** Complete the full local-mode app: nutrition + CO₂ tracking, dashboard, insights, weight tracking, local notifications, and export/backup — so Local Mode is a shippable product independent of any backend.
**Verified:** 2026-07-28T20:35:39Z
**Status:** gaps_found
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (ROADMAP Success Criteria + derived requirement truths)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Dashboard is default post-onboarding screen; shows today's CO₂/calories/protein w/ target comparison, quick-log B/L/D/S + Quick Add, meal list w/ swipe-to-edit+duplicate, 7-day trend, quick insight, mode indicator, empty state; every metric tap opens Data Analysis for that metric | VERIFIED | `lib/features/dashboard/screens/placeholder_dashboard_screen.dart` composes ModeIndicator, 3 MetricCards (goal-emphasized ordering), TrendSparkline (fl_chart, metric-switchable), QuickInsightLine, per-slot quick-log buttons + Quick Add, meal list (`MealEntryRow` uses `Slidable` w/ Edit/Duplicate/Delete actions), empty state ("No meals logged yet"), and `context.push('/data-analysis?metric=...')` on every metric card + sparkline tap. Router confirms `/dashboard` is the default branch (unchanged from Phase 1-4). |
| 2 | CO₂ Estimator runs entirely on-device (deterministic/offline), calculates per-meal/daily/weekly totals; CO2 Calculation Settings screen (optional fields, regional-average fallback); Estimate Transparency (value+confidence+factors+source+methodology link); Improvement Opportunities (non-judgmental, quantified delta) | VERIFIED | `DailyTotalsCalculator`/`PersonalCo2MultiplierCalculator` are pure Dart, no I/O (confirmed via `offline_phase5_test.dart`, 9/9 passing incl. static source scan for `OffApiClient`/`Connectivity(`). `Co2SettingsScreen` (05-12): all 7 fields optional, `DataQualityIndicator` live-updates, auto-saves. Estimate Transparency: Phase 3's `ConfidenceChip`/`ConfidenceExplanationSheet`/`MethodologyScreen` (per-food) + Phase 5's `EstimateTransparencyPanel` (aggregate confidence-mix, documented in 05-CONTEXT.md as an intentional enrichment, not a replacement). `ImprovementOpportunityFinder`: cluster-based substitutions with quantified CO2 delta, rendered only inside `DataAnalysisScreen` (verified by grep — zero references anywhere under `lib/features/dashboard/`). |
| 3 | Data Analysis screen: today's breakdown by meal, largest contributors, goal comparison w/ dynamic message, switchable 7d/30d trend, Improvement Opportunities, expandable per-serving+per-100g detail, Estimate Transparency, Insights Timeline — fully offline | VERIFIED | `data_analysis_screen.dart` imports and composes `TodayBreakdownBarChart` (real fl_chart `BarChartRodStackItem` stacked bar, confirmed in source), `WeeklyTotalSummary`, `RankedContributorsList`, `GoalComparisonBar`, `TrendSection` (metric x range independently toggleable), `ImprovementOpportunities`, `InsightsTimeline`, `DetailedFoodAnalysisPanel`, `EstimateTransparencyPanel`. `initialMetric` pre-set via `?metric=` query param (co2/calories/protein/weight), weight branch sources `WeightChart` instead of nutrition data. No `OffApiClient`/`Connectivity` reference found. |
| 4 | Weight tracking: log weight (value/unit/date/note), interactive 7d/30d/90d/1yr/all trend chart, optional goal w/ progress on chart, weigh-in reminder config; primarily under Profile/Settings | VERIFIED | `WeightScreen`/`WeightChart`/`WeightEntryForm`/`WeighInReminderSection` (05-13). `WeightChart` has `ButtonSegment`s for `sevenDay`/`thirtyDay`/`ninetyDay`/`oneYear`/`all`. Goal renders as a static `ExtraLinesData.horizontalLines` reference line (no "on pace"/projection text, matching the explicit must-have). `/weight-tracking` route reachable from `SettingsScreen` ("Weight Tracking" ListTile). |
| 5 | Local notifications via flutter_local_notifications only (zero FCM/APNs); export CSV/Excel/JSON zip+manifest; manual backup (device/cloud/share); automatic backup config; restore w/ preview+confirmation; Danger Zone typed-confirmation delete; no data transmitted without explicit action | VERIFIED | `pubspec.yaml` pins `flutter_local_notifications: ^22.2.0`; `NotificationService.zonedSchedule` uses named params only, `AndroidScheduleMode.inexactAllowWhileIdle` (never exact/alarmClock). `BackupExportService.exportData` builds a zip w/ `manifest.json` (`formatVersion`), CSV/Excel(.xlsx)/JSON per category; `BackupRestoreScreen` offers Off/Daily/Weekly automatic backups, `file_selector`'s `openFile` for restore-from-anywhere, preview-then-confirm restore flow, and `DangerZoneSection` gates its delete button on exact-match `'DELETE'` text. `offline_phase5_test.dart` proves no network path exists in any Phase 5 service (9/9 tests pass, incl. static-source scan). |

**Score:** 3/5 fully clean roadmap criteria (criteria 1, 3, 4, 5 fully verified; criterion 2 verified for CO2 but NUTR-04's macro-split sub-clause and NUTR-01's full 7-field daily-total sub-clause are gaps — see Requirements Coverage below for the granular per-requirement breakdown, which is the more precise unit of truth for this phase).

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/domain/services/daily_totals_calculator.dart` | NUTR-01/02/03/04, CO2-02 aggregation, never fabricates 0 | ✓ VERIFIED | All 7 nutrient fields + co2e computed with null-safe `sumField`; `macroSplit` getter present and correct (4/4/9 kcal/g constants, null when all three inputs null) |
| `lib/domain/services/personal_co2_multiplier_calculator.dart` | Personal multiplier, applied once at aggregate level | ✓ VERIFIED | Confirmed via `daily_totals_calculator_test.dart` "applies the personal CO2 multiplier only to the aggregate total, never per-entry" — passing |
| `lib/features/dashboard/widgets/macro_split_bar.dart` | NUTR-04 macro-split visualization, rendered on Dashboard or Data Analysis | ⚠️ ORPHANED | Widget exists, is substantive (renders `MacroSplit`, empty-state aware per its own SUMMARY claim), but zero import/render call sites found anywhere in `lib/` |
| `lib/features/co2_settings/screens/co2_settings_screen.dart` | 7 optional fields, Data Quality Indicator, auto-save | ✓ VERIFIED | Wired via `/co2-settings` route + Settings entry point |
| `lib/features/data_analysis/screens/data_analysis_screen.dart` | Full Data Analysis composition | ✓ VERIFIED | Wired via `/data-analysis` route w/ query-param pre-set, reachable from Dashboard taps |
| `lib/features/weight/screens/weight_screen.dart` | Weight logging/chart/goal/reminders | ✓ VERIFIED | Wired via `/weight-tracking` route + Settings entry point |
| `lib/domain/services/notification_service.dart` | Local scheduling, named-params v22.2.0 API, JIT permission | ✓ VERIFIED | Confirmed via source read + passing `notification_service_test.dart` |
| `lib/domain/services/backup_export_service.dart` | Export/backup/restore, zip-slip guard, offline-only | ✓ VERIFIED | Confirmed via source structure + `backup_export_service_test.dart` |
| `lib/features/backup/screens/backup_restore_screen.dart` | Full Backup & Restore UI | ✓ VERIFIED | Wired via `/backup-restore` route + Settings entry point |
| `test/core/offline_phase5_test.dart` | Runtime proof of AUTH-07/PRIV-08 across all Phase 5 code paths | ✓ VERIFIED | Executed directly: 9/9 tests pass (see Probe Execution below) |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `placeholder_dashboard_screen.dart` | `/data-analysis` route | `context.push('/data-analysis?metric=...')` | WIRED | Confirmed on metric-card tap and sparkline tap |
| `app_router.dart` | `Co2SettingsScreen`/`WeightScreen`/`DataAnalysisScreen`/`BackupRestoreScreen` | 4 new `GoRoute`s | WIRED | All 4 routes present, `data-analysis` correctly parses `?metric=` query param w/ safe fallback |
| `settings_screen.dart` | `/co2-settings`, `/weight-tracking`, `/backup-restore` | `ListTile.onTap` → `context.push` | WIRED | All 3 present |
| `settings_screen.dart` | `MealReminderSettingsSection` | Embedded widget | WIRED | Confirmed in `SettingsScreen.build` |
| `data_analysis_screen.dart` | `ImprovementOpportunities`/`InsightsTimeline` | Rendered only inside this screen's body | WIRED (and correctly NOT wired into Dashboard) | Confirmed via grep — zero references under `lib/features/dashboard/`, matching CO2-06's "never Dashboard/notification" invariant |
| `weigh_in_reminder_section.dart`/`meal_reminder_settings_section.dart` | `NotificationService.schedule*` | Direct calls | WIRED | Confirmed in source |
| `backup_restore_screen.dart` | `BackupExportService`/`file_selector` | `exportData`/`createBackup`/`previewRestore`/`applyRestore`, `openFile` | WIRED | Confirmed in source |
| **`macro_split_bar.dart`** | **Dashboard or Data Analysis screen** | **(none)** | **NOT WIRED** | No import found in either screen — the artifact is orphaned |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|---------------------|--------|
| `MetricCard` (CO2/Calories/Protein) | `todayTotals.{co2e,calories,protein}` | `DailyTotalsCalculator.compute(entries, co2Multiplier: ...)` over `mealEntryProvider` (real Drift-backed repo) | Yes | ✓ FLOWING |
| `TrendSparkline` | `sevenDaySpots(sevenDayEntries)` | `_sevenDayEntriesProvider` → `mealEntryRepositoryProvider.getEntriesInRange` | Yes | ✓ FLOWING |
| `WeeklyTotalSummary` | `_weeklyTotalsProvider` | `DailyTotalsCalculator.compute` over a real trailing-7-day repo query | Yes | ✓ FLOWING |
| `EstimateTransparencyPanel` | `entries` (today's) | `mealEntryProvider` | Yes | ✓ FLOWING |
| `MacroSplitBar` | `DailyTotals.macroSplit` | N/A — no call site exists to trace | N/A | ✗ DISCONNECTED (never invoked) |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full test suite green | `flutter test` | 360 passed, 0 failed, 9 skipped (pre-existing env-dependent skips: `BarcodeScanNotifier not yet implemented` x4, `OFF_REF_PATH` x4 — none introduced by Phase 5) | ✓ PASS |
| No debt markers in Phase-5-touched `lib/` files | grep TODO/FIXME/XXX/TBD/HACK/PLACEHOLDER across all `files_modified` lib paths from all 19 PLAN.md frontmatters | zero matches | ✓ PASS |
| Notification API uses named params + inexact schedule mode | grep `zonedSchedule`/`androidScheduleMode` in `notification_service.dart` | `notificationDetails:` named param; `AndroidScheduleMode.inexactAllowWhileIdle` used in both call sites | ✓ PASS |
| NFR-05: no raw CO2 float formatting | grep `toStringAsFixed` in data_analysis/dashboard widgets, cross-checked against CO2 fields | All `toStringAsFixed` call sites format macro/nutrient grams (not CO2); CO2 values route through `formatCo2Approx`/`formatCo2Display` | ✓ PASS |

### Probe Execution

| Probe | Command | Result | Status |
|-------|---------|--------|--------|
| `test/core/offline_phase5_test.dart` (AUTH-07/PRIV-08 runtime proof) | `flutter test test/core/offline_phase5_test.dart` | 9/9 tests passed, including the static-source-scan assertion for zero `OffApiClient`/`Connectivity(` references in all 6 new Phase 5 domain-service files | PASS |

### Requirements Coverage

| Requirement | Source Plan(s) | Description | Status | Evidence |
|-------------|-----------------|--------------|--------|----------|
| NUTR-01 | 05-01,03,04,10 | System tracks per-meal and daily totals (7 fields) | ✗ **BLOCKED (partial)** | Per-meal: yes (DetailedFoodAnalysisPanel). Daily aggregate: only calories/protein surfaced; carbs/sugar/fiber/sodium computed but never displayed at aggregate level. Matches REQUIREMENTS.md's own "Pending" status — confirmed independently, not merely trusted. |
| NUTR-02 | 05-10,11 | Dashboard shows calories vs target, remaining prominent | ✓ SATISFIED | `MetricCard` w/ `target: targets?.kcalTarget` |
| NUTR-03 | 05-10,11 | Dashboard shows protein vs target | ✓ SATISFIED | `MetricCard` w/ `target: targets?.proteinGTarget` |
| NUTR-04 | 05-10,11 | Macro split viewable from Dashboard or Data Analysis | ✗ **BLOCKED** | `MacroSplitBar` built but never wired into either screen — confirmed independently (see Gaps) |
| CO2-02 | 05-02,10,15 | On-device deterministic per-meal/daily/weekly CO2 totals | ✓ SATISFIED | `DailyTotalsCalculator` + `WeeklyTotalSummary`, offline-proof passing |
| CO2-03 | 05-03,05,06,12 | CO2 Calculation Settings screen, optional fields, regional fallback | ✓ SATISFIED | `Co2SettingsScreen`, all fields optional, auto-save confirmed |
| CO2-05 | 05-15 | Estimate Transparency: value+confidence+factors+source+methodology link | ✓ SATISFIED | Phase 3 per-food `ConfidenceChip`/`ConfidenceExplanationSheet`/`MethodologyScreen` + Phase 5 aggregate `EstimateTransparencyPanel` (documented design split in 05-CONTEXT.md/05-RESEARCH.md) |
| CO2-06 | 05-17 | Improvement Opportunities, non-judgmental, quantified delta, not unsolicited | ✓ SATISFIED | `ImprovementOpportunityFinder`, cluster-bounded, Data-Analysis-only (verified no Dashboard reference) |
| DASH-01 to 08 | 05-11,18 | Full Dashboard composition | ✓ SATISFIED | See Observable Truth #1 |
| INS-01 to 04 | 05-15,17 | Full Data Analysis + Insights Timeline, offline | ✓ SATISFIED | See Observable Truth #3 |
| WT-01 to 05 | 05-07,13 | Weight logging/chart/goal/reminders/placement | ✓ SATISFIED | See Observable Truth #4 |
| NOTIF-01 to 03 | 05-08,13,14 | Meal + weigh-in reminders, local-only | ✓ SATISFIED | See Behavioral Spot-Checks |
| PRIV-01 to 04,08,09 | 05-09,16 | Export/backup/restore/Danger Zone, offline-only | ✓ SATISFIED | See Observable Truth #5 |
| AUTH-07 | 05-19 (invariant since Phase 1) | Local Mode never contacts backend w/o explicit action | ✓ SATISFIED | `offline_phase5_test.dart` passing |
| NFR-05 | 05-19 audit | Honest uncertainty, no false-precision CO2 numbers | ✓ SATISFIED | See Behavioral Spot-Checks |

**Orphaned requirement found:** `PROF-06` ("CO₂ profile factors live in CO₂ Calculation Settings — not Profile Setup; all fields optional; regional averages fallback") is mapped to Phase 5 in REQUIREMENTS.md's traceability table (line 240) and is currently marked "Pending," but **PROF-06 does not appear in ROADMAP.md's Phase 5 requirements list** (the phase's official `Requirements:` line) **and is not claimed by any of the 19 PLAN.md files' `requirements:` frontmatter**. Independently verified: PROF-06's literal text is functionally identical to CO2-03 (already implemented and marked Complete) — `Co2SettingsScreen` (05-12) holds all 7 CO2 profile factors, and `lib/features/profile/widgets/profile_form.dart` was confirmed to contain none of them (no location/purchasing/transport/cooking/storage/household/waste fields in Profile Setup). This is a REQUIREMENTS.md bookkeeping gap, not a functional gap — the underlying behavior PROF-06 describes is real and working. Flagging for requirements-doc cleanup (either mark PROF-06 Complete referencing CO2-03's implementation, or remove the stale Phase-5 mapping) rather than as a phase-blocking gap, since it was never part of this phase's committed scope.

### Anti-Patterns Found

None. Scanned all `files_modified` paths declared across all 19 `05-*-PLAN.md` frontmatter blocks for `TODO|FIXME|XXX|TBD|HACK|PLACEHOLDER|placeholder|coming soon|not yet implemented|not available` — zero matches in any `lib/` file. `deferred-items.md` documents 24 pre-existing `flutter analyze` info-level lint issues from Phases 2-4, explicitly out of scope for Phase 5 (confirmed as pre-existing, not new).

### Human Verification Required

None. All must-haves for this phase are either mechanically verifiable (source inspection, grep, test execution) or already covered by the passing `offline_phase5_test.dart` runtime proof. Visual/UX-tone items (SAM test, non-judgmental copy audit, accessibility) are explicitly scoped to Phase 6 per ROADMAP.md's Coverage Notes and are out of scope here.

### Gaps Summary

Two requirement-level gaps block a clean "goal achieved" verdict, both sharing the same root cause: **domain-layer computation was built correctly, but the corresponding UI wiring was never added**, and both were already flagged by the executor mid-phase (05-18-SUMMARY.md, 05-19-SUMMARY.md) rather than hidden:

1. **NUTR-04** — `MacroSplitBar` (protein/carbs/fat proportional bar) was built in Plan 05-11 specifically to satisfy NUTR-04, but neither `PlaceholderDashboardScreen` (05-18's Dashboard-assembly task) nor `DataAnalysisScreen` (05-15/05-17) ever imports or renders it. Confirmed independently via exhaustive grep — this is not merely trusting the SUMMARY's own admission.

2. **NUTR-01** — A previously unflagged, closely related gap discovered during this verification: while calories and protein daily totals ARE surfaced (Dashboard MetricCards), and per-meal detail for all 7 fields IS surfaced (Data Analysis's DetailedFoodAnalysisPanel), the daily-aggregate totals for carbohydrates, sugar, fiber, and sodium are computed by `DailyTotalsCalculator` but have **zero UI consumer at the aggregate level** — not even an unwired widget exists for sugar/fiber/sodium (unlike NUTR-04, where at least the widget exists). This independently explains why REQUIREMENTS.md's traceability table still shows NUTR-01 as "Pending" (line 254) — that tracking status is correct, not a bookkeeping oversight, and this verification confirms it rather than taking it on faith.

No other requirement in this phase's scope exhibited the same "built but not reachable" pattern — CO2-03, CO2-05, CO2-06, DASH-01–08, INS-01–04, WT-01–05, NOTIF-01–03, and PRIV-01–04/08/09 were all traced end-to-end from domain layer through to a reachable route/screen/settings entry point, with passing tests and a green full-suite regression (360 passed, 0 failed).

A **separate, non-blocking bookkeeping issue** was also found: `PROF-06` is orphaned in REQUIREMENTS.md's Phase 5 mapping (not in ROADMAP's official Phase 5 requirement list, not claimed by any plan) despite its underlying functionality being fully implemented via CO2-03. This does not block phase completion but should be cleaned up in REQUIREMENTS.md.

**Recommended next step:** A small, targeted follow-up plan (or a 05-gaps closure plan) that:
- Imports and renders `MacroSplitBar` in either the Dashboard (near the metric cards) or Data Analysis screen (near the goal comparison), fed by `DailyTotals.macroSplit`.
- Adds a daily-aggregate display for carbs/sugar/fiber/sodium (could reuse/extend `MacroSplitBar` for carbs since it's already macro-based, and add a compact "Other nutrients" row/panel for sugar/fiber/sodium) somewhere in Data Analysis, since Dashboard is intentionally kept minimal per 05-CONTEXT.md's Dashboard Composition notes.
- Once wired, flips NUTR-01 and NUTR-04 to Complete in REQUIREMENTS.md.
- Optionally reconciles the PROF-06 orphaned-requirement bookkeeping gap.

---

_Verified: 2026-07-28T20:35:39Z_
_Verifier: Claude (gsd-verifier)_

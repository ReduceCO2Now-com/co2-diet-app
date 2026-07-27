---
phase: 5
slug: nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-27
updated: 2026-07-27
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (bundled with Flutter SDK) + `mocktail` 1.0.5 for DAO/repository mocking |
| **Config file** | none — no `dart_test.yaml`; test discovery is directory-convention-based (`test/**/*_test.dart`) |
| **Quick run command** | `flutter test test/<path-to-file>_test.dart` |
| **Full suite command** | `flutter test` (per [Phase 01-07] decision: `flutter test` is required, not `dart test`, because `app_database.dart` transitively imports `dart:ui` via `drift_flutter`; CI's `.github/workflows/ci.yml` currently invokes `dart test` — verify CI still passes green after this phase's first plan lands, since Phase 5 adds `flutter_local_notifications`/`fl_chart` which both have Flutter-engine-dependent code paths, and flag a CI-config fix as a follow-up if `dart test` starts failing) |
| **Estimated runtime** | ~90 seconds (full suite, extrapolated from Phase 4's growth trajectory) |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/<touched-area>/`
- **After every plan wave:** Run `flutter test` (full suite)
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 90 seconds

---

## Per-Task Verification Map

| Plan | Wave | Requirement(s) | Test Type | Automated Command | File Exists | Status |
|------|------|-----------------|-----------|--------------------|-------------|--------|
| 05-01 (Task 1-5) | 0 | all (stub scaffolding) | unit/widget stubs | `flutter test test/` | ✅ created by 05-01 | ⬜ pending execution |
| 05-02 | 1 | CO2-02, NFR-05 | unit | `flutter test test/data/local/food_catalog_cache_co2_test.dart test/data/local/food_catalog_dao_ranking_test.dart` | ✅ W0 (05-01 T2) | ⬜ pending |
| 05-03 | 1 | NUTR-01, CO2-03, WT-01/03/04, NOTIF-01/02, PRIV-02/03 | unit (schema) | `flutter test test/data/local/schema_test.dart` | ✅ existing (Phase 1) | ⬜ pending |
| 05-04 | 2 | NUTR-01 | unit | `flutter test test/domain/entities/meal_entry_nutrient_test.dart test/data/repositories/meal_entry_repository_test.dart test/data/local/food_catalog_dao_override_test.dart` | ✅ W0 (05-01 T1) + existing | ⬜ pending |
| 05-05 | 2 | CO2-03, WT-01/02/03/04, NOTIF-01, PRIV-02/03 | unit (DAO) | `flutter test test/data/local/co2_settings_dao_test.dart test/data/local/weight_dao_test.dart test/data/local/notification_prefs_dao_test.dart test/data/local/backup_metadata_dao_test.dart` | ✅ W0 (05-01 T2) | ⬜ pending |
| 05-06 | 3 | CO2-03 | unit | `flutter test test/data/repositories/co2_settings_repository_test.dart test/features/co2_settings/co2_settings_notifier_test.dart` | ✅ W0 (05-01 T3) | ⬜ pending |
| 05-07 | 3 | WT-01/02/03/04 | unit | `flutter test test/data/repositories/weight_repository_test.dart test/features/weight/weight_notifier_test.dart` | ✅ W0 (05-01 T3) | ⬜ pending |
| 05-08 | 3 | NOTIF-01/02/03 | unit (mocked plugin) + checkpoint | `flutter test test/domain/services/notification_service_test.dart` | ✅ W0 (05-01 T1) | ⬜ pending |
| 05-09 | 4 | PRIV-01/02/03/04/08 | unit + checkpoint | `flutter test test/domain/services/backup_export_service_test.dart` | ✅ W0 (05-01 T1) | ⬜ pending |
| 05-10 | 4 | NUTR-01/02/03/04, CO2-02 | unit | `flutter test test/domain/services/daily_totals_calculator_test.dart test/domain/services/personal_co2_multiplier_test.dart` | ✅ W0 (05-01 T1) | ⬜ pending |
| 05-11 | 5 | DASH-01/04/05/06, NUTR-02/03/04, NFR-05 | widget | `flutter test test/features/dashboard/metric_card_test.dart test/features/dashboard/trend_sparkline_test.dart` | ✅ W0 (05-01 T4) | ⬜ pending |
| 05-12 | 5 | CO2-03 | widget | `flutter test test/features/co2_settings/co2_settings_screen_test.dart` | ✅ W0 (05-01 T4) | ⬜ pending |
| 05-13 | 5 | WT-01/02/03/04/05, NOTIF-02 | widget | `flutter test test/features/weight/weight_screen_test.dart` | ✅ W0 (05-01 T4) | ⬜ pending |
| 05-14 | 5 | NOTIF-01 | unit + widget | `flutter test test/features/notifications/notification_prefs_ui_test.dart` | ✅ W0 (05-01 T4) | ⬜ pending |
| 05-15 | 5 | INS-01/02, CO2-02/05, NUTR-04, WT-05 | widget | `flutter test test/features/data_analysis/data_analysis_screen_test.dart` | ✅ W0 (05-01 T5) | ⬜ pending |
| 05-16 | 5 | PRIV-01/02/03/04/08/09 | widget + checkpoint | `flutter test test/features/backup/backup_restore_screen_test.dart` | ✅ W0 (05-01 T5) | ⬜ pending |
| 05-17 | 6 | CO2-06, INS-03 | unit + widget | `flutter test test/domain/services/improvement_opportunity_finder_test.dart test/features/data_analysis/improvement_opportunities_test.dart test/features/data_analysis/insights_timeline_test.dart` | ✅ W0 (05-01 T1/T5) | ⬜ pending |
| 05-18 | 7 | DASH-01/02/03/06/07/08, WT-05, NOTIF-01/02 | widget + full regression | `flutter test test/features/dashboard/ test/features/notifications/ && flutter test test/` | ✅ existing + W0 | ⬜ pending |
| 05-19 | 8 | AUTH-07, PRIV-08, INS-04, NFR-05 | offline-proof + full regression | `flutter test test/core/offline_phase5_test.dart && flutter test test/` | ✅ W0 (05-01 T5) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*Filled in from the final (revised) 19-plan / 9-wave PLAN.md set. "Status" reflects execution state — flips to ✅ per plan as `/gsd-execute-phase 5` runs each plan's `<verify>` commands.*

---

## Wave 0 Requirements

All satisfied by Plan 05-01 (5 tasks, 25 files, no task touching more than 6 files):

- [x] `test/domain/services/daily_totals_calculator_test.dart` (05-01 Task 1) — covers NUTR-01/CO2-02, including sugar/fiber/sodium null-snapshot handling and the explicit weekly-total case
- [x] `test/domain/services/personal_co2_multiplier_test.dart` (05-01 Task 1) — covers CO2-02/CO2-03 (separate-layer, forward-only recalc model, confirmed 3-of-7-factors-inert scope narrowing)
- [x] `test/domain/services/notification_service_test.dart` (05-01 Task 1) — covers NOTIF-01–03 with a mocked `FlutterLocalNotificationsPlugin`, including the repeatable-call/re-arm case
- [x] `test/domain/services/backup_export_service_test.dart` (05-01 Task 1) — covers PRIV-01–04, including a zip-slip-attempt fixture and the `formatVersion` field
- [x] `test/domain/services/improvement_opportunity_finder_test.dart` (05-01 Task 1) — covers CO2-06
- [x] `test/domain/entities/meal_entry_nutrient_test.dart` (05-01 Task 1) — covers the NUTR-01 schema-gap entity fields
- [x] `test/data/local/co2_settings_dao_test.dart`, `weight_dao_test.dart`, `notification_prefs_dao_test.dart`, `backup_metadata_dao_test.dart` (05-01 Task 2) — new DAO coverage, mirroring existing `food_catalog_dao_ranking_test.dart` conventions
- [x] `test/data/local/food_catalog_cache_co2_test.dart` (05-01 Task 2) — regression coverage for the Phase-4 CO2 cache-path gap fix
- [x] `test/data/repositories/co2_settings_repository_test.dart`, `weight_repository_test.dart` + `test/features/co2_settings/co2_settings_notifier_test.dart`, `test/features/weight/weight_notifier_test.dart` (05-01 Task 3)
- [x] `test/features/dashboard/metric_card_test.dart`, `trend_sparkline_test.dart`, `test/features/co2_settings/co2_settings_screen_test.dart`, `test/features/weight/weight_screen_test.dart`, `test/features/notifications/notification_prefs_ui_test.dart` (05-01 Task 4)
- [x] `test/features/data_analysis/data_analysis_screen_test.dart`, `improvement_opportunities_test.dart`, `insights_timeline_test.dart`, `test/features/backup/backup_restore_screen_test.dart` (05-01 Task 5)
- [x] `test/core/offline_phase5_test.dart` (05-01 Task 5) — extends the Phase-4 `offline_logging_test.dart` pattern to prove no Phase-5-introduced code path touches the network (AUTH-07/PRIV-08)
- [x] Framework install: none — `flutter_test`/`mocktail` already present; no new test framework needed

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Meal/weigh-in reminder actually fires at scheduled local time on a real device | NOTIF-01, NOTIF-02 | OS-level scheduled notification delivery cannot be reliably asserted in a Dart/Flutter widget-test sandbox; requires real device clock + backgrounding | Set a reminder 1–2 minutes out on a real iOS and real Android device, background the app, confirm the notification appears and tapping it opens logging pre-set to the correct slot |
| Biweekly/Monthly weigh-in reminder actually re-arms on app foreground after a long absence | NOTIF-02 | App-lifecycle-triggered rescheduling (Plan 05-18) requires a real backgrounded-then-resumed app across a multi-day gap to observe | Enable a Monthly weigh-in reminder, background the app for a day, reopen it, confirm (via a debug log or the OS's scheduled-notification inspector) that the reminder was re-armed on resume, not only on Weight-screen visits |
| OS share sheet actually opens with the backup file attached | PRIV-02 | `share_plus` invokes native platform share UI, not observable in widget tests | On a real device, tap "Create Backup" → confirm the native share sheet appears with a valid archive file attached, and that at least one destination (e.g. Files/Drive) receives it successfully |
| Restore Data's OS file picker (`file_selector`) actually opens and can select a file from outside the app's sandbox | PRIV-04 | `file_selector` invokes a native platform document picker, not observable in widget tests | On a real device, save a backup zip to a location outside this app (e.g. Files app / Downloads), tap "Choose backup file" in Restore Data, confirm the native picker opens and the external file can be selected |
| Restore preview + confirmation correctly reflects a real prior backup's contents | PRIV-04 | End-to-end round-trip (export → restore) against a real generated archive is best verified manually once at least once, even if unit tests cover the parsing logic | Create a backup, delete/modify some local data, restore from that backup, confirm the preview screen accurately listed what would change and the restored data matches the original |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies (confirmed via `gsd-sdk query verify.plan-structure` against all 19 revised PLAN.md files — zero structural errors, only expected warnings on the two checkpoint tasks in 05-08/05-09/05-16)
- [x] Sampling continuity: no 3 consecutive tasks without automated verify (checkpoint tasks in 05-08/05-09/05-16 are immediately followed by an automated-verify task within the same plan)
- [x] Wave 0 covers all MISSING references (see Wave 0 Requirements above — all 25 stub files created by Plan 05-01)
- [x] No watch-mode flags
- [x] Feedback latency < 90s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved (2026-07-27, post-revision — all plan-checker blockers and warnings resolved)

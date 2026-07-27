---
phase: 5
slug: nutrition-co-estimator-dashboard-insights-weight-notifications-export-local-mode-shippable
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-27
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

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 05-xx-xx | TBD | TBD | NUTR-01 | unit | `flutter test test/domain/services/daily_totals_calculator_test.dart` | ❌ W0 | ⬜ pending |
| 05-xx-xx | TBD | TBD | CO2-02 | unit | `flutter test test/domain/services/personal_co2_multiplier_test.dart` | ❌ W0 | ⬜ pending |
| 05-xx-xx | TBD | TBD | CO2-03 | widget + DAO | `flutter test test/features/co2_settings/ test/data/local/co2_settings_dao_test.dart` | ❌ W0 | ⬜ pending |
| 05-xx-xx | TBD | TBD | CO2-06 | widget | `flutter test test/features/data_analysis/improvement_opportunities_test.dart` | ❌ W0 | ⬜ pending |
| 05-xx-xx | TBD | TBD | DASH-01–08 | widget | `flutter test test/features/dashboard/` | ❌ W0 (extends existing dir) | ⬜ pending |
| 05-xx-xx | TBD | TBD | WT-01–05 | unit + widget | `flutter test test/features/weight/ test/domain/services/notification_service_test.dart` | ❌ W0 | ⬜ pending |
| 05-xx-xx | TBD | TBD | NOTIF-01–03 | unit (mocked plugin) | `flutter test test/domain/services/notification_service_test.dart` | ❌ W0 | ⬜ pending |
| 05-xx-xx | TBD | TBD | PRIV-01–04 | unit + integration | `flutter test test/domain/services/backup_export_service_test.dart` | ❌ W0 | ⬜ pending |
| 05-xx-xx | TBD | TBD | PRIV-08/09/AUTH-07 | offline-proof | `flutter test test/core/offline_phase5_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*Exact task IDs/plans/waves to be filled in by the planner once PLAN.md files exist.*

---

## Wave 0 Requirements

- [ ] `test/domain/services/daily_totals_calculator_test.dart` — covers NUTR-01/CO2-02, including sugar/fiber/sodium null-snapshot handling (schema gap discovered in research)
- [ ] `test/domain/services/personal_co2_multiplier_test.dart` — covers CO2-02/CO2-03 (separate-layer, forward-only recalc model)
- [ ] `test/domain/services/notification_service_test.dart` — covers NOTIF-01–03 with a mocked `FlutterLocalNotificationsPlugin`
- [ ] `test/domain/services/backup_export_service_test.dart` — covers PRIV-01–04, including a zip-slip-attempt fixture
- [ ] `test/data/local/co2_settings_dao_test.dart`, `weight_entry_dao_test.dart`, `notification_prefs_dao_test.dart` — new DAO coverage, mirroring existing `food_catalog_dao_ranking_test.dart` conventions
- [ ] `test/core/offline_phase5_test.dart` — extends the Phase-4 `offline_logging_test.dart` pattern to prove no Phase-5-introduced code path touches the network (AUTH-07/PRIV-08)
- [ ] Framework install: none — `flutter_test`/`mocktail` already present; no new test framework needed

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Meal/weigh-in reminder actually fires at scheduled local time on a real device | NOTIF-01, NOTIF-02 | OS-level scheduled notification delivery cannot be reliably asserted in a Dart/Flutter widget-test sandbox; requires real device clock + backgrounding | Set a reminder 1–2 minutes out on a real iOS and real Android device, background the app, confirm the notification appears and tapping it opens logging pre-set to the correct slot |
| OS share sheet actually opens with the backup file attached | PRIV-02 | `share_plus` invokes native platform share UI, not observable in widget tests | On a real device, tap "Create Backup" → confirm the native share sheet appears with a valid archive file attached, and that at least one destination (e.g. Files/Drive) receives it successfully |
| Restore preview + confirmation correctly reflects a real prior backup's contents | PRIV-04 | End-to-end round-trip (export → restore) against a real generated archive is best verified manually once at least once, even if unit tests cover the parsing logic | Create a backup, delete/modify some local data, restore from that backup, confirm the preview screen accurately listed what would change and the restored data matches the original |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 90s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

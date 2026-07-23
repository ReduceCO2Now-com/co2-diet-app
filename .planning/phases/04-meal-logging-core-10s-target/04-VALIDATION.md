---
phase: 4
slug: meal-logging-core-10s-target
status: ready
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-23
updated: 2026-07-23
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (unit/widget) + `integration_test` (on-device benchmarks), both already configured |
| **Config file** | none dedicated — `pubspec.yaml` `dev_dependencies` (`flutter_test`, `integration_test`, `mocktail: 1.0.5`) |
| **Quick run command** | `flutter test test/` |
| **Full suite command** | `flutter test test/ && flutter test integration_test/ --device-id <id>` |
| **Estimated runtime** | ~30-60s (unit/widget) + device-dependent for integration |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/` (fast unit/widget subset relevant to the task)
- **After every plan wave:** Run `flutter test test/ && flutter test integration_test/meal_logging_benchmark_test.dart` (device required for the latter)
- **Before `/gsd:verify-work`:** Full suite must be green + LOG-13's literal manual real-hardware user-testing checkpoint (per CONTEXT.md, this cannot be waived by the automated benchmark alone)
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 04-01 T1/T2 | 04-01 | 0 | LOG-05..LOG-13 (stub scaffolding) | unit/widget/integration stubs | `flutter test test/` | ✅ W0 | ⬜ pending |
| 04-02 T1/T2 | 04-02 | 2 | LOG-05/06/07/08/10/11 (schema) | schema | `flutter test test/data/local/schema_test.dart` | ✅ W0 | ⬜ pending |
| 04-03 T1 | 04-03 | 2 | LOG-06 | unit | `flutter test test/domain/entities/meal_entry_test.dart` | ✅ W0 | ⬜ pending |
| 04-03 T2 | 04-03 | 2 | LOG-10 | unit | `flutter test test/domain/entities/user_food_test.dart test/domain/entities/serving_size_test.dart` | ✅ W0 | ⬜ pending |
| 04-04 T1 | 04-04 | 3 | LOG-05/07/08/09 | unit (DAO) | `flutter test test/data/local/meal_entry_dao_test.dart` | ✅ W0 | ⬜ pending |
| 04-04 T2 | 04-04 | 3 | LOG-10/11 | unit (DAO) | `flutter test test/data/local/user_food_dao_test.dart` | ✅ W0 | ⬜ pending |
| 04-05 T1 | 04-05 | 4 | LOG-05/07/08/09 | unit (repo) | `flutter test test/data/repositories/meal_entry_repository_test.dart` | ✅ W0 | ⬜ pending |
| 04-05 T2 | 04-05 | 4 | LOG-10/11 | unit (repo) | `flutter test test/data/repositories/user_food_repository_test.dart` | ✅ W0 | ⬜ pending |
| 04-06 T1 | 04-06 | 4 | LOG-11 | unit | `flutter test test/domain/entities/food_item_test.dart` | ✅ (existing) | ⬜ pending |
| 04-06 T2 | 04-06 | 4 | LOG-11 | unit (DAO — override precedence) | `flutter test test/data/local/food_catalog_dao_override_test.dart` | ✅ W0 | ⬜ pending |
| 04-07 T1 | 04-07 | 5 | LOG-05/07/09 | unit (notifier) | `flutter test test/features/meal_logging/meal_entry_notifier_test.dart` | ✅ W0 | ⬜ pending |
| 04-07 T2 | 04-07 | 5 | LOG-08/10/11 | unit (notifier) | `flutter test test/features/food_search/favorites_test.dart test/features/my_foods/user_food_notifier_test.dart` | ✅ W0 | ⬜ pending |
| 04-08 T1 | 04-08 | 6 | LOG-06/10/11 | widget | `flutter test test/features/my_foods/custom_food_form_test.dart` | ✅ W0 | ⬜ pending |
| 04-08 T2 | 04-08 | 6 | LOG-10 | analyze (screen, no dedicated stub) | `flutter analyze lib/features/my_foods/ lib/features/settings/screens/settings_screen.dart lib/core/router/app_router.dart` | n/a | ⬜ pending |
| 04-09 T1 | 04-09 | 6 | LOG-05/06/11/13 | analyze (sheet reconciliation) | `flutter analyze lib/features/food_search/widgets/food_detail_sheet.dart lib/features/barcode_scan/screens/barcode_scan_screen.dart` | n/a | ⬜ pending |
| 04-09 T2 | 04-09 | 6 | LOG-05/06/08/13 | widget | `flutter test test/features/food_search/portion_slot_form_test.dart` | ✅ W0 | ⬜ pending |
| 04-10 T1 | 04-10 | 7 | LOG-07/08 | unit (via favorites_test) | `flutter test test/features/food_search/favorites_test.dart` | ✅ W0 | ⬜ pending |
| 04-10 T2 | 04-10 | 7 | LOG-10 | analyze (no dedicated stub) | `flutter analyze lib/features/food_search/widgets/no_results_widget.dart` | n/a | ⬜ pending |
| 04-11 T1 | 04-11 | 7 | LOG-09 (package legitimacy) | human-verify checkpoint | n/a — blocking-human gate before install | n/a | ⬜ pending |
| 04-11 T2 | 04-11 | 7 | LOG-05/09 | widget | `flutter test test/features/dashboard/meal_entry_row_test.dart` | ✅ W0 | ⬜ pending |
| 04-12 T1 | 04-12 | 8 | LOG-13 | integration (Dart proxy, device-optional at plan-gate) | `flutter analyze integration_test/meal_logging_benchmark_test.dart` | ✅ W0 | ⬜ pending |
| 04-12 T2 | 04-12 | 8 | LOG-12 | unit/integration (zero-network assertion) | `flutter test test/features/meal_logging/offline_logging_test.dart` | ✅ W0 | ⬜ pending |
| 04-13 T1/T2 | 04-13 | 9 | LOG-05..LOG-13 (real-device sign-off) | integration + **manual real-device user testing (non-automatable)** | `flutter test test/ && flutter test integration_test/meal_logging_benchmark_test.dart -d <device_id>` | n/a | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*Task IDs reflect the final 13 plans (04-01 through 04-13) as written after the revision pass; every plan/task pair above corresponds 1:1 to a `<task>` in its `PLAN.md`.*

---

## Wave 0 Requirements

- [x] `test/data/local/meal_entry_dao_test.dart` — DAO tests for insert/merge/recent-query/same-day logic (covers LOG-05, LOG-07, LOG-09 groundwork) — created by Plan 04-01 Task 1, filled in by Plan 04-04 Task 1
- [x] `test/data/local/user_food_dao_test.dart` — DAO tests for custom food + override pair, search precedence (covers LOG-10, LOG-11) — created by Plan 04-01 Task 1, filled in by Plan 04-04 Task 2
- [x] `test/domain/entities/meal_entry_test.dart` — sentinel `copyWith`, live macro-scaling pure function (covers LOG-06) — created by Plan 04-01 Task 1, filled in by Plan 04-03 Task 1
- [x] `test/domain/entities/user_food_test.dart` — sentinel `copyWith`, required-fields validation — created by Plan 04-01 Task 1, filled in by Plan 04-03 Task 2
- [x] `test/features/meal_logging/meal_entry_notifier_test.dart` — AsyncNotifier mutation methods (log/merge/edit/delete/duplicate + undo) — created by Plan 04-01 Task 2, filled in by Plan 04-07 Task 1
- [x] `test/features/my_foods/user_food_notifier_test.dart` — AsyncNotifier mutation methods (save/override/revert) — created by Plan 04-01 Task 2, filled in by Plan 04-07 Task 2
- [x] `integration_test/meal_logging_benchmark_test.dart` — created by Plan 04-01 Task 2 (self-skip stub, `off_reference.sqlite`-fixture-absence precedent), filled in by Plan 04-12 Task 1 with `Stopwatch` + bounded `pump()` (never `pumpAndSettle()` — Undo snackbar auto-dismiss + swipe-reveal animations make it unsafe for timing)
- [x] Migration schema-dump script decision — Plan 04-02 Task 2 scopes `tool/generate_schema_v1.dart` explicitly out of tracking the live schemaVersion (documented, not updated)

*(No test framework installs needed — `flutter_test`, `integration_test`, `mocktail` already present.)*

*Additional Wave 0 stub files beyond the six listed above (`test/data/local/food_catalog_dao_override_test.dart`, `test/data/repositories/meal_entry_repository_test.dart`, `test/data/repositories/user_food_repository_test.dart`, `test/domain/entities/serving_size_test.dart`, `test/features/food_search/favorites_test.dart`, `test/features/my_foods/custom_food_form_test.dart`, `test/features/meal_logging/offline_logging_test.dart`, `test/features/food_search/portion_slot_form_test.dart`, `test/features/dashboard/meal_entry_row_test.dart`) are all created by Plan 04-01 and filled in by their respective owning plans per the Per-Task Verification Map above.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|--------------------|
| End-to-end tap-to-saved under 10s on real hardware | LOG-13 | Automated integration_test benchmark is a Dart-level proxy; the literal requirement demands real-device user testing on a mid-range physical device before phase closes | Install build on a mid-range physical Android/iOS device (TestFlight for iOS per Phase 3 precedent), airplane mode ON, time "Add Breakfast" tap → food saved → visible on dashboard with a stopwatch across several real users/attempts — performed in Plan 04-13's `checkpoint:human-verify` task |
| All core meal-logging flows function with airplane mode enabled | LOG-12 | Automated test can assert no network calls are invoked, but full airplane-mode UX (no hangs, no silent failures) needs a human pass on-device | Enable airplane mode on physical device, run through add-food, Recent, Favorites, custom-food creation, edit/delete/duplicate flows end-to-end — performed in Plan 04-13's `checkpoint:human-verify` task |
| `flutter_slidable` package legitimacy | LOG-09 (supporting) | pub.dev/Dart is not a slopcheck-supported ecosystem — independent human verification required per the Package Legitimacy Protocol | Visit pub.dev/github per Plan 04-11 Task 1's `checkpoint:human-verify` instructions before the package is installed |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify (the two `checkpoint:human-verify`/`checkpoint:human-action`-adjacent gaps — Plan 04-11 Task 1's package-legitimacy checkpoint and Plan 04-13's real-device checkpoint — are each immediately preceded/followed by automated-verify tasks)
- [x] Wave 0 covers all MISSING references — all 16 stub files created by Plan 04-01 before any implementation plan runs
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** Planning-time Nyquist compliance confirmed for all 13 plans (04-01 through 04-13). Execution-time sign-off (green suite + Plan 04-13's real-device human-verify) still pending — this file reflects plan-quality validation, not phase-completion status.

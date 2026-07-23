---
phase: 4
slug: meal-logging-core-10s-target
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-23
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
| TBD-01 | TBD | 0 | LOG-05 | unit (DAO/repo) + widget | `flutter test test/data/local/meal_entry_dao_test.dart` | ❌ W0 | ⬜ pending |
| TBD-02 | TBD | 0 | LOG-06 | unit | `flutter test test/domain/entities/meal_entry_test.dart -N "portion"` | ❌ W0 | ⬜ pending |
| TBD-03 | TBD | 0 | LOG-07 | unit (DAO query) + widget | `flutter test test/data/local/meal_entry_dao_test.dart -N "recent"` | ❌ W0 | ⬜ pending |
| TBD-04 | TBD | 0 | LOG-08 | unit + widget | `flutter test test/features/food_search/favorites_test.dart` | ❌ W0 | ⬜ pending |
| TBD-05 | TBD | 0 | LOG-09 | unit (repo) + widget (Slidable actions) | `flutter test test/features/meal_logging/meal_entry_notifier_test.dart` | ❌ W0 | ⬜ pending |
| TBD-06 | TBD | 0 | LOG-10 | unit + widget | `flutter test test/features/my_foods/custom_food_form_test.dart` | ❌ W0 | ⬜ pending |
| TBD-07 | TBD | 0 | LOG-11 | unit (DAO — override/original pair integrity) | `flutter test test/data/local/user_food_dao_test.dart -N "override"` | ❌ W0 | ⬜ pending |
| TBD-08 | TBD | 0 | LOG-12 | unit/integration (assert no network calls invoked in log path) | `flutter test test/features/meal_logging/offline_logging_test.dart` | ❌ W0 | ⬜ pending |
| TBD-09 | TBD | 0 | LOG-13 | integration_test (Dart proxy) + **manual real-device user testing (non-automatable)** | `flutter test integration_test/meal_logging_benchmark_test.dart --device-id <id>` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*Task IDs are placeholders — gsd-planner fills in real plan/task IDs when PLAN.md files are created.*

---

## Wave 0 Requirements

- [ ] `test/data/local/meal_entry_dao_test.dart` — DAO tests for insert/merge/recent-query/same-day logic (covers LOG-05, LOG-07, LOG-09 groundwork)
- [ ] `test/data/local/user_food_dao_test.dart` — DAO tests for custom food + override pair, search precedence (covers LOG-10, LOG-11)
- [ ] `test/domain/entities/meal_entry_test.dart` — sentinel `copyWith`, live macro-scaling pure function (covers LOG-06)
- [ ] `test/domain/entities/user_food_test.dart` — sentinel `copyWith`, required-fields validation
- [ ] `test/features/meal_logging/meal_entry_notifier_test.dart` — AsyncNotifier mutation methods (log/merge/edit/delete/duplicate + undo)
- [ ] `test/features/my_foods/user_food_notifier_test.dart` — AsyncNotifier mutation methods (save/override/revert)
- [ ] `integration_test/meal_logging_benchmark_test.dart` — new file; follow `food_search_benchmark_test.dart`/`co2_coverage_benchmark_test.dart` self-skip precedent (skip when off_reference.sqlite fixture absent), use bounded `pump()` not `pumpAndSettle()` (Undo snackbar auto-dismiss + swipe-reveal animations make `pumpAndSettle()` unsafe for timing)
- [ ] Migration schema-dump script decision — either update `tool/generate_schema_v1.dart` to track `schemaVersion` for new tables, or explicitly scope it out

*(No test framework installs needed — `flutter_test`, `integration_test`, `mocktail` already present.)*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| End-to-end tap-to-saved under 10s on real hardware | LOG-13 | Automated integration_test benchmark is a Dart-level proxy; the literal requirement demands real-device user testing on a mid-range physical device before phase closes | Install build on a mid-range physical Android/iOS device (TestFlight for iOS per Phase 3 precedent), airplane mode ON, time "Add Breakfast" tap → food saved → visible on dashboard with a stopwatch across several real users/attempts |
| All core meal-logging flows function with airplane mode enabled | LOG-12 | Automated test can assert no network calls are invoked, but full airplane-mode UX (no hangs, no silent failures) needs a human pass on-device | Enable airplane mode on physical device, run through add-food, Recent, Favorites, custom-food creation, edit/delete/duplicate flows end-to-end |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

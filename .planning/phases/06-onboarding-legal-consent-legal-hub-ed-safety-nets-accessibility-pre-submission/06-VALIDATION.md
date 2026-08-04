---
phase: 6
slug: onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-08-03
updated: 2026-08-04
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (SDK) + `mocktail 1.0.5` — both already pinned in `pubspec.yaml` |
| **Config file** | none dedicated — standard `flutter test` discovers `test/**/*_test.dart` |
| **Quick run command** | `flutter test test/domain/services/ed_safety_net_checker_test.dart` (or any single new/changed test file) |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30-60 seconds (consistent with prior phases' suite growth) |

---

## Sampling Rate

- **After every task commit:** Run the specific new/changed test file(s) for that task.
- **After every plan wave:** Run `flutter test` (full suite).
- **Before `/gsd:verify-work`:** Full suite must be green, plus the manual accessibility checklist (dark mode/contrast/tap-target spot check, SAM test, screen-reader pass) signed off in Plan 06-10.
- **Max feedback latency:** ~60 seconds.

---

## Per-Task Verification Map

| Plan | Wave | Requirement(s) | Test Type | Automated Command | File Exists | Status |
|------|------|-----------------|-----------|--------------------|-------------|--------|
| 06-01 (Task 1-2) | 0 | LEGAL-01/02/03, NFR-07, ONBD-01/05, PRIV-06 (stub scaffolding) | unit/widget stubs | `flutter test test/domain/services/ed_safety_net_checker_test.dart test/data/repositories/consent_repository_test.dart test/domain/services/legal_document_loader_test.dart test/features/legal/legal_consent_screen_test.dart test/features/legal/consent_history_screen_test.dart test/features/onboarding/onboarding_gate_test.dart` | ✅ created by 06-01 | ⬜ pending |
| 06-02 (Task 2) | 1 | LEGAL-03, LEGAL-04, LEG-02, LEG-03 | unit | `flutter test test/domain/services/legal_document_loader_test.dart` | ✅ W0 (06-01 T1) | ⬜ pending |
| 06-03 (Task 1) | 1 | NFR-07 | unit | `flutter test test/domain/services/ed_safety_net_checker_test.dart` | ✅ W0 (06-01 T1) | ⬜ pending |
| 06-04 (Task 1) | 2 | LEGAL-03 | unit | `flutter test test/data/repositories/consent_repository_test.dart` | ✅ W0 (06-01 T1) | ⬜ pending |
| 06-05 (Task 1) | 2 | ONBD-01/05 (provider-level slice) | unit | `flutter test test/features/onboarding/onboarding_gate_test.dart` | ✅ W0 (06-01 T2) | ⬜ pending |
| 06-06 | 2 | LEG-01 (pre-submission artifacts) | manifest lint + doc presence | `plutil -lint ios/Runner/PrivacyInfo.xcprivacy` | n/a (new artifacts) | ⬜ pending |
| 06-07 (Task 1) | 3 | LEGAL-01/02/03/04, LEG-02, ACC-02, ACC-03, ACC-05, NFR-01 | widget | `flutter test test/features/legal/legal_consent_screen_test.dart` | ✅ W0 (06-01 T2) | ⬜ pending |
| 06-08 (Task 2) | 3 | LEG-01/02/03, PRIV-06 | widget | `flutter test test/features/legal/consent_history_screen_test.dart` | ✅ W0 (06-01 T2) | ⬜ pending |
| 06-09 (Task 3) | 4 | ONBD-01/04/05, LEG-01, ACC-02 (full redirect-gate behavior) | widget/integration | `flutter test test/features/onboarding/onboarding_gate_test.dart` | ✅ W0 (06-01 T2) + 06-05 T1 supplement | ⬜ pending |
| 06-10 | 5 | ACC-01/03/04/05, NFR-01/02/03/04 | manual-only (3 checkpoints) | N/A — human verification checklist | manual | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*Filled in from the final 10-plan / 6-wave PLAN.md set. "Status" reflects execution state — flips to ✅ per plan as `/gsd-execute-phase 6` runs each plan's `<verify>` commands.*

---

## Wave 0 Requirements

All satisfied by Plan 06-01 (2 tasks, 6 files):

- [x] `test/domain/services/ed_safety_net_checker_test.dart` (06-01 Task 1) — filled in by 06-03, covers NFR-07 (calorie <1200kcal, BMI<17.5-with-missing-height-skip)
- [x] `test/data/repositories/consent_repository_test.dart` (06-01 Task 1) — filled in by 06-04, covers LEGAL-03 (mocktail on `ConsentRecordsDao`)
- [x] `test/domain/services/legal_document_loader_test.dart` (06-01 Task 1) — filled in by 06-02, covers the frontmatter parser round-trip
- [x] `test/features/legal/legal_consent_screen_test.dart` (06-01 Task 2) — filled in by 06-07, covers LEGAL-01/02, ACC-02/03
- [x] `test/features/legal/consent_history_screen_test.dart` (06-01 Task 2) — filled in by 06-08, covers PRIV-06's consent-history read path
- [x] `test/features/onboarding/onboarding_gate_test.dart` (06-01 Task 2) — partially filled by 06-05 (provider-level slice), fully filled by 06-09 (router-redirect behavior)
- [x] Framework install: none — `flutter_test`/`mocktail` already present in `pubspec.yaml`

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Dark mode contrast/legibility on real devices | ACC-01 | Contrast/visual judgment beyond golden-file diff's practical value; `buildDarkTheme()` already exists (built pre-Phase-6) — this is an audit pass, not construction | Toggle system dark mode on a real iOS + Android device; walk through Splash/Welcome/Legal Consent/Profile/Carousel/Dashboard/Legal Hub; confirm no illegible text or lost contrast (Plan 06-10, Checkpoint 1) |
| Color-blind-friendly charts/indicators | ACC-04 | Requires visual judgment against a color-blindness simulation, not a unit-testable property | Run existing Dashboard/Insights charts, the ConfidenceChip, and the new onboarding Carousel through a color-blindness simulator; confirm no red/green-only distinctions (Plan 06-10, Checkpoint 1) |
| Tap target sizing spot-check | ACC-05 | Layout measurement across real widget trees is better caught by an eyeball/ruler pass on real devices than a brittle golden test for every touch target | Manually verify ≥44×44pt on all new onboarding/legal-screen interactive elements on a real device (Plan 06-10, Checkpoint 1) |
| VoiceOver / TalkBack screen-reader pass on key flows | ACC-03 | Automated `Semantics` label presence is covered by widget tests (06-07/06-08), but an actual screen-reader traversal (focus order, announcement clarity) needs a human running the real assistive tech | Run VoiceOver (iOS) and TalkBack (Android) through the full onboarding flow + Legal Hub + ED safety-net modal; confirm every interactive element is announced clearly and focus order is logical (Plan 06-10, Checkpoint 2) |
| SAM (Self-Assessment Manikin) test | NFR-03 | Subjective emotional-response measurement — inherently requires real human testers, not automatable | Conduct SAM test with real user(s) walking through onboarding + ED safety-net warning; confirm app feels calm/supportive/non-stressful, not alarming or judgmental (Plan 06-10, Checkpoint 3) |
| Non-judgmental/non-preachy tone copy audit | NFR-01/02 | Qualitative language review, not a testable assertion | Read through all new onboarding/legal/ED-safety-net copy end-to-end; confirm no "you failed" framing, no letter-grades/alarm-red, no preachy CO2 language (Plan 06-10, Checkpoint 3) |
| Google Play Data Safety form + age rating questionnaire draft accuracy | LEG-01, pre-submission | Content of a drafted external-form answer-set doc, not app behavior — no automated test applies | Manually review `docs/PLAY_DATA_SAFETY_DRAFT.md` (Plan 06-06) against Play Console's actual current form fields before real submission |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies (confirmed via `gsd-sdk query verify.plan-structure` against all 10 PLAN.md files — zero structural errors; expected warnings only on the checkpoint tasks in 06-02 and 06-10)
- [x] Sampling continuity: no 3 consecutive tasks without automated verify (06-02's checkpoint task is immediately followed by two automated-verify tasks within the same plan; 06-10 is the terminal manual-only plan, consistent with 05-08/05-09/05-16/05-19's precedent of ending a phase's automated coverage before a dedicated manual gate)
- [x] Wave 0 covers all MISSING references (see Wave 0 Requirements above — all 6 stub files created by Plan 06-01)
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved (2026-08-04 — 10-plan/6-wave PLAN.md set finalized, all 23 phase requirement IDs traced to at least one plan, full source audit below)

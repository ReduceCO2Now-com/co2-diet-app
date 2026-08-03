---
phase: 6
slug: onboarding-legal-consent-legal-hub-ed-safety-nets-accessibility-pre-submission
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-08-03
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
- **Before `/gsd:verify-work`:** Full suite must be green, plus the manual accessibility checklist (dark mode/contrast/tap-target spot check, SAM test, screen-reader pass) signed off outside the automated suite.
- **Max feedback latency:** ~60 seconds.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 06-xx-xx | TBD | 0 | LEGAL-01/02 | widget | `flutter test test/features/legal/legal_consent_screen_test.dart` | ❌ W0 | ⬜ pending |
| 06-xx-xx | TBD | 0 | LEGAL-03 (repo) | unit (mocktail on `ConsentRecordsDao`) | `flutter test test/data/repositories/consent_repository_test.dart` | ❌ W0 | ⬜ pending |
| 06-xx-xx | TBD | — | LEGAL-03 (DAO) | unit (Drift, in-memory) | `flutter test test/data/local/consent_records_dao_test.dart` | ✅ exists (Phase 1) | ⬜ pending |
| 06-xx-xx | TBD | 0 | NFR-07 (calorie) | unit | `flutter test test/domain/services/ed_safety_net_checker_test.dart` | ❌ W0 | ⬜ pending |
| 06-xx-xx | TBD | 0 | NFR-07 (BMI) | unit | same file as above | ❌ W0 | ⬜ pending |
| 06-xx-xx | TBD | 0 | ONBD-01/05 | widget/integration | `flutter test test/features/onboarding/onboarding_gate_test.dart` | ❌ W0 | ⬜ pending |
| 06-xx-xx | TBD | 0 | ACC-02 | widget (overflow-assertion under `MediaQuery` text-scale override) | `flutter test test/features/onboarding/legal_consent_screen_test.dart` | ❌ W0 | ⬜ pending |
| 06-xx-xx | TBD | 0 | ACC-03 | widget (`find.bySemanticsLabel`) | included in each new screen's widget test | ❌ W0 | ⬜ pending |
| 06-xx-xx | TBD | 0 | PRIV-06 | widget | `flutter test test/features/legal/consent_history_screen_test.dart` | ❌ W0 | ⬜ pending |
| 06-xx-xx | TBD | 0 | markdown loader | unit | `flutter test test/domain/services/legal_document_loader_test.dart` | ❌ W0 | ⬜ pending |
| 06-xx-xx | TBD | — | ACC-01/04/05 | manual-only | N/A — visual/manual QA checklist | manual | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*Task IDs and plan/wave numbers are TBD — filled in by the planner once PLAN.md files exist.*

---

## Wave 0 Requirements

- [ ] `test/domain/services/ed_safety_net_checker_test.dart` — stubs for NFR-07 (calorie <1200kcal, BMI<17.5-with-height-missing-skip)
- [ ] `test/data/repositories/consent_repository_test.dart` — stubs for LEGAL-03 (mocktail on `ConsentRecordsDao`, mirrors existing repo test conventions)
- [ ] `test/features/legal/legal_consent_screen_test.dart` — stubs for LEGAL-01/02, ACC-02/03 on this screen
- [ ] `test/features/legal/consent_history_screen_test.dart` — stubs for PRIV-06's consent-history read path
- [ ] `test/features/onboarding/onboarding_gate_test.dart` — stubs for ONBD-01/05's redirect gating
- [ ] `test/domain/services/legal_document_loader_test.dart` — stubs for the markdown+frontmatter parser round-trip and malformed-input handling
- [ ] No new test framework/dependency install needed — `flutter_test`/`mocktail` already present in `pubspec.yaml`

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Dark mode contrast/legibility on real devices | ACC-01 | Contrast/visual judgment beyond golden-file diff's practical value; `buildDarkTheme()` already exists (built pre-Phase-6) — this is an audit pass, not construction | Toggle system dark mode on a real iOS + Android device; walk through Splash/Welcome/Legal Consent/Profile/Carousel/Dashboard/Legal Hub; confirm no illegible text or lost contrast |
| Color-blind-friendly charts/indicators | ACC-04 | Requires visual judgment against a color-blindness simulation, not a unit-testable property | Run existing Dashboard/Insights charts through a color-blindness simulator (e.g. Sim Daltonism) or manual deuteranopia/protanopia check; confirm no red/green-only distinctions |
| Tap target sizing spot-check | ACC-05 | Layout measurement across real widget trees is better caught by an eyeball/ruler pass on real devices than a brittle golden test for every touch target | Manually verify ≥44×44pt on all new onboarding/legal-screen interactive elements on a real device |
| VoiceOver / TalkBack screen-reader pass on key flows | ACC-03 | Automated `Semantics` label presence is covered by widget tests, but an actual screen-reader traversal (focus order, announcement clarity) needs a human running the real assistive tech | Run VoiceOver (iOS) and TalkBack (Android) through the full onboarding flow + Legal Hub + ED safety-net modal; confirm every interactive element is announced clearly and focus order is logical |
| SAM (Self-Assessment Manikin) test | NFR-03 | Subjective emotional-response measurement — inherently requires real human testers, not automatable | Conduct SAM test with real user(s) walking through onboarding + ED safety-net warning; confirm app feels calm/supportive/non-stressful, not alarming or judgmental |
| Non-judgmental/non-preachy tone copy audit | NFR-01/02 | Qualitative language review, not a testable assertion | Read through all new onboarding/legal/ED-safety-net copy end-to-end; confirm no "you failed" framing, no letter-grades/alarm-red, no preachy CO2 language |
| Google Play Data Safety form + age rating questionnaire draft accuracy | LEG-01, pre-submission | Content of a drafted external-form answer-set doc, not app behavior — no automated test applies | Manually review the drafted `docs/` answer-set doc against Play Console's actual current form fields before real submission |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

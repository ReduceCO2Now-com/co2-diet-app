---
phase: 7
slug: keycloak-auth-account-mode-sync
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-08-08
---

# Phase 7 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (unit/widget) + `integration_test` (device-level) + `mocktail` (mocking) — no dedicated config file beyond `pubspec.yaml`'s `dev_dependencies`, consistent with every prior phase |
| **Config file** | none — Wave 0 installs (no new framework/dependency needed; `mocktail`, `flutter_test`, `integration_test` already present) |
| **Quick run command** | `flutter test test/features/auth/` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30 seconds (quick) / consistent with existing full-suite runtime |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/features/auth/` (and `test/domain/services/methodology_version_checker_test.dart` for methodology-banner tasks)
- **After every plan wave:** Run `flutter test` (full suite)
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 07-XX-XX | TBD | TBD | AUTH-01 | widget | `flutter test test/features/auth/auth_screen_test.dart` | ❌ W0 | ⬜ pending |
| 07-XX-XX | TBD | TBD | AUTH-02 | unit | `flutter test test/features/auth/providers/auth_provider_test.dart` | ❌ W0 | ⬜ pending |
| 07-XX-XX | TBD | TBD | AUTH-03 | widget | `flutter test test/features/settings/widgets/account_section_test.dart` | ❌ W0 | ⬜ pending |
| 07-XX-XX | TBD | TBD | AUTH-04 | unit | `flutter test test/features/auth/auth_screen_test.dart` | ❌ W0 | ⬜ pending |
| 07-XX-XX | TBD | TBD | AUTH-05 / AUTH-06 | unit | `flutter test test/features/auth/providers/auth_provider_test.dart` | ❌ W0 | ⬜ pending |
| 07-XX-XX | TBD | TBD | AUTH-10 | ci | `dart run tool/check_privacy_deps.dart` (existing Phase 1 script) | ✅ existing | ⬜ pending |
| 07-XX-XX | TBD | TBD | PRIV-05 | unit + widget | `flutter test test/features/auth/providers/auth_provider_test.dart` and `test/features/settings/widgets/account_section_test.dart` | ❌ W0 | ⬜ pending |
| 07-XX-XX | TBD | TBD | (CO2 methodology banner, success criterion #5) | unit | `flutter test test/domain/services/methodology_version_checker_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*Task IDs and wave assignments are placeholders — the planner fills in real values when PLAN.md files are created.*

---

## Wave 0 Requirements

- [ ] `test/features/auth/auth_screen_test.dart` — stubs for AUTH-01, AUTH-04 (widget-level, mocked `AuthNotifier`/`url_launcher`)
- [ ] `test/features/auth/providers/auth_provider_test.dart` — stubs for AUTH-02, AUTH-05, AUTH-06, PRIV-05 (unit-level, mocked `flutter_appauth`/`flutter_secure_storage`/HTTP client)
- [ ] `test/features/settings/widgets/account_section_test.dart` — stubs for AUTH-03, PRIV-05 (widget-level)
- [ ] `test/domain/services/methodology_version_checker_test.dart` — stubs for the CO2 methodology-announcement mechanism
- [ ] `test/features/dashboard/widgets/co2_methodology_banner_test.dart` — widget-level dismissal-persistence stub
- [ ] All stubs use this project's established group-level `skip:` convention (verbatim, per every prior phase's Wave 0 precedent) — not individual per-test skips
- [ ] No new test framework/dependency install needed

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Apple Sign-in end-to-end via Keycloak IdP on a real iOS device | AUTH-05 | Requires a live, configured Keycloak realm + Apple IdP broker (does not exist yet per backend scan) + real Apple ID; cannot be mocked meaningfully | Once Tomris's realm is live: tap Apple button on a real iPhone, complete the Apple OAuth flow, confirm return to app in logged-in state |
| Google Sign-in end-to-end via Keycloak IdP on a real device | AUTH-06 | Same reason — requires live Keycloak + Google IdP broker | Once realm is live: tap Google button, complete OAuth flow, confirm logged-in state on both Android and iOS |
| Full email/password signup → verification email → login round trip against the real Keycloak realm | AUTH-01 | Requires a live realm with email delivery configured; local mocks can't verify actual email deliverability/link validity | Once realm is live: sign up with a real email, receive and click the verification link, confirm login succeeds only after verification |
| Account deletion against the real (not-yet-built) backend GDPR endpoint | PRIV-05 | Backend delete-account endpoint doesn't exist yet — this phase's automated tests only cover the client-side flow against a mocked response; the real endpoint is a coordination point with Tomris, not buildable/testable client-side alone | Once Tomris ships the endpoint: delete a real test account, confirm the Keycloak user record is gone and local data is untouched |
| App Store Guideline 4.8 compliance of the Keycloak-brokered (non-native-SDK) Apple Sign-in flow | AUTH-05 | No authoritative source confirms a web-broker Apple Sign-in passes App Store review; this is a real-world review-outcome question, not something a test can assert | Submit a TestFlight build with this flow early (before final submission) to probe App Store review reaction, per 07-RESEARCH.md's flagged highest-risk item |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

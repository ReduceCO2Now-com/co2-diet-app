---
phase: 1
slug: foundations-sync-safe-schema
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-16
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (SDK) + `dart test` for pure-Dart domain tests |
| **Config file** | None required — `dart test` discovers `test/` automatically |
| **Quick run command** | `dart test test/domain/` |
| **Full suite command** | `dart test && flutter test` |
| **Estimated runtime** | ~15 seconds (full suite) |

---

## Sampling Rate

- **After every task commit:** Run `dart test test/domain/` (pure-Dart, < 5 seconds)
- **After every plan wave:** Run `dart test && flutter test` (full suite)
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 15 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 1-formula-01 | TBD | 1 | PROF-04 | unit | `dart test test/domain/services/mifflin_st_jeor_test.dart` | ❌ Wave 0 | ⬜ pending |
| 1-formula-02 | TBD | 1 | PROF-04 | unit | `dart test test/domain/services/mifflin_st_jeor_test.dart` | ❌ Wave 0 | ⬜ pending |
| 1-formula-03 | TBD | 1 | PROF-04 | unit | `dart test test/domain/services/mifflin_st_jeor_test.dart` | ❌ Wave 0 | ⬜ pending |
| 1-override-01 | TBD | 1 | PROF-05 | unit | `dart test test/data/local/user_profile_dao_test.dart` | ❌ Wave 0 | ⬜ pending |
| 1-profile-dao-01 | TBD | 1 | PROF-01/02/03 | unit | `dart test test/data/local/user_profile_dao_test.dart` | ❌ Wave 0 | ⬜ pending |
| 1-schema-co2-01 | TBD | 1 | CO2-04 | unit | `dart test test/data/local/schema_test.dart` | ❌ Wave 0 | ⬜ pending |
| 1-schema-mixin-01 | TBD | 1 | Schema | unit | `dart test test/data/local/schema_test.dart` | ❌ Wave 0 | ⬜ pending |
| 1-consent-dao-01 | TBD | 1 | LEGAL-03 | unit | `dart test test/data/local/consent_records_dao_test.dart` | ❌ Wave 0 | ⬜ pending |
| 1-blocklist-pass-01 | TBD | 1 | PRIV-07 | unit | `dart test test/ci/blocklist_test.dart` | ❌ Wave 0 | ⬜ pending |
| 1-blocklist-fail-01 | TBD | 1 | PRIV-07 | unit | `dart test test/ci/blocklist_test.dart` | ❌ Wave 0 | ⬜ pending |
| 1-theme-tokens-01 | TBD | 1 | Theme | unit | `dart test test/core/theme/theme_token_test.dart` | ❌ Wave 0 | ⬜ pending |
| 1-theme-build-01 | TBD | 1 | Theme | unit | `dart test test/core/theme/theme_token_test.dart` | ❌ Wave 0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/domain/services/mifflin_st_jeor_test.dart` — covers PROF-04 formula correctness (known-input TDEE, null returns on missing fields, activity factor multipliers)
- [ ] `test/data/local/user_profile_dao_test.dart` — covers PROF-01/02/03/05 (upsert + retrieve round-trip; override replaces value, is_overridden flag set)
- [ ] `test/data/local/consent_records_dao_test.dart` — covers consent_records insert + read (append-only, UUID v7 PK, per-checkbox JSON column)
- [ ] `test/data/local/schema_test.dart` — covers CO2-04 (co2_methodology_version column exists, defaults to '1.0') + SyncSafeTable mixin injects all expected columns
- [ ] `test/ci/blocklist_test.dart` — covers PRIV-07 (script exits 0 for clean pubspec.lock; exits 1 when firebase_core present)
- [ ] `test/core/theme/theme_token_test.dart` — covers all DESIGN.md color tokens present in ColorScheme; ThemeData.light() and ThemeData.dark() build without error

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Profile screen renders correctly with DESIGN.md design tokens | PROF-01–05 | Visual correctness requires human eye | Launch app → navigate to Profile screen → verify colors, typography, spacing match DESIGN.md |
| — dash displayed when height/weight are empty | PROF-04 | UI rendering behavior | Clear height + weight fields → confirm targets show "—" not "0" or a placeholder value |
| Locale detection sets correct default unit | PROF-02 | Requires real device with non-default locale | Set device locale to US → verify Imperial default; set to DE → verify metric default |
| LicensePage shows all package licenses | PRIV-07 / LEG-04 | Runtime auto-discovery, not a static assertion | Navigate to About/Licenses → confirm list is non-empty and includes known packages |
| flutter build ios --no-codesign succeeds | CI | Requires macOS with Xcode | Run `flutter build ios --no-codesign` locally; verify no compilation errors |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 15s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

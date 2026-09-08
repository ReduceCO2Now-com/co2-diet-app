---
phase: 08
slug: encrypted-account-backup
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-09-08
---

# Phase 08 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (bundled with Flutter 3.44.6) + `mocktail` 1.0.5 + `fake_async` 1.3.3 |
| **Config file** | none — no `dart_test.yaml`; discovery is convention-based from `test/` |
| **Quick run command** | `flutter test test/domain/services/backup_archive_cipher_test.dart test/domain/services/backup_export_service_test.dart` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30s quick / full suite per existing 99-file baseline |

Device/integration: `flutter test integration_test/backup_encryption_benchmark_test.dart -d <device>` (new; follows `meal_logging_benchmark_test.dart` pattern). CI equivalent: `.github/workflows/ci.yml` runs the privacy-blocklist check, then `flutter analyze --no-fatal-warnings`, then `dart test`.

All crypto in `08-01` is pure Dart with no platform channels, so every `08-01` assertion runs in plain `flutter test` — no device, no mock platform channel, no backend required. That is the reason `08-01` is sequenced first.

---

## Sampling Rate

- **After every task commit:** `flutter test test/domain/services/backup_archive_cipher_test.dart test/domain/services/backup_export_service_test.dart` (sub-30s; Argon2id at 19 MiB is ~150ms/derivation — keep full-KDF test count small, use a reduced-memory profile where the KDF itself isn't under test)
- **After every plan wave:** `flutter test`
- **Before `/gsd:verify-work`:** `flutter analyze --no-fatal-warnings` clean **and** `flutter test` green **and** the device benchmark run
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 08-01-01 | 01 | 1 | SC-1 (round trip, tag length) | unit | `flutter test test/domain/services/backup_archive_cipher_test.dart` | ❌ W0 | ⬜ pending |
| 08-01-01 | 01 | 1 | SC-1 (tamper × 3, wrong key, randomness, KDF param round-trip) | unit | same | ❌ W0 | ⬜ pending |
| 08-01-02 | 01 | 1 | SC-2 (plaintext export regression, formatVersion compat) | unit | `flutter test test/domain/services/backup_export_service_test.dart` | ✅ extend existing | ⬜ pending |
| 08-01-02 | 01 | 1 | SC-3 (preview detects encrypted archive, passphrase prompt, wrong-passphrase inline error) | unit + widget | `flutter test test/domain/services/backup_export_service_test.dart test/features/backup/backup_restore_screen_test.dart` | ⚠️ partial | ⬜ pending |
| 08-01-03 | 01 | 1 | Perf (archive size + encrypt/decrypt wall time on device) | integration | `flutter test integration_test/backup_encryption_benchmark_test.dart -d <device>` | ❌ W0 | ⬜ pending |
| 08-02-01 | 02 | 2 | SC-4 (contract doc exists, `status: ASSUMED`, negative-scope section) | manual-only | — reviewed at `/gsd:verify-work` | n/a | ⬜ pending |
| 08-03-01 | 03 | 3 | SC-5 (push/pull request shape, 404→null, non-2xx/timeout typed exceptions) | unit | `flutter test test/data/remote/backup_api_client_test.dart` | ❌ W0 | ⬜ pending |
| 08-03-03 | 03 | 3 | SC-5 (sync section hidden while flag off / not in Account Mode) | widget | `flutter test test/features/backup/backup_restore_screen_test.dart` | ❌ W0 | ⬜ pending |
| 08-03-03 | 03 | 3 | SC-6 (no HLC/outbox/merge/conflict code introduced) | manual-only (grep-based structural check, see 08-03-03's automated verify) | — negative-existence claim | n/a | ⬜ pending |
| 08-01-01 | 01 | 1 | PRIV-07 (new dependency clears privacy blocklist, transitively) | unit | `flutter test test/ci/blocklist_test.dart` | ✅ exists, covers automatically | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

*Task ID key: 08-01-01 = Plan 08-01 Task 1 (BackupArchiveCipher); 08-01-02 = Plan 08-01 Task 2 (wire encryption through export/restore + screen); 08-01-03 = Plan 08-01's device-benchmark checkpoint (08-01 also has an unlisted Wave-0-preceding package-legitimacy checkpoint before Task 1, not independently verification-bearing). 08-02-01 = Plan 08-02 Task 1 (draft contract doc); 08-02-02 = Plan 08-02 Task 2 (cross-reference gdpr-account-deletion.md, not separately listed above -- no independent SC row). 08-03-01 = Plan 08-03 Task 1 (BackupSyncConfig + BackupApiClient); 08-03-02 = Plan 08-03 Task 2 (BackupSyncNotifier + DI, not separately listed above -- covered transitively by 08-03-03's widget tests); 08-03-03 = Plan 08-03 Task 3 (BackupSyncSection widget + screen wiring + SC-6 grep self-check).

---

## Wave 0 Requirements

- [ ] `test/domain/services/backup_archive_cipher_test.dart` — SC-1 (round trip, tag length, tamper × 3, wrong key, randomness, KDF parameter round-trip)
- [ ] `test/data/remote/backup_api_client_test.dart` — SC-5 request shape, 404→null, non-2xx, timeout (mocktail `http.Client`, mirroring `test/data/remote/reference_pack_api_client_test.dart`)
- [ ] `test/features/backup/providers/backup_sync_notifier_test.dart` — SC-5 notifier orchestration
- [ ] `integration_test/backup_encryption_benchmark_test.dart` — device-measured archive size + encrypt/decrypt wall time
- [ ] Extend `test/domain/services/backup_export_service_test.dart` — SC-2 regressions, SC-3 preview detection, wrong-passphrase-writes-nothing
- [ ] Extend `test/features/backup/backup_restore_screen_test.dart` — SC-3 prompt + error copy, SC-5 flag/account gating
- [ ] No framework install needed — `flutter_test`, `mocktail` and `integration_test` are already dependencies

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Backend contract document review | SC-4 | A markdown proposal document has no runnable assertion — correctness is Tomris's review, not a test | Read `docs/backend-contracts/` doc against the `gdpr-account-deletion.md` template shape; confirm `status: ASSUMED` frontmatter and explicit negative-scope section present |
| No sync/HLC/outbox/conflict code introduced | SC-6 | Negative-existence claim — resolved by an automated grep in Plan 08-03 Task 3 (08-03-03) rather than pure diff review, but flagged here since a grep can never fully substitute for human judgment on "nothing sync-shaped was introduced" | `! grep -rniE "outbox|hybridlogicalclock|hlcclock|conflictresolver|lastwritewins|mergeconflict"` across 08-03's new files (see 08-03-03's `<verify>`); spot-check the diff against the phase boundary in `08-CONTEXT.md` if in doubt |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

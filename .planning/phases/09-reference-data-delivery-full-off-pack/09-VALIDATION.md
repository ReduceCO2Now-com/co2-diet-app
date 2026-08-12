---
phase: 9
slug: reference-data-delivery-full-off-pack
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-08-12
---

# Phase 9 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` + `mocktail` (existing project standard, used consistently since Phase 1) |
| **Config file** | none — no dedicated test-runner config exists in this project; tests run via `flutter test` |
| **Quick run command** | `flutter test test/features/reference_data/ test/data/local/reference_pack/` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30 seconds (quick), ~3-5 minutes (full suite, project-wide) |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/features/reference_data/ test/data/local/reference_pack/`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 09-XX-XX | TBD | 0 | Manifest fetch + version comparison logic | unit | `flutter test test/data/local/reference_pack/reference_pack_repository_test.dart` | ❌ W0 | ⬜ pending |
| 09-XX-XX | TBD | 0 | Disk-space preflight blocks download when insufficient | unit | `flutter test test/data/local/reference_pack/disk_space_check_test.dart` | ❌ W0 | ⬜ pending |
| 09-XX-XX | TBD | 0 | Checksum verification accepts matching / rejects mismatched hash | unit | `flutter test test/data/local/reference_pack/checksum_verifier_test.dart` | ❌ W0 | ⬜ pending |
| 09-XX-XX | TBD | ? | Settings row subtitle reflects each status state (seed/downloading/full/update-available) | widget | `flutter test test/features/settings/reference_data_row_test.dart` | ❌ W0 | ⬜ pending |
| 09-XX-XX | TBD | ? | Revert confirmation dialog + disk reclaim + schedule reset to Manual | widget | `flutter test test/features/reference_data/reference_data_screen_test.dart` | ❌ W0 | ⬜ pending |
| 09-XX-XX | TBD | ? | Foreground-triggered Weekly/Monthly throttle check (extends `lib/app.dart` observer) | unit | `flutter test test/app_lifecycle_reference_pack_test.dart` | ❌ W0 | ⬜ pending |
| 09-XX-XX | TBD | ? | `products_fts` stays in sync after a delta apply | integration | `flutter test integration_test/reference_pack_delta_apply_test.dart` | ❌ W0 | ⬜ pending |
| 09-XX-XX | TBD | ? | Actual resumable download (pause/resume/Wi-Fi-drop/background-continuation) | manual / real-device | N/A — cannot be automated against `background_downloader`'s native platform channels | manual-only, justified | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*Task IDs and wave assignments to be finalized by gsd-planner.*

---

## Wave 0 Requirements

- [ ] `test/data/local/reference_pack/reference_pack_repository_test.dart` — manifest parsing, version comparison
- [ ] `test/data/local/reference_pack/disk_space_check_test.dart` — preflight logic
- [ ] `test/data/local/reference_pack/checksum_verifier_test.dart` — SHA-256 match/mismatch
- [ ] `test/features/settings/reference_data_row_test.dart` — subtitle state rendering
- [ ] `test/features/reference_data/reference_data_screen_test.dart` — download screen, revert dialog
- [ ] `integration_test/reference_pack_delta_apply_test.dart` — real SQLite fixture proving `products_fts` sync after delta apply (single highest-value new test this phase needs — `products_fts` has no sync trigger, grep-confirmed in `tools/ingest_off.py`)
- [ ] Mock HTTP client for manifest tests: reuse the existing `_MockHttpClient extends Mock implements http.Client` convention (see `test/features/auth/providers/auth_provider_test.dart`) rather than inventing a new mocking approach

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Resumable download: pause/resume, Wi-Fi-drop auto-pause/resume, background continuation while app is backgrounded | Success criterion 1 (pause/resume, Wi-Fi-only default) | `background_downloader`'s pause/resume/background-continuation relies on native `URLSession`/`WorkManager` platform channels — cannot be meaningfully exercised in `flutter_test`; same class of requirement as Phase 3's barcode-scanning P0 and Phase 7's Keycloak real-device gates | On a real device: start download on Wi-Fi, toggle Wi-Fi off mid-transfer and confirm auto-pause, toggle back on and confirm auto-resume, background the app and confirm progress continues, kill and reopen the app and confirm manual "Resume" restores from the partial file |
| Atomic live swap of `off_reference.sqlite` while `AppDatabase` connection is already open (DETACH/re-ATTACH cycle) | Success criterion 3 (transparent download, revert) | No existing code path exercises a live re-ATTACH while queries may be in flight — needs verification against the real SQLite driver on-device, not just a unit-level mock | On a real device: trigger a full-pack download to completion while performing food searches, confirm no crash/query failure during the swap moment, confirm search results reflect full catalog immediately after |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

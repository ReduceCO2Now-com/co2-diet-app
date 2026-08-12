---
phase: 9
slug: reference-data-delivery-full-off-pack
status: draft
nyquist_compliant: true
wave_0_complete: true
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
| 09-01-T1/T2/T3 | 09-01 | 0 (wave 1) | Wave 0 stub scaffolding for all 7 test files below | scaffold | `flutter test test/data/local/reference_pack/ test/features/settings/reference_data_row_test.dart test/features/reference_data/ test/app_lifecycle_reference_pack_test.dart integration_test/reference_pack_delta_apply_test.dart` | ✅ planned | ⬜ pending execution |
| 09-04-T2 | 09-04 | 4 | Manifest fetch + version comparison logic, incl. delta-download completion driving DeltaApplier | unit | `flutter test test/data/local/reference_pack/reference_pack_repository_test.dart` | ✅ planned (Wave 0 stub → filled) | ⬜ pending execution |
| 09-02-T1 | 09-02 | 2 | Disk-space preflight blocks download when insufficient | unit | `flutter test test/data/local/reference_pack/disk_space_check_test.dart` | ✅ planned (Wave 0 stub → filled) | ⬜ pending execution |
| 09-02-T1 | 09-02 | 2 | Checksum verification accepts matching / rejects mismatched hash | unit | `flutter test test/data/local/reference_pack/checksum_verifier_test.dart` | ✅ planned (Wave 0 stub → filled) | ⬜ pending execution |
| 09-05-T2 | 09-05 | 5 | Settings row subtitle reflects each status state (seed/downloading/full/update-available) | widget | `flutter test test/features/settings/reference_data_row_test.dart` | ✅ planned (Wave 0 stub → filled) | ⬜ pending execution |
| 09-05-T3 (+ 09-06-T2 schedule-reset wiring) | 09-05 / 09-06 | 5 / 6 | Revert confirmation dialog + disk reclaim + schedule reset to Manual | widget | `flutter test test/features/reference_data/reference_data_screen_test.dart` | ✅ planned (Wave 0 stub → filled by 09-05, extended by 09-06) | ⬜ pending execution |
| 09-06-T2 | 09-06 | 6 | Foreground-triggered Weekly/Monthly throttle check (extends `lib/app.dart` observer) | unit | `flutter test test/app_lifecycle_reference_pack_test.dart` | ✅ planned (Wave 0 stub → filled) | ⬜ pending execution |
| 09-04-T1 | 09-04 | 4 | `products_fts` stays in sync after a delta apply | integration | `flutter test integration_test/reference_pack_delta_apply_test.dart` | ✅ planned (Wave 0 stub → filled) | ⬜ pending execution |
| 09-08 (checkpoint 1) | 09-08 | 7 | Actual resumable download (pause/resume/Wi-Fi-drop/background-continuation) | manual / real-device | N/A — cannot be automated against `background_downloader`'s native platform channels | N/A — real-device checkpoint, not a file | ⬜ pending execution |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
*"pending execution" = plan finalized and validated structurally; phase has not yet been run via `/gsd-execute-phase 9`.*

---

## Wave 0 Requirements

- [x] `test/data/local/reference_pack/reference_pack_repository_test.dart` — manifest parsing, version comparison (created by 09-01-T1, filled by 09-04-T2)
- [x] `test/data/local/reference_pack/disk_space_check_test.dart` — preflight logic (created by 09-01-T1, filled by 09-02-T1)
- [x] `test/data/local/reference_pack/checksum_verifier_test.dart` — SHA-256 match/mismatch (created by 09-01-T1, filled by 09-02-T1)
- [x] `test/features/settings/reference_data_row_test.dart` — subtitle state rendering (created by 09-01-T2, filled by 09-05-T2)
- [x] `test/features/reference_data/reference_data_screen_test.dart` — download screen, revert dialog (created by 09-01-T2, filled by 09-05-T3, extended by 09-06-T2)
- [x] `integration_test/reference_pack_delta_apply_test.dart` — real SQLite fixture proving `products_fts` sync after delta apply (created by 09-01-T3, filled by 09-04-T1 — single highest-value new test this phase needs, `products_fts` has no sync trigger, grep-confirmed in `tools/ingest_off.py`)
- [x] Mock HTTP client for manifest tests: reuses the existing `_MockHttpClient extends Mock implements http.Client` convention (see `test/features/auth/providers/auth_provider_test.dart`) — applied in 09-03-T1's `reference_pack_api_client_test.dart` and mirrored via mocktail mocks in 09-04-T2's `reference_pack_repository_test.dart`, rather than inventing a new mocking approach

All seven Wave 0 stub files are created in a single Wave-1 plan (09-01), each with a group-level `skip:` marker and named placeholder cases, mirroring the Phase 2-7 Wave 0 precedent — satisfying the Nyquist "no verify command points at a nonexistent file" contract before any later plan's `<verify>` runs.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Resumable download: pause/resume, Wi-Fi-drop auto-pause/resume, background continuation while app is backgrounded | Success criterion 1 (pause/resume, Wi-Fi-only default) | `background_downloader`'s pause/resume/background-continuation relies on native `URLSession`/`WorkManager` platform channels — cannot be meaningfully exercised in `flutter_test`; same class of requirement as Phase 3's barcode-scanning P0 and Phase 7's Keycloak real-device gates | Plan 09-08, real-device checkpoint 1 (Wave 7): on a real device, start download on Wi-Fi, toggle Wi-Fi off mid-transfer and confirm auto-pause, toggle back on and confirm auto-resume, background the app and confirm progress continues, force-kill and reopen the app and confirm manual "Resume" restores from the partial file, confirm explicit Cancel deletes the partial file |
| Atomic live swap of `off_reference.sqlite` while `AppDatabase` connection is already open (DETACH/re-ATTACH cycle) | Success criterion 3 (transparent download, revert) | No existing code path exercises a live re-ATTACH while queries may be in flight — needs verification against the real SQLite driver on-device, not just a unit-level mock | Plan 09-08, real-device checkpoint 2 (Wave 7): on a real device, trigger a full-pack download to completion while performing food searches, confirm no crash/query failure during the swap moment, confirm search results reflect full catalog immediately after |

Both manual verifications are covered by Plan 09-08 (Wave 7, `autonomous: false`), which also builds a local Range-capable `tool/dev/range_test_server.dart` so these checks do not block on a real CDN (an explicit out-of-scope coordination point per 09-CONTEXT.md).

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies — every `auto`/`tdd` task across 09-01 through 09-08 has an `<automated>` verify command; the four `checkpoint:human-verify`/`checkpoint:human-verify` tasks (package-legitimacy in 09-02, both real-device checks in 09-08) are checkpoints by design, gated on prior automated work
- [x] Sampling continuity: no 3 consecutive tasks without automated verify — checkpoints in 09-02 and 09-08 are each immediately preceded/followed by automated tasks within the same plan
- [x] Wave 0 covers all MISSING references — 09-01 creates all 7 Wave 0 stub files referenced by every later plan's `<verify>` command
- [x] No watch-mode flags — no `--watch` or equivalent used in any plan's verify command
- [x] Feedback latency < 30s — quick-run command scoped to `test/features/reference_data/` + `test/data/local/reference_pack/` completes well under 30s per the Test Infrastructure table above
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** Structurally satisfied by the finalized 8-plan/7-wave structure (09-01 through 09-08, revision pass complete 2026-08-12) — pending actual green-run confirmation once `/gsd-execute-phase 9` runs.

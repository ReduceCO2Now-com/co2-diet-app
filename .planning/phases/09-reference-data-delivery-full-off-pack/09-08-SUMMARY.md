---
phase: 09-reference-data-delivery-full-off-pack
plan: 08
subsystem: infra
tags: [real-device-verification, background_downloader, sqlite, android, resumable-download, atomic-swap]

# Dependency graph
requires:
  - "09-06 — ReferencePackScheduleNotifier + Co2DietApp foreground scheduled-check wiring"
  - "09-07 — tools/build_reference_pack_release.py (smoketest fixture generator)"
provides:
  - "tool/dev/range_test_server.dart — local Range-capable dart:io HttpServer test double for a not-yet-existing real CDN, reusable for any future regression"
  - "Real-device proof (Samsung Galaxy Tab S7 FE, SM-T733, Android 14) that resumable/pausable/background-continuing downloads and the live SQLite DETACH/re-ATTACH swap both work under real platform-channel and real filesystem conditions — closing 09-VALIDATION.md's two Manual-Only Verifications"
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "android/app/src/main/res/xml/network_security_config.xml — debug-only trust anchor for a self-signed dev-server cert, refused under kReleaseMode; mirrors background_downloader's own bypassTLSCertificateValidation debug-only guard"
    - "compute() isolate offload for CPU-bound gzip decompression on the main Flutter isolate — first instance of this pattern in the codebase; any future large synchronous decode on the swap/extract path should follow it"

key-files:
  created:
    - tool/dev/range_test_server.dart
  modified:
    - lib/data/local/reference_pack/download_manager.dart
    - lib/data/local/reference_pack/reference_pack_repository.dart
    - lib/data/local/reference_pack/reference_pack_extractor.dart
    - lib/data/local/reference_pack/reference_pack_api_client.dart
    - android/app/build.gradle.kts
    - android/app/src/main/res/xml/network_security_config.xml
    - android/app/src/main/AndroidManifest.xml

key-decisions:
  - "Real CDN remains explicitly out of scope for this phase (per 09-CONTEXT.md/09-RESEARCH.md) — both checkpoints verified against the local Range-capable dev server, not a production endpoint; logged as a Pre-Launch Blocker, not silently dropped"
  - "compileSdk floor raised project-wide for third-party library subprojects (not just app-level) after storage_space's stale compileSdk 33 broke the build against newer androidx transitive deps — a build-config fix, not a feature change, but directly blocked this plan's real-device verification from starting at all"
  - "gzip decompression during swapIn() moved off the main isolate via compute() — synchronous decompression of a real ~123MB payload froze the UI thread long enough to trigger an Android ANR, invisible to every existing automated test because none decompresses a real full-size payload"
  - "revertToSeed() now copies the seed's bytes to a staging file before any deletion, then renames into place — the prior delete-then-ATTACH sequence assumed the seed path and installed-pack path were independent files, but in production they resolve to the exact same on-disk file (off_reference.sqlite), so the old code deleted the seed's only copy before ever reading it"

requirements-completed: []

# Metrics
duration: "~10 hours (real-device session, includes live debugging across 5 discovered defects)"
completed: 2026-09-03
---

# Phase 9 Plan 08: Real-Device Verification — Resumable Download + Live Atomic Swap Summary

**Both of 09-VALIDATION.md's Manual-Only Verifications (resumable/pausable/background-continuing downloads and the live SQLite DETACH/re-ATTACH swap-while-querying) proved out on a real Samsung Galaxy Tab S7 FE (Android 14), after live debugging surfaced and fixed 5 genuine defects no automated test had caught — closing Phase 9.**

## Performance

- **Duration:** ~10 hours real-device session (2026-09-03, spanning build-fix, resumable-download debugging, and swap/decompression debugging)
- **Completed:** 2026-09-03
- **Tasks:** 3/3 completed (Task 1 automated setup; both checkpoints approved)
- **Files modified:** 1 created (`tool/dev/range_test_server.dart`), plus fixes across `lib/data/local/reference_pack/`, `android/app/build.gradle.kts`, and Android network-security config as real-device testing surfaced defects

## Accomplishments

- Built `tool/dev/range_test_server.dart`: a standalone `dart:io HttpServer` serving a file with HTTP Range support (206 Partial Content + `Content-Range`), a stable per-process ETag, and a proxied `/manifest.json`, with LAN-usage instructions printed on startup — reusable for any future regression without needing a real CDN.
- Regenerated the smoketest fixture (`/tmp/reference-pack-release-smoketest/full_vsmoketest-v1.sqlite.gz` + `manifest.json`) via `tools/build_reference_pack_release.py`, and ran the full `flutter test` suite (green) plus the privacy blocklist audit (clean) before any device testing began.
- **Real-device checkpoint 1 (resumable download mechanics) — APPROVED.** All 8 verification steps confirmed on the Galaxy Tab S7 FE: real moving progress, auto-pause/resume across a Wi-Fi drop with no user action, continued progress while backgrounded, partial-file survival + manual Resume after a force-kill, correct continuation from the partial byte count (not from 0%), and immediate partial-file deletion on Cancel.
- **Real-device checkpoint 2 (live atomic swap while querying) — APPROVED.** A full-pack download completed while Food Search was actively queried back-to-back through the exact "Downloading… → Full catalog installed" transition, with zero crashes, zero database-locked/SQLITE_BUSY errors, and correct full-catalog results once the swap completed. Revert-to-starter-pack was also exercised live and correctly restored the seed pack without corruption (only possible after Bug 5 below was fixed — the pre-fix code corrupted the installed database on every real revert).
- 5 real, previously-undiscovered defects were found and fixed live during device testing (all already committed to `main` before this plan closed) — see Deviations below. All 553 project tests pass as of the last commit; the temporary real-device manifestUrl override in `lib/domain/services/reference_pack_config.dart` was reverted back to its `cdn.example.com` placeholder and confirmed to produce zero git diff against `HEAD`.

## Task Commits

Each task/fix was committed atomically:

1. **Task 1: Local Range-test-server + regenerated fixture** — `76d7855` (feat), `a3e7871` (fix: HTTPS + in-memory manifest pack_url rewrite for the test server)
2. **Bug 1 — Android build broken by stale third-party compileSdk** — `7ea3e84` (fix)
3. **Bug 2 — resume() silently no-ops with no resume data** — `105070c` (fix)
4. **Bug 3 — test server bind race on transient address-in-use** — `9851ed5` (fix)
5. **Bug 4 — self-signed TLS cert rejected + dead manifest fetch hangs forever** — `21b1af8` (fix)
6. **Bug 5 — decompression ANR + revert-corrupts-database** — `01ea2c6` (fix)

Also relevant from the same real-device session, landed just before this plan's Task 1: `0b02bb8` (fix: iOS deployment target 13.0→14.0 for `background_downloader`), `73da6d1` (fix: pin Android compileSdk to 37 for `flutter_secure_storage`), `19164cd` (fix: retroactive migration for `co2_methodology_version(_snapshot)`).

## Files Created/Modified

- `tool/dev/range_test_server.dart` — dev-only local Range-capable HTTP test server; never imported by or bundled with the shipping app (per this plan's threat model, T-09-08-01)
- `lib/data/local/reference_pack/download_manager.dart` — `resume()` now falls back to re-enqueuing from scratch when no native resume data exists after a connection-level failure
- `lib/data/local/reference_pack/reference_pack_repository.dart` — `resumeDownload()` wired through the same from-scratch fallback
- `lib/data/local/reference_pack/reference_pack_extractor.dart` — gzip decompression moved to a background isolate via `compute()`; `revertToSeed()` now stages a copy of the seed bytes before any deletion, then renames into place, instead of delete-then-ATTACH
- `lib/data/local/reference_pack/reference_pack_api_client.dart` — `fetchManifest()` now has a 15s timeout (previously hung indefinitely on a dead/unreachable `manifestUrl`) plus diagnostic logging through the download path
- `android/app/build.gradle.kts` — compileSdk floor raised for third-party library subprojects (the `storage_space` plugin's stale compileSdk 33 broke the build against newer androidx transitive deps)
- `android/app/src/main/res/xml/network_security_config.xml`, `android/app/src/main/AndroidManifest.xml` — debug-only trust anchor for the local dev server's self-signed TLS cert, refused under `kReleaseMode`
- `tool/dev/range_test_server.dart` regenerated `/tmp/reference-pack-release-smoketest/full_vsmoketest-v1.sqlite.gz` + `manifest.json` (not committed — ephemeral fixture, matches Plan 09-07's own precedent)

## Decisions Made

- **Real CDN stays explicitly out of scope** — both checkpoints were verified against the local Range-capable dev server built in this plan's Task 1, per 09-CONTEXT.md/09-RESEARCH.md's Environment Availability table. This is logged as a Pre-Launch Blocker (see STATE.md), not silently dropped.
- **compileSdk floor raised for third-party library subprojects, not just the app module** — a single app-level compileSdk bump does not propagate to library subprojects with their own stale AAR metadata; Bug 1 required raising the floor project-wide.
- **compute() isolate offload for gzip decompression** — the only way to avoid an Android ANR when decompressing a real, full-size (~123MB) payload synchronously on the main Flutter isolate; no existing automated test exercises a payload large enough to have caught this.
- **revertToSeed() stages before deleting** — `bundledSeedPath` and the installed-pack path resolve to the identical on-disk file (`off_reference.sqlite`) in production (confirmed via `first_launch_extractor.dart`'s `ensureOffReferenceDb()` and `ReferencePackExtractor`'s own `installedPath`), so the previous delete-then-ATTACH sequence silently destroyed the seed's only copy before ever reading it. No unit-test fixture exercised this because test fixtures use two distinct files.

## Deviations from Plan

### Auto-fixed Issues

PLAN.md's Task 1 scope (build the local test server, regenerate the fixture, run the full regression suite) executed exactly as written and passed. Both checkpoints, however, surfaced 5 real bugs during live real-device testing that the plan did not and could not anticipate — this is precisely why 09-08 exists as a dedicated real-device-verification plan rather than trusting `flutter test`'s mocked coverage. All 5 were genuine defects (not mocked-away edge cases), auto-fixed under Rule 1/Rule 3 (bugs / blocking issues preventing the checkpoint from passing), verified against the full regression suite, and committed individually before the corresponding checkpoint was re-attempted and approved:

**1. [Rule 3 - Blocking] Android build broken by stale third-party compileSdk**
- **Found during:** Attempting to build for the real device, before checkpoint 1 could even start
- **Issue:** `storage_space` plugin's Android subproject declared `compileSdk 33`, which failed an AAR metadata check against newer androidx transitive dependencies pulled in by this phase's own packages, blocking the Android build entirely.
- **Fix:** Raised the compileSdk floor for third-party library subprojects in `android/app/build.gradle.kts`.
- **Files modified:** `android/app/build.gradle.kts`
- **Commit:** `7ea3e84`

**2. [Rule 1 - Bug] resume() silently no-ops with no resume data**
- **Found during:** Checkpoint 1, step 6/7 (force-kill + manual Resume)
- **Issue:** `DownloadManager.resume()` / `ReferencePackRepository.resumeDownload()` did nothing when a connection-level failure (e.g. "Connection refused") left no native resume data — the Resume tap appeared to do nothing.
- **Fix:** `resume()` now falls back to re-enqueuing the original request from scratch when no resume data is available.
- **Files modified:** `lib/data/local/reference_pack/download_manager.dart`, `lib/data/local/reference_pack/reference_pack_repository.dart`
- **Commit:** `105070c`

**3. [Rule 3 - Blocking] Test server bind race on transient address-in-use**
- **Found during:** Repeated checkpoint 1 iterations (killing and restarting the local test server between test runs)
- **Issue:** `tool/dev/range_test_server.dart`'s `HttpServer.bind` had no retry; a brief OS-level delay releasing a just-killed prior instance's socket surfaced as an immediate fatal error, interrupting the verification session.
- **Fix:** Added a bounded retry with backoff around the bind call.
- **Files modified:** `tool/dev/range_test_server.dart`
- **Commit:** `9851ed5`

**4. [Rule 1 - Bug] Self-signed TLS cert rejected + dead manifest fetch hangs forever**
- **Found during:** Checkpoint 1/2 setup, pointing the device at the local HTTPS test server
- **Issue:** `background_downloader`'s native downloader rejected the test server's self-signed cert (`CertPathValidatorException`) even after installing the cert and configuring Android's Network Security Config. Separately, `ReferencePackApiClient.fetchManifest()` had no timeout and hung indefinitely with zero error surfaced when pointed at a dead/unreachable `manifestUrl`.
- **Fix:** Added `android/app/src/main/res/xml/network_security_config.xml` (debug-only) plus `background_downloader`'s own `bypassTLSCertificateValidation` config (also debug-only, refused under `kReleaseMode`). Added a 15s timeout to `fetchManifest()` plus diagnostic logging through the download path.
- **Files modified:** `android/app/src/main/res/xml/network_security_config.xml`, `android/app/src/main/AndroidManifest.xml`, `lib/data/local/reference_pack/reference_pack_api_client.dart`
- **Commit:** `21b1af8`

**5. [Rule 1 - Bug] Decompression ANR + revert-corrupts-database**
- **Found during:** Checkpoint 2 (live atomic swap) — swap-time ANR on a real ~123MB payload, and a separate corruption discovered while exercising Revert-to-starter-pack
- **Issue:** (a) `ReferencePackExtractor.swapIn()`'s gzip decompression ran synchronously on the main Flutter isolate, blocking the UI thread long enough to trigger an Android ANR on a real full-size payload. (b) `revertToSeed()` assumed the bundled seed path and the installed-pack path were independent files, but in production they are always the exact same file (`off_reference.sqlite`) — the old delete-then-ATTACH sequence deleted the seed's only copy before ever reading it, silently corrupting the installed database to an empty file on every real revert.
- **Fix:** (a) Moved decompression to a background isolate via `compute()`. (b) `revertToSeed()` now copies the seed's bytes to a staging file before any deletion, then renames into place.
- **Files modified:** `lib/data/local/reference_pack/reference_pack_extractor.dart`
- **Commit:** `01ea2c6`

## Issues Encountered

None beyond the 5 auto-fixed bugs documented above — all were found, fixed, and verified within this plan's own real-device session before the corresponding checkpoint was approved.

## User Setup Required

None ongoing. The real-device checkpoints required a physical Android tablet on the same Wi-Fi network as the dev machine running `tool/dev/range_test_server.dart` — a one-time manual setup for this verification session, not a recurring requirement.

## Next Phase Readiness

- Phase 9 (Reference Data Delivery — Full OFF Pack) is now **complete**: 8/8 plans, both real-device checkpoints approved, 553 tests green, privacy blocklist clean.
- **Real CDN integration remains an explicit Pre-Launch Blocker**, not a Phase 9 completion blocker: this phase proved the client-side mechanics (resumable download, atomic swap, revert) against a throwaway local server per 09-CONTEXT.md/09-RESEARCH.md's documented scope boundary. Pointing `ReferencePackConfig.manifestUrl` at a real production CDN, plus verifying real-world CDN behaviors (stable strong ETags, real network conditions, real payload sizes at scale) is still outstanding and logged in STATE.md.
- No blockers to closing Phase 9 itself. The next roadmap phase to route to is either Phase 8 (Encrypted Account Backup — still parked pending Tomris's backend decision) or Phase 10 (Post-Launch Enhancements — placeholder, not yet planned).

---
*Phase: 09-reference-data-delivery-full-off-pack*
*Completed: 2026-09-03*

## Self-Check: PASSED (re-verified)

- FOUND: tool/dev/range_test_server.dart
- FOUND commit: 76d7855 (Task 1: local test server)
- FOUND commit: a3e7871 (fix: HTTPS + manifest rewrite)
- FOUND commit: 7ea3e84 (Bug 1: compileSdk floor)
- FOUND commit: 105070c (Bug 2: resume-from-scratch fallback)
- FOUND commit: 9851ed5 (Bug 3: test server bind retry)
- FOUND commit: 21b1af8 (Bug 4: TLS trust + manifest timeout)
- FOUND commit: 01ea2c6 (Bug 5: decompression ANR + revert corruption fix)
- CONFIRMED: `git diff` against `lib/domain/services/reference_pack_config.dart` is empty (temporary real-device override fully reverted)

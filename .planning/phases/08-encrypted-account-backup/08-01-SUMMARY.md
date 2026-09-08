---
phase: 08-encrypted-account-backup
plan: 01
subsystem: auth
tags: [pointycastle, argon2id, aes-256-gcm, compute, isolate, backup, encryption]

# Dependency graph
requires:
  - phase: 05-privacy-first-mvp-dashboard
    provides: BackupExportService (plaintext formatVersion 1 export/backup/restore pipeline, BackupNotifier, Backup & Restore screen)
  - phase: 09-reference-data-delivery-full-off-pack
    provides: the compute()-for-blocking-native-work precedent (reference_pack_extractor.dart, Phase 9 commit 01ea2c6) this plan's device-benchmark fix follows
provides:
  - BackupArchiveCipher (Argon2id + AES-256-GCM, all PointyCastle work run via compute() on a background isolate)
  - BackupExportService formatVersion 2 encrypted archive (manifest.json + payload.enc), formatVersion 1 unchanged, supportedFormatVersions={1,2}
  - PassphrasePromptDialog (create-mode with unrecoverability warning + checkbox, enter-mode with inline wrong-passphrase retry)
  - Encrypt-toggle create path and encrypted-detected restore path in BackupRestoreScreen
  - Real-device-measured encrypt/decrypt timing for a realistic 600-row dataset
affects: [08-02-backend-contract-specification, 08-03-client-push-pull]

# Tech tracking
tech-stack:
  added: [pointycastle ^4.0.0]
  patterns:
    - "compute()-wrapped crypto: top-level function taking a primitives-only record in, PointyCastle objects constructed inside the isolate body, bytes out -- mirrors reference_pack_extractor.dart's _decompressGzipFile (Phase 9, commit 01ea2c6)"
    - "formatVersion 2 envelope: plaintext manifest.json (KDF+cipher params) bound as AEAD associated data, wrapping an unmodified formatVersion 1 zip as payload.enc"

key-files:
  created:
    - lib/domain/services/backup_archive_cipher.dart
    - test/domain/services/backup_archive_cipher_test.dart
    - lib/features/backup/widgets/passphrase_prompt_dialog.dart
    - integration_test/backup_encryption_benchmark_test.dart
  modified:
    - pubspec.yaml
    - lib/domain/services/backup_export_service.dart
    - lib/features/backup/providers/backup_notifier.dart
    - lib/features/backup/screens/backup_restore_screen.dart
    - test/domain/services/backup_export_service_test.dart
    - test/features/backup/backup_restore_screen_test.dart
    - ios/Runner/Info.plist

key-decisions:
  - "pointycastle ^4.0.0 approved via blocking package-legitimacy checkpoint (verified publisher bouncycastle.org, MIT, 140/160 pub score, dependency graph limited to collection+convert already in lockfile)"
  - "BackupArchiveCipher.deriveKey/encrypt/decrypt each run via compute() -- device benchmark showed encrypt/decrypt is ~99% Argon2id (905ms of 916ms at 13.1 KiB), which blocked the calling isolate long enough that a CircularProgressIndicator could not animate; compute() does not make Argon2id faster, it moves the block off the UI isolate"
  - "PointyCastle objects (Argon2BytesGenerator, GCMBlockCipher) are never sent across the isolate boundary -- only primitives (passphrase String, salt/nonce/plaintext/ciphertext Uint8List, KDF params as plain ints) cross in; the cipher objects are constructed inside the compute() top-level function body, mirroring reference_pack_extractor.dart's established pattern (Phase 9, commit 01ea2c6)"
  - "Automatic backups (PRIV-03) stay unencrypted by design, not as a gap -- PRIV-03 is a persisted user preference with no scheduler, and BackupExportService.createBackup() has only user-initiated call sites, so there is no automatic/background path that could silently produce a backup encrypted with a since-forgotten passphrase (per 08-RESEARCH.md's PRIV-03 x passphrase interaction note)"
  - "ITSAppUsesNonExemptEncryption=true added to Info.plist -- this app now ships its own AES-256-GCM rather than relying solely on OS HTTPS, so the previous implicit export-compliance exemption no longer applies. The resulting annual BIS self-classification (ERN) filing is Ali's administrative/legal call, not resolved here (08-RESEARCH.md Pitfall 8) -- flagged as a pre-launch item, same tracking convention as NFR-03's SAM test"

patterns-established:
  - "Pure-Dart crypto class in domain/services/ (no drift/riverpod/flutter/material imports) doing all its heavy PointyCastle work through compute() -- the class's public methods are Future<Uint8List>, callers await"

requirements-completed: [AUTH-09]

# Metrics
duration: 55min
completed: 2026-09-08
---

# Phase 8 Plan 1: Client-side encrypted backup (Argon2id + AES-256-GCM via compute()) Summary

**BackupExportService now produces/restores a formatVersion 2 Argon2id-derived-key + AES-256-GCM encrypted archive alongside the unchanged formatVersion 1 plaintext one, with all PointyCastle work routed through `compute()` after a real-device measurement showed it would otherwise block the UI isolate for ~900ms.**

## Performance

- **Duration:** ~55 min across the session (checkpoint-interrupted; this continuation covers Task 3's device-benchmark checkpoint fix through plan close)
- **Tasks:** 3 (Task 0 checkpoint approved, Task 1, Task 2) + 1 fix task (compute() routing) + Task 3 checkpoint (device benchmark, resolved)
- **Files modified:** 3 in the compute() fix (backup_archive_cipher.dart, backup_export_service.dart, backup_archive_cipher_test.dart); 11 total across the whole plan

## Accomplishments

- `BackupArchiveCipher`: Argon2id (OWASP m=19456 KiB/t=2/p=1) key derivation + AES-256-GCM authenticated encryption, pure bytes-in/bytes-out, no DAO/Riverpod/Flutter imports.
- `BackupExportService` formatVersion 2 encrypted wrapper: plaintext `manifest.json` (KDF + cipher params, bound as AEAD associated data) + `payload.enc` (the unmodified formatVersion 1 zip, encrypted). formatVersion 1 stays byte-for-byte unchanged; `supportedFormatVersions = {1, 2}`.
- `PassphrasePromptDialog`: create-mode (passphrase + confirm + mandatory plain-language unrecoverability warning + a separate unchecked confirmation checkbox) and enter-mode (single field, inline wrong-passphrase retry error).
- `BackupRestoreScreen`: "Encrypt this backup" toggle on Create Backup; auto-detects an encrypted archive on Restore and prompts for the passphrase instead of failing with a parse error.
- Real-device benchmark (`integration_test/backup_encryption_benchmark_test.dart`) seeding 600 rows (300 meal entries, 200 weigh-ins, 100 custom foods) across the actual DAOs, measuring `createBackup`/`applyRestore` end to end on a real Android tablet.
- **Device-benchmark checkpoint fix (this continuation):** `BackupArchiveCipher.deriveKey`/`encrypt`/`decrypt` now each run their PointyCastle work inside `compute()` on a background isolate, because the original on-device measurement showed the work is ~99% Argon2id and blocks the calling isolate for most of a second -- long enough that a spinner on that isolate cannot animate. Re-measured post-fix: wall-clock time is materially unchanged (as expected -- `compute()` doesn't make Argon2id faster), but the work is no longer on the UI thread.

## Device Benchmark Results (real hardware, not simulator)

**Device:** SM T733 (Samsung Galaxy Tab S7 FE), Android 14, real USB-connected device -- not a simulator.

**Pre-`compute()` measurement (original Task 3 checkpoint run, work on the calling/UI isolate):**
- Archive size: 13.1 KiB
- Encrypt (`createBackup`) wall-clock: 916ms
- Decrypt (`applyRestore`) wall-clock: 711ms

**Post-`compute()` measurement (this continuation, same benchmark, work now on a background isolate):**
- Archive size: 13,027 bytes (12.7 KiB) -- same seeded dataset shape, byte-count varies run to run with the random salt/nonce/timestamp fields
- Encrypt (`createBackup`) wall-clock: 896ms
- Decrypt (`applyRestore`) wall-clock: 805ms

**Interpretation:** wall-clock time did not meaningfully drop (896ms/805ms vs 916ms/711ms is within normal run-to-run variance for the same Argon2id cost), confirming the expected reasoning: `compute()` moves the work off the UI isolate, it does not make Argon2id faster. The change that matters is *where* the ~900ms happens, not how long it takes -- a `CircularProgressIndicator` on the UI isolate can now actually animate while `createBackup`/`applyRestore` run, because that isolate is free to pump frames instead of being blocked inside the Argon2id/AES-GCM call.

**Why the 13.1 KiB archive is smaller than 08-RESEARCH.md's 100KB-1MB estimate:** likely a mix of the synthetic seed data (300 meal entries / 200 weigh-ins / 100 custom foods with short repeated field values) compressing unusually well under deflate, and the research estimate itself being pessimistic for a still-hypothetical "multi-year heavy user" dataset that has never been measured against real user data. Round trip and every assertion (correct-passphrase restore, wrong-passphrase rejection, tamper detection) passed at this size, so it is not treated as a defect -- but the 100KB-1MB estimate should not be reused for future capacity/performance planning without a re-measurement against a real (not synthetic) dataset.

**Why the cost is dominated by the KDF, not the archive:** at 13.1 KiB, AES-256-GCM's own cost is on the order of ~11ms (consistent with 08-RESEARCH.md's measured ~600ms/MB AES-GCM throughput scaled down); the remaining ~900ms is Argon2id key derivation, which is a fixed cost independent of archive size. A larger realistic archive (say 300 KB) would not materially change this profile -- the KDF cost stays roughly constant while the AES-GCM cost grows only a little. Anyone revisiting this operation's performance in the future should tune Argon2id's `memoryKiB`/`iterations` parameters (the actual cost driver), not the cipher or the payload size.

**Why automatic (PRIV-03) backups stay unencrypted:** per 08-RESEARCH.md's "PRIV-03 x passphrase" interaction note, PRIV-03 is a persisted user preference with no scheduler behind it, and `BackupExportService.createBackup()` has only user-initiated call sites in the current codebase. There is therefore no automatic/background backup path today that could silently produce an archive encrypted with a passphrase the user set months earlier and has since forgotten -- the scenario 08-RESEARCH.md flagged as a risk does not currently exist to be mitigated. This should be re-examined if/when an automatic scheduled backup path is ever built.

## Task Commits

Each task was committed atomically:

1. **Package legitimacy checkpoint: pointycastle** - approved (no code change)
2. **Task 1: BackupArchiveCipher (Argon2id + AES-256-GCM)** - `172580a` (feat)
3. **Task 2: Wire encryption through export/restore + Backup screen** - `67233a1` (feat)
4. **Device benchmark checkpoint fix: route encrypt/decrypt through compute()** - `e617b71` (fix)
5. **Device benchmark checkpoint: real archive size + encrypt/decrypt wall time** - resolved (re-measured post-fix, see above; no further code change required)

**Plan metadata:** this commit (docs: complete plan)

## Files Created/Modified

- `lib/domain/services/backup_archive_cipher.dart` - Argon2id + AES-256-GCM, all crypto work run via `compute()`; top-level `_deriveKeyIsolate`/`_gcmProcessIsolate` functions take primitives-only records, construct PointyCastle objects inside the isolate body
- `lib/domain/services/backup_export_service.dart` - formatVersion 2 encrypted wrapper create/preview/restore; four call sites now `await` the now-`Future<Uint8List>` cipher methods
- `test/domain/services/backup_archive_cipher_test.dart` - every cipher call awaited; round-trip/tamper/wrong-key/randomness assertions unchanged
- `lib/features/backup/widgets/passphrase_prompt_dialog.dart` - create/enter passphrase dialogs
- `lib/features/backup/providers/backup_notifier.dart` - optional passphrase plumbing
- `lib/features/backup/screens/backup_restore_screen.dart` - encrypt toggle, encrypted-detected restore prompt
- `test/domain/services/backup_export_service_test.dart` - encrypted round trip, wrong-passphrase-leaves-DB-untouched, formatVersion 1 regression
- `test/features/backup/backup_restore_screen_test.dart` - encrypt-toggle path, encrypted-preview path, wrong-passphrase retry path
- `integration_test/backup_encryption_benchmark_test.dart` - real-device 600-row benchmark
- `ios/Runner/Info.plist` - `ITSAppUsesNonExemptEncryption` set to `true`
- `pubspec.yaml` / `pubspec.lock` - `pointycastle ^4.0.0`

## Decisions Made

See `key-decisions` in frontmatter. Most consequential for future phases: the `compute()`-wrapped crypto pattern (top-level function of primitives, PointyCastle objects constructed inside the isolate, mirroring `reference_pack_extractor.dart`) is now the second precedent for this pattern in the codebase (first was Phase 9's gzip decompression) and should be the template for any future CPU-heavy work that must not block the UI isolate.

## Deviations from Plan

### Auto-fixed Issues

**1. [Checkpoint feedback, not a Rule 1-3 auto-fix] Routed encrypt/decrypt through `compute()`**
- **Found during:** Task 3 checkpoint (device benchmark) -- user did not approve the original 916ms/711ms measurement as-is
- **Issue:** The original implementation ran Argon2id derivation and AES-GCM cipher work synchronously on the calling isolate. At 916ms, that isolate (the UI isolate, in the real `BackupNotifier`/`BackupRestoreScreen` call path) is blocked long enough that a `CircularProgressIndicator` cannot actually animate -- the "spinner is acceptable UX" assumption in the original Task 3 checkpoint text does not hold under the condition being measured.
- **Fix:** `BackupArchiveCipher.deriveKey`/`encrypt`/`decrypt` now each call `compute()` with a top-level function taking a primitives-only record (passphrase/salt/nonce/key/plaintext/ciphertext as `String`/`Uint8List`, KDF params as plain `int`s); `Argon2BytesGenerator`/`GCMBlockCipher` are constructed inside the isolate function body, since PointyCastle instances cannot cross an isolate boundary. Public methods are now `Future<Uint8List>`; the four call sites in `backup_export_service.dart` were updated to `await` them.
- **Files modified:** `lib/domain/services/backup_archive_cipher.dart`, `lib/domain/services/backup_export_service.dart`, `test/domain/services/backup_archive_cipher_test.dart`
- **Verification:** `flutter test test/domain/services/backup_archive_cipher_test.dart test/domain/services/backup_export_service_test.dart test/features/backup/backup_restore_screen_test.dart` -- all 42 tests pass, behavior unchanged. `flutter analyze --no-fatal-warnings` clean on all three changed files. Re-ran the real-device benchmark (SM T733) post-fix: 896ms encrypt / 805ms decrypt at 12.7 KiB -- materially unchanged wall-clock, confirming the fix addresses isolate placement, not raw speed.
- **Committed in:** `e617b71`

---

**Total deviations:** 1 (checkpoint-driven architectural fix, not a Rule 1-3 auto-fix -- required explicit user direction since it changed a public API's return type from `Uint8List` to `Future<Uint8List>`)
**Impact on plan:** Necessary for correctness of the UX claim the original checkpoint text made ("spinner is acceptable"). No scope creep beyond what the user's checkpoint feedback specified.

## Issues Encountered

None beyond the checkpoint-driven fix documented above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plan 08-01 is complete and independently verifiable (round trip, tamper, wrong-key, all runnable in `flutter test`; device benchmark re-confirmed on real hardware). Ready for Wave 2 (`08-02`, backend contract specification), which is independent of this plan's internals and depends only on `docs/backend-contracts/` conventions already established elsewhere in the project.

**Pre-launch blocker carried forward (not a Phase 8 completion blocker):** `ITSAppUsesNonExemptEncryption=true` now requires Ali's administrative/legal call on the annual BIS self-classification (ERN) filing before App Store submission -- tracked the same way NFR-03's SAM test is tracked in `STATE.md`'s Pre-Launch Blockers.

---
*Phase: 08-encrypted-account-backup*
*Completed: 2026-09-08*

## Self-Check: PASSED

All key-files (created and modified) verified present on disk. All three task/fix commits (`172580a`, `67233a1`, `e617b71`) verified present in `git log`.

---
phase: 08-encrypted-account-backup
verified: 2026-09-09T10:10:27Z
status: passed
score: 6/6 must-haves verified
---

# Phase 8: Encrypted Account Backup (client-first) Verification Report

**Phase Goal:** Deliver everything on the client side of the backup boundary that does not require a backend, and specify the backend half in writing. Concretely: encrypt the backup archive on-device so it is opaque before it leaves, publish a contract proposal for the push/pull API, and implement the client against that proposal behind a flag defaulted off.

**Verified:** 2026-09-09T10:10:27Z
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (ROADMAP.md Success Criteria)

| # | Truth (Success Criterion) | Status | Evidence |
|---|---|---|---|
| 1 | Backup archive can be encrypted on-device such that its contents are unreadable without the user's key, verified by encrypt→restore round trip and a wrong-key attempt failing safely | ✓ VERIFIED | `BackupArchiveCipher` (Argon2id + AES-256-GCM) at `lib/domain/services/backup_archive_cipher.dart`; round-trip, tamper x3, wrong-key, randomness, KDF-parameter tests all pass (`test/domain/services/backup_archive_cipher_test.dart`, 21+ tests green). `BackupExportService.applyRestore` with a wrong passphrase throws `WrongBackupPassphraseException` and `verifyNever`s every DAO write (`test/domain/services/backup_export_service_test.dart`). |
| 2 | Phase 5's plaintext export remains available and unchanged | ✓ VERIFIED | `currentFormatVersion = 1` untouched in `backup_export_service.dart`; `createBackup(passphrase: null)` path is byte-identical to pre-Phase-8 code; regression test `"createBackup() with no passphrase still produces formatVersion 1..."` passes. |
| 3 | Restore detects an encrypted archive and prompts for the key, rather than failing with a parse error | ✓ VERIFIED | `previewRestore` reads only the plaintext manifest for a formatVersion 2 archive and returns `RestorePreview.encrypted(...)` with `isEncrypted: true`, no passphrase required; `BackupRestoreScreen` branches on `_restorePreview!.isEncrypted` to show "This backup is encrypted" + "Enter passphrase" instead of a parse error. Widget test confirms this path. |
| 4 | A written backend contract for push/pull exists in docs/backend-contracts/, marked [ASSUMED], stating explicitly what the backend is NOT asked to do | ✓ VERIFIED | `docs/backend-contracts/encrypted-backup-blob.md` (195 lines): `status: ASSUMED` frontmatter, 17+ `[ASSUMED]`-tagged fields, explicit "What the backend is explicitly NOT being asked to do" section (no decrypt/inspect/merge/per-field access/server-side key material), retention/deletion section cross-referencing `gdpr-account-deletion.md`, 5 numbered open questions for Tomris. Reciprocal cross-reference confirmed present in `gdpr-account-deletion.md` (Open Question 5). |
| 5 | Client push/pull is implemented against that proposed contract, account-gated, behind a feature flag defaulted off, with request shape asserted against a mock (not end-to-end verifiable — must be recorded, not discovered later) | ✓ VERIFIED | `BackupSyncConfig.enabled = false` (compile-time const); `BackupApiClient.push/pull` mirror `ReferencePackApiClient`'s convention with a mocked `http.Client` in `test/data/remote/backup_api_client_test.dart` (request shape, 404-to-null, non-2xx, timeout — all green); `BackupSyncSection` gates on `backupSyncEnabledProvider && authProvider is AuthAuthenticated`, verified hidden-by-default and hidden-outside-Account-Mode by widget tests. The "not end-to-end verifiable" limitation is explicitly recorded in 08-03-SUMMARY.md's "Next Phase Readiness" section and in the plan's own `<verification>` block — not discovered later. |
| 6 | No conflict-resolution or merge logic is built (no bidirectional sync, no HLC, no outbox, no LWW) | ✓ VERIFIED | Automated grep self-check (`! grep -rniE "outbox|hybridlogicalclock|hlcclock|conflictresolver|lastwritewins|mergeconflict" lib/domain/services/backup_sync_config.dart lib/data/remote/backup_api_client.dart lib/features/backup/providers/backup_sync_notifier.dart lib/features/backup/widgets/backup_sync_section.dart`) exits 0 — confirmed independently by this verifier, not just claimed in the SUMMARY. |

**Score:** 6/6 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|---|---|---|---|
| `lib/domain/services/backup_archive_cipher.dart` | Pure bytes-in/bytes-out Argon2id + AES-256-GCM, no DAO/Riverpod/Flutter imports (except `compute`) | ✓ VERIFIED | Present, 213 lines. Only import beyond `dart:*`/`pointycastle` is `package:flutter/foundation.dart show compute` — consistent with the domain-layer rule (compute is a pure-Dart-compatible utility, not UI). |
| `lib/domain/services/backup_export_service.dart` | formatVersion 2 encrypted wrapper, supportedFormatVersions={1,2}, WrongBackupPassphraseException, RestorePreview.isEncrypted | ✓ VERIFIED | All four present and wired exactly as specified; `_encryptInPlace`/`applyRestore` implement Pattern 1/2/4 from research. |
| `lib/features/backup/widgets/passphrase_prompt_dialog.dart` | Create-mode + enter-mode dialogs | ✓ VERIFIED | `PassphrasePromptDialog.showCreate`/`showEnter`, unrecoverability warning text present verbatim, `kMinPassphraseLength = 10`, confirmation checkbox gating submit. |
| `test/domain/services/backup_archive_cipher_test.dart` | Round trip, tag-length, tamper x3, wrong-key, randomness, KDF-parameter-round-trip | ✓ VERIFIED | All present, all green. |
| `docs/backend-contracts/encrypted-backup-blob.md` | Full ASSUMED proposal, gdpr-account-deletion.md template shape | ✓ VERIFIED | Present, matches template exactly (frontmatter, legal-requirements, request/response tables, negative-scope, retention/deletion, client-side isolation point, open questions). |
| `docs/backend-contracts/gdpr-account-deletion.md` | Cross-reference note added, no existing content altered | ✓ VERIFIED | Open Question 5 present, references `encrypted-backup-blob.md`; only additions confirmed. |
| `lib/domain/services/backup_sync_config.dart` | enabled=false flag + pushPath/pullPath | ✓ VERIFIED | Present, `enabled = false`, both paths `/api/v1/backup`. |
| `lib/data/remote/backup_api_client.dart` | push/pull, injectable http.Client, timeout, NetworkException | ✓ VERIFIED | Mirrors `ReferencePackApiClient`; 30s timeout; NetworkException on non-2xx/timeout; 404→null on pull. |
| `lib/features/backup/providers/backup_sync_notifier.dart` | Orchestrates encrypt-then-push / pull-then-decrypt, account-gated | ✓ VERIFIED | `pushBackup` always calls `createBackup(passphrase:)` before `push()`; `pullBackup` distinguishes false/exception/true outcomes; `StateError` on unauthenticated. |
| `lib/features/backup/widgets/backup_sync_section.dart` | Flag-and-account gated UI, SizedBox.shrink otherwise | ✓ VERIFIED | Gating logic exactly as specified; reuses `PassphrasePromptDialog` verbatim. |

### Key Link Verification

| From | To | Via | Status | Details |
|---|---|---|---|---|
| `backup_export_service.dart` | `backup_archive_cipher.dart` | `createBackup()`/`applyRestore()` call `cipher.deriveKey/encrypt/decrypt` | ✓ WIRED | `const _cipher = BackupArchiveCipher();` field, called at 3 sites (`_encryptInPlace`, `applyRestore`'s decrypt path). |
| `backup_restore_screen.dart` | `passphrase_prompt_dialog.dart` | Encrypt-toggle create path and encrypted-preview restore path both open `PassphrasePromptDialog` | ✓ WIRED | `PassphrasePromptDialog.showCreate`/`showEnter` called from `_createBackup`/`_confirmEncryptedRestore`. |
| `backup_export_service.dart` manifest bytes | AES-256-GCM associated data | Exact serialized-once manifest bytes written into zip AND passed as AAD | ✓ WIRED | `manifestBytes` computed once in `_encryptInPlace`, used both for `ArchiveFile('manifest.json', ...)` and `cipher.encrypt(associatedData: manifestBytes)`. On restore, raw stored bytes (not re-serialized) read as AAD. |
| `encrypted-backup-blob.md` | `gdpr-account-deletion.md` | Reciprocal cross-reference | ✓ WIRED | Confirmed both directions present via grep. |
| `encrypted-backup-blob.md` | Backend's own documented intent | Quoted `/api/v1/backup` paths, module description | ✓ WIRED | Paths and quoted module line present verbatim. |
| `backup_restore_screen.dart` | `backup_sync_section.dart` | Unconditionally embedded; section decides its own visibility | ✓ WIRED | `const BackupSyncSection()` embedded between Restore Data and Privacy & Ownership. |
| `backup_sync_notifier.dart` | `backup_api_client.dart` | `pushBackup()/pullBackup()` call `BackupApiClient.push/pull` with bearer token | ✓ WIRED | `ref.read(backupApiClientProvider).push(bytes, accessToken)` / `.pull(accessToken)`. |
| `backup_api_client.dart` | `backup_sync_config.dart` | Request URI built from `BackupSyncConfig.pushPath/pullPath` | ✓ WIRED | `Uri.parse('$baseUrl${BackupSyncConfig.pushPath}')` etc. |
| `backup_sync_notifier.dart` | `backup_export_service.dart` | `pushBackup(passphrase)` calls `createBackup(passphrase:)` before ever calling push | ✓ WIRED | Confirmed by reading source: `createBackup(passphrase: passphrase)` called unconditionally before `BackupApiClient.push`; no code path pushes plaintext. |

### compute()-Isolation Fix Verification (specifically requested)

Confirmed directly against source (not just the SUMMARY's claim): `lib/domain/services/backup_archive_cipher.dart`'s `deriveKey`, `encrypt`, and `decrypt` methods each call `compute(_deriveKeyIsolate, ...)` / `compute(_gcmProcessIsolate, ...)`, following `lib/data/local/reference_pack/reference_pack_extractor.dart`'s precedent (`compute(_decompressGzipFile, ...)`) exactly. Both `_deriveKeyIsolate` and `_gcmProcessIsolate` are top-level functions accepting typedef'd records of primitives only (`String`, `Uint8List`, `int`, `bool`) — `Argon2BytesGenerator` and `GCMBlockCipher` are constructed *inside* each isolate function body, never passed across the isolate boundary. No PointyCastle object appears in either typedef (`_DeriveKeyArgs`, `_GcmArgs`). This matches the reference precedent's pattern precisely and is a real, present fix — not merely claimed.

### Requirements Coverage

| Requirement | Source Plan(s) | Description | Status | Evidence |
|---|---|---|---|---|
| AUTH-09 | 08-01, 08-02, 08-03 | Account Mode users can back up data to the backend as an opaque, client-encrypted blob and restore on another device | ? NEEDS HUMAN (by design — partial, not a gap) | REQUIREMENTS.md line 35/243 explicitly leaves the checkbox unchecked (`- [ ]`) and documents exactly why: client-side encryption done (08-01), contract proposed (08-02), client push/pull implemented flag-off (08-03), but no real backend/round-trip/cross-device restore exists. This is consistent across `08-CONTEXT.md` (phase boundary explicitly scopes out server-side implementation), `ROADMAP.md` (Phase 8's "Carried forward" note + `Requirements: AUTH-09 (partially — see carried-forward note)`), and `REQUIREMENTS.md`. All three sources agree this is a deliberate partial status, not an overlooked gap. |

No orphaned requirements found: REQUIREMENTS.md's Phase 8 traceability row lists only AUTH-09, and all three plans' frontmatter (`08-01-PLAN.md`, `08-02-PLAN.md`, `08-03-PLAN.md`) declare `requirements: [AUTH-09]` — full agreement, no requirement ID declared in a plan is missing from REQUIREMENTS.md, and no requirement mapped to Phase 8 in REQUIREMENTS.md is absent from a plan.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|---|---|---|---|---|
| — | — | None found | — | Grep scan for TODO/FIXME/XXX/HACK/PLACEHOLDER/"Not implemented"/"coming soon" across all Phase 8 source files returned zero matches. `flutter analyze --no-fatal-warnings` on all 9 Phase 8 lib files: "No issues found!" |

### Human Verification Required

None required beyond what the phase itself already explicitly defers to human judgment:

1. **Tomris's review of `docs/backend-contracts/encrypted-backup-blob.md`** — the document's correctness as a proposal (not its existence/structure, which is grep-verified) is inherently a human/backend-owner review, exactly as 08-02's own `<verification>` section states ("correctness beyond structure is Tomris's review, not a runnable assertion").
2. **08-03's real-backend round trip** — cannot be verified today by design (no server exists); this is not a defect, it is the explicitly accepted and recorded scope of this phase per `08-CONTEXT.md` and `ROADMAP.md`'s "Carried forward" note.

Both of these are pre-existing, explicitly-scoped limitations of the phase itself, not verification gaps — the phase's own success criteria (4 and 5) define them as out of reach and require only that the limitation be recorded honestly, which it is (in `08-02-SUMMARY.md`, `08-03-SUMMARY.md`, `encrypted-backup-blob.md`'s own frontmatter/body, and `REQUIREMENTS.md`).

### Gaps Summary

No gaps found. All 6 ROADMAP.md success criteria are verified against actual source code (not SUMMARY claims): the encryption round trip, tamper/wrong-key handling, and formatVersion 1/2 coexistence are real and test-covered; the backend contract document is complete, correctly templated, and cross-referenced in both directions; the client push/pull implementation is real, flag-gated off by a compile-time constant (not a runtime toggle), account-gated, and covered by mocked-request-shape tests; no sync/HLC/outbox/conflict-resolution code exists anywhere in the new surface (confirmed by independent grep, not just the plan's own self-check). The `compute()`-isolation fix specifically requested for scrutiny is genuinely present in source, matching the `reference_pack_extractor.dart` precedent exactly, with no PointyCastle objects crossing the isolate boundary. AUTH-09's partial (not complete) status is intentional, consistently documented across `08-CONTEXT.md`, `ROADMAP.md`, and `REQUIREMENTS.md`, and is not a gap — it is the deliberately carried-forward remainder of a requirement whose full satisfaction depends on a backend that does not yet exist.

---

*Verified: 2026-09-09T10:10:27Z*
*Verifier: Claude (gsd-verifier)*

---
phase: 08-encrypted-account-backup
plan: 02
subsystem: docs
tags: [backend-contract, gdpr, api-spec, assumed-contract]

# Dependency graph
requires:
  - phase: 08-encrypted-account-backup (08-01)
    provides: BackupExportService formatVersion 2 encrypted archive (manifest.json + payload.enc), the artifact this contract proposes pushing/pulling
  - phase: 07-keycloak-auth-account-mode-sync
    provides: gdpr-account-deletion.md's established [ASSUMED]-contract template shape, and BackendConfig.baseUrl as the single base-URL source
provides:
  - docs/backend-contracts/encrypted-backup-blob.md -- full [ASSUMED] proposal for POST/GET /api/v1/backup, matching gdpr-account-deletion.md's template
  - A reciprocal cross-reference in gdpr-account-deletion.md's Open Questions list (account deletion must also delete the backup blob if this contract is accepted)
affects: [08-03-client-push-pull]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Backend contract proposal document: status: ASSUMED frontmatter + assumed request/response tables (every field [ASSUMED]) + explicit negative-scope section + GDPR retention/deletion section + numbered open-questions list for the backend owner -- second instance of this pattern (first was gdpr-account-deletion.md, Phase 7), now an established convention for proposing backend surface that does not yet exist"

key-files:
  created:
    - docs/backend-contracts/encrypted-backup-blob.md
  modified:
    - docs/backend-contracts/gdpr-account-deletion.md

key-decisions:
  - "Re-fetched CO2Diet_Backend-reference origin/main immediately before writing (per 08-RESEARCH.md's own instruction) -- confirmed still at d551d0b (2026-09-06), unchanged since 08-RESEARCH.md's last verified check, so no backup/ module or controller has appeared since; the proposal is written against a backend state re-confirmed the same day as this plan's execution, not stale research"
  - "Adopted the backend's own documented paths/module description verbatim (POST/GET /api/v1/backup, the 'opaque end-to-end-encrypted blobs only' module table line) rather than inventing new ones -- the proposal reads as 'here is the concrete shape of what you already sketched', not an unrelated ask"
  - "Proposed 25 MB push size limit is an explicit guess, not a measured requirement -- flagged as Open Question 3 for Tomris, with Plan 08-01's actual measured archive size (~13 KB for a 600-row synthetic dataset) cited as context so Tomris can judge whether 25 MB is generous-but-reasonable or arbitrary"
  - "X-Backup-Format header proposed as one option for opaque format-versioning without requiring the server to parse the archive, but explicitly presented as optional -- Open Question 4 asks whether Tomris prefers the server stay entirely opaque to versioning instead (no header at all)"
  - "Last-write-wins, no version history for v1 -- explicitly not a gap, since no restore-picker UI exists on the client to make a history meaningful yet (08-CONTEXT.md's Deferred Ideas); an optional ETag/If-Match on push proposed as a low-priority addition for concurrent-overwrite detection, not required"
  - "Cross-reference is reciprocal: encrypted-backup-blob.md's retention section points at gdpr-account-deletion.md by filename, and gdpr-account-deletion.md gained a new numbered Open Question (5) plus one sentence in its intro paragraph pointing forward -- no existing content in gdpr-account-deletion.md was altered, only appended"

patterns-established:
  - "A second [ASSUMED]-contract document in docs/backend-contracts/, confirming the template from gdpr-account-deletion.md generalizes to any not-yet-built backend surface: status frontmatter, opening 'this is a proposal, not agreed' paragraph, legal-requirements section, assumed request/response tables with per-field Status column, explicit negative-scope section, retention/deletion section cross-referencing sibling contracts, client-side isolation point, numbered open-questions list"

requirements-completed: [AUTH-09]

# Metrics
duration: ~10min
completed: 2026-09-08
---

# Phase 8 Plan 2: Encrypted backup blob backend contract specification Summary

**Written proposal at `docs/backend-contracts/encrypted-backup-blob.md` for `POST/GET /api/v1/backup` (bearer-JWT, raw-bytes body, 25 MB proposed limit, 404-when-none-exists, opaque to the archive's internal format), adopting the backend's own already-documented paths/module description verbatim and cross-referencing `gdpr-account-deletion.md` in both directions for GDPR retention/deletion.**

## Performance

- **Duration:** ~10 min
- **Completed:** 2026-09-08T20:23:45Z
- **Tasks:** 2
- **Files modified:** 2 (1 created, 1 modified)

## Backend Verification

Re-verified per 08-RESEARCH.md's explicit instruction: `git fetch origin` against the local
`CO2Diet_Backend-reference` clone, immediately before writing this document. Result:
`origin/main` is still `d551d0bdb076404b0b58de25a633550d4d42e301` ("fix(co2): rebuild module
with correct package structure", 2026-09-06) — **identical** to the commit 08-RESEARCH.md had
already verified. No spot-check for a new `backup/` module was needed since the HEAD commit
itself had not moved; the backend's state as documented in 08-RESEARCH.md's "Backend Reality
Check" (no `backup` module, no backup controller, no user-data table, decision still recorded
open in `docs/backend-architecture.md` §13) is confirmed current as of this plan's execution,
not stale. The new document's frontmatter records this commit hash and the re-fetch date
explicitly (`backend_verified_against`).

## Accomplishments

- `docs/backend-contracts/encrypted-backup-blob.md` created: full `status: ASSUMED` proposal
  covering push (`POST /api/v1/backup`) and pull (`GET /api/v1/backup`), with 17 fields marked
  `[ASSUMED]` (more than double the required 8) across request-contract and response-contract
  tables, a "what this proposal deliberately builds on" section quoting the backend's own
  documented API surface and module description verbatim, an explicit negative-scope section
  (no decryption/inspection/merge/per-field access/server-side key material), a GDPR Art. 32 /
  EDPB Guidelines 01/2025 retention-and-deletion section cross-referencing
  `gdpr-account-deletion.md`, a client-side isolation point naming Plan 08-03's planned
  `backup_sync_notifier.dart`, and 5 numbered open questions for Tomris.
- `docs/backend-contracts/gdpr-account-deletion.md` gained a reciprocal cross-reference: a new
  Open Question 5 stating account deletion must delete the backup blob in the same operation if
  the new contract is ever accepted, plus one forward-pointing sentence in the intro paragraph.
  No existing table row, decision, or sentence in that document was altered — verified via
  `git diff --cached` before commit, which shows only additions.

## Task Commits

Each task was committed atomically:

1. **Task 1: Re-verify backend state and draft the contract document** - `c95b5f8` (docs)
2. **Task 2: Cross-reference the GDPR account-deletion contract** - `9bec23b` (docs)

**Plan metadata:** this commit (docs: complete plan)

## Files Created/Modified

- `docs/backend-contracts/encrypted-backup-blob.md` - New. Full `[ASSUMED]` backend contract
  proposal for the encrypted backup blob push/pull API, matching `gdpr-account-deletion.md`'s
  established template shape.
- `docs/backend-contracts/gdpr-account-deletion.md` - Modified. Appended Open Question 5
  (cross-reference to the new document) and one intro-paragraph sentence pointing forward; no
  existing content changed.

## Decisions Made

See `key-decisions` in frontmatter. Most consequential for Plan 08-03: the proposed paths
(`/api/v1/backup`), the 25 MB size limit, and the optional `X-Backup-Format` header are all
explicitly `[ASSUMED]` and unconfirmed — Plan 08-03 should build its client against exactly what
this document proposes, understanding every detail may change once Tomris reviews it. The
`docs/backend-architecture.md` `/api/v1/...` prefix (vs. `gdpr-account-deletion.md`'s existing
`/me/account` path) discrepancy was flagged as Open Question 2 rather than silently "fixed" in
either document, per the plan's explicit instruction not to silently resolve it here.

## Deviations from Plan

None — plan executed exactly as written. Both tasks' automated `<verify>` checks passed on the
first attempt; no auto-fixes, no blocking issues, no architectural questions arose during
execution.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required. This plan is documentation-only; it does not
touch `lib/`, `test/`, or any runtime code.

## Next Phase Readiness

`08-02` is complete: a full backend contract proposal exists, in the established `[ASSUMED]`
convention, ready for Tomris's review (confirm/adjust/reject). Verification beyond the automated
structural grep checks is Tomris's manual review — this is stated honestly in the plan's own
`<verification>` section and in `08-VALIDATION.md` (SC-4 is manual-only by nature). Plan 08-03
(client push/pull behind an off-by-default flag) can proceed: it depends only on this document's
proposed shape existing to build against, not on the backend actually implementing it, and not
on Tomris's review outcome — the flag stays off regardless until both the contract is confirmed
and a real round trip is observed on a live backend.

---
*Phase: 08-encrypted-account-backup*
*Completed: 2026-09-08*

## Self-Check: PASSED

All key-files (created and modified) verified present on disk. Both task commits (`c95b5f8`,
`9bec23b`) verified present in `git log`.

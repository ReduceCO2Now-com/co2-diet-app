---
status: ASSUMED -- not yet confirmed with Tomris
requested_by: Ali (Flutter client)
owner: Tomris (Backend -- Spring Boot + PostgreSQL + Keycloak)
related_requirement: AUTH-09
last_updated: 2026-09-08
backend_verified_against: d551d0bdb076404b0b58de25a633550d4d42e301 (origin/main, 2026-09-06 -- re-fetched and confirmed unchanged 2026-09-08, the date this document was written)
---

# Encrypted Backup Blob — API Contract Spec

This document specifies the backend contract the Flutter client's encrypted backup feature
(Plan 08-01's `BackupArchiveCipher` + `BackupExportService` `formatVersion: 2` archive, and
Plan 08-03's client push/pull implementation, both behind an off-by-default flag) proposes for
pushing and pulling a single opaque, client-encrypted backup blob per account. **Every field
below is `[ASSUMED -- not yet confirmed with Tomris]`** — this is a concrete written proposal
for review, not a description of an already-agreed contract. This closes the "encrypted blob
vs. pure user-cloud export" decision that `docs/backend-architecture.md` §13 records as open
(open as of the last verified fetch, commit `d551d0b`), by converting it into something concrete
to confirm or reject — the same move that unblocked GDPR account deletion in Phase 7. This
proposal deliberately adopts the paths and module description the backend's own
`docs/backend-architecture.md` already names (`POST/GET /api/v1/backup`, an "Encrypted Backup"
module entry), converting what is currently an internal sketch in that document into a concrete
proposal to confirm or reject, rather than inventing new paths or a new module description.

## Legal requirements driving this contract

- **AUTH-09 (narrowed 2026-08-12) / GDPR Art. 32 ("Security of processing")**: "Account Mode
  users can back up their data to the backend as an opaque, client-encrypted blob the server
  cannot read, and restore it on another device." The client-side half of this requirement
  (encryption, key derivation, the passphrase-carries-the-consequence UX) is delivered by Plan
  08-01, independent of whether this contract is ever accepted. This document specifies the
  transport half.
- **GDPR Art. 32 is a security measure, not an exit from the Regulation.** Per EDPB Guidelines
  01/2025, pseudonymised or encrypted data remains personal data for retention/erasure purposes
  where it stays linkable to an individual — and here the blob is stored against an account
  identifier (the bearer token's subject claim). The fact that the server cannot decrypt the
  blob's *contents* does not remove the blob itself from GDPR's scope; it only removes the
  server's ability to inspect what is inside it. See "Retention & deletion" below.

## What this proposal deliberately builds on

This proposal is not inventing new backend surface from nothing. The backend's own
`docs/backend-architecture.md` (verified against `origin/main` = `d551d0b`, 2026-09-06,
re-fetched and confirmed unchanged 2026-09-08) already documents:

- An "API surface (quick reference)" listing `POST /api/v1/backup` and `GET /api/v1/backup`.
- A module table entry reading: **"Encrypted Backup — Optional, account mode only. Stores
  opaque end-to-end-encrypted blobs only — the server cannot read meals/weight/profile."**
- `SecurityConfig` as `oauth2ResourceServer().jwt()` with `.anyRequest().authenticated()` — a
  new `/api/v1/backup` endpoint is bearer-JWT-protected by default, no auth configuration change
  needed on the backend's side.

None of `backup/` module code, a backup controller, or a user-data table currently exist in the
backend (verified: `git ls-tree -r origin/main` contains no `backup/` path; the only
`@*Mapping` controllers in the tree are `MeController` (`GET /api/v1/me`) and `FoodController`).
This document proposes the concrete shape of the thing the backend's own documentation already
sketched, not an unrelated ask.

## Assumed request contract

| Field | Value | Status |
|---|---|---|
| Push method | `POST` | `[ASSUMED]` |
| Push path | `{baseUrl}/api/v1/backup` | `[ASSUMED]` — `baseUrl` per `BackendConfig.baseUrl`; note this uses the `/api/v1/...` prefix, not `/me/...` (see Open Question 2) |
| Pull method | `GET` | `[ASSUMED]` |
| Pull path | `{baseUrl}/api/v1/backup` | `[ASSUMED]` — same path, method distinguishes push from pull |
| Push headers | `Authorization: Bearer <access_token>`, `Content-Type: application/octet-stream` | `[ASSUMED]` |
| Pull headers | `Authorization: Bearer <access_token>` | `[ASSUMED]` — no request body, no `Content-Type` |
| Push body | Raw bytes of the encrypted backup archive (Plan 08-01's `formatVersion: 2` zip — `manifest.json` + `payload.enc`), sent verbatim as the request body, not multipart/form-encoded | `[ASSUMED]` |
| Pull body | none | `[ASSUMED]` |
| Size limit | 25 MB proposed maximum push body size | `[ASSUMED]` — see Open Question 3 |
| Size-exceeded behavior | `413 Payload Too Large` | `[ASSUMED]` |
| Idempotency | Push is idempotent in effect (last-write-wins overwrite of the single stored blob, not an append) — a second push with a different archive simply replaces the first; see "Semantics" below | `[ASSUMED]` |

## Assumed response contract

| Scenario | Expected status | Status |
|---|---|---|
| Push success | Any `2xx` (client accepts the full `2xx` range, does not special-case `200` vs `201` vs `204`, mirroring `gdpr-account-deletion.md`'s existing convention) | `[ASSUMED]` |
| Pull success | `200` + raw bytes of the stored encrypted archive in the response body | `[ASSUMED]` |
| Pull when no backup exists for this account | `404` — the client treats this as "no server backup yet," an expected, normal state, **never** surfaced to the user as an error | `[ASSUMED]` |
| Any other outcome (auth failure, server error, size exceeded, timeout, etc.) | Any non-`2xx` (and non-`404`-on-pull) — the client surfaces a typed `NetworkException`/`BackupSyncException` with the raw status code; no error-body parsing is assumed or attempted, mirroring `ReferencePackApiClient`'s and `gdpr-account-deletion.md`'s existing conventions | `[ASSUMED]` |

**The server must never parse the archive's own internal `formatVersion`.** Plan 08-01's
manifest (`manifest.json`, inside the archive) carries a `formatVersion` field for the
*client's own* format evolution (currently `1` for plaintext, `2` for the Argon2id/AES-256-GCM
encrypted wrapper). The server has no business reading this — it receives and returns opaque
bytes only. As one option for letting a future client version-check what it pulls *without*
requiring the server to open the archive, this proposal suggests an opaque `X-Backup-Format`
response header (an integer the server stores and echoes back verbatim, supplied by the client
on push, never interpreted server-side) — see Open Question 4. If Tomris prefers the server
stay entirely opaque to versioning, including not storing/echoing this header, that is equally
acceptable; the client can determine the format from the archive's own manifest after pull.

## Semantics

**One backup per user, last-write-wins overwrite — explicitly not a version history.** A push
replaces whatever blob (if any) was previously stored for that account; there is no server-side
history of prior pushes. This is a deliberate v1 simplification: a restore-picker UI ("choose
which of your last N backups to restore") does not exist on the client and is explicitly
deferred (`08-CONTEXT.md`'s Deferred Ideas), so there is nothing for a history to serve yet.

As a cheap, low-priority `[ASSUMED]` addition for detecting a concurrent overwrite from another
device (e.g. two devices both push within the same session), this proposal suggests an optional
`ETag` on pull responses and an optional `If-Match` header on push — if present and mismatched,
the server could return `412 Precondition Failed` instead of silently overwriting. This is
explicitly optional and not required for v1; see Open Question 5.

## What the backend is explicitly NOT being asked to do

Quoting the backend's own module-table line verbatim, since it already states this proposal's
negative scope better than a client-authored requirement could:

> "Stores opaque end-to-end-encrypted blobs only — the server cannot read meals/weight/profile."

Concretely, this contract asks the backend for **storage only**. It explicitly does **not** ask
the backend to:

- Decrypt the blob, at any point, for any reason.
- Inspect, parse, or validate the blob's contents (including its internal `manifest.json` or
  `formatVersion` — see "Assumed response contract" above).
- Merge, diff, or reconcile the blob against any other stored data — there is nothing to merge;
  Phase 8 explicitly excludes any bidirectional sync, HLC usage, outbox, or conflict resolution
  (`08-CONTEXT.md`), because an opaque blob has no mergeable structure from the server's point
  of view.
- Provide per-field or partial access to anything inside the blob (e.g. "just the profile
  section") — push and pull are always whole-blob operations.
- Hold, generate, or have access to any server-side key material for this blob. The encryption
  key is derived client-side from a user-supplied passphrase (Plan 08-01) and never transmitted;
  the server never sees the passphrase, the derived key, or any plaintext.
- Run analytics on the blob's contents, size, timing, or frequency of push/pull beyond whatever
  the backend already logs for any authenticated request (standard access logging, not a new
  ask specific to this endpoint).

## Retention & deletion

The stored blob is personal data for GDPR retention/erasure purposes — encryption is a security
measure under GDPR Art. 32, not a basis for treating the blob as outside the Regulation's scope,
per EDPB Guidelines 01/2025 (see "Legal requirements" above). The blob is tied to an account
identifier even though its contents are unreadable to the server, and that linkage is what
brings it within scope.

**Account deletion must delete the stored blob in the same operation as any other backend-side
account data.** This document cross-references `docs/backend-contracts/gdpr-account-deletion.md`
directly: that document specifies the `DELETE {baseUrl}/me/account` contract (itself `[ASSUMED]`
and unconfirmed) and predates this one — it says nothing today about a backup blob, because no
backup blob existed when it was written. If this proposal is ever accepted and implemented, the
account-deletion contract's "hard-deleted in the same operation, synchronously" assumption must
extend to cover the backup blob as well, not leave it orphaned after the rest of the account is
gone. See Task 2's cross-reference addition to `gdpr-account-deletion.md`'s own "Open questions
for Tomris" list for the reciprocal pointer.

Art. 20 data portability is already served by Phase 5's plaintext export (PRIV-01) — this
encrypted blob does not need a separate export/portability route of its own; it exists purely as
an opaque backup-and-restore convenience, not a new access mechanism.

## Client-side isolation point

The entire client-side implementation of this contract is planned to live in one file:
`lib/features/backup/providers/backup_sync_notifier.dart` (per Plan 08-03), composing an
injectable `BackupApiClient` (`lib/data/remote/backup_api_client.dart`) that mirrors
`ReferencePackApiClient`'s existing shape — mirroring `gdpr-account-deletion.md`'s "one-file
change" framing for `AuthNotifier.deleteAccount()`. If any assumption above turns out to be
wrong once Tomris confirms the real contract, updating the client to match should not require
touching the encryption logic (Plan 08-01, independent of transport) or any other feature.

Plan 08-03's implementation stays behind a compile-time flag (`BackupSyncConfig.enabled`,
defaulted `false`) until this contract is confirmed **and** at least one real round trip against
a live backend has been observed — nothing ships enabled against an endpoint that does not exist
yet.

## Open questions for Tomris

1. Has the "encrypted blob vs. pure user-cloud export" decision (`docs/backend-architecture.md`
   §13) moved since the last verified fetch (`d551d0b`, 2026-09-06, re-confirmed unchanged
   2026-09-08)? If it has resolved toward the encrypted-blob approach, are the paths, methods,
   and size limit proposed above acceptable as-is, or do they need adjustment before any backend
   work starts?
2. `docs/backend-contracts/gdpr-account-deletion.md` documents `DELETE {baseUrl}/me/account`,
   but the backend's actual and documented convention elsewhere is `/api/v1/...`
   (`GET /api/v1/me` exists in code today). This proposal uses `/api/v1/backup` to match that
   convention. Is the `/me/account` path in the deletion contract actually correct, or is it a
   latent defect that should be fixed to `/api/v1/me/account` (or similar) independent of
   whether this backup proposal is accepted?
3. Is a 25 MB push size limit right, or does Tomris have a different number in mind? (For
   context: Plan 08-01's real-device benchmark measured a synthetic 600-row dataset producing a
   ~13 KB encrypted archive — 25 MB is chosen as a generous ceiling, not a measured requirement.)
4. Is the optional opaque `X-Backup-Format` header (client-supplied on push, stored and echoed
   verbatim on pull, never interpreted server-side) an acceptable addition, or would Tomris
   prefer the server stay entirely opaque to versioning with no such header at all?
5. Is last-write-wins-with-no-history acceptable for v1 (matching the client's current lack of
   any restore-picker UI), or is a lightweight version history (e.g. keeping the last N blobs)
   wanted from day one, before any client work against this contract starts?

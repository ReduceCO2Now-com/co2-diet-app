# Phase 8: Encrypted Account Backup - Context

**Gathered:** 2026-09-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver client-side encrypted backup of local user data, and specify the backend
contract for pushing and pulling that encrypted blob — **without a backend to
build against**.

**The constraint that shapes this phase.** ROADMAP.md states Phase 8 has "zero
actionable content until Tomris resolves the backend's open encrypted-blob vs.
pure user-cloud-export decision," and that the documented design "leans user-cloud,
which lets us drop the `backup/` module entirely." A re-scan of
`ReduceCO2Now-com/CO2Diet_Backend@origin/main` on 2026-09-07 confirms that
remains true: the backend has `catalog`, `ingestion`, a stub `co2` module
(interfaces only, created 2026-09-06) and the Spring bootstrap. There is **no
backup module, no sync endpoint, and no user-data storage of any kind**, and
`docs/backend-architecture.md` §13 still lists the decision as open.

**Decision (2026-09-08): proceed client-first rather than cancel or wait.** The
alternative considered was cancelling the phase as superseded by Phase 5's
PRIV-01/02/03/04 (export to CSV/Excel/JSON, manual backup to device or
cloud/Files or share, configurable automatic backups, restore with preview) —
which already deliver the user-facing outcome by a user-held route. That
recommendation was made and not taken; both positions are recorded so the
reasoning survives.

**What this phase delivers:**

- Client-side encryption of the backup archive, so the artifact is opaque before
  it leaves the device — AUTH-09's actual privacy property, independent of
  whether a server ever holds it.
- A written backend contract proposing the push/pull API, for Tomris to confirm
  or reject.
- The client push/pull implementation against that proposed contract, behind a
  feature flag defaulted **off**.

**What this phase does NOT include:**

- Any bidirectional sync, HLC usage, outbox, or conflict resolution. Settled on
  2026-08-12: the backend's Sync module is permanently scoped to catalog and CO₂
  reference data only. The blob is opaque, so there is nothing to merge.
- Any server-side implementation. That is Tomris's workstream and is not
  currently planned.
- Changes to Phase 5's existing export/backup/restore, which remain available
  and unchanged for users who do not want cloud backup.

</domain>

<decisions>
## Implementation Decisions

### Ordering

Three plans, in dependency order. `08-01` is independent of the backend and
should land first so the phase produces something verifiable regardless of what
happens to the rest.

### 08-01 — Client-side encryption of the backup archive

- Encrypt the archive produced by the existing `BackupExportService`
  (PRIV-01/02), rather than introducing a parallel backup path.
- The existing plaintext export must remain available. Encrypted backup is an
  additional option, not a replacement — a user exporting their data to inspect
  it in a spreadsheet is a legitimate, GDPR-relevant use (PRIV-01 portability).
- Restore must detect an encrypted archive and prompt accordingly, rather than
  failing with a parse error.
- **Open for planning:** key derivation. Options include a user-supplied
  passphrase, a key derived from the Keycloak identity, or a device-held key in
  `flutter_secure_storage` (already a dependency, Phase 7). Each has a different
  recovery story, and the wrong one makes the backup unrecoverable on a lost
  device. This needs a decision before implementation, not during it.
- `crypto` (^3.0.7) is already a dependency from Phase 9; check whether it
  covers the required primitives before adding anything new. Any new package
  goes through the blocklist and legitimacy checks in CONTRIBUTING.md.

### 08-02 — Backend contract specification

- Written to `docs/backend-contracts/`, in the same shape and register as the
  existing `gdpr-account-deletion.md`: `status: ASSUMED` frontmatter, an
  explicit statement that it is a proposal for Tomris to confirm or reject, and
  every field marked as assumed rather than agreed.
- Covers push and pull of the opaque blob, authentication (bearer token, as with
  `/api/v1/me`), size limits, versioning, and the error cases — including what
  the client should do when no backup exists server-side.
- Must state what the backend is **not** being asked for: no decryption, no
  inspection, no merge, no per-field access. The server stores bytes.

### 08-03 — Client push/pull behind a flag

- Implemented against `08-02`'s proposed contract, reading its base URL from
  `BackendConfig.baseUrl` (already the single source, marked `[ASSUMED]`).
- Feature flag defaults **off**. Nothing ships enabled against an endpoint that
  does not exist.
- Account-gated: only reachable in Account Mode, consistent with Phase 7.

### Verification, stated honestly

`08-01` is fully verifiable today — encrypt, restore, round-trip, wrong-key
failure, all testable locally and on device.

`08-02` is a document; its verification is Tomris's review.

**`08-03` cannot be end-to-end verified.** There is no server to push to. Its
tests can only assert request shape against a mock. Every other phase in this
project was device-verified, and three defects on 2026-09-07 survived precisely
because they had not been. This is a known and accepted risk of proceeding
before the backend exists — it must be recorded in the phase summary, not
discovered later.

### Claude's discretion

- Test structure and naming, following existing repository conventions.
- Exact wording of the contract document, within the established `[ASSUMED]`
  convention.
- Whether `08-03` warrants splitting further once `08-02` settles the surface.

</decisions>

<specifics>
## Specific Ideas

- The contract document is arguably the most valuable artifact in this phase. It
  converts an open backend question into a concrete proposal someone can accept
  or reject, which is what has been missing since 2026-08-12.
- `08-01` is worth doing even if `08-02` is rejected outright: encrypt-before-
  export is useful whether the archive reaches a server or only the user's own
  iCloud or Drive.

</specifics>

<code_context>
## Existing Code Insights

### Reusable assets

- `lib/domain/services/backup_export_service.dart` (688 lines) — already builds
  the archive, selects categories and writes the manifest. The encryption step
  belongs here or immediately downstream of it.
- `lib/features/backup/` — screens, notifier and the danger-zone section from
  Phase 5. Restore already has a preview-and-confirm flow to hook into.
- `lib/domain/services/backend_config.dart` — the single `[ASSUMED]` base URL.
- `flutter_secure_storage` (Phase 7) — already holds the OIDC refresh token, and
  is the natural home for a device-held key if that is the chosen approach.
- `docs/backend-contracts/gdpr-account-deletion.md` — the template for `08-02`.

### Established patterns

- Repository interfaces in `domain/repositories/`, implementations in `data/`;
  presentation depends on the interface only.
- Centralised `[ASSUMED]` config classes so an eventual real-value handoff is a
  one-file change.
- Feature flags and account gating follow Phase 7's realm-discovery pattern
  (`realmDiscoveryReadyProvider`), which hides account UI entirely until the
  backend is reachable rather than showing a broken affordance.

### Integration points

- `BackupRestoreScreen` — where an encrypted-backup option would surface.
- `AuthNotifier` — the single source of truth for whether the user is in Account
  Mode.

</code_context>

<deferred>
## Deferred Ideas

- Automatic scheduled push. Phase 5's PRIV-03 already provides configurable
  automatic backups locally; extending that to the server should wait until the
  contract is accepted and at least one real round trip has been observed.
- Cross-device restore UX (choosing between multiple stored backups, seeing
  their dates). Meaningless until a server holds more than one.
- Encrypting the reference pack or catalog data. Not user data, publicly
  available, and would only cost battery.

</deferred>

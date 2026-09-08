# Phase 8: Encrypted Account Backup (client-first) — Research

**Researched:** 2026-09-08
**Domain:** Applied cryptography on Flutter/Dart (password-based authenticated encryption of a file archive), plus API-contract specification against a backend that does not exist yet
**Confidence:** HIGH for 08-01 (measured and verified locally), HIGH for the backend's current state (verified against `origin/main`), MEDIUM for 08-03 (unverifiable by construction)

---

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

**Ordering.** Three plans, in dependency order. `08-01` is independent of the backend and
should land first so the phase produces something verifiable regardless of what happens to the
rest.

**08-01 — Client-side encryption of the backup archive**

- Encrypt the archive produced by the existing `BackupExportService` (PRIV-01/02), rather than
  introducing a parallel backup path.
- The existing plaintext export must remain available. Encrypted backup is an additional
  option, not a replacement — a user exporting their data to inspect it in a spreadsheet is a
  legitimate, GDPR-relevant use (PRIV-01 portability).
- Restore must detect an encrypted archive and prompt accordingly, rather than failing with a
  parse error.
- **Key derivation — narrowed 2026-09-08, read this before planning.** AUTH-09 requires the
  user can "restore it on another device". That clause is load-bearing and eliminates one
  option outright:

  | Option | Verdict |
  |---|---|
  | Device-held key in `flutter_secure_storage` | **Ruled out.** A key held on device A cannot decrypt on device B. Fails the cross-device half of AUTH-09 by construction — do not plan around it. |
  | Derived from the Keycloak identity | **Viable but weakens the guarantee.** The same organisation runs Keycloak and the backend, so in principle it could derive the key too. That turns "the server cannot read it" from a property into a promise. Acceptable only as an explicit, documented trade — not a default. |
  | User-supplied passphrase | **The only option that cleanly satisfies both halves** — opaque to the server, and portable to any device the user logs in from. |

  **The passphrase carries a hard consequence that must be designed for, not discovered:** if
  the user forgets it, the backup is permanently unrecoverable. There is no reset, by design —
  the server holds bytes it cannot read, so it cannot help. Planning must decide where and how
  that is communicated. It has to be said *before* the user creates their first encrypted
  backup, in plain language, not buried in a help screen afterwards.

  This also interacts with PRIV-03's automatic backups: if scheduled backups are encrypted with
  a passphrase the user set months earlier and has since forgotten, the automatic backup is
  worthless at exactly the moment it matters. Planning should decide whether encryption applies
  to automatic backups at all, or only to explicit user-initiated ones.
- `crypto` (^3.0.7) is already a dependency from Phase 9; check whether it covers the required
  primitives before adding anything new. Any new package goes through the blocklist and
  legitimacy checks in CONTRIBUTING.md.

**08-02 — Backend contract specification**

- Written to `docs/backend-contracts/`, in the same shape and register as the existing
  `gdpr-account-deletion.md`: `status: ASSUMED` frontmatter, an explicit statement that it is a
  proposal for Tomris to confirm or reject, and every field marked as assumed rather than
  agreed.
- Covers push and pull of the opaque blob, authentication (bearer token, as with `/api/v1/me`),
  size limits, versioning, and the error cases — including what the client should do when no
  backup exists server-side.
- Must state what the backend is **not** being asked for: no decryption, no inspection, no
  merge, no per-field access. The server stores bytes.

**08-03 — Client push/pull behind a flag**

- Implemented against `08-02`'s proposed contract, reading its base URL from
  `BackendConfig.baseUrl` (already the single source, marked `[ASSUMED]`).
- Feature flag defaults **off**. Nothing ships enabled against an endpoint that does not exist.
- Account-gated: only reachable in Account Mode, consistent with Phase 7.

**Verification, stated honestly**

`08-01` is fully verifiable today — encrypt, restore, round-trip, wrong-key failure, all
testable locally and on device.

`08-02` is a document; its verification is Tomris's review.

**`08-03` cannot be end-to-end verified.** There is no server to push to. Its tests can only
assert request shape against a mock. Every other phase in this project was device-verified, and
three defects on 2026-09-07 survived precisely because they had not been. This is a known and
accepted risk of proceeding before the backend exists — it must be recorded in the phase
summary, not discovered later.

**Out of scope for the phase (from `## Phase Boundary`)**

- Any bidirectional sync, HLC usage, outbox, or conflict resolution. The blob is opaque, so
  there is nothing to merge.
- Any server-side implementation. That is Tomris's workstream.
- Changes to Phase 5's existing export/backup/restore, which remain available and unchanged.

### Claude's Discretion

- Test structure and naming, following existing repository conventions.
- Exact wording of the contract document, within the established `[ASSUMED]` convention.
- Whether `08-03` warrants splitting further once `08-02` settles the surface.

### Deferred Ideas (OUT OF SCOPE)

- Automatic scheduled push. Phase 5's PRIV-03 already provides configurable automatic backups
  locally; extending that to the server should wait until the contract is accepted and at least
  one real round trip has been observed.
- Cross-device restore UX (choosing between multiple stored backups, seeing their dates).
  Meaningless until a server holds more than one.
- Encrypting the reference pack or catalog data. Not user data, publicly available, and would
  only cost battery.

</user_constraints>

---

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| AUTH-09 (partial) | "Account Mode users can back up their data to the backend as an opaque, client-encrypted blob the server cannot read, and restore it on another device." | **"Opaque, client-encrypted"** — §Standard Stack (PointyCastle Argon2id + AES-256-GCM), §Architecture Pattern 1 (envelope format), §Code Examples. **"Restore it on another device"** — satisfied *in principle* by the passphrase-derived key: every parameter needed to re-derive the key travels inside the archive manifest, so any device with the archive and the passphrase can decrypt. Not satisfied *in practice* until a server can hand the archive to that other device — see §Backend Reality Check. **"The server cannot read it"** — §Don't Hand-Roll (no server-side key material of any kind), and §08-02 Contract Research for the negative-scope statements the contract must carry. |

Success criteria 1–3 of ROADMAP.md's Phase 8 are covered by §Architecture Patterns, §Common
Pitfalls and §Validation Architecture. Criterion 4 is covered by §08-02 Contract Research.
Criteria 5–6 are covered by §08-03 Client Research.

</phase_requirements>

---

## Summary

**The `crypto` package does not cover this.** Verified against its own API docs and the pub.dev
API: `crypto` 3.0.7 (dart.dev, 2025-11-04) is *hashing only* — SHA-1/2 family, MD5, HMAC. It has
no AES, no AEAD, and no PBKDF2. Its own documentation says so explicitly. A new dependency is
therefore unavoidable for 08-01, and CONTRIBUTING.md's package-legitimacy checkpoint applies.

**The recommended addition is `pointycastle` 4.0.0** (verified publisher `bouncycastle.org`, MIT,
140/160 pub points, 3.32M downloads/30d). It is pure Dart with exactly two dependencies —
`collection` and `convert` — both already resolved in this project's lockfile. No platform
channels, no FFI, no network code, nothing that could trip `.privacy-blocklist.yaml`. It runs
unchanged in `flutter test`, which matters because 08-01's whole value is that it is verifiable
without a backend or a device. The recommended construction is **Argon2id → AES-256-GCM**, with
all KDF parameters and the salt carried in a plaintext manifest inside the same zip, so the
archive is self-describing and portable to any device.

**These recommendations were measured, not assumed.** On this machine (Apple Silicon, Dart 3.12.2
JIT) PointyCastle's Argon2id at the OWASP `m=19456 KiB, t=2, p=1` profile takes **154 ms**, and its
AES-256-GCM runs at roughly **600 ms/MB**. Its Argon2id output was verified byte-identical against
an independent implementation (`package:cryptography`), and its AES-GCM was verified to append the
16-byte tag and to throw `InvalidCipherTextException` on a tampered ciphertext, a tampered tag,
and a wrong key. Since backups are compressed before encryption, a heavy user's archive is
realistically 100–300 KB, so the GCM cost is a fraction of a second. A ChaCha20-Poly1305 fallback
exists in the same package and is ~40× faster, but it carries two API traps documented below.

**The backend half is better-grounded than CONTEXT.md suggests, and that is good news for 08-02.**
A fresh `git fetch` of `ReduceCO2Now-com/CO2Diet_Backend` (verified today, `origin/main` =
`d551d0b`, 2026-09-06) confirms there is still no `backup` module, no backup controller and no
user-data table — the only authenticated endpoint that exists is `GET /api/v1/me`. **But** the
backend's own `docs/backend-architecture.md` already names the intended surface:
`POST /api/v1/backup` / `GET /api/v1/backup`, an `Encrypted Backup` module described as storing
"**opaque end-to-end-encrypted blobs only** — the server cannot read meals/weight/profile", and a
`backup/` directory in the planned Maven layout. 08-02 should adopt those exact paths and quote
that module description back, so the proposal reads as "here is the concrete shape of the thing
you already sketched", not as an unrelated ask.

**Primary recommendation:** Add `pointycastle: ^4.0.0`. Implement a pure `domain/services/`
cipher service doing Argon2id(m=19456, t=2, p=1, 16-byte random salt) → AES-256-GCM(12-byte
random nonce, 128-bit tag), wrapped in a `formatVersion: 2` zip whose plaintext `manifest.json`
carries every KDF/cipher parameter and is bound in as AEAD associated data. Keep plaintext
backups at `formatVersion: 1` and teach `previewRestore`/`applyRestore` to accept both. Leave
PRIV-03's automatic backups unencrypted by default (they never leave the device, and the
scheduler that would run them does not exist yet — see §PRIV-03). Then write 08-02 against the
backend's own documented `POST/GET /api/v1/backup`, and build 08-03 as a mock-tested API client
behind an off-by-default flag.

---

## Backend Reality Check (verified today)

Verified by `git fetch origin` against the local reference clone at
`/Users/alisafi/Documents/ReduceCO2-Now/CO2Diet_Backend-reference`. `origin/main` is
`d551d0bdb076404b0b58de25a633550d4d42e301`, "fix(co2): rebuild module with correct package
structure", **2026-09-06**. This is one commit newer than the state CONTEXT.md describes and it
confirms CONTEXT.md's conclusion.

| Claim | Status | Evidence |
|---|---|---|
| No backup module | **CONFIRMED** | Full `git ls-tree -r origin/main` contains no `backup/` path. Maven modules present: `app`, `catalog`, `co2`, `ingestion`, `shared`. |
| No backup endpoint | **CONFIRMED** | The only `@*Mapping` annotations in the tree are `MeController` (`GET /api/v1/me`) and `FoodController` (`/api/v1/foods/**`). |
| No user-data storage | **CONFIRMED** | `V1__init.sql` + `V2__…sql` create exactly one table: `food_product`. |
| `co2` module is interfaces only | **CONFIRMED** | `co2/src/main/java/.../Co2Estimate.java` and `Co2Query.java` only. No controller, no service, no entity. |
| Decision still open | **CONFIRMED** | `docs/backend-architecture.md` §13 "Open items / TBD" still reads: "Encrypted blob backup **vs** pure user-cloud export… The product doc leans user-cloud; choosing that lets us drop the `backup/` module entirely." |

**Three findings that were not in CONTEXT.md and directly shape 08-02:**

1. **The intended API surface is already written down.** `docs/backend-architecture.md`'s "API
   surface (quick reference)" lists `POST /api/v1/backup    GET /api/v1/backup`. 08-02 should
   propose exactly these, not invent `/me/backup` or similar.
2. **The intended module semantics are already written down, and they match AUTH-09 exactly.**
   The module table reads: "**Encrypted Backup** — *Optional, account mode only.* Stores
   **opaque end-to-end-encrypted blobs only** — the server cannot read meals/weight/profile."
   Quote this verbatim in 08-02's "what the backend is not being asked for" section; it converts
   the negative scope from a client-side demand into a restatement of the backend's own design.
3. **Auth is already solved by the existing `SecurityConfig`.** It is
   `oauth2ResourceServer().jwt()` with `.requestMatchers("/api/v1/foods/**").permitAll()` and
   `.anyRequest().authenticated()`. A new `/api/v1/backup` endpoint would be bearer-JWT protected
   by default with zero configuration change. 08-02 can state this as an observation about the
   deployed config rather than as an assumption.

**A latent path discrepancy worth fixing while you are here.** The client's existing
`AuthNotifier.deleteAccount()` calls `${BackendConfig.baseUrl}/me/account`, and
`docs/backend-contracts/gdpr-account-deletion.md` documents that path. The backend's actual and
documented convention is `/api/v1/...` (`GET /api/v1/me` exists in code). 08-02 should use
`/api/v1/backup` and should note the inconsistency in its "Open questions for Tomris" section
— it is a one-line note that may save a wrong-path defect later.

---

## Standard Stack

### Core

| Library | Version | Purpose | Why standard |
|---|---|---|---|
| `pointycastle` | `^4.0.0` | Argon2id KDF, AES-256-GCM AEAD, (fallback) ChaCha20-Poly1305 | Verified publisher `bouncycastle.org` — the Dart port of Bouncy Castle, the reference JVM crypto library. MIT. 140/160 pub points, 414 likes, 3,320,931 downloads/30d. Pure Dart; total dependency set is `collection` + `convert`, both already in this project's lockfile. No FFI, no platform channels, no HTTP. Runs identically in `flutter test`, on device, and in CI. |
| `crypto` | `^3.0.7` *(already present)* | Nothing new — retained for Phase 9's SHA-256 pack verification | **Explicitly insufficient for this phase.** Hashing and HMAC only; no AES, no AEAD, no PBKDF2. Verified against `pub.dev/documentation/crypto/latest/` and the package's own README disclaimer. |
| `archive` | `3.6.1` *(already present, pinned)* | Container for the encrypted payload | Pin must not move — `excel` 4.0.6 hard-depends on `archive ^3.6.1`. Verified in the local pub cache that `ArchiveFile.compress` (a settable `bool`, default `true`) exists in 3.6.1, which is what lets you store the already-encrypted payload uncompressed. |
| `http` | `^1.6.0` *(already present)* | 08-03's push/pull client | Same injectable-`http.Client` + mocktail convention as `ReferencePackApiClient` and `AuthNotifier`. |
| `flutter_secure_storage` | `^11.0.0` *(already present)* | Optional: nothing, by recommendation | See §Pitfall 6 — caching a *derived key* here does not work the way CONTEXT.md's code-context note assumes, because the salt is fresh per archive. |

### Alternatives considered

| Instead of | Could use | Tradeoff |
|---|---|---|
| `pointycastle` | `cryptography` 2.9.0 (publisher `dint.dev`) | Faster pure-Dart AES-GCM — measured 259 ms for 5 MB vs PointyCastle's 2,925 ms, ~11×. Nicer API (`SecretBox`, `SecretBoxAuthenticationError`). **But:** 130/160 pub points; last release 2025-11-21; the maintained-fork `cryptography_plus` states the original "repository was moved… due to lack of maintenance", which is a maintenance signal this project's dependency policy takes seriously (cf. the `excel` staleness note in `pubspec.yaml`). Also pulls `ffi` into the graph for optional native paths. Choose this only if on-device measurement shows GCM throughput is actually a problem. |
| `pointycastle` | `cryptography_plus` 3.0.0 (publisher `emz-hanauer.com`) | Actively maintained fork, published 2026-03-02, same algorithms. **But:** 13 likes, 25,665 downloads/30d — far below the adoption bar every other package in this `pubspec.yaml` cleared. |
| `pointycastle` | `webcrypto` 0.6.1 (publisher **`google.dev`**) | The only candidate from a publisher the dependency policy explicitly prefers, and BoringSSL-backed so PBKDF2/AES run at native speed. **But:** 0.6.1 (2026-05-22) migrated to Dart build hooks (`hooks`, `code_assets`, `native_toolchain_cmake`) and builds BoringSSL from source, requiring `cmake` and a C compiler on every dev machine and CI runner. Build hooks are stable as of Flutter 3.38/Dart 3.10 so the toolchain supports it, but this project's CI (`ubuntu-latest` + `macos-latest`, `flutter build apk --debug` and iOS no-codesign) would gain a from-source native build on a pre-1.0 package that changed its build system three months ago. Disproportionate risk for encrypting a 200 KB zip. |
| `pointycastle` | `encrypt` 5.0.3 | A thin wrapper over `pointycastle` with a friendlier API. Last published **2023-09-18** — three years stale, and it adds `args`/`asn1lib`/`clock` to the graph for no benefit. Use `pointycastle` directly. |
| AES-256-GCM | ChaCha20-Poly1305 (same package) | ~40× faster in pure Dart (measured: 5 MB in 69 ms vs 2,925 ms). RFC 8439, and the standard choice where AES hardware acceleration is unavailable — which is exactly the pure-Dart case. **But** PointyCastle's implementation has two verified API traps (Pitfall 2), and AES-GCM is the more conservative, more widely-reviewed default. Recommended as a documented fallback if the device checkpoint shows real-world archives are large enough to matter. |
| Argon2id | PBKDF2-HMAC-SHA256, 600k iterations | OWASP's FIPS-compliant option. Measured **1,361 ms** in PointyCastle and **1,811 ms** in `cryptography` on desktop — i.e. ~9× *slower* than Argon2id at OWASP's `m=19456` profile while being *weaker* (not memory-hard). There is no FIPS requirement here. Argon2id wins on both axes. |

**Installation:**

```bash
flutter pub add pointycastle
```

The `pubspec.yaml` entry must carry the comment block CONTRIBUTING.md requires. Suggested
content (adapt to the plan's actual verification date):

```yaml
  # pointycastle 4.0.0 — Argon2id key derivation + AES-256-GCM authenticated
  # encryption for the encrypted backup archive (AUTH-09 / 08-01). The
  # already-present `crypto` 3.0.7 is hashing-only (no AES, no AEAD, no
  # PBKDF2 — confirmed against its own API docs), so a new package is
  # unavoidable. Chosen over `cryptography`/`cryptography_plus` (weaker
  # maintenance signal / far lower adoption) and over `webcrypto` (google.dev,
  # but builds BoringSSL from source via Dart build hooks — a from-source
  # native build in CI for a pre-1.0 package, disproportionate here).
  # [VERIFIED: pub.dev 2026-09-08, 140/160 score, MIT, verified publisher
  # bouncycastle.org (github.com/bcgit/pc-dart), 3.32M 30-day downloads.
  # Pure Dart; entire dependency graph is `collection` + `convert`, both
  # already in pubspec.lock — no FFI, no platform channels, no network I/O,
  # no blocklist prefix match. Argon2id output verified byte-identical
  # against an independent implementation; AES-GCM verified to reject a
  # tampered tag and a wrong key. Human-approved per Plan 08-01's blocking
  # package-legitimacy checkpoint]
  pointycastle: ^4.0.0
```

**Note for the plan:** `.privacy-blocklist.yaml` matching is by prefix over `pubspec.lock`.
`pointycastle`, `collection` and `convert` match none of the 14 blocked prefixes.
`test/ci/blocklist_test.dart` will exercise this automatically once the dependency lands; no
blocklist change is needed.

---

## Architecture Patterns

### Where the code goes

```
lib/
├── domain/
│   └── services/
│       ├── backup_archive_cipher.dart      NEW — pure bytes-in/bytes-out AEAD + KDF
│       ├── backup_export_service.dart      MODIFIED — composes the cipher, formatVersion 2
│       └── backup_sync_config.dart         NEW (08-03) — [ASSUMED] paths + feature flag
├── data/
│   └── remote/
│       └── backup_api_client.dart          NEW (08-03) — injectable http.Client
└── features/backup/
    ├── providers/
    │   ├── backup_notifier.dart            MODIFIED — passphrase plumbing
    │   └── backup_sync_notifier.dart       NEW (08-03)
    ├── screens/
    │   └── backup_restore_screen.dart      MODIFIED — encrypt toggle + restore prompt
    └── widgets/
        ├── passphrase_prompt_dialog.dart   NEW
        └── backup_sync_section.dart        NEW (08-03), flag-gated
docs/backend-contracts/
└── encrypted-backup-blob.md                NEW (08-02)
```

**Layering justification (this project's rule is strict, so state it explicitly in the plan).**
`docs/ARCHITECTURE.md` §2 permits `domain/` to import anything "not app-specific"; the existing
`backup_export_service.dart` already imports `archive`, `csv` and `excel` from `domain/services/`,
so a pure-Dart `pointycastle` import there is directly precedented. `BackupArchiveCipher` should
be a plain class with no DAO, no Riverpod, no Flutter widget imports — bytes in, bytes out —
which is what makes it trivially unit-testable. The `http`-touching 08-03 client belongs in
`data/remote/` alongside `reference_pack_api_client.dart`, and the screen must depend on the
notifier, never on the client.

**Existing deviation to be aware of, not to widen.** `BackupExportService` lives in
`domain/services/` but imports `data/local/daos/*`. That inversion already exists and Phase 8
should not deepen it: put the new crypto in its own dependency-free class rather than adding
another concern to the 688-line service.

### Pattern 1: Encrypted archive is still a `.zip` with a plaintext manifest

This is the most consequential structural decision in 08-01, and there is a hard platform reason
for it. `backup_notifier.dart`'s file picker passes
`XTypeGroup(extensions: ['zip'], uniformTypeIdentifiers: ['public.zip-archive'])`, with a code
comment recording that `file_selector_ios` reads **only** `uniformTypeIdentifiers` and throws
before presenting the picker if it is empty. A custom `.co2enc` extension would require
registering a new Uniform Type Identifier in `Info.plist` and declaring it as an exported type —
real iOS work, for no benefit. **Keep the `.zip` container.**

Structure:

```
co2diet_backup_encrypted_1757000000000.zip
├── manifest.json     plaintext, formatVersion 2, KDF + cipher parameters
└── payload.enc       AES-256-GCM(inner plaintext backup zip) ‖ 16-byte tag, stored uncompressed
```

Proposed `manifest.json`:

```json
{
  "formatVersion": 2,
  "createdAt": "2026-09-08T12:00:00.000Z",
  "encryption": {
    "scheme": "argon2id-aes256gcm-v1",
    "kdf": {
      "algorithm": "argon2id",
      "version": 19,
      "memoryKiB": 19456,
      "iterations": 2,
      "parallelism": 1,
      "saltBase64": "…16 random bytes…"
    },
    "cipher": {
      "algorithm": "AES-256-GCM",
      "nonceBase64": "…12 random bytes…",
      "tagBits": 128
    },
    "payloadFile": "payload.enc"
  }
}
```

**Why this shape:**

- `previewRestore` can read the manifest and answer "is this encrypted?" *without* the
  passphrase. That is exactly what success criterion 3 requires — detect and prompt, never a
  parse error.
- Every parameter needed to re-derive the key travels with the archive. Nothing is device-held.
  That is what makes AUTH-09's "restore on another device" true of the artifact, independent of
  transport.
- It leaks only "this is a CO₂ Diet encrypted backup, made at time T, with these KDF params".
  Deliberately **omit** the per-category `files`/`rowCount` array that formatVersion 1 carries —
  row counts are a metadata leak, and they are recoverable after decryption from the inner zip's
  own manifest anyway.
- The inner artifact is the *existing, unmodified* `formatVersion: 1` backup zip. So
  `applyRestore`'s entire existing code path — zip-slip validation, manifest parsing, per-category
  `fromJson` — is reused verbatim after decryption, with no duplicated restore logic.

### Pattern 2: Bind the manifest in as AEAD associated data

Pass the exact UTF-8 bytes of `manifest.json` as the GCM `AEADParameters` associated data.

**What this buys:** an attacker (or a corrupted transfer) cannot edit the manifest — e.g. lower
`memoryKiB` to weaken the KDF, or swap the salt — without the tag check failing. Verified today:
decrypting with different AAD fails with the same authentication error as a tampered ciphertext.

**The one rule this creates:** the encryptor must serialise the manifest **once**, use those
exact bytes as AAD, and write those exact bytes into the zip. The decryptor must read the raw
bytes from the zip and use them as AAD without re-serialising. Any `jsonEncode(jsonDecode(x))`
round-trip in between will silently break every restore, because key order or whitespace may
differ. Put this in a comment; it is the kind of thing that gets "cleaned up" later.

### Pattern 3: Compress, then encrypt — never the reverse

`BackupExportService.exportData` already produces a deflate-compressed zip. Encrypt **that**.
Ciphertext is incompressible, so encrypt-then-zip would produce a larger file and waste CPU. Set
`ArchiveFile('payload.enc', bytes.length, bytes)..compress = false` so `archive` stores the
payload rather than attempting deflate on random-looking bytes.

(The CRIME/BREACH class of compression-oracle attacks does not apply here: there is no
attacker-chosen plaintext mixed into the archive.)

### Pattern 4: Version handling — accept 1 *and* 2, keep writing 1 for plaintext

`BackupExportService` currently has `static const currentFormatVersion = 1` and
`_restorePreviewFromManifest` throws `UnsupportedBackupFormatException` for anything else. Its
own doc comment anticipates this phase: "a future encryption or restructured backup format
bumps this".

**Do not simply bump the constant to 2.** That would make every existing plaintext backup on
every user's device unrestorable. Instead:

- Keep writing `formatVersion: 1` for plaintext exports and backups. Unchanged bytes, unchanged
  behaviour, so success criterion 2 is satisfied by construction.
- Write `formatVersion: 2` only for the encrypted wrapper.
- Replace the equality check with a `supportedFormatVersions = {1, 2}` set membership check, and
  branch on the value: 1 → existing path; 2 → detect encryption, surface an
  `EncryptedBackupDetected` signal to the caller so the UI can prompt.
- The regression test that a `formatVersion: 3` archive still throws
  `UnsupportedBackupFormatException` must be kept — it is the mechanism that makes future format
  changes fail loudly.

An older app build reading a v2 archive throws `UnsupportedBackupFormatException` with a clear
message. That is the designed, correct behaviour; the copy just needs to say "made by a newer
version of the app".

### Pattern 5: Feature flag for 08-03

There is **no existing feature-flag mechanism in this codebase** (grepped: no `FeatureFlag`, no
flags file). Do not build one. Follow the established `[ASSUMED]` config-class precedent
(`BackendConfig`, `KeycloakConfig`, `ReferencePackConfig`) — a compile-time constant in a
centralised config class is the smallest thing that satisfies "defaults off, one-file change
later":

```dart
class BackupSyncConfig {
  const BackupSyncConfig._();

  /// `[ASSUMED]` — no backend endpoint exists (verified against
  /// CO2Diet_Backend@origin/main, 2026-09-06). MUST stay `false` until
  /// docs/backend-contracts/encrypted-backup-blob.md is confirmed by Tomris
  /// AND one real round trip has been observed on a device.
  static const bool enabled = false;

  static const String pushPath = '/api/v1/backup';
  static const String pullPath = '/api/v1/backup';
}
```

Gate the UI on `BackupSyncConfig.enabled && <account mode>`. Account mode comes from
`AuthNotifier`/`authProvider`; Phase 7's `realmDiscoveryReadyProvider` is the precedent for
hiding the surface entirely rather than showing a disabled affordance. A test can still
construct the notifier and API client directly regardless of the constant — keep the flag out of
the client and notifier constructors so they stay testable.

### Anti-patterns to avoid

- **A second backup pipeline.** CONTEXT.md locks this: encryption wraps `BackupExportService`'s
  output. Do not add a parallel "encrypted export" that re-reads the DAOs.
- **A "verifier" hash of the passphrase in the manifest.** It adds an offline-crackable target
  and buys nothing — GCM's tag already tells you the passphrase was wrong.
- **`Random()` for salt or nonce.** Only `Random.secure()`. See Pitfall 3.
- **Deriving the key on the UI isolate without a progress indicator.** See Pitfall 4.
- **Encrypting individual files inside the zip.** One payload, one key, one nonce, one tag. Per-file
  encryption multiplies nonce-management risk for zero benefit.

---

## Don't Hand-Roll

| Problem | Don't build | Use instead | Why |
|---|---|---|---|
| Turning a passphrase into a key | PBKDF2 on top of `crypto`'s `Hmac` (technically possible — `crypto` has HMAC-SHA256) | `pointycastle` `Argon2BytesGenerator` | A hand-rolled KDF loop gets the iteration/salt/output-length handling subtly wrong, and PBKDF2 is the weaker primitive anyway. Argon2id is memory-hard and, at the OWASP profile, measured *faster* than OWASP's PBKDF2 profile. |
| Authenticated encryption | AES-CBC + a separate HMAC ("encrypt-then-MAC") | `GCMBlockCipher(AESEngine())` | Composing your own AEAD means getting IV handling, MAC scope, and constant-time comparison right. GCM is a single reviewed primitive that does all three. |
| Detecting a wrong passphrase | Storing a hash/checksum of the passphrase or plaintext | The GCM tag | Authentication failure *is* the wrong-passphrase signal. A stored verifier is an extra offline-attack target. |
| Random salts / nonces | `Random()`, `DateTime.now()`, a UUID, a counter | `Random.secure()` | `Random()` is a PRNG seeded from low-entropy state and is not cryptographically secure. |
| A password strength meter | A bespoke regex/entropy scorer | Minimum length + a confirm field + a plain-language warning | NIST SP 800-63B guidance is length-first, no composition rules. A scorer here is UI theatre that adds maintenance surface. |
| Chunked/streaming encryption | A custom framing format with per-chunk nonces | One-shot GCM over the whole (already compressed) archive, with a size guard | Chunked AEAD framing is where real projects introduce reordering and truncation bugs. Archive sizes here do not justify it — revisit only if a real archive exceeds the guard. |
| A feature-flag framework | A flags service, remote config, `shared_preferences` plumbing | A `const bool` in an `[ASSUMED]` config class | One flag, one phase, defaults off, and remote config would itself be a network dependency this project does not want. |

**Key insight:** every one of these is a place where "it works in the happy path" and "it is
correct" diverge silently. Nothing in the app will fail visibly if the nonce is predictable or the
tag is never checked — the failure shows up only under an adversary, or years later when a
restore quietly produces garbage rows.

---

## Common Pitfalls

### Pitfall 1: Assuming `crypto` is enough because the name says crypto

**What goes wrong:** planning proceeds on "`crypto` ^3.0.7 is already there", then the
implementation task discovers there is no AES.
**Why it happens:** the package name. Its API is hashes, HMAC, and digests only.
**How to avoid:** treat the new dependency as a certainty, and put CONTRIBUTING.md's blocking
package-legitimacy checkpoint into 08-01's task list from the start — the same pattern as Plans
04-11, 05-08, 05-09, 05-16, 07-02 and 09-02.
**Warning signs:** any plan task that says "use the existing crypto package to encrypt".

### Pitfall 2: PointyCastle's `process()` silently skips authentication on ChaCha20-Poly1305

**Verified on pointycastle 4.0.0, 2026-09-08.** This is the sharpest edge found in this research.

| Call | AES-GCM (`GCMBlockCipher`) | ChaCha20-Poly1305 (`ChaCha20Poly1305`) |
|---|---|---|
| `process(plaintext)` on encrypt | Correct — returns ciphertext **+ 16-byte tag** | **BROKEN** — returns ciphertext with **no tag** (26 bytes in → 26 bytes out) |
| `process(ciphertext)` on decrypt | Correct — verifies tag, throws on failure | **BROKEN** — returns 38 bytes of garbage for a 42-byte input, **no verification** |
| `processBytes(...)` + `doFinal(...)` | Correct | Correct — 26 → 42 bytes, tag present |
| Tamper / wrong key exception | `InvalidCipherTextException` | `ArgumentError` |

**What goes wrong:** the ChaCha path looks like it works — round-trip tests pass in the happy
case if both sides use `process()` — while producing completely unauthenticated ciphertext.
**How to avoid:** if AES-GCM is used (the recommendation), `process()` is safe and the code stays
simple. If the ChaCha fallback is ever taken, `processBytes` + `doFinal` is mandatory and the
`catch` must include `ArgumentError` as well as `InvalidCipherTextException`.
**Warning signs:** a round-trip test that passes while `ciphertext.length == plaintext.length`.
Assert `ciphertext.length == plaintext.length + 16` explicitly — it is a one-line test that
catches this whole class of bug.

### Pitfall 3: A non-secure RNG, or a mis-seeded `FortunaRandom`

**What goes wrong:** salt/nonce generated with `Random()`, `DateTime.now().millisecondsSinceEpoch`,
or a `FortunaRandom` seeded from a timestamp. Every one of those makes the derived key and the
GCM keystream predictable.
**Why it happens:** PointyCastle's registry exposes `SecureRandom('Fortuna')`, which *requires*
an explicit 32-byte seed and is happy to be seeded with anything.
**How to avoid:** use `dart:math`'s `Random.secure()` directly for the 16-byte salt and 12-byte
nonce. It is backed by the platform CSPRNG (`/dev/urandom`, `arc4random`, `BCryptGenRandom`) and
needs no seeding. If a `SecureRandom` instance is needed for some other reason, seed it *from*
`Random.secure()`.
**Warning signs:** any `import 'dart:math'` without `.secure()`; any literal or time-derived seed.

### Pitfall 4: Blocking the UI isolate on the KDF and the cipher

**What goes wrong:** the app freezes for seconds with no feedback when the user taps "Create
encrypted backup".
**Measured cost (this machine, Apple Silicon, Dart 3.12.2 JIT — a mid-range Android device should
be assumed 3–6× slower):**

| Operation | Measured |
|---|---|
| Argon2id `m=19456 KiB, t=2, p=1` (PointyCastle) | **154 ms** |
| Argon2id `m=65536 KiB, t=2, p=1` (PointyCastle) | 366 ms |
| PBKDF2-HMAC-SHA256, 600k iterations (PointyCastle) | 1,361 ms |
| AES-256-GCM encrypt, 256 KiB | 169 ms |
| AES-256-GCM encrypt, 1 MiB | 604 ms |
| AES-256-GCM encrypt, 5 MiB | 2,925 ms |
| AES-256-GCM decrypt, 5 MiB | 3,038 ms |
| ChaCha20-Poly1305 encrypt, 5 MiB *(correct API)* | 69 ms |

A realistic archive is small — the backup is JSON rows, deflate-compressed, so even a multi-year
heavy user lands around 100–300 KB. Expected total on a mid Android: roughly 0.5–1.5 s. That is
short enough to be a spinner, not an isolate — **but only if it is measured, not assumed.**
**How to avoid:** run encrypt/decrypt through `compute()` (already available —
`backup_export_service.dart` imports `package:flutter/foundation.dart`) or accept a spinner, and
either way instrument the real archive size on the device checkpoint. Inject the "run this off
the main isolate" behaviour as a seam so unit tests can run in-process.
**Warning signs:** a device checkpoint that reports "worked fine" on a small test dataset only.

### Pitfall 5: Bumping `currentFormatVersion` to 2 and orphaning every existing backup

**What goes wrong:** every plaintext backup already on users' devices starts throwing
`UnsupportedBackupFormatException` on restore. This is a silent data-availability regression that
no existing test catches, because the existing tests all round-trip within one build.
**How to avoid:** Pattern 4 above — accept `{1, 2}`, keep writing 1 for plaintext.
**Warning signs:** a diff that changes `static const currentFormatVersion = 1`.

### Pitfall 6: "Cache the passphrase-derived key" does not work with a per-archive salt

CONTEXT.md's code-context note suggests `flutter_secure_storage` "may still be the right place to
cache a passphrase-derived key for the current session so the user is not re-prompted per
operation". With the recommended design that is **not coherent**, and the plan should resolve it
rather than inherit it:

- Each backup gets a **fresh random salt**, so each backup has a **different derived key**. A
  cached key from backup A cannot encrypt backup B and cannot decrypt archive C.
- Reusing one stable salt to make the key cacheable would mean storing that salt on the device —
  which reintroduces device-held state and, if the salt is not also written into every archive,
  breaks cross-device restore. (If the salt *is* written into every archive, it is no longer
  stable, and you are back where you started.)

**Recommendation:** if a "do not re-prompt me this session" convenience is wanted, cache the
**passphrase** in memory only — a field on a Riverpod notifier, never written to disk, cleared on
logout and on app lifecycle detach — and re-run Argon2id per operation (154 ms; imperceptible).
Do not put passphrase-derived material in `flutter_secure_storage`: it is device-bound Keychain/
Keystore state, which is precisely the option CONTEXT.md ruled out for key material.

### Pitfall 7: The wrong-passphrase error cannot distinguish "wrong passphrase" from "corrupt file"

**What goes wrong:** copy says "Wrong passphrase", the user's file was actually truncated by a
failed cloud sync, and they spend twenty minutes re-typing a passphrase that was correct.
**Why it happens:** an AEAD tag failure is one signal for many causes, by design.
**How to avoid:** one domain exception (`WrongBackupPassphraseException` or similar) mapped from
`InvalidCipherTextException`, with copy naming both possibilities — "That passphrase didn't work.
Either it's not the right one, or this backup file is damaged." Crucially: **nothing is written to
the database on this path.** Decryption happens before `applyRestore` ever reaches a DAO, so the
existing all-or-nothing guarantee holds. Assert that in a test.

### Pitfall 8: App Store export compliance becomes a submission blocker

**This is the pitfall most likely to be discovered at submission time rather than in planning.**

`ios/Runner/Info.plist` currently contains **no** `ITSAppUsesNonExemptEncryption` key (verified).
Today that is fine — the app's only cryptography is OS-provided HTTPS, which Apple treats as
exempt. Shipping an app-implemented AES-256-GCM changes the answer: Apple's guidance is that
encryption built into the OS is exempt, but apps that ship their own cryptography are not exempt
by default, and an app that "encrypts data at rest using a routine you wrote rather than CryptoKit
or Keychain" should not answer `false`. Answering `true` brings a US BIS annual self-classification
report (ERN) obligation, and App Store Connect additionally asks about French distribution.

**How to avoid:** make this an explicit deliverable of the phase, not an afterthought — a
decision recorded in the phase summary, plus the `Info.plist` key set deliberately, plus a note in
whichever doc tracks pre-submission artifacts (Phase 6 produced `PrivacyInfo.xcprivacy` and
`docs/PLAY_DATA_SAFETY_DRAFT.md`; this belongs beside them). This is a legal/administrative call
for Ali, not a code change — surface it, do not decide it.
**Warning signs:** the phase closes with no mention of export compliance anywhere.

### Pitfall 9: Assuming an encrypted blob on a server is outside GDPR

**What goes wrong:** 08-02 is written as though "the server can't read it" means the server has no
GDPR obligations, and the Privacy Policy is never updated.
**Why it happens:** it is an intuitive but incorrect reading. Data that is pseudonymised (or
encrypted without the recipient holding the key) is still personal data where it remains linkable
to an individual — and here the blob is stored **against an account identifier**. EDPB Guidelines
01/2025 state pseudonymised data counts as personal data even where the recipient does not
simultaneously hold the re-identification information. Encryption is an Art. 32 *security measure*,
not an exit from the Regulation.
**How to avoid:** 08-02 must state (a) the blob is personal data for retention/erasure purposes;
(b) `DELETE /api/v1/me/account` (or whatever the confirmed deletion path is) must delete the blob
in the same operation — cross-reference `gdpr-account-deletion.md`, which today says nothing about
backup blobs because none existed when it was written; (c) Art. 20 portability is already served
by PRIV-01's plaintext export, so the encrypted blob does not need a separate export route.
Additionally, the Privacy Policy must eventually say the operator cannot recover a lost passphrase.
**Warning signs:** an 08-02 draft with no retention or deletion section.

### Pitfall 10: Building 08-03 as though the mock is the verification

**What goes wrong:** 08-03's tests pass, the phase closes, and the first real request fails on
something a mock can never catch — a path prefix, a redirect, a TLS chain, an auth scheme, a body
encoding.
**Why it happens:** it is structurally unavoidable here. CONTEXT.md already accepts it; the risk
is forgetting to *record* it.
**How to avoid:** the plan should require the phase summary to carry an explicit
"not-verified-end-to-end" statement listing exactly what a mock cannot prove, and to keep the flag
`false`. `ReferencePackApiClient`'s history is the cautionary precedent — its real-device failure
mode was "no error, no progress, nothing in logcat", fixed only by adding an explicit `.timeout()`.
Apply that lesson pre-emptively: give the backup client an explicit timeout and a
`NetworkException` on non-2xx, mirroring that client exactly.

---

## Code Examples

All snippets below were executed against `pointycastle` 4.0.0 on Dart 3.12.2 on 2026-09-08 and
produced the stated results. They are illustrative shapes, not drop-in code.

### Deriving the key (Argon2id, OWASP profile)

```dart
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

/// OWASP Password Storage Cheat Sheet, second Argon2id profile.
const kArgon2MemoryKiB = 19456; // 19 MiB
const kArgon2Iterations = 2;
const kArgon2Parallelism = 1;

Uint8List randomBytes(int n) {
  final rnd = Random.secure(); // NEVER Random()
  return Uint8List.fromList(List<int>.generate(n, (_) => rnd.nextInt(256)));
}

Uint8List deriveKey(String passphrase, Uint8List salt) {
  final generator = Argon2BytesGenerator()
    ..init(Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      salt,
      desiredKeyLength: 32,
      iterations: kArgon2Iterations,
      memory: kArgon2MemoryKiB,
      lanes: kArgon2Parallelism,
      version: Argon2Parameters.ARGON2_VERSION_13,
    ));
  final out = Uint8List(32);
  generator.deriveKey(
    Uint8List.fromList(utf8.encode(passphrase)), 0, out, 0,
  );
  return out;
}
```

Verified: output is byte-identical to `package:cryptography`'s independent Argon2id
implementation for the same parameters — cross-implementation agreement, so the parameter mapping
above is correct.

### Encrypting and decrypting (AES-256-GCM, manifest bound as AAD)

```dart
GCMBlockCipher _gcm(bool forEncryption, Uint8List key, Uint8List nonce, Uint8List aad) =>
    GCMBlockCipher(AESEngine())
      ..init(forEncryption, AEADParameters(KeyParameter(key), 128, nonce, aad));

/// Returns ciphertext ‖ 16-byte tag.
Uint8List encryptPayload(Uint8List plaintext, Uint8List key, Uint8List nonce, Uint8List manifestBytes) =>
    _gcm(true, key, nonce, manifestBytes).process(plaintext);

/// Throws [InvalidCipherTextException] on wrong passphrase, tampered
/// ciphertext, tampered tag, or a tampered manifest.
Uint8List decryptPayload(Uint8List ciphertext, Uint8List key, Uint8List nonce, Uint8List manifestBytes) =>
    _gcm(false, key, nonce, manifestBytes).process(ciphertext);
```

Verified behaviour: `process()` on encrypt returns `plaintext.length + 16` bytes; round-trip
recovers the plaintext exactly; a flipped ciphertext byte, a flipped tag byte, a wrong key, and a
modified AAD each throw `InvalidCipherTextException`.

### Wrapping into the zip (archive 3.6.1 API, unchanged pin)

```dart
final encoder = ZipFileEncoder()..create(outPath);
final manifestBytes = Uint8List.fromList(utf8.encode(manifestJsonString));
encoder.addArchiveFile(
  ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
);
encoder.addArchiveFile(
  ArchiveFile('payload.enc', sealed.length, sealed)..compress = false,
);
await encoder.close();
```

`ArchiveFile.compress` is a public settable `bool` (default `true`) in archive 3.6.1 — verified in
the local pub cache. `create`/`addArchiveFile`/`close` are the same three calls
`BackupExportService.exportData` already uses, so no new archive API surface is introduced and the
3.6.1 pin is untouched.

### Detecting encryption during preview (no passphrase required)

```dart
final archive = ZipDecoder().decodeBytes(await zip.readAsBytes());
final manifest = jsonDecode(_contentAsString(archive.findFile('manifest.json')!))
    as Map<String, dynamic>;
final version = manifest['formatVersion'] as int?;

switch (version) {
  case 1:
    return _restorePreviewFromManifest(manifest);      // existing path
  case 2:
    return RestorePreview.encrypted(                    // new: prompts for passphrase
      backupDate: DateTime.tryParse(manifest['createdAt'] as String? ?? ''),
    );
  default:
    throw UnsupportedBackupFormatException(version ?? -1);
}
```

### 08-03 API client shape (mirrors `ReferencePackApiClient` exactly)

```dart
class BackupApiClient {
  const BackupApiClient(this._client, {required this.baseUrl});

  final http.Client _client;
  final String baseUrl;
  static const _timeout = Duration(seconds: 30);

  Future<void> push(Uint8List blob, String accessToken) async {
    final response = await _client
        .post(
          Uri.parse('$baseUrl${BackupSyncConfig.pushPath}'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/octet-stream',
          },
          body: blob,
        )
        .timeout(_timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NetworkException('Backup push failed: HTTP ${response.statusCode}');
    }
  }

  /// Returns `null` when the server holds no backup for this user (404) —
  /// an expected state, not an error.
  Future<Uint8List?> pull(String accessToken) async { /* … 404 → null … */ }
}
```

---

## 08-02 Contract Research — what the document needs to cover

The existing `gdpr-account-deletion.md` is the template: YAML frontmatter
(`status: ASSUMED -- not yet confirmed with Tomris`, `requested_by`, `owner`,
`related_requirement`, `last_updated`), then a "this is a proposal for review, not a description
of an agreed contract" paragraph, assumed-request and assumed-response tables with a `Status`
column that says `[ASSUMED]` on every row, a "client-side isolation point" section naming the one
file that would change, and a numbered "Open questions for Tomris" list. Match that structure.

**Content checklist, grounded in what was verified above:**

| Area | What to specify | Grounding |
|---|---|---|
| Paths | `POST /api/v1/backup` (push), `GET /api/v1/backup` (pull) | The backend's own `docs/backend-architecture.md` "API surface" block — use its paths, do not invent. |
| Auth | `Authorization: Bearer <access_token>`; user identified by the JWT `sub` claim, never a request parameter | `SecurityConfig` is `oauth2ResourceServer().jwt()` with `.anyRequest().authenticated()`; `MeController` already reads `jwt.getSubject()`. |
| Body | `Content-Type: application/octet-stream`, raw archive bytes | The blob is a zip; base64 in JSON would inflate it 33% for no gain. Flag as `[ASSUMED]` — Tomris may prefer multipart. |
| Semantics | One backup per user, last-write-wins overwrite. **Explicitly not** a version history | CONTEXT.md defers multi-backup UX; a history would require the deferred restore-picker UI. |
| Pull when none exists | `404` → client treats as "no server backup yet", not an error | Must be stated; it is the single most likely client-side mishandling. |
| Size limit | Propose a concrete number (e.g. 25 MB) and ask Tomris to confirm, plus the status the server returns when exceeded (`413`) | Without a stated limit the client cannot give a useful pre-flight error. |
| Versioning | The blob's own `formatVersion` lives *inside* the archive; the server must not parse it. Propose an opaque `X-Backup-Format: 2` header or a body-free contract and ask which Tomris prefers | Keeps the server free of any need to understand the payload. |
| Metadata the server may hold | Only: user id, byte size, upload timestamp, opaque ETag. Explicitly **not** row counts, categories, date ranges | This is the line between "opaque blob store" and "user data store". |
| Concurrency | Optional `ETag` / `If-Match` on push to detect a concurrent overwrite from another device | Cheap to specify now, expensive to retrofit. Mark `[ASSUMED]`, low priority. |
| Retention & deletion | The blob is personal data. Account deletion must delete it in the same operation. Cross-reference `gdpr-account-deletion.md` | EDPB Guidelines 01/2025 on pseudonymisation; Art. 17. `gdpr-account-deletion.md` predates any blob and does not mention one. |
| Negative scope | No decryption, no inspection, no merge, no per-field access, no server-side key material, no analytics on blob contents or timing | Quote the backend's own module description back: "Stores **opaque end-to-end-encrypted blobs only** — the server cannot read meals/weight/profile." |
| Open questions | Include the `/me/account` vs `/api/v1/...` path prefix inconsistency; whether the backup decision (§13) has moved; whether the operator accepts that no support-side recovery is possible | Directly observed; §13 is still open as of `origin/main` 2026-09-06. |

---

## 08-03 Client Research — what can and cannot be established

| Question | Answer |
|---|---|
| Where does the base URL come from? | `BackendConfig.baseUrl` — already the single `[ASSUMED]` source, currently `http://localhost:8080`. |
| HTTP client convention? | Injectable `http.Client` + `mocktail`, per `ReferencePackApiClient` and `AuthNotifier`'s `authHttpClientProvider`. Established and tested in this repo. |
| Timeout? | Mandatory. `ReferencePackApiClient` learned this the hard way (`T-09-08-diagnostic`: an unreachable host produced "no error, no progress, nothing in logcat"). Use an explicit `.timeout()` and a `NetworkException` on non-2xx. |
| Account gating? | `AuthNotifier` is the single source of truth for Account Mode. Hide the section entirely when not in Account Mode, per Phase 7's precedent. |
| What can tests prove? | Request shape only: method, path, `Authorization` header, `Content-Type`, body bytes identity, `404` → `null`, non-2xx → typed exception, timeout → typed exception. |
| What can tests never prove? | That the endpoint exists, that the path prefix is right, that the auth scheme is accepted, that the body encoding is what the server wants, that TLS works, that any size limit is real. |
| Large-body concern | `http`'s `post(body: Uint8List)` buffers the whole blob in memory. Fine at 100–300 KB. If the size guard is set high, consider `http.StreamedRequest` — but do not build it speculatively. |

---

## PRIV-03 (automatic backups) × passphrase — options, with a correction

**A verified fact that changes this discussion.** CONTEXT.md and REQUIREMENTS.md both describe
PRIV-03 as delivering "configurable automatic backups". In the shipped code, `autoBackupFrequency`
(`'off'` / `'daily'` / `'weekly'`) is **persisted as a preference and nothing reads it to trigger a
backup**. `createBackup()` has exactly two call sites, both user-initiated:
`BackupNotifier.createAndShareBackup()` ← `BackupRestoreScreen._createBackup()` (the "Create
backup" button). There is no scheduler anywhere in `lib/` — a comment in
`reference_pack_schedule_provider.dart` states outright that "no workmanager/background_fetch/
Timer.periodic exists anywhere in this" codebase.

So the scenario CONTEXT.md worries about — a scheduled backup silently encrypted with a
forgotten passphrase — **cannot occur today**, because nothing runs unattended. The decision is
therefore about not painting a future scheduler into a corner, and it can be made cheaply.

| Option | What it means | Assessment |
|---|---|---|
| **A. Automatic backups stay plaintext; encryption is user-initiated only** | The encrypt toggle lives on the "Create backup" action, not on the frequency selector | **Recommended.** The two features address different threats: an automatic local backup defends against *data loss*, and the file never leaves the app's sandboxed documents directory (iOS Data Protection / Android app-private storage already cover it at rest). Encryption defends against *exfiltration* — which only becomes relevant when the archive is shared or pushed, both of which are explicit user actions. Zero risk of an unrecoverable automatic backup. |
| B. Automatic backups encrypted with a passphrase held in `flutter_secure_storage` | The key becomes device-bound | Reintroduces exactly the property CONTEXT.md ruled out, and buys nothing over the OS protection the file already has. |
| C. Automatic backups encrypted, passphrase re-prompted on schedule | — | Defeats the point of "automatic". |
| D. Ask at the moment automatic backups are enabled | A choice between "local, unencrypted" and "encrypted (you must remember your passphrase)" | Reasonable if the user is ever given a destination outside the sandbox. Given there is no scheduler, this is speculative UI. |

**Recommendation for the plan:** take option A, and record in the phase summary that automatic
backups are deliberately excluded from encryption *and why* — so that whoever eventually builds
the scheduler finds the reasoning rather than re-litigating it. If the encrypt toggle is placed
on the "Create backup" action (not on the frequency selector), option A is the default that falls
out of the UI structure and needs no extra code.

---

## First-encrypted-backup consent moment (CONTEXT.md requires this be designed)

CONTEXT.md: the unrecoverability "has to be said *before* the user creates their first encrypted
backup, in plain language, not buried in a help screen afterwards."

Suggested shape, consistent with this project's non-judgemental tone and its existing consent
precedent (LEGAL-01's separate, unchecked checkboxes; PRIV-09's typed confirmation in the Danger
Zone):

1. Toggle "Encrypt this backup" on the Create Backup action → passphrase sheet opens.
2. Passphrase field + confirm field. Minimum length only (NIST SP 800-63B is length-first: no
   composition rules, no hints, allow paste, allow any printable character). Suggest a 10–12
   character minimum and say why in one line.
3. A plain-language block above the button, not below it:
   *"Only you can unlock this backup. We can't reset it, and neither can the server — it only
   ever holds bytes it can't read. If you lose this passphrase, this backup is gone."*
4. A single unchecked confirmation checkbox: "I understand this backup can't be recovered without
   this passphrase." Button disabled until checked and both fields match. This mirrors LEGAL-01's
   established pattern rather than inventing a new one.
5. Encourage a password manager explicitly. This is the one genuinely effective mitigation.

Restore side: preview detects `formatVersion: 2` → prompt sheet → on failure, the Pitfall 7 copy.
The existing preview-and-confirm flow is unchanged after successful decryption.

---

## State of the Art

| Old approach | Current approach | When changed | Impact here |
|---|---|---|---|
| PBKDF2 as the default password KDF | Argon2id (memory-hard) is the default recommendation; PBKDF2 is retained for FIPS-140 contexts | OWASP has recommended Argon2id first for several revisions; PBKDF2's recommended count rose to 600,000 in 2023 | No FIPS requirement here. Argon2id at `m=19456,t=2,p=1` is both stronger and ~9× faster than PBKDF2@600k in this stack (measured). |
| Zip's built-in password protection (ZipCrypto / AES-256 zip) | Encrypt the payload with an explicit AEAD and keep the zip as a dumb container | Long-standing; ZipCrypto is broken and zip AES lacks integrity over metadata | `archive` 3.6.1 does not implement encrypted zip entries anyway, so this is settled by the toolchain. |
| Flutter native code via plugin scaffolding | Dart build hooks (`hooks` + `code_assets`), stable since Flutter 3.38 / Dart 3.10 | Nov 2025 | Explains why `webcrypto` 0.6.1 changed its build system; it is supported by this project's Flutter 3.44.6, but it is a new-ish path on a pre-1.0 package. |
| `flutter_markdown`, `flutter_downloader` and similar going unmaintained | This project's habit of checking last-publish date and publisher before adopting | Ongoing | Applies directly: `encrypt` (2023) is out; `cryptography` carries a maintenance-move signal; `pointycastle`'s Feb-2025 release is 19 months old but from an organisation whose whole purpose is a stable crypto library — comparable to the documented `excel` 4.0.6 staleness acceptance, and worth an explicit line in the pubspec comment. |

**Deprecated / not to be used:**

- `crypto` for encryption — it has none. Hashing/HMAC only.
- `encrypt` 5.0.3 — last published 2023-09-18.
- Hand-rolled encrypt-then-MAC over AES-CBC — superseded by AEAD.
- PointyCastle's `ChaCha20Poly1305.process()` — verified broken in both directions (Pitfall 2).

---

## Open Questions

1. **Does the export-compliance answer change, and who files the BIS self-classification report?**
   - Known: `Info.plist` has no `ITSAppUsesNonExemptEncryption` today; Apple's guidance is that
     app-implemented cryptography is not exempt by default; answering `true` implies an annual
     BIS self-classification report and a French-distribution question in App Store Connect.
   - Unclear: whether Ali or the organisation files it, and whether the app qualifies for a
     mass-market exemption from a CCATS review.
   - Recommendation: 08-01 sets the `Info.plist` key deliberately and records the decision; the
     filing itself is flagged as a pre-launch item for Ali (like NFR-03's SAM test), not built.

2. **What is the actual archive size for a realistic dataset?**
   - Known: the compression-then-encryption ordering means the encrypted payload is the
     deflate-compressed JSON. Estimated 100–300 KB for a multi-year heavy user.
   - Unclear: the true figure on a real device with a real dataset.
   - Recommendation: measure it in 08-01's device checkpoint and record the number. It decides
     whether the AES-GCM/ChaCha question ever needs revisiting, and it is the input to 08-02's
     proposed size limit. An `integration_test/` benchmark following the existing
     `meal_logging_benchmark_test.dart` precedent is the cheapest way to get it.

3. **Has Tomris's §13 decision moved since 2026-09-06?**
   - Known: `origin/main` at 2026-09-06 still lists it as open, and still says the product doc
     leans user-cloud.
   - Unclear: anything discussed off-repo.
   - Recommendation: do not block on it. 08-02 exists precisely to force the decision, and 08-01
     is valuable under either outcome.

4. **Should the encrypted archive record the app version that produced it?**
   - Known: `package_info_plus` is already a dependency and the plaintext manifest carries
     `createdAt` but not an app version.
   - Unclear: whether it is worth the (small) fingerprinting surface in a file that may sit on a
     server.
   - Recommendation: leave it out of the encrypted wrapper's plaintext manifest; the inner
     archive can carry it if useful. Minimise what the plaintext layer reveals.

5. **Is a passphrase-strength minimum a hard gate or a warning?**
   - Known: NIST SP 800-63B guidance is length-first with no composition rules; the project's tone
     rules discourage friction and judgement.
   - Unclear: what minimum length is right for this audience.
   - Recommendation: Claude's-discretion territory. Suggest a hard minimum of 10–12 characters and
     no other rules, with copy that explains rather than scolds.

---

## Validation Architecture

### Test framework

| Property | Value |
|---|---|
| Framework | `flutter_test` (bundled with Flutter 3.44.6) + `mocktail` 1.0.5 + `fake_async` 1.3.3 |
| Config file | none — no `dart_test.yaml`; discovery is convention-based from `test/` |
| Quick run command | `flutter test test/domain/services/backup_archive_cipher_test.dart test/domain/services/backup_export_service_test.dart` |
| Full suite command | `flutter test` |
| Device/integration | `flutter test integration_test/backup_encryption_benchmark_test.dart -d <device>` (new; follows `meal_logging_benchmark_test.dart`) |
| CI equivalent | `.github/workflows/ci.yml` runs `dart run scripts/check_privacy_deps.dart pubspec.lock .privacy-blocklist.yaml`, then `flutter analyze --no-fatal-warnings`, then `dart test` |
| Existing baseline | 99 `*_test.dart` files under `test/`, 5 under `integration_test/` |

All crypto used here is pure Dart with no platform channels, so **every 08-01 assertion runs in
plain `flutter test`** — no device, no mock platform channel, no backend. That is the whole point
of sequencing 08-01 first.

### Phase requirements → test map

| Criterion | Behavior | Test type | Automated command | File exists? |
|---|---|---|---|---|
| SC-1 | Encrypt → decrypt round trip recovers the original archive bytes exactly | unit | `flutter test test/domain/services/backup_archive_cipher_test.dart` | ❌ Wave 0 |
| SC-1 | Ciphertext length == plaintext length + 16 (tag actually present — guards Pitfall 2) | unit | same | ❌ Wave 0 |
| SC-1 | Wrong passphrase throws the typed domain exception, writes nothing to any DAO | unit | `flutter test test/domain/services/backup_export_service_test.dart` | ⚠️ file exists, cases missing |
| SC-1 | Tampered ciphertext byte / tampered tag byte / tampered manifest each throw | unit | `flutter test test/domain/services/backup_archive_cipher_test.dart` | ❌ Wave 0 |
| SC-1 | Two encryptions of identical input produce different salt, nonce and ciphertext (randomness is live) | unit | same | ❌ Wave 0 |
| SC-1 | Argon2id parameters in the manifest round-trip and are honoured on decrypt | unit | same | ❌ Wave 0 |
| SC-2 | Plaintext export/backup still emits `formatVersion: 1` and identical structure (regression) | unit | `flutter test test/domain/services/backup_export_service_test.dart` | ✅ extend existing |
| SC-2 | A `formatVersion: 1` archive created before this phase still restores | unit | same | ✅ extend existing |
| SC-2 | A `formatVersion: 3` archive still throws `UnsupportedBackupFormatException` | unit | same | ✅ exists |
| SC-3 | `previewRestore` on a v2 archive returns "encrypted" **without** a passphrase and without throwing | unit | same | ❌ Wave 0 |
| SC-3 | Screen shows the passphrase prompt when preview reports encrypted | widget | `flutter test test/features/backup/backup_restore_screen_test.dart` | ✅ extend existing |
| SC-3 | Wrong-passphrase error surfaces inline, dataset unchanged | widget | same | ❌ Wave 0 |
| SC-4 | Contract document exists with `status: ASSUMED` frontmatter and the negative-scope section | manual-only | — reviewed as part of `/gsd:verify-work`; a doc has no runnable assertion | n/a |
| SC-5 | Push sends `POST {baseUrl}/api/v1/backup`, bearer header, octet-stream, exact blob bytes | unit | `flutter test test/data/remote/backup_api_client_test.dart` | ❌ Wave 0 |
| SC-5 | Pull `404` → `null` (not an error); non-2xx → typed exception; timeout → typed exception | unit | same | ❌ Wave 0 |
| SC-5 | Sync section is absent from the UI while the flag is `false` | widget | `flutter test test/features/backup/backup_restore_screen_test.dart` | ❌ Wave 0 |
| SC-5 | Sync section is absent when not in Account Mode | widget | same | ❌ Wave 0 |
| SC-6 | No HLC / outbox / merge / conflict code is introduced (grep-style structural assertion, or reviewer check) | manual-only | — a negative-existence claim; verify by diff review | n/a |
| PRIV-07 | New dependency does not match any blocklist prefix, transitively | unit | `flutter test test/ci/blocklist_test.dart` | ✅ exists, covers automatically |
| Perf | Real archive size + encrypt/decrypt wall time on a physical device | integration | `flutter test integration_test/backup_encryption_benchmark_test.dart -d <device>` | ❌ Wave 0 |

### Sampling rate

- **Per task commit:** `flutter test test/domain/services/backup_archive_cipher_test.dart test/domain/services/backup_export_service_test.dart` (sub-30s; Argon2id at 19 MiB is ~150 ms per derivation, so keep the number of full-KDF tests small and use a reduced-memory profile in tests where the KDF itself is not what is under test)
- **Per wave merge:** `flutter test`
- **Phase gate:** `flutter analyze --no-fatal-warnings` clean **and** `flutter test` green **and** the device benchmark run, before `/gsd:verify-work`

### Wave 0 gaps

- [ ] `test/domain/services/backup_archive_cipher_test.dart` — SC-1 (round trip, tag length, tamper × 3, wrong key, randomness, KDF parameter round-trip)
- [ ] `test/data/remote/backup_api_client_test.dart` — SC-5 request shape, 404→null, non-2xx, timeout (mocktail `http.Client`, mirroring `test/data/remote/reference_pack_api_client_test.dart`)
- [ ] `test/features/backup/providers/backup_sync_notifier_test.dart` — SC-5 notifier orchestration
- [ ] `integration_test/backup_encryption_benchmark_test.dart` — Open Question 2's measurement
- [ ] Extend `test/domain/services/backup_export_service_test.dart` — SC-2 regressions, SC-3 preview detection, wrong-passphrase-writes-nothing
- [ ] Extend `test/features/backup/backup_restore_screen_test.dart` — SC-3 prompt + error copy, SC-5 flag/account gating
- [ ] No framework install needed — `flutter_test`, `mocktail` and `integration_test` are already dependencies

---

## Sources

### Primary (HIGH confidence)

- **Local repository, read directly (2026-09-08):** `lib/domain/services/backup_export_service.dart`, `lib/features/backup/**`, `lib/domain/services/backend_config.dart`, `lib/domain/services/reference_pack_config.dart`, `lib/data/remote/reference_pack_api_client.dart`, `lib/features/auth/providers/auth_provider.dart`, `pubspec.yaml`, `.privacy-blocklist.yaml`, `.github/workflows/ci.yml`, `docs/ARCHITECTURE.md`, `docs/CONTRIBUTING.md`, `docs/backend-contracts/gdpr-account-deletion.md`, `ios/Runner/Info.plist`, `test/**`
- **`ReduceCO2Now-com/CO2Diet_Backend`** — `git fetch origin` performed 2026-09-08; `origin/main` = `d551d0b` (2026-09-06). Verified module tree, controllers, `SecurityConfig.java`, Flyway migrations, and `docs/backend-architecture.md` §5 module table, §11 layout, §13 open items, and the API-surface block.
- **Executed benchmarks and correctness checks** — `pointycastle` 4.0.0 and `cryptography` 2.9.0 on Dart 3.12.2 (Apple Silicon), 2026-09-08. All timings and all pass/fail behaviours quoted in this document were produced by running the code, not recalled.
- **pub.dev API** (`/api/packages/<name>` and `/api/packages/<name>/score`) for exact versions, publish dates, publishers, dependency sets, pub points, likes and 30-day download counts — `crypto`, `cryptography`, `cryptography_plus`, `pointycastle`, `webcrypto`, `encrypt`, `cryptography_flutter`
- <https://pub.dev/documentation/crypto/latest/> — confirms `crypto` is hashing-only (no AES, no PBKDF2)
- <https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html> — Argon2id and PBKDF2 parameter profiles
- <https://developer.apple.com/documentation/bundleresources/information-property-list/itsappusesnonexemptencryption> and <https://developer.apple.com/help/app-store-connect/reference/app-information/export-compliance-documentation-for-encryption> — export-compliance rules
- **Local pub cache** `archive-3.6.1/lib/src/archive_file.dart` and `lib/src/io/zip_file_encoder.dart` — `ArchiveFile.compress` and the `create`/`addArchiveFile`/`close` API confirmed present at the pinned version

### Secondary (MEDIUM confidence)

- <https://blog.flutter.dev/announcing-flutter-3-38-dart-3-10-building-the-future-of-apps-503429eeb685> and <https://dart.dev/tools/hooks> — build hooks / code assets stable since Flutter 3.38 / Dart 3.10 (relevant only to the `webcrypto` alternative)
- EDPB Guidelines 01/2025 on pseudonymisation, via <https://www.cliffordchance.com/insights/resources/blogs/talking-tech/en/articles/2025/09/pseudonymized-data-after-edps-v-srb.html> and <https://sgklegal.gr/en/guidelines-of-the-edpb-on-pseudonymisation/> — encrypted/pseudonymised data remains personal data where linkable
- NIST SP 800-63B memorized-secret guidance (length-first, no composition rules) — recalled and consistent with multiple sources, not re-verified against the publication for this phase

### Tertiary (LOW confidence — flagged for validation)

- The 100–300 KB archive-size estimate is a calculation from row-shape and compression ratios, **not a measurement**. Open Question 2 exists to replace it with a real number.
- The "3–6× slower on a mid-range Android device" scaling factor applied to the desktop benchmarks is a rule of thumb, not a measurement on this project's reference hardware (Galaxy Tab S7 FE).

---

## Metadata

**Confidence breakdown:**

| Area | Level | Reason |
|---|---|---|
| `crypto` is insufficient | HIGH | Confirmed against the package's own API documentation and its README disclaimer. |
| Package choice (`pointycastle`) | HIGH | Publisher, licence, dependency graph, pub score and download counts read from the pub.dev API; algorithms exercised locally; Argon2id cross-verified byte-for-byte against an independent implementation. |
| Measured performance figures | HIGH for the machine they were measured on; MEDIUM as a predictor of device behaviour | Real runs, but on Apple Silicon desktop JIT. The device checkpoint is what converts this to HIGH for the target hardware. |
| PointyCastle ChaCha `process()` trap | HIGH | Directly reproduced in both encrypt and decrypt directions, with byte-length evidence. |
| Archive/container design | HIGH | Grounded in the actual shipped code, the actual `archive` 3.6.1 API in the local pub cache, and the existing iOS UTI constraint recorded in `backup_notifier.dart`. |
| Backend current state | HIGH | Verified against a freshly fetched `origin/main`, not a stale local clone. |
| Backend future behaviour | LOW by construction | §13 is open; nothing about a future endpoint can be verified. This is the phase's accepted, recorded risk. |
| GDPR treatment of encrypted blobs | MEDIUM | Consistent across multiple legal-analysis sources citing EDPB Guidelines 01/2025; not verified against the primary EDPB text, and not legal advice. |
| Export-compliance obligation | MEDIUM | Apple's own documentation is clear that OS encryption is exempt and app-implemented encryption is not; whether a specific exemption applies to this app is a question for Ali, not a research finding. |
| PRIV-03 interaction | HIGH | The absence of any scheduler was verified by grep across `lib/`, and is corroborated by an explicit code comment in `reference_pack_schedule_provider.dart`. |

**Research date:** 2026-09-08
**Valid until:** ~2026-10-08 for the package landscape (stable, slow-moving). The backend section
should be re-checked with a single `git fetch` immediately before 08-02 is written — it changed
once already between CONTEXT.md's scan and this one.

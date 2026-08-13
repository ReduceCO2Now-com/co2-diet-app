---
status: ASSUMED -- design proposal, not confirmed with CDN/build owner
requested_by: Ali (Flutter client)
owner: unassigned -- whoever eventually stands up CDN hosting + the build-pipeline (a coordination point per 09-CONTEXT.md, not yet owned by anyone)
related_phase: 09-reference-data-delivery-full-off-pack
last_updated: 2026-08-13
---

# Reference Pack Manifest & Delta Artifact — Data Contract Spec

This document specifies the `manifest.json` and delta-artifact contract that the Flutter
client (Plan 09-02's `ReferencePackManifest.fromJson`, Plan 09-03's `DownloadManager`, and
Plan 09-04's `DeltaApplier`/`ReferencePackRepository`) is built against. **Every field below
is `[ASSUMED — design proposal, not confirmed with CDN/build owner]`** — this is a concrete
written proposal for review, not a description of an already-agreed external contract. Per
`09-RESEARCH.md`'s Assumptions Log entry A3, this doc exists specifically so a future
CDN/build-pipeline owner has something concrete to confirm, adjust, or reject, rather than the
client silently guessing at runtime — the same hand-off pattern `docs/backend-contracts/gdpr-account-deletion.md`
established for Tomris (see `STATE.md`'s `[Phase 07-08]` decision entry establishing that
`docs/backend-contracts/` precedent for written spec hand-offs; `docs/data-contracts/` is the
sibling directory for this class of doc).

CDN hosting itself, and the build-pipeline's operational ownership, are explicitly out of
Phase 9's scope (a flagged coordination point per `09-CONTEXT.md`). `tools/build_reference_pack_release.py`
(this plan's other deliverable) is the reference implementation this spec describes — it is
run manually today, mirroring the existing Phase 2 seed-generation workflow.

## 1. `manifest.json` shape

A single small JSON document the client fetches via a lightweight `GET` (Plan 09-02's
`ReferencePackApiClient.fetchManifest()`), on any connection type — it must stay small enough
that fetching it never needs Wi-Fi gating.

### Fields

| Field | Type | `[ASSUMED]` | Description |
|---|---|---|---|
| `current_version` | `string` | `[ASSUMED]` | Opaque version tag for the latest published full pack (e.g. `"2026-09-off-pack-v3"`). Client treats this as an opaque string for equality/lookup only — never parses it for ordering. |
| `pack_url` | `string` (HTTPS URL) | `[ASSUMED]` | Absolute HTTPS URL to the current full-pack release artifact (`full_v<version>.sqlite.gz`). Must be `https://` — plain `http://` is rejected by the client (see Section 4, Validation). |
| `pack_size_bytes` | `integer` | `[ASSUMED]` | Size in bytes of the **compressed** `.sqlite.gz` artifact at `pack_url`. See Section 3 for the compressed-vs-decompressed distinction — this is not the installed/decompressed footprint. |
| `pack_sha256` | `string` (64 lowercase hex chars) | `[ASSUMED]` | SHA-256 digest of the **compressed** `.sqlite.gz` artifact's exact bytes, hex-encoded. Client recomputes this over the downloaded file before trusting it (Plan 09-02's `ChecksumVerifier`). |
| `product_count` | `integer` | `[ASSUMED]` | `SELECT COUNT(*) FROM products` in the full pack this manifest describes. Powers the Settings screen's "2.5M products (full catalog)" comparison copy. |
| `delta_from` | `object` (map) | `[ASSUMED]` | Maps a prior `current_version` string the client might already have installed to `{url, size_bytes, sha256}` describing a delta artifact that upgrades from that prior version to `current_version`. May be an empty object `{}` when no delta path exists yet (e.g. the very first published version). |
| `delta_from.<old_version>.url` | `string` (HTTPS URL) | `[ASSUMED]` | Absolute HTTPS URL to the delta artifact (`delta_v<old>_to_v<new>.sqlite`). |
| `delta_from.<old_version>.size_bytes` | `integer` | `[ASSUMED]` | Size in bytes of the delta artifact. Unlike `pack_size_bytes`, this describes an **uncompressed** plain SQLite file — see Section 3. |
| `delta_from.<old_version>.sha256` | `string` (64 lowercase hex chars) | `[ASSUMED]` | SHA-256 digest of the delta artifact's exact bytes, hex-encoded. |

### Worked example

```json
{
  "current_version": "2026-09-off-pack-v3",
  "pack_url": "https://cdn.example.com/off-pack/full_v3.sqlite.gz",
  "pack_size_bytes": 681574912,
  "pack_sha256": "3b1c9f2e7a4d6b8c1e0f5a2d9c7b3e6f1a4d8c2b9e7f0a3d6c1b8e4f2a9d7c0b",
  "product_count": 2500000,
  "delta_from": {
    "2026-08-off-pack-v2": {
      "url": "https://cdn.example.com/off-pack/delta_v2_to_v3.sqlite",
      "size_bytes": 18874368,
      "sha256": "9e2a7c4f1b8d3e6a0c5f2b9d7e4a1c8f3b6d0e9a2c5f8b1d4e7a0c3f6b9d2e5a"
    }
  }
}
```

## 2. Client-side validation (required, every field, every fetch)

Before the client trusts any field of a fetched manifest, it performs:

1. **HTTPS-only enforcement.** `pack_url` and every `delta_from.*.url` must have scheme
   `https`. A manifest with a plain-`http` URL for either field is rejected outright — this
   guards against a man-in-the-middle downgrade of the manifest response itself (mirrors
   `09-RESEARCH.md`'s Known Threat Patterns table: "Man-in-the-middle downgrade of the
   manifest response").
2. **Sanity-bound size validation.** `pack_size_bytes` and every `delta_from.*.size_bytes`
   must be a positive integer below a hard-coded sanity ceiling (client-side constant, well
   above any realistic full-pack size) before being used for the disk-space preflight
   calculation. This guards against a compromised/malicious manifest advertising an
   implausible size to trigger a denial-of-service against device storage (`09-RESEARCH.md`
   Known Threat Patterns: "Denial of service via a manifest that advertises an implausible
   pack size").
3. **Never derive file paths from server-supplied strings.** `current_version` and every key
   of `delta_from` are opaque identifiers only — the client never constructs an on-disk file
   path directly from these strings (mirrors the existing `T-02-03-02` mitigation already
   documented in `first_launch_extractor.dart`: "output path is always derived from
   `getApplicationDocumentsDirectory`, never from user input").
4. **JSON shape validation.** A manifest missing any required field, or with a field of the
   wrong type, is rejected as a malformed manifest (parse failure), not silently coerced.

A manifest that fails any of the above is treated identically to a network failure — the
client surfaces "Update check failed" and leaves the currently-installed pack untouched.

## 3. Compressed vs. Decompressed Sizing

This is the one distinction every consumer of this spec — client, build script, and any
future CDN/build-pipeline owner — must agree on, so nobody silently assumes the wrong number:

- **`pack_size_bytes` and `pack_sha256` both describe the gzip-compressed `full_v<version>.sqlite.gz`
  artifact exactly as `tools/build_reference_pack_release.py` (this plan's Task 2) produces
  it, and exactly as the client's `DownloadManager` (Plan 09-03) downloads and saves it to
  disk.** Neither field ever describes the decompressed `.sqlite`'s final on-disk size.
- **The manifest intentionally does not publish a separate decompressed-size field at this
  phase.** The eventual decompressed size is build-specific (depends on product count, index
  size, page size) and not yet worth a CDN-contract field. Instead, the client derives a
  conservative decompressed-size estimate **client-side**, via a documented compression-ratio
  constant in `ReferencePackRepository` (Plan 09-04), grounded in this project's own measured
  compression ratio for this exact schema/content shape: this repo's bundled
  `assets/off_reference.sqlite` (129,134,592 bytes) compresses to
  `assets/off_reference.sqlite.gz` (40,703,629 bytes) — a ratio of **≈3.17x**
  (`129134592 / 40703629 = 3.1726`). `ReferencePackRepository`'s disk-space preflight estimate
  multiplies the manifest's `pack_size_bytes` by this constant to approximate the decompressed
  footprint, then adds a safety margin per `09-RESEARCH.md` Pitfall 4 (the compressed download
  and the decompressed output must transiently coexist on disk during extraction).
- **Any future CDN/build-pipeline owner reading this spec must never assume `pack_size_bytes`
  represents the installed footprint.** If a decompressed-size field is ever added to this
  contract in a future revision, it must be a distinct, separately-named field (e.g.
  `pack_decompressed_size_bytes`) — never a reinterpretation of the existing `pack_size_bytes`.
- **The delta artifact ships uncompressed, as a plain SQLite file — never gzipped.**
  `delta_from.<old>.size_bytes` and `delta_from.<old>.sha256` describe that plain,
  uncompressed `.sqlite` file directly. `DeltaApplier` (Plan 09-04) `ATTACH`es it directly
  with no decompression step at all, unlike the full pack (which is always downloaded
  compressed and decompressed before/during the atomic swap). This is a deliberate asymmetry:
  full packs are large enough (hundreds of MB) that compression meaningfully reduces transfer
  cost and time; deltas are small enough (tens of MB, typically far less) that the added
  complexity of a compress/decompress step is not worth it for this phase.

## 4. Delta artifact shape

A small, standalone, **uncompressed** SQLite file (see Section 3), downloaded via
`delta_from.<old_version>.url`, `ATTACH`ed temporarily during apply, then discarded after the
apply transaction commits against the real `off_reference.sqlite`.

### `products_delta` table

Every row is an insert-or-replace against the real pack's `products` table. Columns match
`tools/ingest_off.py`'s actual DDL verbatim — **the full 11-column schema**, not the
10-column illustrative subset shown in `09-RESEARCH.md`'s Code Examples section (that example
predates the `primary_category_tag` column added by `ingest_agribalyse()`):

```sql
CREATE TABLE products_delta (
  barcode               TEXT PRIMARY KEY,
  product_name          TEXT NOT NULL,
  product_name_en       TEXT,
  brand                 TEXT,
  calories_100g         REAL,
  protein_100g          REAL,
  carbs_100g            REAL,
  fat_100g              REAL,
  categories_tags       TEXT,
  agribalyse_food_code  TEXT,
  primary_category_tag  TEXT
);
```

### `deleted_barcodes` table

```sql
CREATE TABLE deleted_barcodes (
  barcode TEXT PRIMARY KEY
  -- rows in `products` matching these barcodes must be removed, along with
  -- their corresponding products_fts rowid entries.
);
```

### Required apply order

Any build-side pipeline generating a delta artifact must produce data compatible with this
exact apply sequence (`DeltaApplier`, Plan 09-04):

1. **`ATTACH DATABASE '<delta_path>' AS delta_pack`** — attach the downloaded, verified delta
   file under a temporary alias.
2. **Explicit-column `INSERT OR REPLACE INTO products (...) SELECT ... FROM delta_pack.products_delta`**
   — every column named explicitly (never `SELECT *`), so a future schema drift in either
   table fails loudly instead of silently misaligning columns.
3. **`DELETE FROM products WHERE barcode IN (SELECT barcode FROM delta_pack.deleted_barcodes)`**
   — remove tombstoned rows.
4. **`DETACH DATABASE delta_pack`** — release the temporary attachment; the delta file itself
   can then be deleted from disk.
5. **`products_fts` rebuild** — `INSERT INTO products_fts(products_fts) VALUES('rebuild')`.
   This step is mandatory and non-optional: `products_fts` is declared `content='products'`
   with **no `CREATE TRIGGER`** keeping it in sync (grep-verified against `tools/ingest_off.py`'s
   DDL — `09-RESEARCH.md` Pitfall 1 / Assumptions Log A5). Any pipeline or client code that
   writes to `products` via a delta apply and skips this step leaves FTS text search silently
   stale, even though exact-barcode lookups keep working.

Steps 2–4 run inside a single SQL transaction so a failure partway through never leaves
`products` in a half-applied state.

## 5. CDN requirements (coordination hand-off)

Whoever picks and configures the eventual CDN/static host for `manifest.json` and the pack/delta
artifacts must ensure:

- **HTTPS only.** No plain-HTTP fallback — enforced client-side per Section 2, but the CDN
  should never even serve an HTTP endpoint for these paths.
- **HTTP Range request support.** The full-pack download uses `background_downloader`'s
  `DownloadTask(allowPause: true)`, which relies on Range-based resume to satisfy CONTEXT.md's
  locked "resume from where they left off" decision.
- **A stable strong `ETag` or `Last-Modified` validator, unchanged across pause/resume for the
  same artifact version.** Some CDNs and object-storage services generate weak or
  non-deterministic `ETag`s across edge nodes — if the eventual host doesn't meet this bar,
  resume silently degrades to a full restart on every interruption
  (`09-RESEARCH.md` Pitfall 3 / Assumptions Log A4). This must be explicitly smoke-tested
  against the real chosen CDN/edge configuration before relying on it in production — a local
  dev server passing this test is not sufficient evidence.
- **Content stability.** Once published, an artifact at a given `pack_url` / `delta_from.*.url`
  must never change bytes in place (no silent re-publish under the same URL) — the client's
  cached checksum expectations and any in-progress resumed download assume URL-to-bytes
  stability for the lifetime of that manifest version.

## 6. Open questions for the eventual CDN/build-pipeline owner

1. What CDN/static host will actually serve these artifacts (S3, Cloudflare R2, Bunny, GitHub
   Releases, or backend-team-owned infra), and does it meet Section 5's Range + stable-validator
   requirements out of the box, or does it need explicit configuration?
2. What cadence will new full-pack versions actually be cut on (weekly? monthly? tied to app
   releases?), and who runs `tools/build_reference_pack_release.py` — manually, like the
   existing Phase 2 seed-generation process, or via CI/scheduled infra?
3. Should `manifest.json` ever grow a `pack_decompressed_size_bytes` field, or is the
   client-side compression-ratio estimate (Section 3) sufficient indefinitely?
4. Is a single `delta_from` entry (most-recent-prior-version only) sufficient, or will clients
   realistically fall multiple versions behind and need a multi-hop delta chain / fallback to
   a full-pack re-download when no direct delta path exists?

## Client-side isolation points

- **Manifest fetch + parse:** `ReferencePackApiClient.fetchManifest()` /
  `ReferencePackManifest.fromJson()` (Plan 09-02) — the sole place the JSON shape in Section 1
  is parsed.
- **Validation:** Section 2's checks live alongside the manifest parse/fetch path (Plan 09-02).
- **Download + checksum:** `DownloadManager` (Plan 09-03), `ChecksumVerifier` (Plan 09-02).
- **Decompressed-size estimate:** `ReferencePackRepository`'s compression-ratio constant
  (Plan 09-04).
- **Delta apply:** `DeltaApplier` (Plan 09-04) — the sole place Section 4's apply order is
  implemented.

If any assumption above turns out to be wrong once a CDN/build owner confirms the real
contract, updating the client is scoped to these isolation points — no other file constructs
manifest requests or interprets delta artifacts.

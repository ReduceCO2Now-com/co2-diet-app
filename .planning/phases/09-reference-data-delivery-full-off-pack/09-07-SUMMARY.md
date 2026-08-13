---
phase: 09-reference-data-delivery-full-off-pack
plan: 07
subsystem: infra
tags: [sqlite, data-contracts, off, build-tooling, delta-sync, gzip, sha256]

# Dependency graph
requires: []
provides:
  - "docs/data-contracts/reference-pack-manifest.md — written, [ASSUMED]-flagged manifest.json + delta-artifact contract spec for the eventual CDN/build-pipeline owner"
  - "tools/build_reference_pack_release.py — sibling script to tools/ingest_off.py; produces a versioned full-pack release, manifest.json, and (given --previous) a row-level delta artifact"
  - "Real fixture-generation capability for Plan 09-02 through 09-06's client code and Plan 09-08's real-device verification, closing 09-RESEARCH.md's Open Question 2"
affects: [09-02, 09-03, 09-04, 09-08]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "docs/data-contracts/ directory established as the sibling to docs/backend-contracts/ for build-side/CDN-facing written spec hand-offs"
    - "SQL-only row-level delta diffing via ATTACH + NOT EXISTS + NULL-safe IS comparison, avoiding Python-side row iteration for multi-million-row diffs"

key-files:
  created:
    - docs/data-contracts/reference-pack-manifest.md
    - tools/build_reference_pack_release.py
  modified:
    - tools/README.md

key-decisions:
  - "pack_size_bytes/pack_sha256 describe the gzip-compressed full-pack artifact only, never the decompressed on-disk size — client derives a decompressed estimate via a documented ~3.17x compression-ratio constant (measured from this repo's own assets/off_reference.sqlite vs .sqlite.gz)"
  - "Delta artifact ships uncompressed as a plain SQLite file — no compression/decompression step, unlike the full pack"
  - "products_delta uses the full 11-column products schema (including primary_category_tag), not the 10-column illustrative subset from 09-RESEARCH.md's Code Examples"
  - "Delta diff computed entirely in SQL (ATTACH old/cur + NOT EXISTS + NULL-safe IS equality), not by loading rows into Python — scales to full multi-million-row OFF dumps"
  - "manifest.json's pack_url/delta_from.*.url are https:// placeholder tokens (REPLACE_WITH_CDN_HOST) rather than empty/http strings — already satisfies the client's HTTPS-only validation during local testing"

requirements-completed: []

# Metrics
duration: 8min
completed: 2026-08-13
---

# Phase 9 Plan 07: Reference Pack Manifest Contract + Build-Side Release Tooling Summary

**Written manifest.json/delta-artifact contract spec (docs/data-contracts/) plus a stdlib-only build script (tools/build_reference_pack_release.py) that produces a real versioned off-pack release, manifest, and SQL-diffed delta artifact from the project's existing off_reference.sqlite.**

## Performance

- **Duration:** 8 min
- **Started:** 2026-08-13T19:45:00Z (approx, first commit e73e409 at 19:46:15+08:00)
- **Completed:** 2026-08-13T19:53:19+08:00
- **Tasks:** 2/2 completed
- **Files modified:** 3 (2 created, 1 modified)

## Accomplishments
- Wrote `docs/data-contracts/reference-pack-manifest.md`, a written, `[ASSUMED]`-flagged spec for `manifest.json` and the delta-artifact shape, mirroring `docs/backend-contracts/gdpr-account-deletion.md`'s hand-off precedent for the eventual CDN/build-pipeline owner — includes a dedicated "Compressed vs. Decompressed Sizing" section resolving the one distinction every consumer must agree on
- Built `tools/build_reference_pack_release.py`, a working stdlib-only script that packages an already-built `off_reference.sqlite` into a versioned `full_v<version>.sqlite.gz` + `manifest.json`, and (given `--previous`) diffs it against a prior release entirely in SQL to produce a `products_delta`/`deleted_barcodes` delta artifact
- Verified both the no-`--previous` and `--previous` code paths end-to-end against the project's real bundled `assets/off_reference.sqlite` (352,844 products) — including a real delta run (0 changes, as expected against identical input) producing a valid `manifest.json` with a populated `delta_from` entry
- Updated `tools/README.md` with a new "6. Build a versioned release + delta (Phase 9)" section, including smoke-test invocations and a note on serving the fixture via a local static file server for Plan 09-08's real-device verification

## Task Commits

Each task was committed atomically:

1. **Task 1: Manifest/delta contract spec** - `e73e409` (docs)
2. **Task 2: tools/build_reference_pack_release.py** - `2f2eed9` (feat)

**Plan metadata:** (pending — see final commit step)

## Files Created/Modified
- `docs/data-contracts/reference-pack-manifest.md` - Manifest.json + delta-artifact contract spec: field-by-field `[ASSUMED]` table, worked JSON example, client-side validation rules (HTTPS-only, sanity-bound size, no server-supplied file paths), Compressed vs. Decompressed Sizing section, delta apply order (ATTACH/INSERT/DELETE/DETACH/FTS-rebuild), CDN requirements, and open questions for the eventual owner
- `tools/build_reference_pack_release.py` - Stdlib-only sibling to `tools/ingest_off.py`; `build_release()` compresses+hashes the full pack, computes `product_count`, writes `manifest.json`; `build_delta()` SQL-diffs a decompressed prior release against the current input DB into a plain-SQLite delta artifact
- `tools/README.md` - New "6. Build a versioned release + delta (Phase 9)" section with usage + smoke-test commands

## Decisions Made
- **pack_size_bytes/pack_sha256 = compressed artifact only** — the client never receives or needs a decompressed-size field from the manifest; `ReferencePackRepository` (Plan 09-04) is documented to derive that estimate itself via the ~3.17x compression ratio measured from this repo's own `assets/off_reference.sqlite` (129,134,592 bytes) vs `assets/off_reference.sqlite.gz` (40,703,629 bytes)
- **Delta artifact ships uncompressed** — small enough (tens of MB or less) that compression isn't worth the added complexity; `DeltaApplier` ATTACHes it directly with no decompression step
- **11-column products_delta schema** (not 09-RESEARCH.md's 10-column illustrative example) — matches `tools/ingest_off.py`'s actual DDL including the `primary_category_tag` column added by `ingest_agribalyse()`
- **SQL-only delta diffing** — `build_delta()` runs the entire row-level diff as two `INSERT ... SELECT ... WHERE NOT EXISTS` statements against `ATTACH`ed databases, using NULL-safe `IS` comparison per column, rather than iterating rows in Python — necessary for this to scale to a real multi-million-row full OFF dump, not just the bundled starter-seed sample
- **Defensive column-presence handling** — `_select_clause`/`_existing_columns` check `PRAGMA table_info` on both the current and previous databases before building the diff SQL, substituting `NULL` for any of the 11 documented columns missing from an older schema (e.g. a hypothetical prior release built before `primary_category_tag` existed) — avoids a hard crash on schema drift between release generations

## Deviations from Plan

None - plan executed exactly as written. Both tasks' automated verification commands (from PLAN.md) were run and passed as specified; the delta code path (not explicitly required by the plan's `--previous`-less verification command, but required by the plan's `<action>` block) was additionally smoke-tested end-to-end to confirm correctness before committing.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required. This plan's script is run manually today (same pattern as the existing Phase 2 seed-generation process); no CDN exists yet to configure, per `09-CONTEXT.md`'s explicit out-of-scope boundary.

## Next Phase Readiness

- `docs/data-contracts/reference-pack-manifest.md` is ready for Plan 09-02 (`ReferencePackManifest.fromJson`), Plan 09-03 (`DownloadManager`), and Plan 09-04 (`DeltaApplier`/`ReferencePackRepository`) to build their client-side parsing/validation/apply logic directly against.
- `tools/build_reference_pack_release.py` is ready to produce real manifest+pack+delta fixtures (via a local static file server) for Plan 09-08's real-device verification and any manual testing of the Flutter client's download/delta-apply flow — closing 09-RESEARCH.md's Open Question 2 ("the client can't be meaningfully tested end-to-end without at least one real manifest + pack + delta artifact to point at").
- No blockers. This plan has zero dependency on and zero file overlap with the Flutter client work in Plans 09-01 through 09-06, confirmed during execution (only `docs/` and `tools/` files touched).

---
*Phase: 09-reference-data-delivery-full-off-pack*
*Completed: 2026-08-13*

## Self-Check: PASSED

- FOUND: docs/data-contracts/reference-pack-manifest.md
- FOUND: tools/build_reference_pack_release.py
- FOUND: tools/README.md
- FOUND: .planning/phases/09-reference-data-delivery-full-off-pack/09-07-SUMMARY.md
- FOUND commit: e73e409 (Task 1)
- FOUND commit: 2f2eed9 (Task 2)

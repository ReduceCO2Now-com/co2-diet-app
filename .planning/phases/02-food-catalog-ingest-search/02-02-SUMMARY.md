---
phase: 02-food-catalog-ingest-search
plan: "02"
subsystem: database
tags: [python, sqlite, fts5, off, open-food-facts, ingest, pipeline]

requires:
  - phase: 02-01
    provides: Wave 0 test scaffolds and FTS5 build config establishing the FTS5 schema design

provides:
  - "tools/ingest_off.py: OFF JSONL -> off_reference.sqlite streaming ingest pipeline"
  - "products table with 9-column schema (barcode, product_name, product_name_en, brand, macros, categories_tags)"
  - "products_fts FTS5 virtual table (unicode61, remove_diacritics 2, prefix='2 3 4')"
  - "tools/README.md: developer guide for download, ingest, compress, size-check"

affects:
  - 02-03 (bundles off_reference.sqlite as compressed Flutter asset)
  - 02-04 (FoodCatalogDao queries products_fts schema defined here)
  - 02-05 (search screen queries FTS5 table defined here)
  - all plans using off_reference.sqlite

tech-stack:
  added: []
  patterns:
    - "Streaming JSONL ingest: gzip.open line-by-line + executemany batches of 10,000 rows"
    - "FTS5 bulk populate: INSERT INTO products_fts SELECT after all rows flushed (not per-row)"
    - "VACUUM requires explicit commit before call (cannot run inside transaction)"
    - "Empty-string coercion to None: p.get('product_name_en') or None (Q1 resolution)"
    - "Existing-DB guard: exit code 1 if output DB exists (prevents silent overwrite, T-02-02-01)"

key-files:
  created:
    - tools/ingest_off.py
    - tools/README.md
  modified: []

key-decisions:
  - "VACUUM must be called after commit, not before — sqlite3.OperationalError: cannot VACUUM from within a transaction"
  - "product_name_en extracted as p.get('product_name_en') or None (Q1 resolution: coerce empty strings to NULL)"
  - "EU_COUNTRY_TAGS includes 28 entries: all EU member states + Switzerland (DE/AT/CH market)"
  - "PROGRESS_INTERVAL=50,000 rows per stderr report as specified"
  - "FTS5 tokenize='unicode61 remove_diacritics 2' + prefix='2 3 4' per locked schema decision"

patterns-established:
  - "Python ingest tool: stdlib only, Python 3.8+, no pip installs"
  - "OFF filter chain: EU country AND completeness >= 0.6 AND non-empty product_name"
  - "tools/README.md format: concise (<80 lines), 5 required sections + assumption note"

requirements-completed:
  - LOG-01
  - NFR-06

duration: 3min
completed: "2026-07-20"
---

# Phase 02 Plan 02: OFF JSONL Ingest Pipeline Summary

**Streaming Python pipeline ingesting EU-filtered OFF JSONL into off_reference.sqlite with FTS5 prefix index (unicode61, prefix='2 3 4'), stdio-only dependencies, and existing-DB tamper guard.**

## Performance

- **Duration:** 3 min
- **Started:** 2026-07-20T16:06:36Z
- **Completed:** 2026-07-20T16:09:38Z
- **Tasks:** 2
- **Files created:** 2

## Accomplishments

- Created `tools/ingest_off.py`: streaming JSONL ingest with EU filter, 10k-row batches, bulk FTS5 populate, and tamper guard (exit code 1 on existing DB)
- Smoke-tested against 5 synthetic records: 3 inserted (2 filtered), all 9 schema columns present, FTS5 prefix query (`banana*`) returns correct results
- Created `tools/README.md` (70 lines) covering download, inspect, run, compress, size-check, and assumption A1 note

## Task Commits

1. **Task 1: Python ingest pipeline (tools/ingest_off.py)** - `0725ac5` (feat)
2. **Task 2: Smoke-test + tools/README.md** - `473fadf` (feat — includes Rule 1 VACUUM fix)

## Files Created/Modified

- `tools/ingest_off.py` - Streaming OFF JSONL -> SQLite ingest pipeline with FTS5 index
- `tools/README.md` - Developer guide: download, inspect, ingest, compress, size-check

## Decisions Made

- `VACUUM` requires an explicit `conn.commit()` before the call — SQLite cannot VACUUM inside an open transaction. Commit the FTS5 bulk insert, then VACUUM.
- `product_name_en` coerced with `p.get('product_name_en') or None` so empty strings (`''`) stored as NULL (Q1 resolution, confirmed 2026-07-20 from JSONL inspection).
- EU_COUNTRY_TAGS includes Switzerland (not EU) alongside all 27 EU member states — matches the DE/AT/CH German-speaking market focus.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed VACUUM inside transaction error**
- **Found during:** Task 2 smoke test
- **Issue:** `conn.execute("VACUUM")` raised `sqlite3.OperationalError: cannot VACUUM from within a transaction` because the FTS5 bulk INSERT had opened an implicit transaction that was not committed before VACUUM.
- **Fix:** Added `conn.commit()` immediately after the `INSERT INTO products_fts SELECT` statement, before the VACUUM call. Also removed the trailing `conn.commit()` that came after VACUUM (VACUUM does its own implicit commit).
- **Files modified:** `tools/ingest_off.py`
- **Verification:** Smoke test passed — 3 rows inserted, FTS5 queryable, no error.
- **Committed in:** `473fadf` (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 - Bug)
**Impact on plan:** Fix required for correctness — VACUUM is a mandatory step per the plan spec. No scope creep.

## Issues Encountered

- None beyond the VACUUM bug (auto-fixed above).

## User Setup Required

None — tools/ingest_off.py is a developer build tool. The OFF JSONL dump must be downloaded separately before running the ingest (see tools/README.md Section 1).

## Known Stubs

None — the ingest script is complete. `off_reference.sqlite` itself cannot be committed because the OFF JSONL dump has not been downloaded on this machine (that is the expected developer workflow, documented in tools/README.md).

## Threat Flags

None — no new network endpoints, auth paths, or trust boundaries introduced. The existing-DB guard (T-02-02-01) and streaming architecture (T-02-02-02) are implemented as specified.

## Next Phase Readiness

- `tools/ingest_off.py` is ready for execution against the real OFF JSONL dump (Plan 02-03 dependency)
- The FTS5 schema (`products` + `products_fts`) is locked — Dart DAOs in Plans 02-04/02-05 can be written against this schema with confidence
- Plan 02-03 can bundle the generated `off_reference.sqlite` as a compressed Flutter asset

---
*Phase: 02-food-catalog-ingest-search*
*Completed: 2026-07-20*

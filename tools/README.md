# OFF Seed Database Pipeline

Generates `off_reference.sqlite` from the Open Food Facts JSONL dump.
Python 3.8+ stdlib only — no pip installs required.

## 1. Download the JSONL dump

Download `en.openfoodfacts.org.products.jsonl.gz` from
<https://world.openfoodfacts.org/data> (~5 GB compressed). Do NOT commit
to the repo — it is gitignored.

## 2. Inspect a sample

Verify `product_name_en` is a top-level key before full ingest:

```bash
zcat en.openfoodfacts.org.products.jsonl.gz | head -5 | python3 -m json.tool | head -60
```

## 3. Run the ingest

```bash
python3 tools/ingest_off.py \
    path/to/en.openfoodfacts.org.products.jsonl.gz \
    assets/off_reference.sqlite
```

Streams JSONL line-by-line. Filters to EU/CH products with completeness >= 0.6
and non-empty product_name. Takes 15–30 min. Progress printed to stderr every
50,000 rows.

Smoke-test on a subset without the full dump:

```bash
python3 tools/ingest_off.py path/to/dump.jsonl.gz /tmp/test.sqlite --sample 100000
```

If the output DB already exists the script exits code 1 — delete it first:

```bash
rm assets/off_reference.sqlite
```

## 4. Compress

```bash
gzip -k assets/off_reference.sqlite
ls -lh assets/off_reference.sqlite.gz   # target: <= 50 MB
```

## 5. Size check

If > 50 MB: raise `COMPLETENESS_THRESHOLD` in the script, narrow the country
set in `EU_COUNTRY_TAGS`, or strip columns — then re-run.

## Note on product_name_en

Assumption A1 (confirmed 2026-07-20, n=5,000 records): `product_name_en` is
a flat top-level key in the JSONL export. Empty strings are coerced to NULL by
the script (`p.get('product_name_en') or None`).

After ingest, verify coverage:

```bash
sqlite3 assets/off_reference.sqlite \
    "SELECT count(*) FROM products WHERE product_name_en IS NOT NULL;"
```

If this returns 0, update the extraction line to
`(p.get('product_name_languages') or {}).get('en') or None` and re-run.

## 6. Build a versioned release + delta (Phase 9)

`tools/build_reference_pack_release.py` is a sibling script to `tools/ingest_off.py`.
It takes an already-built `off_reference.sqlite` (this script's own output, run against
the full unfiltered OFF dump) and packages it into a versioned release CDN can serve —
a `full_v<version>.sqlite.gz` artifact, a `manifest.json` describing it, and (given a
prior release) a delta artifact against that prior version. Python 3.8+ stdlib only —
no pip installs required, matching this project's existing convention.

The exact `manifest.json` / delta-artifact shapes are specified in
`docs/data-contracts/reference-pack-manifest.md` — read that first if you're wiring up
a CDN or modifying the Flutter client's parsing code.

**Smoke-test against the project's own small starter-seed `off_reference.sqlite`** (no
`--previous`, to produce a first fixture quickly):

```bash
python3 tools/build_reference_pack_release.py \
    assets/off_reference.sqlite /tmp/reference-pack-release-v1 \
    --version smoketest-v1
```

This writes `/tmp/reference-pack-release-v1/full_vsmoketest-v1.sqlite.gz` and
`manifest.json`. Point Plan 09-08's real-device verification (or any manual testing of
`DownloadManager`/`ReferencePackApiClient`) at these files via a local static file
server, e.g.:

```bash
cd /tmp/reference-pack-release-v1 && python3 -m http.server 8000
```

**Build a second release + delta against the first**, to exercise the delta-generation
path:

```bash
python3 tools/build_reference_pack_release.py \
    assets/off_reference.sqlite /tmp/reference-pack-release-v2 \
    --version smoketest-v2 --previous /tmp/reference-pack-release-v1
```

This additionally writes `delta_vsmoketest-v1_to_vsmoketest-v2.sqlite` (uncompressed —
see the data contract doc's Compressed vs. Decompressed Sizing section) and populates
`manifest.json`'s `delta_from.smoketest-v1` entry.

**Full usage / all flags:**

```bash
python3 tools/build_reference_pack_release.py --help
```

**Note:** `pack_url`/`delta_from.*.url` in the generated `manifest.json` are `https://`
placeholder tokens (`REPLACE_WITH_CDN_HOST`) — the eventual CDN owner fills in the real
host once hosting exists (see `docs/data-contracts/reference-pack-manifest.md` Section 6,
"Open questions for the eventual CDN/build-pipeline owner").

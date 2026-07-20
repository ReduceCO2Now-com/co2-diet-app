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

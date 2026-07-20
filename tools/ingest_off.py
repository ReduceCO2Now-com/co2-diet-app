#!/usr/bin/env python3
"""
OFF JSONL → off_reference.sqlite ingest pipeline.

Usage:
    python3 tools/ingest_off.py <jsonl_gz> <output_db> [--sample N]

Reads the Open Food Facts JSONL dump (gzip-compressed), filters to EU products
with completeness >= 0.6, and writes a SQLite database with a products table
and a products_fts FTS5 virtual table.

Requirements: Python 3.8+, stdlib only (no pip installs required).
"""

import argparse
import gzip
import json
import os
import sqlite3
import sys

# EU country tags from the OFF taxonomy.
# Switzerland (en:switzerland) is included alongside EU members for the
# German-speaking market that is central to this app.
EU_COUNTRY_TAGS = {
    "en:austria",
    "en:belgium",
    "en:bulgaria",
    "en:croatia",
    "en:cyprus",
    "en:czechia",
    "en:denmark",
    "en:estonia",
    "en:finland",
    "en:france",
    "en:germany",
    "en:greece",
    "en:hungary",
    "en:ireland",
    "en:italy",
    "en:latvia",
    "en:lithuania",
    "en:luxembourg",
    "en:malta",
    "en:netherlands",
    "en:poland",
    "en:portugal",
    "en:romania",
    "en:slovakia",
    "en:slovenia",
    "en:spain",
    "en:sweden",
    "en:switzerland",  # Not EU, but included for DE/AT/CH market
}

COMPLETENESS_THRESHOLD = 0.6
BATCH_SIZE = 10_000
PROGRESS_INTERVAL = 50_000

DDL = """
CREATE TABLE IF NOT EXISTS products (
    barcode         TEXT PRIMARY KEY,
    product_name    TEXT NOT NULL,
    product_name_en TEXT,
    brand           TEXT,
    calories_100g   REAL,
    protein_100g    REAL,
    carbs_100g      REAL,
    fat_100g        REAL,
    categories_tags TEXT
);

CREATE VIRTUAL TABLE IF NOT EXISTS products_fts USING fts5(
    product_name,
    product_name_en,
    brand,
    content='products',
    content_rowid='rowid',
    tokenize='unicode61 remove_diacritics 2',
    prefix='2 3 4'
);
"""

INSERT_SQL = """
INSERT OR IGNORE INTO products
    (barcode, product_name, product_name_en, brand,
     calories_100g, protein_100g, carbs_100g, fat_100g, categories_tags)
VALUES (?,?,?,?,?,?,?,?,?)
"""


def _flush(conn: sqlite3.Connection, batch: list) -> int:
    """Insert a batch of rows and commit. Returns number of rows inserted."""
    conn.executemany(INSERT_SQL, batch)
    conn.commit()
    return len(batch)


def ingest(jsonl_gz_path: str, out_db_path: str, sample: int = 0) -> None:
    """
    Stream the OFF JSONL dump and write filtered products to SQLite.

    Args:
        jsonl_gz_path: Path to the gzip-compressed JSONL file.
        out_db_path:   Path for the output SQLite database.
        sample:        If > 0, stop after processing this many records.
    """
    conn = sqlite3.connect(out_db_path)
    # Create the products table and FTS5 virtual table.
    conn.executescript(DDL)
    conn.commit()

    batch: list = []
    n_processed = 0
    n_inserted = 0

    with gzip.open(jsonl_gz_path, "rt", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            # Parse JSON; skip malformed lines with a warning.
            try:
                p = json.loads(line)
            except json.JSONDecodeError as exc:
                print(f"[ingest] WARNING: skipping malformed JSON line: {exc}", file=sys.stderr)
                continue

            n_processed += 1

            # ── Filter 1: EU country ──────────────────────────────────────────
            countries = set(p.get("countries_tags") or [])
            if not countries.intersection(EU_COUNTRY_TAGS):
                if sample and n_processed >= sample:
                    break
                continue

            # ── Filter 2: completeness ────────────────────────────────────────
            completeness = p.get("completeness") or 0.0
            try:
                completeness = float(completeness)
            except (TypeError, ValueError):
                completeness = 0.0
            if completeness < COMPLETENESS_THRESHOLD:
                if sample and n_processed >= sample:
                    break
                continue

            # ── Filter 3: non-empty product_name ─────────────────────────────
            product_name = (p.get("product_name") or "").strip()
            if not product_name:
                if sample and n_processed >= sample:
                    break
                continue

            # ── Extract fields ────────────────────────────────────────────────
            # Q1 resolution: coerce empty strings to None so the DB stores NULL
            # rather than an empty string that would pass count checks falsely.
            product_name_en = p.get("product_name_en") or None

            nutriments = p.get("nutriments") or {}
            row = (
                p.get("code"),
                product_name,
                product_name_en,
                p.get("brands") or None,
                nutriments.get("energy-kcal_100g"),
                nutriments.get("proteins_100g"),
                nutriments.get("carbohydrates_100g"),
                nutriments.get("fat_100g"),
                ",".join(p.get("categories_tags") or []),
            )
            batch.append(row)

            if len(batch) >= BATCH_SIZE:
                n_inserted += _flush(conn, batch)
                batch.clear()

            # Progress report every PROGRESS_INTERVAL rows processed.
            if n_processed % PROGRESS_INTERVAL == 0:
                print(
                    f"[ingest] {n_processed:,} rows processed, {n_inserted:,} inserted",
                    file=sys.stderr,
                )

            # Sample limit: stop after N records have been *processed* (not inserted).
            if sample and n_processed >= sample:
                break

    # Flush remaining rows.
    if batch:
        n_inserted += _flush(conn, batch)

    print(
        f"[ingest] Final: {n_processed:,} rows processed, {n_inserted:,} inserted",
        file=sys.stderr,
    )

    # ── Populate FTS index in a single bulk pass ──────────────────────────────
    # This is faster than per-row inserts because SQLite can sort and batch
    # all the token entries at once.
    print("[ingest] Building FTS5 index...", file=sys.stderr)
    conn.execute(
        "INSERT INTO products_fts(rowid, product_name, product_name_en, brand) "
        "SELECT rowid, product_name, product_name_en, brand FROM products"
    )
    # page_size pragma must be set before VACUUM to take effect.
    conn.execute("PRAGMA page_size = 4096")
    conn.execute("VACUUM")
    conn.commit()
    conn.close()

    print("[ingest] Done.", file=sys.stderr)


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="ingest_off.py",
        description=(
            "Ingest the Open Food Facts JSONL dump into off_reference.sqlite.\n"
            "\n"
            "The output database contains:\n"
            "  products      — filtered product rows (9 columns)\n"
            "  products_fts  — FTS5 virtual table for prefix search\n"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "jsonl_gz",
        metavar="jsonl_gz",
        help=(
            "Path to the gzip-compressed JSONL dump "
            "(e.g. en.openfoodfacts.org.products.jsonl.gz)."
        ),
    )
    parser.add_argument(
        "output_db",
        metavar="output_db",
        help="Path for the output SQLite database (e.g. assets/off_reference.sqlite).",
    )
    parser.add_argument(
        "--sample",
        metavar="N",
        type=int,
        default=0,
        help=(
            "Stop after processing N records from the JSONL dump. "
            "Useful for smoke-testing without the full 5 GB dump."
        ),
    )
    args = parser.parse_args()

    # Guard: refuse to overwrite an existing database.
    # The developer must explicitly delete it before re-running.
    if os.path.exists(args.output_db):
        print(
            f"[ingest] ERROR: output database already exists: {args.output_db}\n"
            "[ingest] Delete it manually before re-running to avoid silent overwrites.",
            file=sys.stderr,
        )
        sys.exit(1)

    ingest(args.jsonl_gz, args.output_db, sample=args.sample)


if __name__ == "__main__":
    main()

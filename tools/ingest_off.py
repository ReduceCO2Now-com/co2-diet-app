#!/usr/bin/env python3
"""
OFF JSONL → off_reference.sqlite ingest pipeline.

Usage:
    python3 tools/ingest_off.py <jsonl_gz> <output_db> [--sample N]

Reads the Open Food Facts JSONL dump (gzip-compressed), filters to EU products
with completeness >= 0.7, and writes a SQLite database with a products table
and a products_fts FTS5 virtual table.

Extended in Phase 3 (Plan 03-02): the `ingest_agribalyse()` function
downloads AGRIBALYSE v3.1.1 synthesis CSV and populates two new tables in
off_reference.sqlite — `co2_factors` and `food_co2_overrides`.

Requirements: Python 3.8+, stdlib only (no pip installs required).
"""

import argparse
import csv
import gzip
import json
import os
import sqlite3
import statistics
import sys
import urllib.request

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

COMPLETENESS_THRESHOLD = 0.7
BATCH_SIZE = 10_000
PROGRESS_INTERVAL = 50_000

DDL = """
CREATE TABLE IF NOT EXISTS products (
    barcode               TEXT PRIMARY KEY,
    product_name          TEXT NOT NULL,
    product_name_en       TEXT,
    brand                 TEXT,
    calories_100g         REAL,
    protein_100g          REAL,
    carbs_100g            REAL,
    fat_100g              REAL,
    categories_tags       TEXT,
    agribalyse_food_code  TEXT
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
     calories_100g, protein_100g, carbs_100g, fat_100g, categories_tags,
     agribalyse_food_code)
VALUES (?,?,?,?,?,?,?,?,?,?)
"""

# ---------------------------------------------------------------------------
# AGRIBALYSE v3.1.1 ingest constants
# ---------------------------------------------------------------------------

# Pinned to v3.1.1 — use this URL, not the rolling 'agribalyse-synthese'
# dataset which now serves v3.2 (updated January 2026).
AGRIBALYSE_URL = (
    "https://data.ademe.fr/data-fair/api/v1/datasets/agribalyse-31-synthese/raw"
)

CO2_FACTORS_DDL = """
CREATE TABLE IF NOT EXISTS co2_factors (
    categories_tag           TEXT PRIMARY KEY,
    agribalyse_group         TEXT NOT NULL,
    co2e_median              REAL NOT NULL,
    co2_methodology_version  TEXT NOT NULL DEFAULT 'AGRIBALYSE-3.1.1-v1',
    unit                     TEXT NOT NULL DEFAULT 'kg_co2e_per_kg'
);
"""

FOOD_CO2_OVERRIDES_DDL = """
CREATE TABLE IF NOT EXISTS food_co2_overrides (
    barcode                  TEXT PRIMARY KEY,
    ciqual_code              TEXT NOT NULL,
    co2e_100g                REAL NOT NULL,
    confidence               TEXT NOT NULL DEFAULT 'high',
    co2_methodology_version  TEXT NOT NULL DEFAULT 'AGRIBALYSE-3.1.1-v1',
    unit                     TEXT NOT NULL DEFAULT 'kg_co2e_per_kg'
);
"""


def _flush(conn: sqlite3.Connection, batch: list) -> int:
    """Insert a batch of rows and commit. Returns number of rows inserted."""
    conn.executemany(INSERT_SQL, batch)
    conn.commit()
    return len(batch)


def _parse_co2_value(raw: str) -> float | None:
    """Parse a CO₂ value string from the AGRIBALYSE CSV.

    Handles French locale decimal format (comma separator: '2,24' → 2.24).
    Returns None when the value is empty, non-numeric, or clearly invalid.
    """
    if not raw or not raw.strip():
        return None
    normalized = raw.strip().replace(",", ".")
    try:
        val = float(normalized)
    except ValueError:
        return None
    if val != val:  # NaN check
        return None
    if val < 0:
        return None
    return val


def ingest_agribalyse(conn: sqlite3.Connection, off_to_agribalyse_path: str) -> None:
    """Extend off_reference.sqlite with AGRIBALYSE v3.1.1 CO₂ data.

    Downloads (or reads from cache) the AGRIBALYSE v3.1.1 synthesis CSV,
    populates `co2_factors` and `food_co2_overrides` tables, adds a
    `primary_category_tag` column to `products`, and sets it for each row.

    Args:
        conn: Open sqlite3 connection to off_reference.sqlite.
        off_to_agribalyse_path: Path to the hand-curated mapping CSV.
    """
    # ── 1. Locate / download AGRIBALYSE synthesis CSV ────────────────────────
    cache_path = os.path.join(
        os.path.dirname(off_to_agribalyse_path), "data", "agribalyse_synthese.csv"
    )
    if os.path.exists(cache_path):
        agribalyse_csv_path = cache_path
        print(f"[agribalyse] Using cached CSV: {cache_path}", file=sys.stderr)
    else:
        os.makedirs(os.path.dirname(cache_path), exist_ok=True)
        print(
            f"[agribalyse] Downloading AGRIBALYSE v3.1.1 from:\n  {AGRIBALYSE_URL}",
            file=sys.stderr,
        )
        urllib.request.urlretrieve(AGRIBALYSE_URL, cache_path)
        agribalyse_csv_path = cache_path
        print(
            f"[agribalyse] Downloaded to: {cache_path}",
            file=sys.stderr,
        )

    # ── 2. Parse AGRIBALYSE CSV ───────────────────────────────────────────────
    # Group CO₂ values by "Groupe d'aliment" for median computation.
    # Column names are French; see RESEARCH.md for header-name verification.
    group_co2_values: dict[str, list[float]] = {}
    ciqual_co2: dict[str, float] = {}  # ciqual_code → co2e_kg_per_kg

    with open(agribalyse_csv_path, encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            group = (row.get("Groupe d'aliment") or "").strip()
            co2_raw = row.get("Changement climatique", "")
            ciqual_code = str(row.get("Code CIQUAL") or "").strip()

            co2_val = _parse_co2_value(co2_raw)
            if co2_val is None or not group:
                continue

            # Accumulate per-group values for median computation.
            group_co2_values.setdefault(group, []).append(co2_val)

            # Store per-CIQUAL-code value for food_co2_overrides.
            if ciqual_code:
                ciqual_co2[ciqual_code] = co2_val

    print(
        f"[agribalyse] Parsed {sum(len(v) for v in group_co2_values.values())} "
        f"CO₂ rows across {len(group_co2_values)} groups; "
        f"{len(ciqual_co2)} CIQUAL codes",
        file=sys.stderr,
    )

    # ── 3. Load the OFF-to-AGRIBALYSE mapping ────────────────────────────────
    # mapping: off_category_tag → agribalyse_group
    off_to_group: dict[str, str] = {}
    with open(off_to_agribalyse_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            tag = row["off_category_tag"].strip()
            group = row["agribalyse_group"].strip()
            off_to_group[tag] = group

    print(
        f"[agribalyse] Loaded {len(off_to_group)} OFF-to-AGRIBALYSE mappings",
        file=sys.stderr,
    )

    # ── 4. Create and populate co2_factors ───────────────────────────────────
    conn.executescript(CO2_FACTORS_DDL)
    conn.commit()

    co2_factors_rows = []
    for off_tag, agribalyse_group in off_to_group.items():
        co2_values = group_co2_values.get(agribalyse_group, [])
        if not co2_values:
            continue  # No AGRIBALYSE data for this group — skip
        median_co2 = statistics.median(co2_values)
        co2_factors_rows.append(
            (off_tag, agribalyse_group, round(median_co2, 4), "AGRIBALYSE-3.1.1-v1", "kg_co2e_per_kg")
        )

    conn.executemany(
        """
        INSERT OR REPLACE INTO co2_factors
            (categories_tag, agribalyse_group, co2e_median, co2_methodology_version, unit)
        VALUES (?, ?, ?, ?, ?)
        """,
        co2_factors_rows,
    )
    conn.commit()
    print(
        f"[agribalyse] Inserted {len(co2_factors_rows)} rows into co2_factors",
        file=sys.stderr,
    )

    # ── 5. Ensure products has agribalyse_food_code column ───────────────────
    # Confirm with PRAGMA table_info; add if absent.
    columns = {
        row[1]
        for row in conn.execute("PRAGMA table_info(products)").fetchall()
    }
    if "agribalyse_food_code" not in columns:
        print(
            "[agribalyse] Adding agribalyse_food_code column to products",
            file=sys.stderr,
        )
        conn.execute(
            "ALTER TABLE products ADD COLUMN agribalyse_food_code TEXT"
        )
        conn.commit()

    # ── 6. Create and populate food_co2_overrides ────────────────────────────
    # Join products.agribalyse_food_code → CIQUAL code → AGRIBALYSE CO₂ value.
    conn.executescript(FOOD_CO2_OVERRIDES_DDL)
    conn.commit()

    # Fetch barcodes with an agribalyse_food_code from products.
    product_rows = conn.execute(
        "SELECT barcode, agribalyse_food_code FROM products "
        "WHERE agribalyse_food_code IS NOT NULL AND agribalyse_food_code != ''"
    ).fetchall()

    overrides_rows = []
    for barcode, ciqual_code in product_rows:
        co2_val = ciqual_co2.get(str(ciqual_code))
        if co2_val is None:
            continue
        overrides_rows.append(
            (barcode, str(ciqual_code), round(co2_val, 4), "high", "AGRIBALYSE-3.1.1-v1", "kg_co2e_per_kg")
        )

    if overrides_rows:
        conn.executemany(
            """
            INSERT OR REPLACE INTO food_co2_overrides
                (barcode, ciqual_code, co2e_100g, confidence, co2_methodology_version, unit)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            overrides_rows,
        )
        conn.commit()

    print(
        f"[agribalyse] Inserted {len(overrides_rows)} rows into food_co2_overrides",
        file=sys.stderr,
    )

    # ── 7. Add primary_category_tag column to products ───────────────────────
    if "primary_category_tag" not in columns:
        print(
            "[agribalyse] Adding primary_category_tag column to products",
            file=sys.stderr,
        )
        conn.execute(
            "ALTER TABLE products ADD COLUMN primary_category_tag TEXT"
        )
        conn.commit()

    # Build set of known categories_tags from co2_factors for fast lookup.
    known_tags = {
        row[0]
        for row in conn.execute("SELECT categories_tag FROM co2_factors").fetchall()
    }

    # Update primary_category_tag: for each product, scan its categories_tags
    # (comma-separated) and pick the first tag that exists in co2_factors.
    # Use a single-pass Python update for correctness — avoids the json_each
    # pitfall (RESEARCH.md Pitfall 5).
    print(
        "[agribalyse] Updating primary_category_tag on products …",
        file=sys.stderr,
    )

    batch_updates: list[tuple[str, str]] = []
    rows_updated = 0

    # Fetch only products where primary_category_tag is not yet set and
    # categories_tags is non-empty.
    for barcode, categories_tags_str in conn.execute(
        "SELECT barcode, categories_tags FROM products "
        "WHERE primary_category_tag IS NULL "
        "  AND categories_tags IS NOT NULL AND categories_tags != ''"
    ).fetchall():
        tags = [t.strip() for t in categories_tags_str.split(",") if t.strip()]
        for tag in tags:
            if tag in known_tags:
                batch_updates.append((tag, barcode))
                break

        if len(batch_updates) >= BATCH_SIZE:
            conn.executemany(
                "UPDATE products SET primary_category_tag = ? WHERE barcode = ?",
                batch_updates,
            )
            rows_updated += len(batch_updates)
            batch_updates.clear()

    if batch_updates:
        conn.executemany(
            "UPDATE products SET primary_category_tag = ? WHERE barcode = ?",
            batch_updates,
        )
        rows_updated += len(batch_updates)

    conn.commit()
    print(
        f"[agribalyse] Set primary_category_tag on {rows_updated} products",
        file=sys.stderr,
    )


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

            # Extract AGRIBALYSE CIQUAL food code from ecoscore data.
            # Path: ecoscore_data.agribalyse.agribalyse_food_code
            ecoscore = p.get("ecoscore_data") or {}
            agribalyse_meta = ecoscore.get("agribalyse") or {}
            raw_code = agribalyse_meta.get("agribalyse_food_code")
            agribalyse_food_code = str(raw_code) if raw_code else None

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
                agribalyse_food_code,
            )
            if n_inserted + len(batch) < 20:
                print(f"[diag] completeness raw={p.get('completeness')!r}", file=sys.stderr)

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
    conn.commit()

    # ── AGRIBALYSE CO₂ factor ingest ─────────────────────────────────────────
    # Must run after products table is populated (products table must exist).
    agribalyse_map_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "off_to_agribalyse_map.csv"
    )
    if os.path.exists(agribalyse_map_path):
        print("[ingest] Running AGRIBALYSE CO₂ ingest...", file=sys.stderr)
        ingest_agribalyse(conn, agribalyse_map_path)
    else:
        print(
            f"[ingest] WARNING: off_to_agribalyse_map.csv not found at {agribalyse_map_path}; "
            "skipping AGRIBALYSE CO₂ ingest.",
            file=sys.stderr,
        )

    # page_size pragma must be set before VACUUM to take effect.
    # VACUUM requires explicit commit before call — cannot VACUUM inside
    # open SQLite transaction (sqlite3.OperationalError).
    conn.commit()
    conn.execute("PRAGMA page_size = 4096")
    conn.execute("VACUUM")
    conn.close()

    print("[ingest] Done.", file=sys.stderr)


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="ingest_off.py",
        description=(
            "Ingest the Open Food Facts JSONL dump into off_reference.sqlite.\n"
            "\n"
            "The output database contains:\n"
            "  products          — filtered product rows (9+ columns)\n"
            "  products_fts      — FTS5 virtual table for prefix search\n"
            "  co2_factors       — AGRIBALYSE v3.1.1 category CO₂e medians\n"
            "  food_co2_overrides — per-product AGRIBALYSE direct matches\n"
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


# ---------------------------------------------------------------------------
# Backfill agribalyse_food_code from JSONL into existing off_reference.sqlite
# ---------------------------------------------------------------------------

def backfill_agribalyse_food_code(
    db_path: str, jsonl_gz_path: str, batch_size: int = 10_000
) -> None:
    """Backfill `products.agribalyse_food_code` from the OFF JSONL dump.

    Used when `off_reference.sqlite` was ingested before `agribalyse_food_code`
    extraction was added to the pipeline. Streams the JSONL dump, extracts
    `ecoscore_data.agribalyse.agribalyse_food_code`, and UPDATE-s matching
    barcode rows.

    Args:
        db_path:      Path to the existing off_reference.sqlite.
        jsonl_gz_path: Path to the gzip-compressed JSONL dump.
        batch_size:   Number of UPDATE rows to batch before committing.
    """
    conn = sqlite3.connect(db_path)

    # Ensure agribalyse_food_code column exists.
    cols = {row[1] for row in conn.execute("PRAGMA table_info(products)").fetchall()}
    if "agribalyse_food_code" not in cols:
        conn.execute("ALTER TABLE products ADD COLUMN agribalyse_food_code TEXT")
        conn.commit()

    print(
        f"[backfill] Scanning {jsonl_gz_path} for agribalyse_food_code …",
        file=sys.stderr,
    )
    batch: list[tuple[str, str]] = []  # (agribalyse_food_code, barcode)
    n_processed = 0
    n_updated = 0

    with gzip.open(jsonl_gz_path, "rt", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                p = json.loads(line)
            except json.JSONDecodeError:
                continue

            n_processed += 1
            if n_processed % PROGRESS_INTERVAL == 0:
                print(
                    f"[backfill] {n_processed:,} lines scanned, {n_updated:,} updated",
                    file=sys.stderr,
                )

            barcode = p.get("code")
            if not barcode:
                continue

            ecoscore = p.get("ecoscore_data") or {}
            agribalyse_meta = ecoscore.get("agribalyse") or {}
            raw_code = agribalyse_meta.get("agribalyse_food_code")
            if not raw_code:
                continue

            batch.append((str(raw_code), barcode))

            if len(batch) >= batch_size:
                conn.executemany(
                    "UPDATE products SET agribalyse_food_code = ? WHERE barcode = ?",
                    batch,
                )
                conn.commit()
                n_updated += len(batch)
                batch.clear()

    if batch:
        conn.executemany(
            "UPDATE products SET agribalyse_food_code = ? WHERE barcode = ?",
            batch,
        )
        conn.commit()
        n_updated += len(batch)

    conn.close()
    print(
        f"[backfill] Done. {n_processed:,} lines scanned, {n_updated:,} products updated.",
        file=sys.stderr,
    )


# ---------------------------------------------------------------------------
# Standalone AGRIBALYSE-only entry point
# ---------------------------------------------------------------------------

def ingest_agribalyse_standalone(db_path: str, map_path: str) -> None:
    """Run AGRIBALYSE ingest against an existing off_reference.sqlite.

    Used when the products table was already built by a previous ingest run
    and only the CO₂ tables need to be added / refreshed.

    After updating the SQLite file, compresses it to `<db_path>.gz` so the
    Flutter asset bundle stays current.

    Args:
        db_path:  Path to the existing off_reference.sqlite.
        map_path: Path to off_to_agribalyse_map.csv.
    """
    import shutil

    conn = sqlite3.connect(db_path)
    ingest_agribalyse(conn, map_path)
    # VACUUM requires explicit commit before call.
    conn.commit()
    conn.execute("VACUUM")
    conn.close()

    # Compress updated database to .gz for the Flutter asset bundle.
    gz_path = db_path + ".gz"
    print(f"[agribalyse] Compressing {db_path} → {gz_path} …", file=sys.stderr)
    with open(db_path, "rb") as f_in:
        with gzip.open(gz_path, "wb", compresslevel=9) as f_out:
            shutil.copyfileobj(f_in, f_out)
    size_mb = os.path.getsize(gz_path) / 1024 / 1024
    print(f"[agribalyse] Compressed: {size_mb:.1f} MB → {gz_path}", file=sys.stderr)
    print("[agribalyse] Standalone ingest complete.", file=sys.stderr)


if __name__ == "__main__":
    import sys as _sys

    # Support:
    #   python3 tools/ingest_off.py --agribalyse-only <db_path> <map_path>
    #   python3 tools/ingest_off.py --backfill-agribalyse-code <db_path> <jsonl_gz>
    if len(_sys.argv) == 4 and _sys.argv[1] == "--agribalyse-only":
        ingest_agribalyse_standalone(_sys.argv[2], _sys.argv[3])
    elif len(_sys.argv) == 4 and _sys.argv[1] == "--backfill-agribalyse-code":
        backfill_agribalyse_food_code(_sys.argv[2], _sys.argv[3])
    else:
        main()

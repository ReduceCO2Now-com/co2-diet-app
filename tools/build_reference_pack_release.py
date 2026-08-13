#!/usr/bin/env python3
"""
off_reference.sqlite -> versioned reference-pack release + manifest.json + delta.

Sibling script to tools/ingest_off.py. Where ingest_off.py builds a fresh
off_reference.sqlite from the raw OFF JSONL dump, this script takes an
already-built off_reference.sqlite (that script's output, run against the
full unfiltered OFF dump rather than this project's bundled size-constrained
starter-seed sample) and packages it into a versioned release artifact a
CDN can serve, plus a manifest.json describing it, and — when a prior
version's release directory is supplied via --previous — a delta artifact
that upgrades from that prior version to this one.

This is the build-side/off-app half of Phase 9's Architectural Responsibility
Map (see 09-RESEARCH.md) — CDN hosting itself is explicitly out of scope, but
producing real fixtures for the Flutter client (Plan 09-04's DeltaApplier)
and Plan 09-08's real-device verification to point at is this script's job.

The exact manifest.json / delta-artifact shapes this script produces are
documented in full in docs/data-contracts/reference-pack-manifest.md — this
script is that spec's reference implementation and must stay in sync with it.

IMPORTANT — Compressed vs. Decompressed Sizing:
`pack_size_bytes` / `pack_sha256` in the generated manifest.json describe the
gzip-compressed `full_v<version>.sqlite.gz` file only (matching
docs/data-contracts/reference-pack-manifest.md's "Compressed vs. Decompressed
Sizing" section). This script does NOT compute or publish a decompressed-size
field, by design — the client derives a conservative decompressed-size
estimate itself via a documented compression-ratio constant.

The delta artifact (`delta_v<old>_to_v<new>.sqlite`), by contrast, ships
uncompressed as a plain SQLite file — it is small enough that compression
isn't worth the added complexity, and the client ATTACHes it directly with
no decompression step.

Usage:
    python3 tools/build_reference_pack_release.py \\
        <input_off_reference.sqlite> <output_dir> \\
        --version <version-tag> [--previous <prior_version_release_dir>]

Example (first release, no delta):
    python3 tools/build_reference_pack_release.py \\
        assets/off_reference.sqlite /tmp/release-v1 --version 2026-08-off-pack-v1

Example (subsequent release, with delta against a prior release directory):
    python3 tools/build_reference_pack_release.py \\
        assets/off_reference.sqlite /tmp/release-v2 --version 2026-09-off-pack-v2 \\
        --previous /tmp/release-v1

Requirements: Python 3.8+, stdlib only (no pip installs required) — matches
tools/ingest_off.py's existing "no pip installs required" convention.
"""

import argparse
import gzip
import hashlib
import json
import os
import shutil
import sqlite3
import sys
import tempfile

# The full 11-column products schema, matching tools/ingest_off.py's actual
# DDL after ingest_agribalyse() has run (products base DDL's 9 explicit
# columns + agribalyse_food_code + primary_category_tag, both added via
# ALTER TABLE by ingest_agribalyse()) — NOT the illustrative 10-column
# subset shown in 09-RESEARCH.md's Code Examples section, which predates
# the primary_category_tag column.
PRODUCTS_COLUMNS = [
    "barcode",
    "product_name",
    "product_name_en",
    "brand",
    "calories_100g",
    "protein_100g",
    "carbs_100g",
    "fat_100g",
    "categories_tags",
    "agribalyse_food_code",
    "primary_category_tag",
]

CHUNK_SIZE = 1024 * 1024  # 1 MiB — streamed reads, never load a whole
# multi-hundred-MB file into memory at once.

PRODUCTS_DELTA_DDL = """
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
"""

DELETED_BARCODES_DDL = """
CREATE TABLE deleted_barcodes (
    barcode TEXT PRIMARY KEY
);
"""


def _sha256_and_size(path: str) -> tuple:
    """Stream-read a file, returning (hex sha256 digest, size in bytes)."""
    digest = hashlib.sha256()
    size = 0
    with open(path, "rb") as f:
        while True:
            chunk = f.read(CHUNK_SIZE)
            if not chunk:
                break
            digest.update(chunk)
            size += len(chunk)
    return digest.hexdigest(), size


def _gzip_compress(src_path: str, dest_path: str) -> None:
    """Stream-compress src_path into dest_path as a .gz file."""
    with open(src_path, "rb") as f_in:
        with gzip.open(dest_path, "wb", compresslevel=9) as f_out:
            shutil.copyfileobj(f_in, f_out, length=CHUNK_SIZE)


def _gzip_decompress(src_path: str, dest_path: str) -> None:
    """Stream-decompress a .gz file at src_path into dest_path."""
    with gzip.open(src_path, "rb") as f_in:
        with open(dest_path, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out, length=CHUNK_SIZE)


def _existing_columns(conn: sqlite3.Connection, schema: str, table: str) -> set:
    """Return the set of column names actually present on schema.table."""
    rows = conn.execute(f"PRAGMA {schema}.table_info({table})").fetchall()
    return {row[1] for row in rows}


def _select_clause(alias: str, available_columns: set) -> str:
    """Build a SELECT column list against `alias`, substituting NULL for any
    of PRODUCTS_COLUMNS missing from `available_columns` (defensive: an
    older prior-version pack built before primary_category_tag/
    agribalyse_food_code were added would otherwise break the diff)."""
    parts = []
    for col in PRODUCTS_COLUMNS:
        if col in available_columns:
            parts.append(f"{alias}.{col}")
        else:
            parts.append(f"NULL AS {col}")
    return ", ".join(parts)


def build_manifest(
    version: str, pack_size_bytes: int, pack_sha256: str, product_count: int
) -> dict:
    """Construct the manifest.json dict per
    docs/data-contracts/reference-pack-manifest.md's Section 1 shape.

    pack_url is a placeholder token using an https:// scheme (so it already
    satisfies the client's HTTPS-only validation if used as-is during local
    testing) — the eventual CDN owner replaces the host/path once real
    hosting exists.
    """
    return {
        "current_version": version,
        "pack_url": f"https://REPLACE_WITH_CDN_HOST/off-pack/full_v{version}.sqlite.gz",
        "pack_size_bytes": pack_size_bytes,
        "pack_sha256": pack_sha256,
        "product_count": product_count,
        "delta_from": {},
    }


def build_delta(
    current_db_path: str,
    previous_db_path: str,
    delta_db_path: str,
) -> None:
    """Diff previous_db_path's products table against current_db_path's,
    writing the row-level delta (added/changed rows -> products_delta;
    removed rows -> deleted_barcodes) to a fresh SQLite file at
    delta_db_path.

    Comparison is done entirely in SQL (via ATTACH + NOT EXISTS / IS
    NULL-safe equality) rather than loading rows into Python, so this
    scales to multi-million-row full packs without excessive memory use.
    """
    if os.path.exists(delta_db_path):
        os.remove(delta_db_path)

    conn = sqlite3.connect(delta_db_path)
    conn.execute("ATTACH DATABASE ? AS cur", (current_db_path,))
    conn.execute("ATTACH DATABASE ? AS old", (previous_db_path,))

    cur_columns = _existing_columns(conn, "cur", "products")
    old_columns = _existing_columns(conn, "old", "products")

    conn.executescript(PRODUCTS_DELTA_DDL)
    conn.executescript(DELETED_BARCODES_DDL)
    conn.commit()

    cur_select = _select_clause("c", cur_columns)

    # NULL-safe ("IS") column-by-column comparison so an actual NULL-to-NULL
    # transition never falsely registers as a change.
    compare_columns = [col for col in PRODUCTS_COLUMNS if col != "barcode"]
    equality_clauses = []
    for col in compare_columns:
        cur_ref = f"c.{col}" if col in cur_columns else "NULL"
        old_ref = f"o.{col}" if col in old_columns else "NULL"
        equality_clauses.append(f"{old_ref} IS {cur_ref}")
    equality_sql = " AND ".join(equality_clauses)

    insert_products_delta_sql = f"""
        INSERT INTO products_delta ({", ".join(PRODUCTS_COLUMNS)})
        SELECT {cur_select}
        FROM cur.products AS c
        WHERE NOT EXISTS (
            SELECT 1 FROM old.products AS o
            WHERE o.barcode = c.barcode AND {equality_sql}
        )
    """
    conn.execute(insert_products_delta_sql)

    insert_deleted_sql = """
        INSERT INTO deleted_barcodes (barcode)
        SELECT o.barcode FROM old.products AS o
        WHERE NOT EXISTS (
            SELECT 1 FROM cur.products AS c WHERE c.barcode = o.barcode
        )
    """
    conn.execute(insert_deleted_sql)
    conn.commit()

    n_delta = conn.execute("SELECT COUNT(*) FROM products_delta").fetchone()[0]
    n_deleted = conn.execute("SELECT COUNT(*) FROM deleted_barcodes").fetchone()[0]
    print(
        f"[delta] {n_delta:,} added/changed rows, {n_deleted:,} deleted barcodes",
        file=sys.stderr,
    )

    conn.execute("DETACH DATABASE cur")
    conn.execute("DETACH DATABASE old")
    conn.commit()
    conn.close()


def build_release(
    input_db: str,
    output_dir: str,
    version: str,
    previous_release_dir: str = None,
) -> None:
    """Produce a versioned full-pack release + manifest.json (+ delta, when
    --previous is given) in output_dir. See module docstring for the exact
    output shapes and the compressed-vs-decompressed sizing rule.
    """
    if not os.path.exists(input_db):
        print(f"[build] ERROR: input database not found: {input_db}", file=sys.stderr)
        sys.exit(1)

    os.makedirs(output_dir, exist_ok=True)

    # ── 1. Compress the full pack, compute its SHA-256/size over the
    #        compressed bytes (this is what pack_size_bytes/pack_sha256
    #        describe — see module docstring). ──────────────────────────────
    full_pack_filename = f"full_v{version}.sqlite.gz"
    full_pack_path = os.path.join(output_dir, full_pack_filename)
    print(f"[build] Compressing {input_db} -> {full_pack_path} …", file=sys.stderr)
    _gzip_compress(input_db, full_pack_path)
    pack_sha256, pack_size_bytes = _sha256_and_size(full_pack_path)
    print(
        f"[build] {full_pack_filename}: {pack_size_bytes:,} bytes, "
        f"sha256={pack_sha256}",
        file=sys.stderr,
    )

    # ── 2. product_count ──────────────────────────────────────────────────
    conn = sqlite3.connect(input_db)
    product_count = conn.execute("SELECT COUNT(*) FROM products").fetchone()[0]
    conn.close()
    print(f"[build] product_count = {product_count:,}", file=sys.stderr)

    # ── 3. manifest.json ──────────────────────────────────────────────────
    manifest = build_manifest(version, pack_size_bytes, pack_sha256, product_count)

    # ── 4. Delta artifact, when --previous is given ─────────────────────────
    if previous_release_dir:
        previous_manifest_path = os.path.join(previous_release_dir, "manifest.json")
        if not os.path.exists(previous_manifest_path):
            print(
                f"[build] ERROR: --previous directory has no manifest.json: "
                f"{previous_manifest_path}",
                file=sys.stderr,
            )
            sys.exit(1)
        with open(previous_manifest_path, encoding="utf-8") as f:
            previous_manifest = json.load(f)
        previous_version = previous_manifest["current_version"]

        previous_full_pack_path = os.path.join(
            previous_release_dir, f"full_v{previous_version}.sqlite.gz"
        )
        if not os.path.exists(previous_full_pack_path):
            print(
                f"[build] ERROR: --previous directory is missing its full pack: "
                f"{previous_full_pack_path}",
                file=sys.stderr,
            )
            sys.exit(1)

        print(
            f"[build] Building delta: {previous_version} -> {version} …",
            file=sys.stderr,
        )

        with tempfile.TemporaryDirectory() as tmp_dir:
            previous_db_decompressed = os.path.join(tmp_dir, "previous.sqlite")
            _gzip_decompress(previous_full_pack_path, previous_db_decompressed)

            delta_filename = f"delta_v{previous_version}_to_v{version}.sqlite"
            delta_path = os.path.join(output_dir, delta_filename)
            build_delta(input_db, previous_db_decompressed, delta_path)

        # Delta artifact ships uncompressed — compute sha256/size over the
        # plain .sqlite file itself, per the documented delta sizing rule.
        delta_sha256, delta_size_bytes = _sha256_and_size(delta_path)
        print(
            f"[build] {delta_filename}: {delta_size_bytes:,} bytes, "
            f"sha256={delta_sha256}",
            file=sys.stderr,
        )

        manifest["delta_from"][previous_version] = {
            "url": f"https://REPLACE_WITH_CDN_HOST/off-pack/{delta_filename}",
            "size_bytes": delta_size_bytes,
            "sha256": delta_sha256,
        }

    # ── 5. Write manifest.json ────────────────────────────────────────────
    manifest_path = os.path.join(output_dir, "manifest.json")
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)
        f.write("\n")
    print(f"[build] Wrote {manifest_path}", file=sys.stderr)
    print("[build] Done.", file=sys.stderr)


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="build_reference_pack_release.py",
        description=(
            "Package an already-built off_reference.sqlite into a versioned "
            "release artifact + manifest.json, and optionally a delta "
            "artifact against a prior version.\n"
            "\n"
            "pack_size_bytes/pack_sha256 in the generated manifest.json "
            "describe the gzip-compressed full_v<version>.sqlite.gz file "
            "ONLY — never the decompressed .sqlite's on-disk size. This "
            "script does not compute or publish a decompressed-size field, "
            "by design. See docs/data-contracts/reference-pack-manifest.md's "
            "'Compressed vs. Decompressed Sizing' section.\n"
            "\n"
            "The delta artifact (when --previous is given) ships "
            "uncompressed as a plain SQLite file — its size_bytes/sha256 "
            "describe those uncompressed bytes directly."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "input_db",
        metavar="input_off_reference.sqlite",
        help="Path to an already-built off_reference.sqlite (tools/ingest_off.py's output).",
    )
    parser.add_argument(
        "output_dir",
        metavar="output_dir",
        help="Directory to write full_v<version>.sqlite.gz, manifest.json, and (if --previous) delta_v<old>_to_v<new>.sqlite into.",
    )
    parser.add_argument(
        "--version",
        required=True,
        metavar="version-tag",
        help="Opaque version tag for this release (e.g. 2026-09-off-pack-v3). Client treats this as an opaque string.",
    )
    parser.add_argument(
        "--previous",
        metavar="prior_version_release_dir",
        default=None,
        help=(
            "Path to a prior release's output_dir (must contain manifest.json "
            "and its full_v<prior-version>.sqlite.gz). When given, also builds "
            "a delta artifact upgrading from that prior version to --version."
        ),
    )
    args = parser.parse_args()

    build_release(
        input_db=args.input_db,
        output_dir=args.output_dir,
        version=args.version,
        previous_release_dir=args.previous,
    )


if __name__ == "__main__":
    main()

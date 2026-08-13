import 'dart:io';

import 'package:co2diet/data/local/app_database.dart';

/// Applies a delta artifact (a small, standalone, uncompressed SQLite file
/// downloaded and checksum-verified by `ReferencePackRepository`, Plan
/// 09-04) against the currently-ATTACHed `off_ref` reference pack.
///
/// Implements `docs/data-contracts/reference-pack-manifest.md` Section 4's
/// "Required apply order": `ATTACH` the delta file, explicit-column
/// `INSERT OR REPLACE` its `products_delta` rows into `off_ref.products`,
/// `DELETE` any `off_ref.products` rows named in `deleted_barcodes`,
/// `DETACH`, then rebuild `off_ref.products_fts`.
///
/// **Why the FTS rebuild is mandatory, not optional (09-RESEARCH.md
/// Pitfall 1):** `off_ref.products_fts` is declared `content='products'`
/// with no `CREATE TRIGGER` keeping it in sync (grep-verified against
/// `tools/ingest_off.py`'s DDL) — every insert/replace/delete against
/// `off_ref.products` leaves `products_fts` silently stale until an
/// explicit `INSERT INTO products_fts(products_fts) VALUES('rebuild')` is
/// issued. At this phase's weekly/monthly delta cadence, a full rebuild
/// after every apply is the simplest correct approach — real-time
/// incremental FTS sync is unnecessary complexity for this update
/// frequency.
///
/// **Caller responsibility:** the delta file's path is never constructed by
/// this class from a manifest string — the caller (`ReferencePackRepository`)
/// hands over an already-downloaded, already-checksum-verified [File] to
/// [apply], which performs no checksum verification of its own.
class DeltaApplier {
  /// Creates a [DeltaApplier].
  const DeltaApplier();

  /// Applies [deltaFile]'s `products_delta`/`deleted_barcodes` tables
  /// against [db]'s currently-ATTACHed `off_ref.products` table.
  ///
  /// **`ATTACH`/`DETACH` deliberately run outside the write transaction**
  /// (a deviation from this plan's original literal action-block prose,
  /// which nested all four steps inside a single `db.transaction()`):
  /// real SQLite refuses `DETACH DATABASE` while a still-open transaction
  /// has touched that attached database (`SqliteException(1): database
  /// ref_delta is locked`) — verified empirically against both raw
  /// `package:sqlite3` and this project's actual `AppDatabase.transaction`
  /// wrapper before landing this implementation. The write transaction
  /// wraps only the `INSERT OR REPLACE` and the tombstone `DELETE`; a
  /// malformed row (e.g. a `NOT NULL` violation) aborts that statement,
  /// which aborts the transaction, leaving `off_ref.products` exactly as
  /// it was before this call (no partial writes) — the `try`/`finally`
  /// still runs `DETACH` afterward either way, so a failed apply never
  /// leaves `ref_delta` attached for a subsequent call to collide with.
  /// The `products_fts` rebuild runs last, after `DETACH`, and is skipped
  /// entirely when the transaction throws (propagated to the caller
  /// before the rebuild statement is ever reached) — there is nothing new
  /// to rebuild after a rolled-back apply.
  ///
  /// T-09-04-02 mitigation: every column is named explicitly in both the
  /// `INSERT` target list and the `SELECT` source list — never `SELECT *`
  /// — so a future schema drift between `products_delta` and
  /// `off_ref.products` fails loudly (a column-count/name mismatch is a
  /// SQL error) instead of silently misaligning data column-by-column.
  Future<void> apply(AppDatabase db, File deltaFile) async {
    await db.customStatement(
      "ATTACH DATABASE '${deltaFile.path}' AS ref_delta",
    );
    try {
      await db.transaction(() async {
        await db.customStatement('''
          INSERT OR REPLACE INTO off_ref.products
            (barcode, product_name, product_name_en, brand, calories_100g,
             protein_100g, carbs_100g, fat_100g, categories_tags,
             agribalyse_food_code, primary_category_tag)
          SELECT
            barcode, product_name, product_name_en, brand, calories_100g,
            protein_100g, carbs_100g, fat_100g, categories_tags,
            agribalyse_food_code, primary_category_tag
          FROM ref_delta.products_delta
        ''');

        await db.customStatement('''
          DELETE FROM off_ref.products
          WHERE barcode IN (SELECT barcode FROM ref_delta.deleted_barcodes)
        ''');
      });
    } finally {
      await db.customStatement('DETACH DATABASE ref_delta');
    }

    await db.customStatement(
      "INSERT INTO off_ref.products_fts(products_fts) VALUES('rebuild')",
    );
  }
}

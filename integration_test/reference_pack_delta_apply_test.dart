// Real-fixture proof that DeltaApplier keeps off_ref.products_fts in sync
// after every delta apply (09-RESEARCH.md Pitfall 1 -- the single
// highest-value new test this phase needs). Replaces Plan 09-01's Wave 0
// skip stub.
//
// Mirrors reference_pack_extractor_test.dart's real-fixture-plus-real-
// AppDatabase precedent and food_catalog_dao_ranking_test.dart's
// build-a-real-off_ref-fixture-via-package:sqlite3 convention, extended to
// products_fts's external-content-table quirk: since products_fts has
// content='products' with no sync trigger, seeding it requires an explicit
// INSERT INTO products_fts(rowid, ...) alongside every products row.

import 'dart:io';

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/reference_pack/delta_applier.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// A single seed row for the off_ref products fixture.
class _Product {
  const _Product(this.barcode, this.name);

  final String barcode;
  final String name;
}

/// Builds a real off_ref.sqlite fixture at `<dir>/off_reference_fixture.sqlite`
/// with the full 11-column products schema (tools/ingest_off.py's DDL plus
/// primary_category_tag) and a matching products_fts virtual table, seeded
/// with [products]. Returns the fixture's path.
String _buildOffRefFixture(Directory dir, List<_Product> products) {
  final path = p.join(dir.path, 'off_reference_fixture.sqlite');
  final db = sqlite3.sqlite3.open(path)
    ..execute('''
    CREATE TABLE products (
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
    CREATE VIRTUAL TABLE products_fts USING fts5(
      product_name,
      product_name_en,
      brand,
      content='products',
      content_rowid='rowid',
      tokenize='unicode61 remove_diacritics 2',
      prefix='2 3 4'
    );
  ''');

  final insertProduct = db.prepare('''
    INSERT INTO products (barcode, product_name)
    VALUES (?, ?)
  ''');
  final insertFts = db.prepare('''
    INSERT INTO products_fts(rowid, product_name, product_name_en, brand)
    VALUES (?, ?, ?, ?)
  ''');
  for (final product in products) {
    insertProduct.execute([product.barcode, product.name]);
    final rowid = db.lastInsertRowId;
    insertFts.execute([rowid, product.name, null, null]);
  }
  insertProduct.close();
  insertFts.close();
  db.close();
  return path;
}

/// Builds a real, uncompressed delta fixture at
/// `<dir>/delta_fixture.sqlite` with `products_delta`/`deleted_barcodes`
/// tables matching `docs/data-contracts/reference-pack-manifest.md`
/// Section 4's shape. [malformedProductName] lets a single test build a
/// deliberately-broken row (NULL product_name) to prove the all-or-nothing
/// transaction behavior.
String _buildDeltaFixture(
  Directory dir, {
  List<_Product> upserts = const [],
  List<String> deletedBarcodes = const [],
  bool malformedProductName = false,
}) {
  final path = p.join(dir.path, 'delta_fixture.sqlite');
  final db = sqlite3.sqlite3.open(path)
    ..execute('''
    CREATE TABLE products_delta (
      barcode               TEXT PRIMARY KEY,
      product_name          TEXT,
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
    CREATE TABLE deleted_barcodes (
      barcode TEXT PRIMARY KEY
    );
  ''');

  final insertDelta = db.prepare('''
    INSERT INTO products_delta (barcode, product_name)
    VALUES (?, ?)
  ''');
  for (final product in upserts) {
    insertDelta.execute([product.barcode, product.name]);
  }
  if (malformedProductName) {
    // products_delta.product_name has no NOT NULL constraint (per the data
    // contract), but off_ref.products.product_name does -- this row is
    // valid to store in the delta artifact itself, but fails to apply.
    insertDelta.execute(['BAD-BARCODE', null]);
  }
  insertDelta.close();

  final insertDeleted = db.prepare(
    'INSERT INTO deleted_barcodes (barcode) VALUES (?)',
  );
  for (final barcode in deletedBarcodes) {
    insertDeleted.execute([barcode]);
  }
  insertDeleted.close();

  db.close();
  return path;
}

Future<int> _ftsMatchCount(AppDatabase db, String query) async {
  // The FTS5 MATCH operator's left-hand side must be the bare, unqualified
  // virtual-table name -- neither a schema-qualified name
  // (`off_ref.products_fts`) nor a join alias is accepted by SQLite's
  // query planner for an ATTACHed FTS5 table (verified empirically: both
  // forms raise `no such column`), so the MATCH lives inside a subquery
  // scoped to the `off_ref` schema via its FROM clause instead.
  final rows = await db
      .customSelect(
        'SELECT barcode FROM off_ref.products WHERE rowid IN '
        '(SELECT rowid FROM off_ref.products_fts WHERE products_fts MATCH ?)',
        variables: [Variable.withString(query)],
        readsFrom: {},
      )
      .get();
  return rows.length;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase db;
  const applier = DeltaApplier();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'reference_pack_delta_apply_',
    );
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<AppDatabase> openWithOffRef(List<_Product> seedProducts) async {
    final offRefPath = _buildOffRefFixture(tempDir, seedProducts);
    final database = AppDatabase(NativeDatabase.memory());
    await database.customStatement(
      "ATTACH DATABASE '$offRefPath' AS off_ref",
    );
    return database;
  }

  testWidgets(
    'applying a delta with a new barcode inserts it and makes it '
    'immediately findable via products_fts (09-RESEARCH.md Pitfall 1)',
    (tester) async {
      db = await openWithOffRef([
        const _Product('1111', 'Existing Yogurt'),
      ]);

      final deltaPath = _buildDeltaFixture(
        tempDir,
        upserts: const [_Product('2222', 'Brand New Oat Milk')],
      );

      await applier.apply(db, File(deltaPath));

      final row = await db
          .customSelect(
            'SELECT product_name FROM off_ref.products WHERE barcode = ?',
            variables: [Variable.withString('2222')],
            readsFrom: {},
          )
          .getSingle();
      expect(row.read<String>('product_name'), 'Brand New Oat Milk');

      expect(await _ftsMatchCount(db, 'Oat'), 1);
    },
  );

  testWidgets(
    'applying a delta with an existing barcode replaces the row and '
    'products_fts matches the updated name, not the stale one',
    (tester) async {
      db = await openWithOffRef([
        const _Product('3333', 'Old Stale Cheese'),
      ]);

      final deltaPath = _buildDeltaFixture(
        tempDir,
        upserts: const [_Product('3333', 'Updated Fresh Cheese')],
      );

      await applier.apply(db, File(deltaPath));

      final row = await db
          .customSelect(
            'SELECT product_name FROM off_ref.products WHERE barcode = ?',
            variables: [Variable.withString('3333')],
            readsFrom: {},
          )
          .getSingle();
      expect(row.read<String>('product_name'), 'Updated Fresh Cheese');

      expect(await _ftsMatchCount(db, 'Fresh'), 1);
      expect(await _ftsMatchCount(db, 'Stale'), 0);
    },
  );

  testWidgets(
    'applying a delta whose deleted_barcodes lists a barcode removes it '
    'from both products and products_fts',
    (tester) async {
      db = await openWithOffRef([
        const _Product('4444', 'Doomed Discontinued Snack'),
      ]);

      final deltaPath = _buildDeltaFixture(
        tempDir,
        deletedBarcodes: const ['4444'],
      );

      await applier.apply(db, File(deltaPath));

      final row = await db
          .customSelect(
            'SELECT barcode FROM off_ref.products WHERE barcode = ?',
            variables: [Variable.withString('4444')],
            readsFrom: {},
          )
          .getSingleOrNull();
      expect(row, isNull);

      expect(await _ftsMatchCount(db, 'Discontinued'), 0);
    },
  );

  testWidgets(
    'a malformed row mid-apply rolls back the whole transaction -- prior '
    'products/products_fts state is left untouched (all-or-nothing)',
    (tester) async {
      db = await openWithOffRef([
        const _Product('5555', 'Untouched Survivor Product'),
      ]);

      final deltaPath = _buildDeltaFixture(
        tempDir,
        upserts: const [_Product('6666', 'Should Never Land')],
        malformedProductName: true,
      );

      await expectLater(
        () => applier.apply(db, File(deltaPath)),
        throwsA(isA<Exception>()),
      );

      // The pre-existing row is untouched.
      final survivor = await db
          .customSelect(
            'SELECT product_name FROM off_ref.products WHERE barcode = ?',
            variables: [Variable.withString('5555')],
            readsFrom: {},
          )
          .getSingle();
      expect(
        survivor.read<String>('product_name'),
        'Untouched Survivor Product',
      );

      // Neither the valid nor the malformed row from the failed delta
      // landed -- the whole statement (and transaction) aborted together.
      final shouldNeverLand = await db
          .customSelect(
            'SELECT barcode FROM off_ref.products WHERE barcode = ?',
            variables: [Variable.withString('6666')],
            readsFrom: {},
          )
          .getSingleOrNull();
      expect(shouldNeverLand, isNull);

      expect(await _ftsMatchCount(db, 'Survivor'), 1);
    },
  );
}

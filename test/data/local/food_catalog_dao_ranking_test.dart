// Tests FoodCatalogDao.searchLocalFoods' nutrition-data-completeness ranking
// boost: results with a non-null calories_100g must outrank results without
// one, regardless of raw BM25 relevance — see the doc comment on
// searchLocalFoods in food_catalog_dao.dart.
//
// Builds a real, minimal off_ref.sqlite fixture on disk (same schema as
// tools/ingest_off.py's DDL) and ATTACHes it via a real AppDatabase, rather
// than mocking — the boost is expressed entirely in the raw SQL's ORDER BY,
// so only a real SQLite/FTS5 query can prove it works.

import 'dart:io';

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Creates a temp off_ref.sqlite fixture with the real ingest schema
/// (tools/ingest_off.py's DDL) and the given rows, returning its path.
String _buildOffRefFixture(Directory dir, List<_Product> products) {
  final path = p.join(dir.path, 'off_reference_fixture.sqlite');
  final db = sqlite3.sqlite3.open(path);
  db.execute('''
    CREATE TABLE products (
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
    INSERT INTO products
      (barcode, product_name, product_name_en, brand, calories_100g)
    VALUES (?, ?, ?, ?, ?)
  ''');
  final insertFts = db.prepare('''
    INSERT INTO products_fts(rowid, product_name, product_name_en, brand)
    VALUES (?, ?, ?, ?)
  ''');

  for (final product in products) {
    insertProduct.execute([
      product.barcode,
      product.name,
      null,
      product.brand,
      product.calories100g,
    ]);
    final rowid = db.lastInsertRowId;
    insertFts.execute([rowid, product.name, null, product.brand]);
  }

  insertProduct.close();
  insertFts.close();
  db.close();
  return path;
}

class _Product {
  const _Product(this.barcode, this.name, this.brand, this.calories100g);

  final String barcode;
  final String name;
  final String brand;
  final double? calories100g;
}

void main() {
  late Directory tempDir;
  late AppDatabase db;
  late FoodCatalogDao dao;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('off_ref_ranking_test');
  });

  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  test(
    'a short exact-name match with no nutrition data does not outrank a '
    'longer match that has nutrition data',
    () async {
      // "Milk" is a short, exact product_name match for query "milk" — BM25
      // alone ranks a short exact match very highly. Without the
      // completeness boost, this would sit above "Milk Chocolate Bar", even
      // though the latter has real nutrition data and the former doesn't.
      final offRefPath = _buildOffRefFixture(tempDir, const [
        _Product('1111111111111', 'Milk', 'GenericBrand', null),
        _Product(
          '2222222222222',
          'Milk Chocolate Bar',
          'SomeChocolateCo',
          540,
        ),
      ]);

      db = AppDatabase(NativeDatabase.memory(), offRefPath: offRefPath);
      dao = FoodCatalogDao(db);

      final results = await dao.searchLocalFoods('milk');

      expect(results, hasLength(2));
      expect(
        results.first.calories100g,
        isNotNull,
        reason:
            'the data-complete result ("Milk Chocolate Bar") should be '
            'first despite "Milk" being the closer BM25 match',
      );
      expect(results.first.productName, 'Milk Chocolate Bar');
      expect(results.last.productName, 'Milk');
      expect(results.last.calories100g, isNull);
    },
  );

  test(
    'BM25 relevance is still the tie-break within each completeness tier',
    () async {
      // Two data-complete products: "Milk" (shorter/more exact) should still
      // rank above "Whole Milk Beverage Extra" within the complete tier.
      final offRefPath = _buildOffRefFixture(tempDir, const [
        _Product('3333333333333', 'Whole Milk Beverage Extra', 'Brand', 60),
        _Product('4444444444444', 'Milk', 'Brand', 42),
        // A data-empty distractor that must sort after both complete ones.
        _Product('5555555555555', 'Milkshake Mix', 'Brand', null),
      ]);

      db = AppDatabase(NativeDatabase.memory(), offRefPath: offRefPath);
      dao = FoodCatalogDao(db);

      final results = await dao.searchLocalFoods('milk');

      expect(results, hasLength(3));
      expect(results[0].calories100g, isNotNull);
      expect(results[1].calories100g, isNotNull);
      expect(
        results[2].calories100g,
        isNull,
        reason: 'the data-empty result must sort last regardless of BM25',
      );
      expect(
        results[0].productName,
        'Milk',
        reason: 'within the complete tier, the closer BM25 match still wins',
      );
    },
  );
}

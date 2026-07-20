import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/tables/user_food_cache_table.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:drift/drift.dart';

part 'food_catalog_dao.g.dart';

/// DAO for food catalog queries.
///
/// Performs a UNION ALL of two FTS5 sources:
/// 1. `off_ref.products_fts` — the bundled OFF reference DB (ATTACHed).
/// 2. `user_food_cache_fts` — API-cached results in co2diet.sqlite
///    (D-API-FALLBACK per CONTEXT.md: "Cached results indexed: FTS5 table
///    in co2diet.sqlite indexes cached items — they appear in future local
///    searches without re-hitting the API").
///
/// T-02-03-01 mitigation: [_sanitizeFts5Query] strips all FTS5 metacharacters
/// before building the MATCH expression; query is parameterized via
/// Variable.withString (not string interpolation).
@DriftAccessor(tables: [UserFoodCacheTable])
class FoodCatalogDao extends DatabaseAccessor<AppDatabase>
    with _$FoodCatalogDaoMixin {
  /// Creates a [FoodCatalogDao] bound to [attachedDatabase].
  FoodCatalogDao(super.attachedDatabase);

  /// Searches local FTS5 indexes and returns up to 25 [FoodItem]s.
  ///
  /// Queries both `off_ref.products_fts` (when [AppDatabase.offRefPath] is
  /// non-null) and `user_food_cache_fts`, deduplicates results by barcode,
  /// and caps the total at 25.
  ///
  /// Returns [] if [query] sanitizes to empty (T-02-03-03: early return
  /// for DoS mitigation — caller enforces the 2-char minimum).
  Future<List<FoodItem>> searchLocalFoods(String query) async {
    final sanitized = _sanitizeFts5Query(query);
    if (sanitized.isEmpty) return [];

    final results = <FoodItem>[];
    final seenBarcodes = <String>{};

    // --- off_ref query (skipped in unit tests without ATTACH) ---
    if (attachedDatabase.offRefPath != null) {
      try {
        // bm25 weights: product_name=10.0, product_name_en=8.0, brand=3.0.
        // ORDER BY rank ASC: bm25 returns negative — most relevant first.
        final offRows = await attachedDatabase.customSelect(
          '''
          SELECT
            p.barcode,
            p.product_name,
            p.product_name_en,
            p.brand,
            p.calories_100g,
            p.protein_100g,
            p.carbs_100g,
            p.fat_100g,
            bm25(off_ref.products_fts, 10.0, 8.0, 3.0) AS rank
          FROM off_ref.products_fts
          JOIN off_ref.products p ON off_ref.products_fts.rowid = p.rowid
          WHERE off_ref.products_fts MATCH ?
          ORDER BY rank
          LIMIT 25
          ''',
          variables: [Variable.withString(sanitized)],
          readsFrom: {},
        ).get();

        for (final row in offRows) {
          final item = FoodItem.fromQueryRow(row);
          final key = item.barcode;
          if (key != null) {
            if (seenBarcodes.add(key)) results.add(item);
          } else {
            results.add(item);
          }
        }
      } on Exception {
        // Swallow off_ref query errors — fall through to user cache.
        // This can happen if the attached DB is corrupt or not yet populated.
      }
    }

    // --- user_food_cache_fts query (D-API-FALLBACK) ---
    if (results.length < 25) {
      try {
        final cacheRows = await attachedDatabase.customSelect(
          '''
          SELECT
            barcode,
            product_name,
            product_name_en,
            brand,
            calories_100g,
            protein_100g,
            carbs_100g,
            fat_100g,
            0.0 AS rank
          FROM user_food_cache_fts
          JOIN user_food_cache_table
            ON user_food_cache_fts.rowid = user_food_cache_table.rowid
          WHERE user_food_cache_fts MATCH ?
          LIMIT 25
          ''',
          variables: [Variable.withString(sanitized)],
          readsFrom: {attachedDatabase.userFoodCacheTable},
        ).get();

        for (final row in cacheRows) {
          if (results.length >= 25) break;
          final item = FoodItem.fromQueryRow(row);
          final key = item.barcode;
          if (key != null) {
            if (seenBarcodes.add(key)) results.add(item);
          } else {
            results.add(item);
          }
        }
      } on Exception {
        // Swallow user cache errors — FTS5 table may not exist yet
        // if the DB is brand new and no API results have been cached.
      }
    }

    return results;
  }

  /// Strips FTS5 metacharacters and appends '*' to each term.
  ///
  /// T-02-03-01: Removes all chars that are not alphanumeric, space, or hyphen.
  /// Splits on whitespace, filters empty tokens, appends '*' per term.
  /// Returns empty string when no valid terms remain (caller returns []).
  ///
  /// Exposed as package-private via [sanitizeFts5QueryForTest] for unit tests.
  String _sanitizeFts5Query(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'[^\w\s\-]'), '');
    final terms = cleaned
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => '$t*')
        .toList();
    return terms.join(' ');
  }

  /// Test-only accessor for [_sanitizeFts5Query].
  ///
  /// Allows unit tests to verify sanitization logic without running SQL.
  String sanitizeFts5QueryForTest(String raw) => _sanitizeFts5Query(raw);
}

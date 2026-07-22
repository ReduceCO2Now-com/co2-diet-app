import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/tables/user_food_cache_table.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

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
///
/// T-03-02-01/02 mitigation: [lookupByBarcodeWithCo2] uses
/// Variable.withString for the barcode parameter and applies a max-length
/// guard (EAN-13 = 13 chars max) before any DB access.
@DriftAccessor(tables: [UserFoodCacheTable])
class FoodCatalogDao extends DatabaseAccessor<AppDatabase>
    with _$FoodCatalogDaoMixin {
  /// Creates a [FoodCatalogDao] bound to [attachedDatabase].
  FoodCatalogDao(super.attachedDatabase);

  // ---------------------------------------------------------------------------
  // FTS5 name search
  // ---------------------------------------------------------------------------

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
            NULL AS co2e_100g,
            NULL AS confidence_band,
            bm25(products_fts, 10.0, 8.0, 3.0) AS rank
          FROM off_ref.products_fts
          JOIN off_ref.products p ON off_ref.products_fts.rowid = p.rowid
          WHERE products_fts MATCH ?
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
      } on Exception catch (e) {
        // Fall through to user cache. Logged so failures are visible in
        // device logs (adb logcat / flutter test --verbose) without crashing.
        debugPrint('[FoodCatalogDao] off_ref query error: $e');
      }
    }

    // --- user_food_cache_fts query (D-API-FALLBACK) ---
    if (results.length < 25) {
      try {
        final cacheRows = await attachedDatabase.customSelect(
          '''
          SELECT
            t.barcode,
            t.product_name,
            t.product_name_en,
            t.brand,
            t.calories_100g,
            t.protein_100g,
            t.carbs_100g,
            t.fat_100g,
            NULL AS co2e_100g,
            NULL AS confidence_band,
            0.0 AS rank
          FROM user_food_cache_fts
          JOIN user_food_cache_table t
            ON user_food_cache_fts.rowid = t.rowid
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
      } on Exception catch (e) {
        debugPrint('[FoodCatalogDao] user_food_cache_fts query error: $e');
      }
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // Barcode lookup with CO₂ enrichment
  // ---------------------------------------------------------------------------

  /// Looks up a food item by [barcode] and enriches the result with CO₂ data.
  ///
  /// Implements the two-step CO₂ lookup chain:
  ///
  /// **Step 1 — High confidence:** Queries `off_ref.food_co2_overrides` for
  /// a direct AGRIBALYSE barcode crosswalk match. Returns a [FoodItem] with
  /// `confidenceBand = 'high'` if found.
  ///
  /// **Step 2 — Medium confidence:** Falls back to `off_ref.products` joined
  /// with `off_ref.co2_factors` on `primary_category_tag`. Returns a
  /// [FoodItem] with `confidenceBand = 'medium'` if found.
  ///
  /// Returns null if:
  /// - [barcode] is empty or longer than 13 chars (T-03-02-02 DoS guard:
  ///   EAN-13 = 13 chars, EAN-8 = 8, UPC-A = 12 — reject >13).
  /// - [AppDatabase.offRefPath] is null (no ATTACH — unit test isolation).
  /// - No match found in either step.
  ///
  /// T-03-02-01 mitigation: [barcode] is always passed as
  /// `Variable.withString(barcode)` — parameterized query prevents SQL
  /// injection.
  Future<FoodItem?> lookupByBarcodeWithCo2(String barcode) async {
    // T-03-02-02: Max-length guard — EAN-13 is the longest valid product
    // barcode at 13 chars. Reject oversized or empty inputs immediately.
    if (barcode.isEmpty || barcode.length > 13) return null;

    // No ATTACH — skip all DB queries (unit test isolation pattern).
    if (attachedDatabase.offRefPath == null) return null;

    try {
      // Step 1 — High confidence: direct barcode match in food_co2_overrides.
      final overrideRows = await attachedDatabase.customSelect(
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
          ov.co2e_100g,
          'high' AS confidence_band
        FROM off_ref.food_co2_overrides ov
        JOIN off_ref.products p ON p.barcode = ov.barcode
        WHERE ov.barcode = ?
        LIMIT 1
        ''',
        variables: [Variable.withString(barcode)],
        readsFrom: {},
      ).get();

      if (overrideRows.isNotEmpty) {
        return FoodItem.fromQueryRow(overrideRows.first);
      }

      // Step 2 — Medium confidence: category average via primary_category_tag.
      // The ingest pipeline (Task 2) adds primary_category_tag to products —
      // avoids the json_each approach (Pitfall 5 in RESEARCH.md).
      final catRows = await attachedDatabase.customSelect(
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
          cf.co2e_median AS co2e_100g,
          'medium' AS confidence_band
        FROM off_ref.products p
        JOIN off_ref.co2_factors cf
          ON cf.categories_tag = p.primary_category_tag
        WHERE p.barcode = ?
        LIMIT 1
        ''',
        variables: [Variable.withString(barcode)],
        readsFrom: {},
      ).get();

      if (catRows.isNotEmpty) {
        return FoodItem.fromQueryRow(catRows.first);
      }
    } on Exception catch (e) {
      debugPrint('[FoodCatalogDao] barcode lookup error: $e');
    }

    return null;
  }

  /// Enriches an already-fetched API [FoodItem] with CO₂ data from
  /// `off_ref.co2_factors` using [FoodItem.categoriesTags] from the API.
  ///
  /// Iterates [apiResult.categoriesTags] most-specific-first (OFF API order)
  /// and returns on the first hit in co2_factors. This avoids a circular
  /// barcode→products subquery that always fails for items not in the local DB.
  ///
  /// Returns [apiResult] unchanged when no category match is found, when
  /// [FoodItem.categoriesTags] is null/empty, or when [AppDatabase.offRefPath]
  /// is null.
  Future<FoodItem> lookupByBarcodeFromApi(
    String barcode,
    FoodItem apiResult,
  ) async {
    if (barcode.isEmpty || barcode.length > 13) return apiResult;
    if (attachedDatabase.offRefPath == null) return apiResult;

    final tags = apiResult.categoriesTags;
    if (tags == null || tags.isEmpty) return apiResult;

    // Iterate tags most-specific-first (OFF API order) — return on first hit.
    try {
      for (final tag in tags) {
        final rows = await attachedDatabase.customSelect(
          'SELECT co2e_median AS co2e_100g'
          ' FROM off_ref.co2_factors'
          ' WHERE categories_tag = ?'
          ' LIMIT 1',
          variables: [Variable.withString(tag)],
          readsFrom: {},
        ).get();

        if (rows.isNotEmpty) {
          final co2e = rows.first.read<double?>('co2e_100g');
          if (co2e != null) {
            return apiResult.copyWith(
              co2e100g: co2e,
              confidenceBand: 'medium',
            );
          }
        }
      }
    } on Exception catch (e) {
      debugPrint('[FoodCatalogDao] API barcode CO₂ enrichment error: $e');
    }

    return apiResult;
  }

  // ---------------------------------------------------------------------------
  // FTS5 query sanitization
  // ---------------------------------------------------------------------------

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

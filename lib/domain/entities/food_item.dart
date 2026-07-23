import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// Domain entity representing a food product from either the OFF bundled
/// reference database or the API-cached user food catalog.
///
/// Plain Dart class (no Freezed) — domain entities are simple here.
/// Equality is based on [barcode] (nullable) and [productName] to support
/// deduplication when merging results from off_ref and user_food_cache.
///
/// [FoodItem.fromQueryRow] reads columns by name from a Drift QueryRow and
/// is used by the DAO to map raw DB rows to this entity.
@immutable
class FoodItem {
  /// Creates a [FoodItem] with the given fields.
  ///
  /// Only [productName] is required; all other fields are optional/nullable.
  const FoodItem({
    required this.productName,
    this.barcode,
    this.productNameEn,
    this.brand,
    this.calories100g,
    this.protein100g,
    this.carbs100g,
    this.fat100g,
    this.co2e100g,
    this.confidenceBand,
    this.categoriesTags,
    this.source,
    this.sourceRowId,
  });

  /// Creates a [FoodItem] from a Drift [QueryRow].
  ///
  /// Reads columns by name using [QueryRow.read] with nullable type parameters.
  /// Used by FoodCatalogDao to map both off_ref and user_food_cache results.
  /// Reads `co2e_100g` and `confidence_band` columns (null-safe) — present
  /// only in CO₂-enriched queries (lookupByBarcodeWithCo2).
  factory FoodItem.fromQueryRow(QueryRow row) {
    return FoodItem(
      barcode: row.read<String?>('barcode'),
      productName: row.read<String>('product_name'),
      productNameEn: row.read<String?>('product_name_en'),
      brand: row.read<String?>('brand'),
      calories100g: row.read<double?>('calories_100g'),
      protein100g: row.read<double?>('protein_100g'),
      carbs100g: row.read<double?>('carbs_100g'),
      fat100g: row.read<double?>('fat_100g'),
      co2e100g: row.read<double?>('co2e_100g'),
      confidenceBand: row.read<String?>('confidence_band'),
      source: row.read<String?>('source'),
      sourceRowId: row.read<String?>('source_row_id'),
    );
  }

  /// EAN barcode; nullable because some API results may lack a barcode.
  final String? barcode;

  /// Primary product name (may be in any language — whatever the OFF record
  /// stores as product_name). Never empty for valid entries.
  final String productName;

  /// English product name, nullable. Absent for many non-English products.
  final String? productNameEn;

  /// Brand name, nullable.
  final String? brand;

  /// Energy in kcal per 100 g, nullable when not available.
  final double? calories100g;

  /// Protein in g per 100 g, nullable when not available.
  final double? protein100g;

  /// Carbohydrates in g per 100 g, nullable when not available.
  final double? carbs100g;

  /// Fat in g per 100 g, nullable when not available.
  final double? fat100g;

  /// CO₂e in kg per kg of product (from AGRIBALYSE v3.1.1), nullable.
  ///
  /// Null means no CO₂ estimate is available — the CO₂ row should be hidden
  /// in the UI rather than showing a false-precision value.
  final double? co2e100g;

  /// Confidence band for the CO₂ estimate; one of 'high', 'medium', or null.
  ///
  /// - 'high': direct AGRIBALYSE barcode crosswalk match (product-specific LCA)
  /// - 'medium': AGRIBALYSE category average (estimate based on food category)
  /// - null: no CO₂ estimate available; [co2e100g] will also be null
  final String? confidenceBand;

  /// OFF category tags from the API response (e.g. ['en:milks', 'en:dairy']).
  ///
  /// Transient — never persisted to DB or read from [fromQueryRow]. Populated
  /// only for items fetched via [OffApiClient.fetchByBarcode] and used by
  /// [FoodCatalogDao.lookupByBarcodeFromApi] to match against co2_factors.
  final List<String>? categoriesTags;

  /// Which table this [FoodItem] originated from: `'off_ref'`,
  /// `'user_food_cache'`, or `'user_foods'`.
  ///
  /// Nullable for backward compatibility with call sites/tests that
  /// construct a [FoodItem] directly (e.g. API results before caching).
  /// Populated by [fromQueryRow] when the underlying query aliases a
  /// `source` column (see `FoodCatalogDao`).
  final String? source;

  /// The primary key of this row within its own origin table
  /// (`user_food_cache_table.id` or `user_foods_table.id`).
  ///
  /// Always `null` for `off_ref` rows, which use [barcode] as their own
  /// table's primary key already and therefore never need a separate row
  /// id. Populated by [fromQueryRow] when the underlying query aliases a
  /// `source_row_id` column.
  final String? sourceRowId;

  /// The single authoritative merge-key resolution rule (CONTEXT.md Merge
  /// Semantics): "the food's internal reference/ID — barcode when
  /// present, otherwise catalog/custom-food ID — never a product-name
  /// string match".
  ///
  /// Returns [barcode] when non-null (regardless of [source]); returns
  /// [sourceRowId] when [barcode] is null and [sourceRowId] is non-null;
  /// throws a [StateError] when both are null — a [FoodItem] must always
  /// originate from a DAO query that populates at least one of these two
  /// fields, so reaching neither indicates a query bug upstream, not a
  /// legitimate "no reference" state.
  ///
  /// Every plan that needs a `MealEntry.foodRef`/`Favorite.foodRef` value
  /// from a [FoodItem] MUST call this getter rather than reading
  /// [barcode]/[productName] directly — it never falls back to
  /// [productName] under any circumstance.
  String get resolvedFoodRef {
    if (barcode != null) return barcode!;
    if (sourceRowId != null) return sourceRowId!;
    throw StateError(
      'FoodItem.resolvedFoodRef: both barcode and sourceRowId are null '
      'for productName="$productName" — the DAO query that produced this '
      'FoodItem must populate at least one of these fields.',
    );
  }

  /// Sentinel object used by [copyWith] to detect when a caller explicitly
  /// passes `null` for a nullable field vs. not providing the field at all.
  static const _sentinel = Object();

  /// Returns a copy of this [FoodItem] with the specified fields replaced.
  ///
  /// To explicitly set a nullable field to `null`, pass `null` explicitly:
  /// `item.copyWith(barcode: null)` — the sentinel pattern detects the
  /// override and sets the field to null rather than preserving the old value.
  FoodItem copyWith({
    Object? barcode = _sentinel,
    String? productName,
    Object? productNameEn = _sentinel,
    Object? brand = _sentinel,
    Object? calories100g = _sentinel,
    Object? protein100g = _sentinel,
    Object? carbs100g = _sentinel,
    Object? fat100g = _sentinel,
    Object? co2e100g = _sentinel,
    Object? confidenceBand = _sentinel,
    Object? categoriesTags = _sentinel,
    Object? source = _sentinel,
    Object? sourceRowId = _sentinel,
  }) {
    return FoodItem(
      barcode: barcode == _sentinel ? this.barcode : barcode as String?,
      productName: productName ?? this.productName,
      productNameEn: productNameEn == _sentinel
          ? this.productNameEn
          : productNameEn as String?,
      brand: brand == _sentinel ? this.brand : brand as String?,
      calories100g: calories100g == _sentinel
          ? this.calories100g
          : calories100g as double?,
      protein100g: protein100g == _sentinel
          ? this.protein100g
          : protein100g as double?,
      carbs100g:
          carbs100g == _sentinel ? this.carbs100g : carbs100g as double?,
      fat100g: fat100g == _sentinel ? this.fat100g : fat100g as double?,
      co2e100g:
          co2e100g == _sentinel ? this.co2e100g : co2e100g as double?,
      confidenceBand: confidenceBand == _sentinel
          ? this.confidenceBand
          : confidenceBand as String?,
      categoriesTags: categoriesTags == _sentinel
          ? this.categoriesTags
          : categoriesTags as List<String>?,
      source: source == _sentinel ? this.source : source as String?,
      sourceRowId: sourceRowId == _sentinel
          ? this.sourceRowId
          : sourceRowId as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem &&
        other.barcode == barcode &&
        other.productName == productName;
  }

  @override
  int get hashCode => Object.hash(barcode, productName);

  @override
  String toString() =>
      'FoodItem(barcode: $barcode, productName: $productName, '
      'productNameEn: $productNameEn, brand: $brand, '
      'calories100g: $calories100g, co2e100g: $co2e100g, '
      'confidenceBand: $confidenceBand, source: $source, '
      'sourceRowId: $sourceRowId)';
}

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
  });

  /// Creates a [FoodItem] from a Drift [QueryRow].
  ///
  /// Reads columns by name using [QueryRow.read] with nullable type parameters.
  /// Used by FoodCatalogDao to map both off_ref and user_food_cache results.
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
      'calories100g: $calories100g)';
}

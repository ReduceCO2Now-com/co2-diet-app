import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/domain/entities/serving_size.dart';
import 'package:flutter/foundation.dart';

/// A user-created custom food, or a user-created override of an existing
/// off_ref/user_food_cache product.
///
/// Mirrors `FoodItem`'s sentinel `copyWith` pattern. Per LOG-10, only
/// [name] and [calories] are required to save — every other field
/// (protein, carbs, fat, sugar, fiber, salt, CO₂ estimate, barcode, quick
/// serving sizes) is optional.
@immutable
class UserFood {
  /// Creates a [UserFood] with the given fields.
  ///
  /// [calories] is nullable in the constructor to allow constructing an
  /// in-progress form draft before the user has entered a value — see
  /// [isValid] for the save-time requirement.
  const UserFood({
    required this.id,
    required this.name,
    this.brand,
    this.category,
    this.referenceAmountG = 100,
    this.calories,
    this.protein,
    this.carbs,
    this.sugar,
    this.fat,
    this.fiber,
    this.salt,
    this.co2e100g,
    this.confidenceBand,
    this.co2Source,
    this.co2MethodologyVersion,
    this.barcode,
    this.quickServingSizes = const [],
    this.overrideOfRef,
    this.overrideOfSource,
  });

  /// Maps a Drift [UserFoodRow] 1:1 onto a [UserFood].
  ///
  /// Owned exclusively by Plan 04-05 (the data-layer repository plan) —
  /// Plan 04-03, which defines this entity, deliberately never imports
  /// `package:drift`, so the Drift-row-to-entity mapping direction lives
  /// here instead. `row.quickServingSizes` is already decoded to
  /// `List<ServingSize>` at the column level by the table's
  /// `TypeConverter.json2` (Plan 04-02) — assigned directly, never
  /// re-decoded.
  factory UserFood.fromRow(UserFoodRow row) => UserFood(
    id: row.id,
    name: row.name,
    brand: row.brand,
    category: row.category,
    referenceAmountG: row.referenceAmountG,
    calories: row.calories,
    protein: row.protein,
    carbs: row.carbs,
    sugar: row.sugar,
    fat: row.fat,
    fiber: row.fiber,
    salt: row.salt,
    co2e100g: row.co2e100g,
    confidenceBand: row.confidenceBand,
    co2Source: row.co2Source,
    co2MethodologyVersion: row.co2MethodologyVersion,
    barcode: row.barcode,
    quickServingSizes: row.quickServingSizes,
    overrideOfRef: row.overrideOfRef,
    overrideOfSource: row.overrideOfSource,
  );

  /// Unique row id.
  final String id;

  /// Food name (required, non-empty per [isValid]).
  final String name;

  /// Brand, nullable.
  final String? brand;

  /// Category, nullable.
  final String? category;

  /// The amount (in grams or ml) that [calories]/[protein]/etc. are
  /// expressed per. Defaults to 100 (matching the off_ref/user_food_cache
  /// per-100g convention), but a user may enter values per a different
  /// reference amount (e.g. "per serving").
  final double referenceAmountG;

  /// Calories per [referenceAmountG]. Required at save time (see
  /// [isValid]) but nullable in the constructor to allow an in-progress
  /// form draft.
  final double? calories;

  /// Protein (g) per [referenceAmountG], nullable.
  final double? protein;

  /// Carbs (g) per [referenceAmountG], nullable.
  final double? carbs;

  /// Sugar (g) per [referenceAmountG], nullable.
  final double? sugar;

  /// Fat (g) per [referenceAmountG], nullable.
  final double? fat;

  /// Fiber (g) per [referenceAmountG], nullable.
  final double? fiber;

  /// Salt (g) per [referenceAmountG], nullable.
  final double? salt;

  /// CO₂e per [referenceAmountG], nullable.
  final double? co2e100g;

  /// Confidence band for [co2e100g], nullable.
  final String? confidenceBand;

  /// Source of the CO₂ estimate: `'category_estimate'` or `'manual'`,
  /// nullable.
  final String? co2Source;

  /// Version of the CO₂ calculation methodology that produced [co2e100g]
  /// when [co2Source] is `'category_estimate'` (CO2-04), nullable. Always
  /// null for a `'manual'` [co2Source], mirroring [confidenceBand].
  final String? co2MethodologyVersion;

  /// Barcode, nullable — set when this custom food is associated with a
  /// physical product barcode.
  final String? barcode;

  /// User-configurable quick serving sizes (e.g. "1 slice = 30g").
  final List<ServingSize> quickServingSizes;

  /// When this [UserFood] is an override of an existing off_ref/
  /// user_food_cache product, the `foodRef` being overridden. Null for a
  /// standalone custom food.
  final String? overrideOfRef;

  /// The `foodRefSource` of [overrideOfRef] (`'off_ref'` or
  /// `'user_food_cache'`), nullable.
  final String? overrideOfSource;

  /// Whether this [UserFood] has the minimum required fields to be saved
  /// (LOG-10: name + at least a calorie value are required).
  bool get isValid => name.trim().isNotEmpty && calories != null;

  /// Whether this [UserFood] is an override of an existing product rather
  /// than a standalone custom food.
  bool get isOverride => overrideOfRef != null;

  double? _per100g(double? value) =>
      value == null ? null : value * 100 / referenceAmountG;

  /// Calories rescaled to a per-100g/100ml basis (using
  /// [referenceAmountG]), nullable.
  double? get caloriesPer100g => _per100g(calories);

  /// Protein rescaled to a per-100g/100ml basis, nullable.
  double? get proteinPer100g => _per100g(protein);

  /// Carbs rescaled to a per-100g/100ml basis, nullable.
  double? get carbsPer100g => _per100g(carbs);

  /// Fat rescaled to a per-100g/100ml basis, nullable.
  double? get fatPer100g => _per100g(fat);

  /// Sugar rescaled to a per-100g/100ml basis, nullable.
  double? get sugarPer100g => _per100g(sugar);

  /// Fiber rescaled to a per-100g/100ml basis, nullable.
  double? get fiberPer100g => _per100g(fiber);

  /// Salt rescaled to a per-100g/100ml basis, nullable.
  double? get saltPer100g => _per100g(salt);

  /// Sentinel object used by [copyWith] to detect when a caller explicitly
  /// passes `null` for a nullable field vs. not providing the field at all.
  static const _sentinel = Object();

  /// Returns a copy of this [UserFood] with the specified fields replaced.
  ///
  /// To explicitly set a nullable field to `null`, pass `null` explicitly:
  /// `food.copyWith(brand: null)` — the sentinel pattern detects the
  /// override and sets the field to null rather than preserving the old
  /// value.
  UserFood copyWith({
    String? id,
    String? name,
    Object? brand = _sentinel,
    Object? category = _sentinel,
    double? referenceAmountG,
    Object? calories = _sentinel,
    Object? protein = _sentinel,
    Object? carbs = _sentinel,
    Object? sugar = _sentinel,
    Object? fat = _sentinel,
    Object? fiber = _sentinel,
    Object? salt = _sentinel,
    Object? co2e100g = _sentinel,
    Object? confidenceBand = _sentinel,
    Object? co2Source = _sentinel,
    Object? co2MethodologyVersion = _sentinel,
    Object? barcode = _sentinel,
    List<ServingSize>? quickServingSizes,
    Object? overrideOfRef = _sentinel,
    Object? overrideOfSource = _sentinel,
  }) {
    return UserFood(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand == _sentinel ? this.brand : brand as String?,
      category: category == _sentinel ? this.category : category as String?,
      referenceAmountG: referenceAmountG ?? this.referenceAmountG,
      calories: calories == _sentinel ? this.calories : calories as double?,
      protein: protein == _sentinel ? this.protein : protein as double?,
      carbs: carbs == _sentinel ? this.carbs : carbs as double?,
      sugar: sugar == _sentinel ? this.sugar : sugar as double?,
      fat: fat == _sentinel ? this.fat : fat as double?,
      fiber: fiber == _sentinel ? this.fiber : fiber as double?,
      salt: salt == _sentinel ? this.salt : salt as double?,
      co2e100g: co2e100g == _sentinel ? this.co2e100g : co2e100g as double?,
      confidenceBand: confidenceBand == _sentinel
          ? this.confidenceBand
          : confidenceBand as String?,
      co2Source:
          co2Source == _sentinel ? this.co2Source : co2Source as String?,
      co2MethodologyVersion: co2MethodologyVersion == _sentinel
          ? this.co2MethodologyVersion
          : co2MethodologyVersion as String?,
      barcode: barcode == _sentinel ? this.barcode : barcode as String?,
      quickServingSizes: quickServingSizes ?? this.quickServingSizes,
      overrideOfRef: overrideOfRef == _sentinel
          ? this.overrideOfRef
          : overrideOfRef as String?,
      overrideOfSource: overrideOfSource == _sentinel
          ? this.overrideOfSource
          : overrideOfSource as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserFood && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserFood(id: $id, name: $name, brand: $brand, calories: $calories, '
      'referenceAmountG: $referenceAmountG)';
}

import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:flutter/foundation.dart';

/// A single logged meal-entry row: a "snapshot, not reference" of a food
/// product's macro/CO₂ values at the moment it was logged.
///
/// Deliberately snapshots (not live-references) `calories100gSnapshot` /
/// `protein100gSnapshot` / `carbs100gSnapshot` / `fat100gSnapshot` /
/// `co2e100gSnapshot` so a later edit to the source product (off_ref,
/// user_food_cache, or user_foods) never silently rewrites history for
/// already-logged meals.
///
/// Scope note: the snapshot intentionally captures calories/protein/carbs/
/// fat/co2e only — not sugar/fiber/salt, which `UserFood` captures. This is
/// a deliberate Phase 4 scope boundary, flagged here for Phase 5
/// nutrition-rollup planning rather than expanded now.
///
/// Unlike `FoodItem` (which has no `id`), [MealEntry] rows are individually
/// addressable for edit/delete/duplicate, so [id] is required and equality
/// is based on it.
@immutable
class MealEntry {
  /// Creates a [MealEntry] with the given fields.
  const MealEntry({
    required this.id,
    required this.mealSlot,
    required this.foodRef,
    required this.foodRefSource,
    required this.quantity,
    required this.unit,
    required this.productNameSnapshot,
    required this.loggedAt,
    required this.logDate,
    this.brandSnapshot,
    this.calories100gSnapshot,
    this.protein100gSnapshot,
    this.carbs100gSnapshot,
    this.fat100gSnapshot,
    this.co2e100gSnapshot,
    this.confidenceBandSnapshot,
  });

  /// Unique, individually addressable row id.
  final String id;

  /// Which slot (breakfast/lunch/dinner/snack) this entry belongs to.
  final MealSlot mealSlot;

  /// Reference key to the source food (barcode, cache id, or user food id
  /// — interpretation depends on [foodRefSource]).
  final String foodRef;

  /// Which table [foodRef] resolves against: `'off_ref'`,
  /// `'user_food_cache'`, or `'user_foods'`.
  final String foodRefSource;

  /// Logged quantity, expressed in [unit].
  final double quantity;

  /// Unit [quantity] is expressed in.
  final PortionUnit unit;

  /// Product name at the moment of logging (snapshot).
  final String productNameSnapshot;

  /// Brand at the moment of logging (snapshot), nullable.
  final String? brandSnapshot;

  /// Calories per 100g/100ml at the moment of logging (snapshot), nullable.
  final double? calories100gSnapshot;

  /// Protein per 100g/100ml at the moment of logging (snapshot), nullable.
  final double? protein100gSnapshot;

  /// Carbs per 100g/100ml at the moment of logging (snapshot), nullable.
  final double? carbs100gSnapshot;

  /// Fat per 100g/100ml at the moment of logging (snapshot), nullable.
  final double? fat100gSnapshot;

  /// CO₂e per 100g/100ml at the moment of logging (snapshot), nullable.
  final double? co2e100gSnapshot;

  /// Confidence band for [co2e100gSnapshot] at the moment of logging
  /// (snapshot), nullable.
  final String? confidenceBandSnapshot;

  /// When this entry was logged (UTC).
  final DateTime loggedAt;

  /// Logical log date (`yyyy-MM-dd`), used to group entries by day
  /// independent of timezone shifts on [loggedAt].
  final String logDate;

  /// Sentinel object used by [copyWith] to detect when a caller explicitly
  /// passes `null` for a nullable field vs. not providing the field at all.
  static const _sentinel = Object();

  /// Returns a copy of this [MealEntry] with the specified fields replaced.
  ///
  /// To explicitly set a nullable field to `null`, pass `null` explicitly:
  /// `entry.copyWith(brandSnapshot: null)` — the sentinel pattern detects
  /// the override and sets the field to null rather than preserving the
  /// old value.
  MealEntry copyWith({
    String? id,
    MealSlot? mealSlot,
    String? foodRef,
    String? foodRefSource,
    double? quantity,
    PortionUnit? unit,
    String? productNameSnapshot,
    Object? brandSnapshot = _sentinel,
    Object? calories100gSnapshot = _sentinel,
    Object? protein100gSnapshot = _sentinel,
    Object? carbs100gSnapshot = _sentinel,
    Object? fat100gSnapshot = _sentinel,
    Object? co2e100gSnapshot = _sentinel,
    Object? confidenceBandSnapshot = _sentinel,
    DateTime? loggedAt,
    String? logDate,
  }) {
    return MealEntry(
      id: id ?? this.id,
      mealSlot: mealSlot ?? this.mealSlot,
      foodRef: foodRef ?? this.foodRef,
      foodRefSource: foodRefSource ?? this.foodRefSource,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      brandSnapshot: brandSnapshot == _sentinel
          ? this.brandSnapshot
          : brandSnapshot as String?,
      calories100gSnapshot: calories100gSnapshot == _sentinel
          ? this.calories100gSnapshot
          : calories100gSnapshot as double?,
      protein100gSnapshot: protein100gSnapshot == _sentinel
          ? this.protein100gSnapshot
          : protein100gSnapshot as double?,
      carbs100gSnapshot: carbs100gSnapshot == _sentinel
          ? this.carbs100gSnapshot
          : carbs100gSnapshot as double?,
      fat100gSnapshot: fat100gSnapshot == _sentinel
          ? this.fat100gSnapshot
          : fat100gSnapshot as double?,
      co2e100gSnapshot: co2e100gSnapshot == _sentinel
          ? this.co2e100gSnapshot
          : co2e100gSnapshot as double?,
      confidenceBandSnapshot: confidenceBandSnapshot == _sentinel
          ? this.confidenceBandSnapshot
          : confidenceBandSnapshot as String?,
      loggedAt: loggedAt ?? this.loggedAt,
      logDate: logDate ?? this.logDate,
    );
  }

  /// Computes this entry's live-scaled macro/CO₂ values for the given
  /// [gramsEquivalent] (the actual weight/volume this entry's [quantity]
  /// + [unit] resolves to in grams or milliliters).
  ///
  /// Pure function: `snapshot == null ? null : snapshot * gramsEquivalent
  /// / 100`. A `null` snapshot field always yields a `null` scaled field
  /// — never `0` or a fabricated number (no false precision).
  ScaledMacros scaled(double gramsEquivalent) =>
      scaledMacros(this, gramsEquivalent: gramsEquivalent);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MealEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MealEntry(id: $id, mealSlot: $mealSlot, foodRef: $foodRef, '
      'foodRefSource: $foodRefSource, quantity: $quantity, unit: $unit, '
      'productNameSnapshot: $productNameSnapshot, logDate: $logDate)';
}

/// Live-scaled macro/CO₂ values for a [MealEntry], computed from its
/// per-100g/100ml snapshot fields against an actual gram/ml equivalent.
///
/// Has no independent identity/persistence — it is a transient
/// presentation value object, so it lives alongside [MealEntry] rather
/// than in its own file.
@immutable
class ScaledMacros {
  /// Creates a [ScaledMacros] with the given scaled values.
  const ScaledMacros({
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.co2e,
  });

  /// Scaled calories, or `null` when the source snapshot was `null`.
  final double? calories;

  /// Scaled protein (g), or `null` when the source snapshot was `null`.
  final double? protein;

  /// Scaled carbs (g), or `null` when the source snapshot was `null`.
  final double? carbs;

  /// Scaled fat (g), or `null` when the source snapshot was `null`.
  final double? fat;

  /// Scaled CO₂e, or `null` when the source snapshot was `null`.
  final double? co2e;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScaledMacros &&
          other.calories == calories &&
          other.protein == protein &&
          other.carbs == carbs &&
          other.fat == fat &&
          other.co2e == co2e);

  @override
  int get hashCode => Object.hash(calories, protein, carbs, fat, co2e);

  @override
  String toString() =>
      'ScaledMacros(calories: $calories, protein: $protein, carbs: $carbs, '
      'fat: $fat, co2e: $co2e)';
}

/// Pure function computing [entry]'s live-scaled macro/CO₂ values for the
/// given [gramsEquivalent]. See [MealEntry.scaled] for the instance-method
/// equivalent.
ScaledMacros scaledMacros(MealEntry entry, {required double gramsEquivalent}) {
  double? scale(double? snapshot) =>
      snapshot == null ? null : snapshot * gramsEquivalent / 100;
  return ScaledMacros(
    calories: scale(entry.calories100gSnapshot),
    protein: scale(entry.protein100gSnapshot),
    carbs: scale(entry.carbs100gSnapshot),
    fat: scale(entry.fat100gSnapshot),
    co2e: scale(entry.co2e100gSnapshot),
  );
}

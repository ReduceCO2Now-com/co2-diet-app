import 'package:co2diet/data/local/app_database.dart';
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
/// Also snapshots `sugar100gSnapshot`/`fiber100gSnapshot`/`saltSnapshot`
/// (added in Phase 5, NUTR-01) — populated only when the source food
/// carries that data (personal overrides / custom foods via `UserFood`);
/// null for off_ref/user_food_cache-sourced entries, which have no such
/// data (honest absence, not a fabricated `0`).
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
    this.co2MethodologyVersionSnapshot,
    this.sugar100gSnapshot,
    this.fiber100gSnapshot,
    this.saltSnapshot,
  });

  /// Maps a Drift [MealEntryRow] 1:1 onto a [MealEntry].
  ///
  /// Owned exclusively by Plan 04-05 (the data-layer repository plan) —
  /// Plan 04-03, which defines this entity, deliberately never imports
  /// `package:drift`, so the Drift-row-to-entity mapping direction lives
  /// here instead. Every table column maps directly onto the matching
  /// entity field; no lossy conversions.
  factory MealEntry.fromRow(MealEntryRow row) => MealEntry(
    id: row.id,
    mealSlot: row.mealSlot,
    foodRef: row.foodRef,
    foodRefSource: row.foodRefSource,
    quantity: row.quantity,
    unit: row.unit,
    productNameSnapshot: row.productNameSnapshot,
    loggedAt: row.loggedAt,
    logDate: row.logDate,
    brandSnapshot: row.brandSnapshot,
    calories100gSnapshot: row.calories100gSnapshot,
    protein100gSnapshot: row.protein100gSnapshot,
    carbs100gSnapshot: row.carbs100gSnapshot,
    fat100gSnapshot: row.fat100gSnapshot,
    co2e100gSnapshot: row.co2e100gSnapshot,
    confidenceBandSnapshot: row.confidenceBandSnapshot,
    co2MethodologyVersionSnapshot: row.co2MethodologyVersionSnapshot,
    sugar100gSnapshot: row.sugar100gSnapshot,
    fiber100gSnapshot: row.fiber100gSnapshot,
    saltSnapshot: row.saltSnapshot,
  );

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

  /// Version of the CO₂ calculation methodology that produced
  /// [co2e100gSnapshot] at the moment of logging (CO2-04 snapshot),
  /// nullable.
  final String? co2MethodologyVersionSnapshot;

  /// Sugar per 100g/100ml at the moment of logging (snapshot), nullable.
  ///
  /// Populated only when the source `FoodItem` carried a non-null
  /// `sugar100g` (personal overrides / custom foods, source `'user_foods'`
  /// — see `UserFoodTable`). Always `null` for entries logged from
  /// off_ref/user_food_cache foods, which have no sugar data — honest
  /// absence, not a fabricated `0`.
  final double? sugar100gSnapshot;

  /// Fiber per 100g/100ml at the moment of logging (snapshot), nullable.
  /// See [sugar100gSnapshot]'s doc comment for the same source-data rule.
  final double? fiber100gSnapshot;

  /// Salt per 100g/100ml at the moment of logging (snapshot), nullable.
  /// See [sugar100gSnapshot]'s doc comment for the same source-data rule.
  final double? saltSnapshot;

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
    Object? co2MethodologyVersionSnapshot = _sentinel,
    Object? sugar100gSnapshot = _sentinel,
    Object? fiber100gSnapshot = _sentinel,
    Object? saltSnapshot = _sentinel,
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
      co2MethodologyVersionSnapshot:
          co2MethodologyVersionSnapshot == _sentinel
          ? this.co2MethodologyVersionSnapshot
          : co2MethodologyVersionSnapshot as String?,
      sugar100gSnapshot: sugar100gSnapshot == _sentinel
          ? this.sugar100gSnapshot
          : sugar100gSnapshot as double?,
      fiber100gSnapshot: fiber100gSnapshot == _sentinel
          ? this.fiber100gSnapshot
          : fiber100gSnapshot as double?,
      saltSnapshot: saltSnapshot == _sentinel
          ? this.saltSnapshot
          : saltSnapshot as double?,
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
      'productNameSnapshot: $productNameSnapshot, logDate: $logDate, '
      'sugar100gSnapshot: $sugar100gSnapshot, '
      'fiber100gSnapshot: $fiber100gSnapshot, saltSnapshot: $saltSnapshot)';
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
    this.sugar,
    this.fiber,
    this.salt,
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

  /// Scaled sugar (g), or `null` when the source snapshot was `null`.
  final double? sugar;

  /// Scaled fiber (g), or `null` when the source snapshot was `null`.
  final double? fiber;

  /// Scaled salt (g), or `null` when the source snapshot was `null`.
  final double? salt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScaledMacros &&
          other.calories == calories &&
          other.protein == protein &&
          other.carbs == carbs &&
          other.fat == fat &&
          other.co2e == co2e &&
          other.sugar == sugar &&
          other.fiber == fiber &&
          other.salt == salt);

  @override
  int get hashCode =>
      Object.hash(calories, protein, carbs, fat, co2e, sugar, fiber, salt);

  @override
  String toString() =>
      'ScaledMacros(calories: $calories, protein: $protein, carbs: $carbs, '
      'fat: $fat, co2e: $co2e, sugar: $sugar, fiber: $fiber, salt: $salt)';
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
    sugar: scale(entry.sugar100gSnapshot),
    fiber: scale(entry.fiber100gSnapshot),
    salt: scale(entry.saltSnapshot),
  );
}

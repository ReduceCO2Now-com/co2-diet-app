import 'package:flutter/foundation.dart';

/// Domain entity for the user's personal-footprint CO2 settings (CO2-03).
///
/// This is a strictly separate layer from any individual food's own CO2
/// data (`co2e100g`/`confidenceBand` on `FoodItem`/`UserFood`/`MealEntry`).
/// Per `05-CONTEXT.md`, changes here are forward-only: saving new settings
/// never rewrites, recalculates, or joins against already-logged meal
/// entries. Every field is optional — an unset field falls back to a
/// regional average when the app computes a personal footprint elsewhere.
@immutable
class Co2Settings {
  /// Creates an immutable [Co2Settings]. All fields are optional; the
  /// no-argument form represents "no settings saved yet".
  const Co2Settings({
    this.locationCountry,
    this.locationRegion,
    this.purchasingSource,
    this.shoppingTransport,
    this.cookingMethod,
    this.foodStorage,
    this.householdSize,
    this.foodWasteLevel,
  });

  /// Country the user shops/lives in, used for regional CO2 averages.
  final String? locationCountry;

  /// Region/state within [locationCountry].
  final String? locationRegion;

  /// Where the user primarily buys food: `'supermarket'`, `'local_farm'`,
  /// `'mix'`.
  final String? purchasingSource;

  /// How the user typically travels to buy food: `'car'`, `'public'`,
  /// `'walk_bike'`.
  final String? shoppingTransport;

  /// The user's primary cooking method: `'electric'`, `'gas'`,
  /// `'induction'`.
  final String? cookingMethod;

  /// The user's food storage setup: `'small_fridge'`,
  /// `'large_fridge_freezer'`.
  final String? foodStorage;

  /// Number of people in the user's household.
  final int? householdSize;

  /// Self-reported food waste level: `'low'`, `'medium'`, `'high'`.
  final String? foodWasteLevel;

  /// Classifies how many of the 7 optional fields are set, matching the
  /// CO2 Calculation Settings screen's Data Quality Indicator:
  /// - `'basic'`: 0-2 fields set
  /// - `'good'`: 3-5 fields set
  /// - `'detailed'`: 6-7 fields set
  String get dataQuality {
    final setCount = [
      locationCountry,
      locationRegion,
      purchasingSource,
      shoppingTransport,
      cookingMethod,
      foodStorage,
      foodWasteLevel,
    ].where((field) => field != null).length +
        (householdSize != null ? 1 : 0);

    if (setCount <= 2) return 'basic';
    if (setCount <= 5) return 'good';
    return 'detailed';
  }

  /// Sentinel object used by [copyWith] to detect when a caller explicitly
  /// passes `null` for a nullable field vs. not providing the field at all.
  static const _sentinel = Object();

  /// Returns a copy of this [Co2Settings] with the specified fields
  /// replaced.
  ///
  /// To explicitly set a nullable field to `null`, pass `null` explicitly:
  /// `settings.copyWith(locationCountry: null)` — the sentinel pattern
  /// detects the override and sets the field to null rather than
  /// preserving the old value.
  Co2Settings copyWith({
    Object? locationCountry = _sentinel,
    Object? locationRegion = _sentinel,
    Object? purchasingSource = _sentinel,
    Object? shoppingTransport = _sentinel,
    Object? cookingMethod = _sentinel,
    Object? foodStorage = _sentinel,
    Object? householdSize = _sentinel,
    Object? foodWasteLevel = _sentinel,
  }) {
    return Co2Settings(
      locationCountry: locationCountry == _sentinel
          ? this.locationCountry
          : locationCountry as String?,
      locationRegion: locationRegion == _sentinel
          ? this.locationRegion
          : locationRegion as String?,
      purchasingSource: purchasingSource == _sentinel
          ? this.purchasingSource
          : purchasingSource as String?,
      shoppingTransport: shoppingTransport == _sentinel
          ? this.shoppingTransport
          : shoppingTransport as String?,
      cookingMethod: cookingMethod == _sentinel
          ? this.cookingMethod
          : cookingMethod as String?,
      foodStorage: foodStorage == _sentinel
          ? this.foodStorage
          : foodStorage as String?,
      householdSize: householdSize == _sentinel
          ? this.householdSize
          : householdSize as int?,
      foodWasteLevel: foodWasteLevel == _sentinel
          ? this.foodWasteLevel
          : foodWasteLevel as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Co2Settings &&
          runtimeType == other.runtimeType &&
          locationCountry == other.locationCountry &&
          locationRegion == other.locationRegion &&
          purchasingSource == other.purchasingSource &&
          shoppingTransport == other.shoppingTransport &&
          cookingMethod == other.cookingMethod &&
          foodStorage == other.foodStorage &&
          householdSize == other.householdSize &&
          foodWasteLevel == other.foodWasteLevel;

  @override
  int get hashCode => Object.hash(
        locationCountry,
        locationRegion,
        purchasingSource,
        shoppingTransport,
        cookingMethod,
        foodStorage,
        householdSize,
        foodWasteLevel,
      );

  @override
  String toString() => 'Co2Settings('
      'locationCountry: $locationCountry, '
      'locationRegion: $locationRegion, '
      'purchasingSource: $purchasingSource, '
      'shoppingTransport: $shoppingTransport, '
      'cookingMethod: $cookingMethod, '
      'foodStorage: $foodStorage, '
      'householdSize: $householdSize, '
      'foodWasteLevel: $foodWasteLevel)';
}

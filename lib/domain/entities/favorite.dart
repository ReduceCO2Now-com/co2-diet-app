import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:flutter/foundation.dart';

/// A favorited food, enabling one-tap re-logging from the Favorites list.
///
/// Like `MealEntry`, captures a "snapshot, not reference" of the food's
/// display fields at favorite-time so the Favorites list never silently
/// changes underneath the user when the source product data is updated.
/// Unique on `foodRef` + `foodRefSource` (enforced at the data layer).
@immutable
class Favorite {
  /// Creates a [Favorite] with the given fields.
  const Favorite({
    required this.id,
    required this.foodRef,
    required this.foodRefSource,
    required this.productNameSnapshot,
    required this.favoritedAt,
    this.brandSnapshot,
    this.calories100gSnapshot,
    this.co2e100gSnapshot,
    this.confidenceBandSnapshot,
    this.lastQuantity,
    this.lastUnit,
  });

  /// Unique, individually addressable row id.
  final String id;

  /// Reference key to the source food (barcode, cache id, or user food id
  /// — interpretation depends on [foodRefSource]).
  final String foodRef;

  /// Which table [foodRef] resolves against: `'off_ref'`,
  /// `'user_food_cache'`, or `'user_foods'`.
  final String foodRefSource;

  /// Product name at the moment of favoriting (snapshot).
  final String productNameSnapshot;

  /// Brand at the moment of favoriting (snapshot), nullable.
  final String? brandSnapshot;

  /// Calories per 100g/100ml at the moment of favoriting (snapshot),
  /// nullable.
  final double? calories100gSnapshot;

  /// CO₂e per 100g/100ml at the moment of favoriting (snapshot), nullable.
  final double? co2e100gSnapshot;

  /// Confidence band for [co2e100gSnapshot] at the moment of favoriting
  /// (snapshot), nullable.
  final String? confidenceBandSnapshot;

  /// The quantity last logged from this favorite (one-tap-log memory),
  /// nullable until first used.
  final double? lastQuantity;

  /// The unit last logged from this favorite (one-tap-log memory),
  /// nullable until first used.
  final PortionUnit? lastUnit;

  /// When this food was favorited.
  final DateTime favoritedAt;

  /// Sentinel object used by [copyWith] to detect when a caller explicitly
  /// passes `null` for a nullable field vs. not providing the field at all.
  static const _sentinel = Object();

  /// Returns a copy of this [Favorite] with the specified fields replaced.
  ///
  /// To explicitly set a nullable field to `null`, pass `null` explicitly:
  /// `favorite.copyWith(lastQuantity: null)` — the sentinel pattern
  /// detects the override and sets the field to null rather than
  /// preserving the old value.
  Favorite copyWith({
    String? id,
    String? foodRef,
    String? foodRefSource,
    String? productNameSnapshot,
    Object? brandSnapshot = _sentinel,
    Object? calories100gSnapshot = _sentinel,
    Object? co2e100gSnapshot = _sentinel,
    Object? confidenceBandSnapshot = _sentinel,
    Object? lastQuantity = _sentinel,
    Object? lastUnit = _sentinel,
    DateTime? favoritedAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      foodRef: foodRef ?? this.foodRef,
      foodRefSource: foodRefSource ?? this.foodRefSource,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      brandSnapshot: brandSnapshot == _sentinel
          ? this.brandSnapshot
          : brandSnapshot as String?,
      calories100gSnapshot: calories100gSnapshot == _sentinel
          ? this.calories100gSnapshot
          : calories100gSnapshot as double?,
      co2e100gSnapshot: co2e100gSnapshot == _sentinel
          ? this.co2e100gSnapshot
          : co2e100gSnapshot as double?,
      confidenceBandSnapshot: confidenceBandSnapshot == _sentinel
          ? this.confidenceBandSnapshot
          : confidenceBandSnapshot as String?,
      lastQuantity: lastQuantity == _sentinel
          ? this.lastQuantity
          : lastQuantity as double?,
      lastUnit: lastUnit == _sentinel
          ? this.lastUnit
          : lastUnit as PortionUnit?,
      favoritedAt: favoritedAt ?? this.favoritedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Favorite && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Favorite(id: $id, foodRef: $foodRef, foodRefSource: $foodRefSource, '
      'productNameSnapshot: $productNameSnapshot)';
}

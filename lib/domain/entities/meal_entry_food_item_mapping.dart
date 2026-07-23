import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';

/// `MealEntry`/`Favorite` → [FoodItem] reverse-mapping extensions.
///
/// This file exists specifically so Plans 04-10 and 04-11 (both wave 7,
/// with no dependency between each other) can share one already-built,
/// already-tested implementation of "pre-fill the logging sheet from an
/// existing entry" instead of each independently defining (or racing to
/// define) their own.
///
/// Round-trip guarantee: both [MealEntryFoodItemMapping.toFoodItem] and
/// [FavoriteFoodItemMapping.toFoodItem] set `FoodItem.sourceRowId` to the
/// entry's/favorite's own `foodRef` and leave `FoodItem.barcode: null` —
/// so `toFoodItem().resolvedFoodRef` always reproduces the original
/// `foodRef` exactly (byte-for-byte), regardless of whether that
/// `foodRef` was actually a real barcode, a `user_food_cache_table.id`,
/// or a `user_foods_table.id`. This guarantees re-logging an
/// edited/duplicated/recent entry, or re-logging a favorite, resolves to
/// the identical merge key it originally had — see
/// [FoodItem.resolvedFoodRef] for the authoritative merge-key rule this
/// depends on.
extension MealEntryFoodItemMapping on MealEntry {
  /// Builds a [FoodItem] from this [MealEntry]'s snapshot fields, suitable
  /// for pre-filling the logging sheet when editing/duplicating/re-logging
  /// an existing entry.
  FoodItem toFoodItem() => FoodItem(
    productName: productNameSnapshot,
    brand: brandSnapshot,
    calories100g: calories100gSnapshot,
    protein100g: protein100gSnapshot,
    carbs100g: carbs100gSnapshot,
    fat100g: fat100gSnapshot,
    co2e100g: co2e100gSnapshot,
    confidenceBand: confidenceBandSnapshot,
    source: foodRefSource,
    sourceRowId: foodRef,
  );
}

/// `Favorite` → [FoodItem] reverse-mapping extension.
///
/// See [MealEntryFoodItemMapping] for the shared round-trip guarantee this
/// extension follows. Note that [Favorite] only snapshots
/// calories/co2e (not protein/carbs/fat), so [FoodItem.protein100g],
/// [FoodItem.carbs100g], and [FoodItem.fat100g] are always `null` on the
/// result.
extension FavoriteFoodItemMapping on Favorite {
  /// Builds a [FoodItem] from this [Favorite]'s snapshot fields, suitable
  /// for pre-filling the logging sheet when re-logging a favorited food.
  FoodItem toFoodItem() => FoodItem(
    productName: productNameSnapshot,
    brand: brandSnapshot,
    calories100g: calories100gSnapshot,
    co2e100g: co2e100gSnapshot,
    confidenceBand: confidenceBandSnapshot,
    source: foodRefSource,
    sourceRowId: foodRef,
  );
}

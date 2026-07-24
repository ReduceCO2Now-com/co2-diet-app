import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/features/meal_logging/providers/meal_entry_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_notifier.g.dart';

/// AsyncNotifier exposing the current favorites list and the toggle /
/// one-tap-log mutation surface (LOG-08) the UI layer (Plans 04-08 through
/// 04-11) consumes exclusively — those plans never touch
/// `IMealEntryRepository` directly for favorite concerns.
///
/// Follows `ProfileNotifier`'s exact codegen shape: `build()` returns the
/// current state, every mutation method calls the repository then
/// `ref.invalidateSelf()` so the Favorites list picks up the change.
@riverpod
class FavoriteNotifier extends _$FavoriteNotifier {
  @override
  Future<List<Favorite>> build() =>
      ref.watch(mealEntryRepositoryProvider).getFavorites();

  /// Flips favorite status for [draft]'s `foodRef` + `foodRefSource`
  /// (inserts if absent, deletes if present — see
  /// `IMealEntryRepository.toggleFavorite`'s contract).
  Future<void> toggle(Favorite draft) async {
    await ref.read(mealEntryRepositoryProvider).toggleFavorite(draft);
    ref.invalidateSelf();
  }

  /// Whether a food identified by [foodRef] + [foodRefSource] is currently
  /// favorited. A plain pass-through read — does not participate in
  /// `build()`'s state or `invalidateSelf()` cycle.
  Future<bool> isFavorite(String foodRef, String foodRefSource) =>
      ref.read(mealEntryRepositoryProvider).isFavorite(foodRef, foodRefSource);

  /// Logs [favorite] with a single tap: builds a `MealEntry` draft from the
  /// favorite's snapshot fields plus its remembered `lastQuantity`/
  /// `lastUnit` (falling back to 100g when `lastQuantity` is null — a
  /// favorite that has never been logged before) and [autoDetectedSlot],
  /// delegates the actual write to `MealEntryNotifier.logFood` (keeping
  /// "one tap = instant log" behavior in exactly one place), then updates
  /// the favorite's remembered quantity/unit via `touchFavoriteUsage`.
  ///
  /// Returns the `MealLogResult` from the underlying `logFood` call so the
  /// caller's Undo snackbar works identically to a sheet-initiated log.
  Future<MealLogResult> logFromFavorite(
    Favorite favorite, {
    required MealSlot autoDetectedSlot,
  }) async {
    final now = DateTime.now();
    final quantity = favorite.lastQuantity ?? 100;
    final unit = favorite.lastUnit ?? PortionUnit.g;
    final draft = MealEntry(
      id: '',
      mealSlot: autoDetectedSlot,
      foodRef: favorite.foodRef,
      foodRefSource: favorite.foodRefSource,
      quantity: quantity,
      unit: unit,
      productNameSnapshot: favorite.productNameSnapshot,
      brandSnapshot: favorite.brandSnapshot,
      calories100gSnapshot: favorite.calories100gSnapshot,
      co2e100gSnapshot: favorite.co2e100gSnapshot,
      confidenceBandSnapshot: favorite.confidenceBandSnapshot,
      loggedAt: now,
      logDate: _formatLogDate(now),
    );

    final result = await ref.read(mealEntryProvider.notifier).logFood(draft);
    await ref
        .read(mealEntryRepositoryProvider)
        .touchFavoriteUsage(
          favorite.foodRef,
          favorite.foodRefSource,
          quantity: quantity,
          unit: unit,
        );
    return result;
  }
}

/// Formats [now] as a `yyyy-MM-dd` logical log date, matching
/// `MealEntryRepository.getEntriesForToday`'s existing convention.
String _formatLogDate(DateTime now) =>
    '${now.year.toString().padLeft(4, '0')}-'
    '${now.month.toString().padLeft(2, '0')}-'
    '${now.day.toString().padLeft(2, '0')}';

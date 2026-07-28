import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';

/// Domain contract for meal-entry and favorite persistence.
///
/// Covers both concerns in one cohesive interface — CONTEXT.md treats
/// Recent/Favorites/logging as one connected flow. Implementations live in
/// the data layer (Plan 04-05) and consumers are Riverpod notifiers
/// (Plan 04-07).
abstract interface class IMealEntryRepository {
  /// Inserts a new [MealEntry] row, or merges (adds `quantity`) into an
  /// existing row with the same `foodRef` + `foodRefSource` + `mealSlot` +
  /// `logDate` + `unit`. Returns the resulting persisted row (new or
  /// merged).
  Future<MealEntry> logOrMerge(MealEntry draft);

  /// Returns today's logged entries, excluding soft-deleted rows, ordered
  /// for grouped-by-slot display.
  Future<List<MealEntry>> getEntriesForToday();

  /// Returns up to [limit] individually logged items, deduped by
  /// `foodRef` + `foodRefSource`, most-recent-first.
  Future<List<MealEntry>> getRecent({int limit = 15});

  /// Returns all non-deleted entries logged between [from] and [to]
  /// (inclusive, by logical log date), pooled across days -- powers the
  /// Data Analysis screen's weekly-total (CO2-02) and 7d/30d trend views
  /// (Plan 05-15), which need multi-day aggregation that
  /// [getEntriesForToday]'s single-day scope cannot provide.
  Future<List<MealEntry>> getEntriesInRange(DateTime from, DateTime to);

  /// Updates slot/quantity/unit on an existing row identified by
  /// `updated.id`. Does NOT touch the snapshot fields (snapshot, not
  /// reference — a slot/quantity/unit edit must never silently rewrite
  /// the product data captured at log time).
  Future<MealEntry> editEntry(MealEntry updated);

  /// Soft-deletes (tombstone) the entry identified by [id] and returns the
  /// pre-delete row, used to power the Undo snackbar.
  Future<MealEntry> deleteEntry(String id);

  /// Clears the tombstone on [entry], restoring the exact row. Undo for
  /// [deleteEntry].
  Future<void> restoreEntry(MealEntry entry);

  /// Creates a new row copying [id]'s fields into the same slot. Bypasses
  /// [logOrMerge]'s merge rule entirely — Duplicate must never be a no-op
  /// via accidental merge.
  Future<MealEntry> duplicateEntry(String id);

  /// Subtracts [delta] from `entryId`'s `quantity`. Undo after a merge
  /// restores the pre-merge quantity without deleting the row.
  Future<void> undoMergeDelta(String entryId, double delta);

  /// Whether a food identified by [foodRef] + [foodRefSource] is currently
  /// favorited.
  Future<bool> isFavorite(String foodRef, String foodRefSource);

  /// Toggles favorite status for [draft]'s `foodRef` + `foodRefSource`
  /// (unique constraint): inserts if absent, deletes if present.
  ///
  /// Contract: returns the [Favorite] row that now exists (i.e. the
  /// inserted row when it was newly favorited). When the toggle results in
  /// removal, callers must call [isFavorite] separately to determine the
  /// resulting boolean state — this method's return value alone does not
  /// disambiguate insert-vs-delete outcomes.
  Future<Favorite> toggleFavorite(Favorite draft);

  /// Returns all current favorites.
  Future<List<Favorite>> getFavorites();

  /// Updates `lastQuantity`/`lastUnit` on the favorite identified by
  /// [foodRef] + [foodRefSource] after a one-tap log from Favorites.
  Future<void> touchFavoriteUsage(
    String foodRef,
    String foodRefSource, {
    required double quantity,
    required PortionUnit unit,
  });
}

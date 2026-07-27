import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/meal_entry_dao.dart';
import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:uuid/uuid.dart';

/// Concrete implementation of [IMealEntryRepository], backed by
/// [MealEntryDao].
///
/// This is the orchestration boundary between raw Drift rows
/// (`MealEntryRow`/`FavoriteRow`) and domain entities (`MealEntry`/
/// `Favorite`) — row<->entity mapping lives here (via `MealEntry.fromRow`/
/// `Favorite.fromRow`), not in the DAO, matching `FoodCatalogRepository`'s
/// existing role.
///
/// "Snapshot, not reference" (CONTEXT.md): every method that persists a
/// `MealEntry`/`Favorite` builds the Drift row directly from the
/// already-populated snapshot fields on the incoming domain entity. This
/// repository never re-fetches or re-derives snapshot data from a source
/// `FoodItem`/`UserFood` — that responsibility belongs to the caller (the
/// portion/slot form's notifier, Plan 04-07), which populates the snapshot
/// from the currently-displayed product at the moment "Log this food" is
/// tapped.
///
/// HLC fields use Phase 1 placeholders (matching `FoodCatalogRepository`'s
/// established convention): `hlcNodeId` is `'local'`, `hlcCounter` is `0`.
/// Phase 7 replaces these with full HLC clock logic using a stable device
/// UUID.
final class MealEntryRepository implements IMealEntryRepository {
  /// Creates a [MealEntryRepository] backed by [_dao].
  MealEntryRepository(this._dao);

  final MealEntryDao _dao;

  static const _uuid = Uuid();

  BigInt get _nowHlcMillis =>
      BigInt.from(DateTime.now().millisecondsSinceEpoch);

  @override
  Future<MealEntry> logOrMerge(MealEntry draft) async {
    final id = draft.id.isEmpty ? _uuid.v7() : draft.id;
    final row = MealEntryRow(
      id: id,
      hlcMillis: _nowHlcMillis,
      hlcCounter: 0,
      hlcNodeId: 'local',
      dirty: true,
      mealSlot: draft.mealSlot,
      foodRef: draft.foodRef,
      foodRefSource: draft.foodRefSource,
      quantity: draft.quantity,
      unit: draft.unit,
      productNameSnapshot: draft.productNameSnapshot,
      brandSnapshot: draft.brandSnapshot,
      calories100gSnapshot: draft.calories100gSnapshot,
      protein100gSnapshot: draft.protein100gSnapshot,
      carbs100gSnapshot: draft.carbs100gSnapshot,
      fat100gSnapshot: draft.fat100gSnapshot,
      co2e100gSnapshot: draft.co2e100gSnapshot,
      confidenceBandSnapshot: draft.confidenceBandSnapshot,
      co2MethodologyVersionSnapshot: draft.co2MethodologyVersionSnapshot,
      sugar100gSnapshot: draft.sugar100gSnapshot,
      fiber100gSnapshot: draft.fiber100gSnapshot,
      saltSnapshot: draft.saltSnapshot,
      loggedAt: draft.loggedAt,
      logDate: draft.logDate,
    );
    final result = await _dao.insertOrMerge(draft: row);
    return MealEntry.fromRow(result);
  }

  @override
  Future<List<MealEntry>> getEntriesForToday() async {
    final now = DateTime.now();
    final logDate =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final rows = await _dao.getEntriesForToday(logDate);
    return rows.map(MealEntry.fromRow).toList();
  }

  @override
  Future<List<MealEntry>> getRecent({int limit = 15}) async {
    final rows = await _dao.getRecent(limit: limit);
    return rows.map(MealEntry.fromRow).toList();
  }

  @override
  Future<MealEntry> editEntry(MealEntry updated) async {
    await _dao.updateSlotQuantityUnit(
      id: updated.id,
      mealSlot: updated.mealSlot.name,
      quantity: updated.quantity,
      unit: updated.unit.name,
    );
    final row = await _dao.getById(updated.id);
    if (row == null) {
      throw StateError(
        'MealEntryRow with id=${updated.id} not found after editEntry',
      );
    }
    return MealEntry.fromRow(row);
  }

  @override
  Future<MealEntry> deleteEntry(String id) async {
    final row = await _dao.getById(id);
    if (row == null) {
      throw StateError('MealEntryRow with id=$id not found');
    }
    await _dao.softDelete(id);
    // Returns the pre-delete row so the caller can power an Undo snackbar.
    return MealEntry.fromRow(row);
  }

  @override
  Future<void> restoreEntry(MealEntry entry) => _dao.restore(entry.id);

  @override
  Future<MealEntry> duplicateEntry(String id) async {
    final result = await _dao.duplicate(id, newId: _uuid.v7());
    return MealEntry.fromRow(result);
  }

  @override
  Future<void> undoMergeDelta(String entryId, double delta) =>
      _dao.adjustQuantity(entryId, delta);

  @override
  Future<bool> isFavorite(String foodRef, String foodRefSource) =>
      _dao.isFavorite(foodRef, foodRefSource);

  @override
  Future<Favorite> toggleFavorite(Favorite draft) async {
    final id = draft.id.isEmpty ? _uuid.v7() : draft.id;
    final row = FavoriteRow(
      id: id,
      hlcMillis: _nowHlcMillis,
      hlcCounter: 0,
      hlcNodeId: 'local',
      dirty: true,
      foodRef: draft.foodRef,
      foodRefSource: draft.foodRefSource,
      productNameSnapshot: draft.productNameSnapshot,
      brandSnapshot: draft.brandSnapshot,
      calories100gSnapshot: draft.calories100gSnapshot,
      co2e100gSnapshot: draft.co2e100gSnapshot,
      confidenceBandSnapshot: draft.confidenceBandSnapshot,
      lastQuantity: draft.lastQuantity,
      lastUnit: draft.lastUnit,
      favoritedAt: draft.favoritedAt,
    );
    // `MealEntryDao.toggleFavorite` already performs the presence check
    // internally (insert if absent, delete if present) and returns void.
    // Per this method's documented contract (see
    // `IMealEntryRepository.toggleFavorite`), we return the row we
    // attempted to persist — meaningful as "the newly favorited row" when
    // the toggle inserted, but stale (the just-deleted snapshot) when the
    // toggle deleted. Callers must call `isFavorite` separately to
    // disambiguate insert-vs-delete outcomes.
    await _dao.toggleFavorite(row);
    return Favorite.fromRow(row);
  }

  @override
  Future<List<Favorite>> getFavorites() async {
    final rows = await _dao.getFavorites();
    return rows.map(Favorite.fromRow).toList();
  }

  @override
  Future<void> touchFavoriteUsage(
    String foodRef,
    String foodRefSource, {
    required double quantity,
    required PortionUnit unit,
  }) => _dao.touchFavoriteUsage(
    foodRef,
    foodRefSource,
    quantity: quantity,
    unit: unit.name,
  );
}

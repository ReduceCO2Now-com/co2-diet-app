import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/tables/favorite_table.dart';
import 'package:co2diet/data/local/tables/meal_entry_table.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

part 'meal_entry_dao.g.dart';

/// DAO covering [MealEntryTable] (logged meal entries) and [FavoriteTable]
/// (favorited foods) — one DAO for both closely related tables, following
/// the `FoodCatalogDao` precedent of a single DAO owning multiple tables
/// that are always queried/mutated together in the same feature area.
///
/// T-04-04-01 mitigation: every query below uses `Variable.withString`/
/// `Variable.withReal` parameterized `customSelect`/`customUpdate`, or a
/// typed Drift Companion insert — never string interpolation of
/// `foodRef`, `productNameSnapshot`, `brandSnapshot`, or any other
/// free-text value.
@DriftAccessor(tables: [MealEntryTable, FavoriteTable])
class MealEntryDao extends DatabaseAccessor<AppDatabase>
    with _$MealEntryDaoMixin {
  /// Creates a [MealEntryDao] bound to [attachedDatabase].
  MealEntryDao(super.attachedDatabase);

  // ---------------------------------------------------------------------
  // Meal entries
  // ---------------------------------------------------------------------

  /// Inserts [draft] as a new logged entry, or merges it into an existing
  /// row when one already exists for the same
  /// `(foodRef, foodRefSource, mealSlot, logDate, unit)` tuple.
  ///
  /// Merge-check uses `log_date` string equality (RESEARCH.md Pattern 3) —
  /// never a SQL date function. A different [MealEntryRow.unit] for the
  /// same food+slot+day is intentionally treated as a separate row (no
  /// merge across units).
  Future<MealEntryRow> insertOrMerge({required MealEntryRow draft}) async {
    try {
      final existingRows = await customSelect(
        'SELECT * FROM meal_entry_table '
        'WHERE food_ref = ? AND food_ref_source = ? AND meal_slot = ? '
        'AND log_date = ? AND unit = ? AND deleted_at IS NULL',
        variables: [
          Variable.withString(draft.foodRef),
          Variable.withString(draft.foodRefSource),
          Variable.withString(draft.mealSlot.name),
          Variable.withString(draft.logDate),
          Variable.withString(draft.unit.name),
        ],
        readsFrom: {mealEntryTable},
      ).get();

      if (existingRows.isNotEmpty) {
        final existing = mealEntryTable.map(existingRows.first.data);
        await customUpdate(
          'UPDATE meal_entry_table SET quantity = quantity + ?, dirty = 1 '
          'WHERE id = ?',
          variables: [
            Variable.withReal(draft.quantity),
            Variable.withString(existing.id),
          ],
          updates: {mealEntryTable},
        );
        final updatedRows = await customSelect(
          'SELECT * FROM meal_entry_table WHERE id = ?',
          variables: [Variable.withString(existing.id)],
          readsFrom: {mealEntryTable},
        ).get();
        return mealEntryTable.map(updatedRows.first.data);
      }

      return into(mealEntryTable).insertReturning(draft.toCompanion(false));
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] insertOrMerge error: $e');
      rethrow;
    }
  }

  /// Returns every non-deleted entry ever logged, ordered oldest-first.
  ///
  /// Added for `BackupExportService`'s full-data export/backup
  /// (PRIV-01/02) — Phase 4 only needed day-scoped ([getEntriesForToday])
  /// and recency-scoped ([getRecent]) reads.
  Future<List<MealEntryRow>> getAllEntries() async {
    try {
      final rows = await customSelect(
        'SELECT * FROM meal_entry_table '
        'WHERE deleted_at IS NULL ORDER BY logged_at ASC',
        readsFrom: {mealEntryTable},
      ).get();
      return rows.map((row) => mealEntryTable.map(row.data)).toList();
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] getAllEntries error: $e');
      rethrow;
    }
  }

  /// Bulk-restores [rows] verbatim (insert-or-update on PK), for
  /// `BackupExportService.applyRestore`.
  ///
  /// Unlike [insertOrMerge], this never merges quantities across
  /// matching entries — a restore re-creates exactly the rows a prior
  /// export/backup captured, byte-for-byte.
  Future<void> restoreEntries(List<MealEntryRow> rows) async {
    if (rows.isEmpty) return;
    try {
      await batch((b) {
        b.insertAllOnConflictUpdate(
          mealEntryTable,
          rows.map((r) => r.toCompanion(false)).toList(),
        );
      });
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] restoreEntries error: $e');
      rethrow;
    }
  }

  /// Bulk-restores [rows] verbatim (insert-or-update on PK), for
  /// `BackupExportService.applyRestore`.
  Future<void> restoreFavorites(List<FavoriteRow> rows) async {
    if (rows.isEmpty) return;
    try {
      await batch((b) {
        b.insertAllOnConflictUpdate(
          favoriteTable,
          rows.map((r) => r.toCompanion(false)).toList(),
        );
      });
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] restoreFavorites error: $e');
      rethrow;
    }
  }

  /// Returns all non-deleted entries logged for [logDate], ordered by
  /// meal slot then logged-at time.
  Future<List<MealEntryRow>> getEntriesForToday(String logDate) async {
    try {
      final rows = await customSelect(
        'SELECT * FROM meal_entry_table '
        'WHERE log_date = ? AND deleted_at IS NULL '
        'ORDER BY meal_slot, logged_at',
        variables: [Variable.withString(logDate)],
        readsFrom: {mealEntryTable},
      ).get();
      return rows.map((row) => mealEntryTable.map(row.data)).toList();
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] getEntriesForToday error: $e');
      rethrow;
    }
  }

  /// Returns up to [limit] most-recently-logged entries, deduped by
  /// `(food_ref, food_ref_source)` — the SQLite "bare column in aggregate
  /// query" idiom selects the full row belonging to the max `logged_at`
  /// per group.
  Future<List<MealEntryRow>> getRecent({int limit = 15}) async {
    try {
      final rows = await customSelect(
        'SELECT *, MAX(logged_at) FROM meal_entry_table '
        'WHERE deleted_at IS NULL '
        'GROUP BY food_ref, food_ref_source '
        'ORDER BY MAX(logged_at) DESC '
        'LIMIT ?',
        variables: [Variable.withInt(limit)],
        readsFrom: {mealEntryTable},
      ).get();
      return rows.map((row) => mealEntryTable.map(row.data)).toList();
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] getRecent error: $e');
      rethrow;
    }
  }

  /// Returns the entry with [id], or null if none exists.
  Future<MealEntryRow?> getById(String id) =>
      (select(mealEntryTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Updates the meal slot, quantity, and unit of the entry with [id]
  /// (LOG-09 edit). Deliberately does not touch any `*Snapshot` column —
  /// editing an entry never re-derives nutrition/CO2 data.
  Future<void> updateSlotQuantityUnit({
    required String id,
    required String mealSlot,
    required double quantity,
    required String unit,
  }) async {
    try {
      await customUpdate(
        'UPDATE meal_entry_table '
        'SET meal_slot = ?, quantity = ?, unit = ?, dirty = 1 '
        'WHERE id = ?',
        variables: [
          Variable.withString(mealSlot),
          Variable.withReal(quantity),
          Variable.withString(unit),
          Variable.withString(id),
        ],
        updates: {mealEntryTable},
      );
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] updateSlotQuantityUnit error: $e');
      rethrow;
    }
  }

  /// Soft-deletes the entry with [id] by setting `deleted_at`.
  Future<void> softDelete(String id) async {
    try {
      await customUpdate(
        'UPDATE meal_entry_table SET deleted_at = ? WHERE id = ?',
        variables: [
          Variable.withDateTime(DateTime.now()),
          Variable.withString(id),
        ],
        updates: {mealEntryTable},
      );
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] softDelete error: $e');
      rethrow;
    }
  }

  /// Clears the `deleted_at` tombstone on the entry with [id], restoring
  /// it to the live (non-deleted) state.
  Future<void> restore(String id) async {
    try {
      await customUpdate(
        'UPDATE meal_entry_table SET deleted_at = NULL WHERE id = ?',
        variables: [Variable.withString(id)],
        updates: {mealEntryTable},
      );
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] restore error: $e');
      rethrow;
    }
  }

  /// Subtracts [delta] from the quantity of the entry with [id]
  /// (undo-merge — the inverse of the delta applied by [insertOrMerge]).
  Future<void> adjustQuantity(String id, double delta) async {
    try {
      await customUpdate(
        'UPDATE meal_entry_table SET quantity = quantity - ?, dirty = 1 '
        'WHERE id = ?',
        variables: [Variable.withReal(delta), Variable.withString(id)],
        updates: {mealEntryTable},
      );
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] adjustQuantity error: $e');
      rethrow;
    }
  }

  /// Reads the entry with [id] and inserts a new row with [newId],
  /// copying every other field verbatim. Bypasses [insertOrMerge] entirely
  /// — a duplicated entry is always its own row, never merged into an
  /// existing one.
  Future<MealEntryRow> duplicate(String id, {required String newId}) async {
    try {
      final original = await getById(id);
      if (original == null) {
        throw ArgumentError('No MealEntryRow found for id=$id');
      }
      final companion = original.toCompanion(false).copyWith(id: Value(newId));
      return into(mealEntryTable).insertReturning(companion);
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] duplicate error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------
  // Favorites
  // ---------------------------------------------------------------------

  /// Looks up an existing favorite row for [foodRef]/[foodRefSource], or
  /// null if the food is not currently favorited.
  Future<FavoriteRow?> _findFavorite(
    String foodRef,
    String foodRefSource,
  ) async {
    final rows = await customSelect(
      'SELECT * FROM favorite_table '
      'WHERE food_ref = ? AND food_ref_source = ?',
      variables: [
        Variable.withString(foodRef),
        Variable.withString(foodRefSource),
      ],
      readsFrom: {favoriteTable},
    ).get();
    if (rows.isEmpty) return null;
    return favoriteTable.map(rows.first.data);
  }

  /// Toggles the favorite state of [draft]'s `(foodRef, foodRefSource)`
  /// pair: inserts a new favorite row if none exists, or deletes the
  /// existing one. The `UNIQUE(food_ref, food_ref_source)` constraint
  /// (Plan 04-02) backs the "one favorite row per food" invariant.
  Future<void> toggleFavorite(FavoriteRow draft) async {
    try {
      final existing = await _findFavorite(draft.foodRef, draft.foodRefSource);
      if (existing != null) {
        await customUpdate(
          'DELETE FROM favorite_table '
          'WHERE food_ref = ? AND food_ref_source = ?',
          variables: [
            Variable.withString(draft.foodRef),
            Variable.withString(draft.foodRefSource),
          ],
          updates: {favoriteTable},
        );
      } else {
        await into(favoriteTable).insert(draft.toCompanion(false));
      }
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] toggleFavorite error: $e');
      rethrow;
    }
  }

  /// Returns whether [foodRef]/[foodRefSource] is currently favorited.
  Future<bool> isFavorite(String foodRef, String foodRefSource) async {
    final existing = await _findFavorite(foodRef, foodRefSource);
    return existing != null;
  }

  /// Returns all favorited foods, most-recently-favorited first.
  Future<List<FavoriteRow>> getFavorites() async {
    try {
      final rows = await customSelect(
        'SELECT * FROM favorite_table ORDER BY favorited_at DESC',
        readsFrom: {favoriteTable},
      ).get();
      return rows.map((row) => favoriteTable.map(row.data)).toList();
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] getFavorites error: $e');
      rethrow;
    }
  }

  /// Updates the one-tap-log defaults (`last_quantity`/`last_unit`) for the
  /// favorite matching [foodRef]/[foodRefSource].
  Future<void> touchFavoriteUsage(
    String foodRef,
    String foodRefSource, {
    required double quantity,
    required String unit,
  }) async {
    try {
      await customUpdate(
        'UPDATE favorite_table SET last_quantity = ?, last_unit = ? '
        'WHERE food_ref = ? AND food_ref_source = ?',
        variables: [
          Variable.withReal(quantity),
          Variable.withString(unit),
          Variable.withString(foodRef),
          Variable.withString(foodRefSource),
        ],
        updates: {favoriteTable},
      );
    } on Exception catch (e) {
      debugPrint('[MealEntryDao] touchFavoriteUsage error: $e');
      rethrow;
    }
  }
}

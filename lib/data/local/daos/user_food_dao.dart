import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/tables/user_food_table.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

part 'user_food_dao.g.dart';

/// DAO for [UserFoodTable] — custom foods and personal overrides
/// (LOG-10/LOG-11).
///
/// T-04-04-01 mitigation: every raw query uses `Variable.withString`
/// parameterization — never string interpolation of `name`, `brand`,
/// `category`, or any other free-text field.
///
/// T-04-04-02 mitigation: `insert` guards against missing `name`/`calories`
/// at the DAO boundary — defense in depth beyond the domain-layer
/// `UserFood.isValid` check, in case a caller bypasses the domain layer.
@DriftAccessor(tables: [UserFoodTable])
class UserFoodDao extends DatabaseAccessor<AppDatabase>
    with _$UserFoodDaoMixin {
  /// Creates a [UserFoodDao] bound to [attachedDatabase].
  UserFoodDao(super.attachedDatabase);

  /// Inserts [draft] as a new custom food or override row.
  ///
  /// Throws an `ArgumentError` when `name` is absent/blank or `calories`
  /// is absent — required fields per LOG-10 ("name + at least a calorie
  /// value are required to save"). `Value<T>.value` throws a `TypeError`
  /// when the field is absent for a non-nullable column type, so
  /// `.present` is checked first rather than comparing `.value` directly
  /// to `null`.
  Future<UserFoodRow> insert(UserFoodTableCompanion draft) async {
    if (!draft.name.present ||
        draft.name.value.trim().isEmpty ||
        !draft.calories.present) {
      throw ArgumentError('UserFood requires a name and a calorie value');
    }
    try {
      return await into(userFoodTable).insertReturning(draft);
    } on Exception catch (e) {
      debugPrint('[UserFoodDao] insert error: $e');
      rethrow;
    }
  }

  /// Applies [changes] to the row with [id] and returns the updated row.
  ///
  /// Named `updateFood` (not `update`) — `DatabaseAccessor` already
  /// declares a generic `update` method for its typed update-statement
  /// builder, and a same-named method with an incompatible signature is
  /// an invalid override, not a harmless shadow.
  Future<UserFoodRow> updateFood(
    String id,
    UserFoodTableCompanion changes,
  ) async {
    try {
      await (update(userFoodTable)..where((t) => t.id.equals(id)))
          .write(changes);
      final row = await getById(id);
      if (row == null) {
        throw StateError('UserFoodRow with id=$id not found after update');
      }
      return row;
    } on Exception catch (e) {
      debugPrint('[UserFoodDao] updateFood error: $e');
      rethrow;
    }
  }

  /// Returns the row with [id], or null if none exists.
  Future<UserFoodRow?> getById(String id) =>
      (select(userFoodTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Returns the override row for [foodRef]/[foodRefSource], or null if
  /// the catalog/cache food has no personal override.
  Future<UserFoodRow?> findOverrideByFoodRef(
    String foodRef,
    String foodRefSource,
  ) async {
    try {
      final rows = await customSelect(
        'SELECT * FROM user_food_table '
        'WHERE override_of_ref = ? AND override_of_source = ? '
        'AND deleted_at IS NULL '
        'LIMIT 1',
        variables: [
          Variable.withString(foodRef),
          Variable.withString(foodRefSource),
        ],
        readsFrom: {userFoodTable},
      ).get();
      if (rows.isEmpty) return null;
      return userFoodTable.map(rows.first.data);
    } on Exception catch (e) {
      debugPrint('[UserFoodDao] findOverrideByFoodRef error: $e');
      rethrow;
    }
  }

  /// Hard-deletes the override row with [id].
  ///
  /// Deliberate deviation from the `SyncSafeTable` soft-delete convention
  /// (T-04-04-03, accepted risk): CONTEXT.md requires the original
  /// catalog/cache food to reappear in search immediately when an
  /// override is reverted, which a `deletedAt` tombstone would not
  /// satisfy — a lingering tombstone row would still need to be filtered
  /// out of every read path. This is a real `DELETE`, not a soft delete.
  /// Flagged for Phase 7: hard deletes on this table will need their own
  /// sync propagation mechanism, since there is no dirty/tombstone row
  /// left behind to carry the deletion to other devices.
  Future<void> revert(String id) async {
    try {
      await customUpdate(
        'DELETE FROM user_food_table WHERE id = ?',
        variables: [Variable.withString(id)],
        updates: {userFoodTable},
      );
    } on Exception catch (e) {
      debugPrint('[UserFoodDao] revert error: $e');
      rethrow;
    }
  }

  /// Bulk-restores [rows] verbatim (insert-or-update on PK), for
  /// `BackupExportService.applyRestore`.
  ///
  /// Deliberately bypasses [insert]'s required-field guard — a row
  /// captured by a prior export/backup already satisfied that guard once,
  /// and re-validating would only reject a restore that would otherwise
  /// succeed if any field happened to be legitimately blank at export
  /// time (never the case for `name`/`calories`, but this keeps restore
  /// a pure verbatim reconstruction rather than a second validation
  /// pass).
  Future<void> restoreCustomFoods(List<UserFoodRow> rows) async {
    if (rows.isEmpty) return;
    try {
      await batch((b) {
        b.insertAllOnConflictUpdate(
          userFoodTable,
          rows.map((r) => r.toCompanion(false)).toList(),
        );
      });
    } on Exception catch (e) {
      debugPrint('[UserFoodDao] restoreCustomFoods error: $e');
      rethrow;
    }
  }

  /// Returns all non-deleted rows sorted alphabetically by `name`
  /// (case-insensitive), optionally filtered to names containing
  /// [filter] (also case-insensitive).
  Future<List<UserFoodRow>> getAllAlphabetical({String? filter}) async {
    try {
      final filterVariable = Variable<String>(filter);
      final rows = await customSelect(
        'SELECT * FROM user_food_table '
        'WHERE deleted_at IS NULL '
        "AND (? IS NULL OR LOWER(name) LIKE '%' || LOWER(?) || '%') "
        'ORDER BY name COLLATE NOCASE',
        variables: [filterVariable, filterVariable],
        readsFrom: {userFoodTable},
      ).get();
      return rows.map((row) => userFoodTable.map(row.data)).toList();
    } on Exception catch (e) {
      debugPrint('[UserFoodDao] getAllAlphabetical error: $e');
      rethrow;
    }
  }
}

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/tables/weight_entry_table.dart';
import 'package:co2diet/data/local/tables/weight_settings_table.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

part 'weight_dao.g.dart';

/// DAO covering [WeightEntryTable] (logged weigh-ins, WT-01) and
/// [WeightSettingsTable] (goal + reminder config, WT-03/WT-04) — one DAO
/// for both closely related tables, following the `MealEntryDao`
/// precedent of a single DAO owning multiple tables that are always
/// queried/mutated together in the same feature area.
///
/// T-05-05-01 mitigation: [getEntriesInRange] uses
/// `Variable.withDateTime`/nullable `Variable<DateTime>` parameterized
/// `customSelect` — never string interpolation of the date bounds,
/// mirroring `UserFoodDao.getAllAlphabetical`'s nullable-parameter idiom
/// (T-04-04-01 precedent).
@DriftAccessor(tables: [WeightEntryTable, WeightSettingsTable])
class WeightDao extends DatabaseAccessor<AppDatabase> with _$WeightDaoMixin {
  /// Creates a [WeightDao] bound to [attachedDatabase].
  WeightDao(super.attachedDatabase);

  // ---------------------------------------------------------------------
  // Weight entries
  // ---------------------------------------------------------------------

  /// Inserts [draft] as a new logged weigh-in (WT-01).
  Future<WeightEntryRow> logWeight(WeightEntryTableCompanion draft) =>
      into(weightEntryTable).insertReturning(draft);

  /// Returns all non-deleted weigh-ins with `logged_at` within
  /// `[from, to]` inclusive, ordered oldest-first.
  ///
  /// A null [from]/[to] leaves that bound unconstrained; both null
  /// returns the full "all-time" set. Callers compute the concrete
  /// 7d/30d/90d/1yr/all bounds (WT-02) via `DateTime.now().subtract(...)`
  /// — this method is not itself aware of named ranges.
  Future<List<WeightEntryRow>> getEntriesInRange({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final fromVariable = Variable<DateTime>(from);
      final toVariable = Variable<DateTime>(to);
      final rows = await customSelect(
        'SELECT * FROM weight_entry_table '
        'WHERE deleted_at IS NULL '
        'AND (? IS NULL OR logged_at >= ?) '
        'AND (? IS NULL OR logged_at <= ?) '
        'ORDER BY logged_at ASC',
        variables: [
          fromVariable,
          fromVariable,
          toVariable,
          toVariable,
        ],
        readsFrom: {weightEntryTable},
      ).get();
      return rows.map((row) => weightEntryTable.map(row.data)).toList();
    } on Exception catch (e) {
      debugPrint('[WeightDao] getEntriesInRange error: $e');
      rethrow;
    }
  }

  /// Bulk-restores [rows] verbatim (insert-or-update on PK), for
  /// `BackupExportService.applyRestore`.
  Future<void> restoreEntries(List<WeightEntryRow> rows) async {
    if (rows.isEmpty) return;
    try {
      await batch((b) {
        b.insertAllOnConflictUpdate(
          weightEntryTable,
          rows.map((r) => r.toCompanion(false)).toList(),
        );
      });
    } on Exception catch (e) {
      debugPrint('[WeightDao] restoreEntries error: $e');
      rethrow;
    }
  }

  /// Hard-deletes the weigh-in with [id].
  ///
  /// Deviation from the `SyncSafeTable` soft-delete convention: a
  /// mis-logged weigh-in has no sync-relevant tombstone need distinct
  /// from `UserFoodDao.revert`'s existing hard-delete precedent
  /// [Phase 04-04].
  Future<void> deleteEntry(String id) =>
      (delete(weightEntryTable)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------
  // Weight settings (goal + reminder config)
  // ---------------------------------------------------------------------

  /// Returns the single settings row, or null if none exists yet
  /// (WT-03/WT-04).
  Future<WeightSettingsRow?> getSettings() =>
      (select(weightSettingsTable)..limit(1)).getSingleOrNull();

  /// Upserts the settings row (insert or update on PK conflict).
  ///
  /// This is the only settings write method. The single-row invariant
  /// is enforced by always using the same stable UUID v7 as the entry
  /// id value.
  Future<void> saveSettings(WeightSettingsTableCompanion entry) =>
      into(weightSettingsTable).insertOnConflictUpdate(entry);
}

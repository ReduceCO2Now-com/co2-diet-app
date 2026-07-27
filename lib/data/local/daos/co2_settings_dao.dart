import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/tables/co2_settings_table.dart';
import 'package:drift/drift.dart';

part 'co2_settings_dao.g.dart';

/// DAO for the single-row [Co2SettingsTable] (CO2-03).
///
/// Enforces the single-row constraint via [upsertSettings], which uses
/// insertOnConflictUpdate on the UUID v7 primary key. Callers must
/// always provide the same stable ID for the settings row, mirroring
/// `UserProfileDao`'s established single-row pattern.
@DriftAccessor(tables: [Co2SettingsTable])
class Co2SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$Co2SettingsDaoMixin {
  /// Creates a [Co2SettingsDao] bound to [attachedDatabase].
  Co2SettingsDao(super.attachedDatabase);

  /// Returns the single settings row, or null if none exists yet.
  Future<Co2SettingsRow?> getSettings() =>
      (select(co2SettingsTable)..limit(1)).getSingleOrNull();

  /// Upserts the settings row (insert or update on PK conflict).
  ///
  /// This is the only write method. The single-row invariant is
  /// enforced by always using the same stable UUID v7 as the entry
  /// id value.
  Future<void> upsertSettings(Co2SettingsTableCompanion entry) =>
      into(co2SettingsTable).insertOnConflictUpdate(entry);
}

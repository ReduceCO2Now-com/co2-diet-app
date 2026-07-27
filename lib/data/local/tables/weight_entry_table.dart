import 'package:co2diet/data/local/mixins/sync_safe_table.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:drift/drift.dart';

/// Drift table for logged weigh-in entries (WT-01) using the
/// [SyncSafeTable] mixin.
///
/// One row per logged weigh-in — this is a log table, not a
/// singleton, matching `MealEntryTable`'s per-entry style rather than
/// `UserProfileTable`'s single-row style.
@DataClassName('WeightEntryRow')
class WeightEntryTable extends Table with SyncSafeTable {
  /// The logged weight value, expressed in [unit].
  Column<double> get value => real()();

  /// Unit [value] is expressed in. Stored via `textEnum` as
  /// `Enum.name` — append-only, see [WeightUnit].
  Column<String> get unit => textEnum<WeightUnit>()();

  /// Wall-clock timestamp of when this weigh-in was logged.
  Column<DateTime> get loggedAt => dateTime()();

  /// Optional free-text note attached to this weigh-in.
  Column<String> get note => text().nullable()();
}

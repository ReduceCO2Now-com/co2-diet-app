import 'package:co2diet/data/local/mixins/sync_safe_table.dart';
import 'package:drift/drift.dart';

/// Single-row table storing the user's weight goal + weigh-in
/// reminder configuration (WT-03/WT-04).
///
/// All sync-safe columns (id, hlcMillis, hlcCounter, hlcNodeId,
/// dirty, deletedAt) are injected by the [SyncSafeTable] mixin. A
/// later plan's DAO enforces the single-row constraint via upsert on
/// the 'id' PK, mirroring UserProfileTable's pattern.
///
/// No "on pace"/projection value is ever derived from
/// [targetWeightKg]/[targetDate] — CONTEXT.md explicitly rejects
/// that; this table stores only the goal value and the
/// chart-rendering layer draws a static reference line from it.
@DataClassName('WeightSettingsRow')
class WeightSettingsTable extends Table with SyncSafeTable {
  /// Target weight in kilograms. Always stored in kg; imperial
  /// conversion is an app-layer concern (mirrors
  /// `UserProfileTable.weightKg`'s existing convention).
  Column<double> get targetWeightKg => real().nullable()();

  /// Target date for reaching [targetWeightKg].
  Column<DateTime> get targetDate => dateTime().nullable()();

  /// How often the user wants a weigh-in reminder.
  /// Values: 'never', 'weekly', 'biweekly', 'monthly', 'custom'.
  Column<String> get reminderFrequency => text().nullable()();

  /// Day of week the reminder fires on, 1 (Monday) to 7 (Sunday),
  /// ISO-8601 weekday numbering. Only meaningful when
  /// [reminderFrequency] is `'custom'`.
  Column<int> get reminderWeekday => integer().nullable()();

  /// Local time the reminder fires at, `'HH:mm'` 24-hour string.
  Column<String> get reminderTime => text().nullable()();

  /// Whether the weigh-in reminder is enabled.
  Column<bool> get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
}

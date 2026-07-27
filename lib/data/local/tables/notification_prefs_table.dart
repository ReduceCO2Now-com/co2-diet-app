import 'package:co2diet/data/local/mixins/sync_safe_table.dart';
import 'package:drift/drift.dart';

/// Single-row table storing per-meal-slot reminder configuration
/// (NOTIF-01).
///
/// All sync-safe columns (id, hlcMillis, hlcCounter, hlcNodeId,
/// dirty, deletedAt) are injected by the [SyncSafeTable] mixin. A
/// later plan's DAO enforces the single-row constraint via upsert on
/// the 'id' PK, mirroring UserProfileTable's pattern.
///
/// One enabled+time pair per meal slot (breakfast/lunch/dinner/snack).
@DataClassName('NotificationPrefsRow')
class NotificationPrefsTable extends Table with SyncSafeTable {
  /// Whether the breakfast reminder is enabled.
  Column<bool> get breakfastEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Local time the breakfast reminder fires at, `'HH:mm'`.
  Column<String> get breakfastTime => text().nullable()();

  /// Whether the lunch reminder is enabled.
  Column<bool> get lunchEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Local time the lunch reminder fires at, `'HH:mm'`.
  Column<String> get lunchTime => text().nullable()();

  /// Whether the dinner reminder is enabled.
  Column<bool> get dinnerEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Local time the dinner reminder fires at, `'HH:mm'`.
  Column<String> get dinnerTime => text().nullable()();

  /// Whether the snack reminder is enabled.
  Column<bool> get snackEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Local time the snack reminder fires at, `'HH:mm'`.
  Column<String> get snackTime => text().nullable()();
}

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/notification_prefs_dao.dart';
import 'package:co2diet/domain/entities/notification_prefs.dart';
import 'package:co2diet/domain/repositories/i_notification_prefs_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Concrete data-layer implementation of [INotificationPrefsRepository].
///
/// Backed by [NotificationPrefsDao] (Drift). All Drift and SQLite imports
/// are intentionally confined to this file — the domain layer and UI layer
/// MUST NOT import package:drift directly.
///
/// HLC fields use Phase-1 placeholder values, matching every other
/// Phase 1-4/5 repository:
///   - `hlcNodeId` is `'local'` (Phase 7 replaces with stable device UUID)
///   - `hlcCounter` is `0` (Phase 7 implements full HLC increment logic)
final class NotificationPrefsRepository
    implements INotificationPrefsRepository {
  /// Creates a [NotificationPrefsRepository] backed by the given DAO.
  const NotificationPrefsRepository(this._dao);

  final NotificationPrefsDao _dao;
  static const _uuid = Uuid();

  @override
  Future<NotificationPrefs> getPrefs() async {
    final row = await _dao.getPrefs();
    if (row == null) return const NotificationPrefs();

    return NotificationPrefs(
      breakfastEnabled: row.breakfastEnabled,
      breakfastTime: row.breakfastTime,
      lunchEnabled: row.lunchEnabled,
      lunchTime: row.lunchTime,
      dinnerEnabled: row.dinnerEnabled,
      dinnerTime: row.dinnerTime,
      snackEnabled: row.snackEnabled,
      snackTime: row.snackTime,
    );
  }

  @override
  Future<void> savePrefs(NotificationPrefs prefs) async {
    // Reuse the existing single row's id if present; otherwise generate a
    // fresh UUID v7 for the first-ever save (mirrors Co2SettingsRepository's
    // single-row-id convention).
    final existing = await _dao.getPrefs();
    final id = existing?.id ?? _uuid.v7();

    final companion = NotificationPrefsTableCompanion(
      id: Value(id),
      breakfastEnabled: Value(prefs.breakfastEnabled),
      breakfastTime: Value(prefs.breakfastTime),
      lunchEnabled: Value(prefs.lunchEnabled),
      lunchTime: Value(prefs.lunchTime),
      dinnerEnabled: Value(prefs.dinnerEnabled),
      dinnerTime: Value(prefs.dinnerTime),
      snackEnabled: Value(prefs.snackEnabled),
      snackTime: Value(prefs.snackTime),
      // HLC Phase-1 placeholders — Phase 7 replaces with full HLC clock.
      hlcMillis: Value(BigInt.from(DateTime.now().millisecondsSinceEpoch)),
      hlcCounter: const Value(0),
      hlcNodeId: const Value('local'),
      dirty: const Value(true),
    );

    await _dao.savePrefs(companion);
  }
}

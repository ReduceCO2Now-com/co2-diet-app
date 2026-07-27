import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/tables/notification_prefs_table.dart';
import 'package:drift/drift.dart';

part 'notification_prefs_dao.g.dart';

/// DAO for the single-row [NotificationPrefsTable] (NOTIF-01).
///
/// Enforces the single-row constraint via [savePrefs], which uses
/// insertOnConflictUpdate on the UUID v7 primary key. Callers must
/// always provide the same stable ID for the prefs row, mirroring
/// `UserProfileDao`'s established single-row pattern.
@DriftAccessor(tables: [NotificationPrefsTable])
class NotificationPrefsDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationPrefsDaoMixin {
  /// Creates a [NotificationPrefsDao] bound to [attachedDatabase].
  NotificationPrefsDao(super.attachedDatabase);

  /// Returns the single prefs row, or null if none exists yet.
  Future<NotificationPrefsRow?> getPrefs() =>
      (select(notificationPrefsTable)..limit(1)).getSingleOrNull();

  /// Upserts the prefs row (insert or update on PK conflict).
  ///
  /// This is the only write method. The single-row invariant is
  /// enforced by always using the same stable UUID v7 as the entry
  /// id value.
  Future<void> savePrefs(NotificationPrefsTableCompanion entry) =>
      into(notificationPrefsTable).insertOnConflictUpdate(entry);
}

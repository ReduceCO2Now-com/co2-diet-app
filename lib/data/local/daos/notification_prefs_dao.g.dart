// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_prefs_dao.dart';

// ignore_for_file: type=lint
mixin _$NotificationPrefsDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotificationPrefsTableTable get notificationPrefsTable =>
      attachedDatabase.notificationPrefsTable;
  NotificationPrefsDaoManager get managers => NotificationPrefsDaoManager(this);
}

class NotificationPrefsDaoManager {
  final _$NotificationPrefsDaoMixin _db;
  NotificationPrefsDaoManager(this._db);
  $$NotificationPrefsTableTableTableManager get notificationPrefsTable =>
      $$NotificationPrefsTableTableTableManager(
        _db.attachedDatabase,
        _db.notificationPrefsTable,
      );
}

// Notification DI providers: NotificationPrefsDao,
// INotificationPrefsRepository, NotificationService.
//
// Kept in a separate file (mirrors co2_settings_providers.dart) to keep
// providers.dart focused on core infrastructure (AppDatabase, profile).

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/daos/notification_prefs_dao.dart';
import 'package:co2diet/data/repositories/notification_prefs_repository.dart';
import 'package:co2diet/domain/repositories/i_notification_prefs_repository.dart';
import 'package:co2diet/domain/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

/// Provides the [NotificationPrefsDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [notificationPrefsRepositoryProvider] which
/// is also keep-alive.
@Riverpod(keepAlive: true)
NotificationPrefsDao notificationPrefsDao(Ref ref) {
  return ref.watch(appDatabaseProvider).notificationPrefsDao;
}

/// Provides the [INotificationPrefsRepository] for the Notification Settings
/// feature.
///
/// The declared return type is the abstract [INotificationPrefsRepository]
/// interface — callers in the presentation layer depend only on the
/// interface, not on [NotificationPrefsRepository].
@Riverpod(keepAlive: true)
INotificationPrefsRepository notificationPrefsRepository(Ref ref) {
  return NotificationPrefsRepository(ref.watch(notificationPrefsDaoProvider));
}

/// Provides the single authoritative [NotificationService] instance.
///
/// keepAlive: true — the service wraps a live [FlutterLocalNotificationsPlugin]
/// registration (`onDidReceiveNotificationResponse` is set once via
/// `initialize()` in `main.dart`) and must persist for the full app
/// lifetime. This is the ONE place `NotificationService` is constructed —
/// every later plan (05-13, 05-14, 05-18) consumes it via
/// `ref.read(notificationServiceProvider)` / `ref.watch(...)`; none of them
/// may declare a competing provider for it.
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService(FlutterLocalNotificationsPlugin());
}

import 'package:co2diet/domain/entities/notification_prefs.dart';

/// Abstract interface for persisting and retrieving the user's per-meal-slot
/// reminder configuration (NOTIF-01).
///
/// Implementations live in the data layer and may use Drift (local SQLite)
/// or any other storage backend. The domain layer depends only on this
/// interface, ensuring zero framework coupling.
abstract interface class INotificationPrefsRepository {
  /// Returns the current [NotificationPrefs], or an all-disabled default
  /// when no prefs have ever been saved.
  Future<NotificationPrefs> getPrefs();

  /// Persists [prefs] to storage (upsert semantics, single-row table).
  Future<void> savePrefs(NotificationPrefs prefs);
}

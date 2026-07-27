import 'package:co2diet/domain/entities/co2_settings.dart';

/// Abstract interface for persisting and retrieving the user's personal-
/// footprint CO2 settings (CO2-03).
///
/// Implementations live in the data layer and may use Drift (local SQLite)
/// or any other storage backend. The domain layer depends only on this
/// interface, ensuring zero framework coupling.
///
/// This is a strictly separate layer from any food's own CO2 data — an
/// implementation MUST NOT read or write any `MealEntryTable`/`UserFood`
/// row.
abstract interface class ICo2SettingsRepository {
  /// Returns the current [Co2Settings], or an all-null default when no
  /// settings have ever been saved.
  Future<Co2Settings> getSettings();

  /// Persists [settings] to storage (upsert semantics, single-row table).
  Future<void> saveSettings(Co2Settings settings);
}

// CO2 Settings DI providers: Co2SettingsDao, ICo2SettingsRepository.
//
// Kept in a separate file (mirrors meal_logging_providers.dart) to keep
// providers.dart focused on core infrastructure (AppDatabase, profile).

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/daos/co2_settings_dao.dart';
import 'package:co2diet/data/repositories/co2_settings_repository.dart';
import 'package:co2diet/domain/repositories/i_co2_settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'co2_settings_providers.g.dart';

/// Provides the [Co2SettingsDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [co2SettingsRepositoryProvider] which is
/// also keep-alive.
@Riverpod(keepAlive: true)
Co2SettingsDao co2SettingsDao(Ref ref) {
  return ref.watch(appDatabaseProvider).co2SettingsDao;
}

/// Provides the [ICo2SettingsRepository] for the CO2 Settings feature.
///
/// The declared return type is the abstract [ICo2SettingsRepository]
/// interface — callers in the presentation layer (notifiers, Plan 05-12)
/// depend only on the interface, not on [Co2SettingsRepository].
@Riverpod(keepAlive: true)
ICo2SettingsRepository co2SettingsRepository(Ref ref) {
  return Co2SettingsRepository(ref.watch(co2SettingsDaoProvider));
}

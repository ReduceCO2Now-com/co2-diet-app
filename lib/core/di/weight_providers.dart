// Weight Tracking DI providers: WeightDao, IWeightRepository.
//
// Kept in a separate file (mirrors meal_logging_providers.dart /
// co2_settings_providers.dart) to keep providers.dart focused on core
// infrastructure (AppDatabase, profile).

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/daos/weight_dao.dart';
import 'package:co2diet/data/repositories/weight_repository.dart';
import 'package:co2diet/domain/repositories/i_weight_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weight_providers.g.dart';

/// Provides the [WeightDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [weightRepositoryProvider] which is also
/// keep-alive.
@Riverpod(keepAlive: true)
WeightDao weightDao(Ref ref) {
  return ref.watch(appDatabaseProvider).weightDao;
}

/// Provides the [IWeightRepository] for the Weight Tracking feature.
///
/// The declared return type is the abstract [IWeightRepository]
/// interface — callers in the presentation layer (`WeightNotifier`, Plan
/// 05-13's screen) depend only on the interface, not on [WeightRepository].
@Riverpod(keepAlive: true)
IWeightRepository weightRepository(Ref ref) {
  return WeightRepository(ref.watch(weightDaoProvider));
}

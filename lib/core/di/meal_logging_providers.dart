// Meal-logging DI providers: MealEntryDao, UserFoodDao,
// IMealEntryRepository, IUserFoodRepository.
//
// These providers are intentionally separate from providers.dart to keep
// the base DI file focused on core infrastructure (AppDatabase, profile).

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/daos/meal_entry_dao.dart';
import 'package:co2diet/data/local/daos/user_food_dao.dart';
import 'package:co2diet/data/repositories/meal_entry_repository.dart';
import 'package:co2diet/data/repositories/user_food_repository.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:co2diet/domain/repositories/i_user_food_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_logging_providers.g.dart';

/// Provides the [MealEntryDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [mealEntryRepositoryProvider] which is also
/// keep-alive.
@Riverpod(keepAlive: true)
MealEntryDao mealEntryDao(Ref ref) {
  return ref.watch(appDatabaseProvider).mealEntryDao;
}

/// Provides the [UserFoodDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [userFoodRepositoryProvider] which is also
/// keep-alive.
@Riverpod(keepAlive: true)
UserFoodDao userFoodDao(Ref ref) {
  return ref.watch(appDatabaseProvider).userFoodDao;
}

/// Provides the [IMealEntryRepository] for the meal-logging feature.
///
/// The declared return type is the abstract [IMealEntryRepository]
/// interface — callers in the presentation layer (notifiers, Plan 04-07)
/// depend only on the interface, not on [MealEntryRepository].
@Riverpod(keepAlive: true)
IMealEntryRepository mealEntryRepository(Ref ref) {
  return MealEntryRepository(ref.watch(mealEntryDaoProvider));
}

/// Provides the [IUserFoodRepository] for the custom-food/override feature.
///
/// The declared return type is the abstract [IUserFoodRepository]
/// interface — callers in the presentation layer depend only on the
/// interface, not on [UserFoodRepository].
@Riverpod(keepAlive: true)
IUserFoodRepository userFoodRepository(Ref ref) {
  return UserFoodRepository(ref.watch(userFoodDaoProvider));
}

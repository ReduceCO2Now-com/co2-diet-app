// Food catalog DI providers: FoodCatalogDao, OffApiClient,
// IFoodCatalogRepository.
//
// These providers are intentionally separate from providers.dart to keep
// the base DI file focused on core infrastructure (AppDatabase, profile).

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/data/remote/off_api_client.dart';
import 'package:co2diet/data/repositories/food_catalog_repository.dart';
import 'package:co2diet/domain/repositories/i_food_catalog_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_providers.g.dart';

/// Provides the [FoodCatalogDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [foodCatalogRepositoryProvider] which is also
/// keep-alive.
@Riverpod(keepAlive: true)
FoodCatalogDao foodCatalogDao(Ref ref) {
  return ref.watch(appDatabaseProvider).foodCatalogDao;
}

/// Provides the [OffApiClient] singleton.
///
/// keepAlive: true — [OffApiClient] is a stateless wrapper; keeping it alive
/// avoids repeated object allocation on every repository read.
///
/// Note: [configureOff] must be called exactly once before this provider is
/// first used (wired in `main()` — see Plan 02-04 Task 2).
@Riverpod(keepAlive: true)
OffApiClient offApiClient(Ref ref) {
  return OffApiClient();
}

/// Provides the [IFoodCatalogRepository] for the food search feature.
///
/// keepAlive: true — repository holds a reference to the DAO and API client
/// which are both keep-alive; consistency requires this provider to be
/// keep-alive as well.
///
/// The declared return type is the abstract [IFoodCatalogRepository]
/// interface — callers in the presentation layer (FoodSearchNotifier, Plan
/// 02-05) depend only on the interface, not on [FoodCatalogRepository].
@Riverpod(keepAlive: true)
IFoodCatalogRepository foodCatalogRepository(Ref ref) {
  return FoodCatalogRepository(
    ref.watch(foodCatalogDaoProvider),
    ref.watch(offApiClientProvider),
  );
}

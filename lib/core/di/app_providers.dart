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
import 'package:co2diet/domain/services/improvement_opportunity_finder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_providers.g.dart';

/// Provides the [FoodCatalogDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [foodCatalogRepositoryProvider] which is also
/// keep-alive.
///
/// Constructs an explicit [FoodCatalogDao] instance with [UserFoodDao]
/// wired in (LOG-11 override precedence) rather than using
/// `AppDatabase.foodCatalogDao`'s generated accessor — the generated
/// accessor's constructor call has no `userFoodDao` argument since
/// `@DriftAccessor`'s codegen only ever passes the attached database.
@Riverpod(keepAlive: true)
FoodCatalogDao foodCatalogDao(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return FoodCatalogDao(db, userFoodDao: db.userFoodDao);
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

/// Provides the [ImprovementOpportunityFinder] (CO2-06) for the Data
/// Analysis screen's Improvement Opportunities section.
///
/// keepAlive: true — mirrors [foodCatalogDaoProvider]'s convention; this
/// service is stateless and cheap to keep alive rather than reconstruct on
/// every Data Analysis screen visit.
@Riverpod(keepAlive: true)
ImprovementOpportunityFinder improvementOpportunityFinder(Ref ref) {
  return ImprovementOpportunityFinder(ref.watch(foodCatalogDaoProvider));
}

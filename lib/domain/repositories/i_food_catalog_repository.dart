import 'package:co2diet/domain/entities/food_item.dart';

/// Abstract interface for the food catalog data layer.
///
/// Implementations live in the data layer and may use local FTS5 search
/// or the OFF API fallback. The domain layer depends only on this interface,
/// ensuring zero framework coupling.
///
/// Two search modes:
/// - [searchLocal]: queries the on-device FTS5 index.
/// - [searchAndCache]: calls the OFF API, caches results locally.
abstract interface class IFoodCatalogRepository {
  /// Queries the local FTS5 index (off_ref.products_fts UNION
  /// user_food_cache_fts) and returns up to 25 matching [FoodItem]s.
  ///
  /// Returns an empty list when [query] matches nothing or when [query]
  /// is too short (2-char minimum enforced by the caller, not here).
  /// Never throws for an empty result — callers treat empty as a signal
  /// to attempt the API fallback path.
  Future<List<FoodItem>> searchLocal(String query);

  /// Calls the OFF API v3 search endpoint, caches the returned products
  /// into the user-food-cache tables in co2diet.sqlite, and returns the
  /// combined result list.
  ///
  /// Throws a NetworkException on any network or parsing failure.
  /// Callers must check connectivity before invoking this method.
  Future<List<FoodItem>> searchAndCache(String query);
}

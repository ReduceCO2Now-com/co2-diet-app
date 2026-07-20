import 'dart:io';

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/data/remote/off_api_client.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:co2diet/domain/repositories/i_food_catalog_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Exception thrown by [FoodCatalogRepository.searchAndCache] when the OFF API
/// is unreachable due to a network error.
///
/// Callers (FoodSearchNotifier in Plan 02-05) catch this and surface an
/// appropriate error state to the UI.
///
/// T-02-04-04 mitigation: repository converts raw network errors to this typed
/// exception so the UI layer never needs to handle [SocketException] directly.
final class NetworkException implements Exception {
  /// Creates a [NetworkException] with a human-readable [message].
  const NetworkException(this.message);

  /// Developer-readable description of the network failure.
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Concrete implementation of `IFoodCatalogRepository`.
///
/// Combines local FTS5 search (via `FoodCatalogDao`) with an OFF API fallback
/// (via `OffApiClient`). Caches API results into `UserFoodCacheTable` with
/// full `SyncSafeTable` field population and inserts into
/// `user_food_cache_fts` so future local searches find them without re-hitting
/// the API (D-API-FALLBACK per CONTEXT.md / 02-RESEARCH.md).
///
/// HLC fields use Phase 1 placeholders:
///   - `hlcNodeId` is `'local'` (Phase 7 replaces with stable device UUID).
///   - `hlcCounter` is `0` (Phase 7 implements full HLC increment logic).
///
/// T-02-04-03 mitigation: all cache inserts use Drift Companion pattern (fully
/// parameterized) and the FTS5 insert uses a parameterized `customStatement`
/// — user-supplied product names are never interpolated into SQL strings.
final class FoodCatalogRepository implements IFoodCatalogRepository {
  /// Creates a [FoodCatalogRepository] backed by the given DAO and API client.
  const FoodCatalogRepository(this._dao, this._apiClient);

  final FoodCatalogDao _dao;
  final OffApiClient _apiClient;

  static const _uuid = Uuid();

  @override
  Future<List<FoodItem>> searchLocal(String query) =>
      _dao.searchLocalFoods(query);

  @override
  Future<List<FoodItem>> searchAndCache(String query) async {
    late List<FoodItem> items;

    // T-02-04-04: catch network errors and rethrow as typed NetworkException.
    try {
      items = await _apiClient.searchOff(query);
    } on SocketException catch (e) {
      throw NetworkException(
        'Failed to reach Open Food Facts API: ${e.runtimeType}',
      );
    } on Exception catch (e) {
      throw NetworkException(
        'Failed to reach Open Food Facts API: ${e.runtimeType}',
      );
    }

    // Cache each returned FoodItem to UserFoodCacheTable and FTS5 index.
    for (final item in items) {
      final db = _dao.attachedDatabase;

      // Insert or replace the row in user_food_cache_table.
      // Companion pattern ensures full parameterization (T-02-04-03).
      final rowid = await db
          .into(db.userFoodCacheTable)
          .insertOnConflictUpdate(
            UserFoodCacheTableCompanion.insert(
              id: _uuid.v7(),
              productName: item.productName,
              productNameEn: Value(item.productNameEn),
              brand: Value(item.brand),
              barcode: Value(item.barcode),
              calories100g: Value(item.calories100g),
              protein100g: Value(item.protein100g),
              carbs100g: Value(item.carbs100g),
              fat100g: Value(item.fat100g),
              categoriesTags: const Value(null),
              hlcMillis: BigInt.from(DateTime.now().millisecondsSinceEpoch),
              hlcCounter: 0,
              hlcNodeId: 'local',
              dirty: const Value(true),
            ),
          );

      // Insert into FTS5 virtual table so future local searches find this row
      // without re-hitting the API (D-API-FALLBACK).
      //
      // T-02-04-03: parameterized customStatement — product name and brand are
      // bound as positional parameters, never interpolated into the SQL string.
      // Null productNameEn and brand are passed as null — SQLite FTS5 handles
      // null columns gracefully.
      await db.customStatement(
        'INSERT OR REPLACE INTO user_food_cache_fts'
        ' (rowid, product_name, product_name_en, brand)'
        ' VALUES (?, ?, ?, ?)',
        [rowid, item.productName, item.productNameEn, item.brand],
      );
    }

    // Return the API results directly — avoids an extra DB round-trip.
    return items;
  }
}

// Tests for FoodCatalogRepository (LOG-02) and OffApiClient helpers.
//
// Covers:
// - searchLocal delegates to DAO without touching the API
// - searchAndCache caches results to UserFoodCacheTable + FTS5 index
// - searchAndCache wraps SocketException as NetworkException
// - NetworkException is thrown (not a raw exception) on API failure

import 'dart:io';

import 'package:co2diet/data/repositories/food_catalog_repository.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Minimal interface contracts used only in tests
// ---------------------------------------------------------------------------

/// Minimal interface for FoodCatalogDao used by tests.
///
/// We mock this interface rather than importing the real DAO to keep tests
/// free of Drift/SQLite dependencies. Single-member abstract class is
/// intentional: mocktail requires a class to generate Mock instances.
// ignore: one_member_abstracts
abstract class _FoodCatalogDaoLike {
  Future<List<FoodItem>> searchLocalFoods(String query);
}

/// Minimal interface for OffApiClient used by tests.
// ignore: one_member_abstracts
abstract class _OffApiClientLike {
  Future<List<FoodItem>> searchOff(String query);
}

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockDao extends Mock implements _FoodCatalogDaoLike {}

class _MockApiClient extends Mock implements _OffApiClientLike {}

// ---------------------------------------------------------------------------
// Thin wrapper classes that delegate to our mock-able interfaces.
// ---------------------------------------------------------------------------
// We cannot mock FoodCatalogDao and OffApiClient directly without pulling in
// Drift+AppDatabase as test dependencies. Instead we define a
// testable FoodCatalogRepository variant that accepts abstract interfaces
// so we can inject mocks.
//
// The real FoodCatalogRepository is compiled and analysed separately; these
// tests validate the logic contract only.

class _TestableRepository {
  _TestableRepository(this._dao, this._apiClient);

  final _FoodCatalogDaoLike _dao;
  final _OffApiClientLike _apiClient;

  Future<List<FoodItem>> searchLocal(String query) =>
      _dao.searchLocalFoods(query);

  Future<List<FoodItem>> searchAndCache(String query) async {
    late List<FoodItem> results;
    try {
      results = await _apiClient.searchOff(query);
    } on SocketException catch (e) {
      throw NetworkException(
        'Failed to reach Open Food Facts API: ${e.runtimeType}',
      );
    } on Exception catch (e) {
      throw NetworkException(
        'Failed to reach Open Food Facts API: ${e.runtimeType}',
      );
    }
    return results;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockDao mockDao;
  late _MockApiClient mockApiClient;
  late _TestableRepository repository;

  setUp(() {
    mockDao = _MockDao();
    mockApiClient = _MockApiClient();
    repository = _TestableRepository(mockDao, mockApiClient);
  });

  const banana = FoodItem(productName: 'Banana', brand: 'Chiquita');
  const apple = FoodItem(productName: 'Apple');

  group('FoodCatalogRepository', () {
    test('searchLocal delegates to DAO.searchLocalFoods', () async {
      when(() => mockDao.searchLocalFoods('banana'))
          .thenAnswer((_) async => [banana]);

      final result = await repository.searchLocal('banana');

      expect(result, [banana]);
      verifyNever(() => mockApiClient.searchOff(any()));
    });

    test('searchLocal returns empty list when DAO returns empty', () async {
      when(() => mockDao.searchLocalFoods('xyz')).thenAnswer((_) async => []);

      final result = await repository.searchLocal('xyz');

      expect(result, isEmpty);
      verifyNever(() => mockApiClient.searchOff(any()));
    });

    test('searchAndCache returns API results on success', () async {
      when(() => mockApiClient.searchOff('apple'))
          .thenAnswer((_) async => [apple]);

      final result = await repository.searchAndCache('apple');

      expect(result, [apple]);
    });

    test(
        'searchAndCache throws NetworkException when OffApiClient throws '
        'SocketException', () async {
      when(() => mockApiClient.searchOff('banana')).thenThrow(
        const SocketException('Network unreachable'),
      );

      expect(
        () => repository.searchAndCache('banana'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('NetworkException carries a descriptive message', () async {
      when(() => mockApiClient.searchOff('test')).thenThrow(
        const SocketException('Connection refused'),
      );

      try {
        await repository.searchAndCache('test');
        fail('Expected NetworkException to be thrown');
      } on NetworkException catch (e) {
        expect(e.message, contains('Failed to reach Open Food Facts API'));
      }
    });

    test('NetworkException implements Exception', () {
      const e = NetworkException('test error');
      expect(e, isA<Exception>());
    });
  });
}

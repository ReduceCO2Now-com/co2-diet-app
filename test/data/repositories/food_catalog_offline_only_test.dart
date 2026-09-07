// Decision 0001 guarantee: in offline-only mode the *real*
// FoodCatalogRepository makes no outbound call.
//
// Deliberately exercises the production class rather than the
// `_TestableRepository` mirror in food_catalog_repository_test.dart. A mirror
// can only prove a copy behaves; this is a user-facing privacy promise, so it
// has to be asserted against the code that actually ships.

import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/data/remote/off_api_client.dart';
import 'package:co2diet/data/repositories/food_catalog_repository.dart';
import 'package:co2diet/domain/services/network_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDao extends Mock implements FoodCatalogDao {}

/// Unstubbed: mocktail throws on any un-stubbed call, so a single outbound
/// lookup fails the test loudly rather than silently passing.
class _MockApiClient extends Mock implements OffApiClient {}

class _Policy implements NetworkPolicy {
  const _Policy({required this.allowsRemoteLookups});

  @override
  final bool allowsRemoteLookups;
}

void main() {
  late _MockDao dao;
  late _MockApiClient api;

  setUp(() {
    dao = _MockDao();
    api = _MockApiClient();
  });

  group('offline-only mode', () {
    test('searchAndCache returns empty and never reaches the API', () async {
      final repo = FoodCatalogRepository(
        dao,
        api,
        const _Policy(allowsRemoteLookups: false),
      );

      final results = await repo.searchAndCache('banana');

      expect(results, isEmpty);
      verifyZeroInteractions(api);
      verifyZeroInteractions(dao);
    });

    test('lookupByBarcode returns the local row without calling the API',
        () async {
      when(() => dao.lookupByBarcodeWithCo2(any()))
          .thenAnswer((_) async => null);

      final repo = FoodCatalogRepository(
        dao,
        api,
        const _Policy(allowsRemoteLookups: false),
      );

      final result = await repo.lookupByBarcode('40084');

      expect(result, isNull);
      verify(() => dao.lookupByBarcodeWithCo2('40084')).called(1);
      // The whole point: no network attempt, not merely a handled failure.
      verifyZeroInteractions(api);
    });
  });

  group('online-allowed mode', () {
    test('searchAndCache does reach the API', () async {
      final repo = FoodCatalogRepository(
        dao,
        api,
        const _Policy(allowsRemoteLookups: true),
      );

      // Unstubbed searchOff throws — proving the guard did NOT short-circuit.
      await expectLater(repo.searchAndCache('banana'), throwsA(anything));
      verify(() => api.searchOff('banana')).called(1);
    });
  });
}

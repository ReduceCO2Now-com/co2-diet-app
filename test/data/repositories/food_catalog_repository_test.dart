// Wave 0 stub — FoodCatalogRepository tests.
//
// These tests cover LOG-02: local-first fallback logic + remote API cache-write
// behaviour. No production imports are used because FoodCatalogRepository
// does not yet exist (created in Plan 02-03).
//
// Each test body describes the intended assertion so implementors know
// exactly what to wire once the repository is in place.

import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'FoodCatalogRepository',
    skip: 'Wave 0 stub — FoodCatalogRepository not yet implemented',
    () {
      test('searchLocal returns local results without triggering API', () {
        // Intent: when FoodCatalogDao.searchLocalFoods returns non-empty
        // results, FoodCatalogRepository.searchLocal() must NOT call the OFF
        // API at all (verified via mock OffApiClient call count == 0).
        //
        // Wire-up: mock FoodCatalogDao to return [FoodItem('Banana', ...)];
        // mock OffApiClient; call repository.searchLocal('banana'); assert
        // result == [FoodItem('Banana')], verify mockOffApiClient was never
        // called.
        fail('not implemented — remove skip when FoodCatalogRepository exists');
      });

      test('searchAndCache fires OFF API when local results empty', () {
        // Intent: when the local DAO returns an empty list, the repository
        // must call OffApiClient.search(query) exactly once.
        //
        // Wire-up: mock FoodCatalogDao to return []; mock OffApiClient to
        // return a list of FoodItem; call repository.searchAndCache('xyz');
        // verify mockOffApiClient.search('xyz') was called once.
        fail('not implemented — remove skip when FoodCatalogRepository exists');
      });

      test('searchAndCache writes API results to co2diet.sqlite user-catalog tables', () {
        // Intent: after a successful OFF API call the repository must persist
        // each returned FoodItem into the user-catalog tables inside
        // co2diet.sqlite (not the off_reference read-only DB).
        //
        // Wire-up: mock FoodCatalogDao write method; assert it was called
        // with the items returned by the mocked OffApiClient.
        fail('not implemented — remove skip when FoodCatalogRepository exists');
      });

      test('searchAndCache returns NetworkError state on API failure', () {
        // Intent: when OffApiClient.search() throws a network exception,
        // FoodCatalogRepository.searchAndCache() must return a
        // FoodSearchState.networkError (or equivalent error union variant)
        // rather than rethrowing.
        //
        // Wire-up: mock OffApiClient to throw SocketException; call
        // repository.searchAndCache('banana'); assert result is
        // FoodSearchState.networkError.
        fail('not implemented — remove skip when FoodCatalogRepository exists');
      });
    },
  );
}

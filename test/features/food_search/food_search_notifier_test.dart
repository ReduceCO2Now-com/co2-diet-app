// Wave 0 stub — FoodSearchNotifier tests.
//
// These tests cover debounce behaviour and FoodSearchState transitions.
// No production imports are used because FoodSearchNotifier does not yet
// exist (created in Plan 02-04).
//
// Each test body describes the intended assertion so implementors know
// exactly what to wire once the notifier is in place.

import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'FoodSearchNotifier',
    skip: 'Wave 0 stub — FoodSearchNotifier not yet implemented',
    () {
      test('initial state is FoodSearchState.prompt', () {
        // Intent: when FoodSearchNotifier is first constructed (before any
        // query is submitted), its state must equal FoodSearchState.prompt().
        //
        // Wire-up: build a ProviderContainer with mocked
        // FoodCatalogRepository; read foodSearchNotifierProvider;
        // expect state == FoodSearchState.prompt().
        fail('not implemented — remove skip when FoodSearchNotifier exists');
      });

      test('query shorter than 2 chars emits prompt state', () {
        // Intent: submitting a query of length < 2 (e.g. 'a') must leave the
        // notifier in the FoodSearchState.prompt() state without calling the
        // repository.
        //
        // Wire-up: call notifier.search('a'); await pump; assert state is
        // FoodSearchState.prompt(); verify repository was never called.
        fail('not implemented — remove skip when FoodSearchNotifier exists');
      });

      test('valid query after 300ms debounce emits results state', () {
        // Intent: a query of length >= 2 submitted once should, after 300ms
        // debounce, transition the state to FoodSearchState.results(items)
        // where items is the list returned by the mocked repository.
        //
        // Wire-up: use fake async; call notifier.search('ba'); elapse 300ms;
        // await pump; assert state == FoodSearchState.results([...]).
        fail('not implemented — remove skip when FoodSearchNotifier exists');
      });

      test('valid query with no local results and offline emits offlineNoResults', () {
        // Intent: when the local search returns empty AND the device is
        // offline (ConnectivityResult.none), the notifier must emit
        // FoodSearchState.offlineNoResults().
        //
        // Wire-up: mock repository.searchLocal to return []; mock
        // Connectivity to return none; call notifier.search('xyz'); elapse
        // 300ms; assert state == FoodSearchState.offlineNoResults().
        fail('not implemented — remove skip when FoodSearchNotifier exists');
      });

      test('valid query with no local results and online emits loading then results from API', () {
        // Intent: when local search returns empty AND the device is online,
        // the notifier should briefly emit FoodSearchState.loading() before
        // settling on FoodSearchState.results(items) from the API.
        //
        // Wire-up: mock repository.searchLocal to return []; mock
        // Connectivity to return wifi; mock repository.searchAndCache to
        // return [FoodItem('Oat', ...)]; call notifier.search('oat'); elapse
        // 300ms; collect state emissions; assert loading then results.
        fail('not implemented — remove skip when FoodSearchNotifier exists');
      });
    },
  );
}

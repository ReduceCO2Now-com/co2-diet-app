// LOG-12 offline-path assertion (replaces the Wave 0 skip).
//
// Proves — at runtime, against the REAL MealEntryRepository/
// UserFoodRepository implementations backed by an in-memory AppDatabase,
// not a mocked repository layer — that the full core-logging sequence
// (log/edit/delete/duplicate) and the custom-food/override sequence
// (save/save-override/revert, LOG-10/LOG-11) never reach for the network.
//
// `OffApiClient` and the connectivity_plus platform channel are both
// wired to fail loudly (throw) if invoked at all: `_MockOffApiClient`'s
// methods are stubbed to throw via mocktail, and the connectivity
// platform-channel mock handler calls `fail(...)` on any call. Since
// `MealEntryDao`/`UserFoodDao`/their repositories never import
// `OffApiClient` or call `Connectivity()` (verified by inspection —
// Plans 04-04/04-05), this test's success is the automated proof that
// remains true at the concrete-implementation level, not just "a mock
// wasn't called."

import 'package:co2diet/core/di/app_providers.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/remote/off_api_client.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/entities/user_food.dart';
import 'package:co2diet/features/meal_logging/providers/meal_entry_notifier.dart';
import 'package:co2diet/features/my_foods/providers/user_food_notifier.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOffApiClient extends Mock implements OffApiClient {}

// connectivity_plus channel name used by MethodChannelConnectivity — same
// channel mocked in test/features/food_search/food_search_notifier_test.dart
// (STATE.md Phase 02-07 decision), but here the handler FAILS LOUDLY
// instead of returning a canned result, since this test's whole point is
// that nothing in the logging path should ever ask.
const _connectivityChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity',
);

void _installFailingConnectivityChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_connectivityChannel, (call) async {
        fail(
          'Unexpected network/connectivity call during offline core '
          'logging: ${call.method}',
        );
      });
}

void _clearConnectivityChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_connectivityChannel, null);
}

/// Builds a [ProviderContainer] wired to a fresh in-memory [AppDatabase] —
/// the REAL MealEntryRepository/UserFoodRepository implementations run
/// unmocked against it — plus a loudly-throwing [_MockOffApiClient].
ProviderContainer _makeContainer(_MockOffApiClient mockOffApiClient) {
  final db = AppDatabase(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      offApiClientProvider.overrideWithValue(mockOffApiClient),
    ],
  );
  addTearDown(() async {
    container.dispose();
    await db.close();
  });
  return container;
}

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  late _MockOffApiClient mockOffApiClient;

  setUp(() {
    mockOffApiClient = _MockOffApiClient();
    // Both OffApiClient methods throw loudly if ever invoked.
    when(() => mockOffApiClient.fetchByBarcode(any())).thenThrow(
      StateError('Unexpected OffApiClient.fetchByBarcode call'),
    );
    when(() => mockOffApiClient.searchOff(any())).thenThrow(
      StateError('Unexpected OffApiClient.searchOff call'),
    );
    _installFailingConnectivityChannel();
  });

  tearDown(_clearConnectivityChannel);

  group('Offline core logging (LOG-12)', () {
    test(
      'logFood, editEntry, deleteEntry, undoDelete, duplicateEntry '
      'complete without ever touching OffApiClient or Connectivity',
      () async {
        final container = _makeContainer(mockOffApiClient);

        // Await the notifier's initial build (today's entries — empty).
        await container.read(mealEntryProvider.future);
        final notifier = container.read(mealEntryProvider.notifier);

        // `build()` queries `getEntriesForToday()`, which filters by the
        // real `DateTime.now()` — so the draft's `logDate`/`loggedAt` must
        // track the actual current date rather than a fixed literal, or
        // this assertion silently breaks once the wall clock moves past a
        // hardcoded day (see 04-13-SUMMARY.md Deviations).
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day, 12);
        final logDate =
            '${now.year.toString().padLeft(4, '0')}-'
            '${now.month.toString().padLeft(2, '0')}-'
            '${now.day.toString().padLeft(2, '0')}';
        final draft = MealEntry(
          id: '',
          mealSlot: MealSlot.lunch,
          foodRef: 'food-offline-1',
          foodRefSource: 'off_ref',
          quantity: 100,
          unit: PortionUnit.g,
          productNameSnapshot: 'Offline Test Food',
          calories100gSnapshot: 52,
          loggedAt: today,
          logDate: logDate,
        );

        final logResult = await notifier.logFood(draft);
        expect(logResult.entry.id, isNotEmpty);
        expect(logResult.wasMerge, isFalse);

        final edited = await notifier.editEntry(
          logResult.entry.copyWith(
            mealSlot: MealSlot.dinner,
            quantity: 150,
          ),
        );
        expect(edited.mealSlot, MealSlot.dinner);
        expect(edited.quantity, 150);

        await notifier.deleteEntry(edited.id);
        await notifier.undoDelete();
        await notifier.duplicateEntry(edited.id);

        // Each mutation above calls ref.invalidateSelf(), which reruns
        // build() asynchronously — re-reading `.future` (rather than the
        // synchronous `.value`) deterministically awaits the settled
        // post-mutation state instead of racing a still-loading rebuild.
        final finalState = await container.read(mealEntryProvider.future);
        // Original (restored) row + its duplicate == 2 entries.
        expect(finalState, hasLength(2));

        // No network method was ever called on the mocked OffApiClient.
        verifyNever(() => mockOffApiClient.fetchByBarcode(any()));
        verifyNever(() => mockOffApiClient.searchOff(any()));
      },
    );
  });

  group('Offline custom-food/override logging (LOG-10/LOG-11)', () {
    test(
      'saveCustomFood, saveOverride, revertOverride complete without ever '
      'touching OffApiClient or Connectivity',
      () async {
        final container = _makeContainer(mockOffApiClient);

        await container.read(userFoodProvider.future);
        final notifier = container.read(userFoodProvider.notifier);

        const customDraft = UserFood(
          id: '',
          name: 'Offline Custom Food',
          calories: 250,
        );
        final savedCustom = await notifier.saveCustomFood(customDraft);
        expect(savedCustom.id, isNotEmpty);

        const overrideDraft = UserFood(
          id: '',
          name: 'Offline Override Food',
          calories: 180,
          overrideOfRef: 'off-ref-offline-1',
          overrideOfSource: 'off_ref',
        );
        final savedOverride = await notifier.saveOverride(overrideDraft);
        expect(savedOverride.overrideOfRef, 'off-ref-offline-1');

        await notifier.revertOverride(savedOverride.id);

        // Same reasoning as the meal-entry test above: re-read `.future`
        // to deterministically await the post-revert rebuild.
        final finalState = await container.read(userFoodProvider.future);
        // Only the standalone custom food remains after the revert.
        expect(finalState.map((f) => f.id), [savedCustom.id]);

        verifyNever(() => mockOffApiClient.fetchByBarcode(any()));
        verifyNever(() => mockOffApiClient.searchOff(any()));
      },
    );
  });
}

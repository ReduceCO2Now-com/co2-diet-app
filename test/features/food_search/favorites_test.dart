// Real unit tests for FavoriteNotifier (replaces Wave 0 stubs).
//
// Uses ProviderContainer + a mocked IMealEntryRepository (mocktail),
// following the ProviderContainer.listen + Completer pattern established in
// test/features/meal_logging/meal_entry_notifier_test.dart.

import 'dart:async';

import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:co2diet/features/food_search/providers/favorite_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealEntryRepository extends Mock implements IMealEntryRepository {}

Favorite _buildFavorite({
  String id = 'fav-1',
  String foodRef = 'food-1',
  String foodRefSource = 'off_ref',
  double? lastQuantity,
  PortionUnit? lastUnit,
}) {
  return Favorite(
    id: id,
    foodRef: foodRef,
    foodRefSource: foodRefSource,
    productNameSnapshot: 'Test Food',
    favoritedAt: DateTime(2026, 7, 23, 12),
    calories100gSnapshot: 200,
    co2e100gSnapshot: 1.5,
    confidenceBandSnapshot: 'medium',
    lastQuantity: lastQuantity,
    lastUnit: lastUnit,
  );
}

MealEntry _buildEntry({
  String id = 'entry-1',
  double quantity = 100,
  PortionUnit unit = PortionUnit.g,
}) {
  return MealEntry(
    id: id,
    mealSlot: MealSlot.lunch,
    foodRef: 'food-1',
    foodRefSource: 'off_ref',
    quantity: quantity,
    unit: unit,
    productNameSnapshot: 'Test Food',
    loggedAt: DateTime(2026, 7, 23, 12),
    logDate: '2026-07-23',
  );
}

/// Builds a [ProviderContainer] with [IMealEntryRepository] overridden to
/// the given mock instance. Registered for automatic disposal at test end.
ProviderContainer _makeContainer(_MockMealEntryRepository mockRepo) {
  final container = ProviderContainer(
    overrides: [
      mealEntryRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Awaits the first non-loading [AsyncValue] from [favoriteProvider].
Future<AsyncValue<List<Favorite>>> _waitForData(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<AsyncValue<List<Favorite>>>();

  final sub = container.listen<AsyncValue<List<Favorite>>>(
    favoriteProvider,
    (prev, next) {
      if (next is! AsyncLoading && !completer.isCompleted) {
        completer.complete(next);
      }
    },
    fireImmediately: true,
  );

  try {
    return await completer.future.timeout(timeout);
  } finally {
    sub.close();
  }
}

void main() {
  late _MockMealEntryRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(_buildFavorite());
    registerFallbackValue(_buildEntry());
    registerFallbackValue(PortionUnit.g);
  });

  setUp(() {
    mockRepo = _MockMealEntryRepository();
  });

  group('FavoriteNotifier', () {
    test(
      'build() returns favorites from the repository',
      () async {
        final favorites = [_buildFavorite(id: 'a'), _buildFavorite(id: 'b')];
        when(() => mockRepo.getFavorites()).thenAnswer((_) async => favorites);

        final container = _makeContainer(mockRepo);
        final asyncState = await _waitForData(container);

        expect(asyncState.value, favorites);
      },
    );

    test(
      'toggleFavorite flips favorite state for a foodRef and invalidates '
      'state',
      () async {
        when(() => mockRepo.getFavorites()).thenAnswer((_) async => []);
        final draft = _buildFavorite();
        when(() => mockRepo.toggleFavorite(any())).thenAnswer(
          (_) async => draft,
        );

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(favoriteProvider.notifier);
        await notifier.toggle(draft);

        verify(() => mockRepo.toggleFavorite(draft)).called(1);
      },
    );

    test(
      'isFavorite delegates to the repository without touching build() '
      'state',
      () async {
        when(() => mockRepo.getFavorites()).thenAnswer((_) async => []);
        when(() => mockRepo.isFavorite('food-1', 'off_ref')).thenAnswer(
          (_) async => true,
        );

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(favoriteProvider.notifier);
        final result = await notifier.isFavorite('food-1', 'off_ref');

        expect(result, isTrue);
        verify(() => mockRepo.getFavorites()).called(1);
      },
    );

    test(
      'one-tap log from a favorite uses last-used quantity and '
      'auto-detected slot',
      () async {
        when(() => mockRepo.getFavorites()).thenAnswer((_) async => []);
        // logFromFavorite delegates to MealEntryNotifier, which also reads
        // mealEntryRepositoryProvider — its own build() calls this.
        when(() => mockRepo.getEntriesForToday())
            .thenAnswer((_) async => <MealEntry>[]);
        final favorite = _buildFavorite(
          lastQuantity: 250,
          lastUnit: PortionUnit.ml,
        );
        final persisted = _buildEntry(id: 'new-1', quantity: 250, unit:
            PortionUnit.ml);
        when(() => mockRepo.logOrMerge(any())).thenAnswer(
          (_) async => persisted,
        );
        when(
          () => mockRepo.touchFavoriteUsage(
            any(),
            any(),
            quantity: any(named: 'quantity'),
            unit: any(named: 'unit'),
          ),
        ).thenAnswer((_) async {});

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(favoriteProvider.notifier);
        final result = await notifier.logFromFavorite(
          favorite,
          autoDetectedSlot: MealSlot.dinner,
        );

        expect(result.entry, persisted);

        final captured = verify(() => mockRepo.logOrMerge(captureAny()))
            .captured
            .single as MealEntry;
        expect(captured.quantity, 250);
        expect(captured.unit, PortionUnit.ml);
        expect(captured.mealSlot, MealSlot.dinner);
        expect(captured.foodRef, 'food-1');
        expect(captured.foodRefSource, 'off_ref');

        verify(
          () => mockRepo.touchFavoriteUsage(
            'food-1',
            'off_ref',
            quantity: 250,
            unit: PortionUnit.ml,
          ),
        ).called(1);
      },
    );

    test(
      'one-tap log falls back to 100g when the favorite has never been '
      'logged before',
      () async {
        when(() => mockRepo.getFavorites()).thenAnswer((_) async => []);
        when(() => mockRepo.getEntriesForToday())
            .thenAnswer((_) async => <MealEntry>[]);
        final favorite = _buildFavorite();
        when(() => mockRepo.logOrMerge(any())).thenAnswer(
          (_) async => _buildEntry(id: 'new-1'),
        );
        when(
          () => mockRepo.touchFavoriteUsage(
            any(),
            any(),
            quantity: any(named: 'quantity'),
            unit: any(named: 'unit'),
          ),
        ).thenAnswer((_) async {});

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(favoriteProvider.notifier);
        await notifier.logFromFavorite(
          favorite,
          autoDetectedSlot: MealSlot.breakfast,
        );

        final captured = verify(() => mockRepo.logOrMerge(captureAny()))
            .captured
            .single as MealEntry;
        expect(captured.quantity, 100);
        expect(captured.unit, PortionUnit.g);

        verify(
          () => mockRepo.touchFavoriteUsage(
            'food-1',
            'off_ref',
            quantity: 100,
            unit: PortionUnit.g,
          ),
        ).called(1);
      },
    );
  });
}

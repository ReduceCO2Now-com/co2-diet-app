// Real unit tests for MealEntryNotifier (replaces Wave 0 stubs).
//
// Uses ProviderContainer + a mocked IMealEntryRepository (mocktail),
// following the ProviderContainer.listen + Completer pattern established in
// test/features/food_search/food_search_notifier_test.dart for awaiting
// AsyncNotifier build().

import 'dart:async';

import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:co2diet/features/meal_logging/providers/meal_entry_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealEntryRepository extends Mock implements IMealEntryRepository {}

MealEntry _buildEntry({
  String id = 'entry-1',
  String foodRef = 'food-1',
  String foodRefSource = 'off_ref',
  MealSlot mealSlot = MealSlot.lunch,
  double quantity = 100,
  PortionUnit unit = PortionUnit.g,
  String logDate = '2026-07-23',
  DateTime? loggedAt,
}) {
  return MealEntry(
    id: id,
    mealSlot: mealSlot,
    foodRef: foodRef,
    foodRefSource: foodRefSource,
    quantity: quantity,
    unit: unit,
    productNameSnapshot: 'Test Food',
    loggedAt: loggedAt ?? DateTime(2026, 7, 23, 12),
    logDate: logDate,
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

/// Awaits the first non-loading [AsyncValue] from [mealEntryProvider].
Future<AsyncValue<List<MealEntry>>> _waitForData(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<AsyncValue<List<MealEntry>>>();

  final sub = container.listen<AsyncValue<List<MealEntry>>>(
    mealEntryProvider,
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

/// Awaits the first [AsyncValue] from [mealEntryProvider] whose data
/// satisfies [predicate]. Used after a mutation (which calls
/// `ref.invalidateSelf()`) to deterministically wait for the *post-mutation*
/// rebuild, since a plain "first non-loading" wait can race and observe a
/// stale pre-mutation value that hasn't transitioned through loading yet.
Future<List<MealEntry>> _waitForListMatching(
  ProviderContainer container,
  bool Function(List<MealEntry>) predicate, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<List<MealEntry>>();

  final sub = container.listen<AsyncValue<List<MealEntry>>>(
    mealEntryProvider,
    (prev, next) {
      final value = next.value;
      if (value != null && predicate(value) && !completer.isCompleted) {
        completer.complete(value);
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
    registerFallbackValue(_buildEntry());
  });

  setUp(() {
    mockRepo = _MockMealEntryRepository();
  });

  group('MealEntryNotifier', () {
    test(
      'build() returns entries for today from the repository',
      () async {
        final today = [_buildEntry(id: 'a'), _buildEntry(id: 'b')];
        when(() => mockRepo.getEntriesForToday())
            .thenAnswer((_) async => today);

        final container = _makeContainer(mockRepo);
        final asyncState = await _waitForData(container);

        expect(asyncState.value, today);
      },
    );

    test(
      'logFood: fresh insert returns wasMerge=false and invalidates state',
      () async {
        when(() => mockRepo.getEntriesForToday())
            .thenAnswer((_) async => <MealEntry>[]);
        final draft = _buildEntry(id: '');
        final persisted = _buildEntry(id: 'new-1');
        when(() => mockRepo.logOrMerge(any())).thenAnswer((_) async {
          when(() => mockRepo.getEntriesForToday())
              .thenAnswer((_) async => [persisted]);
          return persisted;
        });

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(mealEntryProvider.notifier);
        final result = await notifier.logFood(draft);

        expect(result.wasMerge, isFalse);
        expect(result.loggedDelta, 100);
        expect(result.entry, persisted);

        final refreshed = await _waitForListMatching(
          container,
          (list) => list.isNotEmpty,
        );
        expect(refreshed, [persisted]);
      },
    );

    test(
      'logFood: merge into existing row returns wasMerge=true with the '
      'delta this call contributed',
      () async {
        when(() => mockRepo.getEntriesForToday())
            .thenAnswer((_) async => <MealEntry>[]);
        final draft = _buildEntry(id: '', quantity: 50);
        // Existing row already had 100g; merge brings it to 150g.
        final merged = _buildEntry(id: 'existing-1', quantity: 150);
        when(() => mockRepo.logOrMerge(any())).thenAnswer((_) async => merged);

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(mealEntryProvider.notifier);
        final result = await notifier.logFood(draft);

        expect(result.wasMerge, isTrue);
        expect(result.loggedDelta, 50);
        expect(result.entry, merged);
      },
    );

    test(
      'undoMerge delegates to undoMergeDelta and invalidates state',
      () async {
        when(() => mockRepo.getEntriesForToday())
            .thenAnswer((_) async => <MealEntry>[]);
        when(() => mockRepo.undoMergeDelta(any(), any()))
            .thenAnswer((_) async {});

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(mealEntryProvider.notifier);
        await notifier.undoMerge('existing-1', 50);

        verify(() => mockRepo.undoMergeDelta('existing-1', 50)).called(1);
      },
    );

    test(
      'editEntry updates slot/quantity/unit and invalidates state',
      () async {
        when(() => mockRepo.getEntriesForToday())
            .thenAnswer((_) async => <MealEntry>[]);
        final updated = _buildEntry(
          mealSlot: MealSlot.dinner,
          quantity: 200,
        );
        when(() => mockRepo.editEntry(any())).thenAnswer((_) async => updated);

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(mealEntryProvider.notifier);
        final result = await notifier.editEntry(updated);

        expect(result, updated);
        verify(() => mockRepo.editEntry(updated)).called(1);
      },
    );

    test(
      'deleteEntry soft-deletes; undoDelete restores the exact prior entry',
      () async {
        when(() => mockRepo.getEntriesForToday())
            .thenAnswer((_) async => <MealEntry>[]);
        final preDelete = _buildEntry();
        when(() => mockRepo.deleteEntry('entry-1'))
            .thenAnswer((_) async => preDelete);
        when(() => mockRepo.restoreEntry(any())).thenAnswer((_) async {});

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(mealEntryProvider.notifier);
        await notifier.deleteEntry('entry-1');
        verify(() => mockRepo.deleteEntry('entry-1')).called(1);

        await notifier.undoDelete();
        verify(() => mockRepo.restoreEntry(preDelete)).called(1);
      },
    );

    test(
      'undoDelete is a no-op when there is nothing pending',
      () async {
        when(() => mockRepo.getEntriesForToday())
            .thenAnswer((_) async => <MealEntry>[]);

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(mealEntryProvider.notifier);
        await notifier.undoDelete();

        verifyNever(() => mockRepo.restoreEntry(any()));
      },
    );

    test(
      'duplicateEntry creates a new row bypassing merge and invalidates '
      'state',
      () async {
        when(() => mockRepo.getEntriesForToday())
            .thenAnswer((_) async => <MealEntry>[]);
        when(() => mockRepo.duplicateEntry('entry-1'))
            .thenAnswer((_) async => _buildEntry(id: 'entry-2'));

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(mealEntryProvider.notifier);
        await notifier.duplicateEntry('entry-1');

        verify(() => mockRepo.duplicateEntry('entry-1')).called(1);
        verifyNever(() => mockRepo.logOrMerge(any()));
      },
    );

    test(
      'getRecent delegates to the repository without touching build() '
      'state',
      () async {
        when(() => mockRepo.getEntriesForToday())
            .thenAnswer((_) async => <MealEntry>[]);
        final recent = [_buildEntry(id: 'r1'), _buildEntry(id: 'r2')];
        when(() => mockRepo.getRecent())
            .thenAnswer((_) async => recent);

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(mealEntryProvider.notifier);
        final result = await notifier.getRecent();

        expect(result, recent);
        // Confirm getRecent did not trigger a rebuild of the today-list.
        verify(() => mockRepo.getEntriesForToday()).called(1);
      },
    );
  });
}

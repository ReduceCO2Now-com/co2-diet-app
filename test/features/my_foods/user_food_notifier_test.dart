// Real unit tests for UserFoodNotifier (replaces Wave 0 stubs).
//
// Uses ProviderContainer + a mocked IUserFoodRepository (mocktail),
// following the ProviderContainer.listen + Completer pattern established in
// test/features/meal_logging/meal_entry_notifier_test.dart.

import 'dart:async';

import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/domain/entities/user_food.dart';
import 'package:co2diet/domain/repositories/i_user_food_repository.dart';
import 'package:co2diet/features/my_foods/providers/user_food_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserFoodRepository extends Mock implements IUserFoodRepository {}

UserFood _buildFood({
  String id = 'food-1',
  String name = 'Test Food',
  double calories = 200,
  String? overrideOfRef,
  String? overrideOfSource,
}) {
  return UserFood(
    id: id,
    name: name,
    calories: calories,
    overrideOfRef: overrideOfRef,
    overrideOfSource: overrideOfSource,
  );
}

/// Builds a [ProviderContainer] with [IUserFoodRepository] overridden to
/// the given mock instance. Registered for automatic disposal at test end.
ProviderContainer _makeContainer(_MockUserFoodRepository mockRepo) {
  final container = ProviderContainer(
    overrides: [
      userFoodRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Awaits the first non-loading [AsyncValue] from [userFoodProvider].
Future<AsyncValue<List<UserFood>>> _waitForData(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<AsyncValue<List<UserFood>>>();

  final sub = container.listen<AsyncValue<List<UserFood>>>(
    userFoodProvider,
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

/// Awaits the first [AsyncValue] from [userFoodProvider] whose data
/// satisfies [predicate]. Used after a mutation (which calls
/// `ref.invalidateSelf()`) to deterministically wait for the
/// *post-mutation* rebuild.
Future<List<UserFood>> _waitForListMatching(
  ProviderContainer container,
  bool Function(List<UserFood>) predicate, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<List<UserFood>>();

  final sub = container.listen<AsyncValue<List<UserFood>>>(
    userFoodProvider,
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
  late _MockUserFoodRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(_buildFood());
  });

  setUp(() {
    mockRepo = _MockUserFoodRepository();
  });

  group('UserFoodNotifier', () {
    test(
      'build() returns the alphabetical My Foods list from the repository',
      () async {
        final foods = [_buildFood(id: 'a'), _buildFood(id: 'b')];
        when(() => mockRepo.getAllAlphabetical())
            .thenAnswer((_) async => foods);

        final container = _makeContainer(mockRepo);
        final asyncState = await _waitForData(container);

        expect(asyncState.value, foods);
      },
    );

    test(
      'saveCustomFood persists and refreshes the My Foods list',
      () async {
        when(() => mockRepo.getAllAlphabetical())
            .thenAnswer((_) async => <UserFood>[]);
        final draft = _buildFood(id: '');
        final saved = _buildFood(id: 'new-1');
        when(() => mockRepo.saveCustomFood(any())).thenAnswer((_) async {
          when(() => mockRepo.getAllAlphabetical())
              .thenAnswer((_) async => [saved]);
          return saved;
        });

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(userFoodProvider.notifier);
        final result = await notifier.saveCustomFood(draft);

        expect(result, saved);
        verify(() => mockRepo.saveCustomFood(draft)).called(1);

        final refreshed = await _waitForListMatching(
          container,
          (list) => list.isNotEmpty,
        );
        expect(refreshed, [saved]);
      },
    );

    test(
      'saveOverride persists an override tied to '
      'overrideOfRef/overrideOfSource',
      () async {
        when(() => mockRepo.getAllAlphabetical())
            .thenAnswer((_) async => <UserFood>[]);
        final draft = _buildFood(
          id: '',
          overrideOfRef: 'off-ref-1',
          overrideOfSource: 'off_ref',
        );
        final saved = _buildFood(
          id: 'override-1',
          overrideOfRef: 'off-ref-1',
          overrideOfSource: 'off_ref',
        );
        when(() => mockRepo.saveOverride(any()))
            .thenAnswer((_) async => saved);

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(userFoodProvider.notifier);
        final result = await notifier.saveOverride(draft);

        expect(result, saved);
        expect(result.overrideOfRef, 'off-ref-1');
        expect(result.overrideOfSource, 'off_ref');
        verify(() => mockRepo.saveOverride(draft)).called(1);
      },
    );

    test(
      'revertOverride removes the override and invalidates the list so '
      'the original reappears',
      () async {
        final override = _buildFood(
          id: 'override-1',
          overrideOfRef: 'off-ref-1',
          overrideOfSource: 'off_ref',
        );
        when(() => mockRepo.getAllAlphabetical())
            .thenAnswer((_) async => [override]);
        when(() => mockRepo.revertOverride('override-1'))
            .thenAnswer((_) async {
          when(() => mockRepo.getAllAlphabetical())
              .thenAnswer((_) async => <UserFood>[]);
        });

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(userFoodProvider.notifier);
        await notifier.revertOverride('override-1');

        verify(() => mockRepo.revertOverride('override-1')).called(1);

        final refreshed = await _waitForListMatching(
          container,
          (list) => list.isEmpty,
        );
        expect(refreshed, isEmpty);
      },
    );

    test(
      'findOverrideForFoodRef delegates to the repository without '
      'touching build() state',
      () async {
        when(() => mockRepo.getAllAlphabetical())
            .thenAnswer((_) async => <UserFood>[]);
        final override = _buildFood(id: 'override-1');
        when(() => mockRepo.findOverrideForFoodRef('food-1', 'off_ref'))
            .thenAnswer((_) async => override);

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(userFoodProvider.notifier);
        final result = await notifier.findOverrideForFoodRef(
          'food-1',
          'off_ref',
        );

        expect(result, override);
        verify(() => mockRepo.getAllAlphabetical()).called(1);
      },
    );
  });
}

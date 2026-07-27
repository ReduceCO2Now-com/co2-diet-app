// Real unit tests for WeightNotifier (replaces Wave 0 stub).
//
// Uses ProviderContainer + a mocked IWeightRepository (mocktail), following
// the ProviderContainer.listen + Completer pattern established in
// test/features/co2_settings/co2_settings_notifier_test.dart.

import 'dart:async';

import 'package:co2diet/core/di/weight_providers.dart';
import 'package:co2diet/domain/entities/weight_entry.dart';
import 'package:co2diet/domain/entities/weight_settings.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:co2diet/domain/repositories/i_weight_repository.dart';
import 'package:co2diet/features/weight/providers/weight_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWeightRepository extends Mock implements IWeightRepository {}

/// Builds a [ProviderContainer] with [IWeightRepository] overridden to the
/// given mock instance. Registered for automatic disposal at test end.
ProviderContainer _makeContainer(_MockWeightRepository mockRepo) {
  final container = ProviderContainer(
    overrides: [weightRepositoryProvider.overrideWithValue(mockRepo)],
  );
  addTearDown(container.dispose);
  return container;
}

/// Awaits the first non-loading [AsyncValue] from [weightProvider].
Future<AsyncValue<WeightState>> _waitForData(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<AsyncValue<WeightState>>();

  final sub = container.listen<AsyncValue<WeightState>>(weightProvider, (
    prev,
    next,
  ) {
    if (next is! AsyncLoading && !completer.isCompleted) {
      completer.complete(next);
    }
  }, fireImmediately: true);

  try {
    return await completer.future.timeout(timeout);
  } finally {
    sub.close();
  }
}

/// Awaits the first [AsyncValue] from [weightProvider] whose data satisfies
/// [predicate]. Used after a mutation (which calls `ref.invalidateSelf()`)
/// to deterministically wait for the *post-mutation* rebuild.
Future<WeightState> _waitForMatching(
  ProviderContainer container,
  bool Function(WeightState) predicate, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<WeightState>();

  final sub = container.listen<AsyncValue<WeightState>>(weightProvider, (
    prev,
    next,
  ) {
    final value = next.value;
    if (value != null && predicate(value) && !completer.isCompleted) {
      completer.complete(value);
    }
  }, fireImmediately: true);

  try {
    return await completer.future.timeout(timeout);
  } finally {
    sub.close();
  }
}

WeightEntry _buildEntry({String id = 'w1', double value = 80}) => WeightEntry(
  id: id,
  value: value,
  unit: WeightUnit.kg,
  loggedAt: DateTime.utc(2026),
);

void main() {
  late _MockWeightRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(_buildEntry());
    registerFallbackValue(WeightRange.all);
  });

  setUp(() {
    mockRepo = _MockWeightRepository();
  });

  group('WeightNotifier', () {
    test(
      'build() loads all weight entries and current goal/reminder '
      'settings together',
      () async {
        final entries = [_buildEntry(), _buildEntry(id: 'w2', value: 79)];
        const settings = WeightSettings(
          targetWeightKg: 75,
          reminderFrequency: 'weekly',
          reminderEnabled: true,
        );
        when(
          () => mockRepo.getEntriesInRange(WeightRange.all),
        ).thenAnswer((_) async => entries);
        when(
          () => mockRepo.getSettings(),
        ).thenAnswer((_) async => settings);

        final container = _makeContainer(mockRepo);
        final asyncState = await _waitForData(container);

        expect(asyncState.value!.entries, entries);
        expect(asyncState.value!.settings, settings);
        verify(() => mockRepo.getEntriesInRange(WeightRange.all)).called(1);
        verify(() => mockRepo.getSettings()).called(1);
      },
    );

    test(
      'logWeight appends a new entry and refreshes the chart-backing list',
      () async {
        when(
          () => mockRepo.getEntriesInRange(WeightRange.all),
        ).thenAnswer((_) async => [_buildEntry()]);
        when(
          () => mockRepo.getSettings(),
        ).thenAnswer((_) async => const WeightSettings());
        when(
          () => mockRepo.logWeight(any()),
        ).thenAnswer((_) async => _buildEntry(id: 'w2', value: 79));

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        // After logging, the repository's next getEntriesInRange call
        // returns both entries.
        when(() => mockRepo.getEntriesInRange(WeightRange.all)).thenAnswer(
          (_) async => [_buildEntry(), _buildEntry(id: 'w2', value: 79)],
        );

        final notifier = container.read(weightProvider.notifier);
        await notifier.logWeight(_buildEntry(id: 'w2', value: 79));

        verify(() => mockRepo.logWeight(any())).called(1);

        final refreshed = await _waitForMatching(
          container,
          (state) => state.entries.length == 2,
        );
        expect(refreshed.entries.map((e) => e.id), containsAll(['w1', 'w2']));
      },
    );

    test(
      'saveGoal persists and refreshes independently of reminder settings',
      () async {
        when(
          () => mockRepo.getEntriesInRange(WeightRange.all),
        ).thenAnswer((_) async => <WeightEntry>[]);
        when(
          () => mockRepo.getSettings(),
        ).thenAnswer((_) async => const WeightSettings());
        when(
          () => mockRepo.saveGoal(
            targetWeightKg: any(named: 'targetWeightKg'),
            targetDate: any(named: 'targetDate'),
          ),
        ).thenAnswer((_) async {});

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final targetDate = DateTime.utc(2026, 12, 31);
        when(() => mockRepo.getSettings()).thenAnswer(
          (_) async =>
              WeightSettings(targetWeightKg: 75, targetDate: targetDate),
        );

        final notifier = container.read(weightProvider.notifier);
        await notifier.saveGoal(targetWeightKg: 75, targetDate: targetDate);

        verify(
          () => mockRepo.saveGoal(
            targetWeightKg: 75,
            targetDate: targetDate,
          ),
        ).called(1);

        final refreshed = await _waitForMatching(
          container,
          (state) => state.settings.targetWeightKg == 75,
        );
        expect(refreshed.settings.targetDate, targetDate);
      },
    );

    test(
      'saveReminderSettings persists and refreshes independently of goal '
      'fields',
      () async {
        when(
          () => mockRepo.getEntriesInRange(WeightRange.all),
        ).thenAnswer((_) async => <WeightEntry>[]);
        when(
          () => mockRepo.getSettings(),
        ).thenAnswer((_) async => const WeightSettings());
        when(
          () => mockRepo.saveReminderSettings(
            frequency: any(named: 'frequency'),
            enabled: any(named: 'enabled'),
            weekday: any(named: 'weekday'),
            time: any(named: 'time'),
          ),
        ).thenAnswer((_) async {});

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        when(() => mockRepo.getSettings()).thenAnswer(
          (_) async => const WeightSettings(
            reminderFrequency: 'weekly',
            reminderEnabled: true,
          ),
        );

        final notifier = container.read(weightProvider.notifier);
        await notifier.saveReminderSettings(
          frequency: 'weekly',
          enabled: true,
        );

        verify(
          () => mockRepo.saveReminderSettings(
            frequency: 'weekly',
            enabled: true,
          ),
        ).called(1);

        final refreshed = await _waitForMatching(
          container,
          (state) => state.settings.reminderEnabled,
        );
        expect(refreshed.settings.reminderFrequency, 'weekly');
      },
    );

    test(
      'entriesForRange re-queries the repository directly without '
      'affecting the notifier state',
      () async {
        when(
          () => mockRepo.getEntriesInRange(WeightRange.all),
        ).thenAnswer((_) async => [_buildEntry()]);
        when(
          () => mockRepo.getSettings(),
        ).thenAnswer((_) async => const WeightSettings());

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final sevenDayEntries = [_buildEntry(id: 'w2', value: 79)];
        when(
          () => mockRepo.getEntriesInRange(WeightRange.sevenDay),
        ).thenAnswer((_) async => sevenDayEntries);

        final notifier = container.read(weightProvider.notifier);
        final result = await notifier.entriesForRange(WeightRange.sevenDay);

        expect(result, sevenDayEntries);
        // Notifier's own state is untouched by this on-demand query.
        expect(container.read(weightProvider).value!.entries, hasLength(1));
      },
    );
  });
}

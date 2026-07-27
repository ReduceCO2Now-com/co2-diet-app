// Real unit tests for Co2SettingsNotifier (replaces Wave 0 stub).
//
// Uses ProviderContainer + a mocked ICo2SettingsRepository (mocktail),
// following the ProviderContainer.listen + Completer pattern established in
// test/features/meal_logging/meal_entry_notifier_test.dart.

import 'dart:async';

import 'package:co2diet/core/di/co2_settings_providers.dart';
import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:co2diet/domain/repositories/i_co2_settings_repository.dart';
import 'package:co2diet/features/co2_settings/providers/co2_settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCo2SettingsRepository extends Mock
    implements ICo2SettingsRepository {}

/// Builds a [ProviderContainer] with [ICo2SettingsRepository] overridden to
/// the given mock instance. Registered for automatic disposal at test end.
ProviderContainer _makeContainer(_MockCo2SettingsRepository mockRepo) {
  final container = ProviderContainer(
    overrides: [
      co2SettingsRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Awaits the first non-loading [AsyncValue] from [co2SettingsProvider].
Future<AsyncValue<Co2Settings>> _waitForData(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<AsyncValue<Co2Settings>>();

  final sub = container.listen<AsyncValue<Co2Settings>>(
    co2SettingsProvider,
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

/// Awaits the first [AsyncValue] from [co2SettingsProvider] whose data
/// satisfies [predicate]. Used after a mutation (which calls
/// `ref.invalidateSelf()`) to deterministically wait for the
/// *post-mutation* rebuild.
Future<Co2Settings> _waitForMatching(
  ProviderContainer container,
  bool Function(Co2Settings) predicate, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<Co2Settings>();

  final sub = container.listen<AsyncValue<Co2Settings>>(
    co2SettingsProvider,
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
  late _MockCo2SettingsRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const Co2Settings());
  });

  setUp(() {
    mockRepo = _MockCo2SettingsRepository();
  });

  group('Co2SettingsNotifier', () {
    test(
      'build() loads current settings from the repository',
      () async {
        const settings = Co2Settings(
          locationCountry: 'DE',
          householdSize: 2,
        );
        when(() => mockRepo.getSettings()).thenAnswer((_) async => settings);

        final container = _makeContainer(mockRepo);
        final asyncState = await _waitForData(container);

        expect(asyncState.value, settings);
      },
    );

    test(
      'build() returns the all-null default when no settings have ever '
      'been saved',
      () async {
        when(() => mockRepo.getSettings())
            .thenAnswer((_) async => const Co2Settings());

        final container = _makeContainer(mockRepo);
        final asyncState = await _waitForData(container);

        expect(asyncState.value, const Co2Settings());
      },
    );

    test(
      'saveSettings persists and re-runs build() so the notifier reflects '
      'the freshly saved state',
      () async {
        when(() => mockRepo.getSettings())
            .thenAnswer((_) async => const Co2Settings());
        const saved = Co2Settings(
          locationCountry: 'AT',
          purchasingSource: 'local_farm',
        );
        when(() => mockRepo.saveSettings(any())).thenAnswer((_) async {
          when(() => mockRepo.getSettings())
              .thenAnswer((_) async => saved);
        });

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(co2SettingsProvider.notifier);
        await notifier.saveSettings(saved);

        verify(() => mockRepo.saveSettings(saved)).called(1);

        final refreshed = await _waitForMatching(
          container,
          (settings) => settings.locationCountry == 'AT',
        );
        expect(refreshed, saved);
      },
    );
  });
}

// Real unit tests for ProfileNotifier's save-path behavior.
//
// Uses ProviderContainer + a mocked IProfileRepository (mocktail), following
// the same pattern established in
// test/features/co2_settings/co2_settings_notifier_test.dart.

import 'dart:async';

import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/domain/entities/user_profile.dart';
import 'package:co2diet/domain/repositories/i_profile_repository.dart';
import 'package:co2diet/features/profile/providers/profile_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements IProfileRepository {}

ProviderContainer _makeContainer(_MockProfileRepository mockRepo) {
  final container = ProviderContainer(
    overrides: [profileRepositoryProvider.overrideWithValue(mockRepo)],
  );
  addTearDown(container.dispose);
  return container;
}

/// Awaits the first non-loading [AsyncValue] from [profileProvider].
Future<AsyncValue<UserProfile?>> _waitForData(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<AsyncValue<UserProfile?>>();

  final sub = container.listen<AsyncValue<UserProfile?>>(
    profileProvider,
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
  late _MockProfileRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const UserProfile(id: ''));
  });

  setUp(() {
    mockRepo = _MockProfileRepository();
  });

  group('ProfileNotifier', () {
    test(
      'saveProfile never emits an AsyncLoading state (regression: '
      'auto-save-on-keystroke must not swap the whole screen to a '
      'spinner)',
      () async {
        // Regression test for a real device-testing-only bug: saveProfile
        // used to set `state = const AsyncValue.loading()` before the
        // write completed. Since ProfileScreen gates its body on
        // `.when(loading: () => CircularProgressIndicator(), data: ...)`,
        // and this method fires on every single keystroke via
        // ProfileForm's auto-save onChanged, that loading state made the
        // *entire* screen body (every field, not just one) get torn down
        // and rebuilt on every keystroke -- an even more severe version
        // of the per-field ValueKey bug, and the reason focus/keyboard
        // loss persisted intermittently even after that fix (timing-
        // dependent on how fast the write actually completes).
        when(mockRepo.getProfile).thenAnswer((_) async => null);
        when(() => mockRepo.saveProfile(any())).thenAnswer((_) async {});

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final emitted = <AsyncValue<UserProfile?>>[];
        final sub = container.listen<AsyncValue<UserProfile?>>(
          profileProvider,
          (prev, next) => emitted.add(next),
        );
        addTearDown(sub.close);

        final notifier = container.read(profileProvider.notifier);
        await notifier.saveProfile(const UserProfile(id: '', age: 30));

        expect(
          emitted.whereType<AsyncLoading<UserProfile?>>(),
          isEmpty,
          reason:
              'saveProfile emitted an AsyncLoading state mid-save -- this '
              'would swap the whole ProfileScreen body to a spinner on '
              'every keystroke, dropping focus regardless of any '
              'per-field key fix.',
        );
      },
    );

    test(
      'saveProfile persists and re-runs build() so the notifier reflects '
      'the freshly saved state',
      () async {
        when(mockRepo.getProfile).thenAnswer((_) async => null);
        const saved = UserProfile(id: 'p1', age: 30);
        when(() => mockRepo.saveProfile(any())).thenAnswer((_) async {
          when(mockRepo.getProfile).thenAnswer((_) async => saved);
        });

        final container = _makeContainer(mockRepo);
        await _waitForData(container);

        final notifier = container.read(profileProvider.notifier);
        await notifier.saveProfile(saved);

        verify(() => mockRepo.saveProfile(saved)).called(1);

        final completer = Completer<UserProfile?>();
        final sub = container.listen<AsyncValue<UserProfile?>>(
          profileProvider,
          (prev, next) {
            if (next.value?.age == 30 && !completer.isCompleted) {
              completer.complete(next.value);
            }
          },
          fireImmediately: true,
        );
        addTearDown(sub.close);
        final refreshed = await completer.future.timeout(
          const Duration(seconds: 5),
        );

        expect(refreshed?.age, 30);
      },
    );
  });
}

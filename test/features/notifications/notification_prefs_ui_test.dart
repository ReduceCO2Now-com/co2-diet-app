import 'dart:async';

import 'package:co2diet/core/di/notification_providers.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/notification_prefs.dart';
import 'package:co2diet/domain/repositories/i_notification_prefs_repository.dart';
import 'package:co2diet/domain/services/notification_service.dart';
import 'package:co2diet/features/notifications/providers/notification_prefs_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationPrefsRepository extends Mock
    implements INotificationPrefsRepository {}

class _MockNotificationService extends Mock implements NotificationService {}

/// Builds a [ProviderContainer] with both [INotificationPrefsRepository]
/// and [NotificationService] overridden to the given mocks. Registered for
/// automatic disposal at test end.
ProviderContainer _makeContainer(
  _MockNotificationPrefsRepository mockRepo,
  _MockNotificationService mockService,
) {
  final container = ProviderContainer(
    overrides: [
      notificationPrefsRepositoryProvider.overrideWithValue(mockRepo),
      notificationServiceProvider.overrideWithValue(mockService),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Awaits the first non-loading [AsyncValue] from [notificationPrefsProvider].
Future<AsyncValue<NotificationPrefs>> _waitForData(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<AsyncValue<NotificationPrefs>>();

  final sub = container.listen<AsyncValue<NotificationPrefs>>(
    notificationPrefsProvider,
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
  late _MockNotificationPrefsRepository mockRepo;
  late _MockNotificationService mockService;

  setUpAll(() {
    registerFallbackValue(const NotificationPrefs());
    registerFallbackValue(MealSlot.breakfast);
  });

  setUp(() {
    mockRepo = _MockNotificationPrefsRepository();
    mockService = _MockNotificationService();
  });

  group('NotificationPrefsNotifier', () {
    test('build() loads the current NotificationPrefs', () async {
      const prefs = NotificationPrefs(
        breakfastEnabled: true,
        breakfastTime: '07:30',
      );
      when(() => mockRepo.getPrefs()).thenAnswer((_) async => prefs);

      final container = _makeContainer(mockRepo, mockService);
      final asyncState = await _waitForData(container);

      expect(asyncState.value, prefs);
      verify(() => mockRepo.getPrefs()).called(1);
    });

    test(
      'setSlotEnabled requests permission before persisting/scheduling '
      'when enabling',
      () async {
        when(
          () => mockRepo.getPrefs(),
        ).thenAnswer((_) async => const NotificationPrefs());
        when(
          () => mockService.requestPermissionIfNeeded(),
        ).thenAnswer((_) async => true);
        when(() => mockRepo.savePrefs(any())).thenAnswer((_) async {});
        when(
          () => mockService.scheduleMealReminder(any(), any()),
        ).thenAnswer((_) async => true);

        final container = _makeContainer(mockRepo, mockService);
        await _waitForData(container);

        final notifier = container.read(notificationPrefsProvider.notifier);
        final result = await notifier.setSlotEnabled(
          MealSlot.lunch,
          true,
          time: '12:00',
        );

        expect(result, isTrue);
        verify(() => mockService.requestPermissionIfNeeded()).called(1);

        final captured = verify(
          () => mockRepo.savePrefs(captureAny()),
        ).captured;
        final saved = captured.single as NotificationPrefs;
        expect(saved.lunchEnabled, isTrue);
        expect(saved.lunchTime, '12:00');
        verify(
          () => mockService.scheduleMealReminder(MealSlot.lunch, '12:00'),
        ).called(1);
      },
    );

    test(
      'setSlotEnabled returns false and does not persist/schedule when '
      'permission is denied',
      () async {
        when(
          () => mockRepo.getPrefs(),
        ).thenAnswer((_) async => const NotificationPrefs());
        when(
          () => mockService.requestPermissionIfNeeded(),
        ).thenAnswer((_) async => false);

        final container = _makeContainer(mockRepo, mockService);
        await _waitForData(container);

        final notifier = container.read(notificationPrefsProvider.notifier);
        final result = await notifier.setSlotEnabled(
          MealSlot.dinner,
          true,
          time: '19:00',
        );

        expect(result, isFalse);
        verifyNever(() => mockRepo.savePrefs(any()));
        verifyNever(() => mockService.scheduleMealReminder(any(), any()));
      },
    );

    test(
      'setSlotEnabled(false) cancels the reminder and persists without a '
      'permission check',
      () async {
        const initial = NotificationPrefs(
          snackEnabled: true,
          snackTime: '16:00',
        );
        when(() => mockRepo.getPrefs()).thenAnswer((_) async => initial);
        when(() => mockRepo.savePrefs(any())).thenAnswer((_) async {});
        when(
          () => mockService.cancelMealReminder(any()),
        ).thenAnswer((_) async {});

        final container = _makeContainer(mockRepo, mockService);
        await _waitForData(container);

        final notifier = container.read(notificationPrefsProvider.notifier);
        final result = await notifier.setSlotEnabled(MealSlot.snack, false);

        expect(result, isTrue);
        verifyNever(() => mockService.requestPermissionIfNeeded());
        verify(
          () => mockService.cancelMealReminder(MealSlot.snack),
        ).called(1);

        final captured = verify(
          () => mockRepo.savePrefs(captureAny()),
        ).captured;
        final saved = captured.single as NotificationPrefs;
        expect(saved.snackEnabled, isFalse);
      },
    );
  });

  group(
    'Meal reminder settings section',
    skip: 'meal reminder settings UI not yet implemented',
    () {
      testWidgets(
        'each of the four meal slots has an independent enable '
        'toggle and time picker',
        (tester) async {},
      );

      testWidgets(
        'toggling a reminder on when permission is denied reverts '
        'the toggle and shows an Open Settings link',
        (tester) async {},
      );
    },
  );
}

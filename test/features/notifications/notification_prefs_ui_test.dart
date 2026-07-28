import 'dart:async';

import 'package:co2diet/core/di/notification_providers.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/notification_prefs.dart';
import 'package:co2diet/domain/repositories/i_notification_prefs_repository.dart';
import 'package:co2diet/domain/services/notification_service.dart';
import 'package:co2diet/features/notifications/providers/notification_prefs_notifier.dart';
import 'package:co2diet/features/notifications/widgets/meal_reminder_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// In-memory fake repository -- mirrors `_FakeWeightRepository`'s
/// precedent (Plan 05-13): a saved value is reflected on the next
/// `getPrefs()` call, which a mocktail `Mock` would require per-call
/// stubbing to achieve across the widget tree's multiple rows.
class _FakeNotificationPrefsRepository implements INotificationPrefsRepository {
  NotificationPrefs _prefs = const NotificationPrefs();

  @override
  Future<NotificationPrefs> getPrefs() async => _prefs;

  @override
  Future<void> savePrefs(NotificationPrefs prefs) async => _prefs = prefs;
}

Widget _buildTestable(
  INotificationPrefsRepository repo,
  NotificationService service,
) {
  return ProviderScope(
    overrides: [
      notificationPrefsRepositoryProvider.overrideWithValue(repo),
      notificationServiceProvider.overrideWithValue(service),
    ],
    child: const MaterialApp(
      home: Scaffold(body: MealReminderSettingsSection()),
    ),
  );
}

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

  group('Meal reminder settings section', () {
    testWidgets(
      'each of the four meal slots has an independent enable '
      'toggle and time picker',
      (tester) async {
        final repo = _FakeNotificationPrefsRepository();
        final service = _MockNotificationService();
        when(
          service.requestPermissionIfNeeded,
        ).thenAnswer((_) async => true);
        when(
          () => service.scheduleMealReminder(any(), any()),
        ).thenAnswer((_) async => true);
        when(
          () => service.cancelMealReminder(any()),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(_buildTestable(repo, service));
        await tester.pumpAndSettle();

        expect(find.text('Breakfast'), findsOneWidget);
        expect(find.text('Lunch'), findsOneWidget);
        expect(find.text('Dinner'), findsOneWidget);
        expect(find.text('Snack'), findsOneWidget);
        expect(find.byType(Switch), findsNWidgets(4));

        // MealSlot.values order: breakfast, lunch, dinner, snack. Toggle
        // only Lunch's switch on; the other three rows stay off and
        // remain independently controllable.
        final switches = find.byType(Switch);
        await tester.tap(switches.at(1));
        await tester.pumpAndSettle();

        expect(tester.widget<Switch>(switches.at(0)).value, isFalse);
        expect(tester.widget<Switch>(switches.at(1)).value, isTrue);
        expect(tester.widget<Switch>(switches.at(2)).value, isFalse);
        expect(tester.widget<Switch>(switches.at(3)).value, isFalse);

        verify(
          () => service.scheduleMealReminder(MealSlot.lunch, any()),
        ).called(1);
      },
    );

    testWidgets(
      'toggling a reminder on when permission is denied reverts '
      'the toggle and shows an Open Settings link',
      (tester) async {
        final repo = _FakeNotificationPrefsRepository();
        final service = _MockNotificationService();
        when(
          service.requestPermissionIfNeeded,
        ).thenAnswer((_) async => false);

        await tester.pumpWidget(_buildTestable(repo, service));
        await tester.pumpAndSettle();

        final switches = find.byType(Switch);
        // Toggle Breakfast (first row) on -- permission will be denied.
        await tester.tap(switches.at(0));
        await tester.pumpAndSettle();

        expect(tester.widget<Switch>(switches.at(0)).value, isFalse);
        expect(
          find.textContaining('Notifications are disabled'),
          findsOneWidget,
        );
        expect(find.text('Open Settings'), findsOneWidget);

        // Only the denied row shows the recovery link -- the other three
        // rows are untouched.
        expect(
          find.textContaining('Notifications are disabled'),
          findsNWidgets(1),
        );
      },
    );
  });
}

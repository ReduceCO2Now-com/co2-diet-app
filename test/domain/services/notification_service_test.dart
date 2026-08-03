import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/services/notification_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class _MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

const _permissionChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);

    // Fallback values for `any()` matchers on non-nullable, non-core types
    // (bool/int/double/String/List/Map/Set/DateTime already have mocktail
    // built-in fallbacks -- see mocktail's `_fallbackValues`).
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(
      const NotificationDetails(
        android: AndroidNotificationDetails('fallback_channel', 'Fallback'),
      ),
    );
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
  });

  late _MockFlutterLocalNotificationsPlugin mockPlugin;
  late NotificationService service;

  setUp(() {
    mockPlugin = _MockFlutterLocalNotificationsPlugin();
    service = NotificationService(mockPlugin);

    when(
      () => mockPlugin.zonedSchedule(
        id: any(named: 'id'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockPlugin.cancel(id: any(named: 'id')),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_permissionChannel, null);
  });

  group('NotificationService', () {
    test(
      'scheduleMealReminder calls zonedSchedule with '
      'matchDateTimeComponents: time and androidScheduleMode: '
      'exactAllowWhileIdle',
      () async {
        final result = await service.scheduleMealReminder(
          MealSlot.breakfast,
          '08:00',
        );

        expect(result, isTrue);
        verify(
          () => mockPlugin.zonedSchedule(
            id: 100 + MealSlot.breakfast.index,
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: '/food-search?slot=breakfast',
            matchDateTimeComponents: DateTimeComponents.time,
          ),
        ).called(1);
      },
    );

    test(
      'cancelMealReminder cancels the stable per-slot notification id',
      () async {
        await service.cancelMealReminder(MealSlot.lunch);

        verify(
          () => mockPlugin.cancel(id: 100 + MealSlot.lunch.index),
        ).called(1);
      },
    );

    test(
      'scheduleWeighInReminder for Custom frequency uses '
      'matchDateTimeComponents: dayOfWeekAndTime with the chosen '
      'weekday',
      () async {
        final result = await service.scheduleWeighInReminder(
          frequency: 'custom',
          weekday: DateTime.monday,
          time: '07:30',
        );

        expect(result, isTrue);
        verify(
          () => mockPlugin.zonedSchedule(
            id: 200,
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: '/weight-tracking',
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          ),
        ).called(1);
      },
    );

    test(
      'scheduleWeighInReminder is safe to call repeatedly -- a '
      'second call replaces rather than duplicates the pending '
      'schedule',
      () async {
        await service.scheduleWeighInReminder(
          frequency: 'monthly',
          time: '09:00',
        );
        await service.scheduleWeighInReminder(
          frequency: 'monthly',
          time: '09:00',
        );

        // Both calls use the exact same stable weigh-in id (200) -- this
        // is what makes the second call *replace* rather than duplicate
        // the pending schedule.
        verify(
          () => mockPlugin.zonedSchedule(
            id: 200,
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).called(2);
      },
    );

    test(
      'requestPermissionIfNeeded is only invoked when a toggle is '
      'first enabled, never on service construction',
      () async {
        final calls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_permissionChannel, (call) async {
              calls.add(call);
              if (call.method == 'checkPermissionStatus') {
                return 1; // PermissionStatus.granted
              }
              return null;
            });

        // Service was already constructed (and would have been
        // `initialize()`-equivalent configured) in `setUp()` above without
        // ever touching the permission_handler channel.
        expect(calls, isEmpty);

        final granted = await service.requestPermissionIfNeeded();

        expect(granted, isTrue);
        expect(calls, hasLength(1));
        expect(calls.single.method, 'checkPermissionStatus');
      },
    );

    test(
      'permission denied leaves the reminder disabled and surfaces '
      'a recoverable state (no full-screen block)',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_permissionChannel, (call) async {
              if (call.method == 'checkPermissionStatus') {
                return 0; // PermissionStatus.denied
              }
              if (call.method == 'requestPermissions') {
                return <int, int>{Permission.notification.value: 0};
              }
              return null;
            });

        final granted = await service.requestPermissionIfNeeded();
        expect(granted, isFalse);

        // A `PlatformException` from the plugin (e.g. OS-level permission
        // denial surfacing through `zonedSchedule` itself) never
        // propagates -- callers interpret a `false` result as "revert the
        // toggle, show Open Settings link" (CONTEXT.md permission-denied
        // UX), not an unhandled exception / full-screen crash.
        when(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).thenThrow(PlatformException(code: 'permission_denied'));

        final scheduled = await service.scheduleMealReminder(
          MealSlot.dinner,
          '18:30',
        );
        expect(scheduled, isFalse);
      },
    );
  });
}

import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/services/notification_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/timezone.dart' as tz;

const _flutterTimezoneChannel = MethodChannel('flutter_timezone');

/// Fake fallback for mocktail's `any(named: 'scheduledDate')` matcher --
/// deliberately NOT a real `tz.TZDateTime.now(tz.local)` instance, since
/// constructing one requires `tz.local` to already be initialized, which
/// is exactly the thing this test file must NOT do ahead of time.
class _FakeTZDateTime extends Fake implements tz.TZDateTime {}

/// Deliberately isolated from `notification_service_test.dart`, whose
/// `setUpAll` calls `tz_data.initializeTimeZones()` +
/// `tz.setLocalLocation(tz.UTC)` before every test in that file -- which
/// masks the fact that `NotificationService.initialize()` itself never
/// does this. `timezone`'s `tz.local` is a package-global `late` field
/// with no initializer (see timezone-0.11.1/lib/src/env.dart), so a fresh
/// Dart VM that never calls `setLocalLocation` reproduces exactly what a
/// real cold-started app does (`main.dart` only calls
/// `NotificationService.initialize()`, nothing else touches `tz.local`).
class _MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    registerFallbackValue(_FakeTZDateTime());
    registerFallbackValue(
      const NotificationDetails(
        android: AndroidNotificationDetails('fallback_channel', 'Fallback'),
      ),
    );
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
  });

  test(
    'scheduleMealReminder does not crash with an uninitialized timezone '
    'database (UAT bug: enabling a meal reminder never fires -- '
    'NotificationService.initialize() never calls '
    'tz_data.initializeTimeZones()/tz.setLocalLocation, so tz.local is '
    'read before ever being set)',
    () async {
      final mockPlugin = _MockFlutterLocalNotificationsPlugin();
      when(
        () => mockPlugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(
            named: 'onDidReceiveNotificationResponse',
          ),
        ),
      ).thenAnswer((_) async => true);
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

      final service = NotificationService(mockPlugin);
      await service.initialize();

      final result = await service.scheduleMealReminder(
        MealSlot.breakfast,
        '08:00',
      );

      expect(
        result,
        isTrue,
        reason:
            'scheduleMealReminder should succeed after initialize() -- if '
            'this throws instead of returning false/true, the timezone '
            'database was never initialized before tz.local was read.',
      );
    },
  );

  test(
    'initialize() sets tz.local to the real device timezone when '
    'flutter_timezone resolves one, not just the UTC fallback',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_flutterTimezoneChannel, (call) async {
            if (call.method == 'getLocalTimezone') return 'Europe/Berlin';
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding
            .instance
            .defaultBinaryMessenger
            .setMockMethodCallHandler(_flutterTimezoneChannel, null),
      );

      final mockPlugin = _MockFlutterLocalNotificationsPlugin();
      when(
        () => mockPlugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(
            named: 'onDidReceiveNotificationResponse',
          ),
        ),
      ).thenAnswer((_) async => true);

      await NotificationService(mockPlugin).initialize();

      expect(tz.local.name, 'Europe/Berlin');
    },
  );
}

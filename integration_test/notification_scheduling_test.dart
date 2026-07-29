// Real-device evidence for the UAT Test 5/6 notification bug
// (deferred-items.md / 05-UAT.md Gaps: "Meal and weigh-in reminders
// actually fire").
//
// Unlike test/domain/services/notification_service_test.dart (mocked
// plugin, no real platform channels) and
// test/domain/services/notification_service_timezone_test.dart (mocked
// plugin, mocked flutter_timezone channel), this test uses a REAL
// FlutterLocalNotificationsPlugin and the REAL flutter_timezone platform
// channel on whatever device this runs on. It does not wait for a
// notification to actually fire (that's what the user is manually
// verifying) -- instead it queries the OS directly via
// pendingNotificationRequests() immediately after scheduling, which is
// the same source of truth Android/iOS itself uses. If this test passes,
// the OS has genuinely accepted and queued the notification; if it
// fails, the bug is real and reproducible independent of any theory.
//
// Run on the connected device:
//   flutter test integration_test/notification_scheduling_test.dart
//       --device-id <id>
//
// Also watch `adb logcat | grep NotificationService` (Android) while this
// runs to see NotificationService's own debugPrint trail (device
// timezone resolution, computed scheduledDate, tz.local, and any
// exception) -- the same log lines that fire when a user flips a
// reminder toggle in the real app.

import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/timezone.dart' as tz;

String _formatHHmm(DateTime t) {
  final hour = t.hour.toString().padLeft(2, '0');
  final minute = t.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'NotificationService.initialize() resolves the real device timezone, '
    'and scheduleMealReminder/scheduleWeighInReminder actually register a '
    'pending notification with the OS',
    (tester) async {
      final plugin = FlutterLocalNotificationsPlugin();
      final service = NotificationService(plugin);

      // Start clean -- cancel anything left over from a prior manual test.
      await service.cancelMealReminder(MealSlot.breakfast);
      await service.cancelWeighInReminder();

      await service.initialize();

      // The crux check: does the `timezone` package's resolved offset
      // actually match the device's real UTC offset (which Dart's own
      // DateTime.now() always gets correctly from the OS, independent of
      // any third-party package)? If these differ, flutter_timezone's
      // returned identifier failed to resolve via tz.getLocation() on
      // THIS device and silently fell back to UTC -- reminders would
      // still get scheduled, just at the wrong wall-clock time.
      final tzOffset = tz.TZDateTime.now(tz.local).timeZoneOffset;
      final deviceOffset = DateTime.now().timeZoneOffset;
      debugPrint(
        '[integration_test] tz.local = "${tz.local.name}", '
        'tz offset = $tzOffset, device offset = $deviceOffset',
      );
      expect(
        tzOffset,
        deviceOffset,
        reason:
            "tz.local's resolved UTC offset ($tzOffset) does not match "
            "the device's real UTC offset ($deviceOffset) -- "
            'flutter_timezone/tz.getLocation() silently fell back to UTC '
            'on this device, which explains reminders firing at the '
            'wrong wall-clock time (or never, if the wait window in '
            'manual testing never reached the actual UTC-offset '
            'scheduled time).',
      );

      final granted = await service.requestPermissionIfNeeded();
      debugPrint(
        '[integration_test] notification permission granted: $granted',
      );

      // Schedule 2 minutes out -- close enough that a human watching the
      // device would see it fire if the OS actually honors the schedule,
      // but this assertion itself only checks the OS accepted it.
      final targetTime = DateTime.now().add(const Duration(minutes: 2));
      final timeString = _formatHHmm(targetTime);

      final mealScheduled = await service.scheduleMealReminder(
        MealSlot.breakfast,
        timeString,
      );
      expect(
        mealScheduled,
        isTrue,
        reason:
            'scheduleMealReminder returned false/threw -- see the '
            'NotificationService debugPrint trail above for why.',
      );

      final weighInScheduled = await service.scheduleWeighInReminder(
        frequency: 'weekly',
        time: timeString,
        weekday: targetTime.weekday,
      );
      expect(
        weighInScheduled,
        isTrue,
        reason:
            'scheduleWeighInReminder returned false/threw -- see the '
            'NotificationService debugPrint trail above for why.',
      );

      final pending = await plugin.pendingNotificationRequests();
      debugPrint(
        '[integration_test] pendingNotificationRequests(): '
        '${pending.map((p) => '#${p.id} "${p.title}"').join(', ')}',
      );

      final mealId = 100 + MealSlot.breakfast.index;
      expect(
        pending.any((p) => p.id == mealId),
        isTrue,
        reason:
            'No pending notification with id $mealId (breakfast reminder) '
            'found via pendingNotificationRequests() -- the OS itself '
            'does not have this reminder queued, confirmed directly '
            'against the platform, not a mock.',
      );
      expect(
        pending.any((p) => p.id == 200),
        isTrue,
        reason:
            'No pending notification with id 200 (weigh-in reminder) '
            'found via pendingNotificationRequests() -- the OS itself '
            'does not have this reminder queued, confirmed directly '
            'against the platform, not a mock.',
      );

      // Clean up so this test doesn't leave a real notification armed on
      // the device after the run.
      await service.cancelMealReminder(MealSlot.breakfast);
      await service.cancelWeighInReminder();
    },
  );
}

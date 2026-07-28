import 'dart:async';

import 'package:co2diet/core/router/app_router.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

/// Route-prefix allowlist for notification-tap deep links.
///
/// Payloads are always constructed by [NotificationService] itself (never
/// derived from network/user input -- RESEARCH.md Security Domain,
/// threat T-05-08-01), but the tap handler still validates the payload
/// shape defensively before calling `router.push`.
const _knownRoutePrefixes = ['/food-search', '/weight-tracking'];

/// Stable Android notification-channel ids for the two reminder kinds.
const _mealChannelId = 'meal_reminders';
const _mealChannelName = 'Meal reminders';
const _weighInChannelId = 'weigh_in_reminders';
const _weighInChannelName = 'Weigh-in reminders';

/// Stable notification id used for the single weigh-in reminder slot.
///
/// Distinct from the meal-slot id range (100 + [MealSlot.index]) so the two
/// reminder kinds never collide.
const _weighInNotificationId = 200;

/// Wraps [FlutterLocalNotificationsPlugin] as the single authoritative
/// service every meal-reminder/weigh-in-reminder feature talks to
/// (Architectural Responsibility Map: "Notification scheduling/permission
/// -- Local domain service").
///
/// Constructor-injected plugin instance (not a static singleton) for
/// testability, following this project's existing DI-by-constructor
/// convention.
class NotificationService {
  /// Creates a [NotificationService] wrapping [_plugin].
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  /// Configures `timezone`/`flutter_timezone` and initializes the
  /// underlying plugin.
  ///
  /// Deliberately does NOT request notification permission -- iOS/macOS
  /// permission prompts are suppressed via `requestAlertPermission: false`
  /// etc. below. Permission is only ever requested by
  /// [requestPermissionIfNeeded], called explicitly by a settings toggle
  /// handler (built in Plans 05-13/05-14/05-18).
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
  }

  /// Handles a notification tap while the app is running (foreground or
  /// background-but-alive). Cold-start-via-notification-tap is handled
  /// separately in `main.dart` via `getNotificationAppLaunchDetails()`
  /// (RESEARCH.md Pattern 4).
  ///
  /// A plain top-level-shaped static function -- no `BuildContext`/`ref` is
  /// available here, so navigation goes through [rootNavigatorKey] instead.
  static void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    navigateToPayload(payload);
  }

  /// Validates [payload] against the known route-prefix allowlist and, if
  /// valid, pushes it via [rootNavigatorKey]. Public + static so
  /// `main.dart`'s cold-start handling can reuse the identical validation
  /// logic.
  static void navigateToPayload(String payload) {
    final isKnownRoute = _knownRoutePrefixes.any(payload.startsWith);
    if (!isKnownRoute) return;

    final context = rootNavigatorKey.currentState?.context;
    if (context == null) return;

    unawaited(GoRouter.of(context).push(payload));
  }

  /// Requests notification permission if not already granted.
  ///
  /// Never called automatically by [initialize] -- callers (a reminder
  /// toggle handler) call this explicitly only when the user first enables
  /// a reminder (just-in-time permission timing).
  Future<bool> requestPermissionIfNeeded() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    final result = await Permission.notification.request();
    return result.isGranted;
  }

  /// Stable per-slot notification id so re-scheduling a slot's reminder
  /// replaces rather than duplicates it.
  int _mealSlotNotificationId(MealSlot slot) => 100 + slot.index;

  /// Schedules a daily-repeating reminder for [slot] at [time] (`'HH:mm'`).
  ///
  /// `payload: '/food-search?slot=${slot.name}'` is the exact query-param
  /// contract Plan 05-18's food-search `initialSlot` wiring implements --
  /// do not change this shape without updating that plan's consumer.
  ///
  /// Returns `false` (no exception) on permission denial or any other
  /// [PlatformException] from the plugin -- callers interpret `false` as
  /// "revert the toggle, show Open Settings link" per CONTEXT.md's
  /// permission-denied UX.
  Future<bool> scheduleMealReminder(MealSlot slot, String time) async {
    final parsed = _parseTime(time);
    if (parsed == null) return false;

    try {
      await _plugin.zonedSchedule(
        id: _mealSlotNotificationId(slot),
        scheduledDate: _nextInstanceOfTime(parsed.$1, parsed.$2),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _mealChannelId,
            _mealChannelName,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        title: '${slot.displayLabel} reminder',
        payload: '/food-search?slot=${slot.name}',
      );
      return true;
    } on PlatformException {
      return false;
    }
  }

  /// Cancels the reminder for [slot] (stable per-slot id).
  Future<void> cancelMealReminder(MealSlot slot) =>
      _plugin.cancel(id: _mealSlotNotificationId(slot));

  /// Schedules the weigh-in reminder.
  ///
  /// `'weekly'`/`'custom'` use `matchDateTimeComponents:
  /// DateTimeComponents.dayOfWeekAndTime` -- a true native weekly
  /// recurrence. `'biweekly'`/`'monthly'` have no native recurrence
  /// primitive in `flutter_local_notifications`, so this schedules only
  /// the next single occurrence, computed fresh from `DateTime.now()`
  /// every time this method runs.
  ///
  /// Always uses the same stable [_weighInNotificationId], so every call
  /// (first enable or a later re-arm) replaces the pending schedule rather
  /// than duplicating it -- this idempotency is the mechanism biweekly/
  /// monthly recurrence relies on.
  ///
  /// **Locked decision (05-CONTEXT.md Planning Addendum):** this method
  /// stays a pure, stateless scheduling call with no knowledge of *when*
  /// it's invoked from. Plan 05-18 adds the actual
  /// `AppLifecycleState.resumed` observer at the app root (`lib/app.dart`)
  /// that re-invokes this method on every foreground event (in addition to
  /// Plan 05-13's screen-open call) so the "next occurrence" stays fresh
  /// for infrequent-checkin users.
  Future<bool> scheduleWeighInReminder({
    required String frequency,
    required String time,
    int? weekday,
  }) async {
    final parsed = _parseTime(time);
    if (parsed == null) return false;
    final (hour, minute) = parsed;

    final usesWeeklyRecurrence =
        frequency == 'weekly' || frequency == 'custom';

    final scheduledDate = weekday != null
        ? _nextInstanceOfWeekdayTime(weekday, hour, minute)
        : _nextInstanceOfTime(hour, minute);

    try {
      await _plugin.zonedSchedule(
        id: _weighInNotificationId,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _weighInChannelId,
            _weighInChannelName,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: usesWeeklyRecurrence
            ? DateTimeComponents.dayOfWeekAndTime
            : null,
        title: 'Time for your weigh-in',
        payload: '/weight-tracking',
      );
      return true;
    } on PlatformException {
      return false;
    }
  }

  /// Cancels the single weigh-in reminder (stable fixed id).
  Future<void> cancelWeighInReminder() =>
      _plugin.cancel(id: _weighInNotificationId);

  /// Parses `'HH:mm'` into `(hour, minute)`, or returns `null` if
  /// malformed.
  (int, int)? _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return (hour, minute);
  }

  /// Returns the next [tz.TZDateTime] occurrence of [hour]:[minute],
  /// today if that time hasn't passed yet, otherwise tomorrow.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Returns the next [tz.TZDateTime] occurrence of [weekday] (1=Monday,
  /// per [DateTime.weekday]) at [hour]:[minute].
  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    var scheduled = _nextInstanceOfTime(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

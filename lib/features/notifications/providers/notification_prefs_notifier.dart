import 'package:co2diet/core/di/notification_providers.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/notification_prefs.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_prefs_notifier.g.dart';

/// Fallback reminder time used only when a slot is enabled with no
/// explicit time and none was ever previously saved for that slot. In
/// practice `MealReminderSettingsSection` (Plan 05-14) always passes the
/// row's currently-displayed time, so this is purely a defensive default.
const _defaultReminderTime = '08:00';

/// AsyncNotifier exposing the user's per-meal-slot reminder configuration
/// (NOTIF-01) and the single mutation surface (`setSlotEnabled`) that keeps
/// the stored [NotificationPrefs] row and the live-scheduled OS
/// notifications in sync -- this notifier is the one place both are
/// touched together.
///
/// `MealReminderSettingsSection` (this plan) is the sole consumer today;
/// Plan 05-18 embeds that widget into General Settings.
///
/// `NotificationService` is obtained via
/// `ref.watch(notificationServiceProvider)` -- the single provider
/// registered by Plan 05-08 (`lib/core/di/notification_providers.dart`).
/// This notifier never declares a competing provider for it.
@riverpod
class NotificationPrefsNotifier extends _$NotificationPrefsNotifier {
  @override
  Future<NotificationPrefs> build() =>
      ref.watch(notificationPrefsRepositoryProvider).getPrefs();

  /// Enables/disables the reminder for [slot], scheduled at [time]
  /// (`'HH:mm'`) when enabling.
  ///
  /// When [enabled] is `true`, requests notification permission
  /// just-in-time first (never during `build()`/app startup). If denied,
  /// returns `false` immediately without persisting anything or touching
  /// the OS scheduler -- the caller (a settings-row widget) is responsible
  /// for reverting its own toggle UI and showing the inline "Open
  /// Settings" recovery link in that case.
  ///
  /// Otherwise (permission already granted, or [enabled] is `false`),
  /// persists the updated [NotificationPrefs] via the repository, calls
  /// `scheduleMealReminder`/`cancelMealReminder` for [slot] accordingly,
  /// re-runs `build()`, and returns `true`.
  Future<bool> setSlotEnabled(
    MealSlot slot,
    bool enabled, {
    String? time,
  }) async {
    final notificationService = ref.read(notificationServiceProvider);

    if (enabled) {
      final granted = await notificationService.requestPermissionIfNeeded();
      if (!granted) return false;
    }

    final current = state.value ?? await future;
    final resolvedTime =
        time ?? current.timeFor(slot) ?? _defaultReminderTime;
    final updated = _withSlot(current, slot, enabled, resolvedTime);

    await ref.read(notificationPrefsRepositoryProvider).savePrefs(updated);

    if (enabled) {
      await notificationService.scheduleMealReminder(slot, resolvedTime);
    } else {
      await notificationService.cancelMealReminder(slot);
    }

    ref.invalidateSelf();
    return true;
  }

  /// Returns a copy of [prefs] with [slot]'s enabled/time fields replaced --
  /// the generic-lookup counterpart to [NotificationPrefs.enabledFor]/
  /// [NotificationPrefs.timeFor], since `copyWith` only exposes the four
  /// flat named fields directly.
  NotificationPrefs _withSlot(
    NotificationPrefs prefs,
    MealSlot slot,
    bool enabled,
    String time,
  ) => switch (slot) {
    MealSlot.breakfast => prefs.copyWith(
      breakfastEnabled: enabled,
      breakfastTime: time,
    ),
    MealSlot.lunch => prefs.copyWith(lunchEnabled: enabled, lunchTime: time),
    MealSlot.dinner => prefs.copyWith(
      dinnerEnabled: enabled,
      dinnerTime: time,
    ),
    MealSlot.snack => prefs.copyWith(snackEnabled: enabled, snackTime: time),
  };
}

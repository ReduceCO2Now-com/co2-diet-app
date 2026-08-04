// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_prefs_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(NotificationPrefsNotifier)
final notificationPrefsProvider = NotificationPrefsNotifierProvider._();

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
final class NotificationPrefsNotifierProvider
    extends
        $AsyncNotifierProvider<NotificationPrefsNotifier, NotificationPrefs> {
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
  NotificationPrefsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPrefsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPrefsNotifierHash();

  @$internal
  @override
  NotificationPrefsNotifier create() => NotificationPrefsNotifier();
}

String _$notificationPrefsNotifierHash() =>
    r'675092c59988eb1e680960f83458b37f2eee47f7';

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

abstract class _$NotificationPrefsNotifier
    extends $AsyncNotifier<NotificationPrefs> {
  FutureOr<NotificationPrefs> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<NotificationPrefs>, NotificationPrefs>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NotificationPrefs>, NotificationPrefs>,
              AsyncValue<NotificationPrefs>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

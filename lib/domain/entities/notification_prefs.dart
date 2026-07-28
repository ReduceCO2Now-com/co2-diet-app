import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:flutter/foundation.dart';

/// Domain entity for the user's per-meal-slot reminder configuration
/// (NOTIF-01).
///
/// Models the table's fixed 4-slot layout directly as flat named fields
/// (`breakfastEnabled`/`breakfastTime`, etc.) rather than a
/// `Map<MealSlot, MealReminderConfig>` — there are exactly four meal slots
/// and this avoids an extra Map-based indirection layer for a fixed set.
/// Use [enabledFor]/[timeFor] to look up a slot's configuration generically.
@immutable
class NotificationPrefs {
  /// Creates an immutable [NotificationPrefs]. All reminders default to
  /// disabled with no time set — this is the "no prefs saved yet" default.
  const NotificationPrefs({
    this.breakfastEnabled = false,
    this.breakfastTime,
    this.lunchEnabled = false,
    this.lunchTime,
    this.dinnerEnabled = false,
    this.dinnerTime,
    this.snackEnabled = false,
    this.snackTime,
  });

  /// Whether the breakfast reminder is enabled.
  final bool breakfastEnabled;

  /// Local time the breakfast reminder fires at, `'HH:mm'`.
  final String? breakfastTime;

  /// Whether the lunch reminder is enabled.
  final bool lunchEnabled;

  /// Local time the lunch reminder fires at, `'HH:mm'`.
  final String? lunchTime;

  /// Whether the dinner reminder is enabled.
  final bool dinnerEnabled;

  /// Local time the dinner reminder fires at, `'HH:mm'`.
  final String? dinnerTime;

  /// Whether the snack reminder is enabled.
  final bool snackEnabled;

  /// Local time the snack reminder fires at, `'HH:mm'`.
  final String? snackTime;

  /// Returns whether the reminder for [slot] is enabled.
  bool enabledFor(MealSlot slot) => switch (slot) {
    MealSlot.breakfast => breakfastEnabled,
    MealSlot.lunch => lunchEnabled,
    MealSlot.dinner => dinnerEnabled,
    MealSlot.snack => snackEnabled,
  };

  /// Returns the configured reminder time for [slot], or `null` if unset.
  String? timeFor(MealSlot slot) => switch (slot) {
    MealSlot.breakfast => breakfastTime,
    MealSlot.lunch => lunchTime,
    MealSlot.dinner => dinnerTime,
    MealSlot.snack => snackTime,
  };

  /// Sentinel object used by [copyWith] to detect when a caller explicitly
  /// passes `null` for a nullable field vs. not providing the field at all.
  static const _sentinel = Object();

  /// Returns a copy of this [NotificationPrefs] with the specified fields
  /// replaced.
  ///
  /// To explicitly clear a time field, pass `null` explicitly:
  /// `prefs.copyWith(breakfastTime: null)` — the sentinel pattern detects
  /// the override and sets the field to null rather than preserving the
  /// old value.
  NotificationPrefs copyWith({
    bool? breakfastEnabled,
    Object? breakfastTime = _sentinel,
    bool? lunchEnabled,
    Object? lunchTime = _sentinel,
    bool? dinnerEnabled,
    Object? dinnerTime = _sentinel,
    bool? snackEnabled,
    Object? snackTime = _sentinel,
  }) {
    return NotificationPrefs(
      breakfastEnabled: breakfastEnabled ?? this.breakfastEnabled,
      breakfastTime: breakfastTime == _sentinel
          ? this.breakfastTime
          : breakfastTime as String?,
      lunchEnabled: lunchEnabled ?? this.lunchEnabled,
      lunchTime: lunchTime == _sentinel
          ? this.lunchTime
          : lunchTime as String?,
      dinnerEnabled: dinnerEnabled ?? this.dinnerEnabled,
      dinnerTime: dinnerTime == _sentinel
          ? this.dinnerTime
          : dinnerTime as String?,
      snackEnabled: snackEnabled ?? this.snackEnabled,
      snackTime: snackTime == _sentinel
          ? this.snackTime
          : snackTime as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPrefs &&
          runtimeType == other.runtimeType &&
          breakfastEnabled == other.breakfastEnabled &&
          breakfastTime == other.breakfastTime &&
          lunchEnabled == other.lunchEnabled &&
          lunchTime == other.lunchTime &&
          dinnerEnabled == other.dinnerEnabled &&
          dinnerTime == other.dinnerTime &&
          snackEnabled == other.snackEnabled &&
          snackTime == other.snackTime;

  @override
  int get hashCode => Object.hash(
    breakfastEnabled,
    breakfastTime,
    lunchEnabled,
    lunchTime,
    dinnerEnabled,
    dinnerTime,
    snackEnabled,
    snackTime,
  );

  @override
  String toString() => 'NotificationPrefs('
      'breakfastEnabled: $breakfastEnabled, breakfastTime: $breakfastTime, '
      'lunchEnabled: $lunchEnabled, lunchTime: $lunchTime, '
      'dinnerEnabled: $dinnerEnabled, dinnerTime: $dinnerTime, '
      'snackEnabled: $snackEnabled, snackTime: $snackTime)';
}

import 'package:co2diet/data/local/app_database.dart';
import 'package:flutter/foundation.dart';

/// Domain entity for the user's weight goal + weigh-in reminder
/// configuration (WT-03/WT-04).
///
/// Deliberately has NO derived "pace"/"on track"/projection field.
/// `05-CONTEXT.md` explicitly rejects deriving one from [targetWeightKg] +
/// [targetDate] — the chart-rendering layer draws only a static reference
/// line from the raw goal value. Any future screen must not synthesize a
/// pace/projection value either; this entity's shape makes that impossible
/// to do "by accident".
@immutable
class WeightSettings {
  /// Creates an immutable [WeightSettings]. The no-argument form represents
  /// "no settings saved yet" (no goal, reminder disabled).
  const WeightSettings({
    this.targetWeightKg,
    this.targetDate,
    this.reminderFrequency,
    this.reminderWeekday,
    this.reminderTime,
    this.reminderEnabled = false,
  });

  /// Maps a Drift [WeightSettingsRow] 1:1 onto a [WeightSettings].
  factory WeightSettings.fromRow(WeightSettingsRow row) => WeightSettings(
    targetWeightKg: row.targetWeightKg,
    targetDate: row.targetDate,
    reminderFrequency: row.reminderFrequency,
    reminderWeekday: row.reminderWeekday,
    reminderTime: row.reminderTime,
    reminderEnabled: row.reminderEnabled,
  );

  /// Target weight in kilograms (WT-03). Always stored in kg; imperial
  /// conversion is an app-layer concern.
  final double? targetWeightKg;

  /// Target date for reaching [targetWeightKg] (WT-03).
  final DateTime? targetDate;

  /// How often the user wants a weigh-in reminder (WT-04). Values:
  /// `'never'`, `'weekly'`, `'biweekly'`, `'monthly'`, `'custom'`.
  final String? reminderFrequency;

  /// Day of week the reminder fires on, 1 (Monday) to 7 (Sunday),
  /// ISO-8601 weekday numbering (WT-04). Only meaningful when
  /// [reminderFrequency] is `'custom'`.
  final int? reminderWeekday;

  /// Local time the reminder fires at, `'HH:mm'` 24-hour string (WT-04).
  final String? reminderTime;

  /// Whether the weigh-in reminder is enabled (WT-04).
  final bool reminderEnabled;

  /// Sentinel object used by [copyWith] to detect when a caller explicitly
  /// passes `null` for a nullable field vs. not providing the field at all.
  static const _sentinel = Object();

  /// Returns a copy of this [WeightSettings] with the specified fields
  /// replaced.
  ///
  /// To explicitly set a nullable field to `null`, pass `null` explicitly:
  /// `settings.copyWith(targetWeightKg: null)` — the sentinel pattern
  /// detects the override and sets the field to null rather than
  /// preserving the old value.
  WeightSettings copyWith({
    Object? targetWeightKg = _sentinel,
    Object? targetDate = _sentinel,
    Object? reminderFrequency = _sentinel,
    Object? reminderWeekday = _sentinel,
    Object? reminderTime = _sentinel,
    bool? reminderEnabled,
  }) {
    return WeightSettings(
      targetWeightKg: targetWeightKg == _sentinel
          ? this.targetWeightKg
          : targetWeightKg as double?,
      targetDate: targetDate == _sentinel
          ? this.targetDate
          : targetDate as DateTime?,
      reminderFrequency: reminderFrequency == _sentinel
          ? this.reminderFrequency
          : reminderFrequency as String?,
      reminderWeekday: reminderWeekday == _sentinel
          ? this.reminderWeekday
          : reminderWeekday as int?,
      reminderTime: reminderTime == _sentinel
          ? this.reminderTime
          : reminderTime as String?,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightSettings &&
          runtimeType == other.runtimeType &&
          targetWeightKg == other.targetWeightKg &&
          targetDate == other.targetDate &&
          reminderFrequency == other.reminderFrequency &&
          reminderWeekday == other.reminderWeekday &&
          reminderTime == other.reminderTime &&
          reminderEnabled == other.reminderEnabled;

  @override
  int get hashCode => Object.hash(
    targetWeightKg,
    targetDate,
    reminderFrequency,
    reminderWeekday,
    reminderTime,
    reminderEnabled,
  );

  @override
  String toString() =>
      'WeightSettings(targetWeightKg: $targetWeightKg, '
      'targetDate: $targetDate, reminderFrequency: $reminderFrequency, '
      'reminderWeekday: $reminderWeekday, reminderTime: $reminderTime, '
      'reminderEnabled: $reminderEnabled)';
}

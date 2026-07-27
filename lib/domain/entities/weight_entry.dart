import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:flutter/foundation.dart';

/// A single logged weigh-in (WT-01): value + unit + timestamp + optional
/// free-text note.
///
/// Unlike `FoodItem`, [WeightEntry] rows are individually addressable
/// (edit/delete), so [id] is required and equality is based on it, mirroring
/// `MealEntry`'s established convention.
@immutable
class WeightEntry {
  /// Creates a [WeightEntry] with the given fields.
  const WeightEntry({
    required this.id,
    required this.value,
    required this.unit,
    required this.loggedAt,
    this.note,
  });

  /// Maps a Drift [WeightEntryRow] 1:1 onto a [WeightEntry].
  ///
  /// Mirrors `MealEntry.fromRow`'s precedent (Phase 4): the Drift-row-to-
  /// entity mapping direction lives directly on the entity, in the same
  /// file, rather than in a separate mapper class.
  factory WeightEntry.fromRow(WeightEntryRow row) => WeightEntry(
    id: row.id,
    value: row.value,
    unit: row.unit,
    loggedAt: row.loggedAt,
    note: row.note,
  );

  /// Unique, individually addressable row id.
  final String id;

  /// The logged weight value, expressed in [unit].
  final double value;

  /// Unit [value] is expressed in.
  final WeightUnit unit;

  /// Wall-clock timestamp of when this weigh-in was logged.
  final DateTime loggedAt;

  /// Optional free-text note attached to this weigh-in.
  final String? note;

  /// Sentinel object used by [copyWith] to detect when a caller explicitly
  /// passes `null` for a nullable field vs. not providing the field at all.
  static const _sentinel = Object();

  /// Returns a copy of this [WeightEntry] with the specified fields
  /// replaced.
  ///
  /// To explicitly set [note] to `null`, pass `null` explicitly:
  /// `entry.copyWith(note: null)` — the sentinel pattern detects the
  /// override and sets the field to null rather than preserving the old
  /// value.
  WeightEntry copyWith({
    String? id,
    double? value,
    WeightUnit? unit,
    DateTime? loggedAt,
    Object? note = _sentinel,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      loggedAt: loggedAt ?? this.loggedAt,
      note: note == _sentinel ? this.note : note as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is WeightEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'WeightEntry(id: $id, value: $value, unit: $unit, '
      'loggedAt: $loggedAt, note: $note)';
}

/// Named history filter window for [WT-02]'s 7d/30d/90d/1yr/all filter.
///
/// Resolved to a concrete `[from, to]` date range (via [startDate]) at the
/// repository layer before delegating to `WeightDao.getEntriesInRange`'s raw
/// date-bound query — the DAO itself is not aware of named ranges.
enum WeightRange {
  /// Last 7 days.
  sevenDay,

  /// Last 30 days.
  thirtyDay,

  /// Last 90 days.
  ninetyDay,

  /// Last 1 year.
  oneYear,

  /// All time — no lower bound.
  all,
}

/// Resolution helpers for [WeightRange].
extension WeightRangeResolution on WeightRange {
  /// Returns the lower bound (`from`) for this range relative to [now], or
  /// `null` for [WeightRange.all] (no lower bound — full history).
  DateTime? startDate(DateTime now) => switch (this) {
    WeightRange.sevenDay => now.subtract(const Duration(days: 7)),
    WeightRange.thirtyDay => now.subtract(const Duration(days: 30)),
    WeightRange.ninetyDay => now.subtract(const Duration(days: 90)),
    WeightRange.oneYear => now.subtract(const Duration(days: 365)),
    WeightRange.all => null,
  };
}

/// Unit a logged weight value is expressed in.
///
/// APPEND-ONLY: `textEnum<WeightUnit>()` (see `weight_entry_table.dart`)
/// stores `Enum.name` in SQLite. Renaming a member after rows exist
/// breaks deserialization for those rows (RESEARCH.md Pitfall 4) —
/// only add new members at the end, never rename or remove existing
/// ones.
enum WeightUnit {
  /// Kilograms.
  kg,

  /// Pounds.
  lb,
}

/// Display-facing helpers for [WeightUnit].
extension WeightUnitDisplay on WeightUnit {
  /// Human-readable label for this unit (e.g. `'kg'`, `'lb'`).
  String get displayLabel => switch (this) {
    WeightUnit.kg => 'kg',
    WeightUnit.lb => 'lb',
  };
}

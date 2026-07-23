/// Unit a logged quantity (or a favorite's last-logged quantity) is
/// expressed in.
///
/// APPEND-ONLY: `textEnum<PortionUnit>()` (see `meal_entry_table.dart` /
/// `favorite_table.dart`) stores `Enum.name` in SQLite. Renaming a member
/// after rows exist breaks deserialization for those rows (RESEARCH.md
/// Pitfall 4) — only add new members at the end, never rename or remove
/// existing ones.
enum PortionUnit {
  /// Grams.
  g,

  /// Milliliters.
  ml,

  /// A single discrete item (e.g. one apple).
  piece,

  /// A cup, user-configurable via My Foods quick serving sizes.
  cup,

  /// A generic serving/portion, user-configurable via My Foods quick
  /// serving sizes.
  portion,
}

/// Display-facing helpers for [PortionUnit].
extension PortionUnitDisplay on PortionUnit {
  /// Human-readable label for this unit (e.g. `'g'`, `'piece'`).
  String get displayLabel => switch (this) {
    PortionUnit.g => 'g',
    PortionUnit.ml => 'ml',
    PortionUnit.piece => 'piece',
    PortionUnit.cup => 'cup',
    PortionUnit.portion => 'portion',
  };

  /// Whether this unit expresses a directly weighable/measurable quantity
  /// ([PortionUnit.g], [PortionUnit.ml]) as opposed to a discrete or
  /// user-defined unit ([PortionUnit.piece], [PortionUnit.cup],
  /// [PortionUnit.portion]) that requires a weight-per-unit conversion
  /// (e.g. a quick serving size) before it can be scaled against a
  /// per-100g/100ml snapshot.
  bool get isWeightBased => switch (this) {
    PortionUnit.g || PortionUnit.ml => true,
    PortionUnit.piece || PortionUnit.cup || PortionUnit.portion => false,
  };
}

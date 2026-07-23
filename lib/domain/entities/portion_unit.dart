/// Unit a logged quantity (or a favorite's last-logged quantity) is
/// expressed in.
///
/// APPEND-ONLY: `textEnum<PortionUnit>()` (see `meal_entry_table.dart` /
/// `favorite_table.dart`) stores `Enum.name` in SQLite. Renaming a member
/// after rows exist breaks deserialization for those rows (RESEARCH.md
/// Pitfall 4) — only add new members at the end, never rename or remove
/// existing ones.
///
/// STAND-IN NOTE: This minimal enum was created by Plan 04-02 (Drift
/// schema plan) solely to unblock `MealEntryTable`/`FavoriteTable`
/// compilation and `dart run build_runner build` — Plan 04-03 (parallel
/// Wave 2 domain-layer plan) owns the authoritative `portion_unit.dart`
/// and is expected to extend this file with the `displayLabel` and
/// `isWeightBased` extension getters it specifies, rather than assume
/// those additions already exist here.
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

/// Which meal slot a [MealEntryTable] row belongs to.
///
/// APPEND-ONLY: `textEnum<MealSlot>()` (see `meal_entry_table.dart`) stores
/// `Enum.name` in SQLite. Renaming a member after rows exist breaks
/// deserialization for those rows (RESEARCH.md Pitfall 4) — only add new
/// members at the end, never rename or remove existing ones.
///
/// STAND-IN NOTE: This minimal enum was created by Plan 04-02 (Drift
/// schema plan) solely to unblock `MealEntryTable`/`FavoriteTable`
/// compilation and `dart run build_runner build` — Plan 04-03 (parallel
/// Wave 2 domain-layer plan) owns the authoritative `meal_slot.dart` and
/// is expected to extend this file with the `displayLabel` extension
/// getter and the `detectMealSlotForTime` time-of-day auto-detect
/// function it specifies, rather than assume those additions already
/// exist here.
enum MealSlot {
  /// Morning meal.
  breakfast,

  /// Midday meal.
  lunch,

  /// Evening meal.
  dinner,

  /// Any meal logged outside the three main slots.
  snack,
}

/// Which meal slot a `MealEntryTable` row belongs to.
///
/// APPEND-ONLY: `textEnum<MealSlot>()` (see `meal_entry_table.dart`) stores
/// `Enum.name` in SQLite. Renaming a member after rows exist breaks
/// deserialization for those rows (RESEARCH.md Pitfall 4) — only add new
/// members at the end, never rename or remove existing ones.
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

/// Display-facing labels for [MealSlot], used by UI widgets (e.g.
/// `PortionSlotForm` in Plan 04-09, Recent/Favorites one-tap-log in
/// Plan 04-10).
extension MealSlotDisplay on MealSlot {
  /// Human-readable label for this slot (e.g. `'Breakfast'`).
  String get displayLabel => switch (this) {
    MealSlot.breakfast => 'Breakfast',
    MealSlot.lunch => 'Lunch',
    MealSlot.dinner => 'Dinner',
    MealSlot.snack => 'Snack',
  };
}

/// Auto-detects the most likely [MealSlot] for the given [now] based on
/// time of day. Used to pre-select a slot when logging a meal without
/// requiring the user to pick one manually (10-second logging target).
///
/// Boundaries (local device time):
/// - before 11:00 -> [MealSlot.breakfast]
/// - 11:00 (inclusive) to 15:00 (exclusive) -> [MealSlot.lunch]
/// - 15:00 (inclusive) to 18:00 (exclusive) -> [MealSlot.snack]
/// - 18:00 (inclusive) and after -> [MealSlot.dinner]
///
/// This is the single shared implementation of the time-of-day auto-detect
/// rule (CONTEXT.md) — `PortionSlotForm` (Plan 04-09) and the
/// Recent/Favorites one-tap-log path (Plan 04-10) both depend on this
/// function rather than defining their own private copies.
MealSlot detectMealSlotForTime(DateTime now) {
  final hour = now.hour;
  if (hour < 11) {
    return MealSlot.breakfast;
  } else if (hour < 15) {
    return MealSlot.lunch;
  } else if (hour < 18) {
    return MealSlot.snack;
  } else {
    return MealSlot.dinner;
  }
}

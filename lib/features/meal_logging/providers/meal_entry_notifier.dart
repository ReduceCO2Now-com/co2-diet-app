import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_entry_notifier.g.dart';

/// Result of a [MealEntryNotifier.logFood] call, telling the caller (the
/// UI's Undo snackbar) whether the write was a fresh insert or a merge into
/// an existing row.
///
/// - Fresh insert ([wasMerge] == false): Undo should call
///   `deleteEntry(entry.id)`.
/// - Merge ([wasMerge] == true): Undo should call
///   `undoMerge(entry.id, loggedDelta)` to subtract back out only the
///   quantity this particular log call added, leaving any pre-existing
///   quantity on the row intact.
@immutable
class MealLogResult {
  /// Creates a [MealLogResult].
  const MealLogResult({
    required this.entry,
    required this.wasMerge,
    required this.loggedDelta,
  });

  /// The persisted row after the write (new or merged).
  final MealEntry entry;

  /// Whether [entry] already existed and this call merged (added) quantity
  /// into it, as opposed to inserting a brand-new row.
  final bool wasMerge;

  /// The quantity delta this specific log call contributed. For a fresh
  /// insert this equals the draft's full quantity; for a merge it's the
  /// amount added on top of whatever quantity the row already had.
  final double loggedDelta;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealLogResult &&
          other.entry == entry &&
          other.wasMerge == wasMerge &&
          other.loggedDelta == loggedDelta);

  @override
  int get hashCode => Object.hash(entry, wasMerge, loggedDelta);

  @override
  String toString() =>
      'MealLogResult(entry: $entry, wasMerge: $wasMerge, '
      'loggedDelta: $loggedDelta)';
}

/// AsyncNotifier exposing today's logged [MealEntry] rows and the mutation
/// surface (log/edit/delete/duplicate/undo) the UI layer (Plans 04-08
/// through 04-11) consumes exclusively — those plans never touch
/// `IMealEntryRepository` or the DAO layer directly.
///
/// Follows `ProfileNotifier`'s exact codegen shape: `build()` returns the
/// current state, every mutation method calls the repository then
/// `ref.invalidateSelf()` so the dashboard's today-list picks up the change.
@riverpod
class MealEntryNotifier extends _$MealEntryNotifier {
  /// The most recently soft-deleted row, kept client-side so `undoDelete()`
  /// can restore it without a round-trip re-fetch. Exactly one pending-undo
  /// slot — no unbounded undo history (CONTEXT.md's single-level Undo
  /// pattern). A second `deleteEntry()` call before `undoDelete()` silently
  /// replaces this slot; only the most recent delete is undoable.
  MealEntry? _pendingUndoDelete;

  @override
  Future<List<MealEntry>> build() =>
      ref.watch(mealEntryRepositoryProvider).getEntriesForToday();

  /// Logs [draft], merging into an existing same-slot/same-day/same-unit
  /// row when one exists (`IMealEntryRepository.logOrMerge`'s contract).
  ///
  /// Detects merge-vs-fresh-insert by comparing the persisted row's
  /// `quantity` against `draft.quantity`: a merge absorbs the draft's
  /// quantity into a larger existing total, so the persisted quantity will
  /// exceed the draft's. Returns a [MealLogResult] so the UI's Undo button
  /// knows whether to call [undoMerge] (merge case) or [deleteEntry]
  /// (fresh-insert case).
  Future<MealLogResult> logFood(MealEntry draft) async {
    final persisted =
        await ref.read(mealEntryRepositoryProvider).logOrMerge(draft);
    final wasMerge = persisted.quantity > draft.quantity;
    ref.invalidateSelf();
    return MealLogResult(
      entry: persisted,
      wasMerge: wasMerge,
      loggedDelta: draft.quantity,
    );
  }

  /// Undoes a merge by subtracting [delta] back out of the row identified
  /// by [entryId], restoring its pre-merge quantity without deleting it.
  Future<void> undoMerge(String entryId, double delta) async {
    await ref.read(mealEntryRepositoryProvider).undoMergeDelta(entryId, delta);
    ref.invalidateSelf();
  }

  /// Updates slot/quantity/unit on an existing row. Snapshot fields are
  /// never touched — a slot/quantity/unit edit must never silently rewrite
  /// the product data captured at log time.
  Future<MealEntry> editEntry(MealEntry updated) async {
    final result =
        await ref.read(mealEntryRepositoryProvider).editEntry(updated);
    ref.invalidateSelf();
    return result;
  }

  /// Soft-deletes the entry identified by [id], keeping the pre-delete row
  /// in [_pendingUndoDelete] so a subsequent [undoDelete] can restore it
  /// without re-fetching.
  Future<void> deleteEntry(String id) async {
    _pendingUndoDelete =
        await ref.read(mealEntryRepositoryProvider).deleteEntry(id);
    ref.invalidateSelf();
  }

  /// Restores the most recently deleted entry (see [_pendingUndoDelete]).
  /// No-op if there is no pending undo (already undone, or nothing was
  /// deleted this session).
  Future<void> undoDelete() async {
    final entry = _pendingUndoDelete;
    if (entry == null) return;
    await ref.read(mealEntryRepositoryProvider).restoreEntry(entry);
    _pendingUndoDelete = null;
    ref.invalidateSelf();
  }

  /// Creates a new row copying [id]'s fields into the same slot. Bypasses
  /// [logFood]'s merge rule entirely — Duplicate must never be a no-op via
  /// accidental merge.
  Future<void> duplicateEntry(String id) async {
    await ref.read(mealEntryRepositoryProvider).duplicateEntry(id);
    ref.invalidateSelf();
  }

  /// Returns up to [limit] recently logged individual items.
  ///
  /// Deliberately NOT part of `build()`'s state and never followed by
  /// `ref.invalidateSelf()` — Recent is a separate, on-demand concern
  /// queried by the food search empty state (Plan 04-10), not the
  /// dashboard's today-list. Folding it into `build()` would force every
  /// dashboard rebuild to also re-run the Recent query, and folding it into
  /// the mutation cycle would incorrectly suggest Recent has its own
  /// invalidation-driven lifecycle when it's actually a plain read.
  Future<List<MealEntry>> getRecent({int limit = 15}) =>
      ref.read(mealEntryRepositoryProvider).getRecent(limit: limit);
}

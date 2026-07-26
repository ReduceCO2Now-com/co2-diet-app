import 'dart:async';

import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_entry_food_item_mapping.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/features/dashboard/widgets/meal_entry_row.dart';
import 'package:co2diet/features/food_search/widgets/food_detail_sheet.dart';
import 'package:co2diet/features/meal_logging/providers/meal_entry_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dashboard screen (LOG-05/LOG-09/LOG-13): today's logged meal entries,
/// grouped by slot (breakfast/lunch/dinner/snack), each row swipeable to
/// reveal Edit/Duplicate/Delete.
///
/// Class name kept as `PlaceholderDashboardScreen` (unchanged from Phase 1
/// through 3) even though this plan gives it a real body — CONTEXT.md:
/// "Phase 5 extends/replaces this same list rather than starting from
/// scratch," and the class name signals its Phase-5-provisional nature
/// intentionally.
class PlaceholderDashboardScreen extends ConsumerWidget {
  /// Creates the dashboard screen.
  const PlaceholderDashboardScreen({super.key});

  void _editEntry(BuildContext context, MealEntry entry) {
    unawaited(
      showFoodDetailSheet(
        context,
        entry.toFoodItem(),
        initialSlot: entry.mealSlot,
        initialQuantity: entry.quantity,
        initialUnit: entry.unit,
      ),
    );
  }

  void _duplicateEntry(WidgetRef ref, MealEntry entry) {
    unawaited(ref.read(mealEntryProvider.notifier).duplicateEntry(entry.id));
  }

  void _deleteEntry(BuildContext context, WidgetRef ref, MealEntry entry) {
    final notifier = ref.read(mealEntryProvider.notifier);
    unawaited(notifier.deleteEntry(entry.id));

    final messenger = ScaffoldMessenger.of(context);
    // Captured via the raw ProviderContainer (not this widget's `ref`) so
    // Undo stays usable even if this widget is disposed before it's tapped
    // — same pattern as `PortionSlotForm`/`RecentFavoritesList`.
    final container = ProviderScope.containerOf(context, listen: false);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Deleted'),
        duration: const Duration(seconds: 5),
        // See PortionSlotForm._handleLogPressed — SnackBar.persist defaults
        // to true whenever an `action` is set, which no-ops the timeout.
        persist: false,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            unawaited(container.read(mealEntryProvider.notifier).undoDelete());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(mealEntryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) =>
            const Center(child: Text('Error loading today’s meals')),
        data: (entries) => _buildBody(context, ref, entries),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<MealEntry> entries,
  ) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.restaurant_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No meals logged yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final slot in MealSlot.values)
          ..._buildSlotSection(context, ref, slot, entries),
      ],
    );
  }

  List<Widget> _buildSlotSection(
    BuildContext context,
    WidgetRef ref,
    MealSlot slot,
    List<MealEntry> entries,
  ) {
    final slotEntries = entries
        .where((entry) => entry.mealSlot == slot)
        .toList();
    if (slotEntries.isEmpty) return const [];

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          slot.displayLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      for (final entry in slotEntries)
        MealEntryRow(
          entry: entry,
          onEdit: (entry) => _editEntry(context, entry),
          onDuplicate: (entry) => _duplicateEntry(ref, entry),
          onDelete: (entry) => _deleteEntry(context, ref, entry),
        ),
    ];
  }
}

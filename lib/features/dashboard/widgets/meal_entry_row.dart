import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/features/barcode_scan/utils/co2_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// A single logged meal-entry row (LOG-09): name + quantity/unit + scaled
/// calories + scaled CO2, swipeable (end action pane) to reveal Edit,
/// Duplicate, and Delete actions in that order.
///
/// Pure presentation/gesture widget — `onEdit`/`onDuplicate`/`onDelete` are
/// constructor callbacks; the caller (`PlaceholderDashboardScreen`) wires
/// them to `MealEntryNotifier` methods rather than this widget calling the
/// notifier directly. Matches RESEARCH.md's Architectural Responsibility
/// Map: "Swipe-to-reveal actions — Client (Flutter UI widget) — Pure
/// presentation/gesture concern."
///
/// Scaled calories/CO2 are only computed for weight-based units
/// ([PortionUnit.g]/[PortionUnit.ml]), where `quantity` directly IS the
/// grams/ml equivalent [MealEntry.scaled] expects — piece/cup/portion units
/// need a weight-per-unit conversion this row has no access to, so it falls
/// back to a plain quantity+unit subtitle for those (same limitation and
/// pattern as `RecentFavoritesList`'s `_RecentRow._summary`, Plan 04-10).
class MealEntryRow extends ConsumerWidget {
  /// Creates a [MealEntryRow] for [entry].
  const MealEntryRow({
    required this.entry,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    super.key,
  });

  /// The logged entry this row displays.
  final MealEntry entry;

  /// Called when the user taps the Edit swipe action.
  final void Function(MealEntry entry) onEdit;

  /// Called when the user taps the Duplicate swipe action.
  final void Function(MealEntry entry) onDuplicate;

  /// Called when the user taps the Delete swipe action.
  final void Function(MealEntry entry) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaled = entry.unit.isWeightBased
        ? entry.scaled(entry.quantity)
        : const ScaledMacros();
    final co2Text = formatCo2Display(scaled.co2e);
    final calText = scaled.calories != null
        ? '${scaled.calories!.round()} kcal'
        : '—';
    final quantityLabel =
        '${_formatQuantity(entry.quantity)}${entry.unit.displayLabel}';
    final subtitle = co2Text != null
        ? '$quantityLabel • $calText • $co2Text'
        : '$quantityLabel • $calText';

    return Slidable(
      key: ValueKey(entry.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(entry),
            icon: Icons.edit_outlined,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => onDuplicate(entry),
            icon: Icons.copy_outlined,
            label: 'Duplicate',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(entry),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        title: Text(entry.productNameSnapshot),
        subtitle: Text(subtitle),
      ),
    );
  }

  /// Formats [value] for display — a whole number when it has no
  /// fractional part, otherwise its plain string form. Mirrors
  /// `RecentFavoritesList`'s private `_formatQuantity` (duplicated here
  /// rather than shared since both are file-private single-line helpers).
  static String _formatQuantity(double value) =>
      value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}

import 'dart:async';

import 'package:co2diet/domain/entities/food_item.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/entities/serving_size.dart';
import 'package:co2diet/domain/entities/user_food.dart';
import 'package:co2diet/features/barcode_scan/utils/co2_formatter.dart';
import 'package:co2diet/features/barcode_scan/widgets/confidence_chip.dart';
import 'package:co2diet/features/meal_logging/providers/meal_entry_notifier.dart';
import 'package:co2diet/features/my_foods/providers/user_food_notifier.dart';
import 'package:co2diet/features/profile/providers/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The core LOG-05/LOG-06/LOG-13 logging UI: meal-slot picker, quantity/unit
/// input (with locale-aware defaults and quick-serving-size chips), a
/// live-scaled macro/CO₂ table, and the "Log this food" action.
///
/// Embedded inside `_FoodDetailContent` (`food_detail_sheet.dart`) for both
/// the search and barcode-scan entry points — there is only ever one sheet
/// content widget (Plan 04-09's sheet-reconciliation fix).
///
/// [initialSlot]/[initialQuantity]/[initialUnit] are the pre-fill contract
/// Plans 04-10/04-11 (wave 7, no dependency on each other) use to open this
/// form already populated with an existing entry's values (Recent/
/// Favorites edit icon, dashboard edit). All three default to `null` — the
/// normal search/scan entry points never pass them, preserving today's
/// auto-detect/locale-default behavior.
class PortionSlotForm extends ConsumerStatefulWidget {
  /// Creates a [PortionSlotForm] for [item].
  const PortionSlotForm({
    required this.item,
    this.initialSlot,
    this.initialQuantity,
    this.initialUnit,
    super.key,
  });

  /// The food this form logs. Its per-100g/100ml fields are the snapshot
  /// source for both the live-scaled macro table and the persisted
  /// [MealEntry] draft.
  final FoodItem item;

  /// Pre-selects this slot instead of the time-of-day auto-detect. Used by
  /// the Dashboard quick-add buttons (slot-only intent) and the edit-prefill
  /// flow (Plans 04-10/04-11).
  final MealSlot? initialSlot;

  /// Pre-fills the quantity field with this exact value, bypassing both the
  /// chip-derived default and the locale-aware default. Used by the
  /// edit-prefill flow.
  final double? initialQuantity;

  /// Pre-fills the unit dropdown with this exact value, bypassing both the
  /// chip-derived default and the locale-aware default. Used by the
  /// edit-prefill flow. Always provided together with [initialQuantity].
  final PortionUnit? initialUnit;

  @override
  ConsumerState<PortionSlotForm> createState() => _PortionSlotFormState();
}

class _PortionSlotFormState extends ConsumerState<PortionSlotForm> {
  late MealSlot _selectedSlot;
  late PortionUnit _selectedUnit;
  late final TextEditingController _quantityController;
  late final FocusNode _quantityFocusNode;
  late Future<UserFood?> _overrideFuture;

  UserFood? _override;
  List<_QuantityChipOption> _chips = const [];

  /// Guards [_applyLocaleDefault] so it runs at most once per mount — set
  /// synchronously at the top of [didChangeDependencies] (before the async
  /// override lookup resolves) to prevent a second `didChangeDependencies`
  /// call (e.g. a `MediaQuery` change while the override future is still in
  /// flight) from kicking off a duplicate, concurrent locale-default chain.
  bool _localeApplied = false;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.initialSlot ?? detectMealSlotForTime(DateTime.now());
    _selectedUnit = widget.initialUnit ?? PortionUnit.g;
    _quantityController = TextEditingController(
      text: widget.initialQuantity != null
          ? _formatQuantity(widget.initialQuantity!)
          : '100',
    );
    _quantityFocusNode = FocusNode();
    _chips = _buildChips(null);
    _overrideFuture = _resolveOverride();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localeApplied) return;
    _localeApplied = true;
    // Edit-prefill case (Plans 04-10/04-11): explicit values always win —
    // the locale-aware default never runs.
    if (widget.initialQuantity != null || widget.initialUnit != null) {
      return;
    }
    final unitPref = ProfileNotifier.setLocaleUnits(context);
    unawaited(_applyLocaleDefault(unitPref));
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  Future<UserFood?> _resolveOverride() async {
    final override = await ref
        .read(userFoodProvider.notifier)
        .findOverrideForFoodRef(
          widget.item.resolvedFoodRef,
          widget.item.source ?? 'off_ref',
        );
    if (!mounted) return override;
    setState(() {
      _override = override;
      _chips = _buildChips(override);
    });
    return override;
  }

  /// Applies LOG-06's "metric default, imperial from locale" rule when this
  /// form is opened fresh (no [PortionSlotForm.initialQuantity]/
  /// [PortionSlotForm.initialUnit]). Only overrides the plain gram default
  /// when [unitPref] is `'imperial'` AND a real configured (non-generic)
  /// [ServingSize] exists — this never fabricates a unit without a backing
  /// conversion, per CONTEXT.md's "no generic/estimated conversion
  /// fallback" decision. A metric-locale device always keeps the gram
  /// default (the user can still tap a configured chip manually).
  Future<void> _applyLocaleDefault(String unitPref) async {
    if (unitPref != 'imperial') return;
    final override = await _overrideFuture;
    if (!mounted || override == null || override.quickServingSizes.isEmpty) {
      return;
    }
    final firstServing = override.quickServingSizes.first;
    setState(() {
      _selectedUnit = _impliedUnitForLabel(firstServing.label);
      _quantityController.text = '1';
    });
  }

  List<_QuantityChipOption> _buildChips(UserFood? override) {
    if (override == null || override.quickServingSizes.isEmpty) {
      return const [
        _QuantityChipOption(label: '100g', quantity: 100, unit: PortionUnit.g),
        _QuantityChipOption(label: '200g', quantity: 200, unit: PortionUnit.g),
        _QuantityChipOption(label: 'Custom', quantity: null, unit: null),
      ];
    }
    return [
      for (final size in override.quickServingSizes)
        _QuantityChipOption(
          label: size.label,
          quantity: 1,
          unit: _impliedUnitForLabel(size.label),
        ),
      const _QuantityChipOption(label: 'Custom', quantity: null, unit: null),
    ];
  }

  bool _isChipSelected(_QuantityChipOption chip) {
    if (chip.quantity == null) return false;
    final parsed = double.tryParse(_quantityController.text);
    return chip.unit == _selectedUnit && parsed == chip.quantity;
  }

  void _onChipSelected(_QuantityChipOption chip) {
    if (chip.quantity == null) {
      // 'Custom' chip: focuses the field without changing its value.
      _quantityFocusNode.requestFocus();
      return;
    }
    setState(() {
      _quantityController.text = _formatQuantity(chip.quantity!);
      final unit = chip.unit;
      if (unit != null) _selectedUnit = unit;
    });
  }

  /// Units always include g/ml; a `piece`/`cup`/`portion` unit is only
  /// offered when at least one configured [ServingSize] on [_override]
  /// implies it — never a generic/estimated conversion (LOG-06).
  List<PortionUnit> _availableUnits() {
    final units = <PortionUnit>[PortionUnit.g, PortionUnit.ml];
    final override = _override;
    if (override != null) {
      for (final size in override.quickServingSizes) {
        final unit = _impliedUnitForLabel(size.label);
        if (!units.contains(unit)) units.add(unit);
      }
    }
    return units;
  }

  /// Grams-per-one-unit for [unit]. `1` for the directly-weighable g/ml
  /// units; the matching configured [ServingSize.grams] for a
  /// piece/cup/portion unit; `null` when no configured serving size backs
  /// [unit] (should not happen for a unit that reached the dropdown, since
  /// [_availableUnits] only offers units with a backing serving size).
  double? _gramsPerUnitFor(PortionUnit unit) {
    if (unit == PortionUnit.g || unit == PortionUnit.ml) return 1;
    final override = _override;
    if (override == null) return null;
    for (final size in override.quickServingSizes) {
      if (_impliedUnitForLabel(size.label) == unit) return size.grams;
    }
    return null;
  }

  /// Converts the current quantity field + [_selectedUnit] into the actual
  /// grams/ml equivalent this entry resolves to — a transient UI
  /// computation, not persisted, so it stays a private local helper rather
  /// than a `MealEntry` method (`MealEntry` operates on already-persisted
  /// entities, not this form's in-progress state).
  double _resolveGramsEquivalent() {
    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) return 0;
    return quantity * (_gramsPerUnitFor(_selectedUnit) ?? 0);
  }

  bool get _isQuantityValid {
    final quantity = double.tryParse(_quantityController.text);
    return quantity != null && quantity > 0;
  }

  Future<void> _handleLogPressed() async {
    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) return;

    final now = DateTime.now();
    final draft = MealEntry(
      id: '',
      mealSlot: _selectedSlot,
      foodRef: widget.item.resolvedFoodRef,
      foodRefSource: widget.item.source ?? 'off_ref',
      quantity: quantity,
      unit: _selectedUnit,
      productNameSnapshot: widget.item.productName,
      brandSnapshot: widget.item.brand,
      calories100gSnapshot: widget.item.calories100g,
      protein100gSnapshot: widget.item.protein100g,
      carbs100gSnapshot: widget.item.carbs100g,
      fat100gSnapshot: widget.item.fat100g,
      co2e100gSnapshot: widget.item.co2e100g,
      confidenceBandSnapshot: widget.item.confidenceBand,
      loggedAt: now,
      logDate: _formatLogDate(now),
    );

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final slotLabel = _selectedSlot.displayLabel;
    // Captured via the raw ProviderContainer (not this widget's `ref`) so
    // the Undo action stays usable after "Log this food" pops (and disposes)
    // this widget — a disposed ConsumerState's `ref` throws if read from a
    // closure that outlives it.
    final container = ProviderScope.containerOf(context, listen: false);

    try {
      final result = await ref.read(mealEntryProvider.notifier).logFood(draft);
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Added to $slotLabel'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              final notifier = container.read(mealEntryProvider.notifier);
              if (result.wasMerge) {
                unawaited(
                  notifier.undoMerge(result.entry.id, result.loggedDelta),
                );
              } else {
                unawaited(notifier.deleteEntry(result.entry.id));
              }
            },
          ),
        ),
      );
    } on Exception {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            "Couldn't save — check your connection and try again",
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => unawaited(_handleLogPressed()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Establishes a live listener on mealEntryProvider for as long as this
    // form is mounted. mealEntryProvider is autoDispose (no `keepAlive`) —
    // without an active watcher, Riverpod is free to dispose it the moment
    // the current synchronous frame ends, which would crash
    // `MealEntryNotifier.logFood`'s `ref.invalidateSelf()` call (fired
    // after the repository write's `await`) with "Cannot use the Ref ...
    // after it has been disposed." This `watch` (value intentionally
    // unused) keeps the notifier alive for the full duration of
    // `_handleLogPressed`'s async work.
    ref.watch(mealEntryProvider);
    final gramsEquivalent = _resolveGramsEquivalent();
    final scaled = _scaledMacrosForItem(widget.item, gramsEquivalent);
    final availableUnits = _availableUnits();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Macro/CO₂ table is rendered first — above the slot/quantity
        // controls — so it stays visible without scrolling once the
        // on-screen keyboard opens for the quantity field (a real physical-
        // tablet finding: with the block below the quantity row, the
        // keyboard pushed it out of the visible area and it read as "not
        // showing at all" during manual testing, even though it was still
        // in the tree and live-scaling correctly).
        _MacroRow(
          label: 'Calories',
          value: '${scaled.calories?.round() ?? '—'} kcal',
        ),
        _MacroRow(
          label: 'Protein',
          value: '${scaled.protein?.toStringAsFixed(1) ?? '—'} g',
        ),
        _MacroRow(
          label: 'Carbohydrates',
          value: '${scaled.carbs?.toStringAsFixed(1) ?? '—'} g',
        ),
        _MacroRow(
          label: 'Fat',
          value: '${scaled.fat?.toStringAsFixed(1) ?? '—'} g',
        ),
        // CO₂ row — hidden entirely (not '—') when null, per CONTEXT.md.
        if (scaled.co2e != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CO₂e estimate:', style: textTheme.bodyMedium),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatCo2Display(scaled.co2e)!,
                      style: textTheme.bodyMedium,
                    ),
                    if (widget.item.confidenceBand != null) ...[
                      const SizedBox(width: 6),
                      ConfidenceChip(
                        band: widget.item.confidenceBand!,
                        onTap: () => ConfidenceChip.showExplanation(
                          context,
                          widget.item.confidenceBand!,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
        const Divider(height: 24),
        SegmentedButton<MealSlot>(
          segments: MealSlot.values
              .map(
                (slot) => ButtonSegment(
                  value: slot,
                  label: Text(slot.displayLabel),
                ),
              )
              .toList(),
          selected: {_selectedSlot},
          onSelectionChanged: (selection) =>
              setState(() => _selectedSlot = selection.first),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _chips
              .map(
                (chip) => ChoiceChip(
                  label: Text(chip.label),
                  selected: _isChipSelected(chip),
                  onSelected: (_) => _onChipSelected(chip),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                focusNode: _quantityFocusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Quantity'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<PortionUnit>(
              value: _selectedUnit,
              items: availableUnits
                  .map(
                    (unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit.displayLabel),
                    ),
                  )
                  .toList(),
              onChanged: (unit) {
                if (unit == null) return;
                setState(() => _selectedUnit = unit);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isQuantityValid
                ? () => unawaited(_handleLogPressed())
                : null,
            child: const Text('Log this food'),
          ),
        ),
      ],
    );
  }
}

/// A single preset quantity option rendered as a [ChoiceChip].
///
/// [quantity]/[unit] are both `null` for the trailing 'Custom' chip, which
/// only focuses the quantity field rather than assigning it a value.
@immutable
class _QuantityChipOption {
  const _QuantityChipOption({
    required this.label,
    required this.quantity,
    required this.unit,
  });

  final String label;
  final double? quantity;
  final PortionUnit? unit;
}

/// Infers the [PortionUnit] a free-text `ServingSize.label` (e.g. 'Cup',
/// 'Slice', '1 piece') implies, since `ServingSize` stores no explicit unit
/// tag — it's a dynamic label+grams list (CONTEXT.md), not fixed unit
/// slots. Falls back to [PortionUnit.portion] — the app's generic
/// user-configured-serving unit — for any label that doesn't literally
/// reference a cup or a discrete piece/slice.
PortionUnit _impliedUnitForLabel(String label) {
  final lower = label.toLowerCase();
  if (lower.contains('cup')) return PortionUnit.cup;
  if (lower.contains('piece') || lower.contains('slice')) {
    return PortionUnit.piece;
  }
  return PortionUnit.portion;
}

/// Formats [value] for the quantity field — a whole number when it has no
/// fractional part, otherwise its plain string form.
String _formatQuantity(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toString();

/// Formats [now] as a `yyyy-MM-dd` logical log date, matching
/// `MealEntryRepository.getEntriesForToday`'s existing convention.
String _formatLogDate(DateTime now) =>
    '${now.year.toString().padLeft(4, '0')}-'
    '${now.month.toString().padLeft(2, '0')}-'
    '${now.day.toString().padLeft(2, '0')}';

/// Computes [item]'s live-scaled macro/CO₂ values for [gramsEquivalent].
///
/// Mirrors `scaledMacros` (`meal_entry.dart`)'s pure `snapshot *
/// gramsEquivalent / 100` rule, but reads from a [FoodItem]'s per-100g
/// fields directly since [item] is not yet a persisted [MealEntry] at this
/// point in the flow.
ScaledMacros _scaledMacrosForItem(FoodItem item, double gramsEquivalent) {
  double? scale(double? snapshot) =>
      snapshot == null ? null : snapshot * gramsEquivalent / 100;
  return ScaledMacros(
    calories: scale(item.calories100g),
    protein: scale(item.protein100g),
    carbs: scale(item.carbs100g),
    fat: scale(item.fat100g),
    co2e: scale(item.co2e100g),
  );
}

/// A single label/value row in the macro table inside [PortionSlotForm].
class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

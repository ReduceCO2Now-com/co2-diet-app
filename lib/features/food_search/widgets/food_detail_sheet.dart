import 'dart:async';

import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/entities/user_food.dart';
import 'package:co2diet/features/food_search/providers/favorite_notifier.dart';
import 'package:co2diet/features/food_search/widgets/portion_slot_form.dart';
import 'package:co2diet/features/my_foods/providers/user_food_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Displays the shared food detail bottom sheet: [item]'s name, brand, a
/// live-scaled macro/CO₂e table, the [PortionSlotForm] logging UI, a
/// favorite star, and an "Edit this food" action.
///
/// Single shared sheet content for BOTH the food search screen and the
/// barcode scanner (Plan 04-09's sheet-reconciliation fix) — Phase 3's
/// original "no behavioral difference between scan and search sheets"
/// intent, restored after `_BarcodeScanDetailSheet` diverged from this
/// widget.
///
/// Returns the real dismissal [Future] from [showModalBottomSheet] rather
/// than swallowing it — callers that don't care about dismissal (the food
/// search screen) simply don't await it; the barcode scanner awaits it to
/// know when to resume the live camera.
///
/// [initialSlot]/[initialQuantity]/[initialUnit] are optional pre-fill
/// overrides consumed by [PortionSlotForm] — Plans 04-10/04-11 (wave 7, no
/// dependency on each other) use these to open this same sheet pre-filled
/// with an existing entry's slot/quantity/unit for editing. All three
/// default to `null`, preserving today's auto-detect/locale-default
/// behavior for the normal search/scan entry points, which never pass them.
Future<void> showFoodDetailSheet(
  BuildContext context,
  FoodItem item, {
  MealSlot? initialSlot,
  double? initialQuantity,
  PortionUnit? initialUnit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _FoodDetailContent(
      item: item,
      initialSlot: initialSlot,
      initialQuantity: initialQuantity,
      initialUnit: initialUnit,
    ),
  );
}

class _FoodDetailContent extends ConsumerStatefulWidget {
  const _FoodDetailContent({
    required this.item,
    this.initialSlot,
    this.initialQuantity,
    this.initialUnit,
  });

  final FoodItem item;
  final MealSlot? initialSlot;
  final double? initialQuantity;
  final PortionUnit? initialUnit;

  @override
  ConsumerState<_FoodDetailContent> createState() =>
      _FoodDetailContentState();
}

class _FoodDetailContentState extends ConsumerState<_FoodDetailContent> {
  /// `null` while the initial lookup is in flight — the favorite star is
  /// disabled (not tappable) until this resolves, avoiding a toggle race
  /// against an unknown starting state.
  bool? _isFavorite;

  /// The existing override (if any) for [_FoodDetailContent.item], used to
  /// redirect "Edit this food" straight to editing that row (`?userFoodId=`)
  /// instead of creating a second, duplicate override.
  UserFood? _existingOverride;

  @override
  void initState() {
    super.initState();
    unawaited(_loadFavoriteStatus());
    unawaited(_loadExistingOverride());
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await ref
        .read(favoriteProvider.notifier)
        .isFavorite(
          widget.item.resolvedFoodRef,
          widget.item.source ?? 'off_ref',
        );
    if (mounted) setState(() => _isFavorite = isFav);
  }

  Future<void> _loadExistingOverride() async {
    final override = await ref
        .read(userFoodProvider.notifier)
        .findOverrideForFoodRef(
          widget.item.resolvedFoodRef,
          widget.item.source ?? 'off_ref',
        );
    if (mounted) setState(() => _existingOverride = override);
  }

  Future<void> _toggleFavorite() async {
    final item = widget.item;
    await ref.read(favoriteProvider.notifier).toggle(
      Favorite(
        id: '',
        foodRef: item.resolvedFoodRef,
        foodRefSource: item.source ?? 'off_ref',
        productNameSnapshot: item.productName,
        brandSnapshot: item.brand,
        calories100gSnapshot: item.calories100g,
        co2e100gSnapshot: item.co2e100g,
        confidenceBandSnapshot: item.confidenceBand,
        favoritedAt: DateTime.now(),
      ),
    );
    await _loadFavoriteStatus();
  }

  void _editThisFood() {
    final item = widget.item;
    final existingOverride = _existingOverride;
    final foodRefSource = item.source ?? 'off_ref';
    final uri = existingOverride != null
        ? '/custom-food-stub'
              '?userFoodId=${Uri.encodeComponent(existingOverride.id)}'
        : '/custom-food-stub'
              '?overrideOf=${Uri.encodeComponent(item.resolvedFoodRef)}'
              '&overrideOfSource=${Uri.encodeComponent(foodRefSource)}';
    unawaited(context.push(uri));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasBrand = item.brand != null && item.brand!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite == true ? Icons.star : Icons.star_border,
                  ),
                  tooltip: _isFavorite == true
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  onPressed: _isFavorite == null
                      ? null
                      : () => unawaited(_toggleFavorite()),
                ),
              ],
            ),
            // Brand (optional)
            if (hasBrand) ...[
              const SizedBox(height: 4),
              Text(
                item.brand!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const Divider(height: 24),
            PortionSlotForm(
              item: item,
              initialSlot: widget.initialSlot,
              initialQuantity: widget.initialQuantity,
              initialUnit: widget.initialUnit,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _editThisFood,
                child: const Text('Edit this food'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

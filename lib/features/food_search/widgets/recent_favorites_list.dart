import 'dart:async';

import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_entry_food_item_mapping.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/features/barcode_scan/utils/co2_formatter.dart';
import 'package:co2diet/features/food_search/providers/favorite_notifier.dart';
import 'package:co2diet/features/food_search/widgets/food_detail_sheet.dart';
import 'package:co2diet/features/food_search/widgets/search_prompt_widget.dart';
import 'package:co2diet/features/meal_logging/providers/meal_entry_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Replaces the food search screen's plain [SearchPromptWidget] empty-query
/// state with two one-tap-loggable sections (LOG-07/LOG-08):
///
/// - "Recent" — up to 15 individually logged items, most-recent-first
///   (`MealEntryNotifier.getRecent`).
/// - "Favorites" — starred foods (`favoriteProvider`).
///
/// Falls back to the original [SearchPromptWidget] when both sections are
/// empty, so a first-time user with no history sees the familiar prompt
/// rather than two empty section headers.
///
/// Tapping a row's body logs it instantly (one tap = a fresh log using the
/// row's own last-used quantity/unit and a freshly time-of-day-auto-detected
/// slot) with an "Added to `<Slot>`" + Undo snackbar, matching
/// `PortionSlotForm`'s success feedback. Tapping the small edit icon instead
/// opens the shared `FoodDetailBottomSheet`/`PortionSlotForm`, pre-filled
/// with that row's values, for a full edit before logging.
class RecentFavoritesList extends ConsumerStatefulWidget {
  /// Creates a [RecentFavoritesList].
  const RecentFavoritesList({super.key});

  @override
  ConsumerState<RecentFavoritesList> createState() =>
      _RecentFavoritesListState();
}

class _RecentFavoritesListState extends ConsumerState<RecentFavoritesList> {
  /// Fetched once per mount (not re-fetched on every rebuild) —
  /// `getRecent()` is a plain on-demand read (see
  /// `MealEntryNotifier.getRecent`'s doc comment), not part of any watched
  /// provider state.
  late final Future<List<MealEntry>> _recentFuture;

  @override
  void initState() {
    super.initState();
    _recentFuture = ref.read(mealEntryProvider.notifier).getRecent();
  }

  void _showLoggedSnackBar(MealSlot slot, MealLogResult result) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    // Captured via the raw ProviderContainer (not this widget's `ref`) so
    // Undo stays usable even if this widget is disposed before it's tapped
    // (e.g. the user navigates away) — same pattern as
    // `PortionSlotForm._handleLogPressed`.
    final container = ProviderScope.containerOf(context, listen: false);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Added to ${slot.displayLabel}'),
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
  }

  Future<void> _logRecent(MealEntry recent) async {
    final slot = detectMealSlotForTime(DateTime.now());
    final result = await ref
        .read(mealEntryProvider.notifier)
        .logFromRecent(recent);
    _showLoggedSnackBar(slot, result);
  }

  Future<void> _logFavorite(Favorite favorite) async {
    final slot = detectMealSlotForTime(DateTime.now());
    final result = await ref
        .read(favoriteProvider.notifier)
        .logFromFavorite(favorite, autoDetectedSlot: slot);
    _showLoggedSnackBar(slot, result);
  }

  void _editRecent(MealEntry recent) {
    unawaited(
      showFoodDetailSheet(
        context,
        recent.toFoodItem(),
        initialSlot: recent.mealSlot,
        initialQuantity: recent.quantity,
        initialUnit: recent.unit,
      ),
    );
  }

  void _editFavorite(Favorite favorite) {
    unawaited(
      showFoodDetailSheet(
        context,
        favorite.toFoodItem(),
        initialSlot: detectMealSlotForTime(DateTime.now()),
        initialQuantity: favorite.lastQuantity ?? 100,
        initialUnit: favorite.lastUnit ?? PortionUnit.g,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keeps mealEntryProvider (autoDispose) alive for as long as this list
    // is mounted — `logFromRecent`/`logFromFavorite` both eventually call
    // `MealEntryNotifier.logFood`, whose `ref.invalidateSelf()` (fired
    // after the repository write's `await`) would crash if nothing were
    // watching the provider by then. Same defensive pattern established in
    // `PortionSlotForm.build` (Plan 04-09).
    ref.watch(mealEntryProvider);
    final favoritesAsync = ref.watch(favoriteProvider);

    return FutureBuilder<List<MealEntry>>(
      future: _recentFuture,
      builder: (context, recentSnapshot) {
        final recentLoaded =
            recentSnapshot.connectionState == ConnectionState.done;
        final recent = recentSnapshot.data ?? const <MealEntry>[];
        final favoritesLoaded = !favoritesAsync.isLoading;
        final favorites = favoritesAsync.value ?? const <Favorite>[];

        if (recentLoaded &&
            favoritesLoaded &&
            recent.isEmpty &&
            favorites.isEmpty) {
          return const SearchPromptWidget();
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            if (recent.isNotEmpty) ...[
              const _SectionHeader('Recent'),
              for (final entry in recent)
                _RecentRow(
                  entry: entry,
                  onTap: () => unawaited(_logRecent(entry)),
                  onEdit: () => _editRecent(entry),
                ),
            ],
            if (favorites.isNotEmpty) ...[
              const _SectionHeader('Favorites'),
              for (final favorite in favorites)
                _FavoriteRow(
                  favorite: favorite,
                  onTap: () => unawaited(_logFavorite(favorite)),
                  onEdit: () => _editFavorite(favorite),
                ),
            ],
          ],
        );
      },
    );
  }
}

/// A bold, primary-colored section label ("Recent" / "Favorites").
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// A single Recent row: product name + a scaled calories/CO₂ summary,
/// trailing an edit icon. Tapping the row body logs instantly; tapping the
/// edit icon opens the pre-filled sheet instead.
class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.entry,
    required this.onTap,
    required this.onEdit,
  });

  final MealEntry entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        entry.productNameSnapshot,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_summary(entry)),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined, size: 18),
        tooltip: 'Edit before logging',
        onPressed: onEdit,
      ),
    );
  }

  /// Scaled calories/CO₂ summary for [entry]'s own last-used quantity/unit.
  ///
  /// Only computed for weight-based units ([PortionUnit.g]/
  /// [PortionUnit.ml]), where `quantity` directly IS the grams/ml
  /// equivalent. A piece/cup/portion unit needs a configured weight-per-unit
  /// conversion this row has no access to, so it falls back to a plain
  /// quantity+unit label rather than fabricating a scaled number.
  String _summary(MealEntry entry) {
    if (!entry.unit.isWeightBased) {
      return '${_formatQuantity(entry.quantity)} ${entry.unit.displayLabel}';
    }
    final scaled = entry.scaled(entry.quantity);
    final calText = scaled.calories != null
        ? '${scaled.calories!.round()} kcal'
        : '— kcal';
    final co2Text = formatCo2Display(scaled.co2e);
    return co2Text != null ? '$calText • $co2Text' : calText;
  }
}

/// A single Favorite row: filled star + product name, trailing an edit
/// icon. Tapping the row body logs instantly using the favorite's
/// remembered quantity/unit; tapping the edit icon opens the pre-filled
/// sheet instead.
class _FavoriteRow extends StatelessWidget {
  const _FavoriteRow({
    required this.favorite,
    required this.onTap,
    required this.onEdit,
  });

  final Favorite favorite;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(Icons.star, color: Theme.of(context).colorScheme.primary),
      title: Text(
        favorite.productNameSnapshot,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined, size: 18),
        tooltip: 'Edit before logging',
        onPressed: onEdit,
      ),
    );
  }
}

/// Formats [value] for display — a whole number when it has no fractional
/// part, otherwise its plain string form. Mirrors `PortionSlotForm`'s
/// private `_formatQuantity` (duplicated here rather than shared since
/// both are file-private single-line helpers).
String _formatQuantity(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toString();

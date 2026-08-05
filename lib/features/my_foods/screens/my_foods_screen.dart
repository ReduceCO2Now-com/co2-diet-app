import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/domain/entities/user_food.dart';
import 'package:co2diet/features/my_foods/providers/user_food_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// My Foods list screen (LOG-10/LOG-11) — the alphabetical list of custom
/// foods and personal overrides, reachable from Settings only (per
/// CONTEXT.md: "not from the food search screen").
///
/// Client-side filtered by a local [TextEditingController] against the
/// unfiltered [userFoodProvider] list (Plan 04-07's parameterless
/// `build()` decision). Tapping a row navigates to the edit form with
/// `userFoodId` set; the "+ Add Custom Food" action navigates to a blank
/// form.
class MyFoodsScreen extends ConsumerStatefulWidget {
  /// Creates the [MyFoodsScreen].
  const MyFoodsScreen({super.key});

  @override
  ConsumerState<MyFoodsScreen> createState() => _MyFoodsScreenState();
}

class _MyFoodsScreenState extends ConsumerState<MyFoodsScreen> {
  final _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filterController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foodsAsync = ref.watch(userFoodProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Foods'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Custom Food',
            onPressed: () => context.push('/custom-food-stub'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.containerMargin,
              vertical: AppSpacing.stackGap,
            ),
            child: TextField(
              controller: _filterController,
              decoration: const InputDecoration(
                hintText: 'Filter custom foods...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: foodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) =>
            const Center(child: Text('Error loading custom foods')),
        data: (foods) => _buildList(context, foods),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<UserFood> foods) {
    final filter = _filterController.text.trim().toLowerCase();
    final filtered = filter.isEmpty
        ? foods
        : foods
              .where((food) => food.name.toLowerCase().contains(filter))
              .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.stackGap),
              Text(
                foods.isEmpty
                    ? 'No custom foods yet — tap + Add Custom Food to '
                          'create one'
                    : 'No custom foods match your search',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final food = filtered[i];

        return ListTile(
          title: Text(food.name),
          subtitle: food.brand != null ? Text(food.brand!) : null,
          trailing: food.isOverride
              ? const Chip(
                  label: Text('Override'),
                  visualDensity: VisualDensity.compact,
                )
              : null,
          onTap: () => context.push('/custom-food-stub?userFoodId=${food.id}'),
        );
      },
    );
  }
}

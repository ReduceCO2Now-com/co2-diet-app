import 'package:co2diet/features/food_search/providers/food_search_notifier.dart';
import 'package:co2diet/features/food_search/providers/food_search_state.dart';
import 'package:co2diet/features/food_search/widgets/api_loading_banner.dart';
import 'package:co2diet/features/food_search/widgets/food_detail_sheet.dart';
import 'package:co2diet/features/food_search/widgets/food_result_row.dart';
import 'package:co2diet/features/food_search/widgets/no_results_widget.dart';
import 'package:co2diet/features/food_search/widgets/search_prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Full-screen food search screen wired to [FoodSearchNotifier].
///
/// Opened from Settings → "Search foods" via go_router's `/food-search` route.
/// The route is a top-level GoRoute (not nested inside the shell) so it covers
/// the bottom navigation bar.
///
/// State machine (see [FoodSearchNotifier] and [FoodSearchState]):
///   - Initial / query < 2 chars → [SearchPromptWidget]
///   - Non-empty results → [ListView] of [FoodResultRow]s
///   - Empty results (API returned 0 items) → [NoResultsVariant.genuine]
///   - Offline, no local hits → [NoResultsVariant.offline]
///   - Network error → [NoResultsVariant.networkError] with retry button
///   - API call in flight (AsyncLoading) → [ApiLoadingBanner]
class FoodSearchScreen extends ConsumerStatefulWidget {
  /// Creates the [FoodSearchScreen].
  const FoodSearchScreen({super.key});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Deferred focus — ensures keyboard opens after the screen transition
    // animation completes, rather than fighting the hero animation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(foodSearchProvider.notifier);
    final searchState = ref.watch(foodSearchProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search for a food...',
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      notifier.onQueryChanged('');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            // Rebuild to show/hide the clear button.
            setState(() {});
            notifier.onQueryChanged(value);
          },
          onSubmitted: notifier.onQuerySubmitted,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan barcode',
            onPressed: () => context.push('/barcode-scan'),
          ),
        ],
      ),
      body: searchState.when(
        data: (state) => _buildBody(context, state, notifier),
        loading: () => const ApiLoadingBanner(),
        error: (e, _) => NoResultsWidget(
          variant: NoResultsVariant.networkError,
          query: _controller.text,
          onRetry: () => notifier.retry(_controller.text),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FoodSearchState state,
    FoodSearchNotifier notifier,
  ) {
    return switch (state) {
      FoodSearchPrompt() => const SearchPromptWidget(),
      FoodSearchResults(:final items) when items.isEmpty => NoResultsWidget(
          variant: NoResultsVariant.genuine,
          query: _controller.text,
        ),
      FoodSearchResults(:final items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, i) => FoodResultRow(
            item: items[i],
            onTap: () => showFoodDetailSheet(context, items[i]),
          ),
        ),
      FoodSearchOfflineNoResults() => NoResultsWidget(
          variant: NoResultsVariant.offline,
          query: _controller.text,
        ),
      FoodSearchNetworkError() => NoResultsWidget(
          variant: NoResultsVariant.networkError,
          query: _controller.text,
          onRetry: () => notifier.retry(_controller.text),
        ),
    };
  }
}

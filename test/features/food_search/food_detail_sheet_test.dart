// Widget tests for the favorite star in FoodDetailBottomSheet
// (_FoodDetailContent), specifically reproducing a reported bug: tapping
// the star successfully writes the favorite (confirmed via the Favorites
// list) but the star icon itself never visually flips to filled.
//
// Root cause under test: favoriteProvider is autoDispose (`@riverpod`, no
// keepAlive). _FoodDetailContentState only ever `ref.read`s it — it never
// `ref.watch`es it anywhere — so when the sheet is the ONLY thing in the
// tree touching favoriteProvider (the real-world case: opening a detail
// sheet from search RESULTS, where RecentFavoritesList — which does
// `ref.watch(favoriteProvider)` — isn't mounted), nothing keeps the
// notifier alive across the toggle's internal `await`. If Riverpod
// disposes it mid-flight, `toggle()`'s `ref.invalidateSelf()` throws,
// which aborts `_toggleFavorite()` before its trailing
// `await _loadFavoriteStatus()` ever runs — the write already landed, but
// the icon-refreshing re-read never happens. Same class of pitfall already
// documented and guarded against elsewhere in this codebase (see
// PortionSlotForm.build's `ref.watch(mealEntryProvider)` comment).
import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:co2diet/domain/repositories/i_user_food_repository.dart';
import 'package:co2diet/features/food_search/widgets/food_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealEntryRepository extends Mock implements IMealEntryRepository {}

class _MockUserFoodRepository extends Mock implements IUserFoodRepository {}

const _item = FoodItem(
  productName: 'Test Food',
  barcode: '1234567890123',
  source: 'off_ref',
  calories100g: 200,
);

/// Wraps [child] with real repository mocks — deliberately NOT rendering
/// anything else that watches `favoriteProvider` (e.g. RecentFavoritesList)
/// alongside it, matching the real search-results entry point where the
/// sheet is the only consumer of favoriteProvider in the tree.
Widget _wrap(
  Widget child, {
  required IMealEntryRepository mealEntryRepo,
  required IUserFoodRepository userFoodRepo,
}) {
  return ProviderScope(
    overrides: [
      mealEntryRepositoryProvider.overrideWithValue(mealEntryRepo),
      userFoodRepositoryProvider.overrideWithValue(userFoodRepo),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showFoodDetailSheet(context, _item),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  late _MockMealEntryRepository mockMealEntryRepo;
  late _MockUserFoodRepository mockUserFoodRepo;

  setUpAll(() {
    registerFallbackValue(
      Favorite(
        id: '',
        foodRef: '0',
        foodRefSource: 'off_ref',
        productNameSnapshot: '',
        favoritedAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    mockMealEntryRepo = _MockMealEntryRepository();
    mockUserFoodRepo = _MockUserFoodRepository();
    when(
      () => mockUserFoodRepo.findOverrideForFoodRef(any(), any()),
    ).thenAnswer((_) async => null);
  });

  testWidgets(
    'tapping the favorite star updates the icon to filled after a '
    'successful toggle, with no sibling widget watching favoriteProvider',
    (tester) async {
      // Starts un-favorited; toggling flips it to favorited.
      when(
        () => mockMealEntryRepo.isFavorite(any(), any()),
      ).thenAnswer((_) async => false);
      when(() => mockMealEntryRepo.toggleFavorite(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as Favorite,
      );

      await tester.pumpWidget(
        _wrap(
          const SizedBox(),
          mealEntryRepo: mockMealEntryRepo,
          userFoodRepo: mockUserFoodRepo,
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);

      // After the toggle, isFavorite must reflect the new state for the
      // sheet's own re-check to pick up.
      when(
        () => mockMealEntryRepo.isFavorite(any(), any()),
      ).thenAnswer((_) async => true);

      await tester.tap(find.byIcon(Icons.star_border));
      await tester.pumpAndSettle();

      verify(() => mockMealEntryRepo.toggleFavorite(any())).called(1);
      expect(
        find.byIcon(Icons.star),
        findsOneWidget,
        reason:
            'star icon must flip to filled after a successful toggle even '
            'when nothing else in the tree watches favoriteProvider',
      );
      expect(find.byIcon(Icons.star_border), findsNothing);
    },
  );
}

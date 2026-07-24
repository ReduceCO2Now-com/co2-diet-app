// Widget tests for RecentFavoritesList (LOG-07/LOG-08): empty-query
// Recent + Favorites sections, one-tap log (no sheet), and edit-icon
// pre-fill of the shared FoodDetailBottomSheet/PortionSlotForm.
//
// Overrides mealEntryRepositoryProvider/userFoodRepositoryProvider with
// mocktail mocks — matches the pattern in
// test/features/food_search/portion_slot_form_test.dart.

import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:co2diet/domain/repositories/i_user_food_repository.dart';
import 'package:co2diet/features/food_search/widgets/portion_slot_form.dart';
import 'package:co2diet/features/food_search/widgets/recent_favorites_list.dart';
import 'package:co2diet/features/food_search/widgets/search_prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealEntryRepository extends Mock implements IMealEntryRepository {}

class _MockUserFoodRepository extends Mock implements IUserFoodRepository {}

MealEntry _buildRecent({
  String id = 'entry-1',
  double quantity = 100,
  PortionUnit unit = PortionUnit.g,
}) => MealEntry(
  id: id,
  mealSlot: MealSlot.lunch,
  foodRef: 'food-1',
  foodRefSource: 'off_ref',
  quantity: quantity,
  unit: unit,
  productNameSnapshot: 'Recent Food',
  calories100gSnapshot: 200,
  co2e100gSnapshot: 1.5,
  confidenceBandSnapshot: 'medium',
  loggedAt: DateTime(2026, 7, 23, 12),
  logDate: '2026-07-23',
);

Favorite _buildFavorite({
  String id = 'fav-1',
  double? lastQuantity,
  PortionUnit? lastUnit,
}) => Favorite(
  id: id,
  foodRef: 'food-2',
  foodRefSource: 'off_ref',
  productNameSnapshot: 'Favorite Food',
  favoritedAt: DateTime(2026, 7, 23, 12),
  calories100gSnapshot: 150,
  co2e100gSnapshot: 1,
  confidenceBandSnapshot: 'high',
  lastQuantity: lastQuantity,
  lastUnit: lastUnit,
);

/// Wraps [child] with a [ProviderScope] (repository overrides) and a
/// [MaterialApp] host — a real Navigator is needed since edit-icon taps
/// open a modal bottom sheet.
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
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  late _MockMealEntryRepository mockMealEntryRepo;
  late _MockUserFoodRepository mockUserFoodRepo;

  setUpAll(() {
    registerFallbackValue(_buildRecent());
    registerFallbackValue(_buildFavorite());
    registerFallbackValue(PortionUnit.g);
  });

  setUp(() {
    mockMealEntryRepo = _MockMealEntryRepository();
    mockUserFoodRepo = _MockUserFoodRepository();
    when(
      () => mockUserFoodRepo.findOverrideForFoodRef(any(), any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockMealEntryRepo.getEntriesForToday(),
    ).thenAnswer((_) async => <MealEntry>[]);
  });

  group('RecentFavoritesList', () {
    testWidgets(
      'shows the original search prompt when both Recent and Favorites '
      'are empty',
      (tester) async {
        when(
          () => mockMealEntryRepo.getRecent(limit: any(named: 'limit')),
        ).thenAnswer((_) async => <MealEntry>[]);
        when(
          () => mockMealEntryRepo.getFavorites(),
        ).thenAnswer((_) async => <Favorite>[]);

        await tester.pumpWidget(
          _wrap(
            const RecentFavoritesList(),
            mealEntryRepo: mockMealEntryRepo,
            userFoodRepo: mockUserFoodRepo,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SearchPromptWidget), findsOneWidget);
        expect(find.text('Recent'), findsNothing);
        expect(find.text('Favorites'), findsNothing);
      },
    );

    testWidgets('shows Recent and Favorites sections when history exists', (
      tester,
    ) async {
      when(
        () => mockMealEntryRepo.getRecent(limit: any(named: 'limit')),
      ).thenAnswer((_) async => [_buildRecent()]);
      when(
        () => mockMealEntryRepo.getFavorites(),
      ).thenAnswer((_) async => [_buildFavorite()]);

      await tester.pumpWidget(
        _wrap(
          const RecentFavoritesList(),
          mealEntryRepo: mockMealEntryRepo,
          userFoodRepo: mockUserFoodRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Recent Food'), findsOneWidget);
      expect(find.text('Favorite Food'), findsOneWidget);
      expect(find.byType(SearchPromptWidget), findsNothing);
    });

    testWidgets(
      'tapping a Recent row body logs it instantly with an Undo snackbar '
      '(no sheet)',
      (tester) async {
        when(
          () => mockMealEntryRepo.getRecent(limit: any(named: 'limit')),
        ).thenAnswer((_) async => [_buildRecent()]);
        when(
          () => mockMealEntryRepo.getFavorites(),
        ).thenAnswer((_) async => <Favorite>[]);
        when(
          () => mockMealEntryRepo.logOrMerge(any()),
        ).thenAnswer((_) async => _buildRecent(id: 'new-1'));

        await tester.pumpWidget(
          _wrap(
            const RecentFavoritesList(),
            mealEntryRepo: mockMealEntryRepo,
            userFoodRepo: mockUserFoodRepo,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Recent Food'));
        await tester.pumpAndSettle();

        final captured =
            verify(() => mockMealEntryRepo.logOrMerge(captureAny()))
                    .captured
                    .single
                as MealEntry;
        expect(captured.foodRef, 'food-1');
        expect(captured.quantity, 100);

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);
        expect(find.byType(PortionSlotForm), findsNothing);
      },
    );

    testWidgets(
      'tapping a Favorite row body logs it instantly using its last-used '
      'quantity/unit',
      (tester) async {
        final favorite = _buildFavorite(
          lastQuantity: 250,
          lastUnit: PortionUnit.ml,
        );
        when(
          () => mockMealEntryRepo.getRecent(limit: any(named: 'limit')),
        ).thenAnswer((_) async => <MealEntry>[]);
        when(
          () => mockMealEntryRepo.getFavorites(),
        ).thenAnswer((_) async => [favorite]);
        when(() => mockMealEntryRepo.logOrMerge(any())).thenAnswer(
          (_) async =>
              _buildRecent(id: 'new-1', quantity: 250, unit: PortionUnit.ml),
        );
        when(
          () => mockMealEntryRepo.touchFavoriteUsage(
            any(),
            any(),
            quantity: any(named: 'quantity'),
            unit: any(named: 'unit'),
          ),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(
          _wrap(
            const RecentFavoritesList(),
            mealEntryRepo: mockMealEntryRepo,
            userFoodRepo: mockUserFoodRepo,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Favorite Food'));
        await tester.pumpAndSettle();

        final captured =
            verify(() => mockMealEntryRepo.logOrMerge(captureAny()))
                    .captured
                    .single
                as MealEntry;
        expect(captured.foodRef, 'food-2');
        expect(captured.quantity, 250);
        expect(captured.unit, PortionUnit.ml);

        verify(
          () => mockMealEntryRepo.touchFavoriteUsage(
            'food-2',
            'off_ref',
            quantity: 250,
            unit: PortionUnit.ml,
          ),
        ).called(1);

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping the edit icon on a Recent row opens the pre-filled sheet '
      'instead of logging',
      (tester) async {
        when(
          () => mockMealEntryRepo.getRecent(limit: any(named: 'limit')),
        ).thenAnswer((_) async => [_buildRecent(quantity: 150)]);
        when(
          () => mockMealEntryRepo.getFavorites(),
        ).thenAnswer((_) async => <Favorite>[]);

        await tester.pumpWidget(
          _wrap(
            const RecentFavoritesList(),
            mealEntryRepo: mockMealEntryRepo,
            userFoodRepo: mockUserFoodRepo,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(PortionSlotForm), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '150'), findsOneWidget);
        verifyNever(() => mockMealEntryRepo.logOrMerge(any()));
      },
    );

    testWidgets(
      'tapping the edit icon on a Favorite row opens the pre-filled sheet '
      'instead of logging',
      (tester) async {
        final favorite = _buildFavorite(
          lastQuantity: 42,
          lastUnit: PortionUnit.ml,
        );
        when(
          () => mockMealEntryRepo.getRecent(limit: any(named: 'limit')),
        ).thenAnswer((_) async => <MealEntry>[]);
        when(
          () => mockMealEntryRepo.getFavorites(),
        ).thenAnswer((_) async => [favorite]);

        await tester.pumpWidget(
          _wrap(
            const RecentFavoritesList(),
            mealEntryRepo: mockMealEntryRepo,
            userFoodRepo: mockUserFoodRepo,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(PortionSlotForm), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '42'), findsOneWidget);
        verifyNever(() => mockMealEntryRepo.logOrMerge(any()));
      },
    );
  });
}

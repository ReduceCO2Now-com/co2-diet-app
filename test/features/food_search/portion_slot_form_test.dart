// Widget tests for PortionSlotForm (replaces the Wave 0 skip stub).
//
// Overrides userFoodRepositoryProvider/mealEntryRepositoryProvider with
// mocktail mocks — the real UserFoodNotifier/MealEntryNotifier run on top
// of these mocks, matching the pattern established in
// test/features/food_search/favorites_test.dart and
// test/features/my_foods/custom_food_form_test.dart.

import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/entities/serving_size.dart';
import 'package:co2diet/domain/entities/user_food.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:co2diet/domain/repositories/i_user_food_repository.dart';
import 'package:co2diet/features/food_search/widgets/portion_slot_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserFoodRepository extends Mock implements IUserFoodRepository {}

class _MockMealEntryRepository extends Mock implements IMealEntryRepository {}

FoodItem _buildItem({
  String barcode = '1234567890123',
  String source = 'off_ref',
  double? calories100g = 200,
  double? protein100g = 10,
  double? carbs100g = 20,
  double? fat100g = 5,
  double? co2e100g = 2.5,
  String? confidenceBand = 'medium',
}) => FoodItem(
  productName: 'Test Food',
  barcode: barcode,
  source: source,
  calories100g: calories100g,
  protein100g: protein100g,
  carbs100g: carbs100g,
  fat100g: fat100g,
  co2e100g: co2e100g,
  confidenceBand: confidenceBand,
);

MealEntry _buildPersistedEntry({
  String id = 'entry-1',
  double quantity = 100,
  PortionUnit unit = PortionUnit.g,
}) => MealEntry(
  id: id,
  mealSlot: MealSlot.lunch,
  foodRef: '1234567890123',
  foodRefSource: 'off_ref',
  quantity: quantity,
  unit: unit,
  productNameSnapshot: 'Test Food',
  loggedAt: DateTime(2026, 7, 24, 12),
  logDate: '2026-07-24',
);

/// Wraps [child] with a [ProviderScope] (repository overrides) and a
/// [MaterialApp] fixed to [locale] (avoids relying on the test harness's
/// ambient locale for the LOG-06 locale-aware default tests).
Widget _wrap(
  Widget child, {
  required IUserFoodRepository userFoodRepo,
  required IMealEntryRepository mealEntryRepo,
  Locale locale = const Locale('en', 'DE'),
}) {
  return ProviderScope(
    overrides: [
      userFoodRepositoryProvider.overrideWithValue(userFoodRepo),
      mealEntryRepositoryProvider.overrideWithValue(mealEntryRepo),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en', 'DE'), Locale('en', 'US')],
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

/// Same as [_wrap], but presents [formBuilder] via a real
/// `showModalBottomSheet` route (with a plain "Open" trigger below it) —
/// needed for tests that exercise `PortionSlotForm`'s
/// `Navigator.of(context).pop()` on a successful log, which requires an
/// actual underlying route to pop back to (unlike a bare `home:` widget).
Widget _wrapAsModalSheet(
  WidgetBuilder formBuilder, {
  required IUserFoodRepository userFoodRepo,
  required IMealEntryRepository mealEntryRepo,
  Locale locale = const Locale('en', 'DE'),
}) {
  return ProviderScope(
    overrides: [
      userFoodRepositoryProvider.overrideWithValue(userFoodRepo),
      mealEntryRepositoryProvider.overrideWithValue(mealEntryRepo),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en', 'DE'), Locale('en', 'US')],
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: formBuilder,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  late _MockUserFoodRepository mockUserFoodRepo;
  late _MockMealEntryRepository mockMealEntryRepo;

  setUpAll(() {
    registerFallbackValue(_buildPersistedEntry());
  });

  setUp(() {
    mockUserFoodRepo = _MockUserFoodRepository();
    mockMealEntryRepo = _MockMealEntryRepository();
    // UserFoodNotifier.build() and MealEntryNotifier.build() both run on
    // first access regardless of which method is actually exercised.
    when(
      () => mockUserFoodRepo.getAllAlphabetical(),
    ).thenAnswer((_) async => <UserFood>[]);
    when(
      () => mockMealEntryRepo.getEntriesForToday(),
    ).thenAnswer((_) async => <MealEntry>[]);
    when(
      () => mockUserFoodRepo.findOverrideForFoodRef(any(), any()),
    ).thenAnswer((_) async => null);
  });

  group('PortionSlotForm', () {
    testWidgets(
      'meal slot segmented control pre-selects based on time of day',
      (tester) async {
        final expectedSlot = detectMealSlotForTime(DateTime.now());

        await tester.pumpWidget(
          _wrap(
            PortionSlotForm(item: _buildItem()),
            userFoodRepo: mockUserFoodRepo,
            mealEntryRepo: mockMealEntryRepo,
          ),
        );
        await tester.pumpAndSettle();

        final segmentedButton = tester.widget<SegmentedButton<MealSlot>>(
          find.byType(SegmentedButton<MealSlot>),
        );
        expect(segmentedButton.selected, {expectedSlot});
      },
    );

    testWidgets(
      'tapping a preset quantity chip pre-fills an editable numeric '
      'field',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            PortionSlotForm(item: _buildItem()),
            userFoodRepo: mockUserFoodRepo,
            mealEntryRepo: mockMealEntryRepo,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ChoiceChip, '200g'));
        await tester.pump();

        expect(find.widgetWithText(TextFormField, '200'), findsOneWidget);

        // Field remains directly editable afterward (not locked to the
        // chip's exact value).
        await tester.enterText(find.byType(TextFormField), '150');
        await tester.pump();
        expect(find.text('150'), findsOneWidget);
      },
    );

    testWidgets(
      'unit dropdown only offers g/ml when no weight-per-unit is '
      'configured',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            PortionSlotForm(item: _buildItem()),
            userFoodRepo: mockUserFoodRepo,
            mealEntryRepo: mockMealEntryRepo,
          ),
        );
        await tester.pumpAndSettle();

        final dropdown = tester.widget<DropdownButton<PortionUnit>>(
          find.byType(DropdownButton<PortionUnit>),
        );
        expect(dropdown.items!.map((item) => item.value).toList(), [
          PortionUnit.g,
          PortionUnit.ml,
        ]);
      },
    );

    testWidgets(
      'unit dropdown offers a configured non-metric unit when a quick '
      'serving size exists',
      (tester) async {
        when(
          () => mockUserFoodRepo.findOverrideForFoodRef(any(), any()),
        ).thenAnswer(
          (_) async => const UserFood(
            id: 'uf-1',
            name: 'Test Food',
            calories: 200,
            quickServingSizes: [ServingSize(label: 'Slice', grams: 30)],
          ),
        );

        await tester.pumpWidget(
          _wrap(
            PortionSlotForm(item: _buildItem()),
            userFoodRepo: mockUserFoodRepo,
            mealEntryRepo: mockMealEntryRepo,
          ),
        );
        await tester.pumpAndSettle();

        final dropdown = tester.widget<DropdownButton<PortionUnit>>(
          find.byType(DropdownButton<PortionUnit>),
        );
        expect(dropdown.items!.map((item) => item.value).toList(), [
          PortionUnit.g,
          PortionUnit.ml,
          PortionUnit.piece,
        ]);
      },
    );

    testWidgets(
      'displayed macro values scale live when quantity changes',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            PortionSlotForm(item: _buildItem()),
            userFoodRepo: mockUserFoodRepo,
            mealEntryRepo: mockMealEntryRepo,
          ),
        );
        await tester.pumpAndSettle();

        // Default 100g -> 200 kcal (item.calories100g == 200).
        expect(find.text('200 kcal'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '150');
        await tester.pump();

        // 150g -> 300 kcal (200 * 150 / 100).
        expect(find.text('300 kcal'), findsOneWidget);
        expect(find.text('200 kcal'), findsNothing);
      },
    );

    testWidgets(
      'Log this food button is disabled until quantity is valid (>0)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            PortionSlotForm(item: _buildItem()),
            userFoodRepo: mockUserFoodRepo,
            mealEntryRepo: mockMealEntryRepo,
          ),
        );
        await tester.pumpAndSettle();

        FilledButton logButton() => tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Log this food'),
        );

        expect(logButton().onPressed, isNotNull);

        await tester.enterText(find.byType(TextFormField), '0');
        await tester.pump();
        expect(logButton().onPressed, isNull);

        await tester.enterText(find.byType(TextFormField), 'abc');
        await tester.pump();
        expect(logButton().onPressed, isNull);

        await tester.enterText(find.byType(TextFormField), '50');
        await tester.pump();
        expect(logButton().onPressed, isNotNull);
      },
    );

    testWidgets(
      'logging uses FoodItem.resolvedFoodRef as the draft foodRef',
      (tester) async {
        when(
          () => mockMealEntryRepo.logOrMerge(any()),
        ).thenAnswer((_) async => _buildPersistedEntry());

        await tester.pumpWidget(
          _wrapAsModalSheet(
            (_) => PortionSlotForm(item: _buildItem(barcode: '9999999999999')),
            userFoodRepo: mockUserFoodRepo,
            mealEntryRepo: mockMealEntryRepo,
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilledButton, 'Log this food'));
        await tester.pumpAndSettle();

        final captured =
            verify(() => mockMealEntryRepo.logOrMerge(captureAny()))
                    .captured
                    .single
                as MealEntry;
        expect(captured.foodRef, '9999999999999');
        expect(captured.foodRefSource, 'off_ref');

        // Undo snackbar shown after the successful log.
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);
      },
    );

    testWidgets(
      'imperial locale defaults to a configured non-metric quick serving '
      'size when one exists',
      (tester) async {
        when(
          () => mockUserFoodRepo.findOverrideForFoodRef(any(), any()),
        ).thenAnswer(
          (_) async => const UserFood(
            id: 'uf-1',
            name: 'Test Food',
            calories: 200,
            quickServingSizes: [ServingSize(label: 'Slice', grams: 30)],
          ),
        );

        await tester.pumpWidget(
          _wrap(
            PortionSlotForm(item: _buildItem()),
            userFoodRepo: mockUserFoodRepo,
            mealEntryRepo: mockMealEntryRepo,
            locale: const Locale('en', 'US'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextFormField, '1'), findsOneWidget);
        final sliceChip = tester.widget<ChoiceChip>(
          find.widgetWithText(ChoiceChip, 'Slice'),
        );
        expect(sliceChip.selected, isTrue);
      },
    );

    testWidgets(
      'metric locale keeps the gram default even when a non-metric quick '
      'serving size is configured',
      (tester) async {
        when(
          () => mockUserFoodRepo.findOverrideForFoodRef(any(), any()),
        ).thenAnswer(
          (_) async => const UserFood(
            id: 'uf-1',
            name: 'Test Food',
            calories: 200,
            quickServingSizes: [ServingSize(label: 'Slice', grams: 30)],
          ),
        );

        await tester.pumpWidget(
          _wrap(
            PortionSlotForm(item: _buildItem()),
            userFoodRepo: mockUserFoodRepo,
            mealEntryRepo: mockMealEntryRepo,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextFormField, '100'), findsOneWidget);
      },
    );

    testWidgets(
      'initialSlot/initialQuantity/initialUnit pre-fill the form and '
      'bypass auto-detect/locale defaults',
      (tester) async {
        // Configure an imperial locale + a configured non-metric serving
        // size, both of which would otherwise change the default — the
        // edit-prefill overrides must still win.
        when(
          () => mockUserFoodRepo.findOverrideForFoodRef(any(), any()),
        ).thenAnswer(
          (_) async => const UserFood(
            id: 'uf-1',
            name: 'Test Food',
            calories: 200,
            quickServingSizes: [ServingSize(label: 'Slice', grams: 30)],
          ),
        );

        await tester.pumpWidget(
          _wrap(
            PortionSlotForm(
              item: _buildItem(),
              initialSlot: MealSlot.dinner,
              initialQuantity: 42,
              initialUnit: PortionUnit.ml,
            ),
            userFoodRepo: mockUserFoodRepo,
            mealEntryRepo: mockMealEntryRepo,
            locale: const Locale('en', 'US'),
          ),
        );
        await tester.pumpAndSettle();

        final segmentedButton = tester.widget<SegmentedButton<MealSlot>>(
          find.byType(SegmentedButton<MealSlot>),
        );
        expect(segmentedButton.selected, {MealSlot.dinner});
        expect(find.widgetWithText(TextFormField, '42'), findsOneWidget);
        final dropdown = tester.widget<DropdownButton<PortionUnit>>(
          find.byType(DropdownButton<PortionUnit>),
        );
        expect(dropdown.value, PortionUnit.ml);
      },
    );
  });
}

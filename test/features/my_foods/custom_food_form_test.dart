// Widget tests for CustomFoodFormScreen (replaces the Wave 0 skip stub).
//
// Wraps the screen in a ProviderScope with foodCatalogDaoProvider,
// foodCatalogRepositoryProvider, and userFoodRepositoryProvider overridden
// to mocktail mocks — no real Drift/off_ref database touches these tests.

import 'package:co2diet/core/di/app_providers.dart';
import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:co2diet/domain/repositories/i_food_catalog_repository.dart';
import 'package:co2diet/domain/repositories/i_user_food_repository.dart';
import 'package:co2diet/features/barcode_scan/widgets/confidence_chip.dart';
import 'package:co2diet/features/my_foods/screens/custom_food_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFoodCatalogDao extends Mock implements FoodCatalogDao {}

class _MockFoodCatalogRepository extends Mock
    implements IFoodCatalogRepository {}

class _MockUserFoodRepository extends Mock implements IUserFoodRepository {}

// Overrides list length must stay identical across pumpWidget() calls that
// reuse the same tester (riverpod forbids adding/removing overrides on an
// existing ProviderScope) — always provide all three overrides, defaulting
// to unstubbed mocks when a test doesn't care about them.
Widget _wrap(
  Widget child, {
  required _MockFoodCatalogDao mockDao,
  IFoodCatalogRepository? catalogRepo,
  IUserFoodRepository? userFoodRepo,
}) {
  return ProviderScope(
    overrides: [
      foodCatalogDaoProvider.overrideWithValue(mockDao),
      foodCatalogRepositoryProvider.overrideWithValue(
        catalogRepo ?? _MockFoodCatalogRepository(),
      ),
      userFoodRepositoryProvider.overrideWithValue(
        userFoodRepo ?? _MockUserFoodRepository(),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  late _MockFoodCatalogDao mockDao;

  setUp(() {
    mockDao = _MockFoodCatalogDao();
    when(
      () => mockDao.getAvailableCo2Categories(),
    ).thenAnswer((_) async => <String>[]);
  });

  group('CustomFoodFormScreen', () {
    testWidgets(
      'Save button disabled until name and calories are provided',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const CustomFoodFormScreen(), mockDao: mockDao),
        );
        await tester.pumpAndSettle();

        FilledButton saveButton() => tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Save'),
        );

        expect(saveButton().onPressed, isNull);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Name'),
          'Apple',
        );
        await tester.pump();
        expect(saveButton().onPressed, isNull);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Calories (required)'),
          '52',
        );
        await tester.pump();
        expect(saveButton().onPressed, isNotNull);
      },
    );

    testWidgets(
      'adding a quick serving size row appends a label+grams field pair',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const CustomFoodFormScreen(), mockDao: mockDao),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('serving-size-row-0')), findsNothing);

        final addButton = find.widgetWithText(TextButton, 'Add serving size');
        await tester.ensureVisible(addButton);
        await tester.pumpAndSettle();
        await tester.tap(addButton);
        await tester.pump();

        expect(
          find.byKey(const ValueKey('serving-size-row-0')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('serving-size-label-0')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('serving-size-grams-0')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'manual CO2 entry shows "user-provided" label and no '
      'ConfidenceChip',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const CustomFoodFormScreen(), mockDao: mockDao),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ConfidenceChip), findsOneWidget);
        expect(find.textContaining('user-provided'), findsNothing);

        final manualSegment = find.text('Enter manually');
        await tester.ensureVisible(manualSegment);
        await tester.pumpAndSettle();
        await tester.tap(manualSegment);
        await tester.pumpAndSettle();

        expect(find.byType(ConfidenceChip), findsNothing);
        expect(find.textContaining('user-provided'), findsOneWidget);
      },
    );

    testWidgets(
      'Revert to original button is shown only when editing an '
      'override',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const CustomFoodFormScreen(), mockDao: mockDao),
        );
        await tester.pumpAndSettle();

        expect(find.text('Revert to original'), findsNothing);

        final mockCatalogRepo = _MockFoodCatalogRepository();
        when(() => mockCatalogRepo.lookupByBarcode(any())).thenAnswer(
          (_) async => const FoodItem(
            productName: 'Original Product',
            barcode: '1234567890123',
            calories100g: 100,
          ),
        );

        // Distinct Key forces a fresh Element/State (a different widget
        // configuration with the same runtimeType/position would otherwise
        // be reconciled via didUpdateWidget rather than a fresh initState).
        await tester.pumpWidget(
          _wrap(
            const CustomFoodFormScreen(
              key: ValueKey('override-form'),
              overrideOf: '1234567890123',
              overrideOfSource: 'off_ref',
            ),
            mockDao: mockDao,
            catalogRepo: mockCatalogRepo,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Revert to original'), findsOneWidget);
      },
    );
  });
}

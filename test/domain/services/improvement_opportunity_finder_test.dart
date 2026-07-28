import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/services/improvement_opportunity_finder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFoodCatalogDao extends Mock implements FoodCatalogDao {}

MealEntry _entry({
  String id = 'e1',
  PortionUnit unit = PortionUnit.g,
  double quantity = 300,
  String productName = 'Beef Steak',
  double? co2e100g = 4,
}) => MealEntry(
  id: id,
  mealSlot: MealSlot.dinner,
  foodRef: 'ref-$id',
  foodRefSource: 'off_ref',
  quantity: quantity,
  unit: unit,
  productNameSnapshot: productName,
  loggedAt: DateTime.utc(2026, 7, 27, 19),
  logDate: '2026-07-27',
  co2e100gSnapshot: co2e100g,
);

void main() {
  late _MockFoodCatalogDao mockDao;
  late ImprovementOpportunityFinder finder;

  setUp(() {
    mockDao = _MockFoodCatalogDao();
    finder = ImprovementOpportunityFinder(mockDao);
  });

  group('ImprovementOpportunityFinder', () {
    test(
      'suggests a same-cluster protein alternative (e.g. red meat '
      '-> poultry/fish/legumes) with a quantified CO2 delta',
      () async {
        when(
          () => mockDao.getCo2ForCategory('en:poultry'),
        ).thenAnswer((_) async => 1.5);
        when(
          () => mockDao.getCo2ForCategory('en:fishes'),
        ).thenAnswer((_) async => 1.2);
        when(
          () => mockDao.getCo2ForCategory('en:legumes'),
        ).thenAnswer((_) async => 0.5);

        final result = await finder.findOpportunities([_entry()]);

        expect(result, hasLength(1));
        final suggestion = result.single;
        expect(suggestion.originalName, 'Beef Steak');
        // Largest delta is against legumes (4 vs 0.5 kg CO2e/100g).
        expect(suggestion.alternativeName, 'legumes');
        // (4 - 0.5) * 300 / 100 = 10.5 kg CO2e saved.
        expect(suggestion.deltaKg, closeTo(10.5, 0.001));
      },
    );

    test(
      'never suggests a cross-cluster swap (e.g. beef -> lettuce)',
      () async {
        when(
          () => mockDao.getCo2ForCategory(any()),
        ).thenAnswer((_) async => 0.1);

        final result = await finder.findOpportunities([_entry()]);

        expect(result, hasLength(1));
        // Alternative must be one of the hand-authored cluster members --
        // never an unrelated category like a vegetable.
        expect(
          ['chicken', 'fish', 'legumes'],
          contains(result.single.alternativeName),
        );
      },
    );

    test(
      'returns no suggestions when today has no high-CO2 entries '
      '(opt-in, never forced)',
      () async {
        when(
          () => mockDao.getCo2ForCategory(any()),
        ).thenAnswer((_) async => 0.1);

        // Below the significant-CO2 threshold (small quantity, low co2e).
        final result = await finder.findOpportunities([
          _entry(co2e100g: 0.5, quantity: 50),
        ]);

        expect(result, isEmpty);
      },
    );

    test(
      'returns no suggestions when the entry has no known category',
      () async {
        when(
          () => mockDao.getCo2ForCategory(any()),
        ).thenAnswer((_) async => 0.1);

        final result = await finder.findOpportunities([
          _entry(productName: 'Mystery Snack Bar'),
        ]);

        expect(result, isEmpty);
      },
    );

    test(
      'legumes/plant-protein entries (already lowest-CO2 tier) never '
      'produce a suggestion',
      () async {
        final result = await finder.findOpportunities([
          _entry(productName: 'Lentil Soup'),
        ]);

        expect(result, isEmpty);
        verifyNever(() => mockDao.getCo2ForCategory(any()));
      },
    );
  });
}

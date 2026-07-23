// Tests for UserFoodRepository (LOG-10/LOG-11).
//
// Covers:
// - saveCustomFood/saveOverride reject invalid drafts before hitting the
//   DAO (T-04-05-01, defense in depth).
// - saveCustomFood persists category-estimate vs. manual CO2 values with
//   the correct confidence-band nullability rule.
// - saveOverride requires overrideOfRef and never touches any other table.
// - revertOverride delegates to UserFoodDao.revert and nothing else.
// - UserFood.fromRow maps every column 1:1, including quickServingSizes.

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/user_food_dao.dart';
import 'package:co2diet/data/repositories/user_food_repository.dart';
import 'package:co2diet/domain/entities/serving_size.dart';
import 'package:co2diet/domain/entities/user_food.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserFoodDao extends Mock implements UserFoodDao {}

UserFoodRow _buildRow({
  String id = 'food-1',
  String name = 'Test Food',
  double calories = 100,
  String? co2Source,
  String? confidenceBand,
  String? co2MethodologyVersion,
  String? overrideOfRef,
  String? overrideOfSource,
  List<ServingSize> quickServingSizes = const [],
}) {
  return UserFoodRow(
    id: id,
    hlcMillis: BigInt.from(1000),
    hlcCounter: 0,
    hlcNodeId: 'local',
    dirty: true,
    name: name,
    referenceAmountG: 100,
    calories: calories,
    co2Source: co2Source,
    confidenceBand: confidenceBand,
    co2MethodologyVersion: co2MethodologyVersion,
    overrideOfRef: overrideOfRef,
    overrideOfSource: overrideOfSource,
    quickServingSizes: quickServingSizes,
  );
}

UserFood _buildFood({
  String id = '',
  String name = 'Test Food',
  double? calories = 100,
  String? co2Source,
  String? confidenceBand,
  String? co2MethodologyVersion,
  String? overrideOfRef,
  String? overrideOfSource,
  List<ServingSize> quickServingSizes = const [],
}) {
  return UserFood(
    id: id,
    name: name,
    calories: calories,
    co2Source: co2Source,
    confidenceBand: confidenceBand,
    co2MethodologyVersion: co2MethodologyVersion,
    overrideOfRef: overrideOfRef,
    overrideOfSource: overrideOfSource,
    quickServingSizes: quickServingSizes,
  );
}

void main() {
  late _MockUserFoodDao mockDao;
  late UserFoodRepository repository;

  setUpAll(() {
    registerFallbackValue(const UserFoodTableCompanion());
  });

  setUp(() {
    mockDao = _MockUserFoodDao();
    repository = UserFoodRepository(mockDao);
  });

  group('UserFoodRepository.saveCustomFood', () {
    test(
      'throws ArgumentError before calling the DAO when food.isValid is '
      'false',
      () async {
        final invalid = _buildFood(name: '', calories: null);

        expect(
          () => repository.saveCustomFood(invalid),
          throwsA(isA<ArgumentError>()),
        );
        verifyNever(() => mockDao.insert(any()));
        verifyNever(() => mockDao.updateFood(any(), any()));
      },
    );

    test(
      'persists a category-estimate CO2 value with medium confidence '
      'band',
      () async {
        final food = _buildFood(
          co2Source: 'category_estimate',
          confidenceBand: 'medium',
          co2MethodologyVersion: '1.0',
        );
        UserFoodTableCompanion? captured;
        when(() => mockDao.insert(any())).thenAnswer((invocation) async {
          captured = invocation.positionalArguments.first
              as UserFoodTableCompanion;
          return _buildRow(
            co2Source: 'category_estimate',
            confidenceBand: 'medium',
            co2MethodologyVersion: '1.0',
          );
        });

        final result = await repository.saveCustomFood(food);

        expect(captured!.co2Source.value, 'category_estimate');
        expect(captured!.confidenceBand.value, 'medium');
        expect(captured!.co2MethodologyVersion.value, '1.0');
        expect(result.co2Source, 'category_estimate');
        expect(result.confidenceBand, 'medium');
      },
    );

    test(
      'with a manual CO2 value stores no confidence band (self-entered, '
      'unbacked)',
      () async {
        final food = _buildFood(co2Source: 'manual');
        UserFoodTableCompanion? captured;
        when(() => mockDao.insert(any())).thenAnswer((invocation) async {
          captured = invocation.positionalArguments.first
              as UserFoodTableCompanion;
          return _buildRow(co2Source: 'manual');
        });

        final result = await repository.saveCustomFood(food);

        expect(captured!.co2Source.value, 'manual');
        expect(captured!.confidenceBand.value, isNull);
        expect(captured!.co2MethodologyVersion.value, isNull);
        expect(result.confidenceBand, isNull);
      },
    );

    test('updates an existing row when food.id already exists', () async {
      final existing = _buildRow();
      when(() => mockDao.getById('food-1'))
          .thenAnswer((_) async => existing);
      when(() => mockDao.updateFood('food-1', any()))
          .thenAnswer((_) async => existing);

      await repository.saveCustomFood(_buildFood(id: 'food-1'));

      verify(() => mockDao.updateFood('food-1', any())).called(1);
      verifyNever(() => mockDao.insert(any()));
    });
  });

  group('UserFoodRepository.saveOverride', () {
    test(
      'throws ArgumentError when overrideOfRef is null',
      () async {
        final override = _buildFood();

        expect(
          () => repository.saveOverride(override),
          throwsA(isA<ArgumentError>()),
        );
        verifyNever(() => mockDao.insert(any()));
      },
    );

    test(
      'never mutates the original catalog/cache row — only inserts the '
      'override row',
      () async {
        final override = _buildFood(
          overrideOfRef: 'barcode-123',
          overrideOfSource: 'off_ref',
        );
        UserFoodTableCompanion? captured;
        when(() => mockDao.insert(any())).thenAnswer((invocation) async {
          captured = invocation.positionalArguments.first
              as UserFoodTableCompanion;
          return _buildRow(
            overrideOfRef: 'barcode-123',
            overrideOfSource: 'off_ref',
          );
        });

        final result = await repository.saveOverride(override);

        expect(captured!.overrideOfRef.value, 'barcode-123');
        expect(captured!.overrideOfSource.value, 'off_ref');
        expect(result.overrideOfRef, 'barcode-123');
        verify(() => mockDao.insert(any())).called(1);
        verifyNever(() => mockDao.revert(any()));
        verifyNever(() => mockDao.findOverrideByFoodRef(any(), any()));
      },
    );
  });

  group('UserFoodRepository.revertOverride', () {
    test(
      'deletes the override row via UserFoodDao.revert and nothing else',
      () async {
        when(() => mockDao.revert('food-1')).thenAnswer((_) async {});

        await repository.revertOverride('food-1');

        verify(() => mockDao.revert('food-1')).called(1);
        verifyNever(() => mockDao.getById(any()));
        verifyNever(() => mockDao.insert(any()));
      },
    );
  });

  group('UserFoodRepository read paths', () {
    test('findOverrideForFoodRef maps the row to a UserFood', () async {
      when(() => mockDao.findOverrideByFoodRef('barcode-123', 'off_ref'))
          .thenAnswer(
        (_) async => _buildRow(overrideOfRef: 'barcode-123'),
      );

      final result = await repository.findOverrideForFoodRef(
        'barcode-123',
        'off_ref',
      );

      expect(result?.overrideOfRef, 'barcode-123');
    });

    test('findOverrideForFoodRef returns null when none exists', () async {
      when(() => mockDao.findOverrideByFoodRef(any(), any()))
          .thenAnswer((_) async => null);

      final result = await repository.findOverrideForFoodRef(
        'barcode-123',
        'off_ref',
      );

      expect(result, isNull);
    });

    test('getAllAlphabetical maps every row to a UserFood', () async {
      when(() => mockDao.getAllAlphabetical(filter: any(named: 'filter')))
          .thenAnswer((_) async => [_buildRow()]);

      final result = await repository.getAllAlphabetical();

      expect(result, hasLength(1));
    });

    test('getById returns null when the DAO returns null', () async {
      when(() => mockDao.getById('missing')).thenAnswer((_) async => null);

      final result = await repository.getById('missing');

      expect(result, isNull);
    });
  });

  group('UserFood.fromRow', () {
    test('maps every column 1:1, including quickServingSizes', () {
      const sizes = [ServingSize(label: 'Slice', grams: 30)];
      final row = _buildRow(quickServingSizes: sizes);

      final food = UserFood.fromRow(row);

      expect(food.id, row.id);
      expect(food.name, row.name);
      expect(food.calories, row.calories);
      expect(food.quickServingSizes, sizes);
    });
  });
}

// Tests for MealEntryRepository (LOG-05 through LOG-09).
//
// Covers:
// - logOrMerge builds the persisted row from the draft's own snapshot
//   fields, never re-reading/re-deriving them.
// - undoMergeDelta delegates to MealEntryDao.adjustQuantity only.
// - duplicateEntry delegates to MealEntryDao.duplicate, never insertOrMerge.
// - deleteEntry soft-deletes and returns the pre-delete row (Undo support);
//   restoreEntry clears the tombstone.
// - MealEntry.fromRow / Favorite.fromRow map every column 1:1.

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/meal_entry_dao.dart';
import 'package:co2diet/data/repositories/meal_entry_repository.dart';
import 'package:co2diet/domain/entities/favorite.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealEntryDao extends Mock implements MealEntryDao {}

MealEntryRow _buildRow({
  String id = 'entry-1',
  String foodRef = 'food-1',
  String foodRefSource = 'off_ref',
  MealSlot mealSlot = MealSlot.lunch,
  double quantity = 100,
  PortionUnit unit = PortionUnit.g,
  String logDate = '2026-07-23',
  DateTime? loggedAt,
}) {
  return MealEntryRow(
    id: id,
    hlcMillis: BigInt.from(1000),
    hlcCounter: 0,
    hlcNodeId: 'local',
    dirty: true,
    mealSlot: mealSlot,
    foodRef: foodRef,
    foodRefSource: foodRefSource,
    quantity: quantity,
    unit: unit,
    productNameSnapshot: 'Test Food',
    brandSnapshot: 'Test Brand',
    calories100gSnapshot: 52,
    protein100gSnapshot: 0.3,
    carbs100gSnapshot: 14,
    fat100gSnapshot: 0.2,
    co2e100gSnapshot: 0.4,
    confidenceBandSnapshot: 'medium',
    co2MethodologyVersionSnapshot: '1.0',
    loggedAt: loggedAt ?? DateTime(2026, 7, 23, 12),
    logDate: logDate,
  );
}

FavoriteRow _buildFavoriteRow({
  String id = 'fav-1',
  String foodRef = 'food-1',
  String foodRefSource = 'off_ref',
}) {
  return FavoriteRow(
    id: id,
    hlcMillis: BigInt.from(1000),
    hlcCounter: 0,
    hlcNodeId: 'local',
    dirty: true,
    foodRef: foodRef,
    foodRefSource: foodRefSource,
    productNameSnapshot: 'Test Food',
    brandSnapshot: 'Test Brand',
    calories100gSnapshot: 52,
    co2e100gSnapshot: 0.4,
    confidenceBandSnapshot: 'medium',
    favoritedAt: DateTime(2026, 7, 23, 12),
  );
}

MealEntry _buildDraft({
  String id = '',
  String foodRef = 'food-1',
  String foodRefSource = 'off_ref',
  MealSlot mealSlot = MealSlot.lunch,
  double quantity = 100,
  PortionUnit unit = PortionUnit.g,
  String logDate = '2026-07-23',
  DateTime? loggedAt,
}) {
  return MealEntry(
    id: id,
    mealSlot: mealSlot,
    foodRef: foodRef,
    foodRefSource: foodRefSource,
    quantity: quantity,
    unit: unit,
    productNameSnapshot: 'Test Food',
    brandSnapshot: 'Test Brand',
    calories100gSnapshot: 52,
    protein100gSnapshot: 0.3,
    carbs100gSnapshot: 14,
    fat100gSnapshot: 0.2,
    co2e100gSnapshot: 0.4,
    confidenceBandSnapshot: 'medium',
    co2MethodologyVersionSnapshot: '1.0',
    loggedAt: loggedAt ?? DateTime(2026, 7, 23, 12),
    logDate: logDate,
  );
}

void main() {
  late _MockMealEntryDao mockDao;
  late MealEntryRepository repository;

  setUpAll(() {
    // Custom (non-core) types passed to `any()` need a registered
    // fallback value so mocktail can satisfy its generic type bookkeeping.
    registerFallbackValue(_buildRow());
    registerFallbackValue(_buildFavoriteRow());
  });

  setUp(() {
    mockDao = _MockMealEntryDao();
    repository = MealEntryRepository(mockDao);
  });

  group('MealEntryRepository.logOrMerge', () {
    test(
      'captures a macro/CO2 snapshot at write time, not a live reference',
      () async {
        final draft = _buildDraft(id: 'entry-1');
        MealEntryRow? capturedRow;
        when(() => mockDao.insertOrMerge(draft: any(named: 'draft')))
            .thenAnswer((invocation) async {
          capturedRow =
              invocation.namedArguments[#draft] as MealEntryRow;
          return capturedRow!;
        });

        final result = await repository.logOrMerge(draft);

        expect(capturedRow, isNotNull);
        expect(capturedRow!.foodRef, draft.foodRef);
        expect(capturedRow!.foodRefSource, draft.foodRefSource);
        expect(capturedRow!.mealSlot, draft.mealSlot);
        expect(capturedRow!.quantity, draft.quantity);
        expect(capturedRow!.unit, draft.unit);
        expect(
          capturedRow!.productNameSnapshot,
          draft.productNameSnapshot,
        );
        expect(capturedRow!.brandSnapshot, draft.brandSnapshot);
        expect(
          capturedRow!.calories100gSnapshot,
          draft.calories100gSnapshot,
        );
        expect(
          capturedRow!.protein100gSnapshot,
          draft.protein100gSnapshot,
        );
        expect(capturedRow!.carbs100gSnapshot, draft.carbs100gSnapshot);
        expect(capturedRow!.fat100gSnapshot, draft.fat100gSnapshot);
        expect(capturedRow!.co2e100gSnapshot, draft.co2e100gSnapshot);
        expect(
          capturedRow!.confidenceBandSnapshot,
          draft.confidenceBandSnapshot,
        );
        expect(
          capturedRow!.co2MethodologyVersionSnapshot,
          draft.co2MethodologyVersionSnapshot,
        );
        expect(capturedRow!.loggedAt, draft.loggedAt);
        expect(capturedRow!.logDate, draft.logDate);
        expect(result.foodRef, draft.foodRef);
      },
    );

    test('generates a fresh id when draft.id is empty', () async {
      final draft = _buildDraft();
      MealEntryRow? capturedRow;
      when(() => mockDao.insertOrMerge(draft: any(named: 'draft')))
          .thenAnswer((invocation) async {
        capturedRow = invocation.namedArguments[#draft] as MealEntryRow;
        return capturedRow!;
      });

      await repository.logOrMerge(draft);

      expect(capturedRow!.id, isNotEmpty);
    });
  });

  group('MealEntryRepository.undoMergeDelta', () {
    test(
      'subtracts only the just-added delta, preserving pre-merge '
      'quantity, and calls nothing else',
      () async {
        when(() => mockDao.adjustQuantity('entry-1', 50))
            .thenAnswer((_) async {});

        await repository.undoMergeDelta('entry-1', 50);

        verify(() => mockDao.adjustQuantity('entry-1', 50)).called(1);
        verifyNever(() => mockDao.getById(any()));
        verifyNever(() => mockDao.insertOrMerge(draft: any(named: 'draft')));
      },
    );
  });

  group('MealEntryRepository.duplicateEntry', () {
    test(
      'always creates a new row via MealEntryDao.duplicate, bypassing '
      'insertOrMerge entirely',
      () async {
        final duplicated = _buildRow(id: 'entry-2');
        when(
          () => mockDao.duplicate('entry-1', newId: any(named: 'newId')),
        ).thenAnswer((_) async => duplicated);

        final result = await repository.duplicateEntry('entry-1');

        expect(result.id, 'entry-2');
        verify(
          () => mockDao.duplicate('entry-1', newId: any(named: 'newId')),
        ).called(1);
        verifyNever(() => mockDao.insertOrMerge(draft: any(named: 'draft')));
      },
    );
  });

  group('MealEntryRepository soft-delete / restore', () {
    test(
      'deleteEntry soft-deletes and returns the pre-delete row for Undo',
      () async {
        final existing = _buildRow();
        when(() => mockDao.getById('entry-1'))
            .thenAnswer((_) async => existing);
        when(() => mockDao.softDelete('entry-1')).thenAnswer((_) async {});

        final result = await repository.deleteEntry('entry-1');

        expect(result, MealEntry.fromRow(existing));
        verify(() => mockDao.softDelete('entry-1')).called(1);
      },
    );

    test('deleteEntry throws when the entry does not exist', () async {
      when(() => mockDao.getById('missing')).thenAnswer((_) async => null);

      expect(
        () => repository.deleteEntry('missing'),
        throwsA(isA<StateError>()),
      );
      verifyNever(() => mockDao.softDelete(any()));
    });

    test('restoreEntry clears the tombstone via MealEntryDao.restore',
        () async {
      when(() => mockDao.restore('entry-1')).thenAnswer((_) async {});

      await repository.restoreEntry(MealEntry.fromRow(_buildRow()));

      verify(() => mockDao.restore('entry-1')).called(1);
    });
  });

  group('MealEntry.fromRow / Favorite.fromRow', () {
    test('MealEntry.fromRow maps every column 1:1, no lossy conversion', () {
      final row = _buildRow();
      final entry = MealEntry.fromRow(row);

      expect(entry.id, row.id);
      expect(entry.mealSlot, row.mealSlot);
      expect(entry.foodRef, row.foodRef);
      expect(entry.foodRefSource, row.foodRefSource);
      expect(entry.quantity, row.quantity);
      expect(entry.unit, row.unit);
      expect(entry.productNameSnapshot, row.productNameSnapshot);
      expect(entry.brandSnapshot, row.brandSnapshot);
      expect(entry.calories100gSnapshot, row.calories100gSnapshot);
      expect(entry.protein100gSnapshot, row.protein100gSnapshot);
      expect(entry.carbs100gSnapshot, row.carbs100gSnapshot);
      expect(entry.fat100gSnapshot, row.fat100gSnapshot);
      expect(entry.co2e100gSnapshot, row.co2e100gSnapshot);
      expect(entry.confidenceBandSnapshot, row.confidenceBandSnapshot);
      expect(
        entry.co2MethodologyVersionSnapshot,
        row.co2MethodologyVersionSnapshot,
      );
      expect(entry.loggedAt, row.loggedAt);
      expect(entry.logDate, row.logDate);
    });

    test('Favorite.fromRow maps every column 1:1, no lossy conversion', () {
      final row = _buildFavoriteRow();
      final favorite = Favorite.fromRow(row);

      expect(favorite.id, row.id);
      expect(favorite.foodRef, row.foodRef);
      expect(favorite.foodRefSource, row.foodRefSource);
      expect(favorite.productNameSnapshot, row.productNameSnapshot);
      expect(favorite.brandSnapshot, row.brandSnapshot);
      expect(favorite.calories100gSnapshot, row.calories100gSnapshot);
      expect(favorite.co2e100gSnapshot, row.co2e100gSnapshot);
      expect(favorite.confidenceBandSnapshot, row.confidenceBandSnapshot);
      expect(favorite.lastQuantity, row.lastQuantity);
      expect(favorite.lastUnit, row.lastUnit);
      expect(favorite.favoritedAt, row.favoritedAt);
    });
  });

  group('MealEntryRepository favorites', () {
    test('toggleFavorite delegates to MealEntryDao.toggleFavorite', () async {
      when(() => mockDao.toggleFavorite(any())).thenAnswer((_) async {});

      final draft = Favorite.fromRow(_buildFavoriteRow());
      final result = await repository.toggleFavorite(draft);

      expect(result.foodRef, draft.foodRef);
      verify(() => mockDao.toggleFavorite(any())).called(1);
    });

    test('isFavorite delegates to MealEntryDao.isFavorite', () async {
      when(() => mockDao.isFavorite('food-1', 'off_ref'))
          .thenAnswer((_) async => true);

      final result = await repository.isFavorite('food-1', 'off_ref');

      expect(result, isTrue);
    });

    test('getFavorites maps every row to a Favorite', () async {
      when(() => mockDao.getFavorites())
          .thenAnswer((_) async => [_buildFavoriteRow()]);

      final result = await repository.getFavorites();

      expect(result, hasLength(1));
      expect(result.first.id, 'fav-1');
    });

    test('touchFavoriteUsage delegates with the unit name', () async {
      when(
        () => mockDao.touchFavoriteUsage(
          'food-1',
          'off_ref',
          quantity: 200,
          unit: 'g',
        ),
      ).thenAnswer((_) async {});

      await repository.touchFavoriteUsage(
        'food-1',
        'off_ref',
        quantity: 200,
        unit: PortionUnit.g,
      );

      verify(
        () => mockDao.touchFavoriteUsage(
          'food-1',
          'off_ref',
          quantity: 200,
          unit: 'g',
        ),
      ).called(1);
    });
  });

  group('MealEntryRepository read paths', () {
    test('getEntriesForToday maps every row to a MealEntry', () async {
      when(() => mockDao.getEntriesForToday(any()))
          .thenAnswer((_) async => [_buildRow()]);

      final result = await repository.getEntriesForToday();

      expect(result, hasLength(1));
      expect(result.first.id, 'entry-1');
    });

    test('getRecent maps every row to a MealEntry', () async {
      when(() => mockDao.getRecent(limit: any(named: 'limit')))
          .thenAnswer((_) async => [_buildRow()]);

      final result = await repository.getRecent();

      expect(result, hasLength(1));
    });

    test('editEntry updates slot/quantity/unit and re-fetches the row',
        () async {
      when(
        () => mockDao.updateSlotQuantityUnit(
          id: 'entry-1',
          mealSlot: 'dinner',
          quantity: 150,
          unit: 'g',
        ),
      ).thenAnswer((_) async {});
      when(() => mockDao.getById('entry-1')).thenAnswer(
        (_) async => _buildRow(
          mealSlot: MealSlot.dinner,
          quantity: 150,
        ),
      );

      final updated = _buildDraft(
        id: 'entry-1',
        mealSlot: MealSlot.dinner,
        quantity: 150,
      );
      final result = await repository.editEntry(updated);

      expect(result.mealSlot, MealSlot.dinner);
      expect(result.quantity, 150);
    });
  });
}

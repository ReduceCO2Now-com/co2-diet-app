// TDD tests for MealEntryDao (MealEntryTable + FavoriteTable).
// Covers LOG-05/07/08/09: merge-on-log-date, unit-mismatch non-merge,
// Recent dedup/cap/reorder, soft-delete exclusion, favorite toggle.

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/meal_entry_dao.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MealEntryDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = MealEntryDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  MealEntryRow buildDraft({
    required String id,
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
      hlcNodeId: 'test-node',
      dirty: true,
      mealSlot: mealSlot,
      foodRef: foodRef,
      foodRefSource: foodRefSource,
      quantity: quantity,
      unit: unit,
      productNameSnapshot: 'Test Food',
      co2e100gSnapshot: 1.5,
      confidenceBandSnapshot: 'medium',
      co2MethodologyVersionSnapshot: 'v1',
      loggedAt: loggedAt ?? DateTime(2026, 7, 23, 12),
      logDate: logDate,
    );
  }

  FavoriteRow buildFavoriteDraft({
    required String id,
    String foodRef = 'food-1',
    String foodRefSource = 'off_ref',
  }) {
    return FavoriteRow(
      id: id,
      hlcMillis: BigInt.from(1000),
      hlcCounter: 0,
      hlcNodeId: 'test-node',
      dirty: true,
      foodRef: foodRef,
      foodRefSource: foodRefSource,
      productNameSnapshot: 'Test Food',
      favoritedAt: DateTime(2026, 7, 23, 12),
    );
  }

  group('MealEntryDao.insertOrMerge', () {
    test(
      'insert creates a new row with correct logDate computed from '
      'loggedAt',
      () async {
        final draft = buildDraft(id: 'entry-1');
        final result = await dao.insertOrMerge(draft: draft);

        expect(result.id, equals('entry-1'));
        expect(result.logDate, equals('2026-07-23'));
        expect(result.quantity, equals(100));
        expect(result.co2MethodologyVersionSnapshot, equals('v1'));
      },
    );

    test(
      'logging same foodRef+slot+day+unit merges into existing row '
      '(adds quantity)',
      () async {
        await dao.insertOrMerge(draft: buildDraft(id: 'entry-1'));
        final merged = await dao.insertOrMerge(
          draft: buildDraft(id: 'entry-2', quantity: 50),
        );

        expect(merged.id, equals('entry-1'));
        expect(merged.quantity, equals(150));

        final all = await dao.getEntriesForToday('2026-07-23');
        expect(all, hasLength(1));
      },
    );

    test(
      'logging same foodRef+slot+day with different unit creates a '
      'separate row',
      () async {
        await dao.insertOrMerge(
          draft: buildDraft(id: 'entry-1'),
        );
        await dao.insertOrMerge(
          draft: buildDraft(id: 'entry-2', unit: PortionUnit.cup),
        );

        final all = await dao.getEntriesForToday('2026-07-23');
        expect(all, hasLength(2));
      },
    );
  });

  group('MealEntryDao.getRecent', () {
    test(
      'returns individually logged items deduped by foodRef, '
      'most-recent-first, capped at 15',
      () async {
        for (var i = 0; i < 20; i++) {
          await dao.insertOrMerge(
            draft: buildDraft(
              id: 'entry-$i',
              foodRef: 'food-$i',
              loggedAt: DateTime(2026, 7, 23, 12, i),
            ),
          );
        }

        final recent = await dao.getRecent();
        expect(recent, hasLength(15));
        expect(recent.first.foodRef, equals('food-19'));
      },
    );

    test(
      're-logging an item already in Recent moves it to the top instead '
      'of duplicating',
      () async {
        await dao.insertOrMerge(
          draft: buildDraft(
            id: 'entry-1',
            foodRef: 'food-A',
            loggedAt: DateTime(2026, 7, 23, 8),
          ),
        );
        await dao.insertOrMerge(
          draft: buildDraft(
            id: 'entry-2',
            foodRef: 'food-B',
            loggedAt: DateTime(2026, 7, 23, 9),
          ),
        );
        // Re-log food-A in a different slot/unit so it doesn't merge —
        // still the same (foodRef, foodRefSource) dedup key for Recent.
        await dao.insertOrMerge(
          draft: buildDraft(
            id: 'entry-3',
            foodRef: 'food-A',
            mealSlot: MealSlot.dinner,
            loggedAt: DateTime(2026, 7, 23, 20),
          ),
        );

        final recent = await dao.getRecent();
        expect(recent, hasLength(2));
        expect(recent.first.foodRef, equals('food-A'));
      },
    );
  });

  group('MealEntryDao soft delete', () {
    test(
      'softDelete sets deletedAt tombstone; row excluded from '
      'getEntriesForToday',
      () async {
        await dao.insertOrMerge(draft: buildDraft(id: 'entry-1'));
        await dao.softDelete('entry-1');

        final all = await dao.getEntriesForToday('2026-07-23');
        expect(all, isEmpty);

        final row = await dao.getById('entry-1');
        expect(row, isNotNull);
        expect(row!.deletedAt, isNotNull);

        await dao.restore('entry-1');
        final restored = await dao.getEntriesForToday('2026-07-23');
        expect(restored, hasLength(1));
      },
    );
  });

  group('MealEntryDao favorites', () {
    test(
      'toggleFavorite inserts a favorite row; toggling again removes it',
      () async {
        final draft = buildFavoriteDraft(id: 'fav-1');
        await dao.toggleFavorite(draft);
        expect(await dao.isFavorite('food-1', 'off_ref'), isTrue);

        await dao.toggleFavorite(draft);
        expect(await dao.isFavorite('food-1', 'off_ref'), isFalse);
      },
    );

    test(
      'getFavorites returns favorited foods with lastQuantity/lastUnit '
      'for one-tap reuse',
      () async {
        await dao.toggleFavorite(buildFavoriteDraft(id: 'fav-1'));
        await dao.touchFavoriteUsage(
          'food-1',
          'off_ref',
          quantity: 200,
          unit: PortionUnit.g.name,
        );

        final favorites = await dao.getFavorites();
        expect(favorites, hasLength(1));
        expect(favorites.first.lastQuantity, equals(200));
        expect(favorites.first.lastUnit, equals(PortionUnit.g));
      },
    );
  });
}

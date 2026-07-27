import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('WeightDao', () {
    WeightEntryTableCompanion entryCompanion({
      required String id,
      required double value,
      required DateTime loggedAt,
    }) =>
        WeightEntryTableCompanion.insert(
          id: id,
          hlcMillis: BigInt.from(1000000),
          hlcCounter: 0,
          hlcNodeId: 'local',
          value: value,
          unit: WeightUnit.kg,
          loggedAt: loggedAt,
        );

    test(
      'logWeight inserts a new WeightEntryRow; getEntriesInRange '
      'filters by [from, to] inclusive',
      () async {
        final day1 = DateTime.utc(2026);
        final day2 = DateTime.utc(2026, 1, 10);
        final day3 = DateTime.utc(2026, 1, 20);

        final inserted = await db.weightDao.logWeight(
          entryCompanion(id: 'w1', value: 80, loggedAt: day1),
        );
        expect(inserted.id, equals('w1'));

        await db.weightDao.logWeight(
          entryCompanion(id: 'w2', value: 79.5, loggedAt: day2),
        );
        await db.weightDao.logWeight(
          entryCompanion(id: 'w3', value: 79, loggedAt: day3),
        );

        final all = await db.weightDao.getEntriesInRange();
        expect(all, hasLength(3));
        expect(all.map((r) => r.id), equals(['w1', 'w2', 'w3']));

        final midRange = await db.weightDao.getEntriesInRange(
          from: DateTime.utc(2026, 1, 5),
          to: DateTime.utc(2026, 1, 15),
        );
        expect(midRange, hasLength(1));
        expect(midRange.single.id, equals('w2'));

        final fromOnly = await db.weightDao.getEntriesInRange(
          from: DateTime.utc(2026, 1, 10),
        );
        expect(fromOnly.map((r) => r.id), equals(['w2', 'w3']));

        await db.weightDao.deleteEntry('w1');
        final afterDelete = await db.weightDao.getEntriesInRange();
        expect(afterDelete.map((r) => r.id), equals(['w2', 'w3']));
      },
    );

    test(
      'getSettings/saveSettings round-trip the target weight, '
      'target date, and reminder fields',
      () async {
        final before = await db.weightDao.getSettings();
        expect(before, isNull);

        final targetDate = DateTime.utc(2026, 12, 31);
        final companion = WeightSettingsTableCompanion.insert(
          id: 'settings-1',
          hlcMillis: BigInt.from(1000000),
          hlcCounter: 0,
          hlcNodeId: 'local',
          targetWeightKg: const Value(75),
          targetDate: Value(targetDate),
          reminderFrequency: const Value('weekly'),
          reminderEnabled: const Value(true),
        );
        await db.weightDao.saveSettings(companion);

        final after = await db.weightDao.getSettings();
        expect(after, isNotNull);
        expect(after!.targetWeightKg, equals(75));
        expect(after.targetDate!.isAtSameMomentAs(targetDate), isTrue);
        expect(after.reminderFrequency, equals('weekly'));
        expect(after.reminderEnabled, isTrue);

        // Second save with same id updates rather than duplicates.
        final updated = WeightSettingsTableCompanion.insert(
          id: 'settings-1',
          hlcMillis: BigInt.from(2000000),
          hlcCounter: 1,
          hlcNodeId: 'local',
          targetWeightKg: const Value(70),
        );
        await db.weightDao.saveSettings(updated);

        final rows = await db
            .customSelect('SELECT * FROM weight_settings_table')
            .get();
        expect(rows, hasLength(1));
      },
    );
  });
}

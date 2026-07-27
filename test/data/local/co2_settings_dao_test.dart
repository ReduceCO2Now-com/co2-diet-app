import 'package:co2diet/data/local/app_database.dart';
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

  group('Co2SettingsDao', () {
    Co2SettingsTableCompanion baseCompanion({
      String id = 'test-uuid-01',
    }) =>
        Co2SettingsTableCompanion.insert(
          id: id,
          hlcMillis: BigInt.from(1000000),
          hlcCounter: 0,
          hlcNodeId: 'local',
        );

    test(
      'getSettings returns null before any save; upsertSettings '
      'enforces the single-row convention',
      () async {
        final before = await db.co2SettingsDao.getSettings();
        expect(before, isNull);

        await db.co2SettingsDao.upsertSettings(baseCompanion());
        final afterFirst = await db.co2SettingsDao.getSettings();
        expect(afterFirst, isNotNull);
        expect(afterFirst!.id, equals('test-uuid-01'));

        final updated = Co2SettingsTableCompanion.insert(
          id: 'test-uuid-01',
          hlcMillis: BigInt.from(2000000),
          hlcCounter: 1,
          hlcNodeId: 'local',
          locationCountry: const Value('DE'),
        );
        await db.co2SettingsDao.upsertSettings(updated);

        final rows = await db
            .customSelect('SELECT * FROM co2_settings_table')
            .get();
        expect(rows, hasLength(1));

        final afterSecond = await db.co2SettingsDao.getSettings();
        expect(afterSecond!.locationCountry, equals('DE'));
      },
    );
  });
}

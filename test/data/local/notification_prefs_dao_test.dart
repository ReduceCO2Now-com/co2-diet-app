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

  group('NotificationPrefsDao', () {
    NotificationPrefsTableCompanion baseCompanion({
      String id = 'test-uuid-01',
    }) =>
        NotificationPrefsTableCompanion.insert(
          id: id,
          hlcMillis: BigInt.from(1000000),
          hlcCounter: 0,
          hlcNodeId: 'local',
        );

    test(
      'getPrefs returns all-disabled defaults before any save; '
      'savePrefs upserts the single row',
      () async {
        final before = await db.notificationPrefsDao.getPrefs();
        expect(before, isNull);

        await db.notificationPrefsDao.savePrefs(baseCompanion());
        final afterFirst = await db.notificationPrefsDao.getPrefs();
        expect(afterFirst, isNotNull);
        expect(afterFirst!.breakfastEnabled, isFalse);
        expect(afterFirst.lunchEnabled, isFalse);
        expect(afterFirst.dinnerEnabled, isFalse);
        expect(afterFirst.snackEnabled, isFalse);

        final updated = NotificationPrefsTableCompanion.insert(
          id: 'test-uuid-01',
          hlcMillis: BigInt.from(2000000),
          hlcCounter: 1,
          hlcNodeId: 'local',
          breakfastEnabled: const Value(true),
          breakfastTime: const Value('08:00'),
        );
        await db.notificationPrefsDao.savePrefs(updated);

        final rows = await db
            .customSelect('SELECT * FROM notification_prefs_table')
            .get();
        expect(rows, hasLength(1));

        final afterSecond = await db.notificationPrefsDao.getPrefs();
        expect(afterSecond!.breakfastEnabled, isTrue);
        expect(afterSecond.breakfastTime, equals('08:00'));
      },
    );
  });
}

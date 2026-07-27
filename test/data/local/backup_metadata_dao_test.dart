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

  group('BackupMetadataDao', () {
    test(
      'getMetadata/saveMetadata round-trip autoBackupFrequency and '
      'lastBackupAt',
      () async {
        final before = await db.backupMetadataDao.getMetadata();
        expect(before, isNull);

        final lastBackupAt = DateTime.utc(2026, 6, 1, 12);
        final companion = BackupMetadataTableCompanion.insert(
          id: 'meta-1',
          hlcMillis: BigInt.from(1000000),
          hlcCounter: 0,
          hlcNodeId: 'local',
          autoBackupFrequency: const Value('daily'),
          lastBackupAt: Value(lastBackupAt),
          lastBackupPath: const Value('/docs/backup.json'),
        );
        await db.backupMetadataDao.saveMetadata(companion);

        final after = await db.backupMetadataDao.getMetadata();
        expect(after, isNotNull);
        expect(after!.autoBackupFrequency, equals('daily'));
        expect(after.lastBackupAt!.isAtSameMomentAs(lastBackupAt), isTrue);
        expect(after.lastBackupPath, equals('/docs/backup.json'));

        final updated = BackupMetadataTableCompanion.insert(
          id: 'meta-1',
          hlcMillis: BigInt.from(2000000),
          hlcCounter: 1,
          hlcNodeId: 'local',
          autoBackupFrequency: const Value('weekly'),
        );
        await db.backupMetadataDao.saveMetadata(updated);

        final rows = await db
            .customSelect('SELECT * FROM backup_metadata_table')
            .get();
        expect(rows, hasLength(1));
      },
    );
  });
}

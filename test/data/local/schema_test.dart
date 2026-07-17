import 'package:co2diet/data/local/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull;
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

  group('Schema', () {
    test('Test 1 (CO2-04): co2_methodology_version defaults to 1.0', () async {
      // Insert a minimal profile — no co2MethodologyVersion specified,
      // so the column default ('1.0') must be applied by SQLite.
      await db.userProfileDao.upsertProfile(
        UserProfileTableCompanion.insert(
          id: 'schema-test-uuid',
          hlcMillis: BigInt.from(1000000),
          hlcCounter: 0,
          hlcNodeId: 'local',
          // co2MethodologyVersion intentionally omitted — default applies
        ),
      );
      final row = await db.userProfileDao.getProfile();
      expect(row, isNotNull);
      expect(row!.co2MethodologyVersion, equals('1.0'));
    });

    test(
        'Test 2: SyncSafeTable mixin injects all 6 expected columns '
        'into user_profile_table', () async {
      final result = await db
          .customSelect(
            'SELECT sql FROM sqlite_master '
            "WHERE type='table' AND name='user_profile_table'",
          )
          .getSingle();
      final sql = result.read<String>('sql');

      // All 6 SyncSafeTable columns must be present in the CREATE TABLE SQL.
      expect(sql, contains('id'));
      expect(sql, contains('hlc_millis'));
      expect(sql, contains('hlc_counter'));
      expect(sql, contains('hlc_node_id'));
      expect(sql, contains('dirty'));
      expect(sql, contains('deleted_at'));
    });

    test(
        'Test 3: consent_records_table does NOT have hlc_millis '
        '(SyncSafeTable mixin absent)', () async {
      final result = await db
          .customSelect(
            'SELECT sql FROM sqlite_master '
            "WHERE type='table' AND name='consent_records_table'",
          )
          .getSingle();
      final sql = result.read<String>('sql');
      expect(sql, isNot(contains('hlc_millis')));
    });
  });
}

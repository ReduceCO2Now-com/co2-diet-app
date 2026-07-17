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

  group('UserProfileDao', () {
    // Minimal required companion for insert (only id, hlcMillis, hlcCounter,
    // hlcNodeId are required; all other fields have defaults or are nullable).
    UserProfileTableCompanion baseCompanion({
      String id = 'test-uuid-01',
    }) =>
        UserProfileTableCompanion.insert(
          id: id,
          hlcMillis: BigInt.from(1000000),
          hlcCounter: 0,
          hlcNodeId: 'local',
        );

    test('Test 1: upsert + retrieve round-trip returns correct id', () async {
      await db.userProfileDao.upsertProfile(baseCompanion());
      final row = await db.userProfileDao.getProfile();
      expect(row, isNotNull);
      expect(row!.id, equals('test-uuid-01'));
    });

    test('Test 2: upsert with kcalIsOverridden=true persists flag', () async {
      final companion = UserProfileTableCompanion.insert(
        id: 'test-uuid-01',
        hlcMillis: BigInt.from(1000000),
        hlcCounter: 0,
        hlcNodeId: 'local',
        kcalIsOverridden: const Value(true),
      );
      await db.userProfileDao.upsertProfile(companion);
      final row = await db.userProfileDao.getProfile();
      expect(row, isNotNull);
      expect(row!.kcalIsOverridden, isTrue);
    });

    test('Test 3: upsert with units=imperial can be retrieved', () async {
      final companion = UserProfileTableCompanion.insert(
        id: 'test-uuid-01',
        hlcMillis: BigInt.from(1000000),
        hlcCounter: 0,
        hlcNodeId: 'local',
        units: const Value('imperial'),
      );
      await db.userProfileDao.upsertProfile(companion);
      final row = await db.userProfileDao.getProfile();
      expect(row, isNotNull);
      expect(row!.units, equals('imperial'));
    });

    test('Test 4: two upserts with same id yields only 1 row', () async {
      await db.userProfileDao.upsertProfile(baseCompanion());
      // Second upsert with updated hlcMillis (simulates a real update)
      final updated = UserProfileTableCompanion.insert(
        id: 'test-uuid-01',
        hlcMillis: BigInt.from(2000000),
        hlcCounter: 1,
        hlcNodeId: 'local',
        age: const Value(30),
      );
      await db.userProfileDao.upsertProfile(updated);

      // Single-row invariant: COUNT(*) must be 1
      final countQuery = await db
          .customSelect(
            'SELECT COUNT(*) AS cnt FROM user_profile_table',
          )
          .getSingle();
      final count = countQuery.read<int>('cnt');
      expect(count, equals(1));
    });
  });
}

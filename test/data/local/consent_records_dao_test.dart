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

  group('ConsentRecordsDao', () {
    test('Test 1: insert + retrieve round-trip returns correct id', () async {
      await db.consentRecordsDao.insertConsent(
        ConsentRecordsTableCompanion.insert(
          id: 'consent-uuid-01',
          appVersion: '0.1.0+1',
          policyVersion: '2026-07-16',
          consentsGiven:
              '["terms","privacy","not_medical_advice","user_responsibility"]',
        ),
      );
      final records = await db.consentRecordsDao.getAllConsents();
      expect(records, hasLength(1));
      expect(records.first.id, equals('consent-uuid-01'));
    });

    test('Test 2: two inserts with different ids yields 2 rows (append-only)',
        () async {
      await db.consentRecordsDao.insertConsent(
        ConsentRecordsTableCompanion.insert(
          id: 'consent-uuid-01',
          appVersion: '0.1.0+1',
          policyVersion: '2026-07-16',
          consentsGiven:
              '["terms","privacy","not_medical_advice","user_responsibility"]',
        ),
      );
      await db.consentRecordsDao.insertConsent(
        ConsentRecordsTableCompanion.insert(
          id: 'consent-uuid-02',
          appVersion: '0.1.0+1',
          policyVersion: '2026-07-16',
          consentsGiven: '["terms","privacy","not_medical_advice",'
              '"user_responsibility","age_16_plus"]',
        ),
      );
      final records = await db.consentRecordsDao.getAllConsents();
      expect(records, hasLength(2));
    });

    test(
        'Test 3: consent_records_table does NOT have a dirty column '
        '(SyncSafeTable mixin is absent)', () async {
      final result = await db
          .customSelect(
            'SELECT sql FROM sqlite_master '
            "WHERE type='table' AND name='consent_records_table'",
          )
          .getSingle();
      final sql = result.read<String>('sql');
      // SyncSafeTable injects a 'dirty' column — its absence proves the mixin
      // was intentionally not applied to this append-only audit table.
      expect(sql, isNot(contains('dirty')));
    });
  });
}

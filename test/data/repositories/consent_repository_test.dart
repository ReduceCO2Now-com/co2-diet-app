// Tests for DriftConsentRepository (LEGAL-03, LEGAL-04, LEG-02).
//
// Covers:
// - recordConsent writes the correct id/appVersion/policyVersion/
//   consentsGiven JSON array through ConsentRecordsDao.
// - recordConsent never touches any other DAO (single-table isolation).
// - watchConsents maps Drift ConsentRecord rows to domain ConsentEvent
//   entities, preserving order.
// - watchConsents emits an empty list when no consent has ever been
//   recorded.

import 'dart:convert';

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/consent_records_dao.dart';
import 'package:co2diet/data/repositories/consent_repository.dart';
import 'package:co2diet/domain/entities/consent_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConsentRecordsDao extends Mock implements ConsentRecordsDao {}

ConsentRecord _buildRow({
  String id = 'consent-1',
  DateTime? createdAt,
  String appVersion = '0.1.0+1',
  String policyVersion = '2026-07-16',
  List<String> consentsGiven = const [
    'terms',
    'privacy',
    'not_medical_advice',
    'user_responsibility',
  ],
}) {
  return ConsentRecord(
    id: id,
    createdAt: createdAt ?? DateTime.utc(2026, 7, 16, 12),
    appVersion: appVersion,
    policyVersion: policyVersion,
    consentsGiven: jsonEncode(consentsGiven),
  );
}

void main() {
  late _MockConsentRecordsDao mockDao;
  late DriftConsentRepository repository;

  setUpAll(() {
    registerFallbackValue(
      ConsentRecordsTableCompanion.insert(
        id: 'fallback',
        appVersion: '0.0.0+0',
        policyVersion: 'fallback',
        consentsGiven: '[]',
      ),
    );
  });

  setUp(() {
    mockDao = _MockConsentRecordsDao();
    repository = DriftConsentRepository(mockDao);
  });

  group('DriftConsentRepository.recordConsent', () {
    test(
      'writes id/appVersion/policyVersion/consentsGiven JSON array '
      'through ConsentRecordsDao',
      () async {
        ConsentRecordsTableCompanion? captured;
        when(() => mockDao.insertConsent(any())).thenAnswer((invocation) {
          captured =
              invocation.positionalArguments[0]
                  as ConsentRecordsTableCompanion;
          return Future<void>.value();
        });

        await repository.recordConsent(
          policyVersion: '2026-07-16',
          appVersion: '0.1.0+1',
          consentsGiven: const [
            'terms',
            'privacy',
            'not_medical_advice',
            'user_responsibility',
            'age_16_plus',
          ],
        );

        expect(captured, isNotNull);
        expect(captured!.id.value, isNotEmpty);
        expect(captured!.appVersion.value, '0.1.0+1');
        expect(captured!.policyVersion.value, '2026-07-16');
        expect(
          jsonDecode(captured!.consentsGiven.value) as List<dynamic>,
          [
            'terms',
            'privacy',
            'not_medical_advice',
            'user_responsibility',
            'age_16_plus',
          ],
        );
        verify(() => mockDao.insertConsent(any())).called(1);
      },
    );

    test('never touches any other DAO (single-table isolation)', () async {
      when(() => mockDao.insertConsent(any())).thenAnswer(
        (_) => Future<void>.value(),
      );

      await repository.recordConsent(
        policyVersion: '2026-07-16',
        appVersion: '0.1.0+1',
        consentsGiven: const ['terms'],
      );

      verify(() => mockDao.insertConsent(any())).called(1);
      verifyNoMoreInteractions(mockDao);
    });
  });

  group('DriftConsentRepository.watchConsents', () {
    test(
      'maps Drift ConsentRecord rows to domain ConsentEvent entities, '
      'preserving order',
      () {
        final rows = [
          _buildRow(
            consentsGiven: const [
              'terms',
              'privacy',
              'not_medical_advice',
              'user_responsibility',
              'age_16_plus',
            ],
          ),
          _buildRow(id: 'consent-2'),
        ];
        when(() => mockDao.watchConsents()).thenAnswer(
          (_) => Stream.value(rows),
        );

        expect(
          repository.watchConsents(),
          emits(
            isA<List<ConsentEvent>>()
                .having((l) => l.length, 'length', 2)
                .having((l) => l[0].id, 'first id', 'consent-1')
                .having(
                  (l) => l[0].consentsGiven,
                  'first consentsGiven',
                  [
                    'terms',
                    'privacy',
                    'not_medical_advice',
                    'user_responsibility',
                    'age_16_plus',
                  ],
                )
                .having((l) => l[1].id, 'second id', 'consent-2'),
          ),
        );
      },
    );

    test('emits an empty list when no consent has ever been recorded', () {
      when(() => mockDao.watchConsents()).thenAnswer(
        (_) => Stream.value(<ConsentRecord>[]),
      );

      expect(repository.watchConsents(), emits(<ConsentEvent>[]));
    });
  });
}

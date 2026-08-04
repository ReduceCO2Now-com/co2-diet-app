import 'package:co2diet/core/di/legal_providers.dart';
import 'package:co2diet/domain/entities/consent_event.dart';
import 'package:co2diet/domain/repositories/i_consent_repository.dart';
import 'package:co2diet/features/legal/screens/consent_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConsentRepository implements IConsentRepository {
  _FakeConsentRepository(List<ConsentEvent> events)
    : _stream = Stream.value(events);

  final Stream<List<ConsentEvent>> _stream;

  @override
  Future<void> recordConsent({
    required String policyVersion,
    required String appVersion,
    required List<String> consentsGiven,
  }) async {}

  @override
  Stream<List<ConsentEvent>> watchConsents() => _stream;
}

Widget _wrap(IConsentRepository repository) {
  return ProviderScope(
    overrides: [consentRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: ConsentHistoryScreen()),
  );
}

void main() {
  group('ConsentHistoryScreen', () {
    testWidgets('renders one row per ConsentEvent', (tester) async {
      final events = [
        ConsentEvent(
          id: 'evt-1',
          createdAt: DateTime.utc(2026, 7, 16, 10, 30),
          appVersion: '0.1.0+1',
          policyVersion: '2026-07-16',
          consentsGiven: const [
            'terms',
            'privacy',
            'not_medical_advice',
            'user_responsibility',
          ],
        ),
        ConsentEvent(
          id: 'evt-2',
          createdAt: DateTime.utc(2026, 8, 1, 9),
          appVersion: '0.1.0+2',
          policyVersion: '2026-08-01',
          consentsGiven: const [
            'terms',
            'privacy',
            'not_medical_advice',
            'user_responsibility',
            'age_16_plus',
          ],
        ),
      ];

      await tester.pumpWidget(_wrap(_FakeConsentRepository(events)));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNWidgets(2));
      expect(find.textContaining('0.1.0+1'), findsOneWidget);
      expect(find.textContaining('0.1.0+2'), findsOneWidget);
      expect(find.textContaining('2026-07-16'), findsOneWidget);
      expect(find.textContaining('2026-08-01'), findsOneWidget);

      // Plain-language translation -- never the raw JSON keys.
      expect(find.textContaining('Terms of Service'), findsWidgets);
      expect(find.textContaining('Privacy Policy'), findsWidgets);
      expect(find.textContaining('Health Disclaimer'), findsWidgets);
      expect(
        find.textContaining('Responsibility acknowledgment'),
        findsWidgets,
      );
      expect(find.textContaining('not_medical_advice'), findsNothing);
      expect(find.textContaining('user_responsibility'), findsNothing);
    });

    testWidgets(
      'shows an empty state when no consent has been recorded yet',
      (tester) async {
        await tester.pumpWidget(_wrap(_FakeConsentRepository(const [])));
        await tester.pumpAndSettle();

        expect(find.text('No consent recorded yet.'), findsOneWidget);
        expect(find.byType(Card), findsNothing);
      },
    );
  });
}

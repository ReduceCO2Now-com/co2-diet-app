import 'package:co2diet/core/di/legal_providers.dart';
import 'package:co2diet/domain/repositories/i_consent_repository.dart';
import 'package:co2diet/domain/services/legal_document_loader.dart';
import 'package:co2diet/features/legal/screens/legal_consent_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockConsentRepository extends Mock implements IConsentRepository {}

/// Avoids depending on a real `rootBundle.loadString` platform-channel
/// round trip for `docs/legal/terms.md` in every test case -- this
/// widget test only needs a deterministic, instant version string.
class _FakeLegalDocumentLoader extends LegalDocumentLoader {
  const _FakeLegalDocumentLoader();

  @override
  Future<String> versionOf(String assetFileName) async => 'test-version';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockConsentRepository mockConsentRepository;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    mockConsentRepository = _MockConsentRepository();
    when(
      () => mockConsentRepository.recordConsent(
        policyVersion: any(named: 'policyVersion'),
        appVersion: any(named: 'appVersion'),
        consentsGiven: any(named: 'consentsGiven'),
      ),
    ).thenAnswer((_) async {});
  });

  Widget wrap({double? textScale}) {
    final router = GoRouter(
      initialLocation: '/legal-consent',
      routes: [
        GoRoute(
          path: '/legal-consent',
          builder: (context, state) => const LegalConsentScreen(),
        ),
        GoRoute(
          path: '/legal-hub/document',
          builder: (context, state) => Scaffold(
            body: Text('doc:${state.uri.queryParameters['doc']}'),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) =>
              const Scaffold(body: Text('Profile Setup')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        consentRepositoryProvider.overrideWithValue(mockConsentRepository),
        appVersionProvider.overrideWith((ref) async => '0.1.0+1'),
        legalDocumentLoaderProvider.overrideWithValue(
          const _FakeLegalDocumentLoader(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        builder: textScale == null
            ? null
            : (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!,
              ),
      ),
    );
  }

  /// Taps the 4 mandatory checkboxes (indices 0-3: Terms, Privacy,
  /// not-medical-advice, user-responsibility), optionally also tapping
  /// the 5th optional 16+ checkbox (index 4).
  Future<void> tapMandatoryCheckboxes(
    WidgetTester tester, {
    bool includeOptional = false,
  }) async {
    final checkboxFinder = find.byType(Checkbox);
    final indices = [0, 1, 2, 3, if (includeOptional) 4];
    for (final i in indices) {
      await tester.tap(checkboxFinder.at(i));
      await tester.pump();
    }
  }

  group('LegalConsentScreen', () {
    testWidgets(
      'no checkbox starts pre-checked and Accept and Continue is disabled',
      (tester) async {
        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        final checkboxes = tester.widgetList<Checkbox>(
          find.byType(Checkbox),
        );
        expect(checkboxes.length, 5);
        expect(checkboxes.every((c) => c.value == false), isTrue);

        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Accept and Continue'),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'checking all 4 mandatory checkboxes enables Accept and Continue',
      (tester) async {
        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tapMandatoryCheckboxes(tester);

        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Accept and Continue'),
        );
        expect(button.onPressed, isNotNull);
      },
    );

    testWidgets(
      'unchecking one mandatory checkbox after all were checked disables '
      'the button again',
      (tester) async {
        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tapMandatoryCheckboxes(tester);

        var button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Accept and Continue'),
        );
        expect(button.onPressed, isNotNull);

        await tester.tap(find.byType(Checkbox).at(0));
        await tester.pump();

        button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Accept and Continue'),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'checking only 3 of 4 mandatory boxes plus the optional 16+ box '
      'leaves the button disabled',
      (tester) async {
        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        final checkboxFinder = find.byType(Checkbox);
        for (final i in [0, 1, 2, 4]) {
          await tester.tap(checkboxFinder.at(i));
          await tester.pump();
        }

        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Accept and Continue'),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'tapping View Terms before any box is checked navigates to the '
      'Terms document',
      (tester) async {
        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Accept and Continue'),
        );
        expect(button.onPressed, isNull);

        await tester.tap(find.widgetWithText(TextButton, 'View Terms'));
        await tester.pumpAndSettle();

        expect(find.text('doc:terms'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Accept and Continue with all 4 mandatory + optional '
      'checked calls acceptConsent with a 5-element list including '
      "'age_16_plus'",
      (tester) async {
        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tapMandatoryCheckboxes(tester, includeOptional: true);

        await tester.tap(
          find.widgetWithText(FilledButton, 'Accept and Continue'),
        );
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockConsentRepository.recordConsent(
            policyVersion: any(named: 'policyVersion'),
            appVersion: any(named: 'appVersion'),
            consentsGiven: captureAny(named: 'consentsGiven'),
          ),
        ).captured;
        final consentsGiven = captured.single as List<String>;
        expect(consentsGiven.length, 5);
        expect(consentsGiven, contains('age_16_plus'));

        expect(find.text('Profile Setup'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Accept and Continue with only the 4 mandatory boxes '
      'checked calls acceptConsent with exactly 4 elements, omitting '
      "'age_16_plus'",
      (tester) async {
        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tapMandatoryCheckboxes(tester);

        await tester.tap(
          find.widgetWithText(FilledButton, 'Accept and Continue'),
        );
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockConsentRepository.recordConsent(
            policyVersion: any(named: 'policyVersion'),
            appVersion: any(named: 'appVersion'),
            consentsGiven: captureAny(named: 'consentsGiven'),
          ),
        ).captured;
        final consentsGiven = captured.single as List<String>;
        expect(consentsGiven.length, 4);
        expect(consentsGiven, isNot(contains('age_16_plus')));
      },
    );

    testWidgets('renders without overflow at 1.6x text scale (ACC-02)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(textScale: 1.6));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'each checkbox row exposes a merged semantics label discoverable '
      'via find.bySemanticsLabel (ACC-03)',
      (tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel(
            'I have read and agree to the Terms of Service',
          ),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('I confirm I am 16 or older'),
          findsOneWidget,
        );

        handle.dispose();
      },
    );
  });
}

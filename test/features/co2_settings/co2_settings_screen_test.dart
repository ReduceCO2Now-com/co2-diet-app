import 'package:co2diet/core/di/co2_settings_providers.dart';
import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:co2diet/domain/repositories/i_co2_settings_repository.dart';
import 'package:co2diet/features/co2_settings/screens/co2_settings_screen.dart';
import 'package:co2diet/features/co2_settings/widgets/data_quality_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake repository so saved settings are reflected on the next
/// rebuild (real persistence behavior), unlike a mocktail Mock which would
/// require per-call stubbing.
class _FakeCo2SettingsRepository implements ICo2SettingsRepository {
  Co2Settings _stored = const Co2Settings();

  @override
  Future<Co2Settings> getSettings() async => _stored;

  @override
  Future<void> saveSettings(Co2Settings settings) async {
    _stored = settings;
  }
}

void main() {
  group('DataQualityIndicator', () {
    testWidgets('renders Basic Estimate label for basic quality',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataQualityIndicator(dataQuality: 'basic'),
          ),
        ),
      );

      expect(find.text('Basic Estimate'), findsOneWidget);
    });

    testWidgets('renders Good Estimate label for good quality',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataQualityIndicator(dataQuality: 'good'),
          ),
        ),
      );

      expect(find.text('Good Estimate'), findsOneWidget);
    });

    testWidgets('renders Detailed Estimate label for detailed quality',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataQualityIndicator(dataQuality: 'detailed'),
          ),
        ),
      );

      expect(find.text('Detailed Estimate'), findsOneWidget);
    });
  });

  group('Co2SettingsScreen', () {
    Widget buildTestable(ICo2SettingsRepository repo) {
      return ProviderScope(
        overrides: [
          co2SettingsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: Co2SettingsScreen()),
      );
    }

    // A tall viewport so every one of the 7 fields (rendered in a
    // ListView) is within the cache extent and reachable via `find.text`
    // without needing to scroll during assertions.
    void useTallViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets(
      'all seven fields are optional; saving with everything empty '
      'succeeds',
      (tester) async {
        useTallViewport(tester);
        final repo = _FakeCo2SettingsRepository();
        await tester.pumpWidget(buildTestable(repo));
        await tester.pumpAndSettle();

        // All 7 fields render with no value pre-filled.
        expect(find.text('Location country'), findsOneWidget);
        expect(find.text('Location region'), findsOneWidget);
        expect(find.text('Purchasing source'), findsOneWidget);
        expect(find.text('Shopping transport'), findsOneWidget);
        expect(find.text('Cooking method'), findsOneWidget);
        expect(find.text('Food storage'), findsOneWidget);
        expect(find.text('Household size'), findsOneWidget);
        expect(find.text('Food waste level'), findsOneWidget);
        expect(find.text('Basic Estimate'), findsOneWidget);

        // Triggering a change on an already-empty text field (no validator
        // blocks saving with everything empty).
        await tester.enterText(find.byType(TextFormField).first, '');
        await tester.pumpAndSettle();

        // No error surfaced -- the screen still renders normally.
        expect(find.text('Error loading CO2 settings'), findsNothing);
        expect(find.byType(Co2SettingsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'data quality indicator updates as fields are filled in',
      (tester) async {
        useTallViewport(tester);
        final repo = _FakeCo2SettingsRepository();
        await tester.pumpWidget(buildTestable(repo));
        await tester.pumpAndSettle();

        expect(find.text('Basic Estimate'), findsOneWidget);

        // Fill in location country -- 1 field set, still basic (<=2).
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Location country'),
          'DE',
        );
        await tester.pumpAndSettle();
        expect(find.text('Basic Estimate'), findsOneWidget);

        // Fill in enough fields to cross into "good" (3-5 fields set).
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Location region'),
          'Berlin',
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.widgetWithText(DropdownButtonFormField<String?>,
              'Purchasing source'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Local farm').last);
        await tester.pumpAndSettle();

        expect(find.text('Good Estimate'), findsOneWidget);

        // Fill in the remaining fields to cross into "detailed" (6-7 set).
        await tester.tap(
          find.widgetWithText(DropdownButtonFormField<String?>,
              'Shopping transport'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Walk or bike').last);
        await tester.pumpAndSettle();

        await tester.tap(
          find.widgetWithText(DropdownButtonFormField<String?>,
              'Cooking method'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Electric').last);
        await tester.pumpAndSettle();

        await tester.tap(
          find.widgetWithText(DropdownButtonFormField<String?>,
              'Food storage'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Small fridge').last);
        await tester.pumpAndSettle();

        expect(find.text('Detailed Estimate'), findsOneWidget);
      },
    );

    testWidgets(
      'Location country field survives an onChanged-driven rebuild '
      '(regression: value-tied key bug)',
      (tester) async {
        // Regression test for a real device-testing-only bug: every field
        // in this screen was keyed by its own current value
        // (`ValueKey('location-country-${settings.locationCountry}')`
        // etc.), so the auto-save round-trip (onChanged -> saveSettings ->
        // provider rebuild -> new key) made Flutter tear down and recreate
        // the field's Element on every keystroke, dropping focus and
        // dismissing the keyboard. `enterText` alone (used elsewhere in
        // this file) never caught this since it sets the whole value in
        // one shot -- this test instead asserts the EditableTextState
        // identity survives the exact onChanged->rebuild cycle a real
        // keystroke triggers.
        useTallViewport(tester);
        final repo = _FakeCo2SettingsRepository();
        await tester.pumpWidget(buildTestable(repo));
        await tester.pumpAndSettle();

        final field = find.widgetWithText(TextFormField, 'Location country');
        final stateBefore = tester.state<EditableTextState>(
          find.descendant(of: field, matching: find.byType(EditableText)),
        );

        await tester.enterText(field, 'D');
        await tester.pump();

        final stateAfter = tester.state<EditableTextState>(
          find.descendant(
            of: find.widgetWithText(TextFormField, 'Location country'),
            matching: find.byType(EditableText),
          ),
        );

        expect(
          identical(stateBefore, stateAfter),
          isTrue,
          reason:
              'Location country TextFormField was remounted (new '
              'EditableTextState) when its own value changed -- this is '
              'exactly the bug that dropped focus/dismissed the keyboard '
              'after every keystroke on real devices.',
        );
      },
    );
  });
}

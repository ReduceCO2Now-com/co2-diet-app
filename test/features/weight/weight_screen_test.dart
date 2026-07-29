import 'package:co2diet/core/di/weight_providers.dart';
import 'package:co2diet/domain/entities/weight_entry.dart';
import 'package:co2diet/domain/entities/weight_settings.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:co2diet/domain/repositories/i_weight_repository.dart';
import 'package:co2diet/features/weight/screens/weight_screen.dart';
import 'package:co2diet/features/weight/widgets/weight_chart.dart';
import 'package:co2diet/features/weight/widgets/weight_entry_form.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake repository -- mirrors `_FakeCo2SettingsRepository`'s
/// precedent (Plan 05-12): saved values are reflected on the next rebuild,
/// which a mocktail Mock would require per-call stubbing to achieve.
class _FakeWeightRepository implements IWeightRepository {
  final List<WeightEntry> _entries = [];
  WeightSettings _settings = const WeightSettings();

  @override
  Future<WeightEntry> logWeight(WeightEntry draft) async {
    final saved = draft.copyWith(id: 'w${_entries.length + 1}');
    _entries.add(saved);
    return saved;
  }

  @override
  Future<List<WeightEntry>> getEntriesInRange(WeightRange range) async {
    // Mirrors the real WeightRepository/WeightDao's actual date-bound
    // filtering (WeightRangeResolution.startDate) -- a range-blind fake
    // here would silently mask a real range-filtering bug in the app.
    final from = range.startDate(DateTime.now());
    if (from == null) return List.of(_entries);
    return _entries.where((e) => !e.loggedAt.isBefore(from)).toList();
  }

  @override
  Future<void> deleteEntry(String id) async =>
      _entries.removeWhere((e) => e.id == id);

  @override
  Future<WeightSettings> getSettings() async => _settings;

  @override
  Future<void> saveGoal({
    double? targetWeightKg,
    DateTime? targetDate,
  }) async {
    _settings = _settings.copyWith(
      targetWeightKg: targetWeightKg,
      targetDate: targetDate,
    );
  }

  @override
  Future<void> saveReminderSettings({
    required String frequency,
    required bool enabled,
    int? weekday,
    String? time,
  }) async {
    _settings = _settings.copyWith(
      reminderFrequency: frequency,
      reminderEnabled: enabled,
      reminderWeekday: weekday,
      reminderTime: time,
    );
  }
}

Widget _buildTestable(IWeightRepository repo, Widget child) {
  return ProviderScope(
    overrides: [weightRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets(
    'logging a weight entry appends a point to the chart',
    (tester) async {
      final repo = _FakeWeightRepository();
      await tester.pumpWidget(
        _buildTestable(
          repo,
          Builder(
            builder: (context) => Column(
              children: [
                const WeightChart(),
                ElevatedButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => const WeightEntryForm(),
                  ),
                  child: const Text('Open form'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final before = tester.widget<LineChart>(find.byType(LineChart));
      expect(before.data.lineBarsData.first.spots, isEmpty);

      await tester.tap(find.text('Open form'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '80');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final after = tester.widget<LineChart>(find.byType(LineChart));
      expect(after.data.lineBarsData.first.spots, hasLength(1));
    },
  );

  testWidgets(
    'goal line renders as a dashed horizontal line with no '
    'pace/projection text anywhere nearby',
    (tester) async {
      final repoNoGoal = _FakeWeightRepository();
      await tester.pumpWidget(
        _buildTestable(repoNoGoal, const WeightChart()),
      );
      await tester.pumpAndSettle();

      var chart = tester.widget<LineChart>(find.byType(LineChart));
      expect(chart.data.extraLinesData.horizontalLines, isEmpty);

      final repoWithGoal = _FakeWeightRepository();
      await repoWithGoal.saveGoal(targetWeightKg: 75);
      await tester.pumpWidget(
        _buildTestable(repoWithGoal, const WeightChart()),
      );
      await tester.pumpAndSettle();

      chart = tester.widget<LineChart>(find.byType(LineChart));
      expect(chart.data.extraLinesData.horizontalLines, hasLength(1));

      final line = chart.data.extraLinesData.horizontalLines.first;
      expect(line.dashArray, isNotNull);
      expect(line.label.labelResolver(line), 'Goal: 75.0 kg');

      // No pace/projection text anywhere in the widget tree.
      expect(find.textContaining('pace'), findsNothing);
      expect(find.textContaining('projection'), findsNothing);
      expect(find.textContaining('on track'), findsNothing);
    },
  );

  testWidgets(
    'range segmented button (7d/30d/90d/1yr/all) actually changes which '
    'entries the chart plots (UAT Test 4: user reported the chart stays '
    'static when switching ranges)',
    (tester) async {
      final now = DateTime.now();
      final repo = _FakeWeightRepository()
        .._entries.addAll([
          WeightEntry(
            id: 'a',
            value: 80,
            unit: WeightUnit.kg,
            loggedAt: now.subtract(const Duration(days: 3)),
          ),
          WeightEntry(
            id: 'b',
            value: 79,
            unit: WeightUnit.kg,
            loggedAt: now.subtract(const Duration(days: 20)),
          ),
          WeightEntry(
            id: 'c',
            value: 78,
            unit: WeightUnit.kg,
            loggedAt: now.subtract(const Duration(days: 60)),
          ),
          WeightEntry(
            id: 'd',
            value: 77,
            unit: WeightUnit.kg,
            loggedAt: now.subtract(const Duration(days: 200)),
          ),
          WeightEntry(
            id: 'e',
            value: 76,
            unit: WeightUnit.kg,
            loggedAt: now.subtract(const Duration(days: 400)),
          ),
        ]);

      await tester.pumpWidget(_buildTestable(repo, const WeightChart()));
      await tester.pumpAndSettle();

      List<Object?> spots() =>
          tester.widget<LineChart>(find.byType(LineChart)).data
              .lineBarsData
              .first
              .spots;

      // Default range is Month (30d) -- entries a+b (3 and 20 days ago).
      expect(spots(), hasLength(2));

      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      expect(spots(), hasLength(1)); // only a (3 days ago)

      await tester.tap(find.text('3 Months'));
      await tester.pumpAndSettle();
      expect(spots(), hasLength(3)); // a+b+c (adds 60 days ago)

      await tester.tap(find.text('Year'));
      await tester.pumpAndSettle();
      expect(spots(), hasLength(4)); // a+b+c+d (adds 200 days ago)

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(spots(), hasLength(5)); // a+b+c+d+e (adds 400 days ago)
    },
  );

  testWidgets(
    'reminder frequency Custom reveals a weekday + time picker',
    (tester) async {
      // Tall viewport so the whole ListView (chart, goal, reminders,
      // best-practices) is within cache extent -- mirrors Plan 05-12's
      // Co2SettingsScreen test precedent.
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeWeightRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [weightRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(home: WeightScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Day of week'), findsNothing);
      expect(find.text('Time'), findsNothing);

      await tester.tap(
        find.widgetWithText(DropdownButtonFormField<String>, 'Frequency'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom').last);
      await tester.pumpAndSettle();

      expect(find.text('Day of week'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
    },
  );

  testWidgets(
    'Target weight field survives an onChanged-driven rebuild '
    '(regression: value-tied key bug)',
    (tester) async {
      // Regression test for a real device-testing-only bug: this field was
      // keyed by its own current value
      // (`ValueKey('target-weight-${widget.settings.targetWeightKg}')`), so
      // the auto-save round-trip (onChanged -> saveGoal -> provider
      // rebuild -> new key) made Flutter tear down and recreate the
      // field's Element on every keystroke, dropping focus and dismissing
      // the keyboard. `enterText` alone (used elsewhere in this file)
      // never caught this since it sets the whole value in one shot --
      // this test instead asserts the EditableTextState identity survives
      // the exact onChanged->rebuild cycle a real keystroke triggers.
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeWeightRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [weightRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(home: WeightScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final targetWeightField = find.widgetWithText(
        TextFormField,
        'Target weight',
      );
      final stateBefore = tester.state<EditableTextState>(
        find.descendant(
          of: targetWeightField,
          matching: find.byType(EditableText),
        ),
      );

      await tester.enterText(targetWeightField, '7');
      await tester.pump();

      final stateAfter = tester.state<EditableTextState>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Target weight'),
          matching: find.byType(EditableText),
        ),
      );

      expect(
        identical(stateBefore, stateAfter),
        isTrue,
        reason:
            'Target weight TextFormField was remounted (new '
            'EditableTextState) when its own value changed -- this is '
            'exactly the bug that dropped focus/dismissed the keyboard '
            'after every keystroke on real devices.',
      );
    },
  );
}

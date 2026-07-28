// Widget tests for MealEntryRow (replaces the Wave 0 skip stub).
//
// Swipe/actions/content assertions run directly against MealEntryRow.
// The "empty slot hides its header" case is a PlaceholderDashboardScreen
// composition behavior (not something a single MealEntryRow instance can
// exhibit), so it's covered here via the dashboard screen with
// mealEntryRepositoryProvider mocked — same override pattern as
// test/features/food_search/portion_slot_form_test.dart.

import 'package:co2diet/core/di/co2_settings_providers.dart';
import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/repositories/i_co2_settings_repository.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:co2diet/domain/repositories/i_profile_repository.dart';
import 'package:co2diet/features/dashboard/screens/placeholder_dashboard_screen.dart';
import 'package:co2diet/features/dashboard/widgets/meal_entry_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealEntryRepository extends Mock implements IMealEntryRepository {}

class _MockProfileRepository extends Mock implements IProfileRepository {}

class _MockCo2SettingsRepository extends Mock
    implements ICo2SettingsRepository {}

MealEntry _buildEntry({
  String id = 'entry-1',
  MealSlot mealSlot = MealSlot.lunch,
  double quantity = 150,
  PortionUnit unit = PortionUnit.g,
  double? calories100g = 200,
  double? co2e100g = 2.5,
}) => MealEntry(
  id: id,
  mealSlot: mealSlot,
  foodRef: '1234567890123',
  foodRefSource: 'off_ref',
  quantity: quantity,
  unit: unit,
  productNameSnapshot: 'Test Food',
  calories100gSnapshot: calories100g,
  co2e100gSnapshot: co2e100g,
  loggedAt: DateTime(2026, 7, 24, 12),
  logDate: '2026-07-24',
);

/// Wraps [child] with a bare [ProviderScope] (no repository dependency —
/// [MealEntryRow] itself is a [ConsumerWidget] but reads no providers) and
/// a [MaterialApp] host with enough width for the swipe gesture.
Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('MealEntryRow', () {
    testWidgets('swipe reveals Edit, Duplicate, Delete actions', (
      tester,
    ) async {
      final entry = _buildEntry();

      await tester.pumpWidget(
        _wrap(
          MealEntryRow(
            entry: entry,
            onEdit: (_) {},
            onDuplicate: (_) {},
            onDelete: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsNothing);
      expect(find.text('Duplicate'), findsNothing);
      expect(find.text('Delete'), findsNothing);

      await tester.drag(find.byType(Slidable), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Duplicate'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets(
      'row shows name, quantity, calories, and CO2 (not just '
      'name+quantity)',
      (tester) async {
        final entry = _buildEntry();

        await tester.pumpWidget(
          _wrap(
            MealEntryRow(
              entry: entry,
              onEdit: (_) {},
              onDuplicate: (_) {},
              onDelete: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Test Food'), findsOneWidget);
        // 150g @ 200 kcal/100g -> 300 kcal; 2.5 kg CO2e/kg @ 150g -> ~0.38.
        expect(find.textContaining('150g'), findsOneWidget);
        expect(find.textContaining('300 kcal'), findsOneWidget);
        expect(find.textContaining('kg CO'), findsOneWidget);
      },
    );

    testWidgets('a slot with zero entries hides its header entirely', (
      tester,
    ) async {
      // Tall test viewport -- Plan 05-18's composed header (mode
      // indicator/metric cards/sparkline/quick insight/quick-log row)
      // needs more vertical space than the default 800x600 test surface
      // (05-12 precedent).
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockRepo = _MockMealEntryRepository();
      when(
        mockRepo.getEntriesForToday,
      ).thenAnswer((_) async => [_buildEntry()]);
      when(
        () => mockRepo.getEntriesInRange(any(), any()),
      ).thenAnswer((_) async => []);

      final mockProfileRepo = _MockProfileRepository();
      when(mockProfileRepo.getProfile).thenAnswer((_) async => null);

      final mockCo2SettingsRepo = _MockCo2SettingsRepository();
      when(
        mockCo2SettingsRepo.getSettings,
      ).thenAnswer((_) async => const Co2Settings());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mealEntryRepositoryProvider.overrideWithValue(mockRepo),
            profileRepositoryProvider.overrideWithValue(mockProfileRepo),
            co2SettingsRepositoryProvider.overrideWithValue(
              mockCo2SettingsRepo,
            ),
          ],
          child: const MaterialApp(home: PlaceholderDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Every slot's quick-log button always renders one "<Slot>" text
      // regardless of that slot's entry count (DASH-02) -- the section
      // *header* is the thing that's conditionally hidden. A slot with
      // entries therefore has 2 matches (button + header); an empty slot
      // has exactly 1 (button only).
      expect(find.text('Lunch'), findsNWidgets(2));
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('Snack'), findsOneWidget);
    });
  });
}

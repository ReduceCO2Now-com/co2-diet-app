// Regression guard: swipe-to-reveal must keep working when a MealEntryRow
// is embedded in the real PlaceholderDashboardScreen composition (ListView +
// slot headers + multiple rows), driven by a realistic multi-step drag
// rather than a single teleporting tester.drag() call — closer to what a
// real finger produces, and closer to production structure than
// meal_entry_row_test.dart's bare single-widget host.
import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/domain/repositories/i_meal_entry_repository.dart';
import 'package:co2diet/features/dashboard/screens/placeholder_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealEntryRepository extends Mock implements IMealEntryRepository {}

MealEntry _buildEntry(String id, MealSlot slot) => MealEntry(
  id: id,
  mealSlot: slot,
  foodRef: '1234567890123',
  foodRefSource: 'off_ref',
  quantity: 150,
  unit: PortionUnit.g,
  productNameSnapshot: 'Test Food $id',
  calories100gSnapshot: 200,
  co2e100gSnapshot: 2.5,
  loggedAt: DateTime(2026, 7, 24, 12),
  logDate: '2026-07-24',
);

Future<void> _realisticDrag(
  WidgetTester tester,
  Finder finder,
  Offset totalOffset,
) async {
  final gesture = await tester.startGesture(tester.getCenter(finder));
  const steps = 10;
  for (var i = 1; i <= steps; i++) {
    await gesture.moveBy(
      Offset(totalOffset.dx / steps, totalOffset.dy / steps),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'swipe on a MealEntryRow inside the real PlaceholderDashboardScreen '
    '(ListView + multiple rows) reveals Edit/Duplicate/Delete via a '
    'realistic incremental drag',
    (tester) async {
      final mockRepo = _MockMealEntryRepository();
      when(mockRepo.getEntriesForToday).thenAnswer(
        (_) async => [
          _buildEntry('e1', MealSlot.breakfast),
          _buildEntry('e2', MealSlot.lunch),
          _buildEntry('e3', MealSlot.dinner),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [mealEntryRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: PlaceholderDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Slidable), findsNWidgets(3));
      expect(find.text('Edit'), findsNothing);

      // Realistic incremental drag on the SECOND row (not the first) —
      // closer to a real mid-list swipe than a bare single-widget host.
      await _realisticDrag(
        tester,
        find.byType(Slidable).at(1),
        const Offset(-400, 0),
      );

      expect(
        find.text('Edit'),
        findsOneWidget,
        reason: 'Edit action should be revealed after a realistic swipe',
      );
      expect(find.text('Duplicate'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    },
  );
}

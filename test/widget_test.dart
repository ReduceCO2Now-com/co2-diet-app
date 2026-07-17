import 'package:co2diet/app.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const Co2DietApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(Co2DietApp), findsOneWidget);
  });
}

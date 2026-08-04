import 'package:co2diet/app.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // Plan 06-09: appRouterProvider's redirect callback reads
    // onboardingGateProvider, which reads sharedPreferencesProvider --
    // must be overridden or the default throws UnimplementedError.
    // Marked onboarding-complete so the router redirects straight to
    // '/dashboard' -- otherwise SplashScreen's real 2s Future.delayed
    // timer is still pending when this single-pump smoke test ends
    // ("A Timer is still pending even after the widget tree was
    // disposed").
    SharedPreferences.setMockInitialValues({
      'hasCompletedOnboarding': true,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const Co2DietApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(Co2DietApp), findsOneWidget);
  });
}

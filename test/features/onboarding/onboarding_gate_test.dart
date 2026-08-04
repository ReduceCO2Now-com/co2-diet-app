import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingGateNotifier (provider-level)', () {
    late ProviderContainer container;

    Future<ProviderContainer> makeContainer({
      Map<String, Object> initialValues = const {},
    }) async {
      SharedPreferences.setMockInitialValues(initialValues);
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('build() returns false when no stored flag exists', () async {
      container = await makeContainer();
      expect(container.read(onboardingGateProvider), isFalse);
    });

    test('build() returns true when the stored flag is true', () async {
      container = await makeContainer(
        initialValues: {'hasCompletedOnboarding': true},
      );
      expect(container.read(onboardingGateProvider), isTrue);
    });

    test(
      'completeOnboarding() persists true and updates state synchronously',
      () async {
        container = await makeContainer();
        expect(container.read(onboardingGateProvider), isFalse);

        await container
            .read(onboardingGateProvider.notifier)
            .completeOnboarding();

        expect(container.read(onboardingGateProvider), isTrue);

        final prefs = container.read(sharedPreferencesProvider);
        expect(prefs.getBool('hasCompletedOnboarding'), isTrue);
      },
    );
  });

  group(
    'OnboardingGate (router-redirect)',
    skip: 'Awaiting Plan 06-09 implementation',
    () {
      // TODO(Plan 06-09): first launch with no stored onboarding-complete
      // flag redirects to /splash (ONBD-01).
      testWidgets(
        'first launch (no stored flag) redirects to /splash',
        (tester) async {},
      );

      // TODO(Plan 06-09): completed onboarding redirects away from
      // /welcome to /dashboard (ONBD-05).
      testWidgets(
        'completed onboarding redirects away from /welcome to '
        '/dashboard',
        (tester) async {},
      );

      // TODO(Plan 06-09): a direct deep link to /dashboard before
      // onboarding completes redirects to /splash.
      testWidgets(
        'a direct deep link to /dashboard before onboarding '
        'completes redirects to /splash',
        (tester) async {},
      );
    },
  );
}

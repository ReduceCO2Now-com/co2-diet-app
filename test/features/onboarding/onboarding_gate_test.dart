import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'OnboardingGate',
    skip: 'Awaiting Plan 06-09 implementation (unit-level supplement '
        'from Plan 06-05)',
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

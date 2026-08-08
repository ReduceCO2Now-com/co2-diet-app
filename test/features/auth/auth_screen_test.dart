import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'AuthScreen',
    skip: 'Awaiting Plan 07-05 implementation',
    () {
      // TODO(Plan 07-05): defaults to create-account mode with social
      // buttons above an 'or' divider above email/password fields.
      testWidgets(
        "defaults to create-account mode with social buttons above an "
        "'or' divider above email/password fields",
        (tester) async {},
      );

      // TODO(Plan 07-05): Apple button only renders on iOS.
      testWidgets(
        'Apple button only renders on iOS',
        (tester) async {},
      );

      // TODO(Plan 07-05): toggling 'Already have an account? Sign in'
      // switches to sign-in mode and hides the account-mode-terms
      // checkbox.
      testWidgets(
        "toggling 'Already have an account? Sign in' switches to "
        'sign-in mode and hides the account-mode-terms checkbox',
        (tester) async {},
      );

      // TODO(Plan 07-05): honesty note text is always visible.
      testWidgets(
        'honesty note text is always visible',
        (tester) async {},
      );

      // TODO(Plan 07-05): submitting create-account with a password
      // under 8 chars shows an inline error and does not call the
      // notifier.
      testWidgets(
        'submitting create-account with a password under 8 chars '
        'shows an inline error and does not call the notifier',
        (tester) async {},
      );

      // TODO(Plan 07-05): submitting create-account without the terms
      // checkbox checked shows an inline error.
      testWidgets(
        'submitting create-account without the terms checkbox checked '
        'shows an inline error',
        (tester) async {},
      );

      // TODO(Plan 07-05): submitting valid create-account calls
      // signUp() and navigates to /check-email.
      testWidgets(
        'submitting valid create-account calls signUp() and navigates '
        'to /check-email',
        (tester) async {},
      );

      // TODO(Plan 07-05): offline (mocked connectivity none) shows an
      // inline no-connection message and never opens the browser.
      testWidgets(
        'offline (mocked connectivity none) shows an inline '
        'no-connection message and never opens the browser',
        (tester) async {},
      );

      // TODO(Plan 07-05): 'Forgot password?' launches the
      // reset-credentials URL via url_launcher.
      testWidgets(
        "'Forgot password?' launches the reset-credentials URL via "
        'url_launcher',
        (tester) async {},
      );

      // TODO(Plan 07-05): tapping the Google/Apple button calls
      // signInWithIdp with the matching alias.
      testWidgets(
        'tapping the Google/Apple button calls signInWithIdp with the '
        'matching alias',
        (tester) async {},
      );

      // TODO(Plan 07-05): CheckEmailScreen renders the entered email
      // and a working Resend action.
      testWidgets(
        'CheckEmailScreen renders the entered email and a working '
        'Resend action',
        (tester) async {},
      );
    },
  );
}

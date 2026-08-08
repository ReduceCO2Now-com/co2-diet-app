import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'AccountSection',
    skip: 'Awaiting Plan 07-06 implementation',
    () {
      // TODO(Plan 07-06): signed-out state shows a single
      // Sign in / Create account row that navigates to /auth.
      testWidgets(
        'signed-out state shows a single Sign in / Create account row '
        'that navigates to /auth',
        (tester) async {},
      );

      // TODO(Plan 07-06): signed-in state shows email + Change
      // password + Log out + Delete account rows.
      testWidgets(
        'signed-in state shows email + Change password + Log out + '
        'Delete account rows',
        (tester) async {},
      );

      // TODO(Plan 07-06): Change password launches the Keycloak
      // account-console URL.
      testWidgets(
        'Change password launches the Keycloak account-console URL',
        (tester) async {},
      );

      // TODO(Plan 07-06): Log out calls logout() immediately with no
      // confirmation dialog.
      testWidgets(
        'Log out calls logout() immediately with no confirmation '
        'dialog',
        (tester) async {},
      );

      // TODO(Plan 07-06): Delete account opens a confirmation
      // AlertDialog with the exact locked copy and no typed-word
      // field.
      testWidgets(
        'Delete account opens a confirmation AlertDialog with the '
        'exact locked copy and no typed-word field',
        (tester) async {},
      );

      // TODO(Plan 07-06): confirming delete calls deleteAccount();
      // cancelling does not.
      testWidgets(
        'confirming delete calls deleteAccount(); cancelling does not',
        (tester) async {},
      );

      // TODO(Plan 07-06): a failed deleteAccount() shows an inline
      // error and leaves the signed-in UI intact.
      testWidgets(
        'a failed deleteAccount() shows an inline error and leaves '
        'the signed-in UI intact',
        (tester) async {},
      );

      // TODO(Plan 07-06): AuthUnauthenticated(sessionExpired: true)
      // shows a one-time 'You've been signed out' notice and then
      // calls acknowledgeSessionExpired().
      testWidgets(
        "AuthUnauthenticated(sessionExpired: true) shows a one-time "
        "'You've been signed out' notice and then calls "
        'acknowledgeSessionExpired()',
        (tester) async {},
      );
    },
  );
}

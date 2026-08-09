// Real widget tests for AccountSection (replaces Plan 07-01's Wave 0 skip
// stub).
//
// authProvider is overridden with a small `_FakeAuthNotifier` (extends the
// real `AuthNotifier` and stubs `build()`/`logout()`/`deleteAccount()`)
// rather than mocking AuthNotifier's private OIDC/secure-storage
// dependencies directly -- this keeps the test focused on AccountSection's
// own signed-out/signed-in/deletion/session-expired UI logic, mirroring how
// widget tests elsewhere in this codebase override a generated Notifier
// provider wholesale rather than re-driving its internals.
//
// url_launcher is mocked via `UrlLauncherPlatform.instance` +
// `MockPlatformInterfaceMixin`, mirroring auth_screen_test.dart's precedent.

import 'package:co2diet/domain/entities/auth_state.dart';
import 'package:co2diet/features/auth/providers/auth_provider.dart';
import 'package:co2diet/features/settings/widgets/account_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _MockUrlLauncherPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

/// A controllable stand-in for the real `AuthNotifier` -- overrides only
/// the public surface AccountSection touches (`build`, `logout`,
/// `deleteAccount`, `acknowledgeSessionExpired`), never the private
/// OIDC/secure-storage internals.
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initialState, {this.deleteAccountBehavior});

  final AuthState _initialState;
  final Future<void> Function()? deleteAccountBehavior;

  int logoutCallCount = 0;
  int deleteAccountCallCount = 0;

  @override
  AuthState build() => _initialState;

  @override
  Future<void> logout() async {
    logoutCallCount++;
    state = AuthState.unauthenticated();
  }

  @override
  Future<void> deleteAccount() async {
    deleteAccountCallCount++;
    if (deleteAccountBehavior != null) {
      await deleteAccountBehavior!();
    } else {
      state = AuthState.unauthenticated();
    }
  }

  @override
  void acknowledgeSessionExpired() {
    final current = state;
    if (current is AuthUnauthenticated && current.sessionExpired) {
      state = AuthState.unauthenticated();
    }
  }
}

void main() {
  late _MockUrlLauncherPlatform mockUrlLauncherPlatform;

  setUpAll(() {
    registerFallbackValue(const LaunchOptions());
    mockUrlLauncherPlatform = _MockUrlLauncherPlatform();
    UrlLauncherPlatform.instance = mockUrlLauncherPlatform;
  });

  setUp(() {
    reset(mockUrlLauncherPlatform);
    when(
      () => mockUrlLauncherPlatform.launchUrl(any(), any()),
    ).thenAnswer((_) async => true);
  });

  Widget wrap(_FakeAuthNotifier fakeNotifier) {
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const Scaffold(body: AccountSection()),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) =>
              const Scaffold(body: Text('auth-screen')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [authProvider.overrideWith(() => fakeNotifier)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('AccountSection', () {
    testWidgets(
      'signed-out state shows a single Sign in / Create account row '
      'that navigates to /auth',
      (tester) async {
        final fake = _FakeAuthNotifier(AuthState.unauthenticated());
        await tester.pumpWidget(wrap(fake));
        await tester.pumpAndSettle();

        expect(find.text('Sign in / Create account'), findsOneWidget);
        expect(find.text('Change password'), findsNothing);

        await tester.tap(find.text('Sign in / Create account'));
        await tester.pumpAndSettle();

        expect(find.text('auth-screen'), findsOneWidget);
      },
    );

    testWidgets(
      'signed-in state shows email + Change password + Log out + '
      'Delete account rows',
      (tester) async {
        final fake = _FakeAuthNotifier(
          AuthState.authenticated(email: 'user@example.com'),
        );
        await tester.pumpWidget(wrap(fake));
        await tester.pumpAndSettle();

        expect(find.text('user@example.com'), findsOneWidget);
        expect(find.text('Change password'), findsOneWidget);
        expect(find.text('Log out'), findsOneWidget);
        expect(find.text('Delete account'), findsOneWidget);
      },
    );

    testWidgets(
      'Change password launches the Keycloak account-console URL',
      (tester) async {
        final fake = _FakeAuthNotifier(
          AuthState.authenticated(email: 'user@example.com'),
        );
        await tester.pumpWidget(wrap(fake));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Change password'));
        await tester.pumpAndSettle();

        final captured = verify(
          () => mockUrlLauncherPlatform.launchUrl(captureAny(), any()),
        ).captured;
        final launchedUrl = captured.single as String;
        expect(
          launchedUrl,
          'http://localhost:8081/realms/co2diet'
          '/account/account-security/signing-in',
        );
      },
    );

    testWidgets(
      'Log out calls logout() immediately with no confirmation dialog',
      (tester) async {
        final fake = _FakeAuthNotifier(
          AuthState.authenticated(email: 'user@example.com'),
        );
        await tester.pumpWidget(wrap(fake));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Log out'));
        await tester.pump();

        expect(find.byType(AlertDialog), findsNothing);
        expect(fake.logoutCallCount, 1);
      },
    );

    testWidgets(
      'Delete account opens a confirmation AlertDialog with the exact '
      'locked copy and no typed-word field',
      (tester) async {
        final fake = _FakeAuthNotifier(
          AuthState.authenticated(email: 'user@example.com'),
        );
        await tester.pumpWidget(wrap(fake));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete account'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Delete your account?'), findsOneWidget);
        expect(
          find.text(
            'Your account will be permanently deleted. Your local data on '
            'this device will NOT be affected.',
          ),
          findsOneWidget,
        );
        expect(find.byType(TextField), findsNothing);
        expect(find.text('Cancel'), findsOneWidget);
      },
    );

    testWidgets(
      'confirming delete calls deleteAccount(); cancelling does not',
      (tester) async {
        final fake = _FakeAuthNotifier(
          AuthState.authenticated(email: 'user@example.com'),
        );
        await tester.pumpWidget(wrap(fake));
        await tester.pumpAndSettle();

        // Open, then cancel.
        await tester.tap(find.text('Delete account'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(fake.deleteAccountCallCount, 0);
        expect(find.text('user@example.com'), findsOneWidget);

        // Open again, confirm this time.
        await tester.tap(find.text('Delete account'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(FilledButton, 'Delete account'),
        );
        await tester.pumpAndSettle();

        expect(fake.deleteAccountCallCount, 1);
      },
    );

    testWidgets(
      'a failed deleteAccount() shows an inline error and leaves the '
      'signed-in UI intact',
      (tester) async {
        final fake = _FakeAuthNotifier(
          AuthState.authenticated(email: 'user@example.com'),
          deleteAccountBehavior: () async {
            throw AccountDeletionException(500);
          },
        );
        await tester.pumpWidget(wrap(fake));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete account'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(FilledButton, 'Delete account'),
        );
        await tester.pumpAndSettle();

        expect(
          find.text("Couldn't delete your account -- please try again."),
          findsOneWidget,
        );
        // Signed-in UI is still fully intact.
        expect(find.text('user@example.com'), findsOneWidget);
        expect(find.text('Log out'), findsOneWidget);
      },
    );

    testWidgets(
      'shows success confirmation before reverting to signed-out on '
      'successful deletion',
      (tester) async {
        final fake = _FakeAuthNotifier(
          AuthState.authenticated(email: 'user@example.com'),
        );
        await tester.pumpWidget(wrap(fake));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete account'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(FilledButton, 'Delete account'),
        );
        await tester.pump();

        // Confirmation SnackBar shown before the section reverts.
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('Your account has been deleted.'),
          findsOneWidget,
        );

        await tester.pumpAndSettle();

        // Reverted to signed-out.
        expect(find.text('Sign in / Create account'), findsOneWidget);
      },
    );

    testWidgets(
      'AuthUnauthenticated(sessionExpired: true) shows a one-time '
      "'You've been signed out' notice and then calls "
      'acknowledgeSessionExpired()',
      (tester) async {
        final fake = _FakeAuthNotifier(
          AuthState.unauthenticated(sessionExpired: true),
        );
        await tester.pumpWidget(wrap(fake));
        await tester.pumpAndSettle();

        expect(find.text("You've been signed out"), findsOneWidget);

        // acknowledgeSessionExpired() already ran (from the
        // addPostFrameCallback), flipping sessionExpired back to false --
        // it never reappears on a later rebuild.
        final state = fake.state;
        expect(state, isA<AuthUnauthenticated>());
        expect((state as AuthUnauthenticated).sessionExpired, isFalse);
      },
    );
  });
}

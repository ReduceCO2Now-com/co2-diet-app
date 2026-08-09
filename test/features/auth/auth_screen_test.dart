// Real widget tests for AuthScreen + CheckEmailScreen (replaces Plan
// 07-01's Wave 0 skip stub).
//
// Uses the REAL AuthNotifier (via authProvider) wired to mocked
// FlutterAppAuth/FlutterSecureStorage/http.Client/IConsentRepository --
// mirrors test/features/auth/providers/auth_provider_test.dart's exact
// mocking pattern -- rather than faking the notifier itself, so social/
// email-password submit assertions verify the real
// `authorizeAndExchangeCode` call shape (kc_idp_hint / prompt=create /
// login_hint).
//
// Connectivity is mocked via the `TestDefaultBinaryMessengerBinding`/
// `dev.fluttercommunity.plus/connectivity` channel pattern from
// food_search_notifier_test.dart. url_launcher is mocked via
// `UrlLauncherPlatform.instance` + `MockPlatformInterfaceMixin`, mirroring
// backup_restore_screen_test.dart's `SharePlatform.instance` precedent.

import 'dart:convert';

import 'package:co2diet/core/di/auth_providers.dart';
import 'package:co2diet/core/di/legal_providers.dart';
import 'package:co2diet/domain/repositories/i_consent_repository.dart';
import 'package:co2diet/domain/services/keycloak_config.dart';
import 'package:co2diet/domain/services/legal_document_loader.dart';
import 'package:co2diet/features/auth/screens/auth_screen.dart';
import 'package:co2diet/features/auth/screens/check_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockAppAuth extends Mock implements FlutterAppAuth {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockHttpClient extends Mock implements http.Client {}

class _MockConsentRepository extends Mock implements IConsentRepository {}

class _MockUrlLauncherPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

class _FakeLegalDocumentLoader extends LegalDocumentLoader {
  const _FakeLegalDocumentLoader();

  @override
  Future<String> versionOf(String assetFileName) async => 'test-version';
}

// ---------------------------------------------------------------------------
// Connectivity channel helpers (food_search_notifier_test.dart pattern)
// ---------------------------------------------------------------------------

const _connectivityChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity',
);

void _mockConnectivity(String result) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_connectivityChannel, (call) async {
    if (call.method == 'check') {
      return [result];
    }
    return null;
  });
}

void _clearConnectivityMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_connectivityChannel, null);
}

// ---------------------------------------------------------------------------
// Response builders
// ---------------------------------------------------------------------------

AuthorizationTokenResponse _buildAuthResponse() => AuthorizationTokenResponse(
  'access-token',
  'refresh-token',
  DateTime.now().add(const Duration(hours: 1)),
  'id-token',
  'Bearer',
  KeycloakConfig.scopes,
  null,
  null,
);

http.Response _userInfoResponse({
  String email = 'user@example.com',
  bool emailVerified = true,
}) => http.Response(
  jsonEncode({'email': email, 'email_verified': emailVerified}),
  200,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAppAuth mockAppAuth;
  late _MockSecureStorage mockStorage;
  late _MockHttpClient mockHttpClient;
  late _MockConsentRepository mockConsentRepository;
  late _MockUrlLauncherPlatform mockUrlLauncherPlatform;

  setUpAll(() {
    registerFallbackValue(
      AuthorizationTokenRequest(
        KeycloakConfig.clientId,
        KeycloakConfig.redirectUrl,
        issuer: KeycloakConfig.issuer,
      ),
    );
    registerFallbackValue(const LaunchOptions());
    registerFallbackValue(Uri.parse('http://localhost'));
    // A single process-wide UrlLauncherPlatform mock, reset between tests
    // -- mirrors backup_restore_screen_test.dart's SharePlatform.instance
    // precedent (a lazily-initialized static field permanently binds to
    // whichever platform instance was set at first access).
    mockUrlLauncherPlatform = _MockUrlLauncherPlatform();
    UrlLauncherPlatform.instance = mockUrlLauncherPlatform;
  });

  setUp(() {
    mockAppAuth = _MockAppAuth();
    mockStorage = _MockSecureStorage();
    mockHttpClient = _MockHttpClient();
    mockConsentRepository = _MockConsentRepository();

    reset(mockUrlLauncherPlatform);
    when(
      () => mockUrlLauncherPlatform.launchUrl(any(), any()),
    ).thenAnswer((_) async => true);

    when(
      () => mockStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    when(
      () => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockStorage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});

    when(
      () => mockConsentRepository.recordConsent(
        policyVersion: any(named: 'policyVersion'),
        appVersion: any(named: 'appVersion'),
        consentsGiven: any(named: 'consentsGiven'),
      ),
    ).thenAnswer((_) async {});

    // Default: connectivity online. Individual offline tests override.
    _mockConnectivity('wifi');
  });

  tearDown(_clearConnectivityMock);

  // No explicit `List<Override>` return type: `Override` is not a publicly
  // exported name from riverpod's package API (it flows anonymously
  // through inference, same as any inline `overrides: [...]` literal).
  // ignore: always_declare_return_types
  overrides() => [
    appAuthProvider.overrideWithValue(mockAppAuth),
    secureStorageProvider.overrideWithValue(mockStorage),
    authHttpClientProvider.overrideWithValue(mockHttpClient),
    consentRepositoryProvider.overrideWithValue(mockConsentRepository),
    appVersionProvider.overrideWith((ref) async => '0.1.0+1'),
    legalDocumentLoaderProvider.overrideWithValue(
      const _FakeLegalDocumentLoader(),
    ),
  ];

  Widget wrap({bool? showAppleButton}) {
    final router = GoRouter(
      initialLocation: '/auth',
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) =>
              AuthScreen(showAppleButton: showAppleButton),
        ),
        GoRoute(
          path: '/check-email',
          builder: (context, state) => CheckEmailScreen(
            email: state.uri.queryParameters['email'] ?? '',
          ),
        ),
        GoRoute(
          path: '/legal-hub/document',
          builder: (context, state) => Scaffold(
            body: Text('doc:${state.uri.queryParameters['doc']}'),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const Scaffold(body: Text('Settings')),
        ),
      ],
    );

    return ProviderScope(
      overrides: overrides(),
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group(
    'AuthScreen',
    () {
      testWidgets(
        'defaults to create-account mode with social buttons above an '
        "'or' divider above email/password fields",
        (tester) async {
          await tester.pumpWidget(wrap());
          await tester.pumpAndSettle();

          // Create-account mode indicators.
          expect(find.byKey(const Key('accountModeTermsCheckbox')),
              findsOneWidget);
          expect(
            find.text('Already have an account? Sign in'),
            findsOneWidget,
          );

          final googleDy = tester
              .getTopLeft(find.byKey(const Key('googleSignInButton')))
              .dy;
          final dividerDy = tester.getTopLeft(find.text('or')).dy;
          final emailFieldDy = tester
              .getTopLeft(find.widgetWithText(TextFormField, 'Email'))
              .dy;

          expect(googleDy, lessThan(dividerDy));
          expect(dividerDy, lessThan(emailFieldDy));
        },
      );

      testWidgets(
        'Apple button only renders on iOS',
        (tester) async {
          await tester.pumpWidget(wrap(showAppleButton: false));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('appleSignInButton')),
            findsNothing,
          );

          await tester.pumpWidget(wrap(showAppleButton: true));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('appleSignInButton')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'renders Apple above Google on iOS',
        (tester) async {
          await tester.pumpWidget(wrap(showAppleButton: true));
          await tester.pumpAndSettle();

          final appleDy = tester
              .getTopLeft(find.byKey(const Key('appleSignInButton')))
              .dy;
          final googleDy = tester
              .getTopLeft(find.byKey(const Key('googleSignInButton')))
              .dy;

          expect(appleDy, lessThan(googleDy));
        },
      );

      testWidgets(
        "toggling 'Already have an account? Sign in' switches to "
        'sign-in mode and hides the account-mode-terms checkbox',
        (tester) async {
          await tester.pumpWidget(wrap());
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('accountModeTermsCheckbox')),
              findsOneWidget);

          await tester.tap(
            find.text('Already have an account? Sign in'),
          );
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('accountModeTermsCheckbox')),
              findsNothing);
          expect(find.text('New here? Create account'), findsOneWidget);
        },
      );

      testWidgets(
        'honesty note text is always visible',
        (tester) async {
          const honestyNote =
              'Your existing local data stays on this device — '
              'cross-device sync is coming soon.';

          await tester.pumpWidget(wrap());
          await tester.pumpAndSettle();
          expect(find.text(honestyNote), findsOneWidget);

          await tester.tap(
            find.text('Already have an account? Sign in'),
          );
          await tester.pumpAndSettle();
          expect(find.text(honestyNote), findsOneWidget);
        },
      );

      testWidgets(
        'submitting create-account with a password under 8 chars '
        'shows an inline error and does not call the notifier',
        (tester) async {
          await tester.pumpWidget(wrap());
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'),
            'user@example.com',
          );
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'),
            'short',
          );

          await tester.tap(
            find.widgetWithText(FilledButton, 'Create account'),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Password must be at least 8 characters'),
            findsOneWidget,
          );
          verifyNever(() => mockAppAuth.authorizeAndExchangeCode(any()));
        },
      );

      testWidgets(
        'submitting create-account without the terms checkbox checked '
        'shows an inline error',
        (tester) async {
          await tester.pumpWidget(wrap());
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'),
            'user@example.com',
          );
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'),
            'longenoughpassword',
          );

          await tester.tap(
            find.widgetWithText(FilledButton, 'Create account'),
          );
          await tester.pumpAndSettle();

          expect(
            find.text(
              'You must agree to the Terms for Account Mode to continue',
            ),
            findsOneWidget,
          );
          verifyNever(() => mockAppAuth.authorizeAndExchangeCode(any()));
        },
      );

      testWidgets(
        'submitting valid create-account calls signUp() and navigates '
        'to /check-email',
        (tester) async {
          when(
            () => mockAppAuth.authorizeAndExchangeCode(any()),
          ).thenAnswer((_) async => _buildAuthResponse());
          when(
            () => mockHttpClient.get(any(), headers: any(named: 'headers')),
          ).thenAnswer((_) async => _userInfoResponse());

          await tester.pumpWidget(wrap());
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'),
            'user@example.com',
          );
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'),
            'longenoughpassword',
          );
          await tester.tap(
            find.byKey(const Key('accountModeTermsCheckbox')),
          );
          await tester.pumpAndSettle();

          await tester.tap(
            find.widgetWithText(FilledButton, 'Create account'),
          );
          await tester.pumpAndSettle();

          final captured = verify(
            () => mockAppAuth.authorizeAndExchangeCode(captureAny()),
          ).captured;
          final request = captured.single as AuthorizationTokenRequest;
          expect(request.additionalParameters, {
            'prompt': 'create',
            'login_hint': 'user@example.com',
          });

          expect(
            find.textContaining(
              'We sent a verification link to user@example.com',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'offline (mocked connectivity none) shows an inline '
        'no-connection message and never opens the browser',
        (tester) async {
          _mockConnectivity('none');

          await tester.pumpWidget(wrap());
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'),
            'user@example.com',
          );
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'),
            'longenoughpassword',
          );
          await tester.tap(
            find.byKey(const Key('accountModeTermsCheckbox')),
          );
          await tester.pumpAndSettle();

          await tester.tap(
            find.widgetWithText(FilledButton, 'Create account'),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Sign-in requires an internet connection'),
            findsOneWidget,
          );
          verifyNever(() => mockAppAuth.authorizeAndExchangeCode(any()));
        },
      );

      testWidgets(
        "'Forgot password?' launches the reset-credentials URL via "
        'url_launcher',
        (tester) async {
          await tester.pumpWidget(wrap());
          await tester.pumpAndSettle();

          // Forgot password only shows in sign-in mode.
          await tester.tap(
            find.text('Already have an account? Sign in'),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Forgot password?'));
          await tester.pumpAndSettle();

          final captured = verify(
            () => mockUrlLauncherPlatform.launchUrl(
              captureAny(),
              any(),
            ),
          ).captured;
          final launchedUrl = captured.single as String;
          expect(
            launchedUrl,
            '${KeycloakConfig.issuer}/login-actions/reset-credentials'
            '?client_id=${KeycloakConfig.clientId}',
          );
        },
      );

      testWidgets(
        'tapping the Google/Apple button calls signInWithIdp with the '
        'matching alias',
        (tester) async {
          when(
            () => mockAppAuth.authorizeAndExchangeCode(any()),
          ).thenAnswer((_) async => _buildAuthResponse());
          when(
            () => mockHttpClient.get(any(), headers: any(named: 'headers')),
          ).thenAnswer((_) async => _userInfoResponse());

          await tester.pumpWidget(wrap(showAppleButton: true));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('appleSignInButton')));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('googleSignInButton')));
          await tester.pumpAndSettle();

          final captured = verify(
            () => mockAppAuth.authorizeAndExchangeCode(captureAny()),
          ).captured;
          expect(captured, hasLength(2));
          expect(
            (captured[0] as AuthorizationTokenRequest).additionalParameters,
            {'kc_idp_hint': KeycloakConfig.appleIdpAlias},
          );
          expect(
            (captured[1] as AuthorizationTokenRequest).additionalParameters,
            {'kc_idp_hint': KeycloakConfig.googleIdpAlias},
          );
        },
      );

      testWidgets(
        'CheckEmailScreen renders the entered email and a working '
        'Resend action',
        (tester) async {
          when(
            () => mockAppAuth.authorizeAndExchangeCode(any()),
          ).thenAnswer((_) async => _buildAuthResponse());
          when(
            () => mockHttpClient.get(any(), headers: any(named: 'headers')),
          ).thenAnswer((_) async => _userInfoResponse());

          await tester.pumpWidget(
            ProviderScope(
              overrides: overrides(),
              child: const MaterialApp(
                home: CheckEmailScreen(email: 'user@example.com'),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.textContaining(
              'We sent a verification link to user@example.com',
            ),
            findsOneWidget,
          );

          await tester.tap(find.text('Resend email'));
          await tester.pumpAndSettle();

          final captured = verify(
            () => mockAppAuth.authorizeAndExchangeCode(captureAny()),
          ).captured;
          final request = captured.single as AuthorizationTokenRequest;
          expect(request.additionalParameters, {
            'prompt': 'create',
            'login_hint': 'user@example.com',
          });
        },
      );
    },
  );
}

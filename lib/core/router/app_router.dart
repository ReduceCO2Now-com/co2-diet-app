import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/features/auth/screens/auth_screen.dart';
import 'package:co2diet/features/auth/screens/check_email_screen.dart';
import 'package:co2diet/features/backup/screens/backup_restore_screen.dart';
import 'package:co2diet/features/barcode_scan/screens/barcode_scan_screen.dart';
import 'package:co2diet/features/barcode_scan/screens/methodology_screen.dart';
import 'package:co2diet/features/co2_settings/screens/co2_settings_screen.dart';
import 'package:co2diet/features/dashboard/screens/placeholder_dashboard_screen.dart';
import 'package:co2diet/features/data_analysis/screens/data_analysis_screen.dart';
import 'package:co2diet/features/data_analysis/widgets/analysis_metric.dart';
import 'package:co2diet/features/food_search/screens/food_search_screen.dart';
import 'package:co2diet/features/legal/screens/consent_history_screen.dart';
import 'package:co2diet/features/legal/screens/legal_consent_screen.dart';
import 'package:co2diet/features/legal/screens/legal_document_screen.dart';
import 'package:co2diet/features/legal/screens/legal_hub_screen.dart';
import 'package:co2diet/features/my_foods/screens/custom_food_form_screen.dart';
import 'package:co2diet/features/my_foods/screens/my_foods_screen.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:co2diet/features/onboarding/screens/onboarding_carousel_screen.dart';
import 'package:co2diet/features/onboarding/screens/splash_screen.dart';
import 'package:co2diet/features/onboarding/screens/welcome_screen.dart';
import 'package:co2diet/features/profile/screens/profile_screen.dart';
import 'package:co2diet/features/reference_data/screens/reference_data_screen.dart';
import 'package:co2diet/features/settings/screens/settings_screen.dart';
import 'package:co2diet/features/weight/screens/weight_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Parses the `doc=` query-param slug used throughout the Legal Hub /
/// Legal Consent flow (Plans 06-07/06-08) back into a [LegalDocId].
///
/// `LegalDocId.name` is camelCase for `healthDisclaimer`, but every
/// existing caller (`LegalHubScreen`'s private `_LegalDocRouteSlug`
/// extension, `LegalConsentScreen`'s `context.push` calls) already
/// committed to the snake_case slug `health_disclaimer` — this mirrors
/// that convention rather than `LegalDocId.values.byName`, which would
/// silently 404 on the health-disclaimer deep link. Falls back to
/// [LegalDocId.terms] on an absent/malformed slug, matching the
/// `firstWhereOrNull`-with-safe-fallback pattern used for
/// `AnalysisMetric`/`MealSlot` deep links (T-05-18-01 precedent).
LegalDocId _legalDocIdFromSlug(String? slug) {
  switch (slug) {
    case 'terms':
      return LegalDocId.terms;
    case 'privacy':
      return LegalDocId.privacy;
    case 'health_disclaimer':
      return LegalDocId.healthDisclaimer;
    case 'impressum':
      return LegalDocId.impressum;
    default:
      return LegalDocId.terms;
  }
}

/// Global navigator key captured once at app start so non-widget code (the
/// `NotificationService`'s tap handler, which runs with no `BuildContext`
/// and no Riverpod `ref` -- see RESEARCH.md Pattern 4) can still navigate.
///
/// Passed into [GoRouter]'s `navigatorKey` below; consumed via
/// `rootNavigatorKey.currentState?.context`.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Bottom navigation shell that wraps the three main branches.
///
/// `/profile` is reachable both as the onboarding flow's Profile Setup
/// step (before the Carousel/`completeOnboarding()` has ever run) and as
/// the shell's normal Profile tab post-onboarding -- both share this same
/// [AppShell] wrapper. Found via 06-10 manual real-device verification:
/// the bottom nav bar rendered unconditionally, so a pre-onboarding user
/// on Profile Setup could tap "Dashboard"/"Settings" directly, bypassing
/// the mandatory Carousel step entirely (skipping the only call site that
/// invokes `completeOnboarding()`) -- the top-level redirect guard then
/// correctly bounced them to `/splash` since onboarding was never actually
/// completed, which read as an unexplained "loop" rather than the
/// guard doing its job. Hiding the bar until [onboardingGateProvider] is
/// true removes the shortcut instead of trying to explain around it.
class AppShell extends ConsumerWidget {
  /// Creates [AppShell] with the given [StatefulNavigationShell].
  const AppShell({required this.shell, super.key});

  /// The [StatefulNavigationShell] provided by go_router.
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasOnboarded = ref.watch(onboardingGateProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: shell,
      bottomNavigationBar: !hasOnboarded
          ? null
          : NavigationBar(
              backgroundColor: colorScheme.surface,
              indicatorColor: AppColors.primaryContainer.withValues(
                alpha: 0.24,
              ),
              selectedIndex: shell.currentIndex,
              onDestinationSelected: (index) => shell.goBranch(
                index,
                initialLocation: index == shell.currentIndex,
              ),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
    );
  }
}

/// Riverpod provider for the app's [GoRouter] instance.
///
/// keepAlive: true — the router must persist for the full app lifetime.
/// go_router 17.x uses [StatefulShellRoute.indexedStack] for persistent
/// bottom-navigation state across tab switches.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    // Single top-level enforcement point for "consent is never skippable"
    // (T-06-09-01): evaluated on every navigation attempt, including
    // `initialLocation` itself, so a crafted deep link into `/dashboard`
    // (or any other post-onboarding route) before Legal Consent is
    // accepted is always redirected back to `/splash`.
    redirect: (context, state) {
      final hasOnboarded = ref.read(onboardingGateProvider);

      const onboardingOnlyRoutes = [
        '/splash',
        '/welcome',
        '/legal-consent',
        '/onboarding-carousel',
      ];
      // '/legal-hub' covers '/legal-hub', '/legal-hub/document', and
      // '/legal-hub/consent-history' via the startsWith check below --
      // LegalConsentScreen's "View Terms/Privacy/Disclaimer" links push
      // into '/legal-hub/document' before onboarding completes, and must
      // not be redirected back to '/splash' (bug found in 06-10 manual
      // verification: the pre-onboarding allowlist omitted this prefix
      // entirely, bouncing every "View..." tap to the start of onboarding).
      const allowedPreOnboarding = [
        ...onboardingOnlyRoutes,
        '/profile',
        '/legal-hub',
      ];

      if (!hasOnboarded &&
          !allowedPreOnboarding.any(
            (route) => state.matchedLocation.startsWith(route),
          )) {
        return '/splash';
      }

      // Deliberately does NOT include '/profile' here — a completed user
      // must still be able to visit the Profile bottom-nav tab normally.
      if (hasOnboarded &&
          onboardingOnlyRoutes.any(
            (route) => state.matchedLocation.startsWith(route),
          )) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Onboarding flow — top-level, outside the shell (no bottom nav).
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/legal-consent',
        builder: (context, state) => const LegalConsentScreen(),
      ),
      GoRoute(
        path: '/onboarding-carousel',
        builder: (context, state) => const OnboardingCarouselScreen(),
      ),
      GoRoute(
        path: '/legal-hub',
        builder: (context, state) => const LegalHubScreen(),
      ),
      GoRoute(
        path: '/legal-hub/document',
        // `_legalDocIdFromSlug` parses the snake_case `doc=` slug
        // convention already committed by LegalHubScreen/
        // LegalConsentScreen — an absent/malformed `doc` query param
        // never crashes, it falls back to Terms.
        builder: (context, state) => LegalDocumentScreen(
          docId: _legalDocIdFromSlug(state.uri.queryParameters['doc']),
        ),
      ),
      GoRoute(
        path: '/legal-hub/consent-history',
        builder: (context, state) => const ConsentHistoryScreen(),
      ),
      // Top-level route — covers the bottom nav bar (not nested in the shell).
      GoRoute(
        path: '/food-search',
        // Slot pre-selection contract (Plan 05-18): shared by the
        // Dashboard's per-slot quick-log buttons and
        // `NotificationService.scheduleMealReminder`'s notification-tap
        // payload (`/food-search?slot=<slot>`). `firstWhereOrNull` falls
        // back to `null` (auto-detect) on an absent/malformed `slot` query
        // param — never crashes on a bad deep link (T-05-18-01).
        builder: (context, state) => FoodSearchScreen(
          initialSlot: MealSlot.values.firstWhereOrNull(
            (s) => s.name == state.uri.queryParameters['slot'],
          ),
        ),
      ),
      GoRoute(
        path: '/barcode-scan',
        builder: (context, state) => const BarcodeScanScreen(),
      ),
      GoRoute(
        path: '/methodology',
        builder: (context, state) => const MethodologyScreen(),
      ),
      GoRoute(
        path: '/co2-settings',
        builder: (context, state) => const Co2SettingsScreen(),
      ),
      GoRoute(
        path: '/weight-tracking',
        builder: (context, state) => const WeightScreen(),
      ),
      GoRoute(
        path: '/data-analysis',
        // `AnalysisMetric` is `DataAnalysisScreen`'s own self-contained enum
        // (distinct from Dashboard's `DashboardMetric`) -- falls back to
        // `co2` when the `metric` query param is absent/unrecognized, never
        // crashing on a malformed deep link (T-05-18-01).
        builder: (context, state) => DataAnalysisScreen(
          initialMetric:
              AnalysisMetric.values.firstWhereOrNull(
                (m) => m.name == state.uri.queryParameters['metric'],
              ) ??
              AnalysisMetric.co2,
        ),
      ),
      GoRoute(
        path: '/backup-restore',
        builder: (context, state) => const BackupRestoreScreen(),
      ),
      GoRoute(
        path: '/reference-data',
        builder: (context, state) => const ReferenceDataScreen(),
      ),
      GoRoute(
        path: '/custom-food-stub',
        // Route contract (Plan 04-08): see CustomFoodFormScreen's doc
        // comment for the five mutually-exclusive query-param variants.
        // Path name kept as `/custom-food-stub` — BarcodeScanNoMatchScreen
        // already depends on `/custom-food-stub?barcode=...` unchanged.
        builder: (context, state) => CustomFoodFormScreen(
          barcode: state.uri.queryParameters['barcode'],
          name: state.uri.queryParameters['name'],
          overrideOf: state.uri.queryParameters['overrideOf'],
          overrideOfSource: state.uri.queryParameters['overrideOfSource'],
          userFoodId: state.uri.queryParameters['userFoodId'],
        ),
      ),
      GoRoute(
        path: '/my-foods',
        builder: (context, state) => const MyFoodsScreen(),
      ),
      // Account Mode entry point (Plan 07-06) — reachable from Settings'
      // AccountSection sign-in/create-account row (07-05-SUMMARY.md: "Plan
      // 07-06 owns adding the /auth and /check-email routes").
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/check-email',
        builder: (context, state) => CheckEmailScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) =>
                    const PlaceholderDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

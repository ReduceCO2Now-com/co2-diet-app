import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/features/profile/screens/profile_screen.dart';
import 'package:co2diet/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Placeholder dashboard screen.
///
/// Replaced with a real implementation in Phase 5.
class PlaceholderDashboardScreen extends StatelessWidget {
  /// Creates the placeholder dashboard screen.
  const PlaceholderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Text(
          'Dashboard coming in Phase 5',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

/// Bottom navigation shell that wraps the three main branches.
class AppShell extends StatelessWidget {
  /// Creates [AppShell] with the given [StatefulNavigationShell].
  const AppShell({required this.shell, super.key});

  /// The [StatefulNavigationShell] provided by go_router.
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: shell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer.withValues(alpha: 0.24),
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
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
    initialLocation: '/profile',
    routes: [
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

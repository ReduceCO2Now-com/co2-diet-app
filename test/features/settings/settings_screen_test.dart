// Plan 05-18: SettingsScreen gains three new entry points (CO2 Calculation
// Settings, Weight Tracking, Backup & Restore) plus the embedded meal
// reminder settings section (NOTIF-01's settings-location decision).
import 'package:co2diet/core/di/notification_providers.dart';
import 'package:co2diet/domain/entities/notification_prefs.dart';
import 'package:co2diet/domain/repositories/i_notification_prefs_repository.dart';
import 'package:co2diet/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationPrefsRepository extends Mock
    implements INotificationPrefsRepository {}

Widget _wrap(Widget dashboard) {
  final router = GoRouter(
    initialLocation: '/settings',
    routes: [
      GoRoute(path: '/settings', builder: (context, state) => dashboard),
      GoRoute(
        path: '/co2-settings',
        builder: (context, state) => const Text('co2-settings-screen'),
      ),
      GoRoute(
        path: '/weight-tracking',
        builder: (context, state) => const Text('weight-tracking-screen'),
      ),
      GoRoute(
        path: '/backup-restore',
        builder: (context, state) => const Text('backup-restore-screen'),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  Future<void> pumpSettings(WidgetTester tester) async {
    // Tall test viewport -- the new tiles + embedded 4-row
    // MealReminderSettingsSection need more vertical space than the
    // default 800x600 test surface (05-12 precedent).
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockPrefsRepo = _MockNotificationPrefsRepository();
    when(
      mockPrefsRepo.getPrefs,
    ).thenAnswer((_) async => const NotificationPrefs());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationPrefsRepositoryProvider.overrideWithValue(
            mockPrefsRepo,
          ),
        ],
        child: _wrap(const SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists CO2 Calculation Settings, Weight Tracking, and '
      'Backup & Restore, and embeds the meal reminder section', (
    tester,
  ) async {
    await pumpSettings(tester);

    expect(find.text('CO2 Calculation Settings'), findsOneWidget);
    expect(find.text('Weight Tracking'), findsOneWidget);
    expect(find.text('Backup & Restore'), findsOneWidget);
    expect(find.text('Meal Reminders'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
  });

  testWidgets('tapping CO2 Calculation Settings navigates to /co2-settings', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(find.text('CO2 Calculation Settings'));
    await tester.pumpAndSettle();

    expect(find.text('co2-settings-screen'), findsOneWidget);
  });

  testWidgets('tapping Weight Tracking navigates to /weight-tracking', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Weight Tracking'));
    await tester.pumpAndSettle();

    expect(find.text('weight-tracking-screen'), findsOneWidget);
  });

  testWidgets('tapping Backup & Restore navigates to /backup-restore', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Backup & Restore'));
    await tester.pumpAndSettle();

    expect(find.text('backup-restore-screen'), findsOneWidget);
  });
}

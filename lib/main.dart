import 'package:co2diet/app.dart';
import 'package:co2diet/core/assets/first_launch_extractor.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/remote/off_api_client.dart';
import 'package:co2diet/domain/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure OFF API User-Agent before any search (T-02-04-05).
  // Must be called once before runApp — plan 02-04.
  configureOff();

  // Decompress the bundled off_reference.sqlite.gz to the app documents
  // directory on first launch. Non-fatal: app runs in local-only mode if the
  // asset is absent during development (off_reference.sqlite.gz not yet
  // committed to the repo).
  String? offRefPath;
  try {
    offRefPath = await ensureOffReferenceDb();
  } on Exception catch (e) {
    debugPrint('off_reference.sqlite not available: $e');
  }

  // Initialize the notification plugin (timezone config + platform
  // registration) before runApp — mirrors configureOff()/
  // ensureOffReferenceDb()'s non-fatal try/on Exception pattern so a
  // simulator/CI environment without notification support never crashes
  // startup. This plugin instance is separate from the one the
  // notificationServiceProvider constructs (Plan 05-08) — both share the
  // same underlying platform method channel, so only one `initialize()`
  // call is needed to register the tap-response callback.
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  final notificationService = NotificationService(notificationsPlugin);
  try {
    await notificationService.initialize();
  } on Exception catch (e) {
    debugPrint('NotificationService initialization failed: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        if (offRefPath != null)
          offRefPathProvider.overrideWithValue(offRefPath),
      ],
      child: const Co2DietApp(),
    ),
  );

  // Cold-start-via-notification-tap handling (RESEARCH.md Pattern 4): warm
  // taps are handled by `onDidReceiveNotificationResponse` inside
  // `NotificationService.initialize()`; a cold start needs this separate
  // check because the plugin has no live callback registered yet at launch.
  try {
    final launchDetails = await notificationsPlugin
        .getNotificationAppLaunchDetails();
    final payload = launchDetails?.notificationResponse?.payload;
    if ((launchDetails?.didNotificationLaunchApp ?? false) &&
        payload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.navigateToPayload(payload);
      });
    }
  } on Exception catch (e) {
    debugPrint('Cold-start notification launch check failed: $e');
  }
}

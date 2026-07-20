import 'package:co2diet/app.dart';
import 'package:co2diet/core/assets/first_launch_extractor.dart';
import 'package:co2diet/core/di/providers.dart';
import 'package:co2diet/data/remote/off_api_client.dart';
import 'package:flutter/material.dart';
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

  runApp(
    ProviderScope(
      overrides: [
        if (offRefPath != null)
          offRefPathProvider.overrideWithValue(offRefPath),
      ],
      child: const Co2DietApp(),
    ),
  );
}

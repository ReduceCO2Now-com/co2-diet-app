import 'package:co2diet/core/router/app_router.dart';
import 'package:co2diet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget.
///
/// Uses [MaterialApp.router] with go_router provided by [appRouterProvider].
/// Wired in Plan 01-05.
class Co2DietApp extends ConsumerWidget {
  /// Creates the root [Co2DietApp] widget.
  const Co2DietApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CO₂ Diet',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}

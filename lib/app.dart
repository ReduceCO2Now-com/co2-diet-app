import 'package:co2diet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Root application widget.
///
/// Uses a plain [MaterialApp] for Phase 1 scaffolding.
/// MaterialApp.router with go_router will be wired in Plan 01-05.
class Co2DietApp extends StatelessWidget {
  /// Creates the root [Co2DietApp] widget.
  const Co2DietApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CO2 Diet',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      home: const Scaffold(
        body: Center(
          child: Text('CO2 Diet'),
        ),
      ),
    );
  }
}

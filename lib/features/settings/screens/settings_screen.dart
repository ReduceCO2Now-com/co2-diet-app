import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';

/// Settings screen with the open source license disclosure (PRIV-07).
///
/// Accessible from the Settings tab in the bottom navigation bar.
class SettingsScreen extends StatelessWidget {
  /// Creates the [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Open source licenses'),
            subtitle: const Text('View all package licenses'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'CO₂ Diet',
              applicationVersion: '0.1.0',
              applicationLegalese: '© 2026 ReduceCO2Now',
            ),
          ),
        ],
      ),
    );
  }
}

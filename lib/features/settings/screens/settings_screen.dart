import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/features/notifications/widgets/meal_reminder_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings screen with the open source license disclosure (PRIV-07), plus
/// entry points into every Wave 5/6 standalone screen this plan wires in
/// (CO2 Calculation Settings, Weight Tracking, Backup & Restore) and the
/// embedded meal-reminder settings section (NOTIF-01's settings-location
/// decision: "meal-reminder config lives in the existing General Settings
/// screen").
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
            leading: const Icon(Icons.search),
            title: const Text('Search foods'),
            subtitle: const Text('Browse the food catalog'),
            onTap: () => context.push('/food-search'),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('My Foods'),
            subtitle: const Text('Custom foods and personal overrides'),
            onTap: () => context.push('/my-foods'),
          ),
          ListTile(
            leading: const Icon(Icons.eco_outlined),
            title: const Text('CO2 Calculation Settings'),
            subtitle: const Text('Personalize your CO2 footprint estimate'),
            onTap: () => context.push('/co2-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight_outlined),
            title: const Text('Weight Tracking'),
            subtitle: const Text('Log weigh-ins, goal, and reminders'),
            onTap: () => context.push('/weight-tracking'),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Export, backup, and restore your data'),
            onTap: () => context.push('/backup-restore'),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              0,
            ),
            child: MealReminderSettingsSection(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Legal & Privacy'),
            subtitle: const Text(
              'Terms, Privacy Policy, consent history, and your rights',
            ),
            onTap: () => context.push('/legal-hub'),
          ),
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

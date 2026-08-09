import 'package:flutter/material.dart';

/// Small Dashboard indicator showing which mode the app is running in
/// (CONTEXT.md: "Mode indicator wording unchanged from spec").
///
/// Wired to real auth state as of this plan (07-08) --
/// `placeholder_dashboard_screen.dart`'s call site now passes
/// `isLocalMode: ref.watch(authProvider) is! AuthAuthenticated`. Account
/// Mode's copy deliberately does NOT claim sync exists yet -- zero data
/// movement happens between Local Mode and Account Mode this phase (07-
/// CONTEXT.md's locked wording), so the old placeholder `'Synced across
/// devices'` copy would have been a false claim.
class ModeIndicator extends StatelessWidget {
  /// Creates a [ModeIndicator].
  const ModeIndicator({this.isLocalMode = true, super.key});

  /// Whether the app is running in Local Mode (`true`) or Account Mode
  /// (`false`).
  final bool isLocalMode;

  @override
  Widget build(BuildContext context) {
    final label = isLocalMode
        ? 'Stored on this device'
        : 'Account Mode: Data still stored locally (sync coming soon)';
    final icon = isLocalMode ? Icons.phone_iphone : Icons.cloud_sync_outlined;

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

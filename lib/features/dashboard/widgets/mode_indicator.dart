import 'package:flutter/material.dart';

/// Small Dashboard indicator showing which mode the app is running in
/// (CONTEXT.md: "Mode indicator wording unchanged from spec").
///
/// Only Local Mode exists until Phase 7 wires Account Mode -- [isLocalMode]
/// defaults to `true` so this widget compiles correctly against Phase 7's
/// future Account Mode state (`'Synced across devices.'`) without needing a
/// rewrite then.
class ModeIndicator extends StatelessWidget {
  /// Creates a [ModeIndicator].
  const ModeIndicator({this.isLocalMode = true, super.key});

  /// Whether the app is running in Local Mode (`true`, the only mode that
  /// exists today) or Account Mode (`false`, Phase 7).
  final bool isLocalMode;

  @override
  Widget build(BuildContext context) {
    final label = isLocalMode
        ? 'Stored on this device'
        : 'Synced across devices';
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

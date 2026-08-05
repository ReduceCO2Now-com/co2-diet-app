import 'package:flutter/material.dart';

/// The dismissible "Complete your CO₂ profile" prompt card, shown at the
/// bottom of the Dashboard (below the meal list, per CONTEXT.md's placement
/// decision) only when `Co2Settings.dataQuality == 'basic'`.
///
/// Renders `SizedBox.shrink()` when [show] is `false` -- the parent screen
/// owns the `dataQuality`/dismissed-state check and passes the resolved
/// [show] flag in.
class Co2ProfilePromptCard extends StatelessWidget {
  /// Creates a [Co2ProfilePromptCard].
  const Co2ProfilePromptCard({
    required this.show,
    required this.onDismiss,
    required this.onTap,
    super.key,
  });

  /// Whether this card should render at all.
  final bool show;

  /// Called when the user taps the dismiss (X) icon button.
  final VoidCallback onDismiss;

  /// Called when the user taps the card body -- navigates to CO2
  /// Calculation Settings (wired by Plan 05-18).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                // Explicit color -- without one, this Text fell back to
                // Theme.of(context)'s dark-mode-aware default (light) while
                // sitting on this card's own hardcoded-light Material
                // background, rendering invisible in system dark mode
                // (found via 06-10 real-device verification).
                child: Text(
                  'Complete your CO₂ profile for better estimates',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onDismiss,
                tooltip: 'Dismiss',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

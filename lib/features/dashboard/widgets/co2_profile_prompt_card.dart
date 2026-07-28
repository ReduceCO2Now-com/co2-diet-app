import 'package:co2diet/core/theme/color_tokens.dart';
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

    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Complete your CO₂ profile for better estimates',
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

import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';

/// A pill-shaped chip showing how complete the user's CO2 Calculation
/// Settings are, sourced from `Co2Settings.dataQuality`.
///
/// This is purely presentational — it renders the classification passed in
/// via [dataQuality] and does not recompute it itself.
///
/// Distinct from `ConfidenceChip`: that widget communicates a *per-food*
/// CO₂ estimate's confidence band (high/medium), while this widget
/// communicates how many *personal settings* fields the user has filled
/// in. Per CONTEXT.md these are "a different concept" and intentionally
/// use separate widgets rather than sharing one.
class DataQualityIndicator extends StatelessWidget {
  /// Creates a [DataQualityIndicator] for the given [dataQuality]
  /// classification (`'basic'`, `'good'`, or `'detailed'`).
  const DataQualityIndicator({
    required this.dataQuality,
    super.key,
  });

  /// The data quality classification — `'basic'`, `'good'`, or `'detailed'`,
  /// matching `Co2Settings.dataQuality`.
  final String dataQuality;

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = switch (dataQuality) {
      'good' => ('Good Estimate', AppColors.warningAmber, Colors.black87),
      'detailed' => (
          'Detailed Estimate',
          AppColors.primaryContainer,
          Colors.white,
        ),
      _ => (
          'Basic Estimate',
          Theme.of(context).colorScheme.surfaceContainerHigh,
          Colors.black87,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insights_outlined, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

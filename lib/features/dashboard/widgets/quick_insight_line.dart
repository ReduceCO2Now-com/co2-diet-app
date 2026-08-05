import 'package:flutter/material.dart';

/// Displays a single, pre-computed "most notable metric today" sentence on
/// the Dashboard, in factual (non-judgmental) tone -- e.g. verbatim from
/// CONTEXT.md: "Lunch contributed most CO₂ today."
///
/// This widget is a pure display component: the "which of CO2/calories/
/// protein is most notable today, plus its contributing meal slot" selection
/// logic lives in Plan 05-18's Dashboard-assembly wiring, which has access
/// to the user's targets and goal. Renders nothing when [insightText] is
/// `null` (nothing notable to show yet, e.g. no meals logged today).
class QuickInsightLine extends StatelessWidget {
  /// Creates a [QuickInsightLine].
  const QuickInsightLine({required this.insightText, super.key});

  /// The pre-computed insight sentence, or `null` to render nothing.
  final String? insightText;

  @override
  Widget build(BuildContext context) {
    if (insightText == null) return const SizedBox.shrink();
    return Text(
      insightText!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

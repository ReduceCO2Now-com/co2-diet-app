import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// Renders `InsightsTimelineRuleEngine.evaluate`'s output (INS-03) as a
/// simple chronological list of neutral observations.
///
/// Rendered ONLY inside `DataAnalysisScreen`. Renders nothing when
/// [observations] is empty — the rule engine returning `[]` means no
/// pattern threshold was met, and this widget never fabricates a line to
/// fill the space.
class InsightsTimeline extends StatelessWidget {
  /// Creates an [InsightsTimeline] widget for [observations].
  const InsightsTimeline({required this.observations, super.key});

  /// Factual, non-judgmental observation strings, typically from
  /// `InsightsTimelineRuleEngine.evaluate`.
  final List<String> observations;

  @override
  Widget build(BuildContext context) {
    if (observations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final observation in observations)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            child: Text(
              observation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

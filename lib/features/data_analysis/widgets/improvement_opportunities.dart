import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/domain/services/improvement_opportunity_finder.dart';
import 'package:flutter/material.dart';

/// Renders [ImprovementOpportunityFinder]'s suggestions (CO2-06) as
/// factual, non-judgmental cards.
///
/// Rendered ONLY inside `DataAnalysisScreen` — never the Dashboard, never
/// a notification (05-CONTEXT.md). Renders nothing when [opportunities] is
/// empty rather than an empty-state message, since the absence of a
/// suggestion here is a normal, unremarkable outcome (not a state the user
/// needs to be told about), unlike e.g. `RankedContributorsList`'s
/// "No contributors logged yet today" empty state.
class ImprovementOpportunities extends StatelessWidget {
  /// Creates an [ImprovementOpportunities] widget for [opportunities].
  const ImprovementOpportunities({required this.opportunities, super.key});

  /// The suggestions to render, typically from
  /// `ImprovementOpportunityFinder.findOpportunities`.
  final List<ImprovementOpportunity> opportunities;

  @override
  Widget build(BuildContext context) {
    if (opportunities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final opportunity in opportunities)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.stackGap),
                child: Text(
                  "Replacing today's ${opportunity.originalName} with "
                  '${opportunity.alternativeName} would save approximately '
                  '${opportunity.deltaKg.toStringAsPrecision(2)} kg CO2 '
                  'today.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

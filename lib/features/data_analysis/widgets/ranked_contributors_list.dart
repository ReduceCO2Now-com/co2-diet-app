import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:co2diet/features/data_analysis/widgets/analysis_metric.dart';
import 'package:flutter/material.dart';

/// Ranks [MealEntry] items by whichever metric (co2/calories/protein) is
/// passed in, descending -- one reusable component, per-metric data, per
/// CONTEXT.md's "one reusable ranked-list component" decision.
class RankedContributorsList extends StatelessWidget {
  /// Creates a [RankedContributorsList] for [entries], ranked by [metric].
  const RankedContributorsList({
    required this.entries,
    required this.metric,
    super.key,
  });

  /// The entries to rank (typically today's entries).
  final List<MealEntry> entries;

  /// Which metric to rank by -- one of co2/calories/protein.
  final AnalysisMetric metric;

  double? _valueFor(MealEntry entry) {
    if (!entry.unit.isWeightBased) return null;
    final scaled = entry.scaled(entry.quantity);
    return switch (metric) {
      AnalysisMetric.co2 => scaled.co2e,
      AnalysisMetric.calories => scaled.calories,
      AnalysisMetric.protein => scaled.protein,
      AnalysisMetric.weight => null,
    };
  }

  String _formatValue(double value) => switch (metric) {
    AnalysisMetric.co2 => '~${value.toStringAsPrecision(2)} kg CO₂e',
    AnalysisMetric.calories => '${value.round()} kcal',
    AnalysisMetric.protein => '${value.round()}g',
    AnalysisMetric.weight => '—',
  };

  @override
  Widget build(BuildContext context) {
    final ranked =
        entries.where((entry) => _valueFor(entry) != null).toList()
          ..sort((a, b) => _valueFor(b)!.compareTo(_valueFor(a)!));

    if (ranked.isEmpty) {
      return Text(
        'No contributors logged yet today',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ranked.length,
      itemBuilder: (context, index) {
        final entry = ranked[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(entry.productNameSnapshot),
          trailing: Text(_formatValue(_valueFor(entry)!)),
        );
      },
    );
  }
}

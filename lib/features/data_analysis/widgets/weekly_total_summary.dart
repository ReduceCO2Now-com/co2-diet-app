import 'package:co2diet/domain/services/daily_totals_calculator.dart';
import 'package:co2diet/features/barcode_scan/utils/co2_formatter.dart';
import 'package:flutter/material.dart';

/// Displays a single explicit "this week" figure per metric (CO2/calories/
/// protein) -- distinct from, and in addition to, the day-by-day trend
/// chart. Satisfies CO2-02's "weekly total" success criterion explicitly.
///
/// A pure presentation component: [totals] is a pre-computed [DailyTotals]
/// -- the caller pools the trailing 7 days' entries into one list and
/// calls `DailyTotalsCalculator.compute()` once. This widget does no
/// aggregation itself.
class WeeklyTotalSummary extends StatelessWidget {
  /// Creates a [WeeklyTotalSummary] for the pre-computed [totals].
  const WeeklyTotalSummary({required this.totals, super.key});

  /// The trailing-7-day pooled [DailyTotals].
  final DailyTotals totals;

  @override
  Widget build(BuildContext context) {
    final co2Text = formatCo2Display(totals.co2e) ?? '—';
    final calText = totals.calories != null
        ? '${totals.calories!.round()} kcal'
        : '—';
    final proteinText = totals.protein != null
        ? '${totals.protein!.round()}g protein'
        : '—';

    return Text(
      'This week: $co2Text | $calText | $proteinText',
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

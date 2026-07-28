import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// The three metrics the Dashboard's 7-day trend sparkline can plot
/// (DASH-08's "switchable single-metric sparkline").
enum DashboardMetric {
  /// CO₂ footprint.
  co2,

  /// Calorie intake.
  calories,

  /// Protein intake.
  protein,
}

/// A compact, axis-free 7-day `fl_chart` sparkline (DASH-08) with a
/// segmented control that switches which of [DashboardMetric.co2],
/// [DashboardMetric.calories], or [DashboardMetric.protein] is plotted.
///
/// This is a controlled component -- [selectedMetric]/[onMetricChanged] are
/// owned by the parent screen (matching this codebase's Riverpod-driven
/// state conventions) rather than local widget state, since the parent
/// needs to read the currently-selected metric anyway for the "tap opens
/// Data Analysis pre-set to this metric" behavior (DASH-08).
///
/// Tapping anywhere on the card (not the chart's own touch handling)
/// invokes [onTap] -- the chart itself has `lineTouchData:
/// LineTouchData(enabled: false)` since this is a compact
/// card-tap-to-navigate pattern, not an interactive tooltip chart (that
/// richer interaction belongs to the Weight/Data-Analysis charts, Plans
/// 05-13/05-15).
class TrendSparkline extends StatelessWidget {
  /// Creates a [TrendSparkline].
  const TrendSparkline({
    required this.selectedMetric,
    required this.onMetricChanged,
    required this.spots,
    required this.onTap,
    super.key,
  });

  /// Which metric is currently plotted.
  final DashboardMetric selectedMetric;

  /// Called when the user switches the segmented control.
  final ValueChanged<DashboardMetric> onMetricChanged;

  /// 7-day spot data for each metric (7 points each).
  final Map<DashboardMetric, List<FlSpot>> spots;

  /// Called when the card (outside the segmented control) is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currentSpots = spots[selectedMetric] ?? const <FlSpot>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<DashboardMetric>(
          segments: const [
            ButtonSegment(value: DashboardMetric.co2, label: Text('CO₂')),
            ButtonSegment(
              value: DashboardMetric.calories,
              label: Text('Calories'),
            ),
            ButtonSegment(
              value: DashboardMetric.protein,
              label: Text('Protein'),
            ),
          ],
          selected: {selectedMetric},
          onSelectionChanged: (selection) => onMetricChanged(selection.first),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 80,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: currentSpots,
                    isCurved: true,
                    color: AppColors.primary,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

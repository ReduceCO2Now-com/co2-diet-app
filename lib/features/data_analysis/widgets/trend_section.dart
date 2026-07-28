import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/features/data_analysis/widgets/analysis_metric.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetches [rangeDays] worth of daily [FlSpot] data for [metric]. The
/// screen assembling [TrendSection] owns the actual query (against
/// `MealEntryRepository`) -- this callback keeps [TrendSection] a pure
/// presentation component with no direct repository dependency.
typedef TrendSpotFetcher =
    Future<List<FlSpot>> Function({
      required AnalysisMetric metric,
      required int rangeDays,
    });

/// A richer, interactive `fl_chart` `LineChart` (visible axes, touch
/// tooltip -- RESEARCH.md Pattern 3's interactive-chart shape minus the
/// goal `HorizontalLine`, which is Weight-only) plotting one of
/// CO2/Calories/Protein over a 7d/30d range.
///
/// The metric segmented control and the range segmented control are two
/// independent local-state values -- changing one never resets the other.
/// [initialMetric] pre-sets the metric toggle (falling back to
/// [AnalysisMetric.co2] if given [AnalysisMetric.weight], since this
/// widget only ever plots nutrition metrics -- Weight mode uses a
/// completely separate chart, `WeightChart`).
class TrendSection extends ConsumerStatefulWidget {
  /// Creates a [TrendSection] pre-set to [initialMetric], fetching spot
  /// data via [fetchSpots].
  const TrendSection({
    required this.initialMetric,
    required this.fetchSpots,
    super.key,
  });

  /// Which metric to pre-select (co2/calories/protein).
  final AnalysisMetric initialMetric;

  /// Callback resolving spot data for the currently selected metric+range.
  final TrendSpotFetcher fetchSpots;

  @override
  ConsumerState<TrendSection> createState() => _TrendSectionState();
}

class _TrendSectionState extends ConsumerState<TrendSection> {
  late AnalysisMetric _selectedMetric = _asNutritionMetric(
    widget.initialMetric,
  );
  int _selectedRangeDays = 7;
  Future<List<FlSpot>>? _spotsFuture;

  static AnalysisMetric _asNutritionMetric(AnalysisMetric metric) =>
      metric == AnalysisMetric.weight ? AnalysisMetric.co2 : metric;

  @override
  void initState() {
    super.initState();
    _refetch();
  }

  void _refetch() {
    setState(() {
      _spotsFuture = widget.fetchSpots(
        metric: _selectedMetric,
        rangeDays: _selectedRangeDays,
      );
    });
  }

  void _selectMetric(AnalysisMetric metric) {
    _selectedMetric = metric;
    _refetch();
  }

  void _selectRange(int rangeDays) {
    _selectedRangeDays = rangeDays;
    _refetch();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<AnalysisMetric>(
          segments: const [
            ButtonSegment(value: AnalysisMetric.co2, label: Text('CO₂')),
            ButtonSegment(
              value: AnalysisMetric.calories,
              label: Text('Calories'),
            ),
            ButtonSegment(
              value: AnalysisMetric.protein,
              label: Text('Protein'),
            ),
          ],
          selected: {_selectedMetric},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => _selectMetric(selection.first),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 7, label: Text('7d')),
            ButtonSegment(value: 30, label: Text('30d')),
          ],
          selected: {_selectedRangeDays},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => _selectRange(selection.first),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<FlSpot>>(
          future: _spotsFuture,
          builder: (context, snapshot) {
            final spots = snapshot.data ?? const <FlSpot>[];
            return SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) => touchedSpots
                          .map(
                            (spot) => LineTooltipItem(
                              spot.y.toStringAsFixed(1),
                              const TextStyle(color: Colors.white),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

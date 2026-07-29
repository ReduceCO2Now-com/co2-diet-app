import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/domain/entities/weight_entry.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:co2diet/features/weight/providers/weight_notifier.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Converts [entry]'s value to kilograms, regardless of the unit it was
/// logged in. The chart plots a single consistent unit (kg) since a goal
/// (`targetWeightKg`) is always stored in kg.
double _valueInKg(WeightEntry entry) =>
    entry.unit == WeightUnit.lb ? entry.value * 0.453592 : entry.value;

/// Interactive multi-range weight-history chart (WT-02) with an optional
/// static goal reference line (WT-03).
///
/// Range tabs (Week/Month/3 Months/Year/All, defaulting to Month) re-query
/// `WeightNotifier.entriesForRange` and re-plot. Uses RESEARCH.md Pattern 3
/// verbatim: `ExtraLinesData.horizontalLines` draws the dashed
/// target-weight line, `LineTouchData.touchTooltipData` shows values on
/// drag/tap.
///
/// No pace/projection value is ever computed or rendered here --
/// CONTEXT.md explicitly rejects it; the `HorizontalLine` is the only
/// goal-related rendering in this widget tree.
class WeightChart extends ConsumerStatefulWidget {
  /// Creates a [WeightChart].
  const WeightChart({super.key});

  @override
  ConsumerState<WeightChart> createState() => _WeightChartState();
}

class _WeightChartState extends ConsumerState<WeightChart> {
  WeightRange _selectedRange = WeightRange.thirtyDay;
  Future<List<WeightEntry>>? _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _fetchEntries();
  }

  Future<List<WeightEntry>> _fetchEntries() =>
      ref.read(weightProvider.notifier).entriesForRange(_selectedRange);

  void _selectRange(WeightRange range) {
    setState(() {
      _selectedRange = range;
      _entriesFuture = _fetchEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Re-fetch whenever the notifier's combined state changes (e.g. after
    // WeightEntryForm logs a new weigh-in via WeightNotifier.logWeight) so
    // the chart reflects the new point without a manual refresh.
    ref.listen(weightProvider, (previous, next) {
      if (next.hasValue && !identical(next.value, previous?.value)) {
        setState(() {
          _entriesFuture = _fetchEntries();
        });
      }
    });

    final targetWeightKg =
        ref.watch(weightProvider).value?.settings.targetWeightKg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<WeightRange>(
          segments: const [
            ButtonSegment(value: WeightRange.sevenDay, label: Text('Week')),
            ButtonSegment(value: WeightRange.thirtyDay, label: Text('Month')),
            ButtonSegment(
              value: WeightRange.ninetyDay,
              label: Text('3 Months'),
            ),
            ButtonSegment(value: WeightRange.oneYear, label: Text('Year')),
            ButtonSegment(value: WeightRange.all, label: Text('All')),
          ],
          selected: {_selectedRange},
          showSelectedIcon: false,
          onSelectionChanged: (selected) => _selectRange(selected.first),
        ),
        const SizedBox(height: AppSpacing.stackGap),
        FutureBuilder<List<WeightEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            final entries = snapshot.data ?? const <WeightEntry>[];
            final spots = [
              for (var i = 0; i < entries.length; i++)
                FlSpot(i.toDouble(), _valueInKg(entries[i])),
            ];

            return SizedBox(
              height: 240,
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
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      if (targetWeightKg != null)
                        HorizontalLine(
                          y: targetWeightKg,
                          color: AppColors.onSurfaceVariant,
                          strokeWidth: 1.5,
                          dashArray: const [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            labelResolver: (line) =>
                                'Goal: ${line.y.toStringAsFixed(1)} kg',
                          ),
                        ),
                    ],
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) => touchedSpots
                          .map(
                            (spot) => LineTooltipItem(
                              '${spot.y.toStringAsFixed(1)} kg',
                              const TextStyle(color: Colors.white),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

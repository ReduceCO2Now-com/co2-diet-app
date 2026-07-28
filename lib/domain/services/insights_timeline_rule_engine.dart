import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/meal_slot.dart';
import 'package:co2diet/domain/services/daily_totals_calculator.dart';

/// ISO weekday order (1 = Monday .. 7 = Sunday), matching `DateTime.weekday`.
const List<int> _weekdayOrder = [1, 2, 3, 4, 5, 6, 7];

/// Display names for `DateTime.weekday` values.
const Map<int, String> _weekdayNames = {
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
  7: 'Sunday',
};

/// Minimum distinct occurrences of a given weekday's dinner-slot entries
/// required before that weekday is considered for the "consistently
/// higher" rule — a single one-off dinner never counts as a pattern.
/// Documented, hand-picked threshold (Claude's discretion per
/// 05-CONTEXT.md).
const int _minWeekdayDinnerOccurrences = 2;

/// The margin by which a weekday's average dinner-slot CO2e total must
/// exceed the overall average daily CO2e total (across every day in the
/// supplied window) before the weekday rule fires. 20% — comfortably above
/// day-to-day noise, documented threshold.
const double _weekdayDinnerMarginPct = 0.20;

/// Minimum distinct days of history required before the protein-target
/// rule considers firing — avoids declaring a "consistent" pattern from
/// only one or two days.
const int _minDistinctDaysForProteinRule = 4;

/// Minimum distinct days of history (with a non-null CO2e total) required
/// before the trend rule considers firing.
const int _minDistinctDaysForTrendRule = 4;

/// Minimum absolute linear-regression slope (kg CO2e per day) across the
/// window's daily totals before the trend rule considers the change
/// meaningful rather than noise.
const double _trendSlopeThresholdKgPerDay = 0.05;

/// Pure domain service (INS-03): a small, fixed, hand-authored rule set
/// producing factual pattern-observation strings from historical
/// `MealEntry` data.
///
/// Per 05-CONTEXT.md: "not a single CO2-only rule and not open-ended ML" —
/// bounded and testable, extensible in later phases by adding another
/// private `_evaluateXRule` method and appending its result. Every rule is
/// independent; [evaluate] returns `[]` when zero rules fire, never a
/// forced/fabricated observation.
class InsightsTimelineRuleEngine {
  /// Creates an [InsightsTimelineRuleEngine].
  const InsightsTimelineRuleEngine();

  /// Evaluates the fixed rule set over [historicalEntries] (typically a
  /// trailing-7-day pooled query, but this method makes no assumption
  /// about the exact window length beyond each rule's own documented
  /// minimum-days threshold).
  ///
  /// [proteinTargetG] is the user's daily protein target (from
  /// `CalcTargets.proteinGTarget`), used only by the protein rule. When
  /// `null` (no target set), the protein rule never fires — there is
  /// nothing to compare against, and fabricating a default target would
  /// violate this app's no-false-precision principle.
  ///
  /// Returns a list of factual, non-judgmental observation strings (zero,
  /// one, or all three rules may fire independently).
  List<String> evaluate(
    List<MealEntry> historicalEntries, {
    double? proteinTargetG,
  }) {
    final observations = <String>[];

    final byDate = _groupByLogDate(historicalEntries);
    if (byDate.isEmpty) return observations;

    final sortedDates = byDate.keys.toList()..sort();
    final dailyTotals = <String, DailyTotals>{
      for (final date in sortedDates)
        date: DailyTotalsCalculator.compute(byDate[date]!),
    };

    final weekdayObservation = _evaluateWeekdayDinnerRule(byDate, dailyTotals);
    if (weekdayObservation != null) observations.add(weekdayObservation);

    final proteinObservation = _evaluateProteinRule(
      dailyTotals,
      proteinTargetG,
    );
    if (proteinObservation != null) observations.add(proteinObservation);

    final trendObservation = _evaluateTrendRule(sortedDates, dailyTotals);
    if (trendObservation != null) observations.add(trendObservation);

    return observations;
  }

  /// Groups [entries] by `MealEntry.logDate`.
  Map<String, List<MealEntry>> _groupByLogDate(List<MealEntry> entries) {
    final byDate = <String, List<MealEntry>>{};
    for (final entry in entries) {
      byDate.putIfAbsent(entry.logDate, () => []).add(entry);
    }
    return byDate;
  }

  /// Rule 1: "CO2 consistently higher on {weekday} evenings" — fires when
  /// a specific weekday's average dinner-slot-only CO2e total exceeds the
  /// overall average daily CO2e total (all slots, all days) by
  /// [_weekdayDinnerMarginPct], across at least
  /// [_minWeekdayDinnerOccurrences] occurrences of that weekday.
  String? _evaluateWeekdayDinnerRule(
    Map<String, List<MealEntry>> byDate,
    Map<String, DailyTotals> dailyTotals,
  ) {
    final allDailyCo2 = dailyTotals.values
        .map((t) => t.co2e)
        .whereType<double>()
        .toList();
    if (allDailyCo2.isEmpty) return null;
    final overallAvg = allDailyCo2.reduce((a, b) => a + b) / allDailyCo2.length;
    if (overallAvg <= 0) return null;

    final dinnerCo2ByWeekday = <int, List<double>>{};
    for (final date in byDate.keys) {
      final weekday = DateTime.parse(date).weekday;
      final dinnerEntries = byDate[date]!
          .where((entry) => entry.mealSlot == MealSlot.dinner)
          .toList();
      if (dinnerEntries.isEmpty) continue;
      final dinnerTotal = DailyTotalsCalculator.compute(dinnerEntries).co2e;
      if (dinnerTotal == null) continue;
      dinnerCo2ByWeekday.putIfAbsent(weekday, () => []).add(dinnerTotal);
    }

    for (final weekday in _weekdayOrder) {
      final values = dinnerCo2ByWeekday[weekday];
      if (values == null || values.length < _minWeekdayDinnerOccurrences) {
        continue;
      }
      final avg = values.reduce((a, b) => a + b) / values.length;
      if (avg > overallAvg * (1 + _weekdayDinnerMarginPct)) {
        return 'CO2 consistently higher on ${_weekdayNames[weekday]} evenings';
      }
    }
    return null;
  }

  /// Rule 2: "Protein consistently below target on {N} days" — fires when
  /// protein total is below [proteinTargetG] on a strict majority of the
  /// distinct days present in [dailyTotals], given at least
  /// [_minDistinctDaysForProteinRule] distinct days of history.
  String? _evaluateProteinRule(
    Map<String, DailyTotals> dailyTotals,
    double? proteinTargetG,
  ) {
    if (proteinTargetG == null || proteinTargetG <= 0) return null;
    if (dailyTotals.length < _minDistinctDaysForProteinRule) return null;

    final totalDays = dailyTotals.length;
    final belowCount = dailyTotals.values
        .where((t) => t.protein != null && t.protein! < proteinTargetG)
        .length;

    if (belowCount > totalDays / 2) {
      return 'Protein consistently below target on $belowCount of the '
          'last $totalDays days';
    }
    return null;
  }

  /// Rule 3: "CO2 trending {up/down} over the trailing week" — fires when
  /// a simple linear-regression slope across the chronologically-ordered
  /// daily CO2e totals exceeds [_trendSlopeThresholdKgPerDay] in magnitude,
  /// given at least [_minDistinctDaysForTrendRule] days with a non-null
  /// CO2e total.
  String? _evaluateTrendRule(
    List<String> sortedDates,
    Map<String, DailyTotals> dailyTotals,
  ) {
    final points = <MapEntry<int, double>>[];
    for (var i = 0; i < sortedDates.length; i++) {
      final co2e = dailyTotals[sortedDates[i]]!.co2e;
      if (co2e != null) points.add(MapEntry(i, co2e));
    }
    if (points.length < _minDistinctDaysForTrendRule) return null;

    final n = points.length;
    final sumX = points.fold<double>(0, (sum, p) => sum + p.key);
    final sumY = points.fold<double>(0, (sum, p) => sum + p.value);
    final meanX = sumX / n;
    final meanY = sumY / n;

    var numerator = 0.0;
    var denominator = 0.0;
    for (final p in points) {
      final dx = p.key - meanX;
      numerator += dx * (p.value - meanY);
      denominator += dx * dx;
    }
    if (denominator == 0) return null;
    final slope = numerator / denominator;

    if (slope > _trendSlopeThresholdKgPerDay) {
      return 'CO2 trending up over the trailing week';
    } else if (slope < -_trendSlopeThresholdKgPerDay) {
      return 'CO2 trending down over the trailing week';
    }
    return null;
  }
}

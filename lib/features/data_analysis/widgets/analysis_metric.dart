/// The four metrics the Data Analysis screen (INS-01/INS-02) can be
/// pre-set to: `co2`/`calories`/`protein` drive every nutrition-facing
/// section (today's breakdown, weekly total, contributors, goal
/// comparison, trend, transparency), while `weight` (WT-05) switches the
/// screen to an entirely distinct weight-trend body.
///
/// Deliberately a screen-local, self-contained type -- NOT imported from
/// or coupled to `DashboardMetric`
/// (`lib/features/dashboard/widgets/trend_sparkline.dart`, a same-wave
/// Plan 05-11 file this plan has no `depends_on` edge on). Every widget in
/// this feature and `DataAnalysisScreen` itself uses [AnalysisMetric],
/// never `DashboardMetric`.
enum AnalysisMetric {
  /// CO₂ footprint.
  co2,

  /// Calorie intake.
  calories,

  /// Protein intake.
  protein,

  /// Body weight (WT-05) -- sources chart data from `WeightNotifier`
  /// instead of `MealEntryRepository`.
  weight,
}

/// Display-facing labels for [AnalysisMetric], matching `MealSlot`/
/// `PortionUnit`'s established enum-plus-display-extension convention.
extension AnalysisMetricDisplay on AnalysisMetric {
  /// Human-readable label for this metric (e.g. `'CO₂'`, `'Weight'`).
  String get displayLabel => switch (this) {
    AnalysisMetric.co2 => 'CO₂',
    AnalysisMetric.calories => 'Calories',
    AnalysisMetric.protein => 'Protein',
    AnalysisMetric.weight => 'Weight',
  };
}

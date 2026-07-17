import 'package:freezed_annotation/freezed_annotation.dart';

part 'calc_targets.freezed.dart';

/// Computed macro and calorie targets for a user.
///
/// All nutrient fields are nullable: a `null` value means a required
/// anthropometric input is missing and the UI should display `—`
/// (per D-07: no fake precision, no population-average fallbacks).
///
/// Override flags (per D-06) indicate whether the corresponding field
/// was manually set by the user instead of auto-calculated. When an
/// override is active the value must be preserved even if other profile
/// fields change.
@freezed
abstract class CalcTargets with _$CalcTargets {
  /// Creates an immutable [CalcTargets] instance.
  const factory CalcTargets({
    /// Daily calorie target in kcal. `null` = missing inputs.
    double? kcalTarget,

    /// Daily protein target in grams. `null` = missing inputs.
    double? proteinGTarget,

    /// Daily carbohydrates target in grams. `null` = missing inputs.
    double? carbsGTarget,

    /// Daily fat target in grams. `null` = missing inputs.
    double? fatGTarget,

    // co2GTarget is stored in schema but NOT shown in UI until Phase 3
    // (per D-08: CO₂ target hidden until CO₂ factor table exists).
    // Included here for schema completeness; UI layer ignores it until Phase 3.

    /// Daily CO₂ footprint target in grams. Hidden from UI until Phase 3.
    double? co2GTarget,

    /// Whether [kcalTarget] was manually overridden by the user.
    @Default(false) bool kcalIsOverridden,

    /// Whether [proteinGTarget] was manually overridden by the user.
    @Default(false) bool proteinIsOverridden,

    /// Whether [carbsGTarget] was manually overridden by the user.
    @Default(false) bool carbsIsOverridden,

    /// Whether [fatIsOverridden] was manually overridden by the user.
    @Default(false) bool fatIsOverridden,
  }) = _CalcTargets;
}

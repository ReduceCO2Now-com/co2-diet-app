import 'package:co2diet/domain/entities/calc_targets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

/// Domain entity representing a user's profile.
///
/// Mirrors the `user_profile` table columns but as a pure Dart type
/// with no Drift, Flutter, or Riverpod imports. All fields except [id]
/// are nullable to support incremental profile completion.
@freezed
abstract class UserProfile with _$UserProfile {
  /// Creates an immutable [UserProfile] instance.
  const factory UserProfile({
    /// UUID v7 primary key (time-ordered).
    required String id,

    /// User's age in years. `null` until the user provides it.
    int? age,

    /// Biological sex string: `'male'`, `'female'`, or `'other'`.
    String? gender,

    /// Height in centimetres. `null` until provided.
    double? heightCm,

    /// Weight in kilograms. `null` until provided.
    double? weightKg,

    /// Physical activity level: `'low'`, `'medium'`, or `'high'`.
    String? activityLevel,

    /// User's dietary preference (free-form string, e.g. `'vegan'`).
    String? dietaryPreference,

    /// User's primary goal, e.g. `'reduce_co2'`, `'lose_weight'`.
    String? goal,

    /// Measurement system in use. Defaults to `'metric'`.
    @Default('metric') String units,

    /// Version tag for the CO₂ methodology data used to compute CO₂ targets.
    @Default('1.0') String co2MethodologyVersion,

    /// BCP-47 locale tag for locale-sensitive formatting, e.g. `'de-DE'`.
    String? localeTag,

    /// Computed macro/calorie targets. `null` until first save.
    CalcTargets? targets,

    /// UTC timestamp when this profile record was first created.
    DateTime? createdAt,

    /// UTC timestamp when this profile record was last modified.
    DateTime? updatedAt,
  }) = _UserProfile;
}

/// Pure Dart ED (eating disorder) safety-net threshold checks.
///
/// Zero Flutter imports — framework-free per RESEARCH.md Pattern 4, so the
/// thresholds can be unit-tested without a widget test harness. Consumed by
/// both `ProfileScreen`'s calorie-target override dialog and `WeightScreen`'s
/// target-weight field (06-CONTEXT.md's locked "two trigger points, one
/// shared component" decision) via `lib/core/widgets/ed_safety_net_dialog.dart`.
///
/// This is a stricter, UI-level warning layered underneath
/// `TargetCalculator`'s existing 500–10000 kcal physiological safety clamp —
/// it does not replace that clamp (NFR-07).
abstract final class EdSafetyNetChecker {
  /// Calorie targets below this value trigger the ED safety-net warning.
  ///
  /// Inclusive-safe: exactly [kcalFloor] is NOT unsafe, only values strictly
  /// below it are.
  static const double kcalFloor = 1200;

  /// BMI values below this value trigger the ED safety-net warning.
  static const double bmiFloor = 17.5;

  /// Returns `true` when [kcalTarget] is below the safe minimum.
  static bool calorieTargetIsUnsafe(double kcalTarget) =>
      kcalTarget < kcalFloor;

  /// Returns whether the BMI implied by [weightKg]/[heightCm] is unsafe.
  ///
  /// Returns `null` (check skipped) when [heightCm] is unavailable or
  /// invalid (missing or `<= 0`) — per 06-CONTEXT.md, the BMI check must be
  /// silently skipped rather than prompting the user to add height, since
  /// Profile Setup has a "no blocking validation" principle.
  static bool? bmiIsUnsafe({required double weightKg, double? heightCm}) {
    if (heightCm == null || heightCm <= 0) return null;
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    return bmi < bmiFloor;
  }
}

/// A single ED helpline/resource entry: display name, phone number (empty
/// string when the resource has no phone line), and an informational URL.
typedef EdHelplineResource = ({String name, String phone, String url});

/// Const ED helpline resources shown alongside the safety-net warning modal
/// and the standalone "Concerned about eating or your relationship with
/// food?" Legal Hub entry point (Plan 06-08).
///
/// RESEARCH.md Assumption A4 / Pitfall 7: phone numbers and URLs were
/// verified via WebSearch against what appear to be each organization's own
/// domain this session, but NOT independently confirmed by a phone call.
/// **Human-verify before real submission** — tracked as a pre-launch
/// blocker (see `STATE.md`), not resolved in this task. A wrong crisis-line
/// number is a real-world harm vector, not just a copy nit.
abstract final class EdSafetyNetResources {
  /// Germany-specific: BZgA's dedicated eating-disorder counseling line.
  static const EdHelplineResource bzga = (
    name: 'BZgA Eating Disorder Counseling',
    phone: '0221 892031',
    url: 'https://www.bzga-essstoerungen.de',
  );

  /// Germany-specific: ANAD e.V. (München) — not to be confused with the
  /// unrelated US-based ANAD (anad.org). See RESEARCH.md Pitfall 7.
  static const EdHelplineResource anad = (
    name: 'ANAD e.V.',
    phone: '089 2199730',
    url: 'https://www.anad.de',
  );

  /// International fallback for non-German users (175+ countries).
  static const EdHelplineResource international = (
    name: 'Find A Helpline (international)',
    phone: '',
    url: 'https://findahelpline.com',
  );

  /// All resources, in display order.
  static const List<EdHelplineResource> all = [bzga, anad, international];
}

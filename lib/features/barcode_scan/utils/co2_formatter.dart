/// Rounds [value] to the same 1-2-significant-figure precision
/// [formatCo2Display] uses, prefixed with `~`, but WITHOUT any unit suffix
/// -- for callers that need to compose their own unit text (e.g. a plain
/// `'kg CO₂e'` total rather than [formatCo2Display]'s per-kg-of-product
/// `'kg CO₂e/kg'` phrasing).
///
/// Returns `'~4.7'` for values < 10, or `'~12'` for values ≥ 10. Returns
/// `null` when [value] is `null` — the caller must hide the CO₂ display
/// entirely in that case (no false-precision fallback like `'~0'`).
///
/// The `~` prefix is mandatory per NFR-05 — CO₂ estimates are LCA model
/// outputs, not physical measurements. Every CO₂ number rendered anywhere
/// in the app should route through this function (or [formatCo2Display],
/// which calls it) rather than ad hoc `toStringAsFixed`/`toStringAsPrecision`
/// calls, so the approximation convention never silently diverges.
String? formatCo2Approx(double? value) {
  if (value == null) return null;
  final String formatted;
  if (value < 10) {
    formatted = value.toStringAsPrecision(2);
  } else {
    formatted = value.round().toString();
  }
  return '~$formatted';
}

/// Formats a CO₂e value (kg per kg of product) for display.
///
/// Returns a string like `'~4.7 kg CO₂e/kg'` for values < 10, or
/// `'~12 kg CO₂e/kg'` for values ≥ 10. Returns null when [value] is null —
/// the caller must hide the CO₂ row entirely in that case.
///
/// Formatting rules:
/// - Values < 10: 2 significant figures via [double.toStringAsPrecision(2)]
///   (e.g. `4.732 → '~4.7 kg CO₂e/kg'`, `0.45 → '~0.45 kg CO₂e/kg'`)
/// - Values ≥ 10: rounded to nearest integer (e.g. `12.04 → '~12 kg CO₂e/kg'`)
///
/// The `~` prefix is mandatory per NFR-05 — CO₂ estimates are LCA model
/// outputs, not physical measurements.
String? formatCo2Display(double? value) {
  final approx = formatCo2Approx(value);
  if (approx == null) return null;
  return '$approx kg CO₂e/kg';
}

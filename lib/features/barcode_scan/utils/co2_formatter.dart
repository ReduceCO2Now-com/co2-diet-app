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
  if (value == null) return null;
  final String formatted;
  if (value < 10) {
    formatted = value.toStringAsPrecision(2);
  } else {
    formatted = value.round().toString();
  }
  return '~$formatted kg CO₂e/kg';
}

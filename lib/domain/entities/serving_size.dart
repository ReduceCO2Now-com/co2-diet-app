import 'dart:convert';

import 'package:flutter/foundation.dart';

/// A user-configurable quick serving size (e.g. `{label: 'Slice', grams:
/// 30}`) stored on a `UserFoodTable` row's `quickServingSizes` JSON
/// column via `servingSizeListConverter` (see `user_food_table.dart`).
///
/// STAND-IN NOTE: This class was created by Plan 04-02 (Drift schema
/// plan) because `UserFoodTable.quickServingSizes`'s `TypeConverter.
/// json2` directly invokes [decodeList]/[encodeList] — it is not a bare
/// type-resolution stub. Plan 04-03 (parallel Wave 2 domain-layer plan)
/// owns the authoritative `serving_size.dart` and should review this
/// implementation against its own spec (round-trip + malformed-input
/// behavior) rather than assume it is unimplemented.
@immutable
class ServingSize {
  /// Creates a [ServingSize] with the given [label] and [grams].
  const ServingSize({required this.label, required this.grams});

  /// Creates a [ServingSize] from a decoded JSON map.
  factory ServingSize.fromJson(Map<String, dynamic> json) {
    return ServingSize(
      label: json['label'] as String,
      grams: (json['grams'] as num).toDouble(),
    );
  }

  /// Display label (e.g. 'Slice', 'Cup').
  final String label;

  /// Weight of this serving size in grams.
  final double grams;

  /// Converts this [ServingSize] to a JSON-encodable map.
  Map<String, dynamic> toJson() => {'label': label, 'grams': grams};

  /// Encodes a list of [ServingSize] as a JSON string.
  static String encodeList(List<ServingSize> sizes) {
    return jsonEncode(sizes.map((s) => s.toJson()).toList());
  }

  /// Decodes a JSON string into a list of [ServingSize].
  ///
  /// Returns an empty list for `null`, empty, or malformed input rather
  /// than throwing — quick serving sizes are a non-critical convenience
  /// feature and must never crash the My Foods form.
  static List<ServingSize> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }
      return decoded
          .map((e) => ServingSize.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServingSize && other.label == label && other.grams == grams);

  @override
  int get hashCode => Object.hash(label, grams);
}

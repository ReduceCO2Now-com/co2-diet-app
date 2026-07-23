import 'dart:convert';

import 'package:co2diet/data/local/mixins/sync_safe_table.dart';
import 'package:co2diet/domain/entities/serving_size.dart';
import 'package:drift/drift.dart';

/// Type converter for the [UserFoodTable.quickServingSizes] JSON column.
///
/// Uses `TypeConverter.json2` (not the deprecated `TypeConverter.json()`)
/// per RESEARCH.md Pitfall 6 — `json2` avoids double-encoding when a
/// future export feature serializes the generated row class to JSON.
///
/// `TypeConverter.json2`'s `fromJson`/`toJson` callbacks operate on the
/// already-decoded JSON object (a `List`/`Map`/primitive), not a raw
/// string — drift performs the string<->JSON-object step itself. This
/// converter bridges that to [ServingSize.decodeList]/[ServingSize.
/// encodeList], which operate on raw JSON strings, via a single
/// `jsonEncode`/`jsonDecode` round trip so the actual label/grams mapping
/// logic still lives in one place (`serving_size.dart`, Plan 04-03).
final JsonTypeConverter2<List<ServingSize>, String, Object?>
servingSizeListConverter = TypeConverter.json2<List<ServingSize>>(
  fromJson: (json) => ServingSize.decodeList(jsonEncode(json)),
  toJson: (sizes) => jsonDecode(ServingSize.encodeList(sizes)),
);

/// Drift table for user-created custom foods AND personal overrides of
/// catalog/cache foods, using the [SyncSafeTable] mixin.
///
/// A single table serves both brand-new custom foods (`overrideOfRef ==
/// null`) and personal overrides (`overrideOfRef != null`) per
/// CONTEXT.md's "single `user_foods` table for both" decision. The
/// original catalog/cache row is never mutated by an override — reverting
/// an override means deleting this row, not restoring a prior value.
@DataClassName('UserFoodRow')
class UserFoodTable extends Table with SyncSafeTable {
  /// Food name, required (LOG-10: "name + at least a calorie value are
  /// required to save").
  Column<String> get name => text()();

  /// Brand, nullable.
  Column<String> get brand => text().nullable()();

  /// Fixed AGRIBALYSE category tag, not freeform (CONTEXT.md decision —
  /// guarantees the CO2 category-estimate always resolves).
  Column<String> get category => text().nullable()();

  /// The amount, in grams, that the nutrition fields below are measured
  /// against. Defaults to 100 (g).
  Column<double> get referenceAmountG =>
      real().withDefault(const Constant(100))();

  /// Energy in kcal per [referenceAmountG]. Required (LOG-10).
  Column<double> get calories => real()();

  /// Protein in g per [referenceAmountG], nullable.
  Column<double> get protein => real().nullable()();

  /// Carbohydrates in g per [referenceAmountG], nullable.
  Column<double> get carbs => real().nullable()();

  /// Sugar in g per [referenceAmountG], nullable.
  Column<double> get sugar => real().nullable()();

  /// Fat in g per [referenceAmountG], nullable.
  Column<double> get fat => real().nullable()();

  /// Fiber in g per [referenceAmountG], nullable.
  Column<double> get fiber => real().nullable()();

  /// Salt in g per [referenceAmountG], nullable.
  Column<double> get salt => real().nullable()();

  /// kg CO2e per kg product — same unit convention as
  /// `FoodItem.co2e100g`, independent of [referenceAmountG] (which only
  /// scopes the nutrition fields above).
  Column<double> get co2e100g => real().nullable()();

  /// Confidence band: `'medium'` when [co2Source] is
  /// `'category_estimate'`; always `null` when [co2Source] is `'manual'`
  /// (a self-entered number has no methodology backing it — CONTEXT.md
  /// decision, no confidence chip for manual CO2).
  Column<String> get confidenceBand => text().nullable()();

  /// One of `'category_estimate'` or `'manual'`.
  Column<String> get co2Source => text().nullable()();

  /// Optional barcode; pre-filled from the barcode no-match flow so a
  /// future scan of that barcode resolves to this custom food.
  Column<String> get barcode => text().nullable()();

  /// User-configurable quick serving sizes (e.g. `{label: 'Slice', grams:
  /// 30}`), stored as JSON via [servingSizeListConverter].
  Column<String> get quickServingSizes =>
      text().map(servingSizeListConverter)();

  /// Non-null only when this row is an override of an existing
  /// catalog/cache food — paired with [overrideOfSource].
  Column<String> get overrideOfRef => text().nullable()();

  /// `'off_ref'` or `'user_food_cache'`, paired with [overrideOfRef].
  Column<String> get overrideOfSource => text().nullable()();
}

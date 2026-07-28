import 'package:co2diet/data/local/daos/food_catalog_dao.dart';
import 'package:co2diet/domain/entities/meal_entry.dart';
import 'package:co2diet/domain/entities/portion_unit.dart';
import 'package:flutter/foundation.dart';

/// Hand-authored protein-for-protein substitution clusters (CO2-06,
/// 05-CONTEXT.md: "red meat <-> poultry <-> fish <-> legumes/plant-protein").
///
/// Keyed by a representative `off_ref.co2_factors.categories_tag` value
/// (verbatim strings from `tools/off_to_agribalyse_map.csv`'s
/// `off_category_tag` column — the same vocabulary [FoodCatalogDao]'s
/// `getCo2ForCategory`/`getAvailableCo2Categories` already query against).
/// Each value lists only lower-typical-CO2 alternatives within the same
/// protein band — never a category outside this cluster (e.g. never
/// vegetables/dairy/grains), and never a "swap up" to a higher-CO2 tier:
///
/// - Tier 1 (red meat, highest typical CO2e): `en:beef`, `en:lamb-and-goat`,
///   `en:pork` -> alternatives are every lower tier (poultry, fish, legumes).
/// - Tier 2 (poultry): `en:poultry` -> alternatives are fish and legumes
///   only (never suggests moving up to red meat).
/// - Tier 3 (fish/seafood): `en:fishes` -> only legumes remains as a
///   lower-CO2 alternative.
/// - Tier 4 (legumes/plant-protein): `en:legumes` — already the lowest-CO2
///   protein source in this cluster; deliberately absent as a map key, so
///   entries in this tier never produce a suggestion (nowhere lower to go).
const Map<String, List<String>> _substitutionClusters = {
  'en:beef': ['en:poultry', 'en:fishes', 'en:legumes'],
  'en:lamb-and-goat': ['en:poultry', 'en:fishes', 'en:legumes'],
  'en:pork': ['en:poultry', 'en:fishes', 'en:legumes'],
  'en:poultry': ['en:fishes', 'en:legumes'],
  'en:fishes': ['en:legumes'],
};

/// Human-readable display name for each alternative category tag used in
/// [_substitutionClusters] values — assembled into factual copy at the
/// widget layer (never baked into this pure-Dart service's return values).
const Map<String, String> _categoryDisplayNames = {
  'en:poultry': 'chicken',
  'en:fishes': 'fish',
  'en:legumes': 'legumes',
};

/// Keyword-based category inference from a logged product's name.
///
/// `MealEntry` has no persisted category-tag snapshot field (only
/// off_ref/user_food_cache rows carry `categories_tags`, and that value is
/// never copied onto `MealEntryTable` — out of this plan's `files_modified`
/// scope to add). Rather than a schema change, `_categoryFor` reuses this
/// codebase's existing keyword-heuristic precedent
/// (`detectMealSlotForTime`'s time-of-day heuristic) applied to
/// [MealEntry.productNameSnapshot] instead: a documented, hand-authored,
/// case-insensitive substring match. Iteration order matters — the first
/// matching key wins, so more specific/common terms are listed first.
const Map<String, List<String>> _categoryKeywords = {
  'en:beef': ['beef', 'steak', 'burger', 'mince'],
  'en:lamb-and-goat': ['lamb', 'goat', 'mutton'],
  'en:pork': ['pork', 'bacon', 'ham', 'sausage'],
  'en:poultry': ['chicken', 'turkey', 'duck'],
  'en:fishes': [
    'fish',
    'salmon',
    'tuna',
    'cod',
    'shrimp',
    'prawn',
    'seafood',
  ],
  'en:legumes': ['lentil', 'bean', 'chickpea', 'tofu', 'tempeh', 'soy'],
};

/// Minimum single-entry CO2e contribution (kg) for a logged meal to count
/// as "meaningfully high" within its cluster. Below this, no suggestion is
/// produced — avoids nudging over a small side dish or garnish-sized
/// portion. Documented, hand-picked threshold (Claude's discretion per
/// 05-CONTEXT.md), not derived from any external source.
const double _significantCo2ThresholdKg = 0.3;

/// A single quantified substitution suggestion: swapping [originalName]
/// for [alternativeName] would save approximately [deltaKg] kg CO2e today.
///
/// Deliberately data-only — no copy/phrasing lives here. The widget layer
/// (`ImprovementOpportunities`) assembles the factual, non-judgmental
/// sentence from these three fields.
@immutable
class ImprovementOpportunity {
  /// Creates an [ImprovementOpportunity].
  const ImprovementOpportunity({
    required this.originalName,
    required this.alternativeName,
    required this.deltaKg,
  });

  /// The logged product's name (e.g. `'Beef Steak'`).
  final String originalName;

  /// The suggested same-cluster alternative's display name (e.g.
  /// `'chicken'`).
  final String alternativeName;

  /// Quantified CO2e savings (kg) from making the swap, for today's logged
  /// quantity. Always > 0 — deltas that would increase CO2e are never
  /// returned.
  final double deltaKg;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImprovementOpportunity &&
          other.originalName == originalName &&
          other.alternativeName == alternativeName &&
          other.deltaKg == deltaKg);

  @override
  int get hashCode => Object.hash(originalName, alternativeName, deltaKg);

  @override
  String toString() =>
      'ImprovementOpportunity(originalName: $originalName, '
      'alternativeName: $alternativeName, deltaKg: $deltaKg)';
}

/// Pure domain service (CO2-06): finds hand-authored, same-cluster,
/// protein-for-protein substitution suggestions for today's high-CO2
/// entries.
///
/// Surfaces ONLY inside the Data Analysis screen (05-CONTEXT.md) — never
/// the Dashboard, never a notification. This service itself has no
/// awareness of where it's rendered; that invariant is enforced entirely
/// by which widget tree calls it (`DataAnalysisScreen` only, verified in
/// `data_analysis_screen_test.dart`/`improvement_opportunities_test.dart`).
class ImprovementOpportunityFinder {
  /// Creates an [ImprovementOpportunityFinder] backed by [_foodCatalogDao]
  /// for [FoodCatalogDao.getCo2ForCategory] category-average lookups —
  /// reuses the existing Phase 3 `co2_factors` data, no new data source.
  const ImprovementOpportunityFinder(this._foodCatalogDao);

  final FoodCatalogDao _foodCatalogDao;

  /// Returns a same-cluster substitution suggestion for each of
  /// [todayEntries] whose inferred category belongs to a known
  /// substitution cluster ([_substitutionClusters]) and whose CO2e
  /// contribution meets [_significantCo2ThresholdKg].
  ///
  /// Only weight-based-unit entries ([PortionUnitDisplay.isWeightBased])
  /// are considered — mirrors `DailyTotalsCalculator`'s existing
  /// "piece/cup/portion entries have no gram-equivalent" precedent.
  ///
  /// For each qualifying entry, computes every cluster alternative's
  /// quantified CO2e for the same logged quantity via
  /// [FoodCatalogDao.getCo2ForCategory] and returns the alternative with
  /// the largest positive delta. Entries with no known category, no
  /// available `co2e100gSnapshot`, or no alternative producing a positive
  /// delta are silently skipped (never a fabricated suggestion).
  Future<List<ImprovementOpportunity>> findOpportunities(
    List<MealEntry> todayEntries,
  ) async {
    final opportunities = <ImprovementOpportunity>[];

    for (final entry in todayEntries) {
      if (!entry.unit.isWeightBased) continue;

      final originalCo2Per100g = entry.co2e100gSnapshot;
      if (originalCo2Per100g == null) continue;

      final category = _categoryFor(entry.productNameSnapshot);
      if (category == null) continue;

      final alternatives = _substitutionClusters[category];
      if (alternatives == null || alternatives.isEmpty) continue;

      final gramsEquivalent = entry.quantity;
      final originalTotalKg = originalCo2Per100g * gramsEquivalent / 100;
      if (originalTotalKg < _significantCo2ThresholdKg) continue;

      ImprovementOpportunity? best;
      for (final alternativeTag in alternatives) {
        final altCo2Per100g = await _foodCatalogDao.getCo2ForCategory(
          alternativeTag,
        );
        if (altCo2Per100g == null) continue;

        final altTotalKg = altCo2Per100g * gramsEquivalent / 100;
        final deltaKg = originalTotalKg - altTotalKg;
        if (deltaKg <= 0) continue;

        if (best == null || deltaKg > best.deltaKg) {
          best = ImprovementOpportunity(
            originalName: entry.productNameSnapshot,
            alternativeName: _categoryDisplayNames[alternativeTag]!,
            deltaKg: deltaKg,
          );
        }
      }

      if (best != null) opportunities.add(best);
    }

    return opportunities;
  }

  /// Infers a `co2_factors.categories_tag` value from [productName] via
  /// [_categoryKeywords] keyword substring matching (case-insensitive).
  /// Returns `null` when no keyword matches — that entry is silently
  /// excluded from suggestions rather than guessed at.
  String? _categoryFor(String productName) {
    final lower = productName.toLowerCase();
    for (final entry in _categoryKeywords.entries) {
      if (entry.value.any(lower.contains)) return entry.key;
    }
    return null;
  }
}

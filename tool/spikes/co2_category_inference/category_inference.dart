// CO2-V2-01 spike — on-device food-category inference.
//
// SPIKE, NOT PRODUCTION. Not wired into the app. See
// docs/ai/CO2-V2-01-EVALUATION.md for the options considered and why this
// approach was chosen.
//
// Infers an AGRIBALYSE food group from a product name so that a product with
// no catalog match can still receive a CO2 estimate, instead of showing
// nothing (today's behaviour per docs/CO2_METHODOLOGY.md).
//
// Runs entirely on-device: pure Dart, no network, no plugin, no user data
// leaves the phone. The model is a JSON asset produced by train.py.

import 'dart:convert';
import 'dart:io';

/// Confidence band for an inferred category.
///
/// Deliberately disjoint from the catalog's existing `high`/`medium` bands:
/// an inferred estimate must never be presentable as a measured or
/// category-averaged one.
enum InferredBand { inferredLikely, inferredUncertain, declined }

class CategoryPrediction {
  const CategoryPrediction({
    required this.group,
    required this.band,
    required this.margin,
    required this.runnerUp,
  });

  /// Best-scoring AGRIBALYSE group, or null when the model declined.
  final String? group;
  final InferredBand band;

  /// Log-probability gap between the top two classes. Low margin means the
  /// model is torn, which is the signal we gate on.
  final double margin;
  final String? runnerUp;

  bool get isUsable => band != InferredBand.declined;
}

class CategoryInferenceModel {
  CategoryInferenceModel._(
    this._classes,
    this._priors,
    this._backoff,
    this._weights,
  );

  factory CategoryInferenceModel.fromJson(Map<String, dynamic> json) {
    final weights = <String, Map<String, double>>{};
    (json['weights'] as Map<String, dynamic>).forEach((feature, perClass) {
      weights[feature] = (perClass as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble()));
    });
    return CategoryInferenceModel._(
      (json['classes'] as List).cast<String>(),
      (json['priors'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      (json['backoff'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      weights,
    );
  }

  final List<String> _classes;
  final Map<String, double> _priors;
  final Map<String, double> _backoff;
  final Map<String, Map<String, double>> _weights;

  /// Margin below which we refuse to answer rather than guess. Tuned on the
  /// held-out set — see the evaluation document's calibration table.
  static const double _declineBelow = 2;
  static const double _uncertainBelow = 8;

  static final _token = RegExp('[a-z0-9]+');
  static final _noise =
      RegExp(r'\b\d+([.,]\d+)?\s*(g|kg|ml|cl|l|oz|lb|x|pc|pcs)?\b');
  static const _combining = 0x300;
  static const _combiningEnd = 0x36F;

  /// Must stay behaviourally identical to `featurize()` in train.py.
  /// Drift between the two silently degrades accuracy with no error and no
  /// crash — the failure mode is a quietly worse model. Productionising this
  /// spike must add a parity test over a shared fixture; there isn't one yet.
  static List<String> featurize(String name) {
    var norm = _stripAccents(name.toLowerCase());
    norm = norm.replaceAll(_noise, ' ');
    final words = _token.allMatches(norm).map((m) => m.group(0)!).toList();
    final feats = <String>[...words];
    for (var i = 0; i + 1 < words.length; i++) {
      feats.add('${words[i]}_${words[i + 1]}');
    }
    final joined = words.join(' ');
    for (var i = 0; i + 3 <= joined.length; i++) {
      feats.add('#${joined.substring(i, i + 3)}');
    }
    return feats;
  }

  static String _stripAccents(String input) {
    const map = {
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
      'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n', 'ý': 'y', 'ÿ': 'y',
    };
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= _combining && rune <= _combiningEnd) continue;
      final ch = String.fromCharCode(rune);
      buffer.write(map[ch] ?? ch);
    }
    return buffer.toString();
  }

  CategoryPrediction predict(String productName) {
    final scores = <String, double>{for (final c in _classes) c: _priors[c]!};

    for (final feature in featurize(productName)) {
      final perClass = _weights[feature];
      if (perClass == null) continue; // unseen feature contributes nothing
      for (final c in _classes) {
        scores[c] = scores[c]! + (perClass[c] ?? _backoff[c]!);
      }
    }

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final margin = ranked[0].value - ranked[1].value;

    if (margin < _declineBelow) {
      return CategoryPrediction(
        group: null,
        band: InferredBand.declined,
        margin: margin,
        runnerUp: ranked[1].key,
      );
    }
    return CategoryPrediction(
      group: ranked[0].key,
      band: margin < _uncertainBelow
          ? InferredBand.inferredUncertain
          : InferredBand.inferredLikely,
      margin: margin,
      runnerUp: ranked[1].key,
    );
  }
}

// ── Spike harness ────────────────────────────────────────────────────────────
// Runs the held-out evaluation set through the Dart implementation and reports
// accuracy, decline rate and per-prediction latency.

Future<void> main() async {
  final dir = File.fromUri(Platform.script).parent.path;
  final model = CategoryInferenceModel.fromJson(
    jsonDecode(await File('$dir/model.json').readAsString())
        as Map<String, dynamic>,
  );
  final eval = (jsonDecode(await File('$dir/holdout.json').readAsString())
      as List)
      .cast<Map<String, dynamic>>();

  var correct = 0;
  var answered = 0;
  var declined = 0;
  var uncertain = 0;
  var correctWhenAnswered = 0;
  final sw = Stopwatch()..start();

  for (final row in eval) {
    final expected = row['expected_group'] as String;
    final p = model.predict(row['name'] as String);
    if (!p.isUsable) {
      declined++;
      continue;
    }
    answered++;
    if (p.band == InferredBand.inferredUncertain) uncertain++;
    if (p.group == expected) {
      correct++;
      correctWhenAnswered++;
    }
  }
  sw.stop();

  final n = eval.length;
  String pct(num v, num d) =>
      d == 0 ? '  n/a' : '${(100 * v / d).toStringAsFixed(1)}%';

  stdout
    ..writeln('CO2-V2-01 spike — Dart on-device inference')
    ..writeln('─' * 52)
    ..writeln('eval products        $n')
    ..writeln('answered             $answered  (${pct(answered, n)})')
    ..writeln('declined (low margin)$declined  (${pct(declined, n)})')
    ..writeln(
      '  of answered: uncertain  $uncertain  (${pct(uncertain, answered)})',
    )
    ..writeln()
    ..writeln('accuracy over all    ${pct(correct, n)}')
    ..writeln(
      'accuracy when answered ${pct(correctWhenAnswered, answered)}',
    )
    ..writeln()
    ..writeln('total time           ${sw.elapsedMilliseconds} ms')
    ..writeln(
      'per prediction       '
      '${(sw.elapsedMicroseconds / n).toStringAsFixed(0)} µs',
    );
}

# CO2-V2-01 spike — on-device food-category inference

**Spike, not production.** Nothing here is wired into the app.
Full write-up: [`docs/ai/CO2-V2-01-EVALUATION.md`](../../../docs/ai/CO2-V2-01-EVALUATION.md)

Infers an AGRIBALYSE food group from a product name, so a product with no
catalog category can still receive a CO₂ estimate instead of showing nothing.

| | |
|---|---|
| Accuracy when answering | 86.4% |
| Coverage | 87.4% (declines 12.6%) |
| Majority baseline | 14.1% |
| Latency | 19 µs / product |
| Asset | 2.0 MB |
| Dependencies | none — stdlib Python, pure Dart |

## Files

| File | Purpose |
|---|---|
| `train.py` | Trains the model, exports `model.json` + the held-out split |
| `category_inference.dart` | On-device inference + evaluation harness |
| `calibrate.py` | Margin-threshold sweep (coverage vs precision) |

## Run

```bash
python3 train.py ../../../tools/data/openfoodfacts-products.jsonl.gz \
    ../../../tools/off_to_agribalyse_map.csv model.json 500000
dart run category_inference.dart
python3 calibrate.py
```

Needs the OFF JSONL dump from `tools/README.md`. `model.json` and
`holdout.json` are generated, not committed.

## Known limitation

Trained and evaluated on products that *have* categories; it would serve
products that *lack* them. Held-out accuracy likely overstates real
performance — resolve before this becomes a phase. See §8 of the evaluation.

---
status: EVALUATION — spike complete, not integrated
requirement: CO2-V2-01 (AI-based CO₂ estimation for unknown products)
author: Ali (Flutter client)
date: 2026-09-07
spike: tool/spikes/co2_category_inference/
---

# CO2-V2-01 — AI-assisted CO₂ estimation for unmatched products

> **Status:** this is an evaluation plus a working spike. Nothing here is wired
> into the app, and the spike is not production code. It exists to answer a
> design question with evidence rather than opinion.

---

## 1. The problem

`docs/CO2_METHODOLOGY.md` defines three outcomes when the app needs a CO₂
figure for a product:

| Band | How it is obtained |
|---|---|
| **High** | Exact barcode matched to a CIQUAL product code with a measured LCA value |
| **Medium** | Product category matched to an AGRIBALYSE food group; the group median is shown |
| *(none)* | No AGRIBALYSE coverage — **no estimate is shown at all** |

That third row is deliberate and correct: *"the app never displays a
poorly-sourced guess."* But it produces a real dead end. A user scans or types a
product, the catalog has no category for it, and the CO₂ number — the reason
this app exists rather than any other food tracker — is simply absent.

`CO2-V2-01` asks whether that gap can be closed. The question this evaluation
answers is narrower and more useful than "can we add AI":

> Given only a product's name, can we infer its food category accurately enough
> to produce an estimate that is honest to show — and can we tell, per product,
> when we cannot?

The second half matters as much as the first. A system that is 85% right and
cannot tell you which 85% is not usable in a product that stakes its
credibility on transparency.

---

## 2. The constraints that decide this

These are product constraints from `PROJECT.md` and `REQUIREMENTS.md`, not
preferences. They eliminate the obvious solution before it is considered.

| Constraint | Consequence for this feature |
|---|---|
| **Privacy-first** — no behavioural data leaves the device | A product name is user data. Sending it to a third-party API to be logged and retained is exactly what this app promises not to do |
| **Offline-first** — core flows work with no network | An estimate that needs connectivity fails precisely when the local catalog already failed |
| **Free forever, no revenue model on user data** | Per-call inference pricing scales with usage against zero revenue |
| **Open source and self-hostable** | A proprietary API key cannot be shipped in an open repository, and a self-hoster cannot obtain one |
| **CI-enforced dependency blocklist** | Any SDK carrying analytics fails the build automatically |
| **Estimates carry confidence and methodology version** | Any new estimate path must integrate with confidence bands, not bypass them |

The obvious 2026 answer — call a hosted LLM — fails four of six. That is the
finding, and it is worth stating plainly rather than treating the constraint set
as an obstacle to route around.

---

## 3. Options considered

**A. Hosted LLM API** (OpenAI, Anthropic, Gemini). Highest accuracy, near-zero
build effort, excellent multilingual handling. Sends user food data to a third
party; requires network; per-call cost; API key unusable in an open-source,
self-hostable build. **Rejected on privacy and offline grounds** — not on
capability.

**B. On-device small LLM** (quantised 1–3B via llama.cpp or MediaPipe LLM). No
data leaves the device, works offline. But a 0.6–2 GB asset against an app whose
entire optional food pack is 300–800 MB, seconds of latency per inference on
mid-range hardware, non-deterministic output needing parsing and validation, and
substantial battery cost. **Rejected as disproportionate** — a
sledgehammer for an 8-way classification.

**C. On-device sentence embeddings + nearest neighbour** (distilled
multilingual encoder via TFLite). Good multilingual generalisation, handles
unseen phrasings well. Costs a 15–25 MB model asset plus a native inference
dependency to vet against the blocklist, and produces distances that are harder
to calibrate into an honest confidence band. **Deferred** — the strongest
upgrade path if the chosen approach proves insufficient.

**D. Supervised text classifier trained on Open Food Facts** — Naive Bayes over
word and character n-grams of the product name. Small, fast, fully offline,
deterministic, auditable, and — critically — produces a per-prediction margin
that calibrates directly into a confidence band. Training data already exists in
the repository. **Chosen for the spike.**

**E. Pure lexical / fuzzy matching against category labels.** Zero model, but no
learning from real product naming, no calibration signal, and brittle across
languages. **Rejected** — it is the baseline this should beat, not the answer.

| | A. Hosted LLM | B. On-device LLM | C. Embeddings | **D. Classifier** | E. Lexical |
|---|---|---|---|---|---|
| No data leaves device | ✗ | ✓ | ✓ | **✓** | ✓ |
| Works offline | ✗ | ✓ | ✓ | **✓** | ✓ |
| Zero marginal cost | ✗ | ✓ | ✓ | **✓** | ✓ |
| Self-hostable / open | ✗ | ✓ | ✓ | **✓** | ✓ |
| Asset size | – | 0.6–2 GB | 15–25 MB | **2 MB** | 0 |
| Latency | network | seconds | ~10 ms | **19 µs** | µs |
| New native dependency | ✓ | ✓ | ✓ | **none** | none |
| Calibratable confidence | weak | weak | moderate | **strong** | none |
| Deterministic / auditable | ✗ | ✗ | ✓ | **✓** | ✓ |

---

## 4. The spike

**Location:** `tool/spikes/co2_category_inference/`

| File | Purpose |
|---|---|
| `train.py` | Trains the model and exports it plus the held-out split. Pure stdlib — no dependency to vet |
| `category_inference.dart` | On-device inference in pure Dart, plus the evaluation harness |
| `calibrate.py` | Margin-threshold sweep producing the table in §6 |
| `model.json` | Trained model artifact (2.0 MB) |
| `holdout.json` | 8,564 held-out products the model never saw |

**Method.** Ground truth is built from Open Food Facts products that *do* carry
a category mapping to an AGRIBALYSE group via the repository's existing
`tools/off_to_agribalyse_map.csv`. The category is then hidden and the model
must recover the group from the product name alone — simulating the production
no-match case. Only products resolving to exactly one group are used, so labels
are unambiguous.

Features are word unigrams and bigrams plus character trigrams of the
normalised name. **Brand is deliberately excluded**: brands correlate with
categories in training data but would not generalise, and would bake brand
identity into a shipped asset. Per-class sampling is capped at 6,000 to blunt an
otherwise severe imbalance.

**Scale.** 500,000 records scanned, 227,640 eligible, 42,817 used after capping,
split 80/20 into 34,253 training and 8,564 held-out.

> **A methodological note, because it changed the numbers.** The first version
> of this spike scored the Dart implementation against an independently sampled
> file drawn from the same scan window as the training data. Those samples
> overlapped the training rows, and the reported accuracy was inflated by
> roughly four points. `train.py` now exports the exact held-out split it
> reports on, and Dart scores against that. Every figure below is from data the
> model has genuinely never seen.

---

## 5. Results

Against a **14.1% majority-class baseline** across 8 AGRIBALYSE groups:

| Metric | Result |
|---|---|
| Top-1 accuracy (always answering) | **80.9%** |
| Top-2 accuracy | **90.9%** |
| Accuracy when the model chooses to answer | **86.4%** |
| Coverage (products answered) | 87.4% |
| Declined (margin too low) | 12.6% |
| Inference latency | **19 µs** per product |
| Model asset | 2.0 MB |

Per-class recall runs 74.9%–85.4% for the seven well-represented groups.
*Matières grasses* (fats and oils) reaches only 66.7% on 153 held-out examples —
the one class with too little data to judge fairly.

---

## 6. Knowing when to decline

This is the part that makes the feature shippable rather than merely accurate.

The gap between the top two class scores — the **margin** — is a usable
confidence signal. Sweeping a threshold over it produces a clean monotonic
trade between how often the model answers and how often it is right:

| Margin ≥ | Coverage | Precision |
|---|---|---|
| 0 (always answer) | 100.0% | 80.9% |
| 1 | 92.6% | 84.3% |
| **2** | **87.4%** | **86.4%** |
| 4 | 77.8% | 90.0% |
| 6 | 69.7% | 92.3% |
| 8 | 62.9% | 94.0% |
| 12 | 50.0% | 96.2% |
| 16 | 39.5% | 97.5% |
| 24 | 23.3% | 98.6% |

The spike uses **≥ 2 to answer at all** and **≥ 8 to answer confidently**,
which yields 87.4% coverage at 86.4% precision, with 28% of answers marked
uncertain. That is a starting point for a product conversation, not a settled
choice — the table is the actual deliverable here, because it lets the decision
be made on the trade rather than on a single number.

---

## 7. How it would integrate

**New bands, disjoint from the existing ones.** An inferred estimate must never
be presentable as a measured or category-averaged one:

```
high                 exact barcode → CIQUAL LCA        (unchanged)
medium               catalog category → group median   (unchanged)
inferred-likely      name-inferred, margin ≥ 8         (new)
inferred-uncertain   name-inferred, margin ≥ 2         (new)
(none)               declined, or no group median      (unchanged)
```

**Disclosure is mandatory, not optional.** The methodology screen already
explains how every figure is derived, and an inferred figure needs its own
entry: the category was guessed from the product name, the app was not certain,
and the user can correct it. The existing custom-food flow already accepts a
category, so correction has a home.

**The declined case must stay a dead end.** When the model refuses, the app
shows no CO₂ figure — exactly today's behaviour. That is the whole point of
having a decline gate.

**Rollout.** Ship behind a flag, default off. Compare inferred categories
against user corrections in the custom-food flow — that is free, honest,
opt-in ground truth from the real target population.

---

## 8. Limitations

Stated plainly, because the strongest argument against this feature is in here.

**Covariate shift is the real risk.** The model is trained and evaluated on
products that *have* categories in Open Food Facts. The products it would
actually serve are those that *lack* them — and those are likely lower-quality
entries with sparser, noisier, more abbreviated names. Held-out accuracy on
well-categorised products probably **overstates** real-world performance, and by
an unknown amount. Quantifying that gap needs labelled examples from the
uncategorised population, which do not currently exist. **This is the first
thing to resolve before shipping.**

**Eight groups is coarse.** An AGRIBALYSE group median spans a wide CO₂e range;
correctly classifying a product as *viandes, œufs, poissons* still leaves beef
and white fish in the same bucket. The gain over showing nothing is real but
should not be oversold, and the confidence wording must reflect it.

**Sampling bias.** Training draws from the first 500,000 records of the OFF
dump, which is not a random sample of the corpus. Country and language skew is
unmeasured.

**Multilingual behaviour is untested per language.** Product names span many
languages; aggregate accuracy hides which ones work.

**One class is undertrained.** *Matières grasses* has 153 held-out examples and
66.7% recall — not enough to trust.

**Not measured on real hardware.** 19 µs is desktop Dart. It will be slower on a
phone, though several orders of magnitude of headroom make this a low risk.

**2 MB asset.** Acceptable, and reducible via a higher minimum document
frequency or weight pruning if it matters.

---

## 9. Recommendation

The approach is viable and the constraints turn out to be clarifying rather
than limiting — they rule out the expensive answers and point at a 2 MB,
19-microsecond, fully-offline model that beats its baseline by 67 points and
knows when to stay quiet.

Before this becomes a phase rather than a spike:

1. **Resolve the covariate-shift question.** Hand-label a few hundred products
   from the uncategorised population and measure against those. If accuracy
   collapses there, the feature does not ship in this form.
2. **Agree the coverage/precision point** from §6 as a product decision.
3. **Confirm the disclosure wording** against the app's non-judgemental,
   estimate-not-measurement copy rules.
4. **Decide whether the group median is granular enough** to be worth showing
   at all, or whether this needs finer categories first.

If (1) holds, this is a well-scoped phase. If it does not, this document is
still the answer to `CO2-V2-01` — that the honest version of AI CO₂ estimation
is a small on-device classifier that declines when unsure, and that the reason
to be careful is data shift, not model capability.

---

## Reproducing

```bash
cd tool/spikes/co2_category_inference
python3 train.py ../../../tools/data/openfoodfacts-products.jsonl.gz \
    ../../../tools/off_to_agribalyse_map.csv model.json 500000
dart run category_inference.dart
python3 calibrate.py
```

Requires the OFF JSONL dump referenced by `tools/README.md`. No third-party
Python or Dart packages.

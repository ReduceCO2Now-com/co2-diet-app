#!/usr/bin/env python3
"""Train a compact on-device category classifier for CO2-V2-01.

Multinomial Naive Bayes over word + character-trigram features of the product
name. Pure stdlib on purpose: the artifact must be auditable and carry no
dependency the app team has to vet (mirrors this project's dependency policy).

Outputs a JSON model small enough to bundle as a Flutter asset and run
entirely on-device: no network call, no user data leaves the phone.

Usage: python3 train.py <off.jsonl.gz> <map.csv> <out_model.json> [max_scan]
"""
import csv, gzip, json, math, random, re, sys, unicodedata
from collections import defaultdict

TOKEN_RE = re.compile(r"[a-z0-9]+")
# Quantities/units carry no category signal and add noise.
NOISE = re.compile(r"\b\d+([.,]\d+)?\s*(g|kg|ml|cl|l|oz|lb|x|pc|pcs)?\b")

def normalize(text):
    text = unicodedata.normalize("NFKD", text.lower())
    text = "".join(c for c in text if not unicodedata.combining(c))
    return NOISE.sub(" ", text)

def featurize(name, brand=""):
    """Word unigrams/bigrams + character trigrams. Brand is deliberately
    excluded from features: brands correlate with categories in the training
    data but would not generalise, and would leak brand identity into the
    model asset."""
    norm = normalize(name)
    words = TOKEN_RE.findall(norm)
    feats = list(words)
    feats += [f"{a}_{b}" for a, b in zip(words, words[1:])]
    joined = " ".join(words)
    feats += [f"#{joined[i:i+3]}" for i in range(max(0, len(joined) - 2))]
    return feats

def load_map(path):
    m = {}
    with open(path, newline="", encoding="utf-8") as fh:
        for row in csv.DictReader(fh):
            tag = (row.get("off_category_tag") or "").strip()
            grp = (row.get("agribalyse_group") or "").strip()
            if tag and grp:
                m[tag] = grp
    return m

def collect(off_path, cat_map, max_scan):
    rows, scanned = [], 0
    with gzip.open(off_path, "rt", encoding="utf-8", errors="replace") as fh:
        for line in fh:
            scanned += 1
            if scanned > max_scan:
                break
            try:
                p = json.loads(line)
            except Exception:
                continue
            name = (p.get("product_name") or "").strip()
            if not name or len(name) < 3 or len(name) > 120:
                continue
            tags = p.get("categories_tags") or []
            hits = {cat_map[t] for t in tags if t in cat_map}
            if len(hits) != 1:
                continue
            rows.append((name, (p.get("brands") or "").strip(), hits.pop()))
    return rows, scanned

def main():
    off_path, map_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
    max_scan = int(sys.argv[4]) if len(sys.argv) > 4 else 500_000

    cat_map = load_map(map_path)
    rows, scanned = collect(off_path, cat_map, max_scan)
    random.seed(42)
    random.shuffle(rows)

    # Cap per class to blunt the 28.5% majority-class imbalance.
    per_class, capped = defaultdict(int), []
    CAP = 6000
    for r in rows:
        if per_class[r[2]] < CAP:
            per_class[r[2]] += 1
            capped.append(r)
    rows = capped
    random.shuffle(rows)

    split = int(len(rows) * 0.8)
    train, test = rows[:split], rows[split:]

    # --- Multinomial Naive Bayes ---
    classes = sorted({r[2] for r in train})
    class_counts = defaultdict(int)
    feat_counts = {c: defaultdict(int) for c in classes}
    totals = defaultdict(int)
    vocab = set()

    for name, brand, grp in train:
        class_counts[grp] += 1
        for f in featurize(name, brand):
            feat_counts[grp][f] += 1
            totals[grp] += 1
            vocab.add(f)

    # Keep only features seen enough times — shrinks the asset and drops
    # one-off noise tokens (product codes, typos).
    MIN_DF = 3
    kept = {f for f in vocab
            if sum(feat_counts[c].get(f, 0) for c in classes) >= MIN_DF}

    V = len(kept)
    n_train = len(train)
    priors = {c: math.log(class_counts[c] / n_train) for c in classes}
    weights = {}
    for c in classes:
        denom = math.log(totals[c] + V)
        for f in kept:
            cnt = feat_counts[c].get(f, 0)
            if cnt:
                weights.setdefault(f, {})[c] = round(math.log(cnt + 1) - denom, 4)
    # Per-class fallback for features unseen in that class.
    backoff = {c: round(math.log(1) - math.log(totals[c] + V), 4) for c in classes}

    model = {
        "version": 1,
        "classes": classes,
        "priors": {c: round(priors[c], 4) for c in classes},
        "backoff": backoff,
        "weights": weights,
    }

    def predict(name, brand=""):
        scores = dict(model["priors"])
        for f in featurize(name, brand):
            w = model["weights"].get(f)
            for c in classes:
                scores[c] += (w.get(c, backoff[c]) if w else 0.0)
        ranked = sorted(scores.items(), key=lambda kv: -kv[1])
        return ranked

    correct = top2 = 0
    per_class_stat = defaultdict(lambda: [0, 0])
    margins = []
    for name, brand, grp in test:
        ranked = predict(name, brand)
        per_class_stat[grp][1] += 1
        if ranked[0][0] == grp:
            correct += 1
            per_class_stat[grp][0] += 1
        if grp in {ranked[0][0], ranked[1][0]}:
            top2 += 1
        margins.append(ranked[0][1] - ranked[1][1])

    majority = max(class_counts.values()) / n_train

    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(model, fh, ensure_ascii=False, separators=(",", ":"))

    # Export the SAME held-out split the numbers above were computed on, so the
    # Dart harness scores against data the model has genuinely never seen.
    # (An earlier revision of this spike scored Dart against an independently
    # sampled file drawn from the same scan window — which silently overlapped
    # the training rows and inflated the result.)
    holdout = [{"name": n, "brand": b, "expected_group": g} for n, b, g in test]
    holdout_path = out_path.replace("model.json", "holdout.json")
    with open(holdout_path, "w", encoding="utf-8") as fh:
        json.dump(holdout, fh, ensure_ascii=False, indent=1)
    print(f"holdout written    {len(holdout):,} -> {holdout_path}")

    import os
    size_kb = os.path.getsize(out_path) / 1024
    print(f"scanned            {scanned:,}")
    print(f"labelled rows      {len(rows):,}  (capped at {CAP}/class)")
    print(f"train / test       {len(train):,} / {len(test):,}")
    print(f"classes            {len(classes)}")
    print(f"features kept      {V:,}  (min_df={MIN_DF})")
    print(f"model size         {size_kb:,.0f} KB")
    print()
    print(f"majority baseline  {majority:6.1%}")
    print(f"top-1 accuracy     {correct/len(test):6.1%}")
    print(f"top-2 accuracy     {top2/len(test):6.1%}")
    print()
    print("per-class recall:")
    for c in classes:
        ok, n = per_class_stat[c]
        print(f"  {ok/n if n else 0:6.1%}  ({n:4d})  {c}")

if __name__ == "__main__":
    main()

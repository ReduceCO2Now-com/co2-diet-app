#!/usr/bin/env python3
"""Margin-threshold sweep: what coverage/precision trade does the decline gate buy?"""
import json, sys
sys.path.insert(0, ".")
from train import featurize

model = json.load(open("model.json"))
holdout = json.load(open("holdout.json"))
classes, priors, backoff, weights = (
    model["classes"], model["priors"], model["backoff"], model["weights"])

rows = []
for r in holdout:
    scores = dict(priors)
    for f in featurize(r["name"]):
        w = weights.get(f)
        if not w:
            continue
        for c in classes:
            scores[c] += w.get(c, backoff[c])
    ranked = sorted(scores.items(), key=lambda kv: -kv[1])
    rows.append((ranked[0][1] - ranked[1][1], ranked[0][0] == r["expected_group"]))

n = len(rows)
print(f"{'margin ≥':>9} {'coverage':>9} {'precision':>10}")
print("-" * 31)
for t in [0, 1, 2, 4, 6, 8, 12, 16, 24]:
    kept = [ok for m, ok in rows if m >= t]
    if not kept:
        continue
    print(f"{t:>9} {len(kept)/n:>8.1%} {sum(kept)/len(kept):>10.1%}")

#!/usr/bin/env python3
"""Synthetic null-model generator for the KS test against AR(1) / random-walk / white-noise.

This is the generator behind the "KS-D vs synthetic null" column of Table 18: it produces
N synthetic monotone cumulative trajectories, fits the same logistic to each, builds the
null distribution of the inflection a_hat, and KS-tests the empirical a_hat distribution
against it. Seeded and reproducible.

Default example: Al-6061 (empirical a_hat = the 146 valid logistic inflections bundled in
`../data/al6061/per_specimen_al6061.tsv`); reproduces KS-D ~ 1.000 (empirical inflections
cluster near 0.08, null inflections near 0.5 -> complete separation).

Requires numpy + scipy (see ../requirements.txt). Run:
    python3 null_model.py            # Al-6061 (bundled empirical a_hat)
    python3 null_model.py --n 1000 --seed 0
"""
import argparse
import csv
import os

import numpy as np
from scipy.optimize import curve_fit
from scipy.stats import ks_2samp

HERE = os.path.dirname(os.path.abspath(__file__))


def logistic(x, a, k):
    return 1.0 / (1.0 + np.exp(-k * (x - a)))


def fit_inflection(y):
    """Normalise a cumulative series to [0,1] over x in [0,1] and return the logistic inflection."""
    y = np.asarray(y, float)
    y = y - y.min()
    if y.max() <= 0:
        return None
    y = y / y.max()
    x = np.linspace(0, 1, len(y))
    try:
        popt, _ = curve_fit(logistic, x, y, p0=[0.5, 10.0],
                            bounds=([0.01, 0.1], [0.99, 100.0]), maxfev=5000)
        return float(popt[0])
    except Exception:
        return None


def synthetic_inflections(n, length, seed):
    """N synthetic monotone cumulatives from AR(1)/RW/WN increments -> logistic inflections."""
    rng = np.random.default_rng(seed)
    out = []
    for i in range(n):
        kind = i % 3
        if kind == 0:                                   # white noise increments
            inc = np.abs(rng.normal(1.0, 1.0, length))
        elif kind == 1:                                 # random walk of |increments|
            inc = np.abs(np.cumsum(rng.normal(0, 1, length)) + rng.normal(1.0, 0.5, length))
        else:                                           # AR(1) increments, phi=0.6
            e = rng.normal(0, 1, length); a = np.zeros(length); a[0] = e[0]
            for t in range(1, length):
                a[t] = 0.6 * a[t - 1] + e[t]
            inc = np.abs(a) + 0.5
        cum = np.cumsum(inc)
        inf = fit_inflection(cum)
        if inf is not None:
            out.append(inf)
    return np.array(out)


def load_emp_al6061():
    f = os.path.join(HERE, "..", "data", "al6061", "per_specimen_al6061.tsv")
    vals = []
    for row in csv.DictReader(open(f), delimiter="\t"):
        if str(row.get("logistic_success", "")).strip().lower() in ("true", "1", "yes"):
            try:
                vals.append(float(row["logistic_inflection"]))
            except (ValueError, KeyError):
                pass
    return np.array(vals)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=1000)
    ap.add_argument("--length", type=int, default=200)
    ap.add_argument("--seed", type=int, default=0)
    args = ap.parse_args()

    emp = load_emp_al6061()
    null = synthetic_inflections(args.n, args.length, args.seed)
    d, p = ks_2samp(emp, null)
    print(f"Al-6061 empirical a_hat: n={len(emp)}  median={np.median(emp):.4f}")
    print(f"Synthetic null a_hat:    n={len(null)}  median={np.median(null):.4f}  (AR(1)/RW/WN, seed={args.seed})")
    print(f"KS-D = {d:.4f}   p = {p:.2e}")
    print("Paper Table 18: Al-6061 KS-D = 1.000, p < 1e-3 (complete separation).")
    print("OK" if d > 0.9 else "DEVIATION")


if __name__ == "__main__":
    main()

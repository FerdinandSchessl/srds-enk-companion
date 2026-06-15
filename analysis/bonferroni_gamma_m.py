#!/usr/bin/env python3
"""Reproduces the paper's KS-test counting and the gamma_M / Bonferroni scheme.

Standard library only. Reads `ks_null_summary.csv` (the six Table-18 substrates with
their KS-D against the synthetic null) and:
  1. recomputes each KS p-value from D and the sample sizes via the asymptotic
     two-sample Kolmogorov formula (no scipy needed),
  2. applies the two thresholds the paper uses and reproduces the headline count.

Two thresholds (see STATISTICS.md):
  * strict   p < 1e-3   -> the headline "five of the six main substrates"
  * gamma_M  = alpha/9 ~ 0.00556  -> the engineering safety-factor analogue
              (Bonferroni-style over the nine-test family); the historical
              "19 of 26" count was over the *extended* 26-substructure set,
              NOT these six.

Run:  python3 bonferroni_gamma_m.py
"""
import csv
import math
import os

ALPHA = 0.05
GAMMA_M = ALPHA / 9.0          # ~ 0.00556
STRICT = 1e-3
HERE = os.path.dirname(os.path.abspath(__file__))


def ks_pvalue(d, n1, n2):
    """Asymptotic two-sample Kolmogorov-Smirnov p-value from statistic d and sizes.
    P(D > d) = 2 * sum_k (-1)^(k-1) exp(-2 k^2 lambda^2),  lambda = (sqrt(ne)+0.12+0.11/sqrt(ne)) d
    ne = n1 n2 / (n1 + n2).  (Exact for large n; over-estimates p for very small n, e.g. DSC n=6.)"""
    ne = n1 * n2 / (n1 + n2)
    lam = (math.sqrt(ne) + 0.12 + 0.11 / math.sqrt(ne)) * d
    s = 0.0
    for k in range(1, 200):
        term = ((-1) ** (k - 1)) * math.exp(-2.0 * (k ** 2) * (lam ** 2))
        s += term
        if abs(term) < 1e-18:
            break
    p = 2.0 * s
    return max(0.0, min(1.0, p))


def main():
    rows = list(csv.DictReader(open(os.path.join(HERE, "ks_null_summary.csv"))))
    print("=" * 78)
    print("KS gegen synthetische Null — gamma_M / Bonferroni-Buchhaltung (Tabelle 18)")
    print(f"gamma_M = alpha/9 = {GAMMA_M:.5f}   |   strikte Schwelle = {STRICT:g}")
    print("=" * 78)
    print(f"{'Substrat':14s} {'n':>5s} {'KS-D':>6s} {'p (reported)':>14s} {'p (asympt. aus D,n)':>22s}")
    n_strict = 0
    n_gamma = 0
    for r in rows:
        d = float(r["ks_d"]); n1 = int(r["n_emp"]); n2 = int(r["n_null"])
        p_asym = ks_pvalue(d, n1, n2)
        prep = f"{r['p_relation'] == 'lt' and '<' or ''}{float(r['p_reported']):g}"
        # for counting use the reported p where exact, else the asymptotic
        p_use = float(r["p_reported"]) if r["p_relation"] == "eq" else min(float(r["p_reported"]), p_asym)
        if p_use < STRICT:
            n_strict += 1
        if p_use < GAMMA_M:
            n_gamma += 1
        print(f"{r['substrate']:14s} {n1:>5d} {d:>6.3f} {prep:>14s} {p_asym:>22.2e}")
    n = len(rows)
    print("-" * 78)
    print(f"unter strikter Schwelle p < {STRICT:g}:   {n_strict}/{n}   "
          f"(erwartet 5/6 — DSC Grenzfall p=0.18 > 1e-3)")
    print(f"unter gamma_M = {GAMMA_M:.5f}:          {n_gamma}/{n}   "
          f"(DSC faellt auch hier: 0.18 > {GAMMA_M:.5f})")
    print()
    ok = (n_strict == 5 and n_gamma == 5)
    print("REPRODUKTION DER HEADLINE:", "OK (5/6 strikt, 5/6 unter gamma_M — DSC faellt beide)" if ok else "ABWEICHUNG")
    print("Hinweis: die historische '19 von 26'-Zaehlung war der gamma_M-Count ueber die")
    print("erweiterte 26-Substruktur-Aufstellung (S8), NICHT ueber diese sechs Haupt-Substrate.")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())

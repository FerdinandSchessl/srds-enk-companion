#!/usr/bin/env python3
"""
Lignin â — RICHTIG: Form ist festgelegt (Weibull, Mode (ii) seriell-kaskadiert,
Schwächste-Glied-Versagen β-O-4 vor 5-5). Kein AICc-Form-Wettbewerb.
Wir legen die Weibull-CDF an die Ordnungsparameter-Kurve Q(Σ) an und lesen die
Inflektion ab.

Σ  = normierter P-Faktor (Last/Dosis, linear — wie alle Substrate, kein log).
Q  = normierte β-O-4-Degradation (Schädigung steigt mit Last): (bO4max - bO4)/(bO4max - bO4min).
Weibull-CDF: Q(Σ) = L * (1 - exp(-(Σ/λ)^m)).
Inflektion (m>1): Σ* = λ * ((m-1)/m)^(1/m).   k (Steilheit) = m (Form-Parameter).
"""
import csv, math
import numpy as np
from scipy.optimize import curve_fit

import os
CSV = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "lignin", "sp_lcc_data_master.csv")
rows = [r for r in csv.DictReader(open(CSV)) if r.get("b-O-4", "").strip() and r.get("p-factor", "").strip()]
P = np.array([float(r["p-factor"]) for r in rows])
B = np.array([float(r["b-O-4"]) for r in rows])
n = len(P)

Sig = (P - P.min()) / (P.max() - P.min())
Q = (B.max() - B) / (B.max() - B.min())   # degradation, 0->1 mit Last


def weibull_cdf(x, L, lam, m):
    xc = np.clip(x, 1e-12, None)
    return L * (1.0 - np.exp(-np.power(xc / lam, m)))


def inflection(lam, m):
    if m <= 1:
        return 0.0  # konkav -> Inflektion am Rand (sehr frühes Versagen)
    return lam * ((m - 1.0) / m) ** (1.0 / m)


def fit(x, y, label):
    try:
        p, _ = curve_fit(weibull_cdf, x, y, p0=[1.0, 0.4, 2.0],
                         bounds=([0.5, 0.05, 0.3], [1.5, 3.0, 12.0]), maxfev=200000)
        L, lam, m = p
        yh = weibull_cdf(x, *p)
        r2 = 1 - np.sum((y - yh) ** 2) / np.sum((y - y.mean()) ** 2)
        ah = inflection(lam, m)
        print(f"  {label:18s} â={ah:.3f}  m(k)={m:.2f}  λ={lam:.3f}  L={L:.3f}  R²={r2:.3f}")
        return ah, m, r2
    except Exception as e:
        print(f"  {label}: FIT-FEHLER {e}")
        return None


print(f"Lignin SP-LCC, n={n} Bedingungen. Weibull-CDF (Form festgelegt = Mode ii).")
print("Ziel-Vergleich: alter Frame-Wert â=0.325, k=2.86")
order = np.argsort(Sig)
fit(Sig[order], Q[order], "roh (alle Pkt)")
for nb in (6, 8, 10):
    edges = np.linspace(0, 1, nb + 1)
    xc, yc = [], []
    for i in range(nb):
        m_ = (Sig >= edges[i]) & (Sig <= edges[i + 1] if i == nb - 1 else Sig < edges[i + 1])
        if m_.sum() > 0:
            xc.append(Sig[m_].mean()); yc.append(Q[m_].mean())
    fit(np.array(xc), np.array(yc), f"gebinnt ({nb} bins)")

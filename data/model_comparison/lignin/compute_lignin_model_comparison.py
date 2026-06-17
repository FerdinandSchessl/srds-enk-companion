#!/usr/bin/env python3
"""
Lignin (SP-LCC) order-parameter model comparison + inflection.

Reviewer-reproducible foundation for the Tab-6 form-class assignment.
Reads the bundled SP-LCC export (Alopaeus et al. 2025, doi:10.1038/s41597-025-05327-8)
and fits the four saturation-class forms (Logistic / Gompertz / Weibull-CDF / Hill)
to the lignin degradation curve Q(Σ) = normalized beta-O-4 loss vs normalized pulping
severity (P-factor), then reports AICc and the inflection a_hat.

Two severity axes are diagnosed because the P-factor is a log time-temperature integral
(textbook Kraft kinetics): linear-P and log-P. NOTE: the form is physically FIXED = Weibull
Mode (ii) (weakest-link, b-O-4 first); the free AICc contest below is diagnostic only, not the
form selector (forcing a logistic shape imposes an inflection the data do not carry). The
fixed-form Weibull fit (weibull_ahat.py) gives m < 1, concave from origin = NO interior a_hat;
only rho_S = -0.78 (axis-free) is reported.

Usage:  python3 compute_lignin_model_comparison.py
Deps:   numpy, scipy  (stdlib csv/json/math)
"""
import csv, json, math
from pathlib import Path
import numpy as np
from scipy.optimize import curve_fit

HERE = Path(__file__).resolve().parent
CSV = HERE.parent.parent / "lignin" / "sp_lcc_data_master.csv"

rows = [r for r in csv.DictReader(open(CSV))
        if r.get("b-O-4", "").strip() and r.get("p-factor", "").strip()]
P = np.array([float(r["p-factor"]) for r in rows])
B = np.array([float(r["b-O-4"]) for r in rows])
n = len(P)

# order parameter Q: normalized beta-O-4 loss, rising 0->1 with severity
deg = (B.max() - B) / (B.max() - B.min())


def logistic(x, L, k, a):  return L / (1 + np.exp(-k * (x - a)))
def gompertz(x, L, k, a):  return L * np.exp(-np.exp(-k * (x - a)))
def hill(x, L, m, a):      xc = np.clip(x, 1e-9, None); return L * xc**m / (a**m + xc**m)
def weibull(x, L, m, lam): xc = np.clip(x, 1e-9, None); return L * (1 - np.exp(-(xc / lam)**m))

MODELS = {"Logistic": (logistic, [1, 5, 0.4]),
          "Gompertz": (gompertz, [1, 5, 0.4]),
          "Hill":     (hill,     [1, 3, 0.4]),
          "Weibull":  (weibull,  [1, 2, 0.4])}


def inflection(f, p):
    xs = np.linspace(0, 1, 4001)
    return float(xs[np.argmax(np.gradient(f(xs, *p), xs))])


def aicc(y, yhat, k):
    rss = max(float(np.sum((y - yhat) ** 2)), 1e-12)
    a = n * math.log(rss / n) + 2 * k
    if n - k - 1 > 0:
        a += 2 * k * (k + 1) / (n - k - 1)
    return a, rss


def run(x_raw, label):
    x = (x_raw - x_raw.min()) / (x_raw.max() - x_raw.min())
    out = {}
    for name, (f, p0) in MODELS.items():
        try:
            p, _ = curve_fit(f, x, deg, p0=p0, maxfev=200000)
            yhat = f(x, *p)
            a, rss = aicc(deg, yhat, len(p))
            r2 = 1 - rss / float(np.sum((deg - deg.mean()) ** 2))
            out[name] = {"AICc": round(a, 2), "R2": round(r2, 3),
                         "a_hat": round(inflection(f, p), 3), "k_or_shape": round(float(p[1]), 2)}
        except Exception as e:
            out[name] = {"error": str(e)}
    winner = min((m for m in out if "AICc" in out[m]), key=lambda m: out[m]["AICc"])
    return {"severity_axis": label, "winner_by_AICc": winner, "models": out}


from scipy import stats
rho = float(stats.spearmanr(B, P).correlation)
result = {
    "substrate": "Lignin (SP-LCC)",
    "source": "Alopaeus et al. 2025, Scientific Data, doi:10.1038/s41597-025-05327-8",
    "n": n,
    "spearman_bO4_vs_Pfactor": round(rho, 4),
    "linear_P": run(P, "linear-P"),
    "log_P": run(np.log(P), "log-P (Kraft severity is a log time-temperature integral)"),
    "note": ("Lignin form is physically FIXED = Weibull Mode (ii), serial-cascaded weakest-link "
             "(phenolic b-O-4 breaks well before non-phenolic / 5-5). A free AICc form-contest is NOT "
             "decisive here: forcing a logistic shape imposes an inflection the data do not carry. The "
             "fixed-form Weibull fit (weibull_ahat.py, same n=72) gives m ~ 0.49 (< 1), concave from the "
             "origin -> NO interior a_hat: the broad b-O-4 strength distribution already yields at the "
             "smallest dose (Woehler creep side, no endurance limit). Reported headline: rho_S = -0.78 "
             "(axis-free, Spearman b-O-4 vs P-factor). The free-fit a_hat ~ 0.21/0.42 are form artefacts, "
             "not reported findings; the earlier a_hat=0.325, k=2.86 (lost n=90 module) does not reproduce."),
}

(HERE / "summary_lignin.json").write_text(json.dumps(result, indent=2))
print(json.dumps(result, indent=2))

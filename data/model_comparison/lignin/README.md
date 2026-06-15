# Lignin (SP-LCC) — model comparison for the Tab-6 form class

Reviewer-reproducible basis for the lignin entry in Table 6 of the paper.

**Run:** `python3 compute_lignin_model_comparison.py` → `summary_lignin.json`
**Data:** `../../lignin/sp_lcc_data_master.csv` (Alopaeus et al. 2025, doi:10.1038/s41597-025-05327-8, n=72).

## Finding (firsthand-reproducible)
- Order parameter `Q(Σ)` = normalized β-O-4 loss vs normalized pulping severity (P-factor).
- AICc over the saturation-class family {Logistic, Gompertz, Weibull-CDF, Hill}:
  **Logistic wins** (AICc ≈ −259); **Weibull is dominated** (AICc ≈ −236, R²≈0.59).
  → The earlier Table-6 label "Weibull / serially-cascaded" is **not** supported by the data;
  the data-supported form is **Logistic**.
- Inflection `a_hat` is **severity-axis dependent**:
  - linear-P: a_hat ≈ 0.21, k ≈ 4.8
  - log-P (Kraft severity is a log time-temperature integral, k ≈ 3.1 ≈ the paper's k=2.86): a_hat ≈ 0.41
  - Both < 0.5 → early/creep regime; the weakest-link narrative holds either way.
- The headline **ρ_S(β-O-4, P-factor) = −0.78** is axis-free and unchanged (reproduce.py [15]).

## Note on the legacy value a_hat = 0.325 / k = 2.86
That pair came from an earlier, lost n=90 text module (different sample set), not from SP-LCC.
On the bundled SP-LCC data it does not reproduce under any natural construction (linear → 0.21,
log-P → 0.41). The canonical Table-6 value is to be set from THIS reproducible computation.

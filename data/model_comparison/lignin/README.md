# Lignin (SP-LCC) — order-parameter data for the Table-6 lignin entry

Reviewer-reproducible data basis for the lignin entry in Table 6.

**Data:** `../../lignin/sp_lcc_data_master.csv` (Alopaeus et al. 2025, doi:10.1038/s41597-025-05327-8;
95 samples under 72 process conditions).

## Form class follows from the aggregation mechanics, NOT from a fit contest
Lignin Kraft pulping is **serial-cascaded weakest-link failure**: the weak β-O-4 bonds (~60 kJ/mol)
yield before the strong 5-5 linkages (~85 kJ/mol). In the SRDS aggregation taxonomy this is
**Mode (ii) → Weibull** (§2.4 / FRAME_ANCHOR §A). That is a *mechanistic* assignment from the
failure topology — it is **not** chosen by letting a curve-fitter pick whichever form scores best.

- **Headline (canonical):** Weibull (Mode ii), $\rho_S(\beta\text{-O-4}, P) = -0.78$ — **no interior $\hat{a}$** (broad β-O-4 strength distribution → concave from origin, $m<1$, no endurance limit; inflection below the tested severity range; firsthand Schlee 2023 / Mattsson 2017). The earlier $\tilde{a}=0.325$, $k=2.86$ (lost $n=90$ module) does not reproduce.
- `compute_lignin_model_comparison.py` runs an AICc comparison across {Logistic, Gompertz, Weibull, Hill}.
  Its output is **descriptive fit-quality only** and is reported for transparency — it does **not**
  determine the form class. (Treating AICc fit-scores as the form selector is the ML/curve-fitting
  framing the framework explicitly rejects: the physics of bond-hierarchy failure fixes the mode.)
- The construction-free, axis-free statistic **$\rho_S = -0.78$** is reproduced by `reproduce.py` [15].

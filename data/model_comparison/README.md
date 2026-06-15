# Model comparison (§2 form-class typology)

AIC/BIC model-fit comparison over the closed saturation family (Logistic, Gompertz,
Weibull-CDF, Hill) per substrate — the source of the §2 numbers about which form wins and
the per-substrate inflection-outcome correlation.

Files: `summary_<substrate>.tsv` (per model: n_valid, median AIC/BIC, median R², win_rate_aic,
rho_inflection_outcome) + `aggregate.json` (Al-6061 detail).

## §2 numbers covered here

| substrate | file | Logistic AIC-win | note |
|---|---|---|---|
| Battery CALB | `summary_battery.tsv` | **1.00 (100 %)** | ρ(â,outcome)=+0.848 |
| FKM fluoroelastomer | `summary_fkm.tsv` | ~0.80 | win_rate_aic column |
| Dryad elastomer (NR/Shore-60) | `summary_dryad_elastomer.tsv` | per model rows | |
| Wood | `summary_holz.tsv` | dominant | |
| Al-6061 | `summary_al6061.tsv` | Gompertz-win (No-Go form exception) | ρ=−0.703 |

"6 of 8 substrates Logistic-dominant" and the mode-typology typicals (ã≈0.55 for parallel-
instantaneous, ≈0.30 for serial-cascaded) are read across these per-substrate summaries.
**Not bundled here** (working-repo `analysis/null_model_comparison/`): the CCP60 elastomer
variant (n=9, Weibull-win, ρ=+0.867) and the multiaxial-fatigue path-shift (ρ≈−0.30, p=0.029),
which run on the same pipeline; pointers in `../../COVERAGE_REPORT.md`.

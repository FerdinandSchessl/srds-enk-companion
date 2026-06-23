# Statistical layer — how every inferential claim is reproduced

`reproduce.py` recomputes the **point estimates** (â, medians, r, ρ, KS-D). This document
covers the **inferential** layer: the null-model KS tests, the permutation test, the
multiple-comparison correction (γ_M / Bonferroni), the bootstrap, and cluster-robust
inference — with, for each, the script that reproduces it.

No-package scripts (Python standard library only) are marked **[stdlib]**; the rest need
`numpy`/`scipy`/`pandas` (see `requirements.txt`) and are marked **[scipy]**.

| Statistical claim (paper) | Reproduced by | Type |
|---|---|---|
| KS-D vs synthetic null per substrate (Table 18) | `analysis/null_model.py` (regenerates the AR(1)/RW/WN null + KS; Al-6061 example from bundled â) | [scipy] |
| "5 of 5 main substrates p < 10⁻³" + γ_M scheme | `analysis/bonferroni_gamma_m.py` (+ `analysis/ks_null_summary.csv`) | [stdlib] |
| Wood permutation p_perm < 10⁻³⁰ | `analysis/permutation_test.py` (10⁴ permutations of r, seeded) | [stdlib] |
| CRC bootstrap (MSI/MSS, KS-D = 0.350) | `data/crc/crc_results_v2.json → bootstrap` (500 resamples; re-run via `data/crc/domain_crc_v2.py`) | [scipy] |
| CRC stage-aggregated Δâ = −0.153 | `data/crc/crc_stage_aggregated.json`; re-fit `data/crc/domain_crc_v2.py` | [scipy] |
| ENK cluster-robust ρ = −0.359 (turn-pair level) | aggregate in `data/enk/ahat_convergence.csv`; **full cluster-robust needs the raw turn-pairs (under DUA, not redistributable)** | limited |
| ParlaMint ℓ₃→ℓ₄ BCa-CI + country-permutation (§5 pilot) | `data/parlamint/pilot_inference.json` (country-cluster BCa B=10⁴ + 4! country permutation); `reproduce.py` [13] recomputes ρ from `pilot_country_year.csv` | [stdlib] ρ; BCa/perm machine-stored |
| LOPO (Macro 0.339), Holm-Bonferroni hold-out | documented in the full working repo (not in this lean companion) | external |

## The two thresholds (this is the historical source of confusion)

The paper uses **two** thresholds; keeping them apart matters:

1. **Strict `p < 10⁻³`** — the headline: all five Table-18 substrates clear it.
2. **γ_M = α/9 ≈ 0.00556** — the engineering safety-factor analogue, a Bonferroni-style
   threshold over the nine-test family. All five clear this as well.

The earlier **"19 of 26"** figure was the γ_M count over the *extended 26-substructure*
exploratory set (sector ETFs, forced materials, etc. — supplement S8), **not** over these five
main substrates. `bonferroni_gamma_m.py` reproduces the 5/5 count and prints this note.

**Withdrawn substrate (for the record).** An earlier exploration also ran a DSC protein-melt KS
test (n = 6); it was withdrawn from Table 18 due to a provenance gap and is no longer part of the
count. For completeness, its canonical value was `D = 0.42, p = 0.18` — a named borderline that did
not clear `p < 10⁻³`; an even earlier draft's `p = 0.0016` is not reproducible from `D = 0.42, n =
6` by any KS procedure.

## Null model (what the KS test is against)

For each substrate, 1000 synthetic monotone cumulative trajectories are generated from
AR(1), random-walk, and white-noise increments, the **same logistic** is fitted to each, and
the empirical â distribution is KS-tested against the resulting null â distribution.
`null_model.py` runs this end-to-end (default: Al-6061, whose 146 empirical inflections cluster
near 0.08 while the null clusters near 0.5 → KS-D ≈ 1.000). `ks_null_summary.csv` holds the five
Table-18 results; `bonferroni_gamma_m.py` also recomputes each KS p-value from D and the sample
sizes via the asymptotic Kolmogorov formula (stdlib), as an independent cross-check.

## What is and is not fully reproducible here

- **Fully reproducible from this folder:** all point estimates (`reproduce.py`), the γ_M/
  Bonferroni counting, the wood permutation, the CRC stage fit + bootstrap (with scipy), and
  the null-model KS for any substrate whose â distribution is bundled (Al-6061 shipped as the
  worked example; battery â is in `data/battery/battery_calb_results.json`).
- **Bounded by the DUA:** ENK cluster-robust inference needs the raw per-turn-pair data, which
  contains real conversations and cannot be redistributed; only the aggregated â/manipulation
  pairs are bundled (`data/enk/ahat_convergence.csv`, chat_id anonymised).
- **Left in the full working repo:** LOPO and the Holm-Bonferroni hold-out (they depend on the
  full ENK pipeline); referenced here for completeness.

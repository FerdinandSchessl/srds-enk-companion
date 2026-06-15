# ParlaMint ℓ₃→ℓ₄ bridge pilot (parliamentary speeches → V-Dem polyarchy)

**Status:** §5 *best-light directional pilot* — explicitly **POSTULATED** (operationalisation open;
full triangulation with Twitter/Reddit is future work). This is **not** one of the ten
load-bearing substrates; it is the cantilever/bridge proof-of-concept for the
addressee-as-support model. Reproducible, but framed as a pilot in the paper.

**Configuration:** speeches as the ℓ₃ discourse layer, the V-Dem **polyarchy** index (annual,
per country) as the ℓ₄ societal support. Four clusters (HU, PL, RS, SI), **65 country-years**,
G = 4. Sensor: `paraphrase-multilingual-MiniLM-L12-v2` (multilingual, HU/PL/RS/SI-calibrated).

## Headline numbers (paper §5)

| axis | ρ_S vs polyarchy drift | BCa-CI₉₅ (country-cluster, B=10⁴) | p |
|---|---|---|---|
| **NC2 geometry** | **−0.3401** (n=65) | [−0.4775, −0.0904] | 0.006 (classical Spearman) |
| **â discourse** | −0.2365 (n=65) | [−0.3370, −0.1488] (excludes null) | 0.058 classical |
| per cluster (â) | HU −0.395, PL −0.524, RS −0.211, SI −0.400 (4/4 negative) | — | — |
| country-permutation | ρ_obs −0.2365 | — | **0.207** (4! / B=10⁴, **tail-arm at G=4, not load-bearing**) |

The load-bearing statistic is the BCa-CI plus the sign convergence over four independent
clusters; the permutation p is tail-arm at G=4 and explicitly *not* relied upon.

## Files

- `pilot_country_year.csv` — 65 country-years × {nc2_median, a_hat_diskurs, …, polyarchy, drift_rate}. **This is the reproduction input.**
- `pilot_inference.json` — machine-stored results: country-cluster BCa bootstrap (B=10⁴) + per-cluster ρ + country permutation. Matches the table above.

## Reproduce

`python3 ../../reproduce.py` (block **[13] PARLAMINT**) recomputes the Spearman ρ's
(NC2, â-discourse, per cluster) from `pilot_country_year.csv` with the standard library.

## Sources (external, public)

- **Speeches:** ParlaMint (CLARIN ERIC), public corpus — HU/PL/SI/RS national parliaments.
  Per-speech ENK metrics (`pilot_metrics.csv`, 15 548 speeches) are derivable from the public
  corpus with `pilot_pipeline.py` (full working repo); not bundled here (size; public record).
- **Polyarchy:** V-Dem (`v-dem.net`).

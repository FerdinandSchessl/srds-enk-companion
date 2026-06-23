# How to reproduce every headline number

**One command, standard library only:**

```bash
python3 reproduce.py
```

It prints, for each substrate, the paper value next to the value recomputed from the
bundled data, with `PASS`/`FAIL`, and exits non-zero if anything deviates. Expected:
`RESULT: all 33 numeric checks PASSED.`

Every number in the paper maps to a bundled file below. Where the raw dataset is large
or third-party, the **fit output** is bundled (so the headline is verifiable from this
folder) and the **raw source** is linked (so the fit itself can be re-run end-to-end).

| # | Substrate | Paper number | Bundled file (verify here) | Raw source (re-fit from scratch) |
|---|---|---|---|---|
| 1 | Wood (DIN EN 408) | r = −0.83; ã = 0.567; n = 230 | `data/holz_master/wood_data_all.csv` | Zenodo `10.5281/zenodo.18340365` |
| 2 | Al-6061 tensile | ã = 0.084 (median, n = 146); ρ = −0.703; KS-D = 1.000 | `data/al6061/per_specimen_al6061.tsv`, `summary_al6061.tsv` | Mendeley `10.17632/rd6jm9tyb6.2` |
| 3 | Multi-material multiaxial fatigue | ã = 0.578; n = 914 (136 metals) | `data/fatigue/multiaxial_fatigue_results.json` | Chen et al. 2024 Sci Data `10.1038/s41597-024-03862-4` |
| 4 | Battery CALB | ã = 0.646; KS-D = 0.733; ρ(EOL) = +0.18 n.s. | `data/battery/battery_calb_results.json` | HF `Battery-Life/BatteryLife_Raw` (arXiv:2502.18807) |
| 5 | Earthquakes USGS | ã = 0.452; median R² = 0.965; ρ(mainshock) = +0.673; n = 284 | `data/earthquake/earthquake_results.csv` (+ `usgs_earthquakes.csv`) | USGS FDSN `earthquake.usgs.gov/fdsnws/event/1/` |
| 6 | Colorectal TCGA | **stage** MSI 0.286 / MSS 0.439 (Δ = −0.153); KS-D = 0.350; n = 579 | `data/crc/crc_stage_aggregated.json` + `crc_results_v2.json` | re-fit: `python3 data/crc/domain_crc_v2.py` (pandas+scipy) on `data/crc/tcga_crc_combined.csv` |
| 7 | V-Dem ERT-v14 | median R² = 0.983; 89 of 117 fitted | `data/vdem/srds_vdem_results.csv` | V-Dem `v-dem.net/data/ert/` |
| 8 | Finance SPY | crash R² = 0.973 vs calm 0.483 | `data/finance/event_results_v3.csv` | Yahoo Finance via `yfinance` |
| 9 | ENK LLM conversations | ρ = −0.359 (n = 202); Ridge 0.700 | `data/enk/ahat_convergence.csv` (chat_id anonymised) | raw chats under DUA — not redistributable (aggregated metrics only) |
| 10 | Music MIDI | n = 2840; median R² = 0.975; Mann-Kendall τ = +1.000 | `data/musik_companion/outputs/` (+ `pipeline/`) | MetaMIDI Zenodo `10.5281/zenodo.5142664` + Tagtraum CD2C + music21 |
| 11 | DP1180 high-strength steel (Tab. 18) | ã = 0.975; KS-D = 1.000; n = 19 | `data/dp1180/numisheet_results.json` | NIST Numisheet 2020 (`data.nist.gov`, DIC uniaxial tension) |
| 12 | ParlaMint ℓ₃→ℓ₄ pilot (§5; *not* a substrate) | NC2 ρ=−0.34 (BCa [−0.48,−0.09]); â-discourse 4/4 neg.; country-perm p=0.207 | `data/parlamint/pilot_country_year.csv` + `pilot_inference.json` | ParlaMint CLARIN + V-Dem |

## Notes on two values that are *deliberately* dual

- **Colorectal Δã.** The canonical headline is the **stage-aggregated** result (MSI 0.286 < MSS 0.439, Δ = −0.153): along the stage/load axis the mismatch-repair-deficient class yields earlier (pre-specified negative sign). Sorting the population by FGA or within-stage by mutation count gives Δ = +0.05/+0.09 — a counting-sort artefact, stored in `crc_results_v2.json → group_results`, **not** the headline. Both are kept so the artefact is transparent. `crc_stage_aggregated.json` holds the headline; `domain_crc_v2.py` (ANALYSIS 2) re-derives it.
- **Al-6061 ã.** `0.084` is the **median of the logistic inflection over the 146 valid fits** (`per_specimen_al6061.tsv`). The mean over all 154 specimens is `0.282` (heavy right skew); that mean is *not* the headline. `reproduce.py` recomputes the median.

## What is NOT recomputed stdlib-only

`reproduce.py` recomputes 33 numbers from the bundled data with the standard library.
The colorectal stage fit and the DP1180 KS test against the synthetic null require a
curve fit / null model (numpy+scipy); for those the bundled **result** is checked, and the
**raw data + script** are bundled (CRC) or linked (DP1180) so a reviewer with numpy/scipy
can re-run the fit. Every paper number is therefore either recomputed here or re-runnable
from a bundled/linked source — nothing rests on an unshipped value.

# Companion — SRDS+ENK Paper

**Paper:** "Self-Referential Dissipative Systems: A Materials Test Across Ten Substrates" (Schessl 2026, arXiv submission in preparation, DE 52p / EN 50p).

This folder contains all reproduction artifacts that cover the paper on their own (Lean-4 proofs, raw/fit data for the ten substrates, pipeline scripts, genealogy). It is structured so that a reviewer can clone it in isolation, navigate it, **and recompute** the numbers.

## Reproduction (one command)

```bash
python3 reproduce.py     # standard library only; expects: "all 33 numeric checks PASSED"
```

The script recomputes every headline number from the bundled data and compares it against the paper value (PASS/FAIL, exit code ≠ 0 on any mismatch; currently 33 checks incl. statistics). **`REPRODUCE.md`** is the authoritative map: per number → bundled file → external raw source (DOI/URL) → test command. Where the raw dataset is external/large, the **fit output** sits in the folder (number checkable here) and the **raw source** is linked (fit traceable end-to-end).

**Statistics layer:** `STATISTICS.md` + `analysis/` reproduce the inference (KS against a synthetic null, permutation test, γ_M/Bonferroni count, bootstrap). The stdlib tests (γ_M count, timber permutation) run directly in `reproduce.py`; the scipy scripts (`analysis/null_model.py`, `data/crc/domain_crc_v2.py`) need `requirements.txt`. The ENK cluster-robust inference is DUA-limited (only aggregates shareable) — details in `STATISTICS.md`.

## The ten substrates (overview)

Per-substrate detail in `REPRODUCIBILITY_MANIFEST.md` (§-numbers on the right).

| # | Substrate | n | Core finding | Manifest |
|---|---|---|---|---|
| 1 | Timber (DIN EN 408) | 230 | $r = -0.83$; $\tilde{a} = 0.567$ | §4.1 |
| 2 | Multi-material multiaxial fatigue | 914 | $R^2 \geq 0.5$ in 74% of metals | §4.2 |
| 3 | Finance (SPY) | 10 / 135 | crash $R^2 = 0.973$ / calm $0.483$ | §4.3 |
| 4 | Lignin/LCC (SP-LCC, Alopaeus 2025) | 72 cond. | $\rho_S = -0.78$ (β-O-4 vs P-factor); Weibull (mode ii) — no interior $\hat{a}$ ($m<1$, concave, no endurance limit) | §4.4 |
| 5 | V-Dem autocratizations | 117 | median $R^2 = 0.983$ | §4.5 |
| 6 | Earthquakes (USGS) | 284 | $\rho(\hat{a}, \text{mainshock}) = +0.673$ | §4.7 |
| 7 | Battery (CALB) | 26 | KS-D $= 0.733$; $\tilde{a} = 0.646$; $\rho(\text{EOL}) = +0.18$ n.s. | §4.8 |
| 8 | Colorectal (TCGA) | 579 | $\Delta\tilde{a}$ (MSI–MSS) $= -0.153$ | §4.9 |
| 9 | LLM conversation (ENK Gold) | 202 | $\rho = -0.359$; ridge $0.700$ | §4.10 |
| 10 | Music (MetaMIDI / music21) | 2,840 | median $R^2 = 0.975$; $\tau = +1.000$ | §4.11 |

**Not a substrate:** political speeches (Bundestag/ParlaMint) are a V-Dem failure mode (§4.6). Pre-registered null controls (not substrates): ProsocialDialog, Sotopia, Google COVID Mobility (§8.1).

## Contents

| Path | Content |
|---|---|
| `reproduce.py` | Self-contained reproduction check of all headline numbers (stdlib only, 33 checks) |
| `REPRODUCE.md` | Map: per number → bundled file → raw source → test command |
| `STATISTICS.md` | Inference layer: KS null, permutation, γ_M/Bonferroni, bootstrap — claim → script |
| `COVERAGE_REPORT.md` | **Full accounting: all 614 paper numbers (DE+EN) → reproduction path/category** |
| `requirements.txt` | Environment (stdlib for `reproduce.py`; numpy/scipy only for re-fits) |
| `analysis/bonferroni_gamma_m.py` | [stdlib] γ_M/Bonferroni count (5/5 strict, 5/5 under γ_M) from `ks_null_summary.csv` |
| `analysis/permutation_test.py` | [stdlib] Timber permutation test (10⁴×, seed=0) → p_perm |
| `analysis/null_model.py` | [scipy] Synthetic-null generator (AR(1)/RW/WN) + KS, Al-6061 example |
| `analysis/ks_null_summary.csv` | Five Tab.-18 substrates: KS-D + p (source of the γ_M count) |
| `REPRODUCIBILITY_MANIFEST.md` | Per paper table/figure: script path, raw-data path, external URLs |
| `lean4/PositivityProofs/` | No-Go in Lean 4, **computer-assisted**: the certified `nogo_theorem_certified` is **sorry-free** (built firsthand, 0 `sorryAx` — evidence `lean4/CHECKAXIOMS_OUTPUT.txt`) and, per `#print axioms`, depends on **12 project axioms** (2 numerical-certificate + 10 IFT-bridge) + 3 Lean foundational axioms. The general `nogo_theorem` (all ε,η) is a **conjecture/axiom**. *(Three reference counts: `#print axioms`=12 · `AxiomAudit.lean` inventory=18 · `grep '^axiom'`=27 — all explained in the evidence file.)* |
| `genealogy_of_frames.md` | 8 dated precursor frame-classes (master's thesis 2025 → SRDS 2026) |
| `data/earthquake/` | USGS-FDSN API sequences, 284 sequences, six regions (`usgs_earthquakes.csv`, `earthquake_results.csv`) |
| `data/battery/` | CALB Li-ion degradation, $n = 26$ cells / 3 temperatures (`battery_calb_results.json`; raw external at HF `Battery-Life/BatteryLife_Raw`) |
| `data/crc/` | TCGA colorectal, $n = 579$ (`tcga_crc_combined.csv`, `crc_results_v2.json`, `crc_stage_aggregated.json`; re-fit `domain_crc_v2.py` + `srds_core.py`) |
| `data/holz_master/` | Timber DIN EN 408, $n = 319$ → balanced $n = 230$; raw data via Zenodo DOI (see `data/holz_master/README.md`) |
| `data/lignin/` | SP-LCC dataset (Alopaeus 2025, doi:10.1038/s41597-025-05327-8): `sp_lcc_data_master.csv` (72 samples); $\rho_S(\beta\text{-O-4},P)=-0.78$, `reproduce.py` [15] |
| `data/al6061/` | Al-6061 tensile per-specimen fits (`per_specimen_al6061.tsv`, `summary_al6061.tsv`); ã = 0.084 median of valid fits, $n = 146$ |
| `data/dp1180/` | DP1180 NIST Numisheet 2020 (`numisheet_results.json`); ã = 0.975, KS-D = 1.000, $n = 19$ |
| `data/fatigue/` | Multi-material multiaxial fatigue result (`multiaxial_fatigue_results.json`); ã = 0.578, $n = 914$ |
| `data/vdem/` | V-Dem ERT-v14 episode fits (`srds_vdem_results.csv`); median $R^2 = 0.983$, 89/117 |
| `data/finance/` | SPY event fits (`event_results_v3.csv`); crash $R^2 = 0.973$ vs. calm $0.483$ |
| `data/enk/` | ENK conversation â aggregate (`ahat_convergence.csv`, `chat_id` anonymized; raw chats under DUA) |
| `data/parlamint/` | ParlaMint ℓ₃→ℓ₄ pilot (§5, **not** a Tab-1 substrate): country-year aggregate + `pilot_inference.json`; NC2 ρ=−0.34, â-discourse 4/4 neg., perm-p=0.207 |
| `data/model_comparison/` | §2 form-class typology (AIC win rates per substrate: battery 100%, FKM ~80%, …) |
| `data/cross_corpus/` | §6 cross-corpus aggregates (Avrami kinetics per corpus); 12 raw corpora external (licenses) |
| `data/musik_companion/pipeline/` | Pipeline scripts for MetaMIDI/Tagtraum/music21 ($\ell_2$ substrate) |
| `data/musik_companion/outputs/` | Pipeline outputs (`musik_l2_lakh_cross_genre.json`, `musik_l2_music21_all_raw.json`, shuffled control) |

## External data sources (not in this folder because externally published)

- **MetaMIDI Dataset:** Zenodo `10.5281/zenodo.5142664` (Ens & Pasquier 2021)
- **Tagtraum CD2C genre labels:** `tagtraum.com/genres/msd_tagtraum_cd2c.cls.zip`
- **USGS Earthquake Catalog API:** `earthquake.usgs.gov/fdsnws/event/1/`
- **TCGA Pan-Cancer Atlas:** `portal.gdc.cancer.gov` (open access)
- **V-Dem ERT-v14:** `v-dem.net/data/ert/`
- **Yahoo Finance SPY:** `finance.yahoo.com` (via `yfinance`)
- **Multi-material multiaxial fatigue:** Chen et al. 2024 Sci Data `10.1038/s41597-024-03862-4` (914 strain-controlled specimens, 136 materials)
- **Al-6061 tensile (raw stress-strain):** Mendeley Data `10.17632/rd6jm9tyb6.2`
- **DP1180 high-strength steel:** NIST Numisheet 2020 benchmark, `data.nist.gov` (DIC uniaxial tension)
- **Master's thesis Schessl 2025 (timber data anchor):** Zenodo `10.5281/zenodo.18340365`
- **ENK gold corpus:** private under DUA ($n = 202$ LLM conversations) — not publicly distributable

## License

The code (Lean 4, Python scripts) is under MIT (see `LICENSE`). The raw data are subject to their respective source licenses (see external URLs).

## Longer version

This companion is self-contained and covers the SRDS+ENK paper. A more extensive version is in preparation.

# Reproducibility Manifest — Paper

**Last updated:** 2026-06-23
**Paper:** "Self-Referential Dissipative Systems: A Materials Test Across Ten Substrates" (Schessl 2026, arXiv submission).
**Purpose:** Every number stated in the paper is traceable through this manifest to a source file — either in the bundled folders (`data/`, `lean4/`, `analysis/`) or via the external URLs in `README.md`.
**Verification:** `python3 reproduce.py` recomputes all headline numbers from the bundled data (33 checks incl. the statistics layer, PASS/FAIL, exit ≠ 0 on mismatch). `REPRODUCE.md` = map number → file → raw source → test; `STATISTICS.md` + `analysis/` = inference layer (KS null, permutation, γ_M/Bonferroni, bootstrap).

---

## 1. Theory (Lean 4)

### Axioms A0–A4, regularity conditions L1–L4, theorems T1–T3, no-go theorem (§2)
- **Proofs:** `lean4/PositivityProofs/`
  - `AxiomAudit.lean` — axiom consistency check
  - `Basic.lean` — foundational definitions
  - `HilbertMetric.lean` — Hilbert metric for $TP_2$ kernels
  - `NoGo.lean` — certified `nogo_theorem_certified` (sorry-free; 12 project axioms via `#print axioms`); general `nogo_theorem` (all ε,η) = conjecture/axiom
  - `Main.lean` — top-level statements
  - `NumericalCertificate.lean` — certified spectral bound $\rho < 0.45$
  - `SpectralGap.lean`, `Symmetry.lean`, `TP2Kernels.lean`, `IFTBridge.lean`, `TwoPointGauge.lean`, `SRDS_Tier1/2/3.lean`, `SRDS_Lyapunov.lean` — helper lemmas + IFT-bridge/tier formalization
  - `CheckAxioms.lean` — `#print axioms` verifier: prints the **exact** axiom dependency of the no-go theorem
- **Status (built firsthand, Lean v4.29.0-rc1 + pinned mathlib):** `lake env lean PositivityProofs/CheckAxioms.lean` runs **without `sorryAx`/errors** — evidence `lean4/CHECKAXIOMS_OUTPUT.txt`. The certified **`nogo_theorem_certified`** (paper: computer-assisted via Arb certificate Q̇(½)∈interval) depends, per `#print axioms`, on **12 project axioms**: 2 numerical-certificate (`Q_dot_half_continuum`, `…_in_interval`) + 10 IFT-bridge (`Q_star`/`Sigma_c` family), plus the 3 Lean foundational axioms (`propext`, `Classical.choice`, `Quot.sound`). The **general** `nogo_theorem` (all ε,η) remains a **conjecture** (kept as an axiom). **Three well-defined reference counts (do not conflate them):** `#print axioms` = **12 project axioms** (what the certified no-go rests on, authoritative) · `AxiomAudit.lean` inventory = **18** (the full formalization incl. the structural Birkhoff-Hopf axis, which the certified theorem does not use) · `grep '^axiom'` = **27** declarations in the bundle.
- **Build:** Lean 4 + Mathlib (`lean4/lakefile.lean`, `lean4/lean-toolchain`); Mathlib rev pinned in `lean4/lake-manifest.json`

## 2. Cross-domain substrates (§4)

### §4.1 Timber (anchor) — DIN EN 408:2012-10
- **Raw data:** Zenodo DOI `10.5281/zenodo.18340365` ($n = 319$ specimens, balanced $n = 230$ from S7+S10+S13; reference in `data/holz_master/README.md`)
- **External source:** master's thesis Schessl 2025, Zenodo `10.5281/zenodo.18340365`
- **Values:** $\tilde{a} = 0.567$ (mean), $r(\hat{a}, \sigma_\text{break}) = -0.83$ (Pearson; Spearman $\rho = -0.99$), $p < 10^{-30}$

### §4.2 Multi-material multiaxial fatigue (boundary)
- **External source:** Chen et al. 2024 Sci Data (`doi:10.1038/s41597-024-03862-4`), 914 strain-controlled specimens across 136 materials
- **Values:** $R^2 \geq 0.5$ in 74% of materials, cross-material aggregated n.s.

### §4.3 Finance SPY
- **External source:** Yahoo Finance via `yfinance`, SPY 1993–2026
- **Values:** crash $R^2 = 0.973 \pm 0.025$ ($n=10$), calm $R^2 = 0.483$ ($n=135$)

### §4.4 Lignin / lignin-carbohydrate complexes (SP-LCC)
- **External source:** Alopaeus et al. 2025, *SP-LCC*, Scientific Data 12, **doi:10.1038/s41597-025-05327-8** (95 LCC samples, AqSO biorefinery)
- **Data (bundled):** `data/lignin/sp_lcc_data_master.csv` (72-sample subset: p-factor, b-O-4, RSI, Tg, surface tension, chain-length)
- **Values (firsthand from CSV):** $\rho_S(\beta\text{-O-4}, \text{P-factor}) = -0.78$ ($n = 72$; `reproduce.py` [15]); form = Weibull (mode (ii) serial-cascaded), from the aggregation mode, not from AICc. **No interior $\hat{a}$:** broad β-O-4 strength distribution → concave from the origin ($m<1$), no endurance limit, inflection below the tested severity range (firsthand re-anchoring + Schlee 2023 / Mattsson 2017). *(Earlier draft: −0.77/n=90 from a lost text module; the data-backed −0.78/n=72 are authoritative.)*

### §4.5 V-Dem autocratizations
- **External source:** V-Dem ERT-v14 (`v-dem.net/data/ert/`), 117 episodes
- **Values:** $n = 117$, median $R^2 = 0.983$ over 89 fitted episodes

### §4.6 Political speeches (Bundestag/ParlaMint)
- **External source:** Bundestag Open Data + ParlaMint (HU+PL+RS+SI), CLARIN ERIC (public)
- **Values:** cantilever-member prediction, $n_\text{Bundestag} = 6{,}874$
- **ℓ₃→ℓ₄ pilot (§5, not a Tab-1 substrate):** `data/parlamint/pilot_country_year.csv` (65 country-years) + `pilot_inference.json`; NC2 $\rho=-0.34$ (BCa CI $[-0.48,-0.09]$, $p=0.006$), â-discourse 4/4 clusters negative (BCa $[-0.34,-0.15]$), country permutation $p=0.207$ (G=4, tail-arm, not load-bearing). Reproduction: `reproduce.py` block [13]. Status: POSTULATED (operationalization open).

### §4.7 Earthquakes USGS
- **Raw data:** `data/earthquake/usgs_earthquakes.csv` (source data), `data/earthquake/earthquake_results.csv` (sigmoid fits)
- **External source:** USGS-FDSN API (`earthquake.usgs.gov/fdsnws/event/1/`)
- **Values:** $n = 284$ sequences, 6 regions, $\rho(\hat{a}, \text{mainshock}) = +0.673$ Bonferroni

### §4.8 Battery CALB (real)
- **Raw data:** HF `Battery-Life/BatteryLife_Raw` CALB ($n = 26$ cells, 3 temperatures); result included: `data/battery/battery_calb_results.json` (analysis script external, raw data via the HF source)
- **External source:** BatteryLife (arXiv:2502.18807)
- **Values:** KS-D $= 0.733$ ($p = 5.7 \cdot 10^{-14}$), $\tilde{a} = 0.646$ (median), $\rho(\hat{a}, \text{EOL}) = +0.18$ n.s. (7/26 reaching EOL, right-censored). *(Was a NASA-PCoE surrogate $+0.853$ / $0.616$ — synthetic, superseded by the real CALB run on 06-03.)*

### §4.9 Colorectal TCGA
- **Raw data:** `data/crc/tcga_crc_combined.csv` (source data), `data/crc/crc_results_v2.json` (population/mutation/bootstrap, MSI/MSS separated: $n_\text{MSI}=76$, $n_\text{MSS}=503$)
- **Stage headline:** `data/crc/crc_stage_aggregated.json` (MSI $\hat{a}=0.286$ / MSS $0.439$, $\Delta=-0.153$); re-fit `python3 data/crc/domain_crc_v2.py` (+ `srds_core.py`) on the CSV
- **External source:** TCGA Pan-Cancer Atlas (`portal.gdc.cancer.gov`)
- **Values:** $n = 579$; **canonical (load axis) stage-aggregated** MSI–MSS $\Delta\hat{a} = -0.153$; population/count ordering $+0.05$ = counting artifact (`crc_results_v2.json → group_results`)

### §4.10 LLM conversations (ENK Gold)
- **Raw data:** ENK gold corpus ($n = 202$, on request under a Data-Use Agreement — see paper §9.3 disclosure)
- **Values:** $\rho = -0.359$ cluster-robust, ridge $\rho = 0.700 \pm 0.076$

### §4.11 Music (MetaMIDI + music21 + Tagtraum)
- **Pre-registration:** music-L2 pre-registration (dated 2026-05-16, on request)
- **Pipeline scripts:** `data/musik_companion/pipeline/`
  - `musik_l2_lakh_cross_genre.py` — main pipeline for 5 Lakh pop genres
  - `musik_l2_ahat_run.py` — sigmoid fit + $\hat{a}$ extraction
  - `musik_substrat_run.py` — substrate aggregation
  - `musik_l2_shuffled_control.py` — shuffled-control negative control
- **Outputs:** `data/musik_companion/outputs/`
  - `musik_l2_lakh_cross_genre.json` — Lakh genre results
  - `musik_l2_music21_all_raw.json` — Bach via music21
  - `musik_l2_music21_all_summary.json` — Bach aggregation
  - `musik_l2_sanity_bach_n50.json` — sanity subset $n=50$
  - `musik_l2_shuffled_control.json` — negative-control result
  - `musik_l2_lakh_run.log`, `musik_l2_shuffled_control.log` — pipeline logs
- **External data sources:** MetaMIDI Dataset Zenodo `10.5281/zenodo.5142664` (Ens & Pasquier 2021); Tagtraum CD2C `tagtraum.com/genres/msd_tagtraum_cd2c.cls.zip`
- **Values:** $n = 2{,}840$ MIDI pieces, 6-genre Mann-Kendall $\tau = +1.000$, $p = 0.003$, median $R^2 = 0.975$

### §4.12 Table-18 forced materials (Al-6061, DP1180) and the fatigue fit
- **Al-6061:** `data/al6061/per_specimen_al6061.tsv` + `summary_al6061.tsv`; $\tilde{a}=0.084$ (median `logistic_inflection`, 146 valid fits), $\rho(\hat{a},\sigma_{\max})=-0.703$, KS-D $=1.000$. Raw stress-strain: Mendeley `10.17632/rd6jm9tyb6.2`.
- **DP1180:** `data/dp1180/numisheet_results.json`; $\tilde{a}=0.975$ ($a\_hat\_mean$, $n=19$), KS-D $=1.000$. Raw: NIST Numisheet 2020 (`data.nist.gov`).
- **Multiaxial fatigue:** `data/fatigue/multiaxial_fatigue_results.json`; $\tilde{a}=0.578$, $n_\text{strain}=914$. Raw: Chen 2024 Sci Data `10.1038/s41597-024-03862-4`.

## 3. Cross-corpus conversations (§6)

- 12 conversation corpora ($\approx 35{,}300$ dialogues): ENK Gold, BothBosu v3, GasConv, Awry (CGA Wikipedia), LegalCon, MentalManip, P4G, SafeDialBench, CoSafe, ProsocialDialog, Sotopia, Google COVID Mobility
- **Cross-method triangulation:** DUA-limited ENK subset, on request (methods published, cf. paper §6.4)

## 4. Genealogy (§9.4)

- **Precursor classes:** `genealogy_of_frames.md` (8 dated frame classes)
- **Self-references (all Zenodo DOIs):**
  - Schessl 2025 master's thesis: `10.5281/zenodo.18340365`
  - Schessl 2025 *Emergente Narrative Kontrolle*: `10.5281/zenodo.17556213`
  - Schessl 2025 *Leben als organisierte Dissipation*: `10.5281/zenodo.17445178`
  - Schessl 2025 *Self-Reference Axiom*: `10.5281/zenodo.17509367`
  - Schessl 2026 ENK minimal disclosure: `10.5281/zenodo.18475921`
  - Schessl 2026 Autocorrelation Blind Spot: `arXiv:2604.14414`

## 5. Structure-to-value / Pisot finding (§2.5)

- **Script:** `analysis/pisot_eigenvalues.py`: Pisot/Galois verification (golden $\varphi$ / silver $1+\sqrt2$ / cubic), 7/7 PASS, self-contained (stdlib)
- *(The earlier $\Sigma_c$ conjecture operationalization was moved, together with Program C, to `analysis/deprecated/`.)*

## 6. Falsification anchors (§8.1)

- **Synthetic null specimens (layer 1):** 1,000 specimens per substrate (AR(1) / random walk / white noise); all five main substrates (Tab 18) separate with a KS test $p < 10^{-3}$. The earlier "19 of 26" count was the $\gamma_M$ threshold [$\alpha/9$] over the extended 26-substructure tally. (A DSC protein-melt test, $n = 6$, carried earlier, was withdrawn from Tab 18 due to a provenance gap.)
- **Predicted nulls (layer 2):** ProsocialDialog (L1 violation), Sotopia (A0 violation), Google COVID Mobility (L3 violation) — all three confirmed
- **Pre-reg hold-out (layer 3):** $n = 50$ Tier B, 3/6 strict conformity under Holm-Bonferroni

## 7. Disclosure (§9.5)

- **Model:** responsible disclosure — open mechanism, withheld "dose" (**no patent reference**).
- **Withheld:** exclusively the operative calibration thresholds of the budget state machine; the architecture is threshold-independent.
- **Published:** the axiomatics, theorems, Lean-4 proofs, architecture, all substrates documented here.

---

**This reproduction file suffices to follow every table, figure, and statement of the paper. Where raw data are external (USGS, TCGA, V-Dem, MetaMIDI), Section 2 contains the direct URLs.**

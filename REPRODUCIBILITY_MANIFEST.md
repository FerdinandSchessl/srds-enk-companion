# Reproducibility Manifest — Paper

**Stand:** 2026-06-15
**Paper:** "SRDS+ENK — Selbstreferentielle Dissipative Systeme als Klassen-Theorie cross-substrater Sigmoid-Inflektion" (Schessl 2026, arXiv submission).
**Zweck:** Jede im Paper genannte Zahl ist über diesen Manifest auf eine Quell-Datei rückverfolgbar — entweder in den gebündelten Ordnern (`data/`, `lean4/`, `analysis/`) oder über die externen URLs in `README.md`.
**Verifikation:** `python3 reproduce.py` rechnet alle Headline-Zahlen aus den gebündelten Daten neu (33 Checks inkl. Statistik-Ebene, PASS/FAIL, Exit ≠ 0 bei Abweichung). `REPRODUCE.md` = Landkarte Zahl → Datei → Roh-Quelle → Test; `STATISTICS.md` + `analysis/` = Inferenz-Schicht (KS-Null, Permutation, γ_M/Bonferroni, Bootstrap).

---

## 1. Theorie (Lean 4)

### Axiome A0–A4, Regularitäts-Bedingungen L1–L3, Theoreme T1–T3, No-Go-Theorem (§2)
- **Beweise:** `lean4/PositivityProofs/`
  - `AxiomAudit.lean` — Axiom-Konsistenz-Check
  - `Basic.lean` — Grundlagen-Definitionen
  - `HilbertMetric.lean` — Hilbert-Metrik für $TP_2$-Kernel
  - `NoGo.lean` — zertifiziertes `nogo_theorem_certified` (sorry-frei; 12 Projekt-Axiome via `#print axioms`); allgemeines `nogo_theorem` (alle ε,η) = Konjektur/Axiom
  - `Main.lean` — Top-level Statements
  - `NumericalCertificate.lean` — Zertifizierte Spektralschranke $\rho < 0.45$
  - `SpectralGap.lean`, `Symmetry.lean`, `TP2Kernels.lean`, `IFTBridge.lean`, `TwoPointGauge.lean`, `SRDS_Tier1/2/3.lean`, `SRDS_Lyapunov.lean` — Hilfs-Lemmas + IFT-Bridge-/Tier-Formalisierung
  - `CheckAxioms.lean` — `#print axioms`-Verifizierer: druckt die **exakte** Axiom-Abhängigkeit des No-Go-Theorems
- **Status (firsthand gebaut, Lean v4.29.0-rc1 + gepinnte mathlib):** `lake env lean PositivityProofs/CheckAxioms.lean` läuft **ohne `sorryAx`/Fehler** — Beleg `lean4/CHECKAXIOMS_OUTPUT.txt`. Das zertifizierte **`nogo_theorem_certified`** (Paper: computer-assistiert via Arb-Zertifikat Q̇(½)∈Intervall) hängt laut `#print axioms` von **12 Projekt-Axiomen** ab: 2 Numerik-Zertifikat (`Q_dot_half_continuum`, `…_in_interval`) + 10 IFT-Bridge (`Q_star`/`Sigma_c`-Familie), plus die 3 Lean-Grundaxiome (`propext`, `Classical.choice`, `Quot.sound`). Das **allgemeine** `nogo_theorem` (alle ε,η) bleibt **Konjektur** (als Axiom geführt). **Drei wohldefinierte Bezugsgrößen (Auflösung der 17/21/27-Verwechslung):** `#print axioms` = **12 Projekt-Axiome** (worauf das zertifizierte No-Go ruht, maßgeblich) · `AxiomAudit.lean`-Inventar = **18** (Gesamt-Formalisierung inkl. struktureller Birkhoff-Hopf-Achse, die das zertifizierte Theorem nicht nutzt) · `grep '^axiom'` = **27** Deklarationen im Bundle.
- **Build:** Lean 4 + Mathlib (`lean4/lakefile.lean`, `lean4/lean-toolchain`); Mathlib-Rev in `lean4/lake-manifest.json` gepinnt

## 2. Cross-Domain Substrate (§4)

### §4.1 Holz (Anker) — DIN EN 408:2012-10
- **Roh-Daten:** Zenodo-DOI `10.5281/zenodo.18340365` ($n = 319$ Prüfkörper, balanced $n = 230$ aus S7+S10+S13; Verweis in `data/holz_master/README.md`)
- **Externe Quelle:** Master-Thesis Schessl 2025, Zenodo `10.5281/zenodo.18340365`
- **Werte:** $\tilde{a} = 0.567$ (Mean), $r(\hat{a}, \sigma_\text{break}) = -0.83$ (Pearson; Spearman $\rho = -0.99$), $p_\mathrm{perm} < 10^{-30}$

### §4.2 Multi-Material Multiaxial Fatigue (Boundary)
- **Externe Quelle:** Heng et al. 2024 Sci Data (`doi:10.1038/s41597-024-03862-4`), 914 strain-kontrollierte Proben über 136 Metalle
- **Werte:** $R^2 \geq 0.5$ in 74% der Materialien, cross-material aggregiert n.s.

### §4.3 Finance SPY
- **Externe Quelle:** Yahoo Finance via `yfinance`, SPY 1993–2026
- **Werte:** Crash $R^2 = 0.973 \pm 0.025$ ($n=10$), Calm $R^2 = 0.483$ ($n=135$)

### §4.4 Lignin / Lignin-Carbohydrate-Complexes (SP-LCC)
- **Externe Quelle:** Alopaeus et al. 2025, *SP-LCC*, Scientific Data 12, **doi:10.1038/s41597-025-05327-8** (95 LCC-Proben, AqSO-Biorefinery)
- **Daten (gebündelt):** `data/lignin/sp_lcc_data_master.csv` (72-Proben-Subset: p-factor, b-O-4, RSI, Tg, Oberflächenspannung, chain-length)
- **Werte (firsthand aus CSV):** $\rho_S(\beta\text{-O-4}, \text{P-Faktor}) = -0.78$ ($n = 72$; `reproduce.py` [15]); Form = Weibull (Mode (ii) seriell-kaskadiert), aus dem Aggregations-Modus, nicht aus AICc. **Kein inneres $\hat{a}$:** breite β-O-4-Festigkeitsverteilung → konkav ab Ursprung ($m<1$), keine Dauerfestigkeit, Inflektion unterhalb des getesteten Schärfebereichs (firsthand Re-Anker + Schlee 2023 / Mattsson 2017). *(Früherer Draft: −0,77/n=90 aus verschollenem Text-Modul; maßgeblich sind die data-backed −0,78/n=72.)*

### §4.5 V-Dem Autokratisierungen
- **Externe Quelle:** V-Dem ERT-v14 (`v-dem.net/data/ert/`), 117 Episoden
- **Werte:** $n = 117$, Median $R^2 = 0.983$ über 89 gefittete Episoden

### §4.6 Politische Reden (Bundestag/ParlaMint)
- **Externe Quelle:** Bundestag Open Data + ParlaMint (HU+PL+RS+SI), CLARIN ERIC (öffentlich)
- **Werte:** Cantilever-Bauteil-Vorhersage, $n_\text{Bundestag} = 6{,}874$
- **ℓ₃→ℓ₄-Pilot (§5, kein Tab-1-Substrat):** `data/parlamint/pilot_country_year.csv` (65 Country-Years) + `pilot_inference.json`; NC2 $\rho=-0.34$ (BCa-CI $[-0.48,-0.09]$, $p=0.006$), â-Diskurs 4/4 Cluster negativ (BCa $[-0.34,-0.15]$), Country-Permutation $p=0.207$ (G=4, tail-arm, nicht load-bearing). Reproduktion: `reproduce.py` Block [13]. Status: POSTULIERT (Operationalisierung offen).

### §4.7 Erdbeben USGS
- **Roh-Daten:** `data/earthquake/usgs_earthquakes.csv` (Quell-Daten), `data/earthquake/earthquake_results.csv` (Sigmoid-Fits)
- **Externe Quelle:** USGS-FDSN-API (`earthquake.usgs.gov/fdsnws/event/1/`)
- **Werte:** $n = 284$ Sequenzen, 6 Regionen, $\rho(\hat{a}, \text{Mainshock}) = +0.673$ Bonferroni

### §4.8 Batterie CALB (real)
- **Roh-Daten:** HF `Battery-Life/BatteryLife_Raw` CALB ($n = 26$ Zellen, 3 Temperaturen); Ergebnis mitgeliefert: `data/battery/battery_calb_results.json` (Analyse-Skript extern, Roh-Daten via HF-Quelle)
- **Externe Quelle:** BatteryLife (arXiv:2502.18807)
- **Werte:** KS-D $= 0.733$ ($p = 5.7 \cdot 10^{-14}$), $\tilde{a} = 0.646$ (Median), $\rho(\hat{a}, \text{EOL}) = +0.18$ n.s. (7/26 bis EOL, rechts-zensiert). *(War NASA-PCoE-Surrogat $+0.853$ / $0.616$ — synthetisch, superseded durch CALB-Real-Lauf 06-03.)*

### §4.9 Kolorektal TCGA
- **Roh-Daten:** `data/crc/tcga_crc_combined.csv` (Quell-Daten), `data/crc/crc_results_v2.json` (Population/Mutations/Bootstrap, MSI/MSS getrennt: $n_\text{MSI}=76$, $n_\text{MSS}=503$)
- **Stage-Headline:** `data/crc/crc_stage_aggregated.json` (MSI $\hat{a}=0.286$ / MSS $0.439$, $\Delta=-0.153$); Re-Fit `python3 data/crc/domain_crc_v2.py` (+ `srds_core.py`) auf der CSV
- **Externe Quelle:** TCGA Pan-Cancer-Atlas (`portal.gdc.cancer.gov`)
- **Werte:** $n = 579$; **kanonisch (Last-Achse) stage-aggregiert** MSI–MSS $\Delta\hat{a} = -0.153$; Population/Count-Sortierung $+0.05$ = Zähl-Artefakt (`crc_results_v2.json → group_results`)

### §4.10 LLM Konversationen (ENK Gold)
- **Roh-Daten:** ENK Gold-Korpus ($n = 202$, Auf-Anfrage unter Data-Use-Agreement — siehe Paper §9.3 Disclosure)
- **Werte:** $\rho = -0.359$ cluster-robust, Ridge $\rho = 0.700 \pm 0.076$

### §4.11 Musik (MetaMIDI + music21 + Tagtraum)
- **Pre-Registrierung:** Musik-L2-Präregistrierung (datiert 2026-05-16, auf Anfrage)
- **Pipeline-Skripte:** `data/musik_companion/pipeline/`
  - `musik_l2_lakh_cross_genre.py` — Hauptpipeline für 5 Lakh-Pop-Genres
  - `musik_l2_ahat_run.py` — Sigmoid-Fit + $\hat{a}$-Extraktion
  - `musik_substrat_run.py` — Substrat-Aggregation
  - `musik_l2_shuffled_control.py` — Shuffled-Control Negativkontrolle
- **Outputs:** `data/musik_companion/outputs/`
  - `musik_l2_lakh_cross_genre.json` — Lakh-Genre-Ergebnisse
  - `musik_l2_music21_all_raw.json` — Bach via music21
  - `musik_l2_music21_all_summary.json` — Bach-Aggregation
  - `musik_l2_sanity_bach_n50.json` — Sanity-Subset $n=50$
  - `musik_l2_shuffled_control.json` — Negativkontrolle-Resultat
  - `musik_l2_lakh_run.log`, `musik_l2_shuffled_control.log` — Pipeline-Logs
- **Externe Daten-Quellen:** MetaMIDI Dataset Zenodo `10.5281/zenodo.5142664` (Ens & Pasquier 2021); Tagtraum CD2C `tagtraum.com/genres/msd_tagtraum_cd2c.cls.zip`
- **Werte:** $n = 2{,}840$ MIDI-Stücke, 6-Genre Mann-Kendall $\tau = +1.000$, $p = 0.003$, Median $R^2 = 0.975$

### §4.12 Tabelle-18 Forced-Materials (Al-6061, DP1180) und Fatigue-Fit
- **Al-6061:** `data/al6061/per_specimen_al6061.tsv` + `summary_al6061.tsv`; $\tilde{a}=0.084$ (Median `logistic_inflection`, 146 valide Fits), $\rho(\hat{a},\sigma_{\max})=-0.703$, KS-D $=1.000$. Roh-Spannungs-Dehnung: Mendeley `10.17632/rd6jm9tyb6.2`.
- **DP1180:** `data/dp1180/numisheet_results.json`; $\tilde{a}=0.975$ ($a\_hat\_mean$, $n=19$), KS-D $=1.000$. Roh: NIST Numisheet 2020 (`data.nist.gov`).
- **Multiaxial Fatigue:** `data/fatigue/multiaxial_fatigue_results.json`; $\tilde{a}=0.578$, $n_\text{strain}=914$. Roh: Heng 2024 Sci Data `10.1038/s41597-024-03862-4`.

## 3. Cross-Corpus Konversationen (§6)

- 12 Konversations-Korpora ($\approx 35{,}300$ Gespräche): ENK-Gold, BothBosu v3, GasConv, Awry (CGA Wikipedia), LegalCon, MentalManip, P4G, SafeDialBench, CoSafe, ProsocialDialog, Sotopia, Google COVID Mobility
- **Cross-Method-Triangulation:** DUA-begrenztes ENK-Subset, auf Anfrage (Methoden publiziert, vgl. Paper §6.4)

## 4. Genealogie (§9.4)

- **Vorform-Klassen:** `genealogy_of_frames.md` (8 datierte Frame-Klassen)
- **Eigen-Refs (alle Zenodo-DOIs):**
  - Schessl 2025 Master-Thesis: `10.5281/zenodo.18340365`
  - Schessl 2025 Emergente Narrative Kontrolle: `10.5281/zenodo.17556213`
  - Schessl 2025 Leben als organisierte Dissipation: `10.5281/zenodo.17445178`
  - Schessl 2025 Self-Reference Axiom: `10.5281/zenodo.17509367`
  - Schessl 2026 ENK Minimal-Disclosure: `10.5281/zenodo.18475921`
  - Schessl 2026 Autocorrelation Blind Spot: `arXiv:2604.14414`

## 5. $\Sigma_c$-Konjektur (§9.2 Programm C)

- **Skript:** `analysis/sigma_operationalisierung.py` — drei Hypothesen C1/C2/C3 mit Datenquelle, Mess-Größe, erwartete Bande, Falsifikations-Schwelle
- **Report:** `analysis/sigma_operationalisierung_report.md` — operative Spezifikation

## 6. Falsifikations-Anker (§8.1)

- **Synthetische Null-Prüfkörper (Schicht 1):** 1.000 Prüfkörper pro Substrat (AR(1) / Random Walk / White Noise); alle fünf Haupt-Substrate (Tab 18) trennen mit KS-Test $p < 10^{-3}$. Die frühere „19 von 26"-Zählung war die $\gamma_M$-Schwelle [$\alpha/9$] über die erweiterte 26-Substruktur-Aufstellung. (Ein früher mitgeführter DSC-Protein-Schmelz-Test, $n = 6$, wurde wegen einer Provenienz-Lücke aus Tab 18 zurückgezogen.)
- **Vorhergesagte Nulls (Schicht 2):** ProsocialDialog (L1-Violation), Sotopia (A0-Violation), Google COVID Mobility (L3-Violation) — alle drei bestätigt
- **Pre-Reg-Hold-out (Schicht 3):** $n = 50$ Tier B, 3/6 strikte Konformität unter Holm-Bonferroni

## 7. Disclosure (§9.5)

- **Modell:** Responsible Disclosure — offener Mechanismus, zurückgehaltene „Dosis" (**kein Patent-Bezug**).
- **Zurückgehalten:** ausschließlich die operativen Kalibrier-Schwellwerte der Budget-Zustandsmaschine; die Architektur ist schwellwert-unabhängig.
- **Publiziert:** Axiomatik, Theoreme, Lean-4-Beweise, Architektur, alle hier dokumentierten Substrate.

---

**Diese Reproduktions-Datei reicht aus, um jede Tabelle, Abbildung und Aussage des Papers nachzuvollziehen. Wo Roh-Daten extern sind (USGS, TCGA, V-Dem, MetaMIDI), enthält Sektion 2 die direkten URLs.**

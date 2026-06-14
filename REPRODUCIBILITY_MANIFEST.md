# Reproducibility Manifest — Concise Paper

**Stand:** 2026-05-25
**Paper:** "SRDS+ENK — Selbstreferentielle Dissipative Systeme als Klassen-Theorie cross-substrater Sigmoid-Inflektion" (Schessl 2026, arXiv submission).
**Zweck:** Jede im Paper genannte Zahl ist über diesen Manifest auf eine Quell-Datei rückverfolgbar — entweder im `concise/`-Ordner oder über die externen URLs in `README.md`.

---

## 1. Theorie (Lean 4)

### Axiome A0–A4, Regularitäts-Bedingungen L1–L3, Theoreme T1–T3, No-Go-Theorem (§2)
- **Beweise:** `lean4/PositivityProofs/`
  - `AxiomAudit.lean` — Axiom-Konsistenz-Check
  - `Basic.lean` — Grundlagen-Definitionen
  - `HilbertMetric.lean` — Hilbert-Metrik für $TP_2$-Kernel
  - `NoGo.lean` — Maschinelle Verifikation des No-Go-Theorems
  - `Main.lean` — Top-level Statements
  - `NumericalCertificate.lean` — Zertifizierte Spektralschranke $\rho < 0.45$
  - `SpectralGap.lean`, `Symmetry.lean`, `TP2Kernels.lean` — Hilfs-Lemmas
- **Status:** sorry-frei
- **Build:** Lean 4 + Mathlib (`lean4/lakefile.lean`, `lean4/lean-toolchain`)

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

### §4.4 Lignin Kraft-Aufschluss
- **Roh-Daten:** `data/lignin/SRDS_Section4-5_Biopolymer_Textbaustein.docx` (Volltext-Belege)
- **Werte:** $n = 90$, $\rho_S = -0.77$, $\tilde{a} = 0.325$, $k = 2.86$

### §4.5 V-Dem Autokratisierungen
- **Externe Quelle:** V-Dem ERT-v14 (`v-dem.net/data/ert/`), 117 Episoden
- **Werte:** $n = 117$, Median $R^2 = 0.983$ über 89 gefittete Episoden

### §4.6 Politische Reden (Bundestag/ParlaMint)
- **Externe Quelle:** Bundestag Open Data + ParlaMint (HU+PL+RS+SI)
- **Werte:** Cantilever-Bauteil-Vorhersage, $n_\text{Bundestag} = 6{,}874$

### §4.7 Erdbeben USGS
- **Roh-Daten:** `data/earthquake/usgs_earthquakes.csv` (Quell-Daten), `data/earthquake/earthquake_results.csv` (Sigmoid-Fits)
- **Externe Quelle:** USGS-FDSN-API (`earthquake.usgs.gov/fdsnws/event/1/`)
- **Werte:** $n = 284$ Sequenzen, 6 Regionen, $\rho(\hat{a}, \text{Mainshock}) = +0.673$ Bonferroni

### §4.8 Batterie CALB (real)
- **Roh-Daten:** HF `Battery-Life/BatteryLife_Raw` CALB ($n = 26$ Zellen, 3 Temperaturen); Ergebnis mitgeliefert: `data/battery/battery_calb_results.json` (Analyse-Skript extern, Roh-Daten via HF-Quelle)
- **Externe Quelle:** BatteryLife (arXiv:2502.18807)
- **Werte:** KS-D $= 0.733$ ($p = 5.7 \cdot 10^{-14}$), $\tilde{a} = 0.646$ (Median), $\rho(\hat{a}, \text{EOL}) = +0.18$ n.s. (7/26 bis EOL, rechts-zensiert). *(War NASA-PCoE-Surrogat $+0.853$ / $0.616$ — synthetisch, superseded durch CALB-Real-Lauf 06-03.)*

### §4.9 Kolorektal TCGA
- **Roh-Daten:** `data/crc/tcga_crc_combined.csv` (Quell-Daten), `data/crc/crc_results_v2.json` (Sigmoid-Fits, MSI/MSS getrennt: $n_\text{MSI}=76$, $n_\text{MSS}=503$)
- **Externe Quelle:** TCGA Pan-Cancer-Atlas (`portal.gdc.cancer.gov`)
- **Werte:** $n = 579$, MSI–MSS $\Delta\hat{a} = -0.153$, $p < 10^{-4}$

### §4.10 LLM Konversationen (ENK Gold)
- **Roh-Daten:** ENK Gold-Korpus ($n = 202$, Auf-Anfrage unter Data-Use-Agreement — siehe Paper §9.3 Disclosure)
- **Werte:** $\rho = -0.359$ cluster-robust, Ridge $\rho = 0.700 \pm 0.076$

### §4.11 Musik (MetaMIDI + music21 + Tagtraum)
- **Pre-Registrierung:** Musik-L2-Präregistrierung (im Haupt-Repo, datiert 2026-05-16)
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

## 3. Cross-Corpus Konversationen (§6)

- 12 Konversations-Korpora ($\approx 35{,}300$ Gespräche): ENK-Gold, BothBosu v3, GasConv, Awry (CGA Wikipedia), LegalCon, MentalManip, P4G, SafeDialBench, CoSafe, ProsocialDialog, Sotopia, Google COVID Mobility
- **Cross-Method-Triangulation:** im Haupt-Repo (`nc2_zigzag_validation/`, CORRECTNESS_AUDIT + RUN_REPORT)

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

- **Synthetische Null-Prüfkörper (Schicht 1):** 1.000 Prüfkörper pro Substrat (AR(1) / Random Walk / White Noise); fünf der sechs Haupt-Substrate (Tab 18) trennen mit KS-Test $p < 10^{-3}$ (DSC Grenzfall, $p = 0.0016$). Die frühere „19 von 26"-Zählung war die $\gamma_M$-Schwelle [$\alpha/9$].
- **Vorhergesagte Nulls (Schicht 2):** ProsocialDialog (L1-Violation), Sotopia (A0-Violation), Google COVID Mobility (L3-Violation) — alle drei bestätigt
- **Pre-Reg-Hold-out (Schicht 3):** $n = 50$ Tier B, 3/6 strikte Konformität unter Holm-Bonferroni

## 7. Disclosure (§9.5)

- **Modell:** Responsible Disclosure — offener Mechanismus, zurückgehaltene „Dosis" (**kein Patent-Bezug**).
- **Zurückgehalten:** ausschließlich die operativen Kalibrier-Schwellwerte der Budget-Zustandsmaschine; die Architektur ist schwellwert-unabhängig.
- **Publiziert:** Axiomatik, Theoreme, Lean-4-Beweise, Architektur, alle hier dokumentierten Substrate.

---

**Diese Reproduktions-Datei reicht aus, um jede Tabelle, Abbildung und Aussage des Concise-Papers nachzuvollziehen. Wo Roh-Daten extern sind (USGS, TCGA, V-Dem, MetaMIDI), enthält Sektion 2 die direkten URLs.**

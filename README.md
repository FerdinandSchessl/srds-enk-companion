# Companion — SRDS+ENK Concise Paper

**Paper:** "SRDS+ENK — Selbstreferentielle Dissipative Systeme als Klassen-Theorie cross-substrater Sigmoid-Inflektion" (Schessl 2026, arXiv submission in preparation, DE 45p / EN 43p).

Dieser Ordner enthält alle Reproduktions-Artefakte, die das Concise-Paper allein abdecken (Lean-4 Beweise, Roh-Daten der zehn Substrate, Pipeline-Skripte, Genealogie). Der Ordner ist so strukturiert, dass ein Reviewer ihn isoliert klonen oder navigieren kann.

## Die zehn Substrate (Überblick)

Details je Substrat im `REPRODUCIBILITY_MANIFEST.md` (§-Nummern rechts).

| # | Substrat | n | Kern-Befund | Manifest |
|---|---|---|---|---|
| 1 | Holz (DIN EN 408) | 230 | $r = -0.83$; $\tilde{a} = 0.567$ | §4.1 |
| 2 | Multi-Material Multiaxial Fatigue | 914 | $R^2 \geq 0.5$ in 74 % der Metalle | §4.2 |
| 3 | Finance (SPY) | 10 / 135 | Crash $R^2 = 0.973$ / Calm $0.483$ | §4.3 |
| 4 | Lignin (Kraft-Aufschluss) | 90 | $\rho_S = -0.77$; $\tilde{a} = 0.325$ | §4.4 |
| 5 | V-Dem Autokratisierungen | 117 | Median $R^2 = 0.983$ | §4.5 |
| 6 | Erdbeben (USGS) | 284 | $\rho(\hat{a}, \text{Mainshock}) = +0.673$ | §4.7 |
| 7 | Batterie (CALB) | 26 | KS-D $= 0.733$; $\tilde{a} = 0.646$; $\rho(\text{EOL}) = +0.18$ n.s. | §4.8 |
| 8 | Kolorektal (TCGA) | 579 | $\Delta\tilde{a}$ (MSI–MSS) $= -0.153$ | §4.9 |
| 9 | LLM-Konversation (ENK Gold) | 202 | $\rho = -0.359$; Ridge $0.700$ | §4.10 |
| 10 | Musik (MetaMIDI / music21) | 2.840 | Median $R^2 = 0.975$; $\tau = +1.000$ | §4.11 |

**Kein Substrat:** Politische Reden (Bundestag/ParlaMint) sind eine V-Dem-Failure-Mode (§4.6). Vorhergesagte Null-Kontrollen (keine Substrate): ProsocialDialog, Sotopia, Google COVID Mobility (§8.1).

## Inhalt

| Pfad | Inhalt |
|---|---|
| `REPRODUCIBILITY_MANIFEST.md` | Pro Tabelle/Abbildung im Paper: Skript-Pfad, Roh-Daten-Pfad, externe URLs |
| `lean4/PositivityProofs/` | No-Go-Theorem maschinell verifiziert in Lean 4 (`AxiomAudit.lean`, `NoGo.lean`, `HilbertMetric.lean`, `Main.lean` etc.); sorry-frei |
| `genealogy_of_frames.md` | 8 datierte Vorform-Frame-Klassen (Master-Thesis 2025 → SRDS 2026) |
| `data/earthquake/` | USGS-FDSN-API-Sequenzen, 284 Sequenzen, sechs Regionen (`usgs_earthquakes.csv`, `earthquake_results.csv`) |
| `data/battery/` | CALB Li-Ion Degradation, $n = 26$ Zellen / 3 Temperaturen (`battery_calb_results.json`; Roh extern HF `Battery-Life/BatteryLife_Raw`) |
| `data/crc/` | TCGA Pan-Cancer-Atlas Colorectal, $n = 579$ Patienten (`tcga_crc_combined.csv`, `crc_results.json`) |
| `data/holz_master/` | Holz DIN EN 408, $n = 319$ → balanced $n = 230$; Roh-Daten via Zenodo-DOI (siehe `data/holz_master/README.md`) |
| `data/lignin/` | Kraft-Aufschluss Bindungs-Hierarchie ($n = 90$, $\rho_S = -0.77$) |
| `data/musik_companion/pipeline/` | Pipeline-Skripte für MetaMIDI/Tagtraum/music21 ($\ell_2$-Substrat) |
| `data/musik_companion/outputs/` | Pipeline-Outputs (`musik_l2_lakh_cross_genre.json`, `musik_l2_music21_all_raw.json`, Shuffled-Control) |
| `analysis/sigma_operationalisierung.py` | Operative Spezifikation der $\Sigma_c$-Konjektur (§9.2 Programm C) |
| `analysis/sigma_operationalisierung_report.md` | Begleit-Report zur $\Sigma_c$-Operationalisierung |

## Externe Daten-Quellen (nicht in diesem Ordner, weil extern publiziert)

- **MetaMIDI Dataset:** Zenodo `10.5281/zenodo.5142664` (Ens & Pasquier 2021)
- **Tagtraum CD2C Genre-Labels:** `tagtraum.com/genres/msd_tagtraum_cd2c.cls.zip`
- **USGS Earthquake Catalog API:** `earthquake.usgs.gov/fdsnws/event/1/`
- **TCGA Pan-Cancer-Atlas:** `portal.gdc.cancer.gov` (Open-Access)
- **V-Dem ERT-v14:** `v-dem.net/data/ert/`
- **Yahoo Finance SPY:** `finance.yahoo.com` (via `yfinance`)
- **Multi-Material Multiaxial Fatigue:** Materials Cloud `10.24435/materialscloud:wt-98` (914 strain-kontrollierte Proben, 31 Materialien)
- **Master-Thesis Schessl 2025 (Holz-Datenanker):** Zenodo `10.5281/zenodo.18340365`
- **ENK-Gold-Korpus:** privat unter DUA ($n = 202$ LLM-Konversationen) — nicht öffentlich verteilbar

## Lizenz

Der Code (Lean 4, Python-Skripte) steht unter MIT (siehe `LICENSE`). Die Roh-Daten unterliegen den jeweiligen Quell-Lizenzen (siehe externe URLs).

## Längere Fassung

Dieses Companion ist self-contained und deckt das SRDS+ENK-Paper ab. Eine ausführlichere Fassung ist in Vorbereitung.

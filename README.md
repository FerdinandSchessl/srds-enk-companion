# Companion — SRDS+ENK Paper

**Paper:** "SRDS+ENK — Selbstreferentielle Dissipative Systeme als Klassen-Theorie cross-substrater Sigmoid-Inflektion" (Schessl 2026, arXiv submission in preparation, DE 50p / EN 48p).

Dieser Ordner enthält alle Reproduktions-Artefakte, die das Paper allein abdecken (Lean-4 Beweise, Roh/Fit-Daten der zehn Substrate, Pipeline-Skripte, Genealogie). Der Ordner ist so strukturiert, dass ein Reviewer ihn isoliert klonen, navigieren **und nachrechnen** kann.

## Reproduktion (ein Befehl)

```bash
python3 reproduce.py     # nur Standard-Bibliothek; erwartet: "all 33 numeric checks PASSED"
```

Das Skript rechnet jede Headline-Zahl aus den gebündelten Daten neu und vergleicht mit dem Paper-Wert (PASS/FAIL, Exit-Code ≠ 0 bei Abweichung; aktuell 33 Checks inkl. Statistik). **`REPRODUCE.md`** ist die maßgebliche Landkarte: pro Zahl → gebündelte Datei → externe Roh-Quelle (DOI/URL) → Test-Befehl. Wo der Roh-Datensatz extern/groß ist, liegt die **Fit-Ausgabe** im Ordner (Zahl hier prüfbar) und die **Roh-Quelle** ist verlinkt (Fit end-to-end nachvollziehbar).

**Statistik-Schicht:** `STATISTICS.md` + `analysis/` reproduzieren die Inferenz (KS gegen synthetische Null, Permutationstest, γ_M/Bonferroni-Zählung, Bootstrap). Die stdlib-Tests (γ_M-Count, Holz-Permutation) laufen direkt in `reproduce.py`; die scipy-Skripte (`analysis/null_model.py`, `data/crc/domain_crc_v2.py`) brauchen `requirements.txt`. Die ENK-cluster-robuste Inferenz ist DUA-begrenzt (nur Aggregat teilbar) — Details in `STATISTICS.md`.

## Die zehn Substrate (Überblick)

Details je Substrat im `REPRODUCIBILITY_MANIFEST.md` (§-Nummern rechts).

| # | Substrat | n | Kern-Befund | Manifest |
|---|---|---|---|---|
| 1 | Holz (DIN EN 408) | 230 | $r = -0.83$; $\tilde{a} = 0.567$ | §4.1 |
| 2 | Multi-Material Multiaxial Fatigue | 914 | $R^2 \geq 0.5$ in 74 % der Metalle | §4.2 |
| 3 | Finance (SPY) | 10 / 135 | Crash $R^2 = 0.973$ / Calm $0.483$ | §4.3 |
| 4 | Lignin/LCC (SP-LCC, Alopaeus 2025) | 72 Bed. | $\rho_S = -0.78$ (β-O-4 vs P-Faktor); Weibull (Mode ii) — kein inneres $\hat{a}$ ($m<1$, konkav, keine Dauerfestigkeit) | §4.4 |
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
| `reproduce.py` | Selbst-enthaltener Reproduktions-Check aller Headline-Zahlen (stdlib only, 33 Checks) |
| `REPRODUCE.md` | Landkarte: pro Zahl → gebündelte Datei → Roh-Quelle → Test-Befehl |
| `STATISTICS.md` | Inferenz-Schicht: KS-Null, Permutation, γ_M/Bonferroni, Bootstrap — Claim → Skript |
| `COVERAGE_REPORT.md` | **Vollständige Buchführung: alle 614 Paper-Zahlen (DE+EN) → Reproduktionspfad/Kategorie** |
| `requirements.txt` | Umgebung (stdlib für `reproduce.py`; numpy/scipy nur für Re-Fits) |
| `analysis/bonferroni_gamma_m.py` | [stdlib] γ_M/Bonferroni-Zählung (5/5 strikt, 5/5 unter γ_M) aus `ks_null_summary.csv` |
| `analysis/permutation_test.py` | [stdlib] Holz-Permutationstest (10⁴×, seed=0) → p_perm |
| `analysis/null_model.py` | [scipy] Synthetik-Null-Generator (AR(1)/RW/WN) + KS, Al-6061-Beispiel |
| `analysis/ks_null_summary.csv` | Fünf Tab.-18-Substrate: KS-D + p (Quelle der γ_M-Zählung) |
| `REPRODUCIBILITY_MANIFEST.md` | Pro Tabelle/Abbildung im Paper: Skript-Pfad, Roh-Daten-Pfad, externe URLs |
| `lean4/PositivityProofs/` | No-Go in Lean 4, **computer-assistiert**: das zertifizierte `nogo_theorem_certified` ist **sorry-frei** (firsthand gebaut, 0 `sorryAx` — Beleg `lean4/CHECKAXIOMS_OUTPUT.txt`) und hängt laut `#print axioms` von **12 Projekt-Axiomen** ab (2 Numerik-Zertifikat + 10 IFT-Bridge) + 3 Lean-Grundaxiomen. Das allgemeine `nogo_theorem` (alle ε,η) ist **Konjektur/Axiom**. *(Drei Bezugsgrößen: `#print axioms`=12 · `AxiomAudit.lean`-Inventar=18 · `grep '^axiom'`=27 — alle im Beleg erklärt.)* |
| `genealogy_of_frames.md` | 8 datierte Vorform-Frame-Klassen (Master-Thesis 2025 → SRDS 2026) |
| `data/earthquake/` | USGS-FDSN-API-Sequenzen, 284 Sequenzen, sechs Regionen (`usgs_earthquakes.csv`, `earthquake_results.csv`) |
| `data/battery/` | CALB Li-Ion Degradation, $n = 26$ Zellen / 3 Temperaturen (`battery_calb_results.json`; Roh extern HF `Battery-Life/BatteryLife_Raw`) |
| `data/crc/` | TCGA Colorectal, $n = 579$ (`tcga_crc_combined.csv`, `crc_results_v2.json`, `crc_stage_aggregated.json`; Re-Fit `domain_crc_v2.py` + `srds_core.py`) |
| `data/holz_master/` | Holz DIN EN 408, $n = 319$ → balanced $n = 230$; Roh-Daten via Zenodo-DOI (siehe `data/holz_master/README.md`) |
| `data/lignin/` | SP-LCC-Datensatz (Alopaeus 2025, doi:10.1038/s41597-025-05327-8): `sp_lcc_data_master.csv` (72 Proben); $\rho_S(\beta\text{-O-4},P)=-0.78$, `reproduce.py` [15] |
| `data/al6061/` | Al-6061-Zugversuch Per-Specimen-Fits (`per_specimen_al6061.tsv`, `summary_al6061.tsv`); ã = 0.084 Median valider Fits, $n = 146$ |
| `data/dp1180/` | DP1180 NIST Numisheet 2020 (`numisheet_results.json`); ã = 0.975, KS-D = 1.000, $n = 19$ |
| `data/fatigue/` | Multi-Material Multiaxial Fatigue Ergebnis (`multiaxial_fatigue_results.json`); ã = 0.578, $n = 914$ |
| `data/vdem/` | V-Dem ERT-v14 Episoden-Fits (`srds_vdem_results.csv`); Median $R^2 = 0.983$, 89/117 |
| `data/finance/` | SPY Event-Fits (`event_results_v3.csv`); Crash $R^2 = 0.973$ vs. Calm $0.483$ |
| `data/enk/` | ENK Konversations-â-Aggregat (`ahat_convergence.csv`, `chat_id` anonymisiert; Roh-Chats unter DUA) |
| `data/parlamint/` | ParlaMint ℓ₃→ℓ₄-Pilot (§5, **kein** Tab-1-Substrat): Country-Year-Aggregat + `pilot_inference.json`; NC2 ρ=−0.34, â-Diskurs 4/4 neg., perm-p=0.207 |
| `data/model_comparison/` | §2 Form-Klassen-Typologie (AIC-Win-Rates je Substrat: Batterie 100 %, FKM ~80 %, …) |
| `data/cross_corpus/` | §6 Cross-Corpus-Aggregate (Avrami-Kinetik je Korpus); 12 Roh-Korpora extern (Lizenzen) |
| `data/musik_companion/pipeline/` | Pipeline-Skripte für MetaMIDI/Tagtraum/music21 ($\ell_2$-Substrat) |
| `data/musik_companion/outputs/` | Pipeline-Outputs (`musik_l2_lakh_cross_genre.json`, `musik_l2_music21_all_raw.json`, Shuffled-Control) |

## Externe Daten-Quellen (nicht in diesem Ordner, weil extern publiziert)

- **MetaMIDI Dataset:** Zenodo `10.5281/zenodo.5142664` (Ens & Pasquier 2021)
- **Tagtraum CD2C Genre-Labels:** `tagtraum.com/genres/msd_tagtraum_cd2c.cls.zip`
- **USGS Earthquake Catalog API:** `earthquake.usgs.gov/fdsnws/event/1/`
- **TCGA Pan-Cancer-Atlas:** `portal.gdc.cancer.gov` (Open-Access)
- **V-Dem ERT-v14:** `v-dem.net/data/ert/`
- **Yahoo Finance SPY:** `finance.yahoo.com` (via `yfinance`)
- **Multi-Material Multiaxial Fatigue:** Chen et al. 2024 Sci Data `10.1038/s41597-024-03862-4` (914 strain-kontrollierte Proben, 136 Materialien)
- **Al-6061 Zugversuch (Roh-Spannungs-Dehnung):** Mendeley Data `10.17632/rd6jm9tyb6.2`
- **DP1180 Hochfest-Stahl:** NIST Numisheet 2020 Benchmark, `data.nist.gov` (DIC Uniaxial Tension)
- **Master-Thesis Schessl 2025 (Holz-Datenanker):** Zenodo `10.5281/zenodo.18340365`
- **ENK-Gold-Korpus:** privat unter DUA ($n = 202$ LLM-Konversationen) — nicht öffentlich verteilbar

## Lizenz

Der Code (Lean 4, Python-Skripte) steht unter MIT (siehe `LICENSE`). Die Roh-Daten unterliegen den jeweiligen Quell-Lizenzen (siehe externe URLs).

## Längere Fassung

Dieses Companion ist self-contained und deckt das SRDS+ENK-Paper ab. Eine ausführlichere Fassung ist in Vorbereitung.

# Coverage report — every paper number vs. companion reproduction path

Systematic audit (2026-06-15): **614 empirical numbers** were extracted from the Banger paper
across **both languages (DE + EN), all 9 sections**, and each was checked for a reproduction
path in this companion. This is the full accounting; no number is left unaccounted-for.

## Summary by category

| category | count | reproducible? |
|---|---:|---|
| **substrate-data** (bundled) | 234 | ✅ from `data/…` + `reproduce.py` (30 stdlib checks cover the headlines) |
| **cross-corpus** (§6) | 158 | ◑ per-corpus aggregates in `data/cross_corpus/`; raw 12 corpora external (licences) + working repo |
| **withheld-gold** | 119 | ⛔ by design — depend on the ENK gold-corpus raw chats (DUA); aggregate in `data/enk/` |
| **external-DOI** | 52 | ✅ with the named public dataset (Zenodo / Mendeley / NIST / Sci Data / V-Dem / Yahoo / TCGA / MetaMIDI) |
| **model-comparison** (§2) | ~14 | ✅ now bundled in `data/model_comparison/` (partial: CCP60 + fatigue-shift in working repo) |
| **withheld-calibration** | 8 | ⛔ by design — budget-state-machine thresholds (`COMMITMENT.md` hash) |
| **theory-lean** | 6 | ✅ `lean4/PositivityProofs/` (sorry-free) |
| **excluded / not a claim** | ~23 | — editing-checklist %s (0× in the built paper), superseded counts, grouping counts, the definitional 1/φ |

## What this audit changed (gaps closed)

- **§2 model-comparison** (NR60/FKM/Battery/CCP60 win-rates, mode-typology ã): per-substrate
  AIC summaries bundled in `data/model_comparison/`.
- **§6 cross-corpus**: consolidated Avrami aggregates bundled in `data/cross_corpus/`.
- (Earlier this session: the ten substrates + DP1180 + the ParlaMint §5 pilot were made
  self-reproducing via `reproduce.py` — 30/30 checks.)

## Honest remaining limitations (not free gaps)

1. **Lignin** (ρ_S=−0.77, n=90): documented in `data/lignin/…docx` + `REPRODUCIBILITY_MANIFEST.md §4.4`,
   but there is **no per-sample CSV** — the headline is not recomputable from bundled data; it
   requires the source biopolymer dataset. Stated openly, not hidden.
2. **Crystallisation signature** (§9: χ²=18.813, V=0.310, p=0.0001) and several §6 meta-tests
   (Fisher-meta χ²=68.96) are computed on the **ENK gold corpus / external corpora** → withheld-gold
   / cross-corpus, not independently bundleable.
3. **CCP60** (n=9) and the **multiaxial-fatigue path-shift** (ρ≈−0.30, p=0.029): same pipeline as
   the bundled model-comparison summaries, results in the working repo (`analysis/null_model_comparison/`).

## Excluded as non-claims (verified)

The §3 disclosure-vocabulary "whitelist" percentages (0.4 %/0.9 % etc.) are an **editing checklist**
in the section markdown and appear **0× in the built `paper.tex`**. The "5/10" and "2/9" Bonferroni
figures are explicitly cited as *superseded/removed*. Grouping counts ("eight research fields",
"four reproducibility layers") and the definitional conjecture root 1/φ≈0.618 are not measurements.

## Bottom line

Every empirical number is one of: reproducible from bundled data (`reproduce.py`), reproducible
with a named public dataset, withheld by design (gold corpus / calibration thresholds), a
cross-corpus number traceable to bundled aggregates + external corpora, or an excluded editing
artifact. The two genuine "documented-but-not-recomputable-here" cases (Lignin; gold/corpus-bound
meta-tests) are named above rather than glossed over.

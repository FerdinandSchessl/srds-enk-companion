# Revision notes relative to the v5 build (12 Aug 2026)

Corrections and additions identified after the v5 build. The file `paper_en_v5_2026-08-12.pdf` in this repository stays byte-identical to that build (md5 `92e15af9…`); the items below are queued for the next manuscript revision. Each item names its evidence artifact.

| # | Item | Kind | Evidence |
|---|---|---|---|
| 1 | Figure 1, right-hand plot: the fitted axis is labeled "Normalized strain" while the method text (§1.1, §4.1) defines the fit over normalized stress x = sigma/sigma_max. Label and text will be brought into agreement. | correction | manuscript, Figure 1 vs. §1.1 |
| 2 | §4.1 timber anchor, construction baseline: the inflection axis is normalized by sigma_max, so part of the raw correlation follows from the construction itself. The control quantifies that baseline near r = -0.74 (onset stress permuted independently of strength) against the measured r = -0.83, which lies outside the baseline's 99% band (0 of 2000 permutations), holds within each grading class, and orders the visually assigned grades monotonically. The revision will quote the coefficient together with its construction baseline. | addition | `analysis/timber_normalization_control.py` + output file; OBJECTIONS_AND_TESTS.md row 2 |
| 3 | Safety factor gamma_M = alpha/9: the factor is defined over the nine per-substrate tests. The revision will state explicitly which family the factor corrects, and that the association count within the conversation substrate uses gamma_M as a conservative per-association threshold rather than a separate Bonferroni family. | clarification | `analysis/bonferroni_gamma_m.py`; `STATISTICS.md` |
| 4 | §4.5 V-Dem: the count of fitted episodes whose inflection lies beyond the observation window will be re-derived from `data/vdem/srds_vdem_results.csv` during revision (a one-off recount suggested a possible off-by-one against the printed number). | check | `data/vdem/srds_vdem_results.csv` |

# Lignin — SP-LCC dataset (lignin–carbohydrate complexes)

**Source (public, citable):** Alopaeus, Stosiek, Diment, Löfgren, Cho, Hemming, Tirri, Pranovich,
Eklund, Rigo, Balakshin, Xu & Rinke (2025), *"SP-LCC — a dataset on the structure and properties of
lignin-carbohydrate complexes from hardwood"*, **Scientific Data 12**,
DOI **10.1038/s41597-025-05327-8**. 95 LCC-containing samples from the AqSO biorefinery process
(NMR structure, molar-mass distribution, antioxidant activity, glass transition Tg, thermal
degradation, surface tension).

**Bundled data:** `sp_lcc_data_master.csv` — 72 samples with the process-load and structure variables:
`p-factor` (process severity), `temperature`, `ls-ratio`, `b-O-4` (β-O-4 linkage density),
`chain-length`, `Tg`, `RSI`, surface tension at 0.5/0.4/0.25/0.1/0.08 mg/ml.

**Headline (firsthand-reproducible, stdlib):** ρ_S(β-O-4 linkage density, P-factor) = **−0.78** (n=72)
— recomputed by `reproduce.py` block [15]. Secondary: RSI vs P = +0.61; surface-tension(0.5) vs P = +0.56.
The order-parameter sigmoid (Q = β-O-4 loss vs normalized P-factor) is **Logistic** (AICc winner over
Logistic/Gompertz/Weibull/Hill; see `data/model_comparison/lignin/`), with **â=0.21, k≈4.8** on the
n=72 process conditions (of 95 samples). An earlier draft cited â=0.325/k=2.86 from a lost n=90 module;
that does not reproduce on SP-LCC (linear-P → 0.21, log-P → 0.41).

**Note on n / value:** an earlier draft cited ρ_S=−0.77 / n=90 (from a recovered text module whose
raw file was lost). The citable SP-LCC subset bundled here yields **ρ_S=−0.78 / n=72** — these
data-backed values are the ones to use.

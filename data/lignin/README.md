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
The order-parameter sigmoid form follows from the **aggregation mode**, not from an AICc contest:
lignin is serial-cascaded weakest-link failure (β-O-4 yields before 5-5) = **Mode (ii) → Weibull**
(framework, §2.4 / FRAME_ANCHOR §A). Headline: **Weibull (Mode ii), ρ_S=−0.78 — no interior â** (broad β-O-4 strength distribution → concave from the origin, m<1, no endurance limit; inflection below the tested severity range; firsthand re-anchor + Schlee 2023 / Mattsson 2017). The earlier â=0.325/k=2.86 (lost n=90 module) does not reproduce. The AICc
table in `data/model_comparison/lignin/` is descriptive fit-quality only and does NOT determine the form.

**Note on n / value:** an earlier draft cited ρ_S=−0.77 / n=90 (from a recovered text module whose
raw file was lost). The citable SP-LCC subset bundled here yields **ρ_S=−0.78 / n=72** — these
data-backed values are the ones to use.

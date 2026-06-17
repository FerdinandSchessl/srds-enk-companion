# Cross-corpus replication (§6) — consolidated aggregates

The §6 claims (≈35,300 conversations over twelve corpora; Avrami/crystallisation kinetics
replicated over seven corpora; Fisher-meta χ²=68.96, p<10⁻⁶ over eight corpora; 47/113
cluster-robust associations; etc.) rest on twelve external conversation corpora.

**Bundled here** (clean per-corpus aggregates, no raw chats):
- `avrami_cross_corpus_v2_summary.csv` — per corpus × metric: n, %high-quality, K/R² medians, MWU p.
- `avrami_cross_transfer_summary.csv` — cross-corpus transfer of the Avrami kinetics.

**Not bundled** (external, own licences; some restricted):
the twelve raw corpora themselves and the per-conversation tables. Public ones: CGA-Wikipedia
(Awry), ProsocialDialog, Sotopia, P4G, CoSafe, SafeDialBench, Google COVID-Mobility. Restricted /
on-request: ENK-Gold (DUA), BothBosu, GasConv, LegalCon, MentalManip. The full per-corpus
pipeline + the Fisher-meta and 47/113 cluster-robust tables live in the working repo
(`analysis/`); the cross-method triangulation runs on a DUA-restricted ENK subset (on request);
see `../../COVERAGE_REPORT.md` for the per-number map.

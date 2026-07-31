# Formal Framework

The standalone mathematical development behind the SRDS class: the five axioms and four
regularity conditions, the reduction theorem, the three structural theorems (T1–T3), the
two-scale renormalization operator and its monotone fixed point, the No-Go theorems, the
elimination ledger, and the spectral/contraction substructure. The document is
self-contained: every result is proved in full, reduced to a cited result of the
established literature, or stated under explicitly named hypotheses.

## Two states

| Path | State | Extent |
|---|---|---|
| `SRDS_Formal_Framework.{tex,pdf}` | Current revision, 30 July 2026 | 30 pp., Sections 1–13 |
| `as-submitted-2026-06/SRDS_Formal_Framework.{tex,pdf}` | Frozen; the state that accompanies the June 2026 manuscript submission | 26 pp., Sections 1–12 |

The frozen state is the reference for the submitted manuscript. The current revision is a
standalone document in its own right and is not part of that submission.

**Difference.** The current revision adds Section 11, *The Third No-Go: No Specimen-Sure
Prospective Identification under Prefix Measurement* (the prefix barrier, the
non-adaptedness of the normalized crossing, and the alarm-floor corollary that singles out
the ensemble-calibrated adapted rule as optimal), together with a delimitation against
He et al. (2026) among the T1 remarks and a harmonized symbol notation with a conventions
table at the end of Section 1. The remaining sections are unchanged in substance; the
Elimination Ledger and the Spectral substructure carry the numbers 11 and 12 in the frozen
state and 12 and 13 in the current revision.

**Identification.** The frozen state is byte-identical with the file carried in this
repository since commit `4bedd0f` (27 June 2026):

```
SHA-256  41c3f08cdf6da283b387cfb3e7d6bbc694a6d3630f6fa04e288ff80eb555ea47  as-submitted-2026-06/SRDS_Formal_Framework.tex
SHA-256  5bb368c4a01c2d781212e4d7bd2aded1ff414d817a050a86908cd61d79bafb93  as-submitted-2026-06/SRDS_Formal_Framework.pdf
```

**Scope of the Lean development.** The proofs under `../lean4/` cover the first No-Go (no
universal inflection constant) and its certified numerical branch. The second and third
No-Go are established in this document only.

**Build.** Both states compile standalone with `pdflatex` run three times (inline
`thebibliography`, no bibtex); no external class or style files beyond a standard TeX
distribution.

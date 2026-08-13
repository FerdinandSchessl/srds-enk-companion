# Formal Framework

Self-referential dissipative systems (SRDS) are the class treated by the main manuscript of
this repository (see `../README.md`). This directory holds the standalone mathematical
development behind that class: the five axioms and four regularity conditions, the reduction
theorem, the three structural theorems (T1–T3), the two-scale renormalization operator and
its monotone fixed point, the No-Go theorems, the elimination ledger, and the
spectral/contraction substructure.

## Two states

| Path | State | Extent |
|---|---|---|
| `SRDS_Formal_Framework.{tex,pdf}` | Current revision, 30 July 2026 | 30 pp., Sections 1–13 |
| `frozen-2026-06/SRDS_Formal_Framework.{tex,pdf}` | The state frozen in June 2026; unchanged since | 26 pp., Sections 1–12 |

Neither state is part of the manuscript, which stands on its own with its
bibliography and figures. The frozen state is the reference for readers of the
June 2026 manuscript; the current revision is a standalone document that continues past it.

**Difference.** The current revision adds Section 11, *The Third No-Go: No Specimen-Sure
Prospective Identification under Prefix Measurement* (the prefix barrier, the
non-adaptedness of the normalized crossing, and the alarm-floor corollary that singles out
the ensemble-calibrated adapted rule as optimal), and a delimitation against He et al.
(2026) among the T1 remarks. The symbol notation is harmonized throughout, with a
conventions table at the end of Section 1; the mathematical content of the remaining
sections is unchanged.

**Numbering.** Sections 1–10 carry identical numbers in both states (T2 is Theorem 6.2, the
first No-Go is Theorem 9.2). The Elimination Ledger and the Spectral substructure move from
Sections 11 and 12 to Sections 12 and 13, and their numbered statements move with them: E1
is Proposition 11.1 in the frozen state and Proposition 12.1 in the current revision.

**Identification.** The frozen state is byte-identical with the file carried in this
repository since commit `4bedd0f` (27 June 2026):

```
SHA-256  41c3f08cdf6da283b387cfb3e7d6bbc694a6d3630f6fa04e288ff80eb555ea47  frozen-2026-06/SRDS_Formal_Framework.tex
SHA-256  5bb368c4a01c2d781212e4d7bd2aded1ff414d817a050a86908cd61d79bafb93  frozen-2026-06/SRDS_Formal_Framework.pdf
```

**Scope of the Lean development.** The proofs under `../lean4/` cover the first No-Go (no
universal inflection constant) and its certified numerical branch. The second and third
No-Go carry document proofs and are not formalized in Lean.

**Build.** Both states compile standalone with `pdflatex` run three times (inline
`thebibliography`, no bibtex); no external class or style files beyond a standard TeX
distribution.

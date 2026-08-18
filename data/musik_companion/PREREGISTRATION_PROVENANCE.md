# Provenance — Music ℓ₂ Pre-Registration

**File:** `preregistration_musik_l2.md` (German; the language of the working repository)

## What this file is

The internal pre-registration for the music substrate (manuscript §4.11), drafted
2026-05-16, one day before the run of 2026-05-17. It fixes the hypotheses H1–H3, the
stop criteria, and the shuffled-control expectation (§5) before the analysis. The copy
in this folder is byte-identical to the frozen original; the file is never edited.

## Source and timestamp

The original lives in the private working repository (`enk-gold-annotator`, <!-- lint:allow R2: Quellangabe ist der Inhalt einer Provenienz-Notiz -->
`paper/v2/audit/preregistration_musik_l2.md`). Its git history binds the timestamp:

```
commit 1e31f86 (2026-05-17): file added
no later commit touches the file (verified via git log --follow, 2026-08-18)
```

## Integrity

```
md5:     18f09543d8c16706a7f0cdc67a5b2bfe
SHA-256: b35f8034a205b060c088141b04e60d6f4a401e5e6ac36cf8adf101e01064a944
File:    preregistration_musik_l2.md  (8093 bytes, UTF-8, LF line endings)
```

A single changed byte changes the hash; a match proves the published copy is
bit-identical to the file committed on 2026-05-17. The private repository's commit <!-- lint:allow R2: Quellangabe ist der Inhalt einer Provenienz-Notiz -->
can be shown to auditors under agreement.

## Deviations of the executed run from the plan

Stated here so the pre-registration can be read against what was actually run:

1. **Data route.** The plan names MetaMIDI with Spotify match (≈21,480 pieces).
   The executed run uses the music21 corpus plus the Lakh subset with Tagtraum
   genre labels ($n = 2{,}840$: 1,974 music21 + 866 Lakh), as reported in
   manuscript §4.11. The construct (note-sequence, cumulative unique edges,
   sigmoid inflection) is the pre-registered one.
2. **H2 (decade drift) is not reported in the manuscript.** The manuscript
   carries H1 (genre separation; pre-registered order per Di Marco, observed
   Mann-Kendall τ = +1.000) and H3 (sigmoid conformity; median R² = 0.975
   against the ≥ 0.85 criterion).
3. **Shuffled control (§5 of the pre-registration): mixed outcome.** Expected:
   â degenerates to a tight cluster near 0.5 and genre separation vanishes.
   Observed (`outputs/musik_l2_shuffled_control.json`): no 0.5 collapse
   (â clusters at 0.27–0.34), the monotone genre ordering breaks
   (Mann-Kendall n.s.), and the Jazz level stays separated. Under the
   reduction clause fixed in §5, the surviving level separation marks a
   vocabulary component; the monotone ordering itself is sequence-carried.
   Manuscript §4.11 reports the control in this form since the v7 build.

Section references inside the pre-registration (§2.2, §4, §6.1, §6.3) point to the
working draft of May 2026; the numbering of the published manuscript differs.

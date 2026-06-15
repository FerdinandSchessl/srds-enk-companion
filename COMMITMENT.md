# Hash Commitment — Withheld Calibration Parameters

**Date of commitment:** 2026-06-12

## What is withheld, and why

Following the responsible-disclosure model described in the paper (§9.5 / §11.5: open
mechanism, regulated dose), the **numeric values** of the ENK budget calibration are not
published. The withheld set covers, for both operating configs (PRODUCTION/ULS and
DETECTION/SLS):

- ε (epsilon — Wasserstein calibration radius)
- θ_V, θ_L (sensor thresholds)
- r (recovery rate)
- Θ₁/Θ₂/Θ₃ (budget state-machine boundary parameters: NORMAL→WATCH→WARNING→CRITICAL)
- window/decay constants of the budget accumulator

The **mechanism** (which quantities are measured, how evidence accumulates, the state-machine
architecture, all axioms and theorems) is fully public in the paper and this repository.
Only the calibration constants — the "dose" — are withheld.

## Integrity statement

1. The withheld values were **frozen on 2026-03-18**, before the confirmatory hold-out run
   (pre-registration "frozen, no re-tuning"; the pre-registration lives in the working repo,
   not in this lean companion), and have not been changed since. No reported result was
   obtained by adjusting them after that date.
2. The paper's headline numbers are reproducible from the bundled data in this repository
   (`data/…`; run `reproduce.py`, see `REPRODUCE.md`) **without** access to the withheld
   values.
3. The hash below binds the exact withheld-parameter file. It proves (a) the values existed
   in this exact form at commitment time and (b) any later disclosure can be verified
   against this commitment.

## Commitment

```
SHA-256: f6f4f71cec21e80d9f314494cbcca19ba94b98ea9cb49fd0c37a958922984c3a
File:    srds_withheld_params.json  (1433 bytes, UTF-8, LF line endings)
```

The file is a canonical JSON document containing both configs in full (parameter names as
listed above, plus a `_meta` block with provenance and freeze date). It is stored privately
by the author and is **never** committed to any repository.

## Verification procedure

Upon disclosure of the parameter file (e.g., to auditors or partners under agreement):

```
sha256sum srds_withheld_params.json
# must print: f6f4f71cec21e80d9f314494cbcca19ba94b98ea9cb49fd0c37a958922984c3a
```

A single changed byte changes the hash; a match proves the disclosed file is bit-identical
to the one committed here on 2026-06-12.

## Append-only rule

This file is append-only. If the calibration is ever revised, the revision gets a **new**
versioned parameter file and a **new** commitment entry appended below — existing entries
are never edited or removed.

/-
  Positivity Paper - Lean 4 Formalization

  Main entry point - imports all modules

  Run `lake build` to verify all proofs.

  Revision: 23 Feb 2026
  - Added NumericalCertificate.lean (certified Q̇(1/2) ∈ [1.858, 1.879])
  - Added AxiomAudit.lean (complete inventory of all axioms)
  - Refactored NoGo.lean: nogo_step5 now derives from certificate
-/

import PositivityProofs.Basic
import PositivityProofs.HilbertMetric
import PositivityProofs.TP2Kernels
import PositivityProofs.SpectralGap
import PositivityProofs.Symmetry
import PositivityProofs.TwoPointGauge
import PositivityProofs.NumericalCertificate
import PositivityProofs.NoGo
import PositivityProofs.IFTBridge
import PositivityProofs.AxiomAudit

/-!
# Summary of Formalized Results

## Definitions
- `MonotoneCone`: The cone of non-negative, non-increasing functions on [0,1]
- `NormalizedProfiles`: Q ∈ MonotoneCone with Q(0)=1, Q(1)=0
- `hilbertMetric`: Hilbert projective metric
- `isTP2`: Totally positive kernel of order 2
- `gaussianKernel`: Gaussian smoothing kernel

## Main Theorems

### Theorem 3.2 (Sharp Decay)
- `sharp_decay_formula`: κ(ε) = tanh(1/(2ε))
- `sharp_decay_asymptotics`: 1 - κ(ε) ~ 2e^{-1/ε}

### Theorem 3.3 (Critical Cooling)
- `critical_cooling`: ε_n ≥ 1/log(n) for convergence

### Theorem 4.3 (Symmetry)
- `symmetry_characterization`: Q*(1/2) = 1/2 ⟺ kernel is symmetric

### Theorem 4.4 (No-Go)
- `nogo_theorem`: dΣ_c/dα|_{α=0} ≠ 0
- `nogo_theorem_certified`: Same, for ε=0.0625, η=0.3 (numerically certified)
- `no_universal_transition`: No universal transition point exists

### Certified Numerical Result
- `Q_dot_half_in_certified_interval`: Q̇(1/2) ∈ [1.858, 1.879]
- `Q_dot_half_nonzero`: Q̇(1/2) ≠ 0 (from interval)
- `nogo_step5_certified`: Step 5 verified via Arb 256-bit arithmetic

## Axiom Inventory
- See `AxiomAudit.lean` for complete categorized list
- 12 structural axioms (standard results, Mathlib gaps)
- 1 numerical certificate axiom (Arb-verified)
- 4 paper-specific analytical axioms (incl. conjectured symmetry converse)

## Verification Status

Run `grep -r "sorry" PositivityProofs/` to find remaining gaps.
Run `grep -r "axiom" PositivityProofs/` to list all axioms.
Goal: Minimize axioms; maximize machine-verified proofs.
-/

-- Quick check that everything compiles
#check MonotoneCone
#check hilbertMetric
#check gaussianKernel_isTP2
#check symmetry_characterization
#check nogo_theorem
#check nogo_theorem_certified
#check Q_dot_half_in_certified_interval
#check Q_dot_half_nonzero
#check nogo_step5_certified
#check no_universal_transition_certified

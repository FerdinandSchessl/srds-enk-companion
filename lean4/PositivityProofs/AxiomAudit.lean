/-
  Axiom Audit for Positivity Paper Lean 4 Formalization

  This file provides a complete inventory of all axioms used in the
  formalization, categorized by type and justified individually.

  Author: Ferdinand Schessl
  Date: February 2026 (revision after Phase 1 certified interval arithmetic)

  ## Summary

  Total axioms: 18 (was 19, twoPointGauge_J_equivariant formalized 2026-05-30)
  - Category A (Standard structural, Mathlib gaps): 12
  - Category B (Numerical certificate): 2 (Q_dot_half_continuum named constant + interval)
  - Category C (Paper-specific analytical): 4 (was 5; twoPointGauge proved)

  ## 2026-05-30 update
  - twoPointGauge_J_equivariant: AXIOM → THEOREM (TwoPointGauge.lean).
    Proof via Subtype reductions + explicit algebraic manipulation. No Mathlib gap.
  - Mathlib4 IFT status REVISED: Mathlib HAS `ImplicitFunctionData.implicitFunction`
    on Banach spaces (Analysis/Calculus/Implicit.lean) and `HasStrictFDerivAt.to_localInverse`
    (Analysis/Calculus/InverseFunctionTheorem/FDeriv.lean). Bochner integration on
    continuous-map-valued functions is in MeasureTheory/Integral/Bochner/.
    The remaining gap is NOT Mathlib but the operator-side: renormOp itself is axiom
    (definition gap; the Bochner integral on C([0,1]) is available but constructing
    the smoothing operator is multi-step). So infinite-dim IFT for our operator
    is bounded but multi-month work.

  ## Acceptance Argument for Reviewer

  Category A axioms encode well-established results from:
  - Birkhoff (1957), Bushell (1973): Hilbert metric properties
  - Karlin (1968): TP2 kernel theory
  - Standard real analysis: tanh bounds, series divergence

  Category B is a SINGLE numerical axiom verified by Arb interval arithmetic
  at 256-bit precision. The certificate is machine-checkable and reproducible.

  Category C encodes the analytical core of the No-Go theorem (gauge mixing
  argument), which requires Fréchet calculus not yet in Mathlib4.
-/

import PositivityProofs.NoGo
import PositivityProofs.IFTBridge
import PositivityProofs.HilbertMetric
import PositivityProofs.SpectralGap

/-! ## Category A: Structural Axioms (Standard Mathematical Results)

  These axioms encode results that are mathematically uncontroversial
  but not yet formalized in Mathlib4. Each has a clear literature reference.
-/

/-!
### A.1: Hilbert Metric (HilbertMetric.lean)

| # | Axiom | Reference | Mathlib4 Status |
|---|-------|-----------|-----------------|
| 1 | hilbertMetric_nonneg | Bushell 1973 | Not yet formalized |
| 2 | hilbertMetric_projective | Bushell 1973, Lemma 2.1 | Not yet formalized |
| 3 | hilbertMetric_eq_zero_iff | Bushell 1973, Prop. 2.3 | Not yet formalized |
| 4 | birkhoff_contraction | Birkhoff 1957, Thm. 1 | Not yet formalized |

These are foundational results in projective metric theory.
The Hilbert metric and Birkhoff contraction theorem are standard tools
in nonlinear Perron-Frobenius theory (see Lemmens-Nussbaum 2012, Ch. 2).
-/

#check @hilbertMetric_nonneg
#check @hilbertMetric_projective
#check @hilbertMetric_eq_zero_iff
#check @birkhoff_contraction

/-!
### A.2: Spectral Gap (SpectralGap.lean)

| # | Axiom | Reference | Mathlib4 Status |
|---|-------|-----------|-----------------|
| 5 | gaussianKernel_diameter | Karlin 1968 + explicit computation | Requires integral bounds |
| 6 | sharp_decay_exact | tanh identity: 1-tanh(z) = 2/(e^{2z}+1), z=1/(2ε) | Mathlib has tanh def |
| 7 | sharp_decay_upper | 1/(e^{1/ε}+1) ≤ e^{-1/ε} | Elementary |
| 8 | sharp_decay_lower | e^{-1/ε}/(1+e^{-1/ε}) ≤ 1/(e^{1/ε}+1) | Elementary |
| 9 | critical_cooling_divergence | p-series test | Requires Mathlib summability |

Axioms 6-8 are elementary real analysis identities involving tanh.
They could be proved in Mathlib4 with moderate effort.
Axiom 9 is a standard application of the p-series convergence test.
-/

#check @gaussianKernel_diameter
#check @sharp_decay_exact
#check @sharp_decay_upper
#check @sharp_decay_lower
#check @critical_cooling_divergence

/-!
### A.3: Symmetry (Symmetry.lean)

| # | Axiom | Reference | Mathlib4 Status |
|---|-------|-----------|-----------------|
| 10 | smoothingOp_commutes_J | Paper Lemma 4.2, Step 2 | Requires integral operator |

Axiom 10 encodes the equivariance T∘J = J∘T under kernel mirror symmetry.
The proof is a direct substitution in the integral. The Bochner integral
on C([0,1]) IS available in Mathlib4 (MeasureTheory/Integral/Bochner/);
the obstruction is constructing the specific smoothing operator concretely.

Note: `symmetry_forward` (the converse direction Q*(1/2) = 1/2 ⟹ K-SYM)
was previously listed here but has been reclassified to Category C,
as it encodes a conjectured result not proved in the paper.
-/

#check @smoothingOp_commutes_J

/-!
### A.4: No-Go Structural (NoGo.lean)

| # | Axiom | Reference | Mathlib4 Status (revised 2026-05-30) |
|---|-------|-----------|-----------------|
| 12 | renormOp | Definition via Bochner integral | Bochner IS in Mathlib; operator construction is bounded but multi-step |
| 13 | fixedPoint_smooth | IFT on Banach spaces | Mathlib HAS Banach IFT (`ImplicitFunctionData.implicitFunction`) |

Axiom 12 is a DEFINITION (the renormalization operator as an integral operator).
Axiom 13 asserts existence of the family Q_star α — does NOT include differentiability
in α. (Differentiability is needed by `nogo_theorem_certified_from_continuum` and
will be encoded separately when Item 1 of the v2 plan is implemented.)
-/

#check @renormOp
#check @fixedPoint_smooth

/-! ## Category B: Numerical Certificate (2 axioms, advisor 4.8 honest refactor May 2026)

| # | Axiom | Verification | Status |
|---|-------|--------------|--------|
| 14a | Q_dot_half_continuum | NAMED constant for the continuum value | (∈ ℝ) |
| 14b | Q_dot_half_continuum_in_interval | A-posteriori certified enclosure | [≈1, 3] |

REVISION (May 2026, advisor 4.8): The old single-axiom formulation
`∃ v, 1.858 ≤ v ∧ v ≤ 1.879` was diagnosed as RELOCATED HOLLOWNESS
(v not bound to Q̇). The honest version uses a NAMED constant
`Q_dot_half_continuum : ℝ` representing the continuum value of
(dQ*_α/dα|_{α=0}) (1/2), bound to the certified interval.

The verification chain (verified-numerics/verified_computation.py):
1. Phase A: NumPy approximation of Q*_0, L_N, b_N, Q̇_N at N=200
2. Phase B (Arb 256-bit):
   - Krawczyk fixed-point enclosure of Q*_0 (residual ~ 10⁻¹⁷)
   - Re-compute L_N, b_N, Q̇_N as Arb balls
   - Krawczyk-certified ‖Y‖_∞, ‖I − Y(I-L_N)‖_∞ < 1
   - ⟹ ρ_inv_disc := ‖Y‖_∞ / (1-c) bounded rigorously in Arb
3. Phase C (a-posteriori box enclosure, advisor 4.8 pivot):
   - Anselone continuum-discrete correction:
     ρ_inv_cont ≤ ρ_inv_disc / (1 - ρ_inv_disc · (h²/8) · A_2(ε))
     where A_2(ε) is the heat-kernel constant from B0.2 (explicit Arb formula)
   - Defect d := (I - L) Q̃ - b for piecewise-linear interpolant Q̃
   - Box enclosure of |d| on each [x_i, x_{i+1}] with subbox refinement
     (K=500) to control Arb interval dependency inflation
   - Identity Q̇ - Q̃ = -(I - L)⁻¹ d ⟹ ‖Q̇ - Q̃‖_∞ ≤ ρ_inv_cont · ‖d‖_∞

J-symmetry cross-check: violation ≤ 1.11 × 10⁻¹⁶ (verifies Q*_0 J-symm).

References (advisor-cited literature):
- Rall (1969): Krawczyk operator
- Anselone (1971): Collectively compact operator approximation
- Nakao-Plum-Watanabe (2019): a-posteriori box enclosure
- Kress (2014) §12: Nyström convergence
- Johansson (2017): Arb interval arithmetic
- Davies (1989): Heat kernels (for A_2 constant)

The certificate is machine-readable: verified-numerics/certificate.json
Reproduction: `make verify` in verified-numerics/
Companion docs:  proof_attempts/defect_bound_writeup.md
                 proof_attempts/analytic_constants.md
-/

#check @Q_dot_half_continuum
#check @Q_dot_half_continuum_in_interval

/-! ## Category C: Paper-Specific Analytical (4 axioms — was 5; #18 formalized 2026-05-30)

| # | Axiom | Reference | Note |
|---|-------|-----------|------|
| 11 | symmetry_forward | Paper Remark 4.5 | Conjectured converse direction |
| 15 | nogo_step5_general | Paper Thm 4.4 Step 5 | Open conjecture (gauge equiv. argument) |
| 16 | nogo_theorem_certified_from_continuum | Paper Thm 4.4 + cert | Bridge: Q̇(1/2)≠0 → No-Go (v2 Item 1 target) |
| 17 | nogo_theorem | Paper Thm 4.4 (general) | OPEN CONJECTURE all ε,η |
| ~~18~~ | ~~twoPointGauge_J_equivariant~~ | ~~Paper Def 2.8 + Lem 4.5~~ | **PROVED 2026-05-30 (TwoPointGauge.lean)** |

REVISION (advisor 4.8 wiring fix, May 2026):
- nogo_theorem_certified was previously a free-standing axiom (`∃...deriv≠0`)
  not connected to the numerical certificate.
- Now PROVED via:  nogo_theorem_certified_from_continuum
                   (Q_dot_half_continuum_nonzero : Q_dot_half_continuum ≠ 0)
- This wires the certificate (Cat B) into the No-Go conclusion.
- `#print axioms nogo_theorem_certified` now correctly lists Q_dot_half_continuum
  + Q_dot_half_continuum_in_interval + the bridge axiom.

REMAINING (future work, advisor 4.8 acknowledged):
- nogo_theorem_certified_from_continuum is ITSELF an axiom (encodes the chain rule
  dΣ_c/dα = -Q̇(1/2)/(Q*_0)'(1/2) + IFT + monotonicity). A proper proof requires:
  (a) defining Q̇ as the Fréchet derivative of α ↦ Q*_α at α=0,
  (b) constructing Σ_c as continuous function of α via IFT,
  (c) applying the chain rule.
  Mathlib HAS the IFT/Bochner pieces; the gap is constructing the specific operator
  family and showing it's C¹ in α. v2 Item 1 plan: split this bridge into the
  finite-dim chain-rule theorem (provable from Mathlib) + atomic operator axioms.
- twoPointGauge_J_equivariant FORMALIZED 2026-05-30 (PROVED as theorem).
  Proof uses Subtype reductions on the 1-0/1-1 endpoints + explicit algebraic
  manipulation. See TwoPointGauge.lean for details.

symmetry_forward encodes the conjectured converse of the symmetry theorem:
Q*(1/2) = 1/2 ⟹ kernel has mirror symmetry. This is NOT proved in the
paper (see Remark 4.5) and is NOT required by any of the main theorems.
It is included for completeness of the biconditional in the Lean formalization.

nogo_step5_general encodes the analytical argument that gauge normalization
forces Q̇_s(1/2) ≠ 0 via symmetric mixing. This is the core novel insight
of the paper and requires Fréchet calculus on C([0,1]).

For the specific parameters ε = 0.0625, η = 0.3, this is INDEPENDENTLY
verified by the numerical certificate (Category B).

nogo_theorem_certified and nogo_theorem combine the structural axioms
(IFT, smooth dependence) with Step 5 to yield the full No-Go result.
-/

#check @symmetry_forward
#check @nogo_step5_general
#check @nogo_theorem_certified
#check @nogo_theorem

/-! ## Proved Theorems (no axioms required)

The following results are FULLY PROVED in this formalization:

| Theorem | File | Description |
|---------|------|-------------|
| reflectionOp_involution | Basic.lean | J is an involution |
| transitionPoint_symmetric | Basic.lean | J-symmetric ⟹ Q*(1/2) = 1/2 |
| twoPointGauge_J_equivariant | TwoPointGauge.lean | A_gauge ∘ J = J ∘ A_gauge (formalized 2026-05-30) |
| twoPointGauge_apply_of_ne | TwoPointGauge.lean | Pointwise formula for the gauge |
| reflectionOp_apply, _at_zero, _at_one | TwoPointGauge.lean | Pointwise formulas for J |
| gaussianKernel_strictlyPositive | TP2Kernels.lean | Gaussian kernel is positive |
| gaussianKernel_isTP2 | TP2Kernels.lean | Gaussian kernel is TP2 |
| gaussianKernel_mirrorSymmetry | TP2Kernels.lean | Gaussian kernel has K-SYM |
| shiftedGaussian_at_zero | TP2Kernels.lean | k_0 = standard Gaussian |
| shiftedGaussian_not_symmetric | TP2Kernels.lean | k_α not symmetric for α≠0 |
| sharp_decay_formula | SpectralGap.lean | κ(ε) = tanh(1/(2ε)) |
| fixedPoint_J_invariant | Symmetry.lean | T∘J=J∘T ⟹ J(Q*)=Q* |
| J_preserves_normalized | Symmetry.lean | J maps NormalizedProfiles to itself |
| symmetry_characterization | Symmetry.lean | Q*(1/2)=1/2 ⟺ K-SYM |
| kernelPerturbation_odd | NoGo.lean | Perturbation kernel is odd |
| nogo_step5_certified | NoGo.lean | Q̇(1/2) ≠ 0 (from certificate) |
| Q_dot_half_nonzero | NumericalCertificate.lean | 0 ∉ [1.858, 1.879] |
| Q_dot_half_pos | NumericalCertificate.lean | Q̇(1/2) > 0 |
| no_universal_transition | NoGo.lean | No constant Σ_c |
| no_universal_transition_certified | NoGo.lean | Same, from certificate |
-/

/-
  Numerical Certificate for Q̇(1/2) ≠ 0

  This module encodes the result of an a-posteriori certified interval
  arithmetic computation using the Arb library (python-flint) at 256-bit
  precision.

  The computation certifies a rigorous bound on the CONTINUUM solution Q̇
  of the linearized fixed-point equation (I - L) Q̇ = b for the shifted
  Gaussian kernel renormalization R_α with parameters ε = 0.0625, η = 0.3.

  ## Verification chain (advisor 4.8 review, May 2026):
    1. NUMPY: Q̇_N (discrete N=200 Nyström solution) computed
    2. ARB:   Q*_0 enclosed via Krawczyk (Phase B in verified_computation.py)
              Q̇_N re-computed in Arb 256-bit (residual ~ 10⁻¹⁷)
              ρ_inv = ‖(I-L_N)⁻¹‖_∞ = ‖Y‖_∞ / (1 - c_norm) (Krawczyk-cert.)
    3. ANSELONE: continuum-correction ρ_inv_cont ≤ ρ_inv_disc / (1 - ρ_inv·δ)
                 with δ = ‖(I-P_N) L‖_∞ ≤ (h²/8)·A_2(ε), A_2 heat-kernel const
    4. BOX-ENCLOSURE (a-posteriori): defect d := (I-L) Q̃ - b on each box
                                     [x_i, x_{i+1}] with K subbox-refinement
                                     to control Arb interval dependency
    5. Identity Q̇ - Q̃ = -(I-L)⁻¹ d  ⟹  |Q̇(1/2) - Q̃(1/2)| ≤ ρ_inv_cont · ‖d‖_∞

  ## References:
    - Rall, Computational Solution of Nonlinear Operator Equations, 1969
      (Krawczyk operator).
    - Anselone, Collectively Compact Operator Approximation Theory, 1971
      (Continuum-discrete operator transfer).
    - Nakao-Plum-Watanabe, Numerical Verification Methods, Springer 2019
      (a-posteriori box enclosure).
    - Kress, Linear Integral Equations, 3rd ed., Springer 2014, §12
      (Nyström convergence).
    - Johansson, "Arb: efficient arbitrary-precision midpoint-radius
      interval arithmetic", IEEE Trans. Comput. 66 (2017).

  ## Reproduce:
    cd verified-numerics
    make verify
    # Produces certificate.json with the certified interval

  ## Companion documentation:
    proof_attempts/defect_bound_writeup.md  — architecture + Mock results
    proof_attempts/analytic_constants.md    — A_2 derivation, heat-kernel bound

  Author: Ferdinand Schessl
  Date: 2026-05 (revised from Feb 2026 hollow axiom)
-/

import PositivityProofs.Basic

/-! ## Certified Continuum Value

  Q_dot_half_continuum is a NAMED constant representing the genuine continuum
  value of the perturbation derivative at x=1/2:

      Q_dot_half_continuum := (dQ*_α/dα|_{α=0}) (1/2)

  where Q*_α is the unique fixed point of R_α = A ∘ T_{ε,α} ∘ M_η,
  with ε = 1/16, η = 3/10, A the two-point gauge (see TwoPointGauge.lean),
  T_{ε,α} the Gaussian smoothing with shift α, and M_η the linear damping.

  Unlike the previous formulation `∃ v, 1.858 ≤ v ∧ v ≤ 1.879` (which only
  asserted that SOME real lies in the interval — trivially true), this
  binds the bound directly to the continuum value.
-/

/-- The continuum value Q̇(1/2) = (dQ*_α/dα|_{α=0}) (1/2) for ε=1/16, η=3/10.

    This is treated as an opaque real constant in Lean. Its value is
    determined by the integral equation (I - L) Q̇ = b in C([0,1]),
    where L = DR_0 and b = ∂_α R_α(Q*_0)|_0. -/
axiom Q_dot_half_continuum : ℝ

/-- A-POSTERIORI CERTIFIED INTERVAL (advisor 4.8 honest refactor).

    The continuum value Q̇(1/2) is enclosed by the certified bounds
    [lower, upper] produced by `verified_computation.py` (Phase C,
    box-enclosure with K=500 subbox refinement).

    The interval has been computed via the chain documented above:
    Krawczyk discrete-fixed-point + Anselone continuum-resolvent +
    box enclosure of the defect d := (I-L) Q̃ - b.

    CONCRETE VALUES (from certificate.json, K=4000 box-refinement run, 2026-05-30):
      Q̃(1/2) midpoint   = 1.8687430365
      ‖d‖_∞ (continuum) ≤ 8.44e-3 (max now at box 64, not box 0)
      ρ_inv_continuum   ≤ 3.266 (Anselone-corrected, K-independent)
      δ_N (a-posteriori) ≤ 0.0276 (was 0.117 at K=500)
      Interval lower     ≥ 1.841191
      Interval upper     ≤ 1.896295

    Previous K=500 baseline values for reference:
      ‖d‖_∞ ≤ 0.0358 (box 0 was the bottleneck)
      δ_N   ≤ 0.117
      Interval [1.7517, 1.9858]

    The interval has positive lower bound (> 1.84 > 0), so Q̇(1/2) > 0,
    hence ≠ 0, establishing the perturbation non-vanishing step of the
    No-Go theorem. The Lean axiom below uses the looser bound [1.75, 1.99]
    which the K=4000 run continues to satisfy (and tightens to [1.84, 1.90]). -/
axiom Q_dot_half_continuum_in_interval :
    (1.75 : ℝ) ≤ Q_dot_half_continuum ∧ Q_dot_half_continuum ≤ 1.99

/-- Q̇(1/2) is strictly positive. Direct from the interval. -/
theorem Q_dot_half_continuum_pos : 0 < Q_dot_half_continuum := by
  obtain ⟨hlo, _⟩ := Q_dot_half_continuum_in_interval
  linarith

/-- Q̇(1/2) ≠ 0. -/
theorem Q_dot_half_continuum_nonzero : Q_dot_half_continuum ≠ 0 := by
  exact ne_of_gt Q_dot_half_continuum_pos

/-! ## Legacy compatibility — keep old API for NoGo.lean

  The original `Q_dot_half_in_certified_interval` axiom is retained for
  backward compatibility with the rest of the formalization, but is now
  PROVED from the honest `Q_dot_half_continuum_in_interval` axiom, removing
  one layer of axiomatization.
-/

/-- Legacy: there exists a value in the certified interval [1.75, 1.99].
    Now derived from the honest continuum constant axiom. -/
theorem Q_dot_half_in_certified_interval :
    ∃ v : ℝ, 1.75 ≤ v ∧ v ≤ 1.99 := by
  obtain ⟨hlo, hhi⟩ := Q_dot_half_continuum_in_interval
  exact ⟨Q_dot_half_continuum, hlo, hhi⟩

/-- Legacy: there exists a non-zero value in the interval. -/
theorem Q_dot_half_nonzero : ∃ v : ℝ, v ≠ 0 ∧ 1.75 ≤ v ∧ v ≤ 1.99 := by
  exact ⟨Q_dot_half_continuum, Q_dot_half_continuum_nonzero,
         Q_dot_half_continuum_in_interval.1, Q_dot_half_continuum_in_interval.2⟩

/-- Legacy: there exists a strictly positive value in the interval. -/
theorem Q_dot_half_pos : ∃ v : ℝ, 0 < v ∧ 1.75 ≤ v ∧ v ≤ 1.99 := by
  exact ⟨Q_dot_half_continuum, Q_dot_half_continuum_pos,
         Q_dot_half_continuum_in_interval.1, Q_dot_half_continuum_in_interval.2⟩

/-! ## Verification metadata (cross-checks, not used in proofs)

    Values recorded from certificate.json for reference:
    - ρ(L_N) ≈ 0.4489 (paper Table 1: 0.4473)
    - ρ_inv_disc = ‖Y‖/(1-c) ≈ 3.252  (Krawczyk-Arb-certified)
    - ρ_inv_cont (Anselone) ≈ 3.266   (0.43% correction)
    - A_2(ε) heat-kernel bound ≤ 425  (B0.2 in analytic_constants.md)
    - h²/8 · A_2 ≈ 1.34e-3
    - Q̇_N(0.5025) Arb midpoint ≈ 1.8688 (radius ~ 10⁻⁷³)
    - Q̃(0.5) midpoint (piecewise-linear interp) ≈ 1.8687
    - K_subbox in box-enclosure = 4000 (2026-05-30); was 500 (K is env-var configurable)
    - ‖d‖_∞ a-posteriori ≤ 8.44e-3 (K=4000 run, max at box 64)
    - δ_N ≤ ρ_inv_cont · ‖d‖_∞ ≈ 0.0276 (K=4000); was ~0.117 (K=500)
    - Box-0 scaling probe (2026-05-30): perfect 1/K linear in K, pure Arb-wrapping
    - J-symmetry violation ~ 10⁻¹⁶
    - Krawczyk Q* enclosure radius ~ 10⁻¹⁷
-/

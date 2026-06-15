/-
  Two-Point Gauge — J-Equivariance Statement

  Per REVISED.tex Definition 2.8 (line 178):
    A(f)(x) := (f(x) - f(1)) / (f(0) - f(1))

  This gauge maps monotone functions with f(0) > f(1) to normalized
  profiles A(f)(0) = 1, A(f)(1) = 0.

  CRITICAL PROPERTY: A commutes with the reflection involution J,
  where (J f)(x) = 1 - f(1 - x). This is the structural fact that
  drives the corrected No-Go proof (advisor 4.8 review, May 2026).

  Without two-point gauge J-equivariance, the manuscript's "gauge
  mixing term" story in Step 5 of the No-Go proof is needed but
  algebraically incorrect. WITH the two-point gauge, DR_0 is
  J-equivariant and the non-vanishing Q̇(1/2) ≠ 0 follows from
  the source's even component at x = 1/2 (Step 4, not Step 5).

  NUMERICAL VERIFICATION (proof_attempts/check_equivariance_and_chain.py):
  Commutator norm ‖L_N · J - J · L_N‖ ≤ 1.2 × 10⁻¹⁵ (relative).
  This is machine precision — J-equivariance verified.

  FORMALIZATION STATUS:
  The J-equivariance is an elementary algebraic identity that follows
  by direct expansion. The full Lean proof requires careful handling
  of the dite_eq_left manipulation for the (f(0) ≠ f(1)) conditional;
  this formalization is left to a follow-up. We axiomatize the result
  here as a Category C (paper-specific analytical) axiom.

  Author: Ferdinand Schessl
  Date: 2026-05
-/

import PositivityProofs.Basic

open ContinuousMap

/-! ## Two-Point Gauge Definition -/

/-- The two-point gauge, defined when f(0) ≠ f(1). When f(0) = f(1),
    we fall back to the zero function (avoiding division by zero). -/
noncomputable def twoPointGauge (f : C01) : C01 :=
  if _h : f ⟨0, by norm_num⟩ ≠ f ⟨1, by norm_num⟩ then
    ⟨fun x => (f x - f ⟨1, by norm_num⟩) / (f ⟨0, by norm_num⟩ - f ⟨1, by norm_num⟩), by
      apply Continuous.div_const
      exact f.continuous.sub continuous_const⟩
  else
    ⟨fun _ => 0, continuous_const⟩

notation "A_gauge" => twoPointGauge

/-! ## J-Equivariance (THE KEY AXIOM)

  This algebraic identity states that the two-point gauge commutes with
  the reflection involution J. The proof is elementary algebra (compute
  both sides, observe equality), but requires careful Lean tactic
  manipulation for the dite reduction.

  This axiom is the structural foundation of the corrected Step 5 in the
  No-Go theorem proof: it ensures that the linearization DR_0 of the
  renormalization operator R = A ∘ T ∘ M is J-equivariant on the tangent
  space, hence (I - DR_0) is block-diagonal in the J̃-eigendecomposition.

  REFERENCES:
  - REVISED.tex Definition 2.8 + Lemma 4.5 (equivariance lemma)
  - proof_attempts/check_equivariance_and_chain.py (numerical verification)
  - SESSION_HANDOFF_no_go_beweis.md §1.1 (structural diagnosis)
-/

/-- Application of `twoPointGauge` when the non-degeneracy hypothesis holds. -/
lemma twoPointGauge_apply_of_ne (f : C01) (x : I)
    (h : f ⟨0, by norm_num⟩ ≠ f ⟨1, by norm_num⟩) :
    (twoPointGauge f) x =
      (f x - f ⟨1, by norm_num⟩) / (f ⟨0, by norm_num⟩ - f ⟨1, by norm_num⟩) := by
  unfold twoPointGauge
  rw [dif_pos h]
  rfl

/-- Pointwise formula for the reflection operator. -/
lemma reflectionOp_apply (f : C01) (x : I) :
    (J f) x = 1 - f ⟨1 - x.val, one_minus_mem_I x⟩ := rfl

/-- Reflection at the left endpoint: (Jf)(0) = 1 - f(1). -/
lemma reflectionOp_at_zero (f : C01) :
    (J f) ⟨0, by norm_num⟩ = 1 - f ⟨1, by norm_num⟩ := by
  rw [reflectionOp_apply]
  congr 1
  congr 1
  apply Subtype.ext
  show (1 : ℝ) - (⟨0, by norm_num⟩ : I).val = 1
  show (1 : ℝ) - 0 = 1
  ring

/-- Reflection at the right endpoint: (Jf)(1) = 1 - f(0). -/
lemma reflectionOp_at_one (f : C01) :
    (J f) ⟨1, by norm_num⟩ = 1 - f ⟨0, by norm_num⟩ := by
  rw [reflectionOp_apply]
  congr 1
  congr 1
  apply Subtype.ext
  show (1 : ℝ) - (⟨1, by norm_num⟩ : I).val = 0
  show (1 : ℝ) - 1 = 0
  ring

/-- The two-point gauge commutes with the reflection involution J.

    Elementary algebraic identity: setting a = f(0), b = f(1), with a ≠ b,
      A(Jf)(x) = ((1-f(1-x)) - (1-a)) / ((1-b) - (1-a)) = (a - f(1-x))/(a - b)
      J(Af)(x) = 1 - (f(1-x) - b)/(a - b)                = (a - f(1-x))/(a - b)
    Numerical cross-check: 1.2e-15 commutator (proof_attempts/check_equivariance_and_chain.py).

    Previously Category C Axiom 18; formalized 2026-05-30. -/
theorem twoPointGauge_J_equivariant (f : C01)
    (h : f ⟨0, by norm_num⟩ ≠ f ⟨1, by norm_num⟩) :
    twoPointGauge (J f) = J (twoPointGauge f) := by
  have hJ0 := reflectionOp_at_zero f
  have hJ1 := reflectionOp_at_one f
  have hJne : (J f) ⟨0, by norm_num⟩ ≠ (J f) ⟨1, by norm_num⟩ := by
    rw [hJ0, hJ1]; intro heq; apply h; linarith
  have hne : f ⟨0, by norm_num⟩ - f ⟨1, by norm_num⟩ ≠ 0 := sub_ne_zero.mpr h
  ext x
  -- LHS: A(Jf) at x  — use twoPointGauge_apply_of_ne with hJne
  rw [twoPointGauge_apply_of_ne (J f) x hJne]
  -- RHS: J(Af) at x  =  1 - (Af) ⟨1-x.val, _⟩
  rw [reflectionOp_apply (twoPointGauge f) x]
  rw [twoPointGauge_apply_of_ne f ⟨1 - x.val, one_minus_mem_I x⟩ h]
  -- LHS still has (J f) x  →  1 - f ⟨1-x.val, _⟩, plus (J f) at 0, 1
  rw [reflectionOp_apply f x, hJ0, hJ1]
  -- Numerator simplifications: (1 - f(1-x)) - (1 - f(0)) = f(0) - f(1-x)
  -- and: (1 - f(1)) - (1 - f(0)) = f(0) - f(1)
  rw [show 1 - f ⟨1 - x.val, one_minus_mem_I x⟩ - (1 - f ⟨0, by norm_num⟩)
        = f ⟨0, by norm_num⟩ - f ⟨1 - x.val, one_minus_mem_I x⟩ from by ring,
      show (1 - f ⟨1, by norm_num⟩) - (1 - f ⟨0, by norm_num⟩)
        = f ⟨0, by norm_num⟩ - f ⟨1, by norm_num⟩ from by ring]
  -- Goal: (a - c) / (a - b) = 1 - (c - b) / (a - b)
  rw [eq_sub_iff_add_eq, ← add_div]
  -- Goal: (a - c + (c - b)) / (a - b) = 1
  rw [show f ⟨0, by norm_num⟩ - f ⟨1 - x.val, one_minus_mem_I x⟩
        + (f ⟨1 - x.val, one_minus_mem_I x⟩ - f ⟨1, by norm_num⟩)
        = f ⟨0, by norm_num⟩ - f ⟨1, by norm_num⟩ from by ring]
  exact div_self hne

/-! ## Discussion: Why this matters for the No-Go Theorem

  At α=0, the linearization DR_0 of R_α at the symmetric fixed point Q*_0
  satisfies DR_0[v] = (1-η)/N_g · DA(g_0)[T_ε v], where g_0 = T_ε(M_η Q*_0).
  Since g_0 is J-symmetric (Q*_0 J-sym + T_ε K-symmetric kernel + M_η preserves J-sym),
  and A is J-equivariant (twoPointGauge_J_equivariant above), DR_0 itself is
  J-equivariant on the tangent space {v ∈ C([0,1]) : v(0)=v(1)=0}.

  Consequence: (I - DR_0) is block-diagonal in the J̃-eigendecomposition.
  The perturbation source b = ∂_α R_α(Q*_0)|_0 decomposes into even + odd parts.
  At x=1/2, odd parts vanish, so Q̇(1/2) = Q̇_even(1/2).
  The even part of the source is computed (numerically verified non-zero)
  via the certified arithmetic in NumericalCertificate.lean (Phase C).

  This is the structural correction to the manuscript's "gauge mixing"
  argument in Step 5 of the No-Go proof. With the two-point gauge,
  no mixing term exists; the non-vanishing comes purely from the
  sign-definite even component of the source at x = 1/2.
-/

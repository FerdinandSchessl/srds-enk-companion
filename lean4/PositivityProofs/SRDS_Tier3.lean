import Mathlib

/-!
# SRDS Formal Framework — Tier 3 (deep stochastics, conditional formalization)

The deep stochastic facts (Itô–Lyapunov SDE, Oseledets/Lyapunov spectrum, the fluctuation
theorems of Crooks/Seifert) are not yet in Mathlib; the honest machine-checked statement is the
*implication* from those facts (taken as explicit hypotheses) to the SRDS conclusion. This is
exactly how the paper states the results (under Assumptions R/L). No `sorry`, no custom axioms.

* `srds_irreversibility_from_ift` — Axiom A4 / Reduction (iii): given the integral fluctuation
  theorem `∑ p(γ) e^{−dS(γ)} = 1` (the hypothesis encoding stochastic thermodynamics) and one
  non-crossing path of positive probability, the return probability of a crossing trajectory is
  strictly less than one — irreversibility.
-/

open scoped BigOperators

namespace SRDS

/-- **Axiom A4 (irreversibility) from the integral fluctuation theorem (Reduction (iii)).**
Over a finite path space `S` with reversed-path weights `p γ · e^{−dS γ}` (`p ≥ 0`) summing to
`1` (the integral fluctuation theorem), the return probability — the weight carried by the
crossing subset `C ⊆ S` — is strictly below `1`, provided at least one non-crossing path has
positive probability. The deep fact (the fluctuation theorem) is the hypothesis `hIFT`; the
irreversibility conclusion is proved in full. -/
theorem srds_irreversibility_from_ift
    {Path : Type*} [DecidableEq Path] (S C : Finset Path) (hC : C ⊆ S) (p dS : Path → ℝ)
    (hp : ∀ γ ∈ S, 0 ≤ p γ)
    (hIFT : ∑ γ ∈ S, p γ * Real.exp (-dS γ) = 1)
    {γ₀ : Path} (hγ₀S : γ₀ ∈ S) (hγ₀C : γ₀ ∉ C) (hγ₀p : 0 < p γ₀) :
    ∑ γ ∈ C, p γ * Real.exp (-dS γ) < 1 := by
  have hsplit :
      (∑ γ ∈ S \ C, p γ * Real.exp (-dS γ)) + (∑ γ ∈ C, p γ * Real.exp (-dS γ))
        = ∑ γ ∈ S, p γ * Real.exp (-dS γ) := Finset.sum_sdiff hC
  have hγ₀diff : γ₀ ∈ S \ C := Finset.mem_sdiff.mpr ⟨hγ₀S, hγ₀C⟩
  have hpos : 0 < ∑ γ ∈ S \ C, p γ * Real.exp (-dS γ) := by
    refine Finset.sum_pos' (fun γ hγ => ?_) ⟨γ₀, hγ₀diff, ?_⟩
    · exact mul_nonneg (hp γ (Finset.mem_sdiff.mp hγ).1) (Real.exp_pos _).le
    · exact mul_pos hγ₀p (Real.exp_pos _)
  rw [hIFT] at hsplit
  linarith

/-- **Theorem 8.3 (Birkhoff–Hopf gap degeneration).** The classical Birkhoff contraction
coefficient `κ = tanh z` (with `z = Δ/4`) leaves a projective gap that closes exponentially:
`1 − tanh z ≤ 2 e^{−2z}`. With `z = 1/(2ε)` this is the SRDS form `1 − κ(ε) ≤ 2 e^{−1/ε}`.
(Externally corroborated as the classical Hilbert-metric bound; cf. optimal-transport literature.) -/
theorem srds_birkhoff_gap_bound (z : ℝ) (hz : 0 ≤ z) :
    1 - Real.tanh z ≤ 2 * Real.exp (-(2 * z)) := by
  have hcosh : 0 < Real.cosh z := Real.cosh_pos z
  have hcs : Real.cosh z - Real.sinh z = Real.exp (-z) := by
    rw [Real.cosh_eq, Real.sinh_eq]; ring
  have hid : 1 - Real.tanh z = Real.exp (-z) / Real.cosh z := by
    rw [Real.tanh_eq_sinh_div_cosh, one_sub_div (ne_of_gt hcosh), hcs]
  have hclow : Real.exp z / 2 ≤ Real.cosh z := by
    rw [Real.cosh_eq]; have := (Real.exp_pos (-z)).le; linarith
  rw [hid, div_le_iff₀ hcosh]
  have hexp : 2 * Real.exp (-(2 * z)) * (Real.exp z / 2) = Real.exp (-z) := by
    rw [show 2 * Real.exp (-(2 * z)) * (Real.exp z / 2)
        = Real.exp (-(2 * z)) * Real.exp z by ring, ← Real.exp_add]
    congr 1; ring
  have h2 : 2 * Real.exp (-(2 * z)) * (Real.exp z / 2)
      ≤ 2 * Real.exp (-(2 * z)) * Real.cosh z :=
    mul_le_mul_of_nonneg_left hclow (by positivity)
  linarith [h2, hexp]

-- Axiom audit (verified 2026-06-05 via `#print axioms`): all theorems depend only on the
-- standard `[propext, Classical.choice, Quot.sound]` — no `sorryAx`, no custom axioms.

end SRDS

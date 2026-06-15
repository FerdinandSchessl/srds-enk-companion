import Mathlib

/-!
# SRDS Formal Framework — Tier 1 (machine-checked core)

Self-contained Lean 4 formalization of the tractable / discrete results of
`SRDS_Formal_Framework.tex`, verified against Mathlib. No `sorry`, no new axioms.

Tier 1 covers the parts that need only existing Mathlib:
* `srds_sigma_c_root`  — Conjecture 9.6 (algebraic core): the positive root of
  `Σ² + Σ − 1 = 0` is `(√5 − 1)/2 = 1/φ`.
* `srds_budget_bound`  — Theorem 11.3 (forward): `∏ κₖ ≤ exp(−∑(1 − κₖ))`.
-/

open scoped BigOperators

namespace SRDS

/-- **Conjecture 9.6 (algebraic core).** `(√5 − 1)/2` is the positive root of `x² + x − 1 = 0`
(the self-similar candidate `Σ_c = 1/φ`). -/
theorem srds_sigma_c_root :
    ((Real.sqrt 5 - 1) / 2) ^ 2 + ((Real.sqrt 5 - 1) / 2) - 1 = 0
      ∧ 0 < (Real.sqrt 5 - 1) / 2 := by
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  have hnn : 0 ≤ Real.sqrt 5 := Real.sqrt_nonneg 5
  refine ⟨by nlinarith [h5, hnn], ?_⟩
  have h2 : (2 : ℝ) < Real.sqrt 5 := by nlinarith [h5, hnn]
  linarith

/-- **Theorem 11.3 (forward).** The cumulative contraction budget bounds the product of the
per-step contraction coefficients: `∏ κₖ ≤ exp(−∑(1 − κₖ))`. -/
theorem srds_budget_bound {n : ℕ} (κ : Fin n → ℝ) (hκ : ∀ k, 0 < κ k) :
    ∏ k, κ k ≤ Real.exp (-∑ k, (1 - κ k)) := by
  have key : ∀ k, κ k ≤ Real.exp (-(1 - κ k)) := by
    intro k
    calc κ k = (κ k - 1) + 1 := by ring
      _ ≤ Real.exp (κ k - 1) := Real.add_one_le_exp (κ k - 1)
      _ = Real.exp (-(1 - κ k)) := by rw [show (κ k - 1) = -(1 - κ k) by ring]
  calc ∏ k, κ k
      ≤ ∏ k, Real.exp (-(1 - κ k)) :=
        Finset.prod_le_prod (fun k _ => (hκ k).le) (fun k _ => key k)
    _ = Real.exp (∑ k, -(1 - κ k)) := (Real.exp_sum _ _).symm
    _ = Real.exp (-∑ k, (1 - κ k)) := by
        rw [show (∑ k, -(1 - κ k)) = -∑ k, (1 - κ k) by simp]

/-- **Theorem 8.4 (critical cooling law).** With per-step gap `1 − κ(εₙ) ∼ 2 n^{−1/c}`, the
cumulative contraction budget `∑ (1 − κ(εₙ))` diverges (the iteration synchronizes) iff `c ≥ 1`.
Formalized via the `p`-series criterion: `∑ n^{−1/c}` diverges iff `1/c ≤ 1`, i.e. `c ≥ 1`. -/
theorem srds_critical_cooling {c : ℝ} (hc : 0 < c) :
    ¬ Summable (fun n : ℕ => 1 / (n : ℝ) ^ ((1 : ℝ) / c)) ↔ 1 ≤ c := by
  rw [Real.summable_one_div_nat_rpow, not_lt, div_le_one hc]

/-- **Theorem 6.2(i) (autopoietic stationarity, existence/uniqueness).** A contraction `f` on a
complete nonempty metric space has a unique fixed point (Banach). This is the existence core of
the autopoietic steady state. -/
theorem srds_autopoietic_fixedpoint {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    {K : NNReal} {f : α → α} (hf : ContractingWith K f) :
    ∃! x, f x = x := by
  refine ⟨ContractingWith.fixedPoint f hf, hf.fixedPoint_isFixedPt, ?_⟩
  intro y hy
  exact hf.fixedPoint_unique hy

-- Axiom audit (verified 2026-06-05 via `#print axioms`): all four theorems depend only on
-- the standard `[propext, Classical.choice, Quot.sound]` — no `sorryAx`, no custom axioms.

end SRDS

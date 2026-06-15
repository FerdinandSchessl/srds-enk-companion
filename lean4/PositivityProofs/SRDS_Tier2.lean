import Mathlib

/-!
# SRDS Formal Framework — Tier 2 (conditional implications, machine-checked)

The deep stochastic facts (Itô, Oseledets, fluctuation theorems) are stated as *hypotheses*;
the implications from them are proved in full. No `sorry`, no custom axioms.

* `srds_nogo_no_universal_constant` — Theorem 9.3 (No-Go), abstract core: an equivariant
  transition-location functional, under a reparametrization group acting transitively on the
  unit interval, cannot be a universal constant.
* `srds_budget_tendsto_zero` — Theorem 11.3 (convergence direction): if the cumulative
  contraction budget diverges, the product of the per-step coefficients tends to `0`.
-/

open Filter
open scoped BigOperators Topology

namespace SRDS

/-- **Theorem 9.3 (No-Go theorem, abstract core).**
Let the reparametrization group `G` act on transition locations via `act`, let `τ g` be the
transition location of the `g`-conjugated fixed point, with equivariance `τ g = act g base`,
and suppose the action is transitive on the open unit interval (for every target in `(0,1)`
some `g` realizes it). Then the transition location is **not** a universal constant.

This captures exactly the paper's argument: reparametrization-closure + equivariance let the
inflection range over all of `(0,1)`, so no value `c` can be shared by all fixed points. -/
theorem srds_nogo_no_universal_constant
    {G : Type*}
    (act : G → ℝ → ℝ) (τ : G → ℝ) (base : ℝ)
    (equivar : ∀ g, τ g = act g base)
    (transitive : ∀ c' ∈ Set.Ioo (0 : ℝ) 1, ∃ g, act g base = c') :
    ¬ ∃ c, ∀ g, τ g = c := by
  rintro ⟨c, hc⟩
  obtain ⟨g1, h1⟩ := transitive (1 / 4) (by norm_num [Set.mem_Ioo])
  obtain ⟨g2, h2⟩ := transitive (3 / 4) (by norm_num [Set.mem_Ioo])
  have c1 : c = 1 / 4 := (hc g1).symm.trans ((equivar g1).trans h1)
  have c2 : c = 3 / 4 := (hc g2).symm.trans ((equivar g2).trans h2)
  rw [c1] at c2
  norm_num at c2

/-- **Theorem 11.3 (convergence direction).** If the cumulative contraction budget
`A_n = ∑_{k<n} (1 − κₖ)` diverges to `+∞` (with `0 < κₖ`), then `∏_{k<n} κₖ → 0`. -/
theorem srds_budget_tendsto_zero (κ : ℕ → ℝ) (hκ0 : ∀ k, 0 < κ k)
    (hdiv : Tendsto (fun n => ∑ k ∈ Finset.range n, (1 - κ k)) atTop atTop) :
    Tendsto (fun n => ∏ k ∈ Finset.range n, κ k) atTop (𝓝 0) := by
  have key : ∀ k, κ k ≤ Real.exp (-(1 - κ k)) := by
    intro k
    have h := Real.add_one_le_exp (κ k - 1)
    have e : -(1 - κ k) = κ k - 1 := by ring
    rw [e]; linarith
  have hbound : ∀ n, ∏ k ∈ Finset.range n, κ k
      ≤ Real.exp (-∑ k ∈ Finset.range n, (1 - κ k)) := by
    intro n
    calc ∏ k ∈ Finset.range n, κ k
        ≤ ∏ k ∈ Finset.range n, Real.exp (-(1 - κ k)) :=
          Finset.prod_le_prod (fun k _ => (hκ0 k).le) (fun k _ => key k)
      _ = Real.exp (∑ k ∈ Finset.range n, -(1 - κ k)) := (Real.exp_sum _ _).symm
      _ = Real.exp (-∑ k ∈ Finset.range n, (1 - κ k)) := by
          rw [show (∑ k ∈ Finset.range n, -(1 - κ k))
              = -∑ k ∈ Finset.range n, (1 - κ k) by simp]
  have hnonneg : ∀ n, 0 ≤ ∏ k ∈ Finset.range n, κ k :=
    fun n => Finset.prod_nonneg (fun k _ => (hκ0 k).le)
  have hexp : Tendsto (fun n => Real.exp (-∑ k ∈ Finset.range n, (1 - κ k))) atTop (𝓝 0) :=
    Real.tendsto_exp_atBot.comp (tendsto_neg_atTop_atBot.comp hdiv)
  exact squeeze_zero hnonneg hbound hexp

/-- **Reduction Theorem, part (i) (accumulation, Axiom A2).** Nonnegative damage increments with
uniformly bounded partial sums make the cumulative damage convergent (`Summable`): bounded
monotone accumulation. -/
theorem srds_reduction_accumulation (δ : ℕ → ℝ) (hδ : ∀ k, 0 ≤ δ k) {B : ℝ}
    (hbdd : ∀ n, ∑ k ∈ Finset.range n, δ k ≤ B) : Summable δ :=
  summable_of_sum_range_le hδ hbdd

/-- **Reduction Theorem, part (ii) (transition / sigmoid shape, Axiom A3).** If the damage rate
`r` is unimodal — nondecreasing up to a peak index `p`, nonincreasing afterward — then the
cumulative damage is convex below `p` and concave above `p` (its second difference changes sign
once at `p`): the sigmoid shape with a unique inflection at `p`. -/
theorem srds_reduction_sigmoid (r : ℕ → ℝ) (p : ℕ)
    (hup : ∀ i j, i ≤ j → j ≤ p → r i ≤ r j)
    (hdown : ∀ i j, p ≤ i → i ≤ j → r j ≤ r i) :
    (∀ n, n + 1 ≤ p → 0 ≤ r (n + 1) - r n) ∧ (∀ n, p ≤ n → r (n + 1) - r n ≤ 0) := by
  refine ⟨fun n hn => ?_, fun n hn => ?_⟩
  · have : r n ≤ r (n + 1) := hup n (n + 1) (Nat.le_succ n) hn
    linarith
  · have : r (n + 1) ≤ r n := hdown n (n + 1) hn (Nat.le_succ n)
    linarith

/-- **Theorem 11.4 (Doeblin restart) ⇒ convergence.** A uniform minorization giving per-step gap
`1 − κₖ ≥ ηₖ`, together with a divergent damping budget `∑ ηₖ → ∞`, forces `∏ κₖ → 0`
independently of the cooling schedule. -/
theorem srds_doeblin_convergence (κ η : ℕ → ℝ) (hκ0 : ∀ k, 0 < κ k)
    (hgap : ∀ k, η k ≤ 1 - κ k)
    (hηdiv : Tendsto (fun n => ∑ k ∈ Finset.range n, η k) atTop atTop) :
    Tendsto (fun n => ∏ k ∈ Finset.range n, κ k) atTop (𝓝 0) :=
  srds_budget_tendsto_zero κ hκ0
    (tendsto_atTop_mono (fun n => Finset.sum_le_sum fun k _ => hgap k) hηdiv)

/-- **Theorem 6.2(ii) core (band absorption).** A nonnegative sequence obeying the discrete
contraction-with-injection recurrence `V_{n+1} ≤ ρ V_n + b` (`0 ≤ ρ < 1`, `b ≥ 0`) satisfies the
envelope bound `V_n ≤ ρⁿ V₀ + b/(1−ρ)`: it converges geometrically into the stationary band of
height `b/(1−ρ)`. This is the discrete Lyapunov comparison underlying autopoietic stationarity. -/
theorem srds_band_envelope (V : ℕ → ℝ) (ρ b : ℝ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (hb : 0 ≤ b)
    (hrec : ∀ n, V (n + 1) ≤ ρ * V n + b) :
    ∀ n, V n ≤ ρ ^ n * V 0 + b / (1 - ρ) := by
  have h1ρ : (0 : ℝ) < 1 - ρ := by linarith
  have hne : (1 : ℝ) - ρ ≠ 0 := ne_of_gt h1ρ
  have hbd : 0 ≤ b / (1 - ρ) := div_nonneg hb h1ρ.le
  intro n
  induction n with
  | zero => simp only [pow_zero, one_mul]; linarith
  | succ k ih =>
      have hmul : ρ * V k ≤ ρ * (ρ ^ k * V 0 + b / (1 - ρ)) :=
        mul_le_mul_of_nonneg_left ih hρ0
      have hcollapse : ρ * (b / (1 - ρ)) + b = b / (1 - ρ) := by field_simp; ring
      calc V (k + 1) ≤ ρ * V k + b := hrec k
        _ ≤ ρ * (ρ ^ k * V 0 + b / (1 - ρ)) + b := by linarith
        _ = ρ ^ (k + 1) * V 0 + (ρ * (b / (1 - ρ)) + b) := by ring
        _ = ρ ^ (k + 1) * V 0 + b / (1 - ρ) := by rw [hcollapse]

/-- **Theorem 7.2 core (Goldilocks).** A strictly concave functional has a unique maximizer:
two maximizers must coincide. The optimum is a single interior balance point, never split
between extremes — the formal core of the Goldilocks principle. -/
theorem srds_goldilocks_unique_max {s : Set ℝ} {f : ℝ → ℝ}
    (hf : StrictConcaveOn ℝ s f) {x y : ℝ} (hx : x ∈ s) (hy : y ∈ s)
    (hxmax : ∀ z ∈ s, f z ≤ f x) (hymax : ∀ z ∈ s, f z ≤ f y) : x = y := by
  by_contra hne
  have hfeq : f x = f y := le_antisymm (hymax x hx) (hxmax y hy)
  have hmid : ((1 : ℝ) / 2) • x + ((1 : ℝ) / 2) • y ∈ s :=
    hf.1 hx hy (by norm_num) (by norm_num) (by norm_num)
  have hstrict := hf.2 hx hy hne (show (0 : ℝ) < 1 / 2 by norm_num)
    (show (0 : ℝ) < 1 / 2 by norm_num) (show (1 : ℝ) / 2 + 1 / 2 = 1 by norm_num)
  have hle : f (((1 : ℝ) / 2) • x + ((1 : ℝ) / 2) • y) ≤ f x := hxmax _ hmid
  simp only [smul_eq_mul] at hstrict hle
  nlinarith [hstrict, hle, hfeq]

-- Axiom audit (verified 2026-06-05 via `#print axioms`): all theorems in this file depend only
-- on the standard `[propext, Classical.choice, Quot.sound]` — no `sorryAx`, no custom axioms.

end SRDS

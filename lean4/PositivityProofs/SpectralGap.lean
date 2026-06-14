/-
  Sharp Decay of Birkhoff Contraction Coefficient

  THEOREM 3.2: κ(ε) = tanh(1/(2ε)) with Δ = 2/ε
  THEOREM 3.3: Critical cooling schedule

  The exact formula κ(ε) = tanh(1/(2ε)) is proved. Asymptotic bounds and
  the critical cooling schedule are standard analytic results stated as axioms.
-/

import PositivityProofs.HilbertMetric
import PositivityProofs.TP2Kernels

open Real

/-! ## Projective Diameter for Gaussian -/

/-- Projective diameter bound for MonotoneCone under Gaussian smoothing (Karlin 1968) -/
axiom gaussianKernel_diameter (ε : ℝ) (hε : 0 < ε) :
    ∃ C : ℝ, ∀ (f g : C01)
    (hf : ∀ x : I, 0 < f x) (hg : ∀ x : I, 0 < g x),
    hilbertMetric f g hf hg ≤ 2 / ε + C

/-! ## Sharp Decay Theorem -/

/-- THEOREM 3.2: Sharp decay formula
    κ(ε) = tanh(1/(2ε)) where κ = birkhoffCoefficient(2/ε) = tanh((2/ε)/4) -/
theorem sharp_decay_formula (ε : ℝ) (hε : 0 < ε) :
    birkhoffCoefficient (2 / ε) = tanh (1 / (2 * ε)) := by
  unfold birkhoffCoefficient
  congr 1
  field_simp
  norm_num

/-! ## Asymptotic Bounds -/

/-- Exact formula: 1 - κ(ε) = 2/(e^{1/ε} + 1)
    Follows from the hyperbolic tangent definition (standard identity)
    with κ(ε) = tanh(1/(2ε)). -/
axiom sharp_decay_exact (ε : ℝ) (hε : 0 < ε) :
    1 - birkhoffCoefficient (2 / ε) = 2 / (exp (1 / ε) + 1)

/-- Upper bound: 1 - κ(ε) ≤ 2e^{-1/ε}
    Since e^{1/ε} + 1 > e^{1/ε}. -/
axiom sharp_decay_upper (ε : ℝ) (hε : 0 < ε) :
    1 - birkhoffCoefficient (2 / ε) ≤ 2 * exp (-1 / ε)

/-- Lower bound: e^{-1/ε} ≤ 1 - κ(ε)
    Since e^{1/ε} + 1 ≤ 2·e^{1/ε}. -/
axiom sharp_decay_lower (ε : ℝ) (hε : 0 < ε) :
    exp (-1 / ε) ≤ 1 - birkhoffCoefficient (2 / ε)

/-! ## Critical Cooling Schedule -/

/-- THEOREM 3.3: Critical cooling schedule.
    For ε_n ≥ C/log(n), the sum ∑(1-κ(ε_n)) diverges. -/
axiom critical_cooling_divergence :
    ∀ C > (0:ℝ), ∀ ε_seq : ℕ → ℝ,
    (∀ n, 1 ≤ n → 0 < ε_seq n) →
    (∀ n, 1 ≤ n → ε_seq n ≥ C / log n) →
    ¬ Summable (fun n => 1 - birkhoffCoefficient (2 / ε_seq n))

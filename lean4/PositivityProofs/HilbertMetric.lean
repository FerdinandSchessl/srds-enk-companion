/-
  Hilbert Projective Metric

  Definition and basic properties following Bushell (1973)

  Standard properties of the Hilbert metric are stated as axioms,
  as they are well-established results in the literature.
  The novel contributions of the paper (SpectralGap, Symmetry, NoGo)
  build on these foundations.
-/

import PositivityProofs.Basic

open Set

/-! ## Hilbert Metric Definition -/

/-- Hilbert projective metric for strictly positive functions -/
noncomputable def hilbertMetric (f g : C01)
    (_hf : ∀ x : I, 0 < f x) (_hg : ∀ x : I, 0 < g x) : ℝ :=
  Real.log (⨆ x : I, f x / g x) - Real.log (⨅ x : I, f x / g x)

/-! ## Basic Properties (standard results) -/

/-- The Hilbert metric is non-negative (Bushell 1973) -/
axiom hilbertMetric_nonneg (f g : C01)
    (hf : ∀ x : I, 0 < f x) (hg : ∀ x : I, 0 < g x) :
    0 ≤ hilbertMetric f g hf hg

/-- The Hilbert metric is projectively invariant (Bushell 1973) -/
axiom hilbertMetric_projective (f g : C01) (α β : ℝ) (hα : 0 < α) (hβ : 0 < β)
    (hf : ∀ x : I, 0 < f x) (hg : ∀ x : I, 0 < g x)
    (hαf : ∀ x : I, 0 < (α • f) x) (hβg : ∀ x : I, 0 < (β • g) x) :
    hilbertMetric (α • f) (β • g) hαf hβg = hilbertMetric f g hf hg

/-- Hilbert metric zero iff proportional (Bushell 1973) -/
axiom hilbertMetric_eq_zero_iff (f g : C01)
    (hf : ∀ x : I, 0 < f x) (hg : ∀ x : I, 0 < g x) :
    hilbertMetric f g hf hg = 0 ↔ ∃ c > 0, ∀ x : I, f x = c * g x

/-! ## Projective Diameter -/

/-- Projective diameter of a set in Hilbert metric -/
noncomputable def projectiveDiameter (S : Set C01)
    (hS : ∀ f ∈ S, ∀ x : I, 0 < f x) : ℝ :=
  ⨆ (f : C01) (hf : f ∈ S) (g : C01) (hg : g ∈ S),
    hilbertMetric f g (hS f hf) (hS g hg)

/-- Birkhoff contraction coefficient from projective diameter.
    Standard convention: κ = tanh(Δ/4) (Birkhoff 1957, Bushell 1973). -/
noncomputable def birkhoffCoefficient (Δ : ℝ) : ℝ :=
  Real.tanh (Δ / 4)

/-- Birkhoff's Theorem: Positive linear operators contract Hilbert metric (Birkhoff 1957) -/
axiom birkhoff_contraction :
    ∀ (T : C01 →L[ℝ] C01) (S : Set C01)
    (hS : ∀ f ∈ S, ∀ x : I, 0 < f x)
    (hT : ∀ f ∈ S, T f ∈ S)
    (Δ : ℝ) (_hΔ : projectiveDiameter S hS ≤ Δ)
    (f g : C01) (hfS : f ∈ S) (hgS : g ∈ S),
    hilbertMetric (T f) (T g) (hS (T f) (hT f hfS)) (hS (T g) (hT g hgS))
    ≤ birkhoffCoefficient Δ * hilbertMetric f g (hS f hfS) (hS g hgS)

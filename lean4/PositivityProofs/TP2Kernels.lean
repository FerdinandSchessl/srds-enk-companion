/-
  Totally Positive Kernels of Order 2 (TP2)

  Following Karlin (1968)
-/

import PositivityProofs.Basic

open Set

/-! ## TP2 Definition -/

/-- A kernel k : I × I → ℝ is TP2 (Totally Positive of order 2) -/
def isTP2 (k : I → I → ℝ) : Prop :=
  ∀ (x₁ x₂ y₁ y₂ : I), x₁.val < x₂.val → y₁.val < y₂.val →
    k x₁ y₁ * k x₂ y₂ ≥ k x₁ y₂ * k x₂ y₁

/-- A kernel is strictly positive -/
def isStrictlyPositive (k : I → I → ℝ) : Prop :=
  ∀ x y : I, 0 < k x y

/-! ## Gaussian Kernel -/

/-- The Gaussian kernel with scale ε -/
noncomputable def gaussianKernel (ε : ℝ) (_hε : 0 < ε) : I → I → ℝ :=
  fun x y => Real.exp (-(x.val - y.val)^2 / ε)

/-- Gaussian kernel is strictly positive -/
theorem gaussianKernel_strictlyPositive (ε : ℝ) (hε : 0 < ε) :
    isStrictlyPositive (gaussianKernel ε hε) := by
  intro x y
  unfold gaussianKernel
  exact Real.exp_pos _

/-- Gaussian kernel is TP2 (log-concavity in (x,y)) -/
theorem gaussianKernel_isTP2 (ε : ℝ) (hε : 0 < ε) :
    isTP2 (gaussianKernel ε hε) := by
  intro x₁ x₂ y₁ y₂ hx hy
  unfold gaussianKernel
  rw [← Real.exp_add, ← Real.exp_add]
  apply Real.exp_le_exp_of_le
  -- Goal: -(x₁-y₂)²/ε + -(x₂-y₁)²/ε ≤ -(x₁-y₁)²/ε + -(x₂-y₂)²/ε
  rw [show -(x₁.val - y₂.val) ^ 2 / ε + -(x₂.val - y₁.val) ^ 2 / ε
    = -((x₁.val - y₂.val) ^ 2 + (x₂.val - y₁.val) ^ 2) / ε from by ring]
  rw [show -(x₁.val - y₁.val) ^ 2 / ε + -(x₂.val - y₂.val) ^ 2 / ε
    = -((x₁.val - y₁.val) ^ 2 + (x₂.val - y₂.val) ^ 2) / ε from by ring]
  apply div_le_div_of_nonneg_right _ (le_of_lt hε)
  linarith [sq_nonneg (x₁.val - y₁.val), sq_nonneg (x₂.val - y₂.val),
            sq_nonneg (x₁.val - y₂.val), sq_nonneg (x₂.val - y₁.val),
            mul_pos (sub_pos.mpr hx) (sub_pos.mpr hy)]

/-! ## Mirror Symmetry -/

/-- A kernel satisfies mirror symmetry (K-SYM): k(x,y) = k(1-x, 1-y) -/
def hasMirrorSymmetry (k : I → I → ℝ) : Prop :=
  ∀ x y : I, k x y = k ⟨1 - x.val, one_minus_mem_I x⟩
                       ⟨1 - y.val, one_minus_mem_I y⟩

/-- Centered Gaussian kernel has mirror symmetry -/
theorem gaussianKernel_mirrorSymmetry (ε : ℝ) (hε : 0 < ε) :
    hasMirrorSymmetry (gaussianKernel ε hε) := by
  intro x y
  unfold gaussianKernel
  congr 1
  show -(x.val - y.val) ^ 2 / ε = -(↑(⟨1 - x.val, one_minus_mem_I x⟩ : I) - ↑(⟨1 - y.val, one_minus_mem_I y⟩ : I)) ^ 2 / ε
  simp only []
  ring

/-! ## Shifted Gaussian (for No-Go Theorem) -/

/-- The shifted Gaussian kernel family parameterized by α -/
noncomputable def shiftedGaussianKernel (ε : ℝ) (_hε : 0 < ε) (α : ℝ) : I → I → ℝ :=
  fun x y => Real.exp (-(x.val - y.val - α)^2 / ε)

/-- At α = 0, the shifted Gaussian equals the standard Gaussian -/
theorem shiftedGaussian_at_zero (ε : ℝ) (hε : 0 < ε) :
    shiftedGaussianKernel ε hε 0 = gaussianKernel ε hε := by
  ext x y
  unfold shiftedGaussianKernel gaussianKernel
  ring_nf

/-- Shifted Gaussian loses mirror symmetry for α ≠ 0 -/
theorem shiftedGaussian_not_symmetric (ε : ℝ) (hε : 0 < ε) (α : ℝ) (hα : α ≠ 0) :
    ¬ hasMirrorSymmetry (shiftedGaussianKernel ε hε α) := by
  intro h_sym
  have h1 := h_sym ⟨1, by norm_num⟩ ⟨0, by norm_num⟩
  unfold shiftedGaussianKernel at h1
  simp only [] at h1
  have h2 := Real.exp_injective h1
  -- h2 : -(1 - 0 - α)² / ε = -(1 - 1 - (1 - 0) - α)² / ε
  -- Simplify: -(1 - α)² / ε = -(-1 - α)² / ε = -(1 + α)² / ε
  have h3 : (1 - α)^2 = (1 + α)^2 := by
    have h2' : -(1 - 0 - α) ^ 2 / ε = -(1 - 1 - (1 - 0) - α) ^ 2 / ε := h2
    have hε' : ε ≠ 0 := ne_of_gt hε
    field_simp at h2'
    nlinarith
  have : α = 0 := by nlinarith
  exact hα this

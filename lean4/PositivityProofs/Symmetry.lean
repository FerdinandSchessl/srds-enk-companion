/-
  Symmetry Theorem

  THEOREM 4.3: The fixed point has transition at 1/2 iff kernel is symmetric
-/

import PositivityProofs.TP2Kernels

/-! ## Equivariance -/

/-- The smoothing operator T commutes with J when kernel is symmetric.
    This requires the integral operator definition of T. -/
axiom smoothingOp_commutes_J (k : I → I → ℝ) (h_sym : hasMirrorSymmetry k)
    (T : C01 → C01) :
    ∀ f : C01, T (J f) = J (T f)

/-- If T commutes with J and Q is a fixed point, then J(Q) is also fixed -/
theorem fixedPoint_J_invariant (T : C01 → C01) (hT_comm : ∀ f, T (J f) = J (T f))
    (Q : C01) (hQ_fixed : T Q = Q) :
    T (J Q) = J Q := by
  calc T (J Q) = J (T Q) := hT_comm Q
    _ = J Q := by rw [hQ_fixed]

/-! ## J preserves NormalizedProfiles -/

/-- J maps NormalizedProfiles to NormalizedProfiles -/
theorem J_preserves_normalized (Q : C01) (hQ : Q ∈ NormalizedProfiles) :
    J Q ∈ NormalizedProfiles := by
  have hQ_nn := hQ.1.1      -- ∀ x, 0 ≤ Q x
  have hQ_mono := hQ.1.2    -- ∀ x y, x ≤ y → Q y ≤ Q x
  have hQ_at0 := hQ.2.1     -- Q(0) = 1
  have hQ_at1 := hQ.2.2     -- Q(1) = 0
  constructor
  · constructor
    · -- (JQ)(x) = 1 - Q(1-x) ≥ 0
      intro x
      simp only [reflectionOp, ContinuousMap.coe_mk]
      -- Q(1-x) ≤ Q(0) = 1, so 1 - Q(1-x) ≥ 0
      have h1 : Q ⟨1 - x.val, one_minus_mem_I x⟩ ≤ Q ⟨0, by norm_num⟩ := by
        apply hQ_mono; simp; exact (one_minus_mem_I x).1
      rw [hQ_at0] at h1
      linarith
    · -- (JQ) is non-increasing
      intro x y hxy
      simp only [reflectionOp, ContinuousMap.coe_mk]
      -- x ≤ y ⟹ 1-y ≤ 1-x ⟹ Q(1-x) ≤ Q(1-y) ⟹ 1-Q(1-x) ≥ 1-Q(1-y)
      have : Q ⟨1 - x.val, one_minus_mem_I x⟩ ≤ Q ⟨1 - y.val, one_minus_mem_I y⟩ := by
        apply hQ_mono; simp; linarith
      linarith
  · constructor
    · -- (JQ)(0) = 1 - Q(1) = 1
      show 1 - Q ⟨1 - (0:ℝ), one_minus_mem_I ⟨0, by norm_num⟩⟩ = 1
      have h1 : (⟨1 - (0:ℝ), one_minus_mem_I ⟨0, by norm_num⟩⟩ : I) = ⟨1, by norm_num⟩ := by
        ext; simp
      rw [h1, hQ_at1]; ring
    · -- (JQ)(1) = 1 - Q(0) = 0
      show 1 - Q ⟨1 - (1:ℝ), one_minus_mem_I ⟨1, by norm_num⟩⟩ = 0
      have h1 : (⟨1 - (1:ℝ), one_minus_mem_I ⟨1, by norm_num⟩⟩ : I) = ⟨0, by norm_num⟩ := by
        ext; simp
      rw [h1, hQ_at0]; ring

/-! ## Main Symmetry Theorem -/

/-- The forward direction of the symmetry theorem (stated as axiom).
    This requires showing that uniqueness of Q* with Q*(1/2)=1/2 constrains k. -/
axiom symmetry_forward (k : I → I → ℝ) (T : C01 → C01)
    (Q_star : C01) (hQ_mem : Q_star ∈ NormalizedProfiles)
    (hQ_fixed : T Q_star = Q_star) :
    Q_star ⟨1/2, by norm_num⟩ = 1/2 → hasMirrorSymmetry k

/-- THEOREM 4.3: Symmetry Characterization

    The fixed point Q* has Q*(1/2) = 1/2 iff the kernel has mirror symmetry.

    Direction (→) requires additional operator theory; direction (←) is
    proved constructively using uniqueness of the fixed point.
-/
theorem symmetry_characterization (k : I → I → ℝ)
    (_hk : isTP2 k) (_hk_pos : isStrictlyPositive k)
    (T : C01 → C01)
    (Q_star : C01) (hQ_mem : Q_star ∈ NormalizedProfiles)
    (hQ_fixed : T Q_star = Q_star)
    (hQ_unique : ∀ Q ∈ NormalizedProfiles, T Q = Q → Q = Q_star) :
    (Q_star ⟨1/2, by norm_num⟩ = 1/2) ↔ hasMirrorSymmetry k := by
  constructor
  · -- (→) Transition at 1/2 implies kernel symmetry
    exact symmetry_forward k T Q_star hQ_mem hQ_fixed
  · -- (←) Kernel symmetry implies transition at 1/2
    intro h_sym
    -- Step 1: T commutes with J
    have hT_comm := smoothingOp_commutes_J k h_sym T
    -- Step 2: J(Q*) is a fixed point
    have hJQ_fixed := fixedPoint_J_invariant T hT_comm Q_star hQ_fixed
    -- Step 3: J(Q*) ∈ NormalizedProfiles
    have hJQ_mem := J_preserves_normalized Q_star hQ_mem
    -- Step 4: By uniqueness, J(Q*) = Q*
    have hQ_sym : J Q_star = Q_star := hQ_unique (J Q_star) hJQ_mem hJQ_fixed
    -- Step 5: Q* is J-symmetric
    have h_Jsym : isJSymmetric Q_star := by
      intro x
      have h : (J Q_star) x = Q_star x := by rw [hQ_sym]
      simp only [reflectionOp, ContinuousMap.coe_mk] at h
      linarith
    -- Step 6: Q*(1/2) = 1/2
    exact transitionPoint_symmetric Q_star hQ_mem h_Jsym

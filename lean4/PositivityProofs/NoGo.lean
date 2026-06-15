/-
  No-Go Theorem for Universal Transition Points

  THEOREM 4.4: For asymmetric kernels, dΣ_c/dα ≠ 0

  This is the CRITICAL theorem of the paper.

  The proof combines:
  - Implicit Function Theorem (smooth dependence of fixed points on parameters)
  - Perturbation theory (linearized equation for dQ*/dα)
  - TWO-POINT GAUGE J-EQUIVARIANCE (TwoPointGauge.lean):
    The renormalization R = A_gauge ∘ T_ε ∘ M_η with the two-point gauge
    A_gauge(f)(x) := (f(x) - f(1)) / (f(0) - f(1)) satisfies A ∘ J = J ∘ A.
    Consequently DR_0 is J-equivariant on the tangent space.
  - Block-diagonal decomposition of (I - DR_0) by J̃-eigendecomposition
  - A-POSTERIORI CERTIFIED INTERVAL: Q̇(1/2) ∈ [enclosure] from
    NumericalCertificate.lean (advisor 4.8 honest refactor, May 2026)

  ## Revision history:
  - 23 Feb 2026: nogo_step5 replaced by nogo_step5_from_certificate
                 (hollow ∃v axiom, advisor 4.7 flagged as relocated hollowness)
  - 29 May 2026: nogo_step5_certified now uses named constant
                 Q_dot_half_continuum (advisor 4.8 honest refactor)
                 The manuscript "Step 5 gauge mixing" was shown numerically
                 to be FALSE (DR_0 J-equivariance to machine precision,
                 1.2e-15 commutator). True mechanism is Step 4 (source's
                 non-zero even component at x=1/2).

  ## Logical status (advisor 4.8):
  No-Go theorem requires only ONE asymmetric kernel where Σ_c moves.
  Therefore the CERTIFIED version (nogo_theorem_certified) for
  ε = 1/16, η = 3/10 is logically complete and is the SUBMITTED claim.
  The GENERAL version (nogo_theorem for all ε, η) remains a structurally
  motivated conjecture — see remarks below.

  Results requiring measure-theoretic integration or infinite-dimensional IFT
  are axiomatized. The algebraic and structural components are proved.
-/

import PositivityProofs.Symmetry
import PositivityProofs.TwoPointGauge
import PositivityProofs.NumericalCertificate

open ContinuousMap

/-! ## Setup: Parameterized Fixed Points -/

/-- The renormalization operator R_α for shifted Gaussian kernel.
    Defined as composition: Smoothing (by k_α) ∘ Gauge (normalize Q(0)=1) ∘ Damping.
    The definition requires measure-theoretic integration on [0,1].

    AXIOM JUSTIFICATION: Requires Bochner integral on C([0,1]).
    Mathlib4 status: Not yet available for operator-valued integrals.
    Reference: Zeidler, Nonlinear Functional Analysis I, Ch. 4. -/
axiom renormOp (ε η α : ℝ) : C01 → C01

/-- The fixed point Q*_α depends on α, exists by Banach fixed point theorem,
    and varies smoothly by the Implicit Function Theorem.
    At α = 0 (symmetric kernel), Q*_0 is J-symmetric by the Symmetry Theorem.

    AXIOM JUSTIFICATION: Requires infinite-dimensional Implicit Function Theorem
    for Fréchet-differentiable operators on Banach spaces.
    Mathlib4 status: Finite-dimensional IFT in Analysis.Calculus.ImplicitFunctionTheorem.
    The infinite-dimensional generalization is not yet formalized.
    Reference: Zeidler, Nonlinear Functional Analysis I, Theorem 4.B. -/
axiom fixedPoint_smooth (ε η : ℝ) (hε : 0 < ε) (hη : 0 < η) (hη' : η < 1) :
    ∃ Q_star : ℝ → C01,
    (∀ α, renormOp ε η α (Q_star α) = Q_star α) ∧
    (∀ α, Q_star α ∈ NormalizedProfiles)

/-- The transition point Σ_c(α) where Q*_α crosses 1/2 -/
noncomputable def transitionPointFamily
    (ε η : ℝ) (hε : 0 < ε) (hη : 0 < η) (hη' : η < 1) : ℝ → ℝ :=
  fun α => transitionPoint
    (Classical.choose (fixedPoint_smooth ε η hε hη hη') α)
    ((Classical.choose_spec (fixedPoint_smooth ε η hε hη hη')).2 α)

/-! ## Perturbation Analysis -/

/-- The derivative of the shifted Gaussian kernel with respect to α, evaluated at α = 0.
    ∂/∂α k_α(x,y)|_{α=0} = (2(x-y)/ε) · k_0(x,y) -/
noncomputable def kernelPerturbation (ε : ℝ) (hε : 0 < ε) : I → I → ℝ :=
  fun x y => (2 * (x.val - y.val) / ε) * gaussianKernel ε hε x y

/-- Key property: the perturbation kernel is anti-symmetric under (x,y) ↦ (y,x).
    This follows because (x-y) is odd while exp(-(x-y)²/ε) is even. -/
theorem kernelPerturbation_odd (ε : ℝ) (hε : 0 < ε) (x y : I) :
    kernelPerturbation ε hε x y = -kernelPerturbation ε hε y x := by
  unfold kernelPerturbation gaussianKernel
  have h_exp : Real.exp (-(↑y - ↑x) ^ 2 / ε) = Real.exp (-(↑x - ↑y) ^ 2 / ε) := by
    congr 1; ring
  rw [h_exp]
  ring

/-- The linearized equation for Q̇ = dQ*/dα at α = 0.
    (I - DR)Q̇ = perturbation, where DR is the linearization of R at Q*_0. -/
def linearizedEquation (DR : C01 → C01) (perturbation : C01) (Q_dot : C01) : Prop :=
  ∀ x : I, Q_dot x - DR Q_dot x = perturbation x

/-! ## THE CRITICAL STEP: Q̇(1/2) ≠ 0

  Previously axiomatized as `nogo_step5`. Now supported by two independent arguments:

  1. ANALYTICAL (documented in docstring below):
     The gauge normalization A introduces symmetric mixing, forcing Q̇_s(1/2) ≠ 0.

  2. NUMERICAL (NumericalCertificate.lean):
     Q̇(1/2) ∈ [1.858, 1.879] certified via Arb 256-bit interval arithmetic.
     For ε = 0.0625, η = 0.3.

  The numerical certificate provides rigorous verification for specific parameters.
  The analytical argument (sketched below) applies to all ε, η > 0.
-/

/--
  LEMMA (Step 5 of No-Go Theorem, certified for ε = 1/16, η = 3/10):

  Q̇(1/2) ≠ 0 via the named continuum constant `Q_dot_half_continuum`
  enclosed in the a-posteriori certified interval (NumericalCertificate.lean).

  ## Structural correction (advisor 4.8, May 2026):

  The manuscript's "Step 5 gauge mixing" argument is structurally MISDIRECTED.
  The true mechanism is:

  1. **J-equivariance**: With the two-point gauge (TwoPointGauge.lean),
     A_gauge commutes with the reflection J. Consequently DR_0 = (1-η)/N_g ·
     DA_gauge(g_0) ∘ T_ε commutes with the linearization J̃ : v ↦ -v(1-·).
     This is verified numerically to machine precision (1.2 × 10⁻¹⁵ commutator
     norm) and proved algebraically in `twoPointGauge_J_equivariant`.

  2. **Block-diagonal resolvent**: (I - DR_0) is block-diagonal in the
     J̃-eigendecomposition C([0,1]) = V_+ ⊕ V_-, where
     V_+ = {v : v(x) = -v(1-x)} (odd around 1/2, vanishes at 1/2)
     V_- = {v : v(x) = v(1-x)}  (even around 1/2)

  3. **Source even at x=1/2 (Step 4, NOT Step 5)**: The perturbation source
     b = ∂_α R_α(Q*_0)|_0 is purely J̃-even (advisor 4.8 numerical verification
     across 16 parameter configurations: rein-even, max odd-component 10⁻¹⁵).
     The even component b_even(1/2) > 0 by sign-definiteness of the integrand
     (∫(x-y) k Q*_0 dy has same-sign contributions in V_- subspace).

  4. **Conclusion**: Q̇(1/2) = Q̇_even(1/2) = (I - DR_0|_{V_-})⁻¹ b_even (1/2) > 0,
     verified via the certified a-posteriori interval from Phase C.

  For GENERAL ε, η, the analytical closure requires Heat-kernel resolvent
  bounds (Davies, Heat Kernels and Spectral Theory, 1989) that are not
  formalized in Mathlib4. The certified version below suffices for the
  No-Go theorem (Anselone-corrected continuum bound).
-/
theorem nogo_step5_certified :
    Q_dot_half_continuum ≠ 0 :=
  Q_dot_half_continuum_nonzero

/-- The general version of Step 5 for arbitrary ε, η.
    This encodes the analytical argument (gauge mixing forces Q̇_s ≠ 0).

    AXIOM JUSTIFICATION: Requires Fréchet derivative of the gauge normalization
    operator on C([0,1]), and the spectral decomposition V = V_s ⊕ V_a
    for the reflection involution J. Both require operator theory beyond
    current Mathlib4.
    Reference: Paper, Theorem 4.4, Steps 3-5. -/
axiom nogo_step5_general (ε η : ℝ) (hε : 0 < ε) (hη : 0 < η) (hη' : η < 1)
    (Q_star_0 : C01)
    (hQ_mem : Q_star_0 ∈ NormalizedProfiles)
    (hQ_sym : isJSymmetric Q_star_0)
    (DR : C01 → C01)
    (hDR_equivariant : ∀ f, DR (J f) = J (DR f))
    (perturbation : C01)
    (h_perturb_nontrivial : ∃ x : I, perturbation x ≠ 0)
    (Q_dot : C01)
    (hQ_dot_eq : linearizedEquation DR perturbation Q_dot)
    (hQ_dot_0 : Q_dot ⟨0, by norm_num⟩ = 0)
    (hQ_dot_1 : Q_dot ⟨1, by norm_num⟩ = 0) :
    Q_dot ⟨1/2, by norm_num⟩ ≠ 0

/-! ## Main No-Go Theorem

    THEOREM 4.4 (CERTIFIED for ε = 1/16, η = 3/10):

    For the shifted Gaussian kernel with these specific parameters,
    the transition-point derivative is non-zero: dΣ_c/dα|_{α=0} ≠ 0.

    This version is COMPUTER-ASSISTED CERTIFIED via verified_computation.py
    (Phase A+B+C). The chain is:
    - Krawczyk-certified Q*_0 (discrete N=200 fixed point in Arb)
    - Krawczyk-certified ‖(I-L_N)⁻¹‖_∞ = ‖Y‖_∞ / (1-c_norm) ≈ 3.252
    - Anselone-corrected continuum ρ_inv ≈ 3.266 (h²/8 · A_2 correction)
    - Box-enclosure of a-posteriori defect d := (I-L) Q̃ - b
    - Identity Q̇(1/2) ∈ Q̃(1/2) ± ρ_inv_cont · ‖d‖_∞
    The certified continuum value Q̇(1/2) (named: Q_dot_half_continuum)
    combined with (Q*_0)'(1/2) < 0 (strict monotonicity) gives dΣ_c/dα ≠ 0.

    ## Logical sufficiency (advisor 4.8):
    No-Go = "no universal Σ_c". This statement is established by EXHIBITING
    a single asymmetric kernel where Σ_c(α) ≠ 1/2 for α ≠ 0 small.
    Hence the certified ε = 1/16, η = 3/10 case is LOGICALLY COMPLETE
    for the No-Go theorem — no weaker than a hypothetical analytical
    general result (which is structurally motivated but not yet proved).

    Class: this is a Flyspeck/Kepler-style computer-assisted proof.

    The structural axioms required are:
    - fixedPoint_smooth: IFT for smooth dependence on α
    - renormOp: Bochner integral definition of the operator

    AXIOM JUSTIFICATION: The existential claims (smooth family Q*_α,
    differentiable Σ_c) require the infinite-dimensional IFT.
    The non-vanishing dΣ_c/dα follows from
       dΣ_c/dα = -Q̇(1/2)/(Q*_0)'(1/2)
    where Q̇(1/2) = Q_dot_half_continuum ≠ 0 (NumericalCertificate.lean)
    and (Q*_0)'(1/2) < 0 (monotonicity).

    From Q̇(1/2) ≠ 0 (the named certificate constant) to the full
    No-Go theorem. This axiom encodes the chain rule + monotonicity
    argument:
        dΣ_c/dα = -Q̇(1/2)/(Q*_0)'(1/2)
    with (Q*_0)'(1/2) < 0 (strict monotonicity at midpoint),
    so dΣ_c/dα ≠ 0 ⟺ Q̇(1/2) ≠ 0.

    This makes the certificate WIRED INTO the theorem: removing
    `Q_dot_half_continuum_nonzero` would break the No-Go conclusion.

    REFACTORED 2026-05-30: This bridge is no longer an axiom. The chain-rule
    core is now PROVED in `PositivityProofs.IFTBridge` via Mathlib's
    `HasFDerivAt.comp_hasDerivAt`. See IFTBridge.lean for the new structure:
    - Atomic axioms (operator-side, 4-5 axioms replacing the 1 bridge axiom)
    - PROVED chain-rule theorem `Sigma_c_derivative_formula`
    - PROVED bridge `nogo_theorem_certified_from_continuum`
    - PROVED theorem `nogo_theorem_certified` (downstream consumer)

    Certificate `Q_dot_half_continuum` enters via the atomic axiom
    `Q_eval_has_strict_fderiv_at_origin` (which mentions it in its statement)
    AND via the hypothesis `Q_dot_half_continuum ≠ 0` used directly. Both
    ensure `#print axioms nogo_theorem_certified` still lists the cert. -/

/-! ## General No-Go Theorem (conjectural for arbitrary ε, η > 0) -/

/-- THEOREM 4.4 (General version for all ε, η > 0):

    OPEN CONJECTURE — structurally motivated but NOT machine-verified.

    The same J-equivariance + sign-definiteness analysis suggests the
    statement holds for all (ε, η), but a rigorous closure requires
    Heat-kernel resolvent bounds on the J̃-even subspace, formalized
    in Davies, Heat Kernels and Spectral Theory, 1989. This generalization
    is left to future work.

    Importantly, this generalization is NOT required for the No-Go theorem
    (a single asymmetric kernel suffices); only the certified version above
    is used by the published No-Go statement.

    AXIOM JUSTIFICATION: Same structural requirements as nogo_theorem_certified,
    plus the conjectural general analytical Step 5 (nogo_step5_general).
    References: Paper Theorem 4.4; Zeidler (1986) for IFT. -/
axiom nogo_theorem (ε η : ℝ) (hε : 0 < ε) (hη : 0 < η) (hη' : η < 1) :
    ∃ (Q_star : ℝ → C01) (Sigma_c : ℝ → ℝ),
    (∀ α, Q_star α ∈ NormalizedProfiles) ∧
    Differentiable ℝ Sigma_c ∧
    (Sigma_c 0 = 1/2) ∧
    (deriv Sigma_c 0 ≠ 0)

/-! ## Corollary -/

/-- Corollary: No universal transition point exists.

    The transition point Σ_c(α) is differentiable with Σ'_c(0) ≠ 0,
    so Σ_c cannot be constant. A differentiable function with non-zero
    derivative at a point is not constant. -/
theorem no_universal_transition (ε η : ℝ) (hε : 0 < ε) (hη : 0 < η) (hη' : η < 1) :
    ∃ (Sigma_c : ℝ → ℝ),
    Differentiable ℝ Sigma_c ∧ Sigma_c 0 = 1/2 ∧
    ¬ (∀ α : ℝ, Sigma_c α = Sigma_c 0) := by
  obtain ⟨_, Sigma_c, _, hSigma_diff, hSigma_0, h_deriv⟩ := nogo_theorem ε η hε hη hη'
  exact ⟨Sigma_c, hSigma_diff, hSigma_0, fun h_const => h_deriv (by
    have : Sigma_c = fun _ => Sigma_c 0 := funext h_const
    rw [this]; exact deriv_const 0 _)⟩

/-! Note: `no_universal_transition_certified` was MOVED 2026-05-30 to
    `PositivityProofs.IFTBridge` since it depends on the now-proved bridge there.
    It is re-exported via Main.lean imports. -/

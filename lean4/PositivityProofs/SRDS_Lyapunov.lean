import Mathlib

/-!
# SRDS Formal Framework — continuous-time Lyapunov band (T2(ii), Itô-Lyapunov core)

The full autopoietic-stationarity theorem applies Itô's formula to a quadratic Lyapunov
functional `V(z_t)` of the SDE `dz = F dt + σ dW`, takes expectation (killing the martingale),
and obtains the drift inequality `(d/dt) E[V] ≤ −2c·E[V] + b`. Itô's formula itself is the deep
fact (only available in Lean ≥ v4.30 libraries). Everything *after* it — the continuous-time
Grönwall band absorption — is proved here in full at v4.29, conditional on that inequality.

`srds_lyapunov_continuous_band`: a differentiable `V` with `V' t ≤ −2c·V t + b` converges
geometrically into the stationary band of height `b/(2c)`:
`V t ≤ b/(2c) + (V 0 − b/(2c))·e^{−2c t}` for `t ≥ 0`. No `sorry`, no custom axioms.
-/

namespace SRDS

theorem srds_lyapunov_continuous_band (V V' : ℝ → ℝ) (c b : ℝ) (hc : 0 < c)
    (hV : ∀ t, HasDerivAt V (V' t) t)
    (hdrift : ∀ t, V' t ≤ -(2 * c) * V t + b) :
    ∀ t, 0 ≤ t → V t ≤ b / (2 * c) + (V 0 - b / (2 * c)) * Real.exp (-(2 * c) * t) := by
  have h2c : (0 : ℝ) < 2 * c := by linarith
  set L : ℝ := b / (2 * c) with hLdef
  have h2cL : 2 * c * L = b := by rw [hLdef]; field_simp
  -- derivative of g s = (V s - L) * exp (2c s)
  have hgHD : ∀ t, HasDerivAt (fun s => (V s - L) * Real.exp (2 * c * s))
      ((V' t + 2 * c * (V t - L)) * Real.exp (2 * c * t)) t := by
    intro t
    have hlin : HasDerivAt (fun s : ℝ => 2 * c * s) (2 * c) t := by
      simpa using (hasDerivAt_id t).const_mul (2 * c)
    have hexp : HasDerivAt (fun s => Real.exp (2 * c * s)) (Real.exp (2 * c * t) * (2 * c)) t := by
      simpa using hlin.exp
    have hmul := ((hV t).sub_const L).mul hexp
    convert hmul using 1
    ring
  have hganti : Antitone (fun s => (V s - L) * Real.exp (2 * c * s)) := by
    refine antitone_of_deriv_nonpos (fun t => (hgHD t).differentiableAt) (fun t => ?_)
    rw [(hgHD t).deriv]
    have hd : V' t + 2 * c * (V t - L) ≤ 0 := by
      have h := hdrift t
      have hrw : 2 * c * (V t - L) = 2 * c * V t - b := by rw [mul_sub, h2cL]
      rw [hrw]; nlinarith [h]
    exact mul_nonpos_of_nonpos_of_nonneg hd (Real.exp_pos _).le
  intro t ht
  have hcmp := hganti ht
  simp only [mul_zero, Real.exp_zero, mul_one] at hcmp
  -- hcmp : (V t - L) * exp (2c t) ≤ V 0 - L
  have hmul := mul_le_mul_of_nonneg_right hcmp (Real.exp_pos (-(2 * c * t))).le
  rw [mul_assoc, ← Real.exp_add, add_neg_cancel, Real.exp_zero, mul_one] at hmul
  have harg : -(2 * c * t) = -(2 * c) * t := by ring
  rw [harg] at hmul
  linarith [hmul]

-- Axiom audit (verified 2026-06-05 via `#print axioms`): depends only on the standard
-- `[propext, Classical.choice, Quot.sound]` — no `sorryAx`, no custom axioms.

end SRDS

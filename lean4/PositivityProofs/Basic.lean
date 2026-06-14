/-
  Positivity Paper - Lean 4 Formalization
  Basic Definitions and Setup

  Author: Ferdinand Schessl
  Date: 2026
-/

import Mathlib.Topology.ContinuousMap.Basic
import Mathlib.Topology.ContinuousMap.Algebra
import Mathlib.Topology.MetricSpace.Basic
import Mathlib.Topology.Order.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Order.ConditionallyCompleteLattice.Basic

open Set Filter Topology

/-! ## Basic Definitions -/

/-- The unit interval [0,1] as a subtype -/
abbrev I := Set.Icc (0 : ℝ) 1

/-- Continuous functions on [0,1] with values in ℝ -/
abbrev C01 := ContinuousMap I ℝ

/-- The cone of non-negative, non-increasing functions -/
def MonotoneCone : Set C01 :=
  { f | (∀ x : I, 0 ≤ f x) ∧ (∀ x y : I, x.val ≤ y.val → f y ≤ f x) }

/-- Normalized monotone profiles: Q(0) = 1, Q(1) = 0 -/
def NormalizedProfiles : Set C01 :=
  { Q ∈ MonotoneCone | Q ⟨0, by norm_num⟩ = 1 ∧ Q ⟨1, by norm_num⟩ = 0 }

/-! ## Reflection Operator -/

/-- Helper: 1-x is in [0,1] when x is in [0,1] -/
lemma one_minus_mem_I (x : I) : 1 - x.val ∈ Set.Icc (0 : ℝ) 1 := by
  constructor
  · linarith [x.prop.2]
  · linarith [x.prop.1]

/-- The map x ↦ 1-x is continuous on I -/
lemma continuous_one_minus_val : Continuous (fun x : I => (⟨1 - x.val, one_minus_mem_I x⟩ : I)) := by
  apply Continuous.subtype_mk
  exact continuous_const.sub continuous_subtype_val

/-- The reflection operator J: (Jf)(x) = 1 - f(1-x) -/
noncomputable def reflectionOp (f : C01) : C01 :=
  ⟨fun x => 1 - f ⟨1 - x.val, one_minus_mem_I x⟩, by
    apply Continuous.sub continuous_const
    exact f.continuous.comp continuous_one_minus_val⟩

notation "J" => reflectionOp

/-- A function is J-symmetric if f(x) + f(1-x) = 1 for all x -/
def isJSymmetric (f : C01) : Prop :=
  ∀ x : I, f x + f ⟨1 - x.val, one_minus_mem_I x⟩ = 1

/-- J is an involution: J(J(f)) = f -/
theorem reflectionOp_involution (f : C01) : J (J f) = f := by
  ext x
  simp only [reflectionOp, ContinuousMap.coe_mk]
  have : (⟨1 - (1 - x.val), one_minus_mem_I ⟨1 - x.val, one_minus_mem_I x⟩⟩ : I) = x := by
    ext; simp
  rw [this]; ring

/-! ## Transition Point -/

/-- The transition point where Q crosses 1/2 -/
noncomputable def transitionPoint (Q : C01) (_hQ : Q ∈ NormalizedProfiles) : ℝ :=
  sSup { x : ℝ | ∃ hx : x ∈ Set.Icc (0:ℝ) 1, Q ⟨x, hx⟩ ≥ 1/2 }

/-- For J-symmetric normalized profiles, Q(1/2) = 1/2 -/
theorem transitionPoint_symmetric (Q : C01) (_hQ : Q ∈ NormalizedProfiles)
    (h_sym : isJSymmetric Q) :
    Q ⟨1/2, by norm_num⟩ = 1/2 := by
  have h := h_sym ⟨1/2, by norm_num⟩
  have h_eq : (⟨1 - (1/2 : ℝ), one_minus_mem_I ⟨1/2, by norm_num⟩⟩ : I) = ⟨1/2, by norm_num⟩ := by
    ext; simp; ring
  rw [h_eq] at h
  linarith

import PositivityProofs.Main

#print axioms nogo_step5_certified
#print axioms nogo_theorem_certified
#print axioms no_universal_transition_certified
#print axioms Q_dot_half_continuum_nonzero

-- 2026-05-30: Chain-rule core is now a THEOREM (no longer axiom).
-- Verify its axiom dependencies are atomic (no bridge axiom).
#print axioms IFTBridge.Sigma_c_derivative_formula

-- Also verify twoPointGauge_J_equivariant is now PROVED (no longer axiom).
#print axioms twoPointGauge_J_equivariant

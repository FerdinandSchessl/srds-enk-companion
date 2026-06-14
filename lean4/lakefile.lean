import Lake
open Lake DSL

package «PositivityProofs» where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩
  ]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "master"

@[default_target]
lean_lib «PositivityProofs» where
  globs := #[.submodules `PositivityProofs]

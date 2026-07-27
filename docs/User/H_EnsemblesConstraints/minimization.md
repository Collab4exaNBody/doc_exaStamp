---
icon: material/chart-line-variant
---

# **Energy Minimization**

!!! warning "Not yet found in current source"

    No complete, wired energy-minimization scheme exists in the current `exaStamp`/`exaNBody` checkout — no `numerical_scheme` analogous to `verlet_nve`/`verlet_nhnvt`/`verlet_nhnpt`, and no gradient-descent/steepest-descent/conjugate-gradient pipeline anywhere in source or in any regression/sample config.

    The closest related code is `push_f_v_r_xform_minimization` (`exaStamp/src/numerical_schemes/push_vec3_2nd_order_xform_minimization.cpp`), a low-level position-push operator that clamps each force component to `±tolF` (default `1.0e-12`) before applying it — structurally similar to the normal Verlet position push, but with force clamping instead of a real convergence criterion. It has no `numerical_scheme` wired to it, no max-iteration/energy-tolerance slots, and is not referenced by any example anywhere in the repository — it reads as dead or unfinished code, not a documented feature. Treat this page as a placeholder until a real minimization scheme is implemented and used somewhere in the codebase.

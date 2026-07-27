# **Ensembles & Constraints**

This section covers how the simulation is integrated in time, how temperature and pressure are controlled, how the box can be deformed on a prescribed path, and how external walls or pistons can confine or impact the system.

- [**`numerical_scheme`**](numerical_scheme.md) — ONIKA's generic operator-alias mechanism, and the named schemes `exaStamp` ships
- [**Generic push operators**](push_operators.md) — the low-level position/velocity update building blocks every scheme below is composed from
- [**NVE ensemble**](nve_ensemble.md) — velocity-Verlet time integration
- [**NVT ensemble**](nvt_ensemble.md) — the Nosé-Hoover thermostat, which replaces the integration scheme itself
- [**NPT ensemble**](npt_ensemble.md) — Nosé-Hoover barostat
- [**Thermostats**](Thermostats/index.md) — Berendsen and Langevin, which couple to temperature without replacing the integration scheme
- [**Deformation Paths**](deformation.md) — prescribing a time-varying box deformation (constant strain-rate, interpolated, or piecewise-interpolated)
- [**Energy Minimization**](minimization.md) — not yet implemented in the current source
- [**Repulsive Walls**](pistons.md) — planar, cylindrical and spherical confining/impacting walls

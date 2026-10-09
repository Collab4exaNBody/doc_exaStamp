---
icon: fontawesome/solid/chalkboard-teacher
---

# User guide to exaStamp

This is the reference section of the documentation: how the simulation domain and regions are defined, what can be attached to grids and particles, and the full set of interatomic and bonding potentials available in `exaStamp`.

If you're looking for a guided introduction instead, see the **Beginner Guide** tab.

- [**Domain & Regions**](D_DomainRegions/index.md) — the simulation domain and named spatial regions used to populate or analyze it
- [**Particles Features**](F_Particles/index.md) — particle species, creation, output and analysis
- [**Grids Features**](E_Grids/index.md) — grid flavors and the per-particle fields they track
- [**Interatomic Potentials**](G_ForceFields/index.md) — pair, many-body, electrostatic and machine-learning potentials
- [**Bonding Potentials**](G_ForceFields/Intramolecular/index.md) — bond, bending, torsion and improper torsion potentials
- [**Ensembles & Constraints**](H_EnsemblesConstraints/index.md) — thermodynamic ensembles, thermostats and barostats, minimization, walls

!!! note

    Not every operator is described here yet. The complete list of operators available in your build, with their parameters, is printed by `exaStamp --help plugins` and `exaStamp --help <operator_name>`.

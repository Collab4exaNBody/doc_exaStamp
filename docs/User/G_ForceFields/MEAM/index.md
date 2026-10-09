---
icon: material/atom-variant
---

# **Modified Embedded-Atom Model (MEAM)**

The Modified Embedded-Atom Model extends [EAM](../EAM/index.md) with angular contributions to the electron density, and a many-body screening function that limits the interactions to the first neighbors. It describes metals with directional bonding and covalent materials better than EAM.

**exaStamp** provides two MEAM operators:

- [**MEAM**](meam.md): `meam_force`, MEAM for a single species.
- [**MEAM + Lennard-Jones**](meam_lj.md): `meam_lj_force`, MEAM for one species, plus Lennard-Jones interactions for all the other species pairs.

!!! note "Build options"

    The MEAM plugin has a few compile-time options:

    - `XSTAMP_MEAM_MAX_NEIGHBORS` (default 32): maximum number of neighbors per atom inside the MEAM cutoff. Increase it for dense or compressed systems.
    - `XSTAMP_MEAM_MULTIMAT_MAX_TYPES` (default 4): maximum number of species handled by `meam_lj_force`.
    - `XSTAMP_MEAM_ENFORCE_OVERFLOW_CHECK` (default `OFF`): check the per-atom neighbor buffer for overflows.

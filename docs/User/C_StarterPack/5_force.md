---
icon: lucide/square-function
---

# Interatomic Potential

The interatomic potential is chosen through the `compute_force` block. By default it does nothing (`compute_force: nop`); it is invoked as part of `compute_all_forces_energy`, called at every step of any numerical scheme:

```yaml linenums="1" hl_lines="2"
compute_force_prolog: zero_force_energy
compute_force: nop
compute_force_epilog: force_to_accel

compute_all_forces_energy:
  - compute_force_prolog
  - compute_force
  - compute_force_epilog
```

Redefining `compute_force` in your input file is enough to select a potential — you don't need to touch `compute_force_prolog`/`compute_force_epilog` or `compute_all_forces_energy`. Three examples are given below: a simple analytical pair potential with no external file ([Lennard-Jones](#lennard-jones-argon)), a tabulated potential read from a file ([EAM alloy](#eam-alloy-tantalum)), and a more complex analytical potential ([MEAM](#meam-tin)).

## Lennard-Jones (Argon)

`lj_compute_force` computes the standard 12/6 Lennard-Jones pair potential from two parameters, `epsilon` and `sigma`, up to a cutoff `rcut`:

```yaml linenums="1"
species:
  - Ar: { mass: 39.948 Da, z: 18, charge: 0.0 e- }

lj_compute_force:
  parameters: { epsilon: 0.0104 eV, sigma: 3.4 ang }
  rcut: 8.0 ang

compute_force: lj_compute_force
```

!!! tip

    For a system with multiple species, `lj_multi_force` takes a `common_parameters` fallback plus a per-pair `parameters` list keyed by `type_a`/`type_b` — see [Lennard-Jones](../G_ForceFields/Pair/Models/lj.md) for details.

## EAM alloy (Tantalum)

`eam/alloy`-format potentials are read from a tabulated file. The `eam_alloy_force` operator computes the whole potential — electron density, embedding energy and force — in a single pass:

```yaml linenums="1"
species:
  - Ta: { mass: 180.95 Da, z: 73, charge: 0 e- }

eam_alloy_force:
  rcut: 5.30 ang
  parameters:
    file: "Ta1_Ravelo_2013.eam.alloy"

compute_force:
  - eam_alloy_force
```

!!! tip

    More complex scenarios (multi-species alloys, the multi-pass/optimized variant with a separate ghost exchange of the embedding derivative, etc.) can also be set up — see the reference [EAM alloy](../G_ForceFields/EAM/alloy.md) section (still being written).

## MEAM (Tin)

`meam_force` implements the full (2NN) MEAM formalism directly from a set of analytical parameters — no external file:

```yaml linenums="1"
species:
  - Tin: { mass: 197.1508269E-27 kg, z: 50, charge: 0 e- }

meam_force:
  rcut: 3.69 ang
  parameters:
    rmax: 3.69 ang
    rmin: 0.0
    Ecoh: 4.93474273599999995322e-19 J
    E0: 4.93474273599999995322e-19 J
    A: 1.000E+00
    r0: 3.44 ang
    alpha: 6.200E+00
    delta: 0.000E+00
    beta0: 6.200E+00
    beta1: 6.000E+00
    beta2: 6.000E+00
    beta3: 6.000E+00
    t0: 1.000E+00
    t1: 4.500E+00
    t2: 6.500E+00
    t3: -0.183E+00
    s0: 1.440E+02
    s1: 0.000E+00
    s2: 0.000E+00
    s3: 0.000E+00
    Cmin: 0.800E+00
    Cmax: 2.800E+00
    Z: 1.200E+01
    rc: 4.0 ang
    rp: 0.1 ang

compute_force: meam_force
```

!!! tip

    `rcut`/`rmax`/`rmin`/`rc`/`rp` are cutoff-related distances, `Ecoh`/`E0`/`A`/`r0`/`alpha`/`delta` describe the universal energy curve, `beta0-3`/`t0-3` control the electron density contributions, `s0-3` are screening-related, and `Cmin`/`Cmax`/`Z` set the angular screening function — see the reference [MEAM potentials](../G_ForceFields/MEAM/meam.md) section (still being written) for the full formalism.

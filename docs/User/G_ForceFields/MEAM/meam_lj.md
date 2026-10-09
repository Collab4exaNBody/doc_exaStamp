# **MEAM + Lennard-Jones**

## **Description**

The `meam_lj_force` operator mixes a [MEAM](meam.md) potential for one species with [Lennard-Jones](../Pair/Models/lj.md) interactions for the other species pairs. A typical use is a metal (described by MEAM) in contact with a gas or a fluid (described by Lennard-Jones).

- Pairs of atoms of the species `meam_type` interact through MEAM. MEAM only "sees" atoms of this species.
- The other species pairs listed in `lj_parameters` interact through a Lennard-Jones potential, shifted to zero at its cutoff:

$$
E_{\mathrm{LJ}}(r) = 4\varepsilon\left[\left(\frac{\sigma}{r}\right)^{12} - \left(\frac{\sigma}{r}\right)^{6}\right] - E_{\mathrm{LJ}}^{\mathrm{raw}}(r_{\mathrm{cut}}) \quad \text{for} \quad r < r_{\mathrm{cut}}
$$

- Species pairs that are not listed do not interact.

At most `XSTAMP_MEAM_MULTIMAT_MAX_TYPES` species (4 by default, see the [MEAM overview](index.md)) can be used.

```{ .yaml title="Syntax" .syntax-block }
meam_lj_force:
  rcut: <float>
  ghost: <bool>
  meam_type: <string>
  parameters: { <MEAM parameters> }
  lj_parameters:
    - { type_a: <string>, type_b: <string>, rcut: <float>, epsilon: <float>, sigma: <float> }
```

```{ .yaml title="Parameters" .params-block }
rcut:           float, required       # Base cutoff radius of the MEAM part.
ghost:          bool, default true    # true: compute the MEAM terms on ghost atoms too (ghost layer of 2 x cutoff, no extra communication). false: ghost layer of 1 x cutoff, ghost forces must be sent back (include config_update_symmetric_forces.msp).
meam_type:      string, required      # Species described by MEAM.
parameters:     map, required         # MEAM parameters, see the MEAM page.
lj_parameters:  list, required        # Lennard-Jones parameters for the other species pairs.
```

## **Usage example**

!!! example "**Tin in an O2/N2 atmosphere**"
    ```yaml
    includes: [ config_update_symmetric_forces.msp ]   # needed with ghost: false

    grid_flavor: grid_flavor_multimat

    meam_lj_force:
      ghost: false
      meam_type: Sn
      rcut: 4.17 ang
      parameters:
        rmax: 4.17 ang
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
      lj_parameters:
        - { type_a: O2 , type_b: O2 , rcut: 8 ang , epsilon: 162.2273150e-23 J , sigma: 3.58 ang }
        - { type_a: N2 , type_b: N2 , rcut: 8 ang , epsilon: 131.3005758e-23 J , sigma: 3.70 ang }
        - { type_a: O2 , type_b: N2 , rcut: 8 ang , epsilon: 145.9470447e-23 J , sigma: 3.64 ang }
        - { type_a: O2 , type_b: Sn , rcut: 8 ang , epsilon: 150.0000000e-24 J , sigma: 3.00 ang }
        - { type_a: N2 , type_b: Sn , rcut: 8 ang , epsilon: 150.0000000e-24 J , sigma: 3.00 ang }

    compute_force: meam_lj_force
    ```

Complete inputs are in `exaStamp/data/regression_new/potentials/meam_lj/` (`Sn_O2_N2.msp`).

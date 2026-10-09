# **MEAM**

## **Description**

The `meam_force` operator computes the Modified Embedded-Atom Model potential with many-body screening, for a single species. The energy of atom $i$ reads

$$
E_i = F\left(\bar\rho_i\right) + \frac{1}{2}\sum_{j \neq i} S_{ij}\,\phi(r_{ij})
$$

**Partial electron densities.** Each neighbor $j$ contributes atomic densities $\rho^{(l)}(r) = e^{-\beta_l\left(r/r_0 - 1\right)}$, $l = 0 \dots 3$, weighted by the screening factor $S_{ij}$. They are combined into a spherical density $\rho_i^{(0)}$ and angular densities $\rho_i^{(1)}$, $\rho_i^{(2)}$, $\rho_i^{(3)}$. The background density is

$$
\bar\rho_i = \rho_i^{(0)}\,\frac{2}{1 + e^{-\Gamma_i}},
\qquad
\Gamma_i = \sum_{l=1}^{3} t_l\left(\frac{\rho_i^{(l)}}{\rho_i^{(0)}}\right)^2
$$

**Embedding function.**

$$
F(\bar\rho) = A\,E_c\,\frac{\bar\rho}{Z}\,\ln\frac{\bar\rho}{Z}
$$

where $E_c$ is the cohesive energy and $Z$ the coordination of the reference structure. The reference-structure density, used to build the pair term, combines the partial densities with the weights $s_l\,t_l$.

!!! tip

    Both `Ecoh` and `E0` enter the energy. In the examples shipped with exaStamp they are set to the same value.

**Pair term.** The pair interaction follows from a Rose-type equation of state, $E^u(r) = -E_0\left(1 + a^* + \delta\,a^{*3} r_0/r\right)e^{-a^*}$ with $a^* = \alpha\left(r/r_0 - 1\right)$.

**Screening.** The screening factor $S_{ij}$ of a pair is the product of the screening by every common neighbor $k$, computed from the ellipse parameter $C_{ikj}$ and the bounds $C_{\min}$, $C_{\max}$ (full screening below $C_{\min}$, none above $C_{\max}$). A polynomial smoothing brings the interactions to zero between $r_c - r_p$ and $r_c$.

!!! note "Ghost atoms"

    By default (`ghost: true`) the MEAM terms are also computed on ghost atoms, so no extra communication is needed, at the price of a ghost layer of twice the MEAM cutoff (`ghost_dist_max` is raised automatically). With `ghost: false`, the ghost layer is one cutoff wide, but the force contributions written on ghost atoms must be sent back to their owners: add `includes: [ config_update_symmetric_forces.msp ]` to the input file.

<div class="center-table" markdown>

| Parameter | Units    | Description                                              |
| :-------- | :------: | :------------------------------------------------------- |
| `rmax`    | distance | Maximum distance for the density contributions           |
| `rmin`    | distance | Minimum distance for the density contributions           |
| `Ecoh`    | energy   | Cohesive energy                                          |
| `E0`      | energy   | Energy scale of the pair term and of the embedding function |
| `A`       | —        | Embedding amplitude                                      |
| `r0`      | distance | Nearest-neighbor distance of the reference structure     |
| `alpha`   | —        | Exponent of the equation of state                        |
| `delta`   | —        | Cubic coefficient of the equation of state               |
| `beta0` … `beta3` | — | Decay rates of the partial densities                    |
| `t0` … `t3` | —      | Weights of the partial densities                         |
| `s0` … `s3` | —      | Reference-structure weights of the partial densities     |
| `Cmin`, `Cmax` | —   | Screening bounds                                         |
| `Z`       | —        | Number of first neighbors in the reference structure     |
| `rc`      | distance | Cutoff of the MEAM interactions                          |
| `rp`      | distance | Width of the smoothing interval $[r_c - r_p, r_c]$       |

</div>

All parameters are required.

```{ .yaml title="Syntax" .syntax-block }
meam_force:
  rcut: <float>
  ghost: <bool>
  parameters: { rmax: <float>, rmin: <float>, Ecoh: <float>, E0: <float>, A: <float>, r0: <float>,
                alpha: <float>, delta: <float>, beta0: <float>, beta1: <float>, beta2: <float>, beta3: <float>,
                t0: <float>, t1: <float>, t2: <float>, t3: <float>, s0: <float>, s1: <float>, s2: <float>, s3: <float>,
                Cmin: <float>, Cmax: <float>, Z: <float>, rc: <float>, rp: <float> }
```

```{ .yaml title="Parameters" .params-block }
rcut:        float, required       # Base cutoff radius. The actual cutoff may be larger, to include the screening neighbors.
ghost:       bool, default true    # true: compute the MEAM terms on ghost atoms too (ghost layer of 2 x cutoff, no extra communication). false: ghost layer of 1 x cutoff, ghost forces must be sent back (include config_update_symmetric_forces.msp).
parameters:  map, required         # MEAM parameters, see the table above.
```

## **Usage example**

!!! example "**Tin**"
    ```yaml
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

Complete inputs are in `exaStamp/data/regression_new/potentials/meam/`.

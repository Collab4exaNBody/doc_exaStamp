# **Lennard-Jones + Wolf**

## **Description**

The `ljwolf_compute_force` operator adds a [Lennard-Jones](lj.md) term and a [Wolf](coul_wolf.md) damped shifted Coulomb term:

$$
E(r) = E_{\mathrm{LJ}}(r) + E_{\mathrm{Wolf}}(r)
$$

with

$$
E_{\mathrm{LJ}}(r) =
\begin{cases}
4\varepsilon\left[\left(\dfrac{\sigma}{r}\right)^{12} - \left(\dfrac{\sigma}{r}\right)^{6}\right] - E_{\mathrm{shift}} & r \le r_{\mathrm{LJ}} \\
0 & r > r_{\mathrm{LJ}}
\end{cases}
\qquad
E_{\mathrm{Wolf}}(r) =
\begin{cases}
\dfrac{q_i q_j}{4\pi\varepsilon_0}\left[\dfrac{\operatorname{erfc}(\alpha r)}{r} - \dfrac{\operatorname{erfc}(\alpha r_c)}{r_c}\right] & r \le r_c \\
0 & r > r_c
\end{cases}
$$

$E_{\mathrm{shift}}$ is the Lennard-Jones energy at $r_{\mathrm{LJ}}$ when `shiftlj` is true, 0 otherwise. The Wolf force is shifted so that it vanishes at $r_c$, as described on the [Wolf page](coul_wolf.md). The charges $q_i$, $q_j$ are the species charges. The Wolf self energy is not included.

<div class="center-table" markdown>

| Parameter        | Units      | Description                                                        |
| :--------------- | :--------: | :----------------------------------------------------------------- |
| `lj_rcut`        | distance   | Cutoff $r_{\mathrm{LJ}}$ of the Lennard-Jones term (0 or missing disables it) |
| `lj.epsilon`     | energy     | Lennard-Jones well depth $\varepsilon$                             |
| `lj.sigma`       | distance   | Lennard-Jones distance $\sigma$                                    |
| `shiftlj`        | —          | Shift the Lennard-Jones energy to zero at `lj_rcut`                |
| `cw.alpha`       | 1/distance | Wolf damping parameter $\alpha$                                    |
| `cw.rc`          | distance   | Cutoff $r_c$ of the Wolf term                                      |
| `rcut`           | distance   | Cutoff radius of the pair potential, at least $\max(r_{\mathrm{LJ}}, r_c)$ |

</div>

!!! warning

    Always set `shiftlj` explicitly: it has no reliable default for this potential.

## **YAML syntax**

```yaml
ljwolf_compute_force:
  rcut: VALUE UNITS
  parameters:
    lj_rcut: VALUE UNITS
    lj: { epsilon: VALUE UNITS , sigma: VALUE UNITS }
    shiftlj: BOOL
    cw: { alpha: VALUE UNITS^-1 , rc: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    ljwolf_compute_force:
      rcut: 12.5 ang
      parameters:
        lj_rcut: 11.0 ang
        lj: { epsilon: 0.01 kcal/mol , sigma: 3.830864488 ang }
        shiftlj: true
        cw: { alpha: 0.2 1/ang , rc: 12.5 ang }

    # Symetric variant
    ljwolf_compute_force_symetric:
      rcut: 12.5 ang
      parameters:
        lj_rcut: 11.0 ang
        lj: { epsilon: 0.01 kcal/mol , sigma: 3.830864488 ang }
        shiftlj: true
        cw: { alpha: 0.2 1/ang , rc: 12.5 ang }
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    ljwolf_multi_force:
      rcut: 12.5 ang
      common_parameters: { lj_rcut: 11.0 ang , shiftlj: true , lj: { epsilon: 0.01 kcal/mol , sigma: 3.83 ang } , cw: { alpha: 0.2 1/ang , rc: 12.5 ang } }
      parameters:
        - { type_a: C , type_b: C , rcut: 12.5 ang , parameters: { lj_rcut: 11.0 ang , shiftlj: true , lj: { epsilon: 0.01 kcal/mol , sigma: 3.83 ang } , cw: { alpha: 0.2 1/ang , rc: 12.5 ang } } }
        - { type_a: C , type_b: N , rcut: 12.5 ang , parameters: { lj_rcut: 11.0 ang , shiftlj: true , lj: { epsilon: 0.01 kcal/mol , sigma: 3.83 ang } , cw: { alpha: 0.3 1/ang , rc: 12.5 ang } } }
    ```

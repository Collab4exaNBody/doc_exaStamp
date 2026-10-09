# **Lennard-Jones + Reaction Field**

## **Description**

The `ljrf_compute_force` operator adds a [Lennard-Jones](lj.md) term and a [reaction-field](coul_rf.md) electrostatic term:

$$
E(r) = E_{\mathrm{LJ}}(r) + E_{\mathrm{RF}}(r)
$$

with

$$
E_{\mathrm{LJ}}(r) =
\begin{cases}
4\varepsilon\left[\left(\dfrac{\sigma}{r}\right)^{12} - \left(\dfrac{\sigma}{r}\right)^{6}\right] - E_{\mathrm{shift}} & r \le r_{\mathrm{LJ}} \\
0 & r > r_{\mathrm{LJ}}
\end{cases}
\qquad
E_{\mathrm{RF}}(r) =
\begin{cases}
\dfrac{q_i q_j}{4\pi\varepsilon_0}\left[\dfrac{1}{r} + k_{\mathrm{rf}} r^2 - C_{\mathrm{rf}}\right] & r \le r_{\mathrm{rf}} \\
0 & r > r_{\mathrm{rf}}
\end{cases}
$$

$E_{\mathrm{shift}}$ is the Lennard-Jones energy at $r_{\mathrm{LJ}}$ when `shiftlj` is true (default), 0 otherwise. $k_{\mathrm{rf}}$ and $C_{\mathrm{rf}}$ are defined on the [reaction field page](coul_rf.md). The charges $q_i$, $q_j$ are the species charges.

<div class="center-table" markdown>

| Parameter        | Units    | Description                                                        |
| :--------------- | :------: | :----------------------------------------------------------------- |
| `lj_rcut`        | distance | Cutoff $r_{\mathrm{LJ}}$ of the Lennard-Jones term (0 or missing disables it) |
| `lj.epsilon`     | energy   | Lennard-Jones well depth $\varepsilon$                             |
| `lj.sigma`       | distance | Lennard-Jones distance $\sigma$                                    |
| `shiftlj`        | —        | Shift the Lennard-Jones energy to zero at `lj_rcut` (default `true`) |
| `rf.epsilon`     | —        | Dielectric constant of the surrounding continuum                   |
| `rf.rc`          | distance | Cutoff $r_{\mathrm{rf}}$ of the reaction field                     |
| `rcut`           | distance | Cutoff radius of the pair potential, at least $\max(r_{\mathrm{LJ}}, r_{\mathrm{rf}})$ |

</div>

## **YAML syntax**

```yaml
ljrf_compute_force:
  rcut: VALUE UNITS
  parameters:
    lj_rcut: VALUE UNITS
    lj: { epsilon: VALUE UNITS , sigma: VALUE UNITS }
    shiftlj: BOOL
    rf: { epsilon: VALUE , rc: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    ljrf_compute_force:
      rcut: 12.5 ang
      parameters:
        lj_rcut: 11.0 ang
        lj: { epsilon: 0.01 kcal/mol , sigma: 3.830864488 ang }
        rf: { epsilon: 100. , rc: 12.5 ang }

    # Symetric variant
    ljrf_compute_force_symetric:
      rcut: 12.5 ang
      parameters:
        lj_rcut: 11.0 ang
        lj: { epsilon: 0.01 kcal/mol , sigma: 3.830864488 ang }
        rf: { epsilon: 100. , rc: 12.5 ang }
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    ljrf_multi_force:
      rcut: 12.5 ang
      common_parameters: { lj_rcut: 11.0 ang , lj: { epsilon: 0.01 kcal/mol , sigma: 3.83 ang } , rf: { epsilon: 100. , rc: 12.5 ang } }
      parameters:
        - { type_a: C , type_b: C , rcut: 12.5 ang , parameters: { lj_rcut: 11.0 ang , lj: { epsilon: 0.01 kcal/mol , sigma: 3.83 ang } , rf: { epsilon: 100. , rc: 12.5 ang } } }
        - { type_a: C , type_b: N , rcut: 12.5 ang , parameters: { lj_rcut: 11.0 ang , lj: { epsilon: 0.02 kcal/mol , sigma: 3.60 ang } , rf: { epsilon: 100. , rc: 12.5 ang } } }
    ```

!!! note

    A rigid molecule variant, `ljrf_rigidmol_force`, is also available.

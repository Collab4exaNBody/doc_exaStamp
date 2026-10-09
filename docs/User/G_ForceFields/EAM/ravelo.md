# **Ravelo EAM**

## **Description**

The `ravelo_force` operator computes the EAM potential of Ravelo et al. (single species), with an analytic pair term and electron density and a tabulated embedding function.

The pair term is a Rose-type function below $r_s$ and a polynomial tail between $r_s$ and $r_c$. With $r^* = \alpha'\left(r/r_1 - 1\right)$:

$$
\phi(r) =
\begin{cases}
-U_0\,e^{-r^*}\left(1 + r^* + \beta_3 r^{*3} + \beta_4 r^{*4}\right) & r \le r_s \\[1ex]
U_0\,(r_c - r)^{s}\left[a_1 + a_2 (r_c-r) + a_3 (r_c-r)^2 + a_4 (r_c-r)^3\right] & r_s < r \le r_c \\[1ex]
0 & r > r_c
\end{cases}
$$

The electron density is, with $r_0 = \frac{\sqrt{3}}{2}a_0$ the nearest-neighbor distance of the bcc lattice,

$$
\rho(r) = \rho_0\left(\frac{r_c^{\,p} - r^{p}}{r_c^{\,p} - r_0^{\,p}}\right)^{q} \quad \text{for} \quad r \le r_c
$$

The embedding function $F(\rho)$ and its derivative are given as tables and interpolated with cubic splines.

See the [EAM overview](index.md) for the total energy and the available operators (`ravelo_force`, `ravelo_emb`, `ravelo_force_reuse_emb`, `ravelo_init`).

<div class="center-table" markdown>

| Parameter | Units    | Description                                         |
| :-------- | :------: | :-------------------------------------------------- |
| `U0`      | energy   | Pair energy scale $U_0$                             |
| `r1`      | distance | Reference distance $r_1$ of the pair term           |
| `alphap`  | —        | Exponent $\alpha'$ of the pair term                 |
| `beta3`, `beta4` | — | Higher-order coefficients of the pair term          |
| `rs`      | distance | Switching distance $r_s$ to the polynomial tail     |
| `s`       | —        | Exponent of the polynomial tail                     |
| `a1` … `a4` | —      | Coefficients of the polynomial tail                 |
| `rc`      | distance | Cutoff $r_c$ of the pair term and electron density  |
| `a0`      | distance | Lattice parameter $a_0$                             |
| `rho0`, `p`, `q` | — | Electron density parameters                         |
| `rho`, `f`, `df` | — | Tables of $\rho$, $F(\rho)$ and $F'(\rho)$ (same length) |
| `Ec`, `alpha`, `f3`, `f4` | — | Read but not used in the force computation   |
| `format`  | —        | Optional. `exastampv1`: the `f` and `df` tables are in SI units |

</div>

All scalar parameters are required. Like the other parameters, the `rho`, `f` and `df` lists accept units on each value.

## **YAML syntax**

The parameters are usually stored in a YAML file (searched in the data paths):

```yaml
ravelo_force:
  rcut: VALUE UNITS
  parameters:
    file: FILENAME
```

The same keys can also be given directly under `parameters`.

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.
- [x] FILENAME = YAML file with the scalar parameters and the `rho`, `f`, `df` tables.

## **Usage example**

!!! example "**Tantalum**"
    ```yaml
    ravelo_force:
      rcut: 5.3 ang
      parameters:
        file: ravelo_Ta1.yaml

    compute_force: ravelo_force
    ```

The parameter files `ravelo_Ta1.yaml` and `ravelo_Ta2.yaml` are shipped in `exaStamp/data/potentials/`. Complete inputs are in `exaStamp/data/regression_new/potentials/eam/eam_ravelo/`. This potential runs on CPU only.

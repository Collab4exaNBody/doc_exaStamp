# **Johnson EAM**

## **Description**

The `johnson_force` operator computes an analytic EAM potential in the Zhou–Johnson–Wadley form (single species). With $x = r/r_e$, the pair term and the electron density are

$$
\phi(r) = \frac{A\,e^{-\alpha(x-1)}}{1 + (x-\kappa)^{20}} - \frac{B\,e^{-\beta(x-1)}}{1 + (x-\lambda)^{20}},
\qquad
\rho(r) = \frac{f_e\,e^{-\beta(x-1)}}{1 + (x-\lambda)^{20}}
$$

The embedding function is defined piecewise, with $\rho_n = 0.85\,\rho_e$ and $\rho_0 = 1.15\,\rho_e$:

$$
F(\rho) =
\begin{cases}
\displaystyle\sum_{k=0}^{3} F_{n,k}\left(\frac{\rho}{\rho_n} - 1\right)^k & \rho < \rho_n \\[2ex]
\displaystyle\sum_{k=0}^{3} F_{k}\left(\frac{\rho}{\rho_e} - 1\right)^k & \rho_n \le \rho < \rho_0 \\[2ex]
F_o\left[1 - \ln\left(\frac{\rho}{\rho_e}\right)^{\eta}\right]\left(\frac{\rho}{\rho_e}\right)^{\eta} & \rho \ge \rho_0
\end{cases}
$$

See the [EAM overview](index.md) for the total energy and the available operators (`johnson_force`, `johnson_emb`, `johnson_force_reuse_emb`, `johnson_init`).

<div class="center-table" markdown>

| Parameter | Units    | Description                                     |
| :-------- | :------: | :---------------------------------------------- |
| `re`      | distance | Equilibrium nearest-neighbor distance $r_e$     |
| `fe`      | —        | Density scale $f_e$                             |
| `rhoe`    | —        | Equilibrium electron density $\rho_e$           |
| `alpha`, `beta` | —  | Decay exponents of the pair and density terms   |
| `A`, `B`  | energy   | Amplitudes of the repulsive and attractive pair terms |
| `kappa`, `lambda` | — | Cutoff-function shifts $\kappa$, $\lambda$     |
| `Fn0` … `Fn3` | energy | Embedding coefficients for $\rho < \rho_n$   |
| `F0` … `F3` | energy | Embedding coefficients for $\rho_n \le \rho < \rho_0$ |
| `Fo`      | energy   | Embedding coefficient for $\rho \ge \rho_0$     |
| `eta`     | —        | Embedding exponent $\eta$                       |

</div>

All parameters are required. `fe` and `rhoe` only need consistent units, since only $\rho/\rho_e$ enters the embedding function.

## **YAML syntax**

```yaml
johnson_force:
  rcut: VALUE UNITS
  parameters:
    re: VALUE UNITS
    fe: VALUE
    rhoe: VALUE
    alpha: VALUE
    beta: VALUE
    A: VALUE UNITS
    B: VALUE UNITS
    kappa: VALUE
    lambda: VALUE
    Fn0: VALUE UNITS
    Fn1: VALUE UNITS
    Fn2: VALUE UNITS
    Fn3: VALUE UNITS
    F0: VALUE UNITS
    F1: VALUE UNITS
    F2: VALUE UNITS
    F3: VALUE UNITS
    Fo: VALUE UNITS
    eta: VALUE
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage example**

!!! example "**Tantalum**"
    ```yaml
    johnson_force:
      rcut: 6.1 ang
      parameters:
        re: 2.860082 ang
        fe: 3.08634 eV/ang
        rhoe: 33.787168 eV/ang
        alpha: 8.489528
        beta: 4.527748
        A: 0.611679 eV
        B: 1.032101 eV
        kappa: 0.176977
        lambda: 0.353954
        Fn0: -5.103845 eV
        Fn1: -0.405524 eV
        Fn2: 1.112997 eV
        Fn3: -3.585325 eV
        F0: -5.14 eV
        F1: 0.0 eV
        F2: 1.640098 eV
        F3: 0.221375 eV
        eta: 0.848843
        Fo: -5.141526 eV

    compute_force: johnson_force
    ```

The complete input is `exaStamp/data/regression_new/potentials/eam/eam_johnson/single_specy.msp`.

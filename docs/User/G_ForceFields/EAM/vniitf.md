# **VNIITF EAM**

## **Description**

The `vniitf_force` operator computes the analytic EAM potential developed at VNIITF (single species). With $x = r/r_{t0} - 1$ and $S(r)$ a smoothing function that goes from 1 at $r_{\min}$ to 0 at $r_{\max}$:

$$
\phi(r) = \left[E_0 - \frac{2E_{coh}}{Z}\left(1 + \alpha x + \eta x^2 + \left(\mu + \frac{\alpha^3 D\,r_{t0}}{r}\right)x^3\right)e^{-\alpha x}\right] S(r)
$$

$$
\rho(r) = \frac{e^{-\beta x}}{Z}\,S(r),
\qquad
F(\rho) = A\,E_{coh}\,\rho^{n}\left(\ln \rho^{n} - 1\right)
$$

The smoothing function is, with $u = \dfrac{r_{\max} - r}{r_{\max} - r_{\min}}$ clamped to $[0,1]$,

$$
S(r) = u^4\left(35 - 84u + 70u^2 - 20u^3\right)
$$

See the [EAM overview](index.md) for the total energy and the available operators (`vniitf_force`, `vniitf_emb`, `vniitf_force_reuse_emb`, `vniitf_init`).

<div class="center-table" markdown>

| Parameter | Units    | Description                                         |
| :-------- | :------: | :-------------------------------------------------- |
| `rmax`    | distance | Distance where the smoothing function reaches 0     |
| `rmin`    | distance | Distance where the smoothing function starts        |
| `rt0`     | distance | Characteristic radius $r_{t0}$                      |
| `Ecoh`    | energy   | Cohesive energy $E_{coh}$                           |
| `E0`      | energy   | Constant energy term $E_0$ of the pair interaction  |
| `beta`    | —        | Decay rate $\beta$ of the electron density          |
| `A`       | —        | Embedding amplitude $A$                             |
| `Z`       | —        | Number of neighbors in the reference structure      |
| `n`       | —        | Embedding exponent $n$                              |
| `alpha`, `D`, `eta`, `mu` | — | Pair term coefficients                    |

</div>

## **YAML syntax**

```yaml
vniitf_force:
  rcut: VALUE UNITS
  parameters:
    rmax: VALUE UNITS
    rmin: VALUE UNITS
    rt0: VALUE UNITS
    Ecoh: VALUE UNITS
    E0: VALUE UNITS
    beta: VALUE
    A: VALUE
    Z: VALUE
    n: VALUE
    alpha: VALUE
    D: VALUE
    eta: VALUE
    mu: VALUE
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage example**

!!! example "**Tin**"
    ```yaml
    vniitf_force:
      rcut: 5.599 ang
      parameters:
        rmax: 5.599 ang
        rmin: 1.0 ang
        rt0: 3.437 ang
        Ecoh: 2.956031e-19 J
        E0: 5.15003855e-20 J
        beta: 6.000E+00
        A: 1.401E+00
        Z: 7.618E+00
        n: 0.724E+00
        alpha: 3.072E+00
        D: 1.450E-01
        eta: 2.720E+00
        mu: -1.87E+00

    compute_force: vniitf_force
    ```

The complete input is `exaStamp/data/regression_new/potentials/eam/eam_vniitf/single_specy.msp`.

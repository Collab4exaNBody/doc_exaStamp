# **Sutton–Chen EAM**

## **Description**

The `sutton_chen_force` operator computes the Sutton–Chen many-body potential (single species), a Finnis–Sinclair-type model with power-law functions:

$$
\phi(r) = \varepsilon\left(\frac{a_0}{r}\right)^{n},
\qquad
\rho(r) = \left(\frac{a_0}{r}\right)^{m},
\qquad
F(\rho) = -c\,\varepsilon\sqrt{\rho}
$$

so that the total energy reads

$$
E = \varepsilon \sum_i \left[\frac{1}{2}\sum_{j\neq i}\left(\frac{a_0}{r_{ij}}\right)^{n} - c\sqrt{\rho_i}\right]
$$

See the [EAM overview](index.md) for the available operators (`sutton_chen_force`, `sutton_chen_emb`, `sutton_chen_force_reuse_emb`, `sutton_chen_init`).

<div class="center-table" markdown>

| Parameter | Units    | Description                          |
| :-------- | :------: | :----------------------------------- |
| `epsilon` | energy   | Energy scale $\varepsilon$           |
| `a0`      | distance | Length scale $a_0$ (lattice constant) |
| `c`       | —        | Embedding strength $c$               |
| `n`       | —        | Exponent of the pair term            |
| `m`       | —        | Exponent of the electron density     |

</div>

## **YAML syntax**

```yaml
sutton_chen_force:
  rcut: VALUE UNITS
  parameters: { c: VALUE , epsilon: VALUE UNITS , a0: VALUE UNITS , n: VALUE , m: VALUE }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage example**

!!! example "**Copper**"
    ```yaml
    sutton_chen_force:
      rcut: 7.29 ang
      parameters:
        c: 3.317E+01
        epsilon: 3.605E-21 J
        a0: 0.327E-09 m
        n: 9.050E+00
        m: 5.005E+00

    compute_force: sutton_chen_force
    ```

The complete input is `exaStamp/data/regression_new/potentials/eam/eam_sutton_chen/single_specy.msp`. This potential runs on CPU only.

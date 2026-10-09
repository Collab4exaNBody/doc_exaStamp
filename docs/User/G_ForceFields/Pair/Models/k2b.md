# **k2b - Two-body kernel potential**

## **Description**

The `k2b` pair style is a machine-learned two-body potential, from Dézaphie *et al.*, *Comput. Mater. Sci.* **246** (2025) 113459. The pair energy is a weighted sum of Gaussians centered on a regular radial grid:

$$
e(r) = \Delta \sum_{k=1}^{K} w_k \exp\left(-\frac{(r-s_k)^2}{2\sigma^2}\right),
\qquad s_k = r_{min} + (k-1)\,\frac{r_{cut}-r_{min}}{K-1}
$$

with the parameters described in the following table.

<div class="center-table" markdown>

| Parameter | YAML key | Default | Description |
| :-------- | :------- | :-----: | :---------- |
| $K$          | `n_rbf` | 40  | Number of Gaussian basis functions |
| $r_{min}$    | `r_min` | 0.0 | First grid point (Å) |
| $r_{cut}$    | `r_cut` | 6.0 | Last grid point (Å) |
| $\sigma$     | `sigma` | 0.2 | Gaussian width (Å) |
| $\Delta$     | `delta` | 2.0 | Energy scale |
| $w_k$        | `w`     | —   | Fitted weights, exactly `n_rbf` values |

</div>

The `parameters` values are plain numbers, read **without unit conversion**.

`k2b` is built like every other pair style (always available, no CMake option). Like the other pair styles, it provides `k2b_compute_force`, `k2b_compute_force_symetric` and `k2b_multi_force` (see [Pair potentials](../index.md)).

## **YAML syntax**

```yaml
k2b_compute_force:
  rcut: VALUE UNITS
  parameters: { n_rbf: N , r_min: VALUE , r_cut: VALUE , sigma: VALUE , delta: VALUE , w: [ w_1, ..., w_N ] }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of `rcut`, passed to the conversion helper for internal units conversion.

## **`k2b_init`**

`k2b_init` takes the same `rcut` and `parameters` in `init_parameters`. It raises `rcut_max` before the system is set up, which the [descriptor operators](../../MLIP/descriptors.md) (`compute_descriptor_k2b`, ...) need.

## **Usage examples**

!!! example "**Force computation**"
    ```yaml
    k2b_compute_force:
      rcut: 6.0 ang
      parameters: { n_rbf: 8, r_min: 0.5, r_cut: 6.0, sigma: 0.4, delta: 1.5, w: [ -1.057, -2.0949, 0.90561, -2.56538, 0.21529, -0.80587, -2.65201, 0.04461 ] }
    ```

!!! example "**Descriptors**"
    ```yaml
    init_parameters:
      - species
      - k2b_init:
          rcut: 6.0 ang
          parameters: { n_rbf: 8, r_min: 0.5, r_cut: 6.0, sigma: 0.4, delta: 1.5, w: [ -1.057, -2.0949, 0.90561, -2.56538, 0.21529, -0.80587, -2.65201, 0.04461 ] }

    simulation_epilog:
      - compute_descriptor_k2b: { compute_derivative: true }
      - compute_descriptor_k2b_global
      - write_descriptor_k2b_global: { filename: "k2b_global.txt" }
    ```

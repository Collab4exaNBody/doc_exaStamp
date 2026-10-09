# **Relax**

## **Description**

The `relax_compute_force` operator applies a soft repulsion between atoms. It is meant to push apart atoms that are too close in an initial configuration (random insertion, overlapping molecules, ...) before switching to the physical potential. It is not a physical model.

With $\tilde r = \min\left(\max(r, r_1), r_c\right)$, the pair energy is

$$
E(r) = \frac{r_c}{\tilde r} - 1
$$

and the pair force has the same magnitude, $f(r) = \dfrac{r_c}{\tilde r} - 1$, directed so that the two atoms move apart. The force is **not** the derivative of the energy: it is constant below $r_1$, decreases linearly in $1/r$ up to $r_c$, and vanishes beyond $r_c$. There is no energy scale parameter: energies and forces are the raw numbers above, taken in internal units.

<div class="center-table" markdown>

| Parameter | Units    | Description                                         |
| :-------- | :------: | :-------------------------------------------------- |
| `r1`      | distance | Distance below which the repulsion stops increasing |
| `rc`      | distance | Distance beyond which the repulsion is zero         |
| `rcut`    | distance | Cutoff radius of the pair potential                 |

</div>

## **YAML syntax**

```yaml
relax_compute_force:
  rcut: VALUE UNITS
  parameters: { r1: VALUE UNITS , rc: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    relax_compute_force:
      rcut: 7.0 ang
      parameters: { r1: 4. ang , rc: 6. ang }

    # Symetric variant
    relax_compute_force_symetric:
      rcut: 7.0 ang
      parameters: { r1: 4. ang , rc: 6. ang }
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    relax_multi_force:
      rcut: 12.5 ang
      common_parameters: { r1: 4. ang , rc: 6. ang }
      parameters:
        - { type_a: C , type_b: C , rcut: 12.5 ang , parameters: { r1: 4. ang , rc: 6. ang } }
        - { type_a: C , type_b: N , rcut: 12.5 ang , parameters: { r1: 4. ang , rc: 6. ang } }
    ```

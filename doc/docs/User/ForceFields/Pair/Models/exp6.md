# **Exponential-6**

## **Description**

The `exp6_compute_force` operator calculates the normalized exponential-6 pair potential parameterized by well depth, equilibrium distance, and hardness:

$$
E(r) = \varepsilon \left[ \frac{6}{\alpha-6}\,\exp\!\big(\alpha(1 - r/r_m)\big) - \frac{\alpha}{\alpha-6}\left(\frac{r_m}{r}\right)^{6} \right] \quad \text{for} \quad r<r_c
$$

with $r_c$ the cutoff and $(\varepsilon,r_m,\alpha)$ as defined below.

<div class="center-table" markdown>

| Parameter     | Units    | Description                                              |
| :------------ | :------: | :------------------------------------------------------- |
| $\varepsilon$ | energy   | Well depth                                               |
| $r_m$         | distance | Distance at potential minimum                            |
| $\alpha$      | —        | Repulsion steepness (dimensionless)                      |
| $r_c$         | distance | Cutoff radius                                            |

</div>

## **YAML syntax**

```yaml
exp6_compute_force:
  rcut: VALUE UNITS
  parameters: { epsilon: VALUE UNITS , r_m: VALUE UNITS , alpha: VALUE }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    exp6_compute_force:
      parameters: { epsilon: 0.0100 eV , r_m: 3.80 ang , alpha: 13.0 }
      rcut: 8.0 ang

    # Symetric variant
    exp6_compute_force_symetric:
      parameters: { epsilon: 0.0100 eV , r_m: 3.80 ang , alpha: 13.0 }
      rcut: 8.0 ang  
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    exp6_multi_force:
      rcut: 8.0 ang
      common_parameters: { epsilon: 0.0 , r_m: 0.0 , alpha: 0.0 }
      parameters:
        - { type_a: Ar , type_b: Ar , rcut: 8.0 ang , parameters: { epsilon: 0.0100 eV , r_m: 3.80 ang , alpha: 13.0 } }
        - { type_a: Kr , type_b: Ar , rcut: 8.0 ang , parameters: { epsilon: 0.0120 eV , r_m: 4.00 ang , alpha: 12.5 } }
    ```

  
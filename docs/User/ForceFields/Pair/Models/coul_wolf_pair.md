# **Coulomb (Wolf)**

## **Description**

The `coul_wolf_compute_force` operator calculates the damped, truncated Coulomb (Wolf) pair potential:

$$
E(r) = \frac{1}{4\pi \varepsilon_0 \varepsilon_r} \, q_i q_j \left[\frac{\operatorname{erfc}(\alpha r)}{r} - \frac{\operatorname{erfc}(\alpha r_c)}{r_c}\right] \quad \text{for} \quad r<r_c
$$

with damping parameter $\alpha$ and cutoff $r_c$. The constant term ensures $E(r_c)=0$.

<div class="center-table" markdown>

| Parameter      | Units        | Description                                 |
| :------------- | :----------: | :------------------------------------------ |
| $\alpha$       | 1/distance   | Wolf damping parameter                       |
| $\varepsilon_r$| —            | Relative dielectric constant of medium       |
| $r_c$          | distance     | Cutoff radius                                |

</div>

## **YAML syntax**

```yaml
coul_wolf_compute_force:
  rcut: VALUE UNITS
  parameters: { alpha: VALUE UNITS^-1 , epsilon_r: VALUE }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    coul_wolf_compute_force:
      parameters: { alpha: 0.20 ang^-1 , epsilon_r: 1.0 }
      rcut: 10.0 ang

    # Symetric variant
    coul_wolf_compute_force_symetric:
      parameters: { alpha: 0.20 ang^-1 , epsilon_r: 1.0 }
      rcut: 10.0 ang  
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    coul_wolf_multi_force:
      rcut: 10.0 ang
      common_parameters: { alpha: 0.20 ang^-1 , epsilon_r: 1.0 }
      parameters:
        - { type_a: Na , type_b: Cl , rcut: 10.0 ang , parameters: { } }
        - { type_a: Na , type_b: Na , rcut: 10.0 ang , parameters: { } }
    ```
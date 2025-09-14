# **Coulomb (cutoff)**

## **Description**

The `coul_cut_compute_force` operator calculates the Coulomb pair potential with a simple real-space cutoff:

$$
E(r) = \frac{1}{4\pi \varepsilon_0 \varepsilon_r} \frac{q_i q_j}{r} \quad \text{for} \quad r<r_c \quad \text{(and } E=0 \text{ for } r\ge r_c\text{)}
$$

with $r_c$ the cutoff and $\varepsilon_r$ the relative permittivity of the medium.

<div class="center-table" markdown>

| Parameter      | Units      | Description                              |
| :------------- | :--------: | :--------------------------------------- |
| $\varepsilon_r$| —          | Relative dielectric constant of medium   |
| $r_c$          | distance   | Cutoff radius                            |

</div>

## **YAML syntax**

```yaml
coul_cut_compute_force:
  rcut: VALUE UNITS
  parameters: { epsilon_r: VALUE }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    coul_cut_compute_force:
      parameters: { epsilon_r: 1.0 }
      rcut: 12.0 ang

    # Symetric variant
    coul_cut_compute_force_symetric:
      parameters: { epsilon_r: 1.0 }
      rcut: 12.0 ang  
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    coul_cut_multi_force:
      rcut: 12.0 ang
      common_parameters: { epsilon_r: 1.0 }
      parameters:
        - { type_a: Na , type_b: Cl , rcut: 12.0 ang , parameters: { } }
        - { type_a: Na , type_b: Na , rcut: 12.0 ang , parameters: { } }
    ```
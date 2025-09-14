# **Reaction Field**

## **Description**

The `reaction_field_compute_force` operator calculates the reaction-field (RF) electrostatic pair potential assuming a dielectric continuum beyond the cutoff:

For $r \le r_c$,
$$
E(r) = \frac{1}{4\pi \varepsilon_0}\, q_i q_j \left[ \frac{1}{r} + k_{\mathrm{rf}} r^2 - C_{\mathrm{rf}} \right],
$$
with
$$
k_{\mathrm{rf}} = \frac{\varepsilon_{\mathrm{rf}} - 1}{2\varepsilon_{\mathrm{rf}} + 1}\,\frac{1}{r_c^3},
\qquad
C_{\mathrm{rf}} = \frac{1}{r_c} + k_{\mathrm{rf}} r_c^2,
$$
so that $E(r_c)=0$. For $r>r_c$, $E=0$.

<div class="center-table" markdown>

| Parameter          | Units    | Description                                       |
| :----------------- | :------: | :------------------------------------------------ |
| $\varepsilon_{\mathrm{rf}}$ | — | Dielectric constant of the surrounding continuum |
| $r_c$              | distance | Cutoff radius                                     |

</div>

## **YAML syntax**

```yaml
reaction_field_compute_force:
  rcut: VALUE UNITS
  parameters: { epsilon_rf: VALUE }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    reaction_field_compute_force:
      parameters: { epsilon_rf: 78.5 }  # e.g., water at room T
      rcut: 12.0 ang

    # Symetric variant
    reaction_field_compute_force_symetric:
      parameters: { epsilon_rf: 78.5 }
      rcut: 12.0 ang  
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    reaction_field_multi_force:
      rcut: 12.0 ang
      common_parameters: { epsilon_rf: 78.5 }
      parameters:
        - { type_a: Na , type_b: Cl , rcut: 12.0 ang , parameters: { } }
        - { type_a: Na , type_b: Na , rcut: 12.0 ang , parameters: { } }
    ```
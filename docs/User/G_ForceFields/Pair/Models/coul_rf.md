# **Coulomb (reaction field)**

## **Description**

The `coul_rf_compute_force` operator calculates the reaction-field (RF) electrostatic pair potential assuming a dielectric continuum beyond the cutoff:

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
so that $E(r_c)=0$. For $r>r_c$, $E=0$. The charges are the species charges. For per-atom charges, use `coulombic_rf`, see [Short range electrostatics](../../Electrostatics/short.md#reaction-field).

!!! note
    This style was named `reaction_field` before. The old operator names (`reaction_field_compute_force`...) and the
    potential name in `compute_force_pair_multimat` are still accepted, with a deprecation warning.

<div class="center-table" markdown>

| Parameter          | Units    | Description                                       |
| :----------------- | :------: | :------------------------------------------------ |
| `epsilon` | — | Dielectric constant $\varepsilon_{\mathrm{rf}}$ of the surrounding continuum |
| `rc`               | distance | Cutoff radius $r_c$ of the reaction field (use the same value as `rcut`) |

</div>

## **YAML syntax**

```yaml
coul_rf_compute_force:
  rcut: VALUE UNITS
  parameters: { epsilon: VALUE , rc: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    coul_rf_compute_force:
      parameters: { epsilon: 78.5 , rc: 12.0 ang }  # e.g., water at room T
      rcut: 12.0 ang

    # Symetric variant
    coul_rf_compute_force_symetric:
      parameters: { epsilon: 78.5 , rc: 12.0 ang }
      rcut: 12.0 ang  
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    coul_rf_multi_force:
      rcut: 12.0 ang
      common_parameters: { epsilon: 78.5 , rc: 12.0 ang }
      parameters:
        - { type_a: Na , type_b: Cl , rcut: 12.0 ang , parameters: { } }
        - { type_a: Na , type_b: Na , rcut: 12.0 ang , parameters: { } }
    ```
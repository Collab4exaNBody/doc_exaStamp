# **Coulomb (cutoff)**

## **Description**

The `coul_cut_compute_force` operator calculates the Coulomb pair potential with a simple real-space cutoff:

$$
E(r) = \frac{1}{4\pi \varepsilon_0 \varepsilon_r} \frac{q_i q_j}{r} - E_{\text{cut}} \quad \text{for} \quad r<r_c \quad \text{(and } E=0 \text{ for } r\ge r_c\text{)}
$$

with $r_c$ the cutoff and $\varepsilon_r$ the relative permittivity of the medium. As for every pair style, the energy is shifted by its value at the cutoff, $E_{\text{cut}}$, and the forces are not modified. The charges are the species charges. See also [Short range electrostatics](../../Electrostatics/short.md).

<div class="center-table" markdown>

| Parameter      | Units      | Description                              |
| :------------- | :--------: | :--------------------------------------- |
| `dielectric`   | —          | Relative dielectric constant $\varepsilon_r$ of the medium |
| `shift`        | —          | Required, but currently unused: the energy is always shifted by the pair template |
| `rcut`         | distance   | Cutoff radius $r_c$                      |

</div>

## **YAML syntax**

```yaml
coul_cut_compute_force:
  rcut: VALUE UNITS
  parameters: { dielectric: VALUE , shift: true }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    coul_cut_compute_force:
      parameters: { dielectric: 1.0 , shift: true }
      rcut: 12.0 ang

    # Symetric variant
    coul_cut_compute_force_symetric:
      parameters: { dielectric: 1.0 , shift: true }
      rcut: 12.0 ang  
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    coul_cut_multi_force:
      rcut: 12.0 ang
      common_parameters: { dielectric: 1.0 , shift: true }
      parameters:
        - { type_a: Na , type_b: Cl , rcut: 12.0 ang , parameters: { } }
        - { type_a: Na , type_b: Na , rcut: 12.0 ang , parameters: { } }
    ```
# **Coulomb (Wolf)**

## **Description**

The `coul_wolf_compute_force` operator calculates the damped, shifted Coulomb (Wolf) pair potential, as LAMMPS `pair_style coul/wolf`:

$$
E(r) = \frac{1}{4\pi \varepsilon_0} \, q_i q_j \left[\frac{\operatorname{erfc}(\alpha r)}{r} - \frac{\operatorname{erfc}(\alpha r_c)}{r_c}\right] \quad \text{for} \quad r<r_c
$$

with damping parameter $\alpha$ and cutoff $r_c$. The constant term ensures $E(r_c)=0$. The force is also shifted to vanish at $r_c$. The charges are the species charges.

The self energy of each particle is not included: add the `coulombic_wolf_self` operator with `per_atom_charge: false`. For per-atom charges, use `coulombic_wolf`. Both are described in [Short range electrostatics](../../Electrostatics/short.md#wolf-summation).

!!! note
    This style was named `coul_wolf_pair` before. The old operator names (`coul_wolf_pair_compute_force`...) and the
    potential name in `compute_force_pair_multimat` are still accepted, with a deprecation warning.

<div class="center-table" markdown>

| Parameter      | Units        | Description                                 |
| :------------- | :----------: | :------------------------------------------ |
| `alpha`        | 1/distance   | Wolf damping parameter $\alpha$             |
| `rc`           | distance     | Cutoff radius $r_c$ of the Wolf sum (use the same value as `rcut`) |
| `rcut`         | distance     | Cutoff radius of the pair potential         |

</div>

## **YAML syntax**

```yaml
coul_wolf_compute_force:
  rcut: VALUE UNITS
  parameters: { alpha: VALUE UNITS^-1 , rc: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    coul_wolf_compute_force:
      parameters: { alpha: 0.20 ang^-1 , rc: 10.0 ang }
      rcut: 10.0 ang

    # Symetric variant
    coul_wolf_compute_force_symetric:
      parameters: { alpha: 0.20 ang^-1 , rc: 10.0 ang }
      rcut: 10.0 ang

    # Self energy (thermodynamic output only)
    coulombic_wolf_self:
      parameters: { alpha: 0.20 ang^-1 , rc: 10.0 ang }
      per_atom_charge: false
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    coul_wolf_multi_force:
      rcut: 10.0 ang
      common_parameters: { alpha: 0.20 ang^-1 , rc: 10.0 ang }
      parameters:
        - { type_a: Na , type_b: Cl , rcut: 10.0 ang , parameters: { } }
        - { type_a: Na , type_b: Na , rcut: 10.0 ang , parameters: { } }
    ```

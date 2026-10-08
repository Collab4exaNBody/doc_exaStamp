# **Coulomb (DSF)**

## **Description**

The `coul_dsf_compute_force` operator calculates the damped shifted force Coulomb pair potential (Fennell and Gezelter), as LAMMPS `pair_style coul/dsf`:

$$
E(r) = \frac{q_i q_j}{4\pi\varepsilon_0}\left[\frac{\operatorname{erfc}(\alpha r)}{r} - \frac{\operatorname{erfc}(\alpha r_c)}{r_c}
+ \left(\frac{\operatorname{erfc}(\alpha r_c)}{r_c^2} + \frac{2\alpha}{\sqrt{\pi}}\frac{e^{-\alpha^2 r_c^2}}{r_c}\right)(r - r_c)\right]
\quad \text{for } r < r_c
$$

with damping parameter $\alpha$ and cutoff $r_c$. Both the energy and the force vanish at $r_c$. The charges are the species charges.

As in LAMMPS, $\operatorname{erfc}(\alpha r)$ uses the Abramowitz–Stegun approximation, so $E(r_c)$ is about $1.8\times10^{-7}$ eV per unit charge product instead of 0. The pair template subtracts this value from every pair: energies differ from LAMMPS by this constant per pair, forces are identical.

The self energy of each particle is not included: add the `coulombic_dsf_self` operator with `per_atom_charge: false`. For per-atom charges, use `coulombic_dsf`. Both are described in [Short range electrostatics](../../Electrostatics/short.md#damped-shifted-force).

<div class="center-table" markdown>

| Parameter      | Units        | Description                                 |
| :------------- | :----------: | :------------------------------------------ |
| `alpha`        | 1/distance   | DSF damping parameter $\alpha$             |
| `rc`           | distance     | Cutoff radius $r_c$ of the DSF shift (use the same value as `rcut`) |
| `rcut`         | distance     | Cutoff radius of the pair potential         |

</div>

## **YAML syntax**

```yaml
coul_dsf_compute_force:
  rcut: VALUE UNITS
  parameters: { alpha: VALUE UNITS^-1 , rc: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    coul_dsf_compute_force:
      parameters: { alpha: 0.20 ang^-1 , rc: 10.0 ang }
      rcut: 10.0 ang

    # Symetric variant
    coul_dsf_compute_force_symetric:
      parameters: { alpha: 0.20 ang^-1 , rc: 10.0 ang }
      rcut: 10.0 ang

    # Self energy (thermodynamic output only)
    coulombic_dsf_self:
      parameters: { alpha: 0.20 ang^-1 , rc: 10.0 ang }
      per_atom_charge: false
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    coul_dsf_multi_force:
      rcut: 10.0 ang
      common_parameters: { alpha: 0.20 ang^-1 , rc: 10.0 ang }
      parameters:
        - { type_a: Na , type_b: Cl , rcut: 10.0 ang , parameters: { } }
        - { type_a: Na , type_b: Na , rcut: 10.0 ang , parameters: { } }
    ```

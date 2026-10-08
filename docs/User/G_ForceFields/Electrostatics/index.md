# **Electrostatic potentials**

exaStamp computes Coulomb interactions either with a cutoff (short range methods) or with the full periodic sum
(long range methods). All methods follow the LAMMPS formulas and were validated against LAMMPS.

<div class="center-table" markdown>

| Method | Operators | Cost | Use it for |
| :----- | :-------- | :--- | :--------- |
| [Plain cutoff](short.md#standard-coulombic-interaction) | `coul_cut` (pair style) | $O(N)$ | Screened or dilute systems only |
| [Damped shifted force](short.md#damped-shifted-force) | `coulombic_dsf`, `coul_dsf` | $O(N)$ | Ionic systems, good energy conservation |
| [Wolf summation](short.md#wolf-summation) | `coulombic_wolf`, `coul_wolf` | $O(N)$ | Ionic systems |
| [Reaction field](short.md#reaction-field) | `coulombic_rf`, `coul_rf` | $O(N)$ | Polar molecules in a dielectric medium |
| [Ewald summation](long.md#ewald-summation) | `coulombic_ewald_init`, `coulombic_ewald_short_range`, `coulombic_ewald_long_range` | $O(N \cdot N_k)$ | Exact periodic sum, small systems |
| [PPPM](long.md#particle-particle-particle-mesh) | `coulombic_pppm_init`, `coulombic_ewald_short_range`, `coulombic_pppm` | $O(N + M\log M)$ | Exact periodic sum, large systems |

</div>

Two families of operators exist:

- **`coulombic_*` operators** read per-particle charges (the `charge` field) by default, or the species charges with
  `per_atom_charge: false`.
- **Pair styles** (`coul_cut`, `coul_dsf`, `coul_wolf`, `coul_rf`, and the combined `ljwolf`, `ljrf`, `exp6rf`,
  `ljexp6rf`) use the species charges and support the multi-species strategies of the
  [pair potential template](../Pair/index.md).

Charge related helper operators:

<div class="center-table" markdown>

| Operator | Role |
| :------- | :--- |
| `copy_charge_species_to_particle` | Fills the per-particle `charge` field with the species charges. |
| `sum_charges` | Total charge, sum of squared charges and number of atoms, from the species charges. Needed by Ewald and PPPM. |
| `sum_charges_pc` | Same, from the per-particle `charge` field. |

</div>

## **Migrating from older inputs**

Several operators were renamed or replaced. Renamed operators keep working under their old name and print a
deprecation warning once. Removed operators stop the run with a message naming their replacement.

<div class="center-table" markdown>

| Old name | Now | Notes |
| :------- | :-- | :---- |
| `coul_wolf_pair_*` (pair style `coul_wolf_pair`) | `coul_wolf_*` (`coul_wolf`) | Renamed, same parameters. |
| `reaction_field_*` (pair style `reaction_field`) | `coul_rf_*` (`coul_rf`) | Renamed, same parameters. |
| `reaction_field` (per-atom charge operator) | `coulombic_rf` | Same parameters. The `compute_virial` slot is gone: the virial is computed with the energy. |
| `copy_charge_specy_to_particle` | `copy_charge_species_to_particle` | Renamed. |
| `coul_wolf_pc` | `coulombic_wolf` | Removed. Same parameters; the self energy is now included. |
| `coul_dsf_pc` | `coulombic_dsf` | Removed. Same parameters; the self energy is now included. |
| `coul_wolf_self` | (included in `coulombic_wolf`) | Removed. With the `coul_wolf` pair style, use `coulombic_wolf_self` with `per_atom_charge: false`. |
| `ewald_init` | `coulombic_ewald_init` or `coulombic_pppm_init` | Removed. New parameters, see [Long range](long.md). |
| `ewald_short_range_pc`, `ewald_short_range_*` | `coulombic_ewald_short_range` | Removed. Parameters come from the initialization operator. |
| `ewald_long_range`, `ewald_long_range_pc` | `coulombic_ewald_long_range` or `coulombic_pppm` | Removed. |
| `ewald_potential_energy_shift` | (included) | Removed. The self and background energies are part of the long range operators. |

</div>

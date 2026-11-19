# **General bonding potential**
  
In **exaStamp**, the intramolecular bonding interactions are associated to bonds, bending angles,
torsion angle and improper torsion angles.
The bonding energy $E^{\text{bonding}}$ is simply:

$$
E^{\text{bonding}} = E^{\text{bond}} + E^{\text{bend}} + E^{\text{torsion}} + E^{\text{improper}}
$$

where $E^{\text{bond}}$, $E^{\text{bend}}$, $E^{\text{torsion}}$ and $E^{\text{improper}}$ are the energies associated
to all bonds, bending angles, torsion angles and improper torsion angles, respectively.
Each kind of term is computed by its own operator (`compute_force_bond`, `compute_force_bend`, `compute_force_torsion`,
`compute_force_improper`), and intramolecular pairs (atoms of the same molecule close in the bond graph) by
`intramolecular_pair_force`. These operators take their parameters from the force field of the system, which comes
from one of three sources:

- an FAtomes file read with `read_fatomes_mol`, which holds the force field;
- a molecule dump read with `read_dump_molecule`, which stores it in its header;
- the input file, with `molecule_force_field` in `setup_system`, for systems read without their force field
  (e.g. `read_xyz_molecules`).

## **Force field in the input file: `molecule_force_field`**

!!! example

    ```yaml
    species:
      - CA: { mass: 12.011 g/mol, charge: -0.115 e-, molecule: MOL }
      - HA: { mass: 1.008 g/mol, charge: 0.115 e-, molecule: MOL }

    molecule_force_field:
      rf_self_pairs: true            # reaction field between an atom and itself (default true)
      long_range_correction: true    # long range correction of the pair energy and virial (default true)
      potentials_for_bonds:
        - type_1
        - type_2
      potentials_for_angles:
        - type_1
      potentials_for_torsions:
        - type_1
      potentials_for_impropers:
        - type_1
      mol_pair_weights:
        CA_CA: { bond: 0.0, bend: 0.0, torsion: 0.5, bond_rf: 0.0, bend_rf: 0.0, torsion_rf: 0.5 }
        CA_HA: { bond: 0.0, bend: 0.0, torsion: 0.5, bond_rf: 0.0, bend_rf: 0.0, torsion_rf: 0.5 }
        HA_HA: { bond: 0.0, bend: 0.0, torsion: 0.5, bond_rf: 0.0, bend_rf: 0.0, torsion_rf: 0.5 }
      potentials_for_pairs:
        - { type_a: CA, type_b: CA, potential: { rcut: 10. ang, lj: { epsilon: 0.29 kJ/mol, sigma: 3.55 ang }, rf: { epsilon: 2.0, rc: 12. ang } } }
        - { type_a: CA, type_b: HA, potential: { rcut: 10. ang, lj: { epsilon: 0.15 kJ/mol, sigma: 2.98 ang }, rf: { epsilon: 2.0, rc: 12. ang } } }
        - { type_a: HA, type_b: HA, potential: { rcut: 10. ang, lj: { epsilon: 0.13 kJ/mol, sigma: 2.42 ang }, rf: { epsilon: 2.0, rc: 12. ang } } }

    setup_system:
      - domain: { cell_size: 8. ang, periodic: [ true, true, true ], expandable: false }
      - read_xyz_molecules: { filename: "system.xyz" }
      - molecule_force_field
    ```

- `potentials_for_bonds`, `potentials_for_angles`, `potentials_for_torsions`, `potentials_for_impropers`: lists of
  bonded potentials. Their `types` are force field types: the `ff` key of [species](../../F_Particles/species.md),
  the species name by default.
- `mol_pair_weights`: weights of intramolecular pairs, for each species pair `A_B`. `bond`, `bend` and `torsion` scale
  the pair potential of atoms 1-2, 1-3 and 1-4 apart in the bond graph; `bond_rf`, `bend_rf` and `torsion_rf` scale the
  reaction field. Pairs further apart are computed as intermolecular pairs.
- `potentials_for_pairs`: pair potentials (Lennard-Jones or Exp-6, plus reaction field) for every species pair, as in
  [ljexp6rf_lj](../Pair/Models/ljexp6rf_lj.md) and [ljexp6rf_exp6](../Pair/Models/ljexp6rf_exp6.md). Cross pairs are not built from a mixing rule: list them all.

`scripts/python/fatomes_to_yaml.py` writes this block, and the system in `read_xyz_molecules` format, from an FAtomes
file and its DONNEES file (mixing rules applied). Both ways of reading the system then give the same forces and
energies.

## **Non-bonding forces and precision**

The non-bonding forces (`potentials_for_pairs`, with the intramolecular pair weights) are computed by one of two
operators:

<div class="center-table" markdown>

| Operator | Precision |
| :------- | :-------- |
| `ljexp6rf_pc` | double precision (default) |
| `ljexp6rf_pc_fp32` | pair terms in single precision, sums of forces, energies and virial in double precision |

</div>

`data/config/config_molecule.msp` uses `ljexp6rf_pc`. To use the mixed precision operator, replace it in
`compute_nonbonding_forces`:

```{ .yaml title="Syntax" .syntax-block }
ljexp6rf_pc_fp32:
  enable_pair_weights: false
  per_atom_charge: true
  use_symmetry: false

compute_nonbonding_forces:
  rebind: { parameters: potentials_for_pairs }
  body: [ ljexp6rf_pc_fp32 ]
```

!!! tip

    `ljexp6rf_pc_fp32` is faster on GPUs with a low double precision throughput (2.4 to 2.9 times faster for the
    non-bonding forces of condensed polybutadiene and TATB on a laptop GPU); it brings almost nothing on CPU. Atomic
    forces differ from double precision by about 1e-7 (relative, up to 1e-6), the potential energy by about 1e-6.
    Use `ljexp6rf_pc` for accurate energies or comparisons with reference data.

## **Reaction field at the cutoff**

The reaction field energy is zero at its cutoff, but its force is not (see
[Force at the cutoff](../Electrostatics/short.md#force-at-the-cutoff)). The `reaction_field_cutoff_mode` operator
sets the treatment of the force at the cutoff for all pair potentials of the force field, whatever their origin
(FAtomes and DONNEES files, molecule dump, `molecule_force_field`). Put it in `setup_system`, after the reader:

```{ .yaml title="Syntax" .syntax-block }
setup_system:
  - read_fatomes_mol: { filename: "FAtomes_tatb_condensed" , stampinput: "DONNEES_tatb_condensed" }
  - reaction_field_cutoff_mode: { mode: switching , rs: 11.5 ang }   # or { mode: shifted_force }
```

<div class="center-table" markdown>

| Parameter | Default | Description |
| :-------- | :-----: | :---------- |
| `mode` | required | `truncated` (plain reaction field), `shifted_force` or `switching` |
| `rs` | — | Distance where switching starts, below the reaction field cutoff (`switching` only) |

</div>

The cutoff mode applies to `ljexp6rf_pc`, `ljexp6rf_pc_fp32` and `intramolecular_pair_force`. With
`molecule_force_field`, it can also be given in each `rf` block of `potentials_for_pairs`
(`rf: { epsilon: 2.2, rc: 12.5 ang, cutoff_mode: shifted_force }`).

!!! warning
    The cutoff mode is not stored in molecule dumps. When restarting from a dump, call `reaction_field_cutoff_mode`
    again after `read_dump_molecule`.

## **Potential types**

where `type_1` and `type_2` stand for bonded potentials of the types described in the following pages, also accessible in the left panel:

- [**Bond**](Bond/index.md)
- [**Bend**](Bend/index.md)
- [**Torsion**](Torsion/index.md)
- [**Improper**](Improper/index.md)

!!! note "Terms without parameters"

    Bonds, bending angles, torsions and improper torsions are deduced from the connectivity of the molecules. A term whose
    atom types match no entry of the corresponding potential list contributes no force and no energy. The number of such
    terms is reported once, in a warning at the beginning of the simulation. To switch a term off on purpose, give it
    the [no_potential](Bond/no_potential.md) type: these terms are not counted in the warning.

!!! note "Improper torsions"

    Improper torsions exist for atoms with exactly three bonded neighbours, the central atom first and its neighbours
    in connectivity order. When the force field defines no improper potential at all, improper torsions are not
    counted in the warning above.

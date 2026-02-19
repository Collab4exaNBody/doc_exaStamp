# **General bonding potential**
  
In **exaStamp**, the intramolecular bonding interactions are associated to bonds, bending angles,
torsion angle and improper torsion angles.
The bonding energy $E^{\text{bonding}}$ is simply:

$$
E^{\text{bonding}} = E^{\text{bond}} + E^{\text{bend}} + E^{\text{torsion}} + E^{\text{improper}}
$$

where $E^{\text{bond}}$, $E^{\text{bend}}$, $E^{\text{torsion}}$ and $E^{\text{improper}}$ are the energies associated
to all bonds, bending angles, torsion angles and improper torsion angles, respectively.
To each type of intramolecular degree of freedom corresponds an
operator as illustrated by the examples below:

!!! example

    ```yaml
    # Bond potential
    compute_force_bond:
      potentials_for_bonds:
        - type_1
        - type_2

    # Bending potential
    compute_force_bend:
      potentials_for_angles:
         - type_1
         - type_2

    # Torsion potential
    compute_force_torsion:
      potentials_for_torsions:
        - type_1
        - type_2

    # Improper torsion potential
    compute_force_improper:
      potentials_for_impropers:
        - type_1
        - type_2
    ```
where `type_1`and `type_2` can be any specific type of bonding potentials as defined in the following items, also accessible in the left panel:

- [**Bond**] (Bond/index.md)
- [**Bend**] (Bend/index.md)
- [**Torsion**] (Torsion/index.md)
- [**Improper**] (Improper/index.md)


# **No potential**

## **Description**

The `no_potential` type corresponds to a potential with zero force and energy

$$
E = 0
$$

## **YAML syntax**

```yaml
molecule_force_field:
  potentials_for_bonds:
    - types: [STRING, STRING]
      potential: no_potential
```

- [x] STRING = Name of the atom type (specie) involved in the bond.

## **Usage examples**

!!! example "**Systems with a single atom type (specie)**"
    ```yaml
    molecule_force_field:
      potentials_for_bonds:
        - types: [CA, CA]
          potential: no_potential
    ```

!!! example "**Systems with several atom types (species)**"

    ```yaml
    molecule_force_field:
      potentials_for_bonds:
        - types: [CA, CA]
          potential: no_potential
        - types: [CA, CH3]
          potential: no_potential
    ```



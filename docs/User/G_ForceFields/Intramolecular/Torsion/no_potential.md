# **No potential**

## **Description**

The `no_potential` type corresponds to a potential with zero force and energy

$$
E = 0
$$

## **YAML syntax**

```yaml
compute_force_torsion:
  potentials_for_torsions:
    - types: [STRING, STRING, STRING, STRING]
      potential: no_potential
```

- [x] STRING = Name of the atom type (specie) involved in the bond.

## **Usage examples**

!!! example "**Systems with a single atom type (specie)**"
    ```yaml
    compute_force_torsion:
      potentials_for_torsions:
        - types: [CA, CA, CA, CA]
          potential: no_potential
    ```

!!! example "**Systems with several atom types (species)**"

    ```yaml
    compute_force_torsion:
      potentials_for_torsions:
        - types: [CA, CA, CA, CA]
          potential: no_potential
        - types: [CA, CA, CT, CT]
          potential: no_potential
    ```



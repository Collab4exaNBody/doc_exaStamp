# **No potential**

## **Description**

The `no_potential` type corresponds to a potential with zero force and energy

$$
E = 0
$$

## **YAML syntax**

```yaml
molecule_force_field:
  potentials_for_impropers:
    - types: [STRING, STRING, STRING, STRING]
      potential: no_potential
```

- [x] STRING = Name of the atom type (specie) involved in the improper torsion angle.

## **Usage examples**

!!! example "**Systems with several atom types (species)**"

    ```yaml
    molecule_force_field:
      potentials_for_impropers:
        - types: [CA, CA, CA, CT]
          potential: no_potential
        - types: [CA, CA, CA, H]
          potential: no_potential
    ```



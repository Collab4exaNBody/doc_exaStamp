# **Cos_two**

## **Description**

The `cos_two` type of torsion potential calculates the torsion potential given by

$$
E = \frac{k}{2}  \left ( 1 - \cos{2(\phi -\phi_0)} \right )
$$

with $k$ and $\phi_0$ the potential parameters decribed in the following table.
  
<div class="center-table" markdown>

| Parameter     | Units           | Description               |
| :------------ | :-------------: | :------------------------ |
| $k$           | energy          | force constant            |
| $\phi_0$      | angle           | equilibrium torsion angle |

</div>

## **YAML syntax**

```yaml
compute_force_torsion:
  potentials_for_torsions:
    - types: [STRING, STRING, STRING, STRING]
      potential: cos_two
      parameters:
        phi0: VALUE UNITS
        k: VALUE UNITS
```

- [x] STRING = Name of the atom type (specie) involved in the bending angle.
- [x] VALUE  = Physical value of the intended parameter.
- [x] UNITS  = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atom type (specie)**"
    ```yaml
    compute_force_torsion:
      potentials_for_torsions:
        - types: [C, C, C, C]
          potential: cos_two
          parameters:
            phi0: 180.0e+02 degree
            k: 8.0e-19 J
    ```

!!! example "**Systems with several atom types (species)**"

    ```yaml
    compute_force_bond:
      potentials_for_bonds:
        - types: [C, C, C, C]
          potential: cos_two
          parameters:
            phi0: 180.0e+02 degree
            k: 8.0e-19 J
        - types: [C, C, C, H]
          potential: cos_two
          parameters:
            phi0: 60.0e+02 degree
            k: 8.0e-19 J
    ```



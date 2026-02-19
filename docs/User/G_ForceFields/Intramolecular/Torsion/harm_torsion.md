# **Harmonic torsion**

## **Description**

The `harm_torsion` type of torsion potential calculates the standard harmonic torsion potential given by

$$
E = \frac{1}{2} k \left ( \phi -\phi_0 \right )^2
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
      potential: harm_torsion
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
          potential: harm_torsion
          parameters:
            phi0: 180.0e+02 degree
            k: 8.0e-19 J
    ```

!!! example "**Systems with several atom types (species)**"

    ```yaml
    compute_force_torsion:
      potentials_for_torsions:
        - types: [C, C, C, C]
          potential: harm_torsion
          parameters:
            phi0: 180.0e+02 degree
            k: 8.0e-19 J
        - types: [C, C, C, H]
          potential: harm_torsion
          parameters:
            phi0: 60.0e+02 degree
            k: 8.0e-19 J
    ```



# **Harmonic bond**

## **Description**

The `harm_bond` type of bond potential calculates the standard harmonic bond potential given by

$$
E = \frac{1}{2} k \left ( r -r_0 \right )^2
$$

with $k$ and $r_0$ the potential parameters decribed in the following table.
  
<div class="center-table" markdown>

| Parameter     | Units           | Description             |
| :------------ | :-------------: | :---------------------- |
| $k$           | mass/time$^2$   | spring constant         |
| $r_0$         | distance        | equilibrium bond length |

</div>

## **YAML syntax**

```yaml
compute_force_bond:
  potentials_for_bonds:
    - types: [STRING, STRING]
      potential: harm_bond
      parameters:
        r0: VALUE UNITS
        k: VALUE UNITS
```

- [x] STRING = Name of the atom type (specie) involved in the bond.
- [x] VALUE  = Physical value of the intended parameter.
- [x] UNITS  = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atom type (specie)**"
    ```yaml
    compute_force_bond:
      potentials_for_bonds:
        - types: [CA, CA]
          potential: harm_bond
          parameters:
            r0: 1.400000e-10 m
            k: 6.521298e+02 J/m^2
    ```

!!! example "**Systems with several atom types (species)**"

    ```yaml
    compute_force_bond:
      potentials_for_bonds:
        - types: [CA, CA]
          potential: harm_bond
          parameters:
            r0: 1.400000e-10 m
            k: 6.521298e+02 J/m^2
        - types: [CA, CH3]
          potential: harm_bond
          parameters:
            r0: 1.510000e-10 m
            k: 4.407786e+02 J/m^2
    ```



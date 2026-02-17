# **Quartic bond**

## **Description**

The `quar_bond` type of bond potential calculates a quartic bond potential given by

$$
E = k_2 \left ( r -r_0 \right )^2 + k_3 \left ( r -r_0 \right )^3 + k_4 \left ( r -r_0 \right )^4
$$

with $k_2$, $k_3$, $k_4$ and $r_0$ the potential parameters decribed in the following table.
  
<div class="center-table" markdown>

| Parameter     | Units               | Description             |
| :------------ | :-----------------: | :---------------------- |
| $k_2$         | energy/distance$^2$ | force constant          |
| $k_3$         | energy/distance$^3$ | force constant          |
| $k_4$         | energy/distance$^4$ | force constant          |
| $r_0$         | distance            | equilibrium bond length |

</div>

## **YAML syntax**

```yaml
compute_force_bond:
  potentials_for_bonds:
    - types: [STRING, STRING]
      potential: quar_bond
      parameters:
        r0: VALUE UNITS
        k2: VALUE UNITS
        k3: VALUE UNITS
        k4: VALUE UNITS
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
          potential: quar_bond
          parameters:
            r0: 1.400000e-10 m
            k2: 326.0649 J/m^2
            k3: 0.0 J/m^3
            k4: 0.0 J/m^4
    ```

!!! example "**Systems with several atom types (species)**"

    ```yaml
    compute_force_bond:
      potentials_for_bonds:
        - types: [CA, CA]
          potential: quar_bond
          parameters:
            r0: 1.400000e-10 m
            k2: 326.0649 J/m^2
            k3: 0.0 J/m^3
            k4: 0.0 J/m^4
        - types: [CA, CH3]
          potential: quar_bond
          parameters:
            r0: 1.510000e-10 m
            k2: 220.3893 J/m^2
            k3: 0.0 J/m^3
            k4: 0.0 J/m^4
    ```



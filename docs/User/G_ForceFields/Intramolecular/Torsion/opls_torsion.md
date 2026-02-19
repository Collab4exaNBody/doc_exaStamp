# **OPLS torsion**

## **Description**

The `opls_torsion` type of torsion potential calculates the torsion potential of the OPLS force field:

$$
E = \frac{1}{2}k_1 \left ( 1 + \cos{\phi}\right ) +  \frac{1}{2}k_2 \left ( 1 - \cos{2\phi}\right ) + \frac{1}{2}k_3 \left ( 1 + \cos{3\phi}\right )
$$

with $k_1$, $k_2$ and $k_3$ the potential parameters decribed in the following table.
  
<div class="center-table" markdown>

| Parameter | Units  | Description    |
| :-------- | :----- | :------------- |
| $k_1$     | energy | force constant |
| $k_2$     | energy | force constant |
| $k_3$     | energy | force constant |

</div>

## **YAML syntax**

```yaml
compute_force_torsion:
  potentials_for_torsions:
    - types: [STRING, STRING, STRING, STRING]
      potential: opls_torsion
      parameters:
        k1: VALUE UNITS
        k2: VALUE UNITS
        k3: VALUE UNITS
```

- [x] STRING = Name of the atom type (specie) involved in the bending angle.
- [x] VALUE  = Physical value of the intended parameter.
- [x] UNITS  = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atom type (specie)**"
    ```yaml
    compute_force_torsion:
      potentials_for_torsions:
        - types: [CA, CA, CA, CA]
          potential: opls_torsion
          parameters:
            k1: 0.000000e-00 J
            k2: 5.040449e-20 J
            k3: 0.000000e-00 J
    ```

!!! example "**Systems with several atom types (species)**"

    ```yaml
    compute_force_bond:
      potentials_for_bonds:
        - types: [CA, CA, CA, CA]
          potential: opls_torsion
          parameters:
            k1: 0.000000e-00 J
            k2: 5.040449e-20 J
            k3: 0.000000e-00 J
        - types: [CA, CA, CT, CT]
          potential: opls_torsion
          parameters:
            k1: 0.000000e-00 J
            k2: 0.000000e-00 J
            k3: 0.000000e-00 J
    ```



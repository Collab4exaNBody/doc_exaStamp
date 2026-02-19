# **OPLS improper**

## **Description**

The `opls_improper` type of improper torsion potential calculates the improper torsion potential of the OPLS force field:

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
compute_force_improper:
  potentials_for_impropers:
    - types: [STRING, STRING, STRING, STRING]
      potential: opls_improper
      parameters:
        k1: VALUE UNITS
        k2: VALUE UNITS
        k3: VALUE UNITS
```

- [x] STRING = Name of the atom type (specie) involved in the bending angle.
- [x] VALUE  = Physical value of the intended parameter.
- [x] UNITS  = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with several atom types (species)**"

    ```yaml
    compute_force_bond:
      potentials_for_bonds:
        - types: [CA, CA, CA, CT]
          potential: opls_improper
          parameters:
            k1: 0.000000e-00 J
            k2: 3.476172e-20 J
            k3: 0.000000e-00 J
        - types: [CA, CA, CA, H]
          potential: opls_improper
          parameters:
            k1: 0.000000e-00 J
            k2: 3.476172e-20 J
            k3: 0.000000e-00 J
    ```



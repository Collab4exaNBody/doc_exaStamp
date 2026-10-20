# **OPLS torsion**

## **Description**

The `opls_torsion` type of torsion potential calculates the torsion potential of the OPLS force field:

$$
E = \frac{1}{2}k_1 \left ( 1 + \cos{\phi}\right ) +  \frac{1}{2}k_2 \left ( 1 - \cos{2\phi}\right ) + \frac{1}{2}k_3 \left ( 1 + \cos{3\phi}\right ) + e_0
$$

with $k_1$, $k_2$, $k_3$ and $e_0$ the potential parameters described in the following table.
  
<div class="center-table" markdown>

| Parameter | Units  | Description    |
| :-------- | :----- | :------------- |
| $k_1$     | energy | force constant |
| $k_2$     | energy | force constant |
| $k_3$     | energy | force constant |
| $e_0$     | energy | constant energy offset, optional (default 0) |

</div>

## **YAML syntax**

```yaml
molecule_force_field:
  potentials_for_torsions:
    - types: [STRING, STRING, STRING, STRING]
      potential: opls_torsion
      parameters:
        k1: VALUE UNITS
        k2: VALUE UNITS
        k3: VALUE UNITS
        e0: VALUE UNITS   # optional
```

`e0` only shifts the energy. It is useful, e.g., to write a GAFF torsion, a sum of $\frac{k}{m}(1+\cos(n\phi-\phi_0))$ terms
with $n \le 3$, in this form with the same energy.

- [x] STRING = Name of the atom type (specie) involved in the torsion angle.
- [x] VALUE  = Physical value of the intended parameter.
- [x] UNITS  = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atom type (specie)**"
    ```yaml
    molecule_force_field:
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
    molecule_force_field:
      potentials_for_torsions:
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



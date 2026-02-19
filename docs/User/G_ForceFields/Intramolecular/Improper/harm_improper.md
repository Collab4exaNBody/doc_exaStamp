# **Harmonic improper**

## **Description**

The `harm_improper` type of improper torsion potential calculates the standard harmonic improper torsion potential given by

$$
E = \frac{1}{2} k \left ( \chi -\chi_0 \right )^2
$$

with $k$ and $\phi_0$ the potential parameters decribed in the following table.
  
<div class="center-table" markdown>

| Parameter     | Units           | Description                |
| :------------ | :-------------: | :------------------------- |
| $k$           | energy          | force constant             |
| $\phi_0$      | angle           | equilibrium improper angle |

</div>

## **YAML syntax**

```yaml
compute_force_improper:
  potentials_for_impropers:
    - types: [STRING, STRING, STRING, STRING]
      potential: harm_improper
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
    compute_force_improper:
      potentials_for_impropers:
        - types: [CA, CA, CA, CT]
          potential: harm_improper
          parameters:
            phi0: 0.0 degree
            k: 8.0e-19 J
    ```

!!! example "**Systems with several atom types (species)**"

    ```yaml
    compute_force_improper:
      potentials_for_impropers:
        - types: [CA, CA, CA, CT]
          potential: harm_improper
          parameters:
            phi0: 0.0 degree
            k: 8.0e-19 J
        - types: [CA, CA, CA, H]
          potential: harm_improper
          parameters:
            phi0: 0.0 degree
            k: 8.0e-19 J
    ```



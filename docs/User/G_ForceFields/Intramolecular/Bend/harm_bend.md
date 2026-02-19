# **Harmonic bending**

## **Description**

The `harm_bend` type of bending potential calculates the standard harmonic bending potential given by

$$
E = \frac{1}{2} k \left ( \theta -\theta_0 \right )^2
$$

with $k$ and $\theta_0$ the potential parameters decribed in the following table.
  
<div class="center-table" markdown>

| Parameter     | Units           | Description               |
| :------------ | :-------------: | :------------------------ |
| $k$           | energy          | force constant            |
| $\theta_0$    | angle           | equilibrium bending angle |

</div>

## **YAML syntax**

```yaml
compute_force_bend:
  potentials_for_bends:
    - types: [STRING, STRING, STRING]
      potential: harm_bend
      parameters:
        theta0: VALUE UNITS
        k: VALUE UNITS
```

- [x] STRING = Name of the atom type (specie) involved in the bending angle.
- [x] VALUE  = Physical value of the intended parameter.
- [x] UNITS  = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atom type (specie)**"
    ```yaml
    compute_force_bend:
      potentials_for_bends:
        - types: [CA, CA, CA]
          potential: harm_bend
          parameters:
            theta0: 1.200000e+02 degree
            k: 8.759953e-19 J
    ```

!!! example "**Systems with several atom types (species)**"

    ```yaml
    compute_force_bond:
      potentials_for_bonds:
        - types: [CA, CA, CA]
          potential: harm_bond
          parameters:
            r0: 1.400000e-10 m
            k: 6.521298e+02 J/m^2
        - types: [CA, CA, CR4]
          potential: harm_bond
          parameters:
            theta0: 1.200000e+02 degree
            k: 9.733281e-19 J
    ```



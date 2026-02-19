# **Quartic bend**

## **Description**

The `quar_bond` type of bending potential calculates a quartic bending potential given by:

$$
E = k_2 \left ( \theta -\theta_0 \right )^2 + k_3 \left ( \theta -\theta_0 \right )^3 + k_4 \left ( \theta -\theta_0 \right )^4
$$

with $k_2$, $k_3$, $k_4$ and $\theta_0$ the potential parameters decribed in the following table.
  
<div class="center-table" markdown>

| Parameter     | Units  | Description               |
| :------------ | :----- | :------------------------ |
| $k_2$         | energy | force constant            |
| $k_3$         | energy | force constant            |
| $k_4$         | energy | force constant            |
| $\theta_0$    | angle  | equilibrium bending angle |

</div>

## **YAML syntax**

```yaml
compute_force_bend:
  potentials_for_bends:
    - types: [STRING, STRING, STRING]
      potential: quar_bend
      parameters:
        theta0: VALUE UNITS
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
    compute_force_bend:
      potentials_for_bends:
        - types: [CA, CA, CA]
          potential: quar_bend
          parameters:
            theta0: 1.200000e+02 degree
            k2: 8.759953e-19 J
            k3: 0.0 J
            k4: 0.0 J
    ```

!!! example "**Systems with several atom types (species)**"

    ```yaml
    compute_force_bend:
      potentials_for_bends:
        - types: [CA, CA, CA]
          potential: quar_bend
          parameters:
            theta0: 1.200000e+02 degree
            k2: 8.759953e-19 J
            k3: 0.0 J
            k4: 0.0 J
        - types: [CA, CA, CR4]
          potential: quar_bend
          parameters:
            theta0: 1.200000e+02 degree
            k: 9.733281e-19 J
            k3: 0.0 J
            k4: 0.0 J
    ```



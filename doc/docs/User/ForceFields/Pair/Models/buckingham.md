# **Buckingham**

## **Description**

The `buckingham_compute_force` operator calculates the Buckingham (exp-6) pair potential given by

$$
E(r) = A \, e^{-r/\rho} - \frac{C}{r^{6}} \quad \text{for} \quad r<r_c
$$
  
with $r_c$ the cutoff and $(A,\rho,C)$ the potential parameters described in the following table.

<div class="center-table" markdown>

| Parameter | Units                | Description                                      |
| :-------- | :------------------: | :----------------------------------------------- |
| $A$       | energy               | Short-range repulsive amplitude                  |
| $\rho$    | distance             | Repulsive decay length                           |
| $C$       | energy·distance$^6$  | Dispersion (attractive) coefficient              |
| $r_c$     | distance             | Cutoff radius                                    |

</div>

## **YAML syntax**

```yaml
buckingham_compute_force:
  rcut: VALUE UNITS
  parameters: { A: VALUE UNITS , rho: VALUE UNITS , C: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    buckingham_compute_force:
      parameters: { A: 1000.0 eV , rho: 0.30 ang , C: 1200.0 eV*ang^6 }
      rcut: 8.0 ang

    # Symetric variant
    buckingham_compute_force_symetric:
      parameters: { A: 1000.0 eV , rho: 0.30 ang , C: 1200.0 eV*ang^6 }
      rcut: 8.0 ang  
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    buckingham_multi_force:
      rcut: 8.0 ang
      common_parameters: { A: 0.0 , rho: 0.0 , C: 0.0 }
      parameters:
        - { type_a: O , type_b: O , rcut: 8.0 ang , parameters: { A: 9547.96 eV , rho: 0.21916 ang , C: 32.0 eV*ang^6 } }
        - { type_a: Si , type_b: O , rcut: 8.0 ang , parameters: { A: 18003.7572 eV , rho: 0.2052 ang , C: 133.5381 eV*ang^6 } }
    ```

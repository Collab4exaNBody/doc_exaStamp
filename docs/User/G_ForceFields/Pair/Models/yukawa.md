# **Yukawa**

## **Description**

The `yukawa_compute_force` operator computes the screened Coulomb (Yukawa) pair potential:

$$
E(r) = \frac{A}{r}\, e^{-\kappa r} \quad \text{for} \quad r<r_c
$$

<div class="center-table" markdown>

| Parameter | Units           | Description                         |
| :-------- | :-------------: | :---------------------------------- |
| `A`       | energy·distance | Prefactor $A$                       |
| `kappa`   | 1/distance      | Screening length inverse $\kappa$   |
| `rcut`    | distance        | Cutoff radius of the pair potential |

</div>

## **YAML syntax**

```yaml
yukawa_compute_force:
  rcut: VALUE UNITS
  parameters: { A: VALUE UNITS , kappa: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    yukawa_compute_force:
      parameters: { A: 2.43 eV*ang , kappa: 4.1 1/ang }
      rcut: 8.0 ang

    # Symetric variant
    yukawa_compute_force_symetric:
      parameters: { A: 2.43 eV*ang , kappa: 4.1 1/ang }
      rcut: 8.0 ang
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    yukawa_multi_force:
      rcut: 8.0 ang
      common_parameters: { A: 0.0 eV*ang , kappa: 1.0 1/ang }
      parameters:
        - { type_a: A , type_b: A , rcut: 8.0 ang , parameters: { A: 2.43 eV*ang , kappa: 4.1 1/ang } }
        - { type_a: A , type_b: B , rcut: 6.0 ang , parameters: { A: 1.20 eV*ang , kappa: 3.5 1/ang } }
    ```

!!! note

    The rigid molecule variant (`yukawa_rigidmol_force`) is not available for this potential.

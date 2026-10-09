# **Exponential-6**

## **Description**

The `exp6_compute_force` operator calculates the Buckingham exponential-6 pair potential with an additional short-range repulsive wall:

$$
E(r) = A\,e^{-Br} - \frac{C}{r^{6}} + D\left(\frac{12}{B\,r}\right)^{12} \quad \text{for} \quad r<r_c
$$

The last term is a steep $r^{-12}$ wall that prevents the collapse of the $-C/r^6$ term at very short distances (the "Buckingham catastrophe"). Set $D=0$ to recover the plain exponential-6 form.

<div class="center-table" markdown>

| Parameter | Units                 | Description                              |
| :-------- | :-------------------: | :--------------------------------------- |
| `A`       | energy                | Amplitude of the exponential repulsion   |
| `B`       | 1/distance            | Inverse range of the exponential         |
| `C`       | energy·distance$^6$   | Dispersion coefficient                   |
| `D`       | energy                | Amplitude of the short-range wall        |
| `rcut`    | distance              | Cutoff radius                            |

</div>

## **YAML syntax**

```yaml
exp6_compute_force:
  rcut: VALUE UNITS
  parameters: { A: VALUE UNITS , B: VALUE UNITS , C: VALUE UNITS , D: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    exp6_compute_force:
      parameters: { A: 107023.9 Da*kcal/g , B: 3.6405 1/ang , C: 554.01 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g }
      rcut: 12.5 ang

    # Symetric variant
    exp6_compute_force_symetric:
      parameters: { A: 107023.9 Da*kcal/g , B: 3.6405 1/ang , C: 554.01 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g }
      rcut: 12.5 ang
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    exp6_multi_force:
      rcut: 12.5 ang
      common_parameters: { A: 107023.9 Da*kcal/g , B: 3.6405 1/ang , C: 554.01 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g }
      parameters:
        - { type_a: C , type_b: C , rcut: 12.5 ang , parameters: { A: 107023.9 Da*kcal/g , B: 3.6405 1/ang ,     C: 554.01 Da*kcal*ang^6/g ,      D: 5.0e-5 Da*kcal/g } }
        - { type_a: C , type_b: N , rcut: 12.5 ang , parameters: { A: 37111.29 Da*kcal/g , B: 3.46350030 1/ang , C: 484.2991571 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g } }
    ```

!!! note

    `Da*kcal/g` is kcal/mol expressed per particle (1 Da = 1 g/mol).

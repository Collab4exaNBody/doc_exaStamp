# **Exponential-6 + Reaction Field**

## **Description**

The `exp6rf_compute_force` operator adds an [exponential-6](exp6.md) term and a [reaction-field](coul_rf.md) electrostatic term:

$$
E(r) = E_{\mathrm{exp6}}(r) + E_{\mathrm{RF}}(r)
$$

with

$$
E_{\mathrm{exp6}}(r) =
\begin{cases}
A\,e^{-Br} - \dfrac{C}{r^{6}} + D\left(\dfrac{12}{B\,r}\right)^{12} - E_{\mathrm{shift}} & r \le r_{\mathrm{exp6}} \\
0 & r > r_{\mathrm{exp6}}
\end{cases}
\qquad
E_{\mathrm{RF}}(r) =
\begin{cases}
\dfrac{q_i q_j}{4\pi\varepsilon_0}\left[\dfrac{1}{r} + k_{\mathrm{rf}} r^2 - C_{\mathrm{rf}}\right] & r \le r_{\mathrm{rf}} \\
0 & r > r_{\mathrm{rf}}
\end{cases}
$$

$E_{\mathrm{shift}}$ is the exponential-6 energy at $r_{\mathrm{exp6}}$, so that this term is zero at its cutoff. $k_{\mathrm{rf}}$ and $C_{\mathrm{rf}}$ are defined on the [reaction field page](coul_rf.md). The charges $q_i$, $q_j$ are the species charges.

<div class="center-table" markdown>

| Parameter        | Units                 | Description                                                  |
| :--------------- | :-------------------: | :----------------------------------------------------------- |
| `exp6_rcut`      | distance              | Cutoff $r_{\mathrm{exp6}}$ of the exponential-6 term (0 or missing disables it) |
| `exp6.A`         | energy                | Amplitude of the exponential repulsion                       |
| `exp6.B`         | 1/distance            | Inverse range of the exponential                             |
| `exp6.C`         | energy·distance$^6$   | Dispersion coefficient                                       |
| `exp6.D`         | energy                | Amplitude of the short-range wall                            |
| `rf.epsilon`     | —                     | Dielectric constant of the surrounding continuum             |
| `rf.rc`          | distance              | Cutoff $r_{\mathrm{rf}}$ of the reaction field               |
| `rcut`           | distance              | Cutoff radius of the pair potential, at least $\max(r_{\mathrm{exp6}}, r_{\mathrm{rf}})$ |

</div>

## **YAML syntax**

```yaml
exp6rf_compute_force:
  rcut: VALUE UNITS
  parameters:
    exp6_rcut: VALUE UNITS
    exp6: { A: VALUE UNITS , B: VALUE UNITS , C: VALUE UNITS , D: VALUE UNITS }
    rf: { epsilon: VALUE , rc: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    exp6rf_compute_force:
      rcut: 12.5 ang
      parameters:
        exp6_rcut: 11.0 ang
        exp6: { A: 107023.9 Da*kcal/g , B: 3.6405 1/ang , C: 554.01 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g }
        rf: { epsilon: 100. , rc: 12.5 ang }

    # Symetric variant
    exp6rf_compute_force_symetric:
      rcut: 12.5 ang
      parameters:
        exp6_rcut: 11.0 ang
        exp6: { A: 107023.9 Da*kcal/g , B: 3.6405 1/ang , C: 554.01 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g }
        rf: { epsilon: 100. , rc: 12.5 ang }
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    exp6rf_multi_force:
      rcut: 12.5 ang
      common_parameters: { rf: { epsilon: 100. , rc: 12.5 ang } , exp6_rcut: 12.5 ang , exp6: { A: 37111.29 Da*kcal/g , B: 3.4635 1/ang , C: 484.30 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g } }
      parameters:
        - { type_a: C , type_b: C , rcut: 12.5 ang , parameters: { rf: { epsilon: 100. , rc: 12.5 ang } , exp6_rcut: 11.0 ang , exp6: { A: 107023.9 Da*kcal/g , B: 3.6405 1/ang , C: 554.01 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g } } }
        - { type_a: C , type_b: N , rcut: 12.5 ang , parameters: { rf: { epsilon: 100. , rc: 12.5 ang } , exp6_rcut: 12.5 ang , exp6: { A: 37111.29 Da*kcal/g , B: 3.4635 1/ang , C: 484.30 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g } } }
    ```

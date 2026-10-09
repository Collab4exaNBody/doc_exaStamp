# **LJExp6RF: Exp-6 + Reaction Field**

## **Description**

`ljexp6rf` is a combined potential designed for molecular systems: each pair of species uses **either** a [Lennard-Jones](lj.md) **or** an [exponential-6](exp6.md) short-range term, plus a [reaction-field](coul_rf.md) electrostatic term. This page describes the exponential-6 flavour; see [LJExp6RF: Lennard-Jones + Reaction Field](ljexp6rf_lj.md) for the other one.

With an exponential-6 short-range term, the pair energy reads

$$
E(r) = A\,e^{-Br} - \frac{C}{r^{6}} + D\left(\frac{12}{B\,r}\right)^{12} - E_{\mathrm{shift}}
+ \frac{q_i q_j}{4\pi\varepsilon_0}\left[\frac{1}{r} + k_{\mathrm{rf}} r^2 - C_{\mathrm{rf}}\right]
\quad \text{for} \quad r<r_{\mathrm{cut}}
$$

$E_{\mathrm{shift}}$ is the exponential-6 energy at the distance given by `parameters.rcut`, so that the short-range term is zero there. $k_{\mathrm{rf}}$ and $C_{\mathrm{rf}}$ are computed from `rf.epsilon` and `rf.rc` as described on the [reaction field page](coul_rf.md). Both terms are evaluated up to the operator cutoff `rcut`, so use the same value for `rcut`, `parameters.rcut` and `rf.rc`. The charges $q_i$, $q_j$ are the species charges.

<div class="center-table" markdown>

| Parameter        | Units                 | Description                                                 |
| :--------------- | :-------------------: | :---------------------------------------------------------- |
| `parameters.rcut`| distance              | Distance where the exponential-6 energy is shifted to zero (required) |
| `exp6.A`         | energy                | Amplitude of the exponential repulsion                      |
| `exp6.B`         | 1/distance            | Inverse range of the exponential                            |
| `exp6.C`         | energy·distance$^6$   | Dispersion coefficient                                      |
| `exp6.D`         | energy                | Amplitude of the short-range wall                           |
| `rf.epsilon`     | —                     | Dielectric constant of the surrounding continuum            |
| `rf.rc`          | distance              | Reaction field cutoff $r_c$ used in $k_{\mathrm{rf}}$ and $C_{\mathrm{rf}}$ |
| `rcut`           | distance              | Cutoff radius of the pair potential                         |

</div>

!!! warning

    Give `lj` **or** `exp6` for a given pair, not both: the simulation aborts if both are present. Unlike [`exp6rf`](exp6rf.md), `ljexp6rf` has no `exp6_rcut` key: the shift distance is `parameters.rcut`.

## **YAML syntax**

```yaml
ljexp6rf_compute_force:
  rcut: VALUE UNITS
  parameters:
    rcut: VALUE UNITS
    exp6: { A: VALUE UNITS , B: VALUE UNITS , C: VALUE UNITS , D: VALUE UNITS }
    rf: { epsilon: VALUE , rc: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    ljexp6rf_compute_force:
      rcut: 12.5 ang
      parameters: { rcut: 12.5 ang , rf: { epsilon: 100. , rc: 12.5 ang } , exp6: { A: 107023.9 Da*kcal/g , B: 3.6405 1/ang , C: 554.01 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g } }

    # Symetric variant
    ljexp6rf_compute_force_symetric:
      rcut: 12.5 ang
      parameters: { rcut: 12.5 ang , rf: { epsilon: 100. , rc: 12.5 ang } , exp6: { A: 107023.9 Da*kcal/g , B: 3.6405 1/ang , C: 554.01 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g } }
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    compute_force_pair_multimat:
      potentials:
        - { type_a: C , type_b: C , potential: ljexp6rf , rcut: 12.5 ang , parameters: { rcut: 12.5 ang , rf: { epsilon: 100. , rc: 12.5 ang } , exp6: { A: 107023.9 Da*kcal/g , B: 3.6405 1/ang ,     C: 554.01 Da*kcal*ang^6/g ,      D: 5.0e-5 Da*kcal/g } } }
        - { type_a: C , type_b: N , potential: ljexp6rf , rcut: 12.5 ang , parameters: { rcut: 12.5 ang , rf: { epsilon: 100. , rc: 12.5 ang } , exp6: { A: 37111.29 Da*kcal/g , B: 3.46350030 1/ang , C: 484.2991571 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g } } }
    ```

!!! note "Molecular systems"

    A rigid molecule variant, `ljexp6rf_rigidmol_force`, is available. For flexible molecules, the dedicated `ljexp6rf_pc` operator handles per-atom charges and intramolecular pair weights; it is set up by `data/config/config_molecule.msp` (see [Bonding potentials](../../Intramolecular/index.md)).

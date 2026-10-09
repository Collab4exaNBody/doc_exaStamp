# **LJExp6RF: Lennard-Jones + Reaction Field**

## **Description**

`ljexp6rf` is a combined potential designed for molecular systems: each pair of species uses **either** a [Lennard-Jones](lj.md) **or** an [exponential-6](exp6.md) short-range term, plus a [reaction-field](coul_rf.md) electrostatic term. This page describes the Lennard-Jones flavour; see [LJExp6RF: Exp-6 + Reaction Field](ljexp6rf_exp6.md) for the other one.

With a Lennard-Jones short-range term, the pair energy reads

$$
E(r) = 4\varepsilon\left[\left(\frac{\sigma}{r}\right)^{12} - \left(\frac{\sigma}{r}\right)^{6}\right] - E_{\mathrm{shift}}
+ \frac{q_i q_j}{4\pi\varepsilon_0}\left[\frac{1}{r} + k_{\mathrm{rf}} r^2 - C_{\mathrm{rf}}\right]
\quad \text{for} \quad r<r_{\mathrm{cut}}
$$

$E_{\mathrm{shift}}$ is the Lennard-Jones energy at the distance given by `parameters.rcut`, so that the short-range term is zero there. $k_{\mathrm{rf}}$ and $C_{\mathrm{rf}}$ are computed from `rf.epsilon` and `rf.rc` as described on the [reaction field page](coul_rf.md). Both terms are evaluated up to the operator cutoff `rcut`, so use the same value for `rcut`, `parameters.rcut` and `rf.rc`. The charges $q_i$, $q_j$ are the species charges.

<div class="center-table" markdown>

| Parameter        | Units    | Description                                                 |
| :--------------- | :------: | :---------------------------------------------------------- |
| `parameters.rcut`| distance | Distance where the Lennard-Jones energy is shifted to zero (required) |
| `lj.epsilon`     | energy   | Lennard-Jones well depth $\varepsilon$                      |
| `lj.sigma`       | distance | Lennard-Jones distance $\sigma$                             |
| `rf.epsilon`     | —        | Dielectric constant of the surrounding continuum            |
| `rf.rc`          | distance | Reaction field cutoff $r_c$ used in $k_{\mathrm{rf}}$ and $C_{\mathrm{rf}}$ |
| `rcut`           | distance | Cutoff radius of the pair potential                         |

</div>

!!! warning

    Give `lj` **or** `exp6` for a given pair, not both: the simulation aborts if both are present.

## **YAML syntax**

```yaml
ljexp6rf_compute_force:
  rcut: VALUE UNITS
  parameters:
    rcut: VALUE UNITS
    lj: { epsilon: VALUE UNITS , sigma: VALUE UNITS }
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
      parameters: { rcut: 12.5 ang , rf: { epsilon: 100. , rc: 12.5 ang } , lj: { epsilon: 0.01 kcal/mol , sigma: 3.830864488 ang } }

    # Symetric variant
    ljexp6rf_compute_force_symetric:
      rcut: 12.5 ang
      parameters: { rcut: 12.5 ang , rf: { epsilon: 100. , rc: 12.5 ang } , lj: { epsilon: 0.01 kcal/mol , sigma: 3.830864488 ang } }
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    ljexp6rf_multi_force:
      rcut: 12.5 ang
      common_parameters: { rcut: 12.5 ang , rf: { epsilon: 100. , rc: 12.5 ang } , lj: { epsilon: 0.01 kcal/mol , sigma: 3.83 ang } }
      parameters:
        - { type_a: C , type_b: C , rcut: 12.5 ang , parameters: { rcut: 12.5 ang , rf: { epsilon: 100. , rc: 12.5 ang } , lj: { epsilon: 0.01 kcal/mol , sigma: 3.83 ang } } }
        - { type_a: C , type_b: N , rcut: 12.5 ang , parameters: { rcut: 12.5 ang , rf: { epsilon: 100. , rc: 12.5 ang } , lj: { epsilon: 0.02 kcal/mol , sigma: 3.60 ang } } }
    ```

!!! note "Molecular systems"

    A rigid molecule variant, `ljexp6rf_rigidmol_force`, is available. For flexible molecules, the dedicated `ljexp6rf_pc` operator handles per-atom charges and intramolecular pair weights; it is set up by `data/config/config_molecule.msp` (see [Bonding potentials](../../Intramolecular/index.md)).

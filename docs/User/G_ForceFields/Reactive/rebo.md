# **REBO - Reactive Empirical Bond Order Potential**

## **Description**

REBO is the second-generation reactive bond-order potential of Brenner et al. for hydrocarbons. The energy is a sum over bonds of a repulsive and an attractive term, the latter being modulated by a bond order that depends on the environment of the bond:

$$
E = \frac{1}{2}\sum_i \sum_{j \neq i} \left[ V_R(r_{ij}) - \bar b_{ij}\, V_A(r_{ij}) \right]
$$

The bond order $\bar b_{ij}$ accounts for the coordination of atoms $i$ and $j$ (numbers of carbon and hydrogen neighbors $N^C$, $N^H$), the bond angles, the conjugation of the bond ($N^{conj}$) and the torsions around it. All the parameters and spline tables are read from a potential file (`CH.rebo`).

The REBO computation is split into several operators that must be called in this order inside `compute_force`, with ghost updates of the intermediate per-atom quantities between them:

<div class="center-table" markdown>

| Operator | Computes |
| :------- | :------- |
| `rebo_init` | Reads the potential file and sets the cutoffs. Place it in `init_parameters`. |
| `rebo_bond_order` | Coordination numbers $N^C_i$, $N^H_i$ (fields `NijC`, `NijH`) |
| `rebo_conjugation` | Conjugation numbers (field `Nconj`) |
| `rebo_pairwise` | Repulsive pair term $V_R$ |
| `rebo_manybody` | Attractive term $\bar b_{ij} V_A$ (bond order, angles, torsions) |

</div>

Alternative implementations are available:

- `rebo_pairwise_nobuffer`: same result as `rebo_pairwise`, without the intermediate neighbor buffer.
- `rebo_manybody_mixedprec`: same as `rebo_manybody`, but evaluates the angular spline in single precision. It is faster (especially on GPUs with low double-precision throughput) and agrees with `rebo_manybody` to about $10^{-6}$ in relative terms.

!!! warning "Species"

    REBO is defined for carbon and hydrogen only. Declare exactly these two species, **carbon first**: species index 0 is treated as C and index 1 as H.

```{ .yaml title="Syntax" .syntax-block }
rebo_init:
  parameters: { potential_file: <string> }
```

```{ .yaml title="Parameters" .params-block }
parameters.potential_file:  string, required   # REBO parameter file, searched in the data paths.
```

`rebo_init` raises `rcut_max` to three times the largest REBO cutoff (the many-body term needs the neighbors of the neighbors) and produces the `bondorder_cutoff` and `rebo_cutoff` values used by the other operators. The force operators share the `parameters` read by `rebo_init` and have no parameter to set.

The REBO operators also write forces on ghost atoms, so the ghost forces must be zeroed before the computation and sent back to their owner processes afterwards (`zero_force_energy: { ghost: true }` in `compute_force_prolog`, `update_force_from_ghost` in `compute_force_epilog`).

## **Usage example**

!!! example "**Hydrocarbon system**"
    ```yaml
    species:
      - C: { z: 6 , mass: 12.0107 Da , charge: 0.0 e- }
      - H: { z: 1 , mass: 1.00794 Da , charge: 0.0 e- }

    init_parameters:
      - species
      - rebo_init:
          parameters:
            potential_file: "CH.rebo"

    compute_force_prolog:
      - zero_force_energy: { ghost: true }

    compute_force:
      - rebo_bond_order
      - ghost_update_opt: { opt_fields: [ "NijC", "NijH" ] }
      - rebo_conjugation
      - ghost_update_opt: { opt_fields: [ "Nconj" ] }
      - rebo_pairwise
      - rebo_manybody            # or rebo_manybody_mixedprec

    compute_force_epilog:
      - update_force_from_ghost
      - force_to_accel
    ```

`CH.rebo` is shipped in `exaStamp/data/potentials/`. Complete inputs are in `exaStamp/data/regression_new/rebo/`.

# **Stillinger-Weber Potential**

## **Description**

The Stillinger-Weber (SW) potential is the sum of a two-body term and a three-body term. The three-body term penalizes deviations of the bond angles from a reference angle $\theta_0$ (the tetrahedral angle, $\cos\theta_0 = -1/3$, for diamond-like structures):

$$
E = \sum_i \sum_{j > i} \phi_2(r_{ij}) + \sum_i \sum_{j \neq i} \sum_{k > j} \phi_3(r_{ij}, r_{ik}, \theta_{ijk})
$$

$$
\phi_2(r_{ij}) = A_{ij}\,\epsilon_{ij} \left[ B_{ij} \left(\frac{\sigma_{ij}}{r_{ij}}\right)^{p_{ij}} - \left(\frac{\sigma_{ij}}{r_{ij}}\right)^{q_{ij}} \right] \exp\left(\frac{\sigma_{ij}}{r_{ij} - a_{ij}\sigma_{ij}}\right)
$$

$$
\phi_3(r_{ij}, r_{ik}, \theta_{ijk}) = \lambda_{ijk}\,\epsilon_{ijk} \left[\cos\theta_{ijk} - \cos\theta_{0,ijk}\right]^2 \exp\left(\frac{\gamma_{ij}\sigma_{ij}}{r_{ij} - a_{ij}\sigma_{ij}}\right) \exp\left(\frac{\gamma_{ik}\sigma_{ik}}{r_{ik} - a_{ik}\sigma_{ik}}\right)
$$

$\theta_{ijk}$ is the angle between bonds $ij$ and $ik$, centered on atom $i$. Each interaction vanishes smoothly at its cutoff $r_c = a\,\sigma$.

The potential uses two operators:

<div class="center-table" markdown>

| Operator | Role |
| :------- | :------- |
| `sw_init` | Reads the parameter file, matches its elements to the declared species and raises `rcut_max` to the SW cutoff. Place it in `init_parameters`, after `species`. |
| `sw_force` | Computes energies, forces and the per-atom virial. Place it in `compute_force`. |

</div>

```{ .yaml title="Syntax" .syntax-block }
sw_init:
  parameters: { file: <string>, threebody: <bool> }
```

```{ .yaml title="Parameters" .params-block }
parameters.file:       string, required       # SW parameter file, searched in the data paths.
parameters.threebody:  bool, default=true     # false drops the three-body term (pure pair potential).
```

`sw_force` has no parameter to set.

### **Parameter file**

The file has one entry per element triplet $(i,j,k)$, with 14 values separated by whitespace. An entry may span several lines, and `#` starts a comment:

```
element_i element_j element_k  epsilon  sigma  a  lambda  gamma  cos(theta0)  A  B  p  q  tol
```

- `epsilon` is in eV and `sigma` in Å. The other parameters are dimensionless.
- The two-body parameters of a pair $(i,j)$ ($\epsilon$, $\sigma$, $a$, $A$, $B$, $p$, $q$) and the radial three-body parameters ($\gamma$) are read from entry $(i,j,j)$.
- The angular parameters of the triplet centered on $i$ ($\lambda$, $\epsilon$, $\cos\theta_0$) are read from entry $(i,j,k)$.
- `tol` > 0 shortens the cutoff to the distance where the radial factor falls below `tol` (at most 0.01). `tol` = 0 keeps the exact cutoff $a\sigma$.

Every triplet of declared species must have exactly one entry, matched by species name. Entries for elements that are not declared are ignored, so a multi-element file can be used for a subset of its elements.

!!! note "Ghost atoms"

    `sw_force` adds the three-body forces of each triplet to the neighbors $j$ and $k$, which may be ghost atoms. Forces and energies must therefore be zeroed in the ghost layer before the computation and sent back to their owner processes afterwards: `zero_force_energy: { ghost: true }` in `compute_force_prolog`, and `update_force_energy_from_ghost` in `compute_force_epilog`. The `config_update_symmetric_forces.msp` include sets up both. Only one cutoff of ghost layer is needed.

!!! info "Per-atom energy"

    Each atom carries half of its pair energies and the whole energy of the triplets centered on it. The total energy, the forces and the virial do not depend on this choice.

!!! info "Implementation"

    `sw_force` runs one thread per atom and computes in double precision on both CPU and GPU. Force contributions to the neighbors use atomic additions. Neighbors within the SW cutoff are stored in a buffer of 64 entries per atom. If a denser system exceeds it, the run stops with an explicit message. Raise the limit with the CMake variable `XSTAMP_SW_MAX_NEIGHBORS`.

## **Usage examples**

!!! example "**Silicon**"
    ```yaml
    includes:
      - config_update_symmetric_forces.msp

    species:
      - Si: { mass: 28.0855 Da , z: 14 , charge: 0.0 e- }

    init_parameters:
      - species
      - sw_init:
          parameters: { file: "Si.sw" }

    compute_force:
      - sw_force
    ```

!!! example "**Gallium nitride (two species)**"
    ```yaml
    includes:
      - config_update_symmetric_forces.msp

    species:
      - Ga: { mass: 69.723 Da , z: 31 , charge: 0.0 e- }
      - N:  { mass: 14.007 Da , z: 7 , charge: 0.0 e- }

    init_parameters:
      - species
      - sw_init:
          parameters: { file: "GaN.sw" }

    compute_force:
      - sw_force
    ```

`Si.sw` and `GaN.sw` are shipped in `exaStamp/data/potentials/`. Complete inputs are in `exaStamp/data/regression_new/potentials/sw/` and in the `sw_si` / `sw_gan` cases of `exaStamp/data/regression_new/physics_regression/`.

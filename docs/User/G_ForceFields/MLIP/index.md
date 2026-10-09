---
icon: material/brain
---

# **Machine Learning Interatomic Potentials**

`exaStamp` ships several machine-learning interatomic potentials (MLIPs). Each one lives in its own plugin under `src/potential/mlip-<name>` and is **disabled by default**: turn it on at configure time with the matching CMake option (see [Build & Install](../../../BuildInstall/cmake_installation.md)).

<div class="center-table" markdown>

| Model | Page | Force operator | Init operator | CMake option | External dependency |
| :---- | :--- | :------------- | :------------ | :----------- | :------------------ |
| SNAP  | [SNAP](snap.md) | `snap_force`, `snap_force_fp64` | `snap_init` (descriptors only) | `EXASTAMP_MLIP_SNAP_BUILD` | exaNBody built with `EXANB_BUILD_CONTRIB_MD=ON` |
| POD   | [POD](pod.md) | `pod_force` | `pod_init` | `EXASTAMP_MLIP_POD_BUILD` | BLAS / LAPACK |
| MTP   | [MTP](mtp.md) | `mtp_force` | `mtp_init` | `EXASTAMP_MLIP_MTP_BUILD` | none |
| PACE  | [PACE](pace.md) | `pace_force` | `pace_init` | `EXASTAMP_MLIP_PACE_BUILD` | cloned at configure time |
| NNP   | [NNP (n2p2)](nnp.md) | `n2p2_force` | — | `EXASTAMP_MLIP_N2P2_BUILD` | n2p2 installation |
| k2b   | [k2b](../Pair/Models/k2b.md) | `k2b_compute_force`, `k2b_multi_force`, ... | `k2b_init` | always built | none |

</div>

## **Init / force pattern**

Most MLIPs split their setup from the force evaluation:

- `<model>_init` goes in the `init_parameters` block. It reads the potential files once, before `setup_system`, and raises `rcut_max` to the potential cutoff. This way the ghost layers and neighbor lists are sized correctly from the start, and you don't need to set `rcut_max` by hand under `global`.
- `<model>_force` goes in the `compute_force` block and evaluates energies, forces and the virial at every step.

```yaml title="Usage example"
init_parameters:
  - species
  - pod_init:
      parameters:
        pod_file: "Ta_param.pod"
        coeff_file: "Ta_coefficients.pod"

compute_force:
  - pod_force
```

!!! warning "Ghost contributions"

    MLIP force operators accumulate forces on ghost atoms. Forces and energies must be zeroed in the ghosts before the force computation and folded back into their owner atoms afterwards. Include the shipped configuration file:

    ```yaml
    includes:
      - config_update_symmetric_forces.msp
    ```

    or, equivalently, write the two blocks yourself:

    ```yaml
    compute_force_prolog:
      - zero_force_energy: { ghost: true }
    compute_force_epilog:
      - update_force_energy_from_ghost
      - force_to_accel
    ```

!!! note "Species mapping"

    How the species of the `species` block are matched to the elements of the potential files depends on the model. SNAP matches them **by position**: declare the species in the same order as the element blocks of the coefficient file. PACE matches them **by name**. Check the page of each model.

## **Descriptors and training**

SNAP, POD, MTP and k2b can also compute their **descriptors** without evaluating the potential: per-atom descriptors, their derivatives, and the global design matrix (energy, forces and virial rows) used to fit linear models. This includes a loop over a database of configurations. See [Descriptors](descriptors.md).

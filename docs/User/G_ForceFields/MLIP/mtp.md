---
icon: material/cube-scan
---

# **MTP - Moment Tensor Potential**

## **Description**

The Moment Tensor Potential writes the energy of atom $i$ as

$$
E_i = c_{\alpha_i} + \sum_{k} \xi_k \, B_k(\mathfrak{n}_i)
$$

where $c_{\alpha_i}$ is a per-species constant and the $B_k$ are scalar contractions of the *moment tensors* of the neighborhood $\mathfrak{n}_i$ of atom $i$. The linear coefficients $\xi_k$ are **shared by all species**; species dependence enters through the radial functions. The potential is read from a single `.almtp` file.

!!! note "Build"

    Configure exaStamp with `-DEXASTAMP_MLIP_MTP_BUILD=ON`. MTP has no external dependency.

## **Operators**

`mtp_init` reads the potential file once, in `init_parameters`, and raises `rcut_max` to the MTP cutoff. `mtp_force` computes energies, forces and the virial in `compute_force`.

```{ .yaml title="Syntax" .syntax-block }
init_parameters:
  - species
  - mtp_init:
      parameters:
        mtp_file: <string>

compute_force:
  - mtp_force
```

```{ .yaml title="Parameters" .params-block }
parameters.mtp_file:  string, required   # MTP potential file (.almtp).
```

`mtp_init` needs the `species` operator to have run before it, so list `species` first in `init_parameters`.

```yaml title="Usage example"
includes:
  - config_update_symmetric_forces.msp

species:
  - Cu: { mass: 63.546 Da , z: 29 , charge: 0.0 e- }

init_parameters:
  - species
  - mtp_init:
      parameters:
        mtp_file: "pot.almtp"

compute_force:
  - mtp_force
```

A complete example is in `exaStamp/data/regression_new/mliaps/mtp/exastamp_example/Cu_mtp.msp`.

## **Descriptors**

MTP descriptors, their derivatives and the global fitting matrix are computed by `compute_descriptor_mtp`, `compute_descriptor_mtp_global` and `write_descriptor_mtp_global`. See [Descriptors](descriptors.md).

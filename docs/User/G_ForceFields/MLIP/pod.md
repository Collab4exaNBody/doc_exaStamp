---
icon: material/vector-polyline
---

# **POD - Proper Orthogonal Descriptors**

## **Description**

The POD potential writes the energy of an atom as a linear combination of orthogonal descriptors. The descriptors are built from two-body and three-body (and optionally higher-order) radial and angular basis functions, compressed by a proper orthogonal decomposition. POD also supports *environment clustering*: atoms are assigned to clusters of local environments, each with its own set of coefficients.

A POD potential is defined by two files:

- a **parameter file** (`.pod`): species, cutoffs, basis sizes, body orders, number of environment clusters, ...
- a **coefficient file** (`.pod`): the fitted coefficients.

!!! note "Build"

    Configure exaStamp with `-DEXASTAMP_MLIP_POD_BUILD=ON`. POD requires BLAS and LAPACK. To force a given BLAS implementation, set `-DEXASTAMP_MLIP_POD_BLAS_VENDOR=<vendor>` (for instance `OpenBLAS` or `Intel10_64lp`). The value is passed to CMake's `FindBLAS` as `BLA_VENDOR`.

## **Operators**

`pod_init` reads both files once, in `init_parameters`, and raises `rcut_max` to the POD cutoff. `pod_force` computes energies, forces and the virial in `compute_force`.

```{ .yaml title="Syntax" .syntax-block }
init_parameters:
  - species
  - pod_init:
      parameters:
        pod_file: <string>
        coeff_file: <string>

compute_force:
  - pod_force
```

```{ .yaml title="Parameters" .params-block }
parameters.pod_file:    string, required   # POD parameter file.
parameters.coeff_file:  string, required   # POD coefficient file.
```

`pod_init` needs the `species` operator to have run before it, so list `species` first in `init_parameters`.

```yaml title="Usage example"
includes:
  - config_update_symmetric_forces.msp

species:
  - Ta: { mass: 180.95 Da, z: 73, charge: 0 e- }

init_parameters:
  - species
  - pod_init:
      parameters:
        pod_file: "Ta_param.pod"
        coeff_file: "Ta_coefficients.pod"

compute_force:
  - pod_force
```

Examples are in `exaStamp/data/regression_new/mliaps/pod/`: `Ta_pod.msp`, `Ta_pod_nClusters_2.msp` (two environment clusters) and `Ta_enhanced_pod.msp`.

## **Descriptors**

POD descriptors, their derivatives and the global fitting matrix are computed by `compute_descriptor_pod`, `compute_descriptor_pod_global` and `write_descriptor_pod_global`. See [Descriptors](descriptors.md).

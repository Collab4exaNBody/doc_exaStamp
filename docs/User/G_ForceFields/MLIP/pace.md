---
icon: material/atom
---

# **PACE - Atomic Cluster Expansion**

## **Description**

The Atomic Cluster Expansion (ACE) expands the energy of an atom on a complete set of body-ordered basis functions of its neighborhood. PACE is a performant implementation of ACE. The potential is read from a `.yace` / `.ace` coefficient file.

!!! note "Build"

    Configure exaStamp with `-DEXASTAMP_MLIP_PACE_BUILD=ON`. At configure time, the PACE compute library is cloned into `<build>/external/pace` from:

    - `EXASTAMP_MLIP_PACE_GIT_REPO` (default `git@github.com:Collab4exaNBody/exaStamp_mlip_pace.git`)
    - `EXASTAMP_MLIP_PACE_GIT_TAG` (default `main`)

    The configure step therefore needs access to that repository. If the directory already exists, it is not cloned again. PACE uses yaml-cpp: if it is not found automatically, pass `-DYAML_CPP_INSTALL_DIR=<path>`.

## **Operators**

`pace_init` reads the potential file once, in `init_parameters`, and raises `rcut_max` to the PACE cutoff. `pace_force` computes energies, forces and the virial in `compute_force`.

```{ .yaml title="Syntax" .syntax-block }
init_parameters:
  - species
  - pace_init:
      parameters:
        coef: <string>
        algorithm: <string>

compute_force:
  - pace_force
```

```{ .yaml title="Parameters" .params-block }
parameters.coef:       string, required             # ACE potential file.
parameters.algorithm:  string, default "recursive"  # "recursive" uses the recursive evaluator; any other value selects the product evaluator.
```

`pace_init` needs the `species` operator to have run before it, so list `species` first in `init_parameters`. Species are matched to the ACE elements **by name**: every species name must be a chemical element defined in the potential file, otherwise the run aborts.

```yaml title="Usage example"
includes:
  - config_update_symmetric_forces.msp

species:
  - Cu: { mass: 63.546 Da, z: 29, charge: 0 e- }

init_parameters:
  - species
  - pace_init:
      parameters:
        coef: "Cu-PBE-core-rep.ace"
        algorithm: "recursive"

compute_force:
  - pace_force
```

Examples are in `exaStamp/data/regression_new/mliaps/pace/` (`Cu_pace.msp`, `CH_pace.msp`, `NH_pace.msp`).

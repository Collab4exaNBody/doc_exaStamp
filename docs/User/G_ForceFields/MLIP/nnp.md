---
icon: material/graph-outline
---

# **NNP - Neural Network Potential (n2p2)**

## **Description**

High-dimensional neural network potentials (Behler-Parrinello type) write the energy of each atom as the output of a per-species neural network whose inputs are atom-centered symmetry functions. `exaStamp` evaluates them through the [n2p2](https://github.com/CompPhysVienna/n2p2) library. The model is read from an n2p2 directory (`input.nn`, `scaling.data`, `weights.XXX.data`).

!!! note "Build"

    Configure exaStamp with:

    - `-DEXASTAMP_MLIP_N2P2_BUILD=ON`
    - `-DEXASTAMP_MLIP_N2P2_ROOT_DIR=<path>` (default `/usr/local/n2p2`)

    The directory must contain the n2p2 headers in `include/` and the `lib/libnnp.so` and `lib/libnnpif.so` libraries. `libnnpif` must provide the exaStamp interface class (`InterfaceExastamp`). If the directory does not exist, the plugin is silently disabled.

!!! warning

    The n2p2 interface runs on CPU only and is not covered by the regression test suite.

## **Operator**

```{ .yaml title="Syntax" .syntax-block }
n2p2_force:
  parameters:
    dir: <string>
    showew: <bool>
    resetew: <bool>
    showewsum: <int>
    maxew: <int>
    cflength: <float>
    cfenergy: <float>
    cutoff: <float>
    dump_out: <bool>
```

```{ .yaml title="Parameters" .params-block }
parameters.dir:        string, required   # n2p2 model directory (input.nn, scaling.data, weights.*.data).
parameters.showew:     bool, required     # Print extrapolation warnings (symmetry functions outside the training range).
parameters.resetew:    bool, required     # Reset the extrapolation warning counter at each step.
parameters.showewsum:  int, required      # Print a summary of extrapolation warnings every showewsum steps (0 = never).
parameters.maxew:      int, required      # Abort after this many extrapolation warnings.
parameters.cflength:   float, required    # Length conversion factor from Angstrom to the model length unit.
parameters.cfenergy:   float, required    # Energy conversion factor from eV to the model energy unit.
parameters.cutoff:     float, required    # Cutoff radius in Angstrom (plain number, no unit). Must be at least the largest symmetry-function cutoff of the model.
parameters.dump_out:   bool, required     # Enable n2p2's own output on stdout.
```

All parameters are required.

```yaml title="Usage example"
compute_force:
  - n2p2_force:
      parameters:
        dir: "nnp-model"
        showew: false
        resetew: true
        showewsum: 0
        maxew: 1000000
        cflength: 1.0
        cfenergy: 1.0
        cutoff: 6.0
        dump_out: false
```

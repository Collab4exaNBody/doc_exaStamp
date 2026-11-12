---
icon: material/atom-variant
---

# **YE3T - linear Atomic Cluster Expansion (.yace)**

## **Description**

`ye3t_force` evaluates the linear atomic cluster expansions of the `.yace` family of [ye3t-lammps](https://github.com/ye3t-equivariance/ye3t-lammps) (`pair_style ye3t`), which are PACE-compatible `.yace` files. For a central atom $i$ of element $\mu$:

$$
A_{\nu n l m}(i) = \sum_{j \in \nu} R^{\mu\nu}_{nl}(r_{ij})\, Y_{lm}(\hat{r}_{ij}), \qquad
\rho_i = \sum_{\text{functions}} \sum_{\text{rows}} \tilde{c}\, \prod_{t} A_{\nu_t n_t l_t m_t}(i), \qquad
E_i = E_0^{\mu} + c^{\mu}\, \rho_i
$$

- radial functions: Chebyshev polynomials of an exponentially scaled distance times a cosine cutoff (`ChebExpCos`), contracted by the `radcoefficients`; rank-1 functions use the radial basis directly;
- $Y_{lm}$: complex spherical harmonics (Condon-Shortley phase, $Y_{00} = 1$);
- radial functions tabulated as cubic splines over `deltaSplineBins`, as in ye3t-lammps and ML-PACE, so that the results match theirs to round-off.

Supported: the subset accepted by ye3t-lammps for `.yace` files, i.e. a **linear** embedding (`FS_parameters: [c, 1]`), one density, no hard-core repulsion (`prehc: 0`), no inner cutoff, `ChebExpCos` radial basis, real (conjugation-symmetric) coefficients. The tagged-Cauchy and lifted-Cauchy bundles of ye3t are not supported yet.

The kernels are native exaStamp kernels: on a GPU if one is available, else vectorised OpenMP on the CPU. No external library is needed.

!!! note "Build"

    Built by default; disable with `-DEXASTAMP_MLIP_YE3T_BUILD=OFF`.

## **Operators**

```{ .yaml title="Syntax" .syntax-block }
init_parameters:
  - species
  - ye3t_init:
      parameters:
        file: <string>
        mem_gb: <float>
        analytic: <bool>
        emulate: <int>

compute_force:
  - ye3t_force
```

```{ .yaml title="Parameters" .params-block }
parameters.file:      string, required        # .yace model file.
parameters.mem_gb:    float, default 1.0      # memory budget of the per-chunk work arrays (GB); atoms are processed in chunks that fit.
parameters.analytic:  bool, default false     # debug: radial functions evaluated directly instead of the splines of the model.
parameters.emulate:   int, default 0          # debug: N > 0 runs the GPU code paths on the CPU with blocks of N threads (slow).
```

The exaStamp species are matched to the elements of the model **by name**; atoms of other species are ignored by the potential. `ye3t_init` raises `rcut_max` to the largest bond cutoff.

`ye3t_force` puts forces on ghost atoms: zero them before and fold them back after (see [MLIP](index.md)). Per-atom energy: $E_i$. Per-atom virial: the whole virial of each bond $i$-$j$ on the central atom $i$ (ye3t-lammps splits it half and half; totals are identical).

```yaml title="Usage example"
includes:
  - config_update_symmetric_forces.msp

species:
  - Ta: { mass: 180.94788 Da, z: 73, charge: 0 e- }

init_parameters:
  - species
  - ye3t_init:
      parameters: { file: "model.yace" }

compute_force:
  - ye3t_force
```

A complete example (random two-element test model from `exaStamp/scripts/python/ye3t_test_model.py`) is the regression case `exaStamp/data/regression_new/physics_regression/mlip_ye3t_tw`.

## **Validation and performance**

Against LAMMPS `pair_style ye3t` and `pace product` on the Ta models shipped with ye3t-lammps (ranks up to 16) and a Ta/W test model: forces agree to $5\times10^{-11}$ eV/Å, energies and virials to round-off, identical for any MPI / OpenMP decomposition and for the emulated GPU code path. On an Apple M4 Pro (3456 Ta atoms, `ta_l8_full` model, per MD step): 24.6 ms on 1 core, 6.6 ms on 4 threads; ye3t-lammps 21.2 / 5.5 ms, ML-PACE 56 / 14.4 ms.

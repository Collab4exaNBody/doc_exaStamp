---
icon: material/atom-variant
---

# **YE3T - linear Atomic Cluster Expansion (.yace) and tagged-Cauchy models**

## **Description**

`ye3t_force` evaluates the linear atomic cluster expansions of the `.yace` family of [ye3t-lammps](https://github.com/ye3t-equivariance/ye3t-lammps) (`pair_style ye3t`), which are PACE-compatible `.yace` files. For a central atom $i$ of element $\mu$:

$$
A_{\nu n l m}(i) = \sum_{j \in \nu} R^{\mu\nu}_{nl}(r_{ij})\, Y_{lm}(\hat{r}_{ij}), \qquad
\rho_i = \sum_{\text{functions}} \sum_{\text{rows}} \tilde{c}\, \prod_{t} A_{\nu_t n_t l_t m_t}(i), \qquad
E_i = E_0^{\mu} + c^{\mu}\, \rho_i
$$

- radial functions: Chebyshev polynomials of an exponentially scaled distance times a cosine cutoff (`ChebExpCos`), contracted by the `radcoefficients`; rank-1 functions use the radial basis directly;
- $Y_{lm}$: complex spherical harmonics (Condon-Shortley phase, $Y_{00} = 1$);
- radial base functions tabulated as cubic splines over `deltaSplineBins` and contracted afterwards (the spline being linear in its nodes, this equals the splined radial functions of ye3t-lammps and ML-PACE to round-off).

Supported: the subset accepted by ye3t-lammps for `.yace` files, i.e. a **linear** embedding (`FS_parameters: [c, 1]`), one density, no hard-core repulsion (`prehc: 0`), no inner cutoff, `ChebExpCos` radial basis, real (conjugation-symmetric) coefficients. Tagged-Cauchy models (slice v2, alone or as a composite with a `.yace` backbone) are supported too, see below; the physical-image tagged slices (v3, v4) and the lifted-Cauchy models of ye3t are not.

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
parameters.file:      string, required        # .yace model file, or .json tagged-Cauchy model (composite manifest or slice v2).
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

## **Tagged-Cauchy models**

ye3t-lammps `pair_style ye3t model_family tagged_cauchy` models (schema `ye3t_tagged_cauchy_slice_v2`) add to the linear ACE a correction built from real orthonormal tesseral components $\phi_c(\vec r_{ij}) = R_{n_c}(r_{ij})\, Y_c(\hat r_{ij})$ (ChebExpCos radial base, one neighbour element per component):

$$
A_k = \sum_j \phi_{c_k}(\vec r_{ij}), \qquad
M_m = \sum_j \prod_{c \in m} \phi_c(\vec r_{ij}), \qquad
E_i \mathrel{+}= o^{\mu} + \sum_{\text{terms}} \beta^{\mu}_f\, w \prod A \prod M \; F(z_i, p)
$$

with moments $M_m$ products over **one edge**, $z_i$ the number of edges of $i$ within the cutoff and $F(z, p) = \prod_{q < s - p} (z - p - q)$ (zero if $z < s$, $s$ = `tag_count`) the falling factorial of the tagged positions. `file` is then the `.json` composite manifest (`ye3t_tagged_cauchy_composite_v1`: backbone `.yace` + tagged correction, e.g. `model.ye3t.json` of the ye3t-lammps `cost_comparison` models) or a tagged slice alone. The correction radials are evaluated directly (no splines), as in ye3t-lammps.

Models fitted as a residual to ZBL (all ye3t-lammps `cost_comparison` models: `pair_style hybrid/overlay ye3t ... zbl inner outer`) need the same ZBL term, from `zbl_multi_force`:

```yaml title="Usage example (Cu, ye3t-lammps cost_comparison model)"
init_parameters:
  - species
  - ye3t_init:
      parameters: { file: "models/ye3t_tagged_127/model.ye3t.json" }

compute_force:
  - ye3t_force
  - zbl_multi_force:
      rcut: 1.6491548566510283 ang
      parameters:
        - { type_a: Cu , type_b: Cu , rcut: 1.6491548566510283 ang , parameters: { r1: 1.2826759996174664 ang , rc: 1.6491548566510283 ang } }
```

A complete example (random rotation-invariant Ta/W correction from `exaStamp/scripts/python/ye3t_tagged_test_model.py` on the `tw_test.yace` backbone) is the regression case `mlip_ye3t_tagged_tw`.

## **Validation and performance**

Against LAMMPS `pair_style ye3t` and `pace product` on the Ta models shipped with ye3t-lammps (ranks up to 16) and a Ta/W test model: forces agree to $5\times10^{-11}$ eV/Å, energies and virials to round-off, identical for any MPI / OpenMP decomposition and for the emulated GPU code path. On an Apple M4 Pro (3456 Ta atoms, `ta_l8_full` model, per MD step): 18.8 ms on 1 core, 5.5 ms on 4 threads; ye3t-lammps 21.4 / 5.6 ms, ML-PACE 56 / 14.4 ms.

Tagged-Cauchy: against LAMMPS `pair_style ye3t model_family tagged_cauchy block_policy direct` on the fitted Cu, Mo and Ni `cost_comparison` models (backbone + correction, rattled 250-atom frames) and on the Ta/W multi-species slice of the ye3t-lammps tests: forces agree to $5\times10^{-11}$ eV/Å ($5\times10^{-10}$ for Ta/W), energies to $10^{-9}$ eV in total, identical for any MPI / OpenMP decomposition and for the emulated GPU code path; with the ZBL term, on frames with pairs down to 1.25 Å, the same agreement with `hybrid/overlay ye3t ... zbl`. 4000 Cu atoms (`ye3t_tagged_127`, per MD step, Apple M4 Pro): 77 ms on 1 core, 20.8 ms on 4 threads, 12.0 ms on 8 threads; ye3t-lammps `block_policy direct` 112-114 / 29-30 / 15-16 ms (1 / 4 / 8 MPI ranks), i.e. 1.25-1.45 times faster. The backbone alone: 22 ms on 1 core (ye3t-lammps 22 ms).

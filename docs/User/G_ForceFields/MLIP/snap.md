---
icon: material/vector-triangle
---

# **SNAP - Spectral Neighbor Analysis Potential**

## **Description**

SNAP writes the energy of atom $i$ as a linear (or quadratic) function of its bispectrum components $B_{i,k}$, which are computed from the neighbor density projected on 4D hyperspherical harmonics:

$$
E_i = \beta_{0}^{\alpha_i} + \sum_{k=1}^{K} \beta_{k}^{\alpha_i} B_{i,k}
$$

where $\alpha_i$ is the species of atom $i$ and $\beta^{\alpha}$ are the fitted coefficients of that species. The potential is defined by two files in the standard SNAP format:

- a **parameter file** (`.snapparam`): `rcutfac`, `twojmax`, `rfac0`, `rmin0`, flags such as `bzeroflag`, `chemflag`, `switchflag`, ...
- a **coefficient file** (`.snapcoeff`): for each element, a header line `name radelem weight` followed by its coefficients.

The per-pair cutoff is $(r^{elem}_{i}+r^{elem}_{j})\times$ `rcutfac`.

!!! note "Build"

    Configure exaStamp with `-DEXASTAMP_MLIP_SNAP_BUILD=ON`. SNAP relies on exaNBody's SNAP kernels, so exaNBody must have been built with `-DEXANB_BUILD_CONTRIB_MD=ON`.

## **Force operators**

Two operators evaluate SNAP energies, forces and virial:

<div class="center-table" markdown>

| Operator | Precision |
| :------- | :-------- |
| `snap_force` | set at exaNBody build time by `SNAP_FP32_MATH` (default **ON**, i.e. single-precision bispectrum) |
| `snap_force_fp64` | always double precision |

</div>

!!! tip

    Because exaNBody is built with `SNAP_FP32_MATH=ON` by default, `snap_force` runs in mixed/single precision. That is faster, especially on GPU, but energies and forces carry single-precision round-off. Use `snap_force_fp64` when you need accurate energies, energy conservation over long NVE runs, or comparisons with reference data.

```{ .yaml title="Syntax" .syntax-block }
snap_force_fp64:
  parameters:
    param: <string>
    coef: <string>
    nt: <int>
  conv_coef_units: <bool>
  bispectrumchkfile: <string>
  check_bs_max_error: <float>
```

```{ .yaml title="Parameters" .params-block }
parameters.param:    string, required       # SNAP parameter file (.snapparam), searched in the data paths.
parameters.coef:     string, required       # SNAP coefficient file (.snapcoeff).
parameters.nt:       int, default 2         # Number of species (informative).
conv_coef_units:     bool, default false    # Convert the coefficients to internal units once at read time instead of converting energies/forces at each step.
bispectrumchkfile:   string, optional       # Reference bispectrum file used to check the bispectrum values (debug).
check_bs_max_error:  float, default 1e-12   # Maximum L2 error allowed when checking against bispectrumchkfile.
```

SNAP is usually combined with a short-range ZBL repulsion, by listing both operators in `compute_force`.

```yaml title="Usage example"
includes:
  - config_update_symmetric_forces.msp

species:
  - Ta: { mass: 180.88 Da , z: 73 , charge: 0.0 e- }

zbl_multi_force:
  rcut: 4.8 ang
  parameters:
    - { type_a: Ta , type_b: Ta , rcut: 4.8 ang , parameters: { r1: 4.0 ang , rc: 4.8 ang } }

compute_force:
  - zbl_multi_force
  - snap_force_fp64:
      parameters:
        nt: 1
        param: "Ta06A.snapparam"
        coef:  "Ta06A.snapcoeff"
```

Complete examples for Mo, Ni, Ta, W, WBe and InP are in `exaStamp/data/regression_new/mliaps/snap/<element>/<element>_exaStamp.msp`.

!!! note "Multi-species potentials"

    Elements are matched **by position**: the first species declared in the `species` block uses the first element block of the coefficient file, and so on. Declare the species in the same order as the coefficient file.

## **`snap_init`**

`snap_init` reads the SNAP files once in `init_parameters` and builds the SNAP context used by the [descriptor operators](descriptors.md) (`compute_descriptor_snap`, `compute_descriptor_snap_global`). It also raises `rcut_max` to the SNAP cutoff. The force operators above do **not** need it.

```{ .yaml title="Syntax" .syntax-block }
snap_init:
  parameters:
    param: <string>
    coef: <string>
  conv_coef_units: <bool>
```

```yaml title="Usage example"
init_parameters:
  - species
  - snap_init:
      parameters: { param: "W.snapparam", coef: "W.snapcoeff" }
```

## **Electronic-temperature dependent SNAP (SNAP-TTM)**

With `snap_ttm_coefficients`, the SNAP coefficients depend on the local electronic temperature $T_e$, which comes from the [two-temperature model](../../H_EnsemblesConstraints/ttm.md). For every atom, the operator reads $T_e$ in the TTM sub-cell that contains the atom (nearest sub-cell, no interpolation) and evaluates:

- $\beta_0(T_e)$: a polynomial of order $P$,
- $\beta_1(T_e) \dots \beta_K(T_e)$: natural cubic splines through tabulated values, extrapolated with the end-interval cubics outside the tabulated range.

The resulting per-atom coefficients replace the per-species coefficients of the `.snapcoeff` file. They are consumed by **`snap_force_fp64`** (not `snap_force`), so `snap_ttm_coefficients` must be placed **right before** `snap_force_fp64` in `compute_force`.

```{ .yaml title="Syntax" .syntax-block }
snap_ttm_coefficients:
  betas_file: <string>
  te_conv_factor: <float>
  betas_check_file: <string>
```

```{ .yaml title="Parameters" .params-block }
betas_file:        string, required                     # Temperature-dependent coefficient file (.snapbetas).
te_conv_factor:    float, default 8.61732814974056e-5   # Conversion factor from Te (K, TTM grid) to the Te unit of the betas file (eV).
betas_check_file:  string, optional                     # If set, writes beta_0..beta_K sampled on 10000 Te points in [0,6] eV to this file (rank 0, first call), to check the fit.
```

**`.snapbetas` file format**:

```text
ntelec N
Te_0 Te_1 ... Te_{N-1}          # N temperature knots in eV, strictly increasing
bzeropolyorder P
c_P ... c_1 c_0                 # P+1 coefficients of beta_0(Te), highest order first
<ncoeffall lines of N values>   # beta_r at each Te knot, r = 0..ncoeffall-1 (row 0 is not used, beta_0 comes from the polynomial)
```

The electronic temperature field `te` must exist, so the TTM grid must be created in `setup_system` with `resize_grid_cell_values` and `init_ttm`.

```yaml title="Usage example"
compute_force:
  - zbl_multi_force
  - snap_ttm_coefficients:
      betas_file: "Au.snapbetas"
  - snap_force_fp64:
      parameters:
        nt: 1
        param: "Au.snapparam"
        coef:  "Au.snapcoeff"
  - ghost_update_r_v
  - ionic_eletronic_heat_transfer:
      # ... TTM parameters, see the TTM page
```

!!! warning "Ghost reduction of the TTM grid"

    `update_force_energy_from_ghost` (in `config_update_symmetric_forces.msp`) also **sums** the ghost grid-cell values into their owner cells. With periodic images, this would multiply $T_e$ by the number of images at every step. With TTM, use the variant that only folds back forces and energies:

    ```yaml
    compute_force_epilog:
      - update_force_energy_from_ghost_no_gcv
      - force_to_accel
    ```

Examples are in `exaStamp/data/regression_new/mliaps/snap_ttm/` (`constant_te`, `ttm_coupled`, `hotspot`).

## **Other SNAP implementations**

`snaplegacy_force` (built with `EXASTAMP_MLIP_SNAP_BUILD`) and `snaplmp_force` (built with `EXASTAMP_MLIP_SNAPLMP_BUILD`, requires an external reference SNAP source tree given by `EXASTAMP_MLIP_SNAPLMP_LMP_SRC_DIR`) are older CPU implementations kept for validation. They take the same `parameters` block. Use `snap_force` / `snap_force_fp64` for production runs.

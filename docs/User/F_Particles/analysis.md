---
icon: simple/moleculer
---

# **Analysis**

Read-only, on-the-fly per-particle diagnostics — as opposed to [Setters](setters.md), which mutate existing particle fields.

## **Neighbor-averaged fields**

### `average_neighbors_scalar`

```{ .yaml title="Syntax" .syntax-block }
average_neighbors_scalar:
  nbh_field: <string>
  avg_field: <string>
  rcut: <float>
  weight_function: [<float>, ...]
```

```{ .yaml title="Parameters" .params-block }
nbh_field:        string, required               # Name of the field to average over neighbors.
avg_field:        string, required               # Name of the resulting averaged field.
rcut:             float, default 0.              # Cutoff distance for the average.
weight_function:  list of floats, default [1.0]  # Polynomial distance-weighting coefficients [a0, a1, a2, a3] (up to 4 terms).
```

Writes a new per-particle scalar field (`avg_field`) that's a distance-weighted average of another field (`nbh_field`) over neighboring particles within `rcut`:

$$
\text{avgField}_i = \frac{\displaystyle\sum_{j} w(r_{ij}) \cdot \text{nbhField}_j}{\displaystyle\sum_{j} w(r_{ij})}
$$

where the sums run over neighbors $j$ of particle $i$ within `rcut`, and the weight is the polynomial given by `weight_function`:

$$
w(r) = a_0 + a_1 r + a_2 r^2 + a_3 r^3
$$

```yaml title="Usage example"
average_neighbors_scalar:
  nbh_field: mass
  avg_field: avg_mass
  rcut: 8.0 ang
  weight_function: [ 1.0, 0.0, -0.01 ]  # 1 + 0·r - 0.01·r²
```

## **Local mechanical metrics**

A family of GPU-compatible operators computes continuum-mechanics measures per particle and stores each result as a new per-particle field, whose name is chosen with the `*_field` parameters. These fields can then be written with the particle output operators (e.g. `write_xyz: { fields: [ ... ] }`), projected on the grid, or used by other operators.

Two operators fit a local tensor over the neighbors of each particle; all the others are pointwise and only read fields computed before:

| Operator | Reads | Writes (default field names) | Description |
| :--- | :--- | :--- | :--- |
| `compute_deformation_gradient_tensor` | positions, reference configuration | `defgrad`, `slip` | Deformation gradient $\mathbf{F}$ and slip vector |
| `compute_velocity_gradient_tensor` | positions, velocities | `velgrad` | Velocity gradient $\mathbf{L}$ |
| `compute_green_lagrange_strain` | `defgrad` | `green_lagrange` | $\mathbf{E} = \frac{1}{2}(\mathbf{F}^T\mathbf{F} - \mathbf{I})$ |
| `compute_polar_decomposition` | `defgrad` | `rotation`, `stretch` | $\mathbf{F} = \mathbf{R}\,\mathbf{U}$ |
| `compute_microrotation` | `rotation` | `microrotation` | Axial vector of the skew part of $\mathbf{R}$ |
| `compute_vorticity` | `velgrad` | `vorticity` | Axial vector of the skew part of $\mathbf{L}$ |
| `compute_jacobian` | `defgrad` | `jacobian` | $J = \det \mathbf{F}$ (local volume ratio) |
| `compute_strain_invariants` | `green_lagrange` | `strain_i1`, `strain_i2`, `strain_i3` | Invariants of a symmetric tensor: trace, sum of principal minors, determinant |
| `compute_von_mises_strain` | `green_lagrange` | `von_mises` | Von Mises equivalent of a symmetric tensor |
| `compute_shear_strain` | `green_lagrange` | `shear_strain` | Shear strain, equal to the von Mises equivalent divided by $\sqrt{3}$ |
| `compute_slip_tripod` | `defgrad` | `burgerpar`, `burgerortho`, `glide` | Local slip basis: Burgers direction $\mathbf{l}$, in-plane orthogonal direction $\mathbf{m}$, glide-plane normal $\mathbf{n}$ |
| `compute_microrotation_gradient` | `microrotation`, reference configuration | `vecgrad` | Spatial gradient of the microrotation vector |
| `compute_dislocation_indicators` | `vecgrad`, `burgerpar`, `burgerortho`, `glide` | `dislo`, `vis`, `coin`, `dislol`, `dislolo` | Dislocation indicator, screw (`vis`) and edge (`coin`) components, dislocation line directions |

### `compute_deformation_gradient_tensor`

```{ .yaml title="Syntax" .syntax-block }
compute_deformation_gradient_tensor:
  rcut: <float>
  weight_function: [<float>, ...]
  defgrad_field: <string>
  slip_field: <string>
```

```{ .yaml title="Parameters" .params-block }
rcut:             float, required                # Neighbor cutoff, in the reference configuration.
weight_function:  list of floats, default [1.0]  # Polynomial distance weight [a0, a1, ...], evaluated on the reference-frame distance.
defgrad_field:    string, default "defgrad"      # Name of the output deformation gradient field.
slip_field:       string, default "slip"         # Name of the output slip vector field.
grid_t0:          grid, required                 # Reference configuration (same particles as the current grid).
backup_r_lt:      position backup, required      # Backup the reference configuration was restored from (provides its box).
```

For each particle, the neighbors are matched between the reference configuration and the current one, and $\mathbf{F}$ is obtained by a weighted least-squares fit of the current relative positions against the reference ones. The slip vector is minus the average displacement of the neighbors whose relative position changed by more than `rcut`/10 (Zimmerman et al., PRL 87, 165507, 2001).

The reference configuration is saved once with `backup_r_lt` (e.g. in `init_epilog`) and restored into a copy of the grid when the analysis runs. Set `rcut_max` in `global` to at least `rcut`, so that the neighbor lists cover the fit cutoff. `weight_function` takes at most 4 coefficients.

### `compute_velocity_gradient_tensor`

```{ .yaml title="Syntax" .syntax-block }
compute_velocity_gradient_tensor:
  rcut: <float>
  weight_function: [<float>, ...]
  velgrad_field: <string>
```

Fits $\mathbf{L}$ from the relative velocities and positions of the neighbors in the current configuration; no reference configuration is needed.

!!! warning
    Ghost velocities must be up to date: call `ghost_update_r_v` just before this operator.

### `compute_microrotation_gradient`

Same parameters as `compute_deformation_gradient_tensor` (`rcut`, `weight_function`, `grid_t0`, `backup_r_lt`), plus `microrot_field` (input, default `"microrotation"`) and `vecgrad_field` (output, default `"vecgrad"`). The microrotation of the ghost particles must be up to date: call `ghost_update_opt: { opt_fields: [ "<microrot_field>" ] }` before.

### Dislocation detection example

```yaml title="Usage example (exaStamp/data/regression_new/analysis_particle/test_dislocation_chain.msp)"
global:
  rcut_max: &defgrad_rcut 6.0 ang

init_epilog:
  - backup_r_lt                       # save the reference configuration

write_snapshot:
  - copy_grid
  - restore_ghost_r0:                 # reference configuration in grid_copy
      rebind: { grid: grid_copy }
      body:
        - backup_r_lt_move_data
        - restore_r_lt
        - ghost_update_r
  - compute_F:
      rebind: { grid_t0: grid_copy }
      body:
        - compute_deformation_gradient_tensor:
            rcut: *defgrad_rcut
            weight_function: [ 1.0 , 0.0 , 0.0 ]
            defgrad_field: F
        - compute_polar_decomposition: { defgrad_field: F, rot_field: R, stretch_field: U }
        - compute_microrotation: { rot_field: R, microrot_field: mu }
        - compute_slip_tripod: { defgrad_field: F, burgerpar_field: l, burgerortho_field: m, glide_field: n }
        - ghost_update_opt: { opt_fields: [ "mu" ] }
        - compute_microrotation_gradient:
            rcut: *defgrad_rcut
            weight_function: [ 1.0 , 0.0 , 0.0 ]
            microrot_field: mu
            vecgrad_field: vecgrad
        - compute_dislocation_indicators:
            vecgrad_field: vecgrad
            burgerpar_field: l
            burgerortho_field: m
            glide_field: n
  - timestep_file: "xyz/dislo_%09d.xyz"
  - write_xyz: { fields: [ id, type, F, mu, dislo, vis, coin, dislol, dislolo ] }
```

The pointwise operators take only their input and output field names, for example:

```yaml title="Usage example"
- compute_green_lagrange_strain: { defgrad_field: defgrad, strain_field: green_lagrange }
- compute_strain_invariants: { tensor_field: green_lagrange, i1_field: strain_i1, i2_field: strain_i2, i3_field: strain_i3 }
- compute_von_mises_strain: { tensor_field: green_lagrange, vonmises_field: von_mises }
- compute_shear_strain: { tensor_field: green_lagrange, shear_strain_field: shear_strain }
- compute_jacobian: { defgrad_field: defgrad, jacobian_field: jacobian }
- compute_vorticity: { velgrad_field: velgrad, vort_field: vorticity }
```

Other examples are available in `exaStamp/data/regression_new/analysis_particle/` (`compute_local_strain.msp`, `compute_local_slip_vector.msp`, `project_local_deformation_gradient.msp`).

## **Local structure classification**

### `compute_slcsa`

Supervised-learning crystal structure analysis: classifies each particle as BCC (0), FCC (1), HCP (2), SC (3) or other (4) from its per-particle bispectrum descriptors, computed beforehand by `compute_descriptor_snap` (see [Descriptors](../G_ForceFields/MLIP/descriptors.md)). A pretrained linear discriminant analysis reduces the bispectrum to 3 components, a softmax gives the most probable class, and a Mahalanobis-distance test against the reference distribution of that class sends outliers back to "other".

```{ .yaml title="Syntax" .syntax-block }
compute_slcsa:
  lda_scalings: [[<float>, <float>, <float>], ...]
  overall_mean: [<float>, ...]
  decision: [[<float>, <float>, <float>], ...]
  biais: [<float>, ...]
  mean_bcc: [<float>, <float>, <float>]
  mean_fcc: [<float>, <float>, <float>]
  mean_hcp: [<float>, <float>, <float>]
  mean_sc:  [<float>, <float>, <float>]
  cova_bcc: <3x3 matrix>
  cova_fcc: <3x3 matrix>
  cova_hcp: <3x3 matrix>
  cova_sc:  <3x3 matrix>
  distance: <float>
  crystal_structure_field: <string>
```

```{ .yaml title="Parameters" .params-block }
lda_scalings:             list of ncoeff 3-vectors, required  # LDA projection matrix.
overall_mean:             list of ncoeff floats, required     # Mean bispectrum, subtracted before projection.
decision:                 list of 4 3-vectors, required       # Softmax decision vectors (BCC, FCC, HCP, SC).
biais:                    list of 4 floats, required          # Softmax biases (BCC, FCC, HCP, SC).
mean_bcc ... mean_sc:     3-vector, required                  # Reference mean of each class in LDA space.
cova_bcc ... cova_sc:     3x3 matrix, required                # Reference covariance of each class in LDA space.
distance:                 float, required                     # Mahalanobis distance threshold.
crystal_structure_field:  string, default "crystal_structure" # Name of the output field.
```

A complete example with trained coefficients is given in `exaStamp/data/regression_new/analysis_particle/compute_slcsa.msp`.

## **Global virial**

### `compute_sum_fdotr`

Computes the global virial tensor $\sum_i \mathbf{F}_i \otimes \mathbf{r}_i$ in a single pass over the particles, owned and ghosts, from the forces and positions only. It does not need per-atom virials, so it works with any potential.

```{ .yaml title="Parameters" .params-block }
ghost:  bool, default true   # Include ghost particles. Must stay true for a correct result with periodic boundaries.
out:    Mat3d (output)       # Global virial tensor, in internal units (not divided by the volume).
```

It must run in `compute_force_epilog`, before the ghost forces are added back to their owners by `update_force_energy_from_ghost`:

```yaml title="Usage example (exaStamp/data/regression_new/mliaps/mtp/exastamp_example/compute_sum_fdotr.msp)"
compute_force_prolog:
  - zero_force_energy: { ghost: true }

compute_force_epilog:
  - compute_sum_fdotr
  - update_force_energy_from_ghost
  - force_to_accel
```

The ghost forces must be zeroed together with the owned ones (`zero_force_energy: { ghost: true }`). The result is not used by the thermodynamic state.

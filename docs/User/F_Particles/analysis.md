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

Three classifiers are available: Common Neighbor Analysis (`compute_cna`), Polyhedral Template Matching (`compute_ptm`, which also gives the local lattice orientation) and a supervised-learning classifier on bispectrum descriptors (`compute_slcsa`). CNA and PTM use the same structure numbering:

| Value | 0 | 1 | 2 | 3 | 4 | 5 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Structure | none | FCC | HCP | BCC | ICO | SC (PTM only) |

CNA and PTM write flat per-particle buffers; a second operator (`cna_fields`, `ptm_fields`) copies them into named grid fields, for the owned particles only. Both need neighbor lists with `chunk_size: 1`:

```yaml
chunk_neighbors:
  config:
    chunk_size: 1
    build_particle_offset: true
```

Any `rcut` is accepted: only the nearest neighbors needed by the method (16 for CNA, 18 for PTM) are kept, so a larger `rcut` gives the same result. Set `rcut_max` in `global` to at least `rcut`.

### `compute_cna`

Adaptive-cutoff Common Neighbor Analysis: FCC, HCP and ICO are recognized from the 12 nearest neighbors, BCC from the 14 nearest. The local cutoff is derived from the mean distance of the nearest neighbors, so no lattice parameter is needed.

```{ .yaml title="Parameters" .params-block }
rcut:  float, required   # Neighbor search cutoff: must include 13 neighbors (FCC/HCP/ICO) or 15 (BCC).
```

```{ .yaml title="Parameters of cna_fields" .params-block }
struct_field:  string, default "cna_type"   # Name of the output structure-type field.
```

```yaml title="Usage example"
- compute_cna: { rcut: 5.0 ang }
- cna_fields: { struct_field: cna_type }
- write_xyz: { fields: [ id, type, cna_type ] }
```

### `compute_ptm`

Polyhedral Template Matching (P. M. Larsen, S. Schmidt, J. Schiøtz, *Modelling Simul. Mater. Sci. Eng.* 24, 055007, 2016): the neighbors of each particle are matched against the FCC, HCP, BCC, ICO and SC templates. It gives the structure type, the lattice orientation and the RMSD of the best match. The PTM library (MIT license) is included in exaStamp. Host only (OpenMP, no GPU).

```{ .yaml title="Parameters" .params-block }
rcut:         float, required     # Neighbor search cutoff: must include 14 neighbors for BCC (12 FCC/HCP/ICO, 6 SC). Only the 18 nearest are used.
rmsd_cutoff:  float, default 0.1  # A match with a larger RMSD is reported as structure 0 (RMSD and orientation still written). <= 0 disables it.
```

```{ .yaml title="Parameters of ptm_fields" .params-block }
struct_field:  string, default "ptm_type"          # Output structure-type field (scalar).
orient_field:  string, default "ptm_orientation"   # Output lattice orientation, as a rotation matrix (Mat3d).
rmsd_field:    string, default "ptm_rmsd"          # Output RMSD (negative if no match).
```

```yaml title="Usage example"
- compute_ptm: { rcut: 3.6 ang, rmsd_cutoff: 0.1 }
- ptm_fields: { struct_field: ptm_type, orient_field: ptm_orientation, rmsd_field: ptm_rmsd }
- write_xyz: { fields: [ id, type, ptm_type, ptm_rmsd ] }
```

### `ptm_shrink_disorder`

Runs between `compute_ptm` and `ptm_fields`. An atom left with no structure takes the structure type shared by at least `min_neighbor_fraction` of its neighbors within `rcut`; the pass is repeated `n_iterations` times, each one using the previous result. This keeps the strained lattice around defects crystalline, while defect cores, whose neighbors are disordered too, stay unmatched.

```{ .yaml title="Parameters" .params-block }
rcut:                   float, required    # Neighbor cutoff of the vote, usually the rcut of compute_ptm.
min_neighbor_fraction:  float, default 0.5 # Fraction of the neighbors that must share a structure type.
n_iterations:           int, default 3     # Number of passes.
```

Unlike `compute_ptm`, the vote uses every neighbor within `rcut`: a too large `rcut` stops with an explicit error.

```yaml title="Usage example"
- compute_ptm: { rcut: 5.0 ang, rmsd_cutoff: 0.2 }
- ptm_shrink_disorder: { rcut: 5.0 ang, min_neighbor_fraction: 0.5, n_iterations: 3 }
- ptm_fields: {}
```

Examples are given in `exaStamp/data/regression_new/analysis_particle/ptm_cna/`.

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

## **Strain functional descriptors**

Strain Functional Descriptors (SFD; E. M. Kober, J. P. Tavenner, C. M. Adams, N. Mathew, *Strain functionals: a complete and symmetry-adapted set of descriptors to characterize atomistic configurations*, arXiv:2402.04191) describe the local arrangement of the neighbors of each particle by rotational invariants of their position moments. They need no reference lattice and are suited as inputs of classifiers or regression models. GPU compatible.

For a particle $i$, the neighbors $j$ within `rcut` and the particle itself (weight 1) are weighted by $w_j = \exp(-r_{ij}^2 / 2\sigma^2)$, with $\mathbf{r}_{ij} = \mathbf{r}_i - \mathbf{r}_j$. With $W = \sum_j w_j$, the weighted centroid $\mathbf{c} = \sum_j w_j \mathbf{r}_{ij} / W$ and $\mathbf{u}_j = (\mathbf{r}_{ij} - \mathbf{c})/\sigma$, the Cartesian moments

$$
M^{(n)} = \frac{1}{W} \sum_j w_j\, \mathbf{u}_j^{\otimes n}, \qquad n = 2, 3, 4
$$

are split into their SO(3) irreducible parts (spherical tensors of rank $l$, solid-harmonic normalization):

| Order | Parts |
| :--- | :--- |
| 1 | $\mathbf{c}/\sigma$: rank 1 |
| 2 | scalar (trace, isotropic Gaussian value removed), rank 2 |
| 3 | rank 1 (trace vector), rank 3 |
| 4 | scalar (double trace, isotropic Gaussian value removed), rank 2 (order 2 contribution removed), rank 4 |

Rotational invariants are built from these parts with Clebsch-Gordan couplings: norms, skewness-like contractions, and cross terms between the parts of the same order. Orientation factors project the rank 1 to 4 parts on the lab $z$, $x$ and $y$ axes. All moments are in units of $\sigma$. A cutoff `rcut` of about $5.6\,\sigma$ neglects weights below $1.6 \times 10^{-7}$.

`compute_strain_functional` writes flat per-particle buffers; `strain_functional_fields` copies selected columns into grid fields named `sfd_<column>`, for the owned particles only. Set `rcut_max` in `global` to at least `rcut`.

| Columns (`sfd_invariants`, 36 per particle) | Meaning |
| :--- | :--- |
| `w` | total weight $W$ (local density) |
| `P1_I0` | norm of the centroid offset |
| `P2_I0`, `P2_I1`, `P2_I2` | order 2: norm and skewness of the rank 2 part, scalar part |
| `P3_I0` ... `P3_I6` | order 3: norm and three self-contractions of the rank 3 part, norm of the rank 1 part, two rank 3 / rank 1 cross terms |
| `P4_I0` ... `P4_I11` | order 4: norm and five self-contractions of the rank 4 part, norm and skewness of the rank 2 part, scalar part, three rank 4 / rank 2 cross terms |
| `O1_I0..2` ... `O4_I0..2` | orientation factors of the rank 1 to 4 parts on $z$, $x$, $y$ |

With `spherical_tensors: true`, the 35 lab-frame spherical tensor components are also stored in `sfd_spherical_tensors`: `P00_0` (= $W$), `P11_0`, `P11_1r`, `P11_1i`, `P20_0`, `P22_0` ... `P22_2i`, `P31a_0` ... `P31a_1i`, `P33a_0` ... `P33a_3i`, `P40_0`, `P42a_0` ... `P42a_2i`, `P44a_0` ... `P44a_4i` (`r`/`i`: real and imaginary parts of the $m > 0$ components).

### `compute_strain_functional`

```{ .yaml title="Parameters" .params-block }
rcut:               float, required        # Neighbor cutoff.
sigma:              float, required        # Width of the Gaussian neighbor weight; moments are in units of sigma.
spherical_tensors:  bool, default false    # Also store the 35 spherical tensor components.
```

```{ .yaml title="Parameters of strain_functional_fields" .params-block }
fields:  list of strings, default all 36 invariant columns   # Columns to copy, invariant or spherical tensor names.
prefix:  string, default "sfd_"                               # Field name = prefix + column name.
```

```yaml title="Usage example"
- compute_strain_functional: { rcut: 5.1 ang, sigma: 0.91 ang }
- strain_functional_fields: { fields: [ w, P2_I0, P3_I0, P4_I0 ] }
- write_xyz: { fields: [ id, type, sfd_w, sfd_P2_I0, sfd_P3_I0, sfd_P4_I0 ] }
```

Examples are given in `exaStamp/data/regression_new/analysis_particle/strain_functional/`.

### Classification with a Gaussian mixture model

Kober et al. (section 3.6) classify the particles of a deformed crystal without supervision: a Gaussian mixture model (GMM) is fitted to the invariants of all particles, and each particle is assigned to its most probable component. In compressed copper, the components separate dislocation cores, stacking faults, twins, deformed FCC and regions of strong strain gradients. The class numbers carry no meaning by themselves: they are interpreted by looking at the particles of each class. The paper uses the 4th order invariants without the orientation factors, no feature scaling, and positions averaged over 20 to 40 MD snapshots to reduce thermal noise. It scans 2 to 10 components and keeps the number for which the Calinski-Harabasz (CHI) and Davies-Bouldin (DBI) scores are both at a local extremum.

Two operators implement it:

- `sfd_gmm_fit` fits the GMM on the current configuration by expectation-maximization (full covariances). The algorithm and defaults are those of scikit-learn's `GaussianMixture`, and a fit started from the same initial model gives the same result. The k-means initialization uses a sample of particles chosen from their ids, so the fit does not depend on the number of MPI ranks. Several numbers of components can be fitted in one call: BIC, CHI and DBI are printed for each, and the best one according to `select_by` is kept (lowest DBI by default; BIC tends to split the thermally broadened bulk into several components). Components are sorted by decreasing weight, so class 0 is the most populated one (usually the bulk). Host only (OpenMP + MPI).
- `sfd_gmm_classify` assigns each particle to its most probable component, and writes the class and its posterior probability to per-particle fields. GPU compatible.

The model is kept in memory between the two operators, and can be saved to a YAML file (`model_file` of `sfd_gmm_fit`) and read back by `sfd_gmm_classify`. A model fitted on each snapshot can number its classes differently from one snapshot to the next. To keep the same classes over a run, fit once (on one snapshot, or offline) and classify every snapshot with the saved model.

The script `exaStamp/scripts/python/sfd_gmm_train.py` trains the same model with scikit-learn from xyz files written with `sfd_<column>` fields (several snapshots can be combined), and writes the same YAML format:

```bash
python sfd_gmm_train.py snap_*.xyz -k 2 3 4 5 6 --select dbi -o gmm_model.yaml
```

```{ .yaml title="Parameters of sfd_gmm_fit" .params-block }
features:         list of strings, default the 23 invariants P1_I0 ... P4_I11   # Descriptor columns used as features (at most 36).
n_components:     list of ints, default [ 2 ]     # Numbers of components to fit (at most 16 each).
select_by:        string, default "dbi"           # dbi (lowest), chi (highest) or bic (lowest), when several n_components are given.
standardize:      bool, default false             # Center and scale each feature by its mean and standard deviation.
max_iter:         int, default 100                # Maximum number of EM iterations.
tol:              float, default 1e-3             # Convergence threshold on the change of the mean log-likelihood.
reg_covar:        float, default 1e-6             # Added to the covariance diagonals.
init_sample:      int, default 20000              # Number of particles used by the k-means initialization.
n_init:           int, default 1                  # Number of initializations; the most likely fit is kept.
seed:             int, default 0                  # Seed of the initialization.
model_file:       string, default ""              # If set, the selected model is written to this YAML file.
init_model_file:  string, default ""              # If set, the initial model (before EM) is written to this YAML file.
scores_file:      string, default ""              # If set, the scores of all fits are written to this CSV file.
```

```{ .yaml title="Parameters of sfd_gmm_classify" .params-block }
model_file:         string, default ""                  # YAML model; if empty, the model of sfd_gmm_fit is used.
class_field:        string, default "sfd_class"         # Output class (component index).
probability_field:  string, default "sfd_class_prob"    # Output posterior probability of the class.
min_probability:    float, default 0                    # Below this probability the class is -1.
```

Grid field names are limited to 15 characters.

```yaml title="Usage example: fit and classify each snapshot"
- compute_strain_functional: { rcut: 5.1 ang, sigma: 0.91 ang }
- sfd_gmm_fit: { n_components: [ 2, 3, 4, 5, 6 ], select_by: dbi, model_file: gmm_model.yaml }
- sfd_gmm_classify: {}
- write_xyz: { fields: [ id, type, sfd_class, sfd_class_prob ] }
```

```yaml title="Usage example: classify with a saved model"
- compute_strain_functional: { rcut: 5.1 ang, sigma: 0.91 ang }
- sfd_gmm_classify: { model_file: gmm_model.yaml, min_probability: 0.9 }
```

The YAML model holds `features`, `center` and `scale` (standardization, 0 and 1 if unused), `weights`, `means` (one list per component) and `covariances` (one matrix per component), in the standardized feature space. Examples are given in `exaStamp/data/regression_new/analysis_particle/strain_functional/`, on a periodic FCC copper crystal with two twin planes, a stacking fault and 24 vacancies (`fcc_planar_defects.py`). With `select_by: dbi`, `sfd_gmm_planar_defects.msp` finds 2 classes: the bulk, and the atoms of the twin and stacking-fault planes and around the vacancies. `sfd_gmm_classify_from_file.msp` uses a 3-component model trained by the script, which separates bulk, planar defects and vacancy neighbors.

## **Grain segmentation**

Groups the crystalline atoms of a polycrystal into grains from the PTM orientations, and gives every atom a grain id. It runs in two passes, after `compute_ptm` and `ptm_fields`, and works with any number of MPI ranks (the grain ids are global).

1. `compute_grain_bond_misorientation` records, for every bond of an owned atom (at most 24 nearest bonds), the neighbor id, the bond length and, when both atoms have the same cubic or hexagonal structure, their disorientation $\theta$: the smallest misorientation angle over the symmetry group of the crystal (24 rotations for cubic, 12 for hexagonal). Bonds above `misorientation_threshold` are not candidates. GPU compatible.
2. `compute_grain_clusters` builds a graph whose nodes are the crystalline atoms and whose edges are the candidate bonds to their PTM template neighbors (12 FCC/HCP/ICO, 14 BCC, 6 SC), with weight $w = \exp(-\theta^2/3)$, $\theta$ in degrees. The graph is clustered hierarchically by Node-Pair-Sampling (T. Bonald et al., *Hierarchical graph clustering using node pair sampling*, MLG 2018): the two clusters $a$, $b$ that are mutual nearest neighbors for the distance $d(a,b) = w_a w_b / w(a,b)$, with $w_a$ the summed edge weight of $a$, are merged first. The resulting dendrogram is cut at a threshold chosen automatically: a robust fit of $\log d$ against the log of the merge size gives the trend of merges inside grains, and merges far above it are grain boundaries. Clusters smaller than `min_grain_atom_count` are dissolved. Atoms left without a grain (grain boundaries, defect cores, non-crystalline atoms) can then be adopted by the grain closest to them along the bond network (`orphan_adoption`). Last, the mean lattice orientation of each grain is computed from its clustered atoms: each atom orientation is replaced by its symmetry equivalent closest to the grain orientation before averaging.

With several MPI ranks, systems of up to `serial_max_atoms` atoms (default 2 million; rank 0 needs about 1 kB per atom) are clustered exactly: the candidate-bond graph is gathered on rank 0 and clustered there as a whole, so the grains do not depend on the number of ranks. Larger systems use a two-level scheme: each rank first clusters its own atoms into fragments of at most `fragment_max_atoms` atoms, the fragment graph, with the bonds across ranks, is clustered on rank 0, and the grain ids are sent back. The two-level scheme needs less memory on rank 0 but its result depends on the domain decomposition (a grain can be split when its pieces only touch across thin rank boundaries). Orphan adoption gives the same result for any number of ranks in both modes.

**Coherent interfaces.** Stacking faults and coherent twin planes in an FCC crystal are HCP layers. Without special treatment they form their own HCP grains, and a stacking fault that crosses a whole grain cuts it in two FCC grains with the same orientation. With `handle_coherent_interfaces` (default), the bonds between an HCP atom and its FCC template neighbors are checked for coherence: the HCP orientation is mapped onto the two FCC orientations that share its close-packed plane, and the bond is coherent when one of them is within `misorientation_threshold` of the FCC atom. After the dendrogram cut, each HCP grain with coherent bonds joins the FCC grains next to it:

- FCC grains with matching mean orientations (within `misorientation_threshold`), such as the two sides of a stacking fault, are merged together with the HCP grain: the stacking fault belongs to the grain;
- FCC grains in twin orientation (60° about $\langle 111 \rangle$) are not merged: the HCP plane joins the side with the most coherent bonds (ties: the side holding the smallest atom id), and the twin boundary stays a grain boundary.

HCP layers smaller than `min_grain_atom_count` are not grains and are handled by orphan adoption. Only hexagonal-into-cubic interfaces are handled: FCC layers in an HCP crystal stay separate grains. Merged grains are reported as FCC in the per-grain table, and their mean orientation is that of their FCC atoms.

!!! note
    OVITO's grain segmentation splits a twin plane atom by atom between the two twins; here the whole HCP plane goes to one side.

### `compute_grain_bond_misorientation`

```{ .yaml title="Parameters" .params-block }
rcut:                      float, required                    # Neighbor cutoff, at least the rcut of compute_ptm.
misorientation_threshold:  float, default 4.0                 # Largest disorientation (degrees) of a candidate bond.
struct_field:              string, default "ptm_type"         # PTM structure-type field (from ptm_fields).
orient_field:              string, default "ptm_orientation"  # PTM orientation field (from ptm_fields).
```

The PTM fields of the ghost particles must be up to date: call `ghost_update_opt: { opt_fields: [ ptm_type, ptm_orientation ] }` before.

### `compute_grain_clusters`

```{ .yaml title="Parameters" .params-block }
auto_threshold:        bool, default true             # Choose the merge threshold automatically.
manual_threshold_log:  float, default 0.0             # Merge threshold when auto_threshold is false: log of the clustering distance d (not an angle).
min_grain_atom_count:  int, default 100               # Smaller clusters are not grains.
orphan_adoption:       bool, default true             # Give atoms with no grain the grain of the closest grain atom along the bonds.
serial_max_atoms:      int, default 2000000           # Up to this many atoms, exact clustering of the whole graph on rank 0 (same result for any number of ranks); above it, two-level clustering.
fragment_max_atoms:    int, default 1000              # Largest fragment of the two-level clustering. Smaller: closer to the exact result; larger: fewer fragments gathered on rank 0.
handle_coherent_interfaces: bool, default true        # Merge HCP stacking faults and twin planes into the adjacent FCC grains (see above).
misorientation_threshold:   float, default 4.0        # Largest disorientation (degrees) of a coherent FCC-HCP bond, and of two FCC grains merged through a stacking fault.
color_seed:            int, default 1                 # Seed of the random grain colors.
struct_field:          string, default "ptm_type"         # PTM structure-type field.
orient_field:          string, default "ptm_orientation"  # PTM orientation field, for the mean grain orientations.
grain_id_field:        string, default "grain_id"         # Output grain id (0, 1, ... by decreasing size; -1 = no grain).
grain_color_field:     string, default "grain_color"      # Output RGB color of the grain (Vec3d, gray for no grain).
grains_file:           string, default ""                 # CSV file with one line per grain and per call, written by rank 0. Empty: no file.
```

Grain ids are sorted by decreasing number of atoms, adopted orphans included (ties: smallest atom id), so they do not depend on the number of MPI ranks. Both per-atom fields are also written on the ghost particles. The number of grains is printed and available in the `n_grains` slot, and the per-grain table in the output slots below:

```{ .yaml title="Outputs" .params-block }
n_grains:           int                # Number of grains.
n_orphans_adopted:  int                # Number of adopted orphan atoms.
grain_atom_count:   list of ints       # Atoms of each grain, adopted orphans included, indexed by grain id.
grain_structure:    list of ints       # PTM structure type of each grain.
grain_orientation:  list of floats     # Mean lattice orientation of each grain: quaternion (w, x, y, z), 4 values per grain.
```

The `grains_file` CSV has the columns `timestep, grain_id, atoms, structure, qw, qx, qy, qz, r, g, b`. The file is started anew (header included) at the first call of a run, and each later call (e.g. at every snapshot) appends its table, so a whole run fits in one file:

```python
import pandas as pd
grains = pd.read_csv("grains.csv")
grains.groupby("timestep").size()   # number of grains at each timestep
```

 The orientation quaternion rotates the reference lattice of the PTM template onto the grain, and is given in the fundamental zone (the symmetry equivalent closest to the identity). It is computed for cubic (FCC, BCC, SC) and hexagonal (HCP) grains; ICO grains get the identity.

```yaml title="Usage example (exaStamp/data/regression_new/grains/compute_grain_segmentation.msp)"
chunk_neighbors:
  config:
    chunk_size: 1
    build_particle_offset: true

compute_ptm:
  rcut: 6.0 ang
  rmsd_cutoff: 0.5

ptm_fields:
  struct_field: ptm_type
  orient_field: ptm_orientation
  rmsd_field: ptm_rmsd

compute_grain_bond_misorientation:
  rcut: 6.0 ang

compute_grain_clusters:
  min_grain_atom_count: 100
  orphan_adoption: true
  grains_file: grains.csv

simulation_epilog:
  - remove_close_particles: { distance: 1.5 ang, seed: 42 }
  - parallel_update_particles   # rebuild ghosts and neighbor lists after the removal
  - compute_ptm
  - ptm_fields
  - ghost_update_opt: { opt_fields: [ ptm_type, ptm_orientation ] }
  - compute_grain_bond_misorientation
  - compute_grain_clusters
  - timestep_file: "result_polycrystal_large.xyz"
  - write_xyz: { fields: [ id, type, ptm_type, grain_id ] }
```

The input polycrystal of this example is built with [Atomsk](https://atomsk.univ-lille.fr/) (24 random Ta grains in a 200 Å box, about 445k atoms); the commands are given at the top of the `.msp` file. Atomsk leaves overlapping atom pairs at the grain boundaries, which `remove_close_particles` deletes before the analysis.

A second example, `compute_grain_segmentation_twins.msp` in the same folder, checks the coherent interfaces: two Cu twins along [111] with an intrinsic stacking fault in one of them (7896 atoms, written by `fcc_twins_stacking_faults.py`). It finds 2 grains, the two twins at 60° about $\langle 111 \rangle$, and 6 grains (three FCC slabs and three HCP planes) with `handle_coherent_interfaces: false`.

## **Delaunay tessellation**

!!! warning "Optional plugin"
    `compute_delaunay` and `write_delaunay_vtk` are in the `exaStampDelaunay` plugin, built only when [Geogram](https://github.com/BrunoLevy/geogram) is found. Add `-DGEOGRAM_INSTALL_PREFIX=<geogram install prefix>` to the exaStamp `cmake` command; the CMake output says `Geogram found` or `exaStampDelaunay plugin disabled`.

### `compute_delaunay`

Computes the 3D Delaunay tessellation of the owned and ghost particles of each rank. A tetrahedron is kept only if its centroid lies in a cell owned by the rank, so the pieces of all ranks fit together with no gaps or duplicates, and the unreliable tetrahedra at the edge of the ghost layer are dropped. The ghost layer must be thick enough to contain the tetrahedra of the owned cells (`rcut_max` of a few interatomic distances).

```{ .yaml title="Parameters" .params-block }
keep_ghost_tets:  bool, default false   # Also keep the tetrahedra whose centroid lies in a ghost cell (they overlap with the neighbor ranks).
```

### `write_delaunay_vtk`

Writes the tessellation as VTK unstructured grids: one `<filename>/piece<rank>.vtu` file per rank and a `<filename>.pvtu` master file (the one to open in ParaView).

```{ .yaml title="Parameters" .params-block }
filename:      string, default "delaunay"   # Output name, without extension (timestep_file sets it).
color_fields:  list of strings, default []  # Per-particle scalar fields averaged over each tetrahedron, one CellData array each.
```

For exact `color_fields` values at the rank boundaries, update the ghosts of these fields first (`ghost_update_opt`).

```yaml title="Usage example (exaStamp/data/regression_new/delaunay/compute_delaunay.msp)"
write_snapshot:
  - compute_delaunay
  - timestep_file: "paraview/delaunay_%09d"
  - write_delaunay_vtk
```

```yaml title="Usage example with fields"
- compute_ptm: { rcut: 3.6 ang }
- ptm_fields: {}
- compute_delaunay: {}
- write_delaunay_vtk: { filename: "paraview/delaunay", color_fields: [ ptm_type, ptm_rmsd ] }
```

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

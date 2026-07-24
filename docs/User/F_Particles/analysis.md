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

## **Local per-atom metrics**

Four operators compute or gather per-particle diagnostic values into separate output structures (`local_data`, `local_mechanical_data`, `local_structural_data`) rather than mutating particle fields directly. Downstream consumers — [`write_xyz_file`](output.md#write_xyz_file) (via `per_atom_data`), `mechanical_write_paraview`, `mechanical_cell_projection` — read from these structures by field name.

### `compute_local_metrics`

```{ .yaml title="Syntax" .syntax-block }
compute_local_metrics:
  is_ghosts: <bool>
  per_atom_data: [<string>, ...]
```

```{ .yaml title="Parameters" .params-block }
is_ghosts:      bool, default false        # Also gather values for ghost particles.
per_atom_data:  list of strings, required  # Which existing fields to gather — see table below.
```

This operator doesn't compute anything new — it's a field **collector**: it copies already-existing per-particle fields (only if they exist on the grid) into a `local_data` output structure.

| `per_atom_data` value | Field gathered | Type |
|---|---|---|
| `"pe"` | potential energy | float |
| `"f"` | force | Vec3d |
| `"v"` | velocity | Vec3d |
| `"q"` | charge | float |
| `"virial"` | virial tensor | Mat3d |
| `"id"` | particle id | int |
| `"type"` | particle type | int |

!!! warning

    [`write_xyz_file`](output.md#write_xyz_file) only knows how to print `"pe"`, `"f"` and `"v"` from this structure — `"q"`, `"virial"`, `"id"`, `"type"` are gathered here but silently dropped (no column written) if listed in `write_xyz_file`'s own `per_atom_data`.

### `compute_local_mechanical_metrics`

```{ .yaml title="Syntax" .syntax-block }
compute_local_mechanical_metrics:
  is_ghosts: <bool>
  use_filtered_positions: <bool>
  compute_static_measures: <bool>
  compute_dynamic_measures: <bool>
  perform_dislocation_analysis: <bool>
  weight_function: <calc_weight_or_wendland>
  rcut_localdef: <float>
  grid_t0: <grid>
  xform_t0: <Mat3d>
```

```{ .yaml title="Parameters" .params-block }
is_ghosts:                     bool, default false           # Also compute for ghost particles.
use_filtered_positions:        bool, default false            # Use rxf/ryf/rzf (from positions_filtering) instead of raw rx/ry/rz.
compute_static_measures:       bool, default true              # Compute deformation gradient, strain, rotation, stretch, microrotation, slip.
compute_dynamic_measures:      bool, default false             # Also compute velocity gradient and vorticity (needs compute_static_measures too).
perform_dislocation_analysis:  bool, default false             # Also compute a dislocation-character analysis from the microrotation field.
weight_function:               string, default "calc_weight"   # Neighbor-weighting kernel: "calc_weight" (cubic spline) or "wendland" (Wendland-C2).
rcut_localdef:                 float, required                 # Cutoff radius for the local least-squares deformation-gradient fit.
grid_t0:                       grid, required for static measures  # Reference-configuration grid (t=0 positions).
xform_t0:                      Mat3d, optional                 # Reference-configuration box transform.
```

Computes continuum-mechanics local measures per particle from a least-squares fit of neighbor displacements between the current configuration and a reference (`grid_t0`) one, within `rcut_localdef`:

| Output field | Meaning |
|---|---|
| `defgrad` (F) | Deformation gradient tensor |
| `greenlag` (E) | Green-Lagrange strain, $E = \frac{1}{2}(F^TF - I)$ |
| `rot` (R) | Rotation tensor (polar decomposition F = RU) |
| `stretch` (U) | Stretch tensor |
| `microrot` | Microrotation vector (axial vector of the skew part of R) |
| `slip` | Slip vector (average non-affine relative displacement) |
| `burgerpar` / `burgerortho` / `glide` | Local slip-plane orthonormal tripod ($\mathbf{l}$, $\mathbf{m}$, $\mathbf{n}$) |
| `velgrad` (L) *(if `compute_dynamic_measures`)* | Velocity gradient tensor |
| `vort` (φ) *(if `compute_dynamic_measures`)* | Vorticity vector |
| `dislo`/`vis`/`coin`/`dislol`/`dislolo` *(if `perform_dislocation_analysis`)* | Dislocation indicator, screw/edge character components, and dislocation-line direction/normal |

None of these ever mutate the particle's own position/velocity/force — everything lands in the separate `local_mechanical_data` structure.

!!! note

    `compute_dynamic_measures` only takes effect when `compute_static_measures` is also true (the code gates on both).

### `compute_local_structural_metrics`

```{ .yaml title="Syntax" .syntax-block }
compute_local_structural_metrics:
  ghost: <bool>
  per_atom_data: [<string>, ...]
  rcut_bispectrum: <float>
  nnn_bispectrum: <int>
  jmax_bispectrum: <float>
  closest_bispectrum: <bool>
```

```{ .yaml title="Parameters" .params-block }
ghost:               bool, default false            # Also compute for ghost particles.
per_atom_data:       list of strings, required       # "bispectrum" is implemented — see warning below.
rcut_bispectrum:     float, default 0.               # Fixed cutoff radius, used when closest_bispectrum is false.
nnn_bispectrum:      int, default 48                 # Target neighbor count for the adaptive cutoff.
jmax_bispectrum:     float, default 3                # SNAP 2·jmax bandwidth parameter.
closest_bispectrum:  bool, default true              # Use the nnn_bispectrum-th closest neighbor's distance (+0.01) as the cutoff instead of a fixed one.
```

If `"bispectrum"` is listed in `per_atom_data`, computes per-particle SNAP-legacy bispectrum components (a structural descriptor used for ML classification, e.g. by [`supervised_learning_classifier`](#supervised_learning_classifier) below) and writes them to the `bispectrum` field.

!!! warning "Steinhardt parameters are not implemented"

    `rcut_steinhardt`/`nnn_steinhardt`/`degree_steinhardt` are real slots (defaults `0.`/`12`/`[5,4,6,8,10,12]`), and `"steinhardt"` is accepted in `per_atom_data`, but requesting it does nothing except log `"Steinhardt parameters not yet implemented (ongoing: Paul Lafourcade)"` — no Steinhardt bond-order values are actually computed.

### `supervised_learning_classifier`

```{ .yaml title="Syntax" .syntax-block }
supervised_learning_classifier:
  lda_scalings: <...>
  overall_mean: <...>
  decision: <...>
  biais: <...>
  mean_bcc: <...>
  mean_fcc: <...>
  mean_hcp: <...>
  mean_sc: <...>
  cova_bcc: <...>
  cova_fcc: <...>
  cova_hcp: <...>
  cova_sc: <...>
  distance: <...>
```

Classifies each particle's local crystal structure (BCC / FCC / HCP / SC / other) from the bispectrum descriptors computed by [`compute_local_structural_metrics`](#compute_local_structural_metrics): a fixed Linear Discriminant Analysis (`lda_scalings`, `overall_mean`, `decision`, `biais`) reduces the bispectrum to a 3-component score and a softmax over the 4 crystal classes, then a per-class Mahalanobis-distance test (`mean_*`/`cova_*`/`distance`) confirms or falls back to "other". Writes the result as an integer `crystal` field.

!!! note "Parameters are a pre-trained model, not simulation-tunable"

    All parameters above are required model coefficients from an offline-trained LDA/Mahalanobis classifier, not physical quantities you'd normally set by hand — their exact shapes/types need follow-up verification before a full parameter table can be written here.

## **Not yet found in current source**

!!! warning "Placeholder — unconfirmed against current code"

    `compute_local_entropy` and `compute_local_centrosymmetry` are referenced by older documentation but do not exist anywhere in the current `exaNBody`/`exaStamp`/`onika` checkout (confirmed by exhaustive grep across all three repos). The syntax below reflects what the old documentation *claimed* — it has not been verified against real source and may be stale, renamed, or simply gone. Treat as a placeholder until confirmed.

### `compute_local_entropy` (unverified)

```{ .yaml title="Syntax (unverified)" .syntax-block }
compute_local_entropy:
  rcut: <float>
  sigma: <float>
  local: <bool>
  nbins: <int>
```

### `compute_local_centrosymmetry` (unverified)

```{ .yaml title="Syntax (unverified)" .syntax-block }
compute_local_centrosymmetry:
  rcut: <float>
  nnn: <int>
```

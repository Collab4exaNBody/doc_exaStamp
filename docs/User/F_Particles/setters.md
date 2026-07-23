---
icon: material/tune
---

# Setters

Operators that set or modify per-particle field values after particles already exist — velocities, forces, positions, noise, temperature, orientation. See [Input](input.md) for creating particles in the first place, and [Analysis](analysis.md) for read-only diagnostics.

## Shifting, scaling and setting a vector field

Six operators share the same generic shape, differing only in which field they touch and what they do to it:

| Operator | Field | Operation |
|---|---|---|
| `shift_r` | position | add `value` |
| `shift_v` | velocity | add `value` |
| `scale_r` | position | multiply (component-wise) by `value` |
| `scale_v` | velocity | multiply (component-wise) by `value` |
| `set_velocity` | velocity | overwrite with `value` |
| `set_force` | force | overwrite with `value` |

| Property | Description | Data Type | Default |
|---|---|---|---|
| `value` | The constant vector — a single scalar is also accepted and broadcast to all 3 components. | Vec3d or float | `[0,0,0]` |
| `region` | Restrict to a geometric region (needs a `particle_regions` block defined earlier — see [Spatial Regions](../D_DomainRegions/regions.md)). | string | *(none)* |

```yaml
shift_v: [ 0. ang/ps, 0. ang/ps, -50. ang/ps ]   # give the whole system a downward velocity kick
set_force: 0.                                    # zero out forces everywhere (scalar shorthand -> [0,0,0])
scale_v:
  value: [ 1.1, 1.1, 1.1 ]
  region: HOTSPOT
```

## Type-scaled setter

`divide_force_by_type_scalar` divides each particle's force vector by a per-type scalar property — this is literally how acceleration (F/m) is computed internally, using `mass`.

| Property | Description | Data Type | Default |
|---|---|---|---|
| `property` | Name of the per-type scalar property to divide by. | string | *(required)* |
| `region` | Restrict to a geometric region. | string | *(none)* |

```yaml
divide_force_by_type_scalar: mass

divide_force_by_type_scalar:
  region: REGION1
  property: mass
```

## Random noise

`gaussian_noise_r`/`_v`/`_f` and `uniform_noise_r`/`_v`/`_f` add random noise to position, velocity, or force respectively — gaussian (mean `0`, standard deviation `sigma`) or uniform (in `[-sigma, +sigma]` — note `sigma` here is a half-range, not a standard deviation). Both families share:

| Property | Description | Data Type | Default |
|---|---|---|---|
| `sigma` | Gaussian standard deviation, or uniform half-range. | float | `1.0` |
| `sigma_cut` | *(gaussian only)* Clips `|noise|` to this cutoff — turns the distribution into a **truncated** gaussian, not a clean one. | float | *(none)* |
| `ghost` | Also apply to ghost particles. | bool | `false` |
| `deterministic_noise` | Seed deterministically per grid cell, for reproducible runs regardless of the MPI/OpenMP decomposition. | bool | `false` |
| `region` | Restrict to a geometric region. | string | *(none)* |
| `grid_cell_mask_name` / `grid_cell_mask_value` | Restrict to a [grid mask](../D_DomainRegions/regions.md#grid-mask-defined-regions) (exact equality, as elsewhere). | string / float | *(none)* |

```yaml
gaussian_noise_r: { sigma: 0.2 ang, sigma_cut: 0.3 ang }
gaussian_noise_v: { sigma: 50. ang/ps, region: SPHERE }
uniform_noise_v: { sigma: 50. ang/ps, grid_cell_mask_name: MYMASK, grid_cell_mask_value: 1. }
```

## Initializing temperature and orientation

- **`init_temperature_new`** — the modern, general way to draw an initial Maxwell-Boltzmann velocity distribution at a target temperature. See [Simulation Starter Pack → Input Data](../C_StarterPack/4_setup_system.md#generating-a-crystal-lattice) for a full walkthrough.
- **`init_temperature`** — an older, simpler variant, restricted to a single species (`atom_type`) and/or a `region`.
- **`init_temperature_rigidmol`** — draws both linear *and* angular (rotational) velocities at a target temperature. Use this instead of `init_temperature_new` for rigid-molecule systems, which have rotational degrees of freedom `init_temperature_new` doesn't set.
- **`random_orient`** — randomly reorients rigid molecules (their quaternion), independently of temperature initialization.

## Mechanics-specific: filtered position

`positions_filtering` maintains an exponentially-smoothed copy of each particle's position — the `rxf`/`ryf`/`rzf` "Filtered Position" field used by the `full_mechanics`/`multimat_mechanics` grid flavors (see [Grids Features](../E_Grids/flavors.md)).

| Property | Description | Data Type | Default |
|---|---|---|---|
| `alpha` | Smoothing rate of the exponential filter. | float | `0.01` |
| `dt` | Simulation timestep. | float | *(required)* |

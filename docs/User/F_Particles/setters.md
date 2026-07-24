---
icon: material/tune
---

# **Setters**

Operators that set or modify per-particle field values after particles already exist — velocities, forces, positions, noise, temperature, orientation. See [Input](input.md) for creating particles in the first place, and [Analysis](analysis.md) for read-only diagnostics.

## **Shifting, scaling and setting a vector field**

Six operators share the same generic shape, differing only in which field they touch and what they do to it:

| Operator | Field | Operation |
|---|---|---|
| `shift_r` | position | add `value` |
| `shift_v` | velocity | add `value` |
| `scale_r` | position | multiply (component-wise) by `value` |
| `scale_v` | velocity | multiply (component-wise) by `value` |
| `set_velocity` | velocity | overwrite with `value` |
| `set_force` | force | overwrite with `value` |

```{ .yaml title="Syntax" .syntax-block }
shift_r:                     # or shift_v / scale_r / scale_v / set_velocity / set_force
  value: <Vec3d_or_float>
  region: <string>
```

```{ .yaml title="Parameters" .params-block }
value:   Vec3d or float, default [0,0,0]  # The constant vector — a single scalar is also accepted (see note below) and broadcast to all 3 components.
region:  string, optional                 # Region name or boolean expression of regions declared in `particle_regions`.
```

A bare scalar for `value` is parsed as a physical quantity, not just a unitless number — `shift_r: 1.5 ang` is valid and broadcasts to `[1.5 ang, 1.5 ang, 1.5 ang]`.

```yaml title="Usage example"
shift_v: [ 0. ang/ps, 0. ang/ps, -50. ang/ps ]   # give the whole system a downward velocity kick
set_force: 0.                                    # zero out forces everywhere (scalar shorthand -> [0,0,0])
scale_v:
  value: [ 1.1, 1.1, 1.1 ]
  region: HOTSPOT
```

## **Type-scaled setter**

```{ .yaml title="Syntax" .syntax-block }
divide_force_by_type_scalar:
  property: <string>
  region: <string>
```

```{ .yaml title="Parameters" .params-block }
property:  string, required  # Name of the per-type scalar property to divide by — looked up in `particle_type_properties`.
region:    string, optional  # Restrict to a geometric region.
```

`divide_force_by_type_scalar` divides each particle's force vector by a per-type scalar property — this is literally how acceleration (F/m) is computed internally, using `mass`. `property` must already exist in `particle_type_properties` (populated by `species`, `particle_types`, or `particle_type_add_properties`) — the operator aborts if it isn't found there.

```yaml title="Usage example"
divide_force_by_type_scalar: mass

divide_force_by_type_scalar:
  region: REGION1
  property: mass
```

## **Random noise**

```{ .yaml title="Syntax" .syntax-block }
gaussian_noise_r:                  # or _v / _f / uniform_noise_r / _v / _f
  sigma: <float>
  sigma_cut: <float>
  ghost: <bool>
  deterministic_noise: <bool>
  region: <string>
  grid_cell_mask_name: <string>
  grid_cell_mask_value: <float>
```

```{ .yaml title="Parameters" .params-block }
sigma:                 float, default 1.0  # Gaussian standard deviation, or uniform half-range.
sigma_cut:             float, optional     # (gaussian only) Clips |noise| to this cutoff — a truncated gaussian, not a clean one.
ghost:                 bool, default false # Also apply to ghost particles.
deterministic_noise:   bool, default false # Seed deterministically per grid cell, independent of the MPI/OpenMP decomposition.
region:                string, optional    # Restrict to a geometric region.
grid_cell_mask_name:   string, optional    # Restrict to a grid mask (exact equality, as elsewhere).
grid_cell_mask_value:  float, optional     # Value grid_cell_mask_name must exactly equal.
```

`gaussian_noise_r`/`_v`/`_f` and `uniform_noise_r`/`_v`/`_f` add random noise to position, velocity, or force respectively — gaussian (mean `0`, standard deviation `sigma`) or uniform (in `[-sigma, +sigma]` — note `sigma` here is a half-range, not a standard deviation).

```yaml title="Usage example"
gaussian_noise_r: { sigma: 0.2 ang, sigma_cut: 0.3 ang }
gaussian_noise_v: { sigma: 50. ang/ps, region: SPHERE }
uniform_noise_v: { sigma: 50. ang/ps, grid_cell_mask_name: MYMASK, grid_cell_mask_value: 1. }
```

## **Initializing temperature and orientation**

### `init_temperature_new`

```{ .yaml title="Syntax" .syntax-block }
init_temperature_new:
  T: <float>
  override_velocities: <bool>
  add_velocities: <bool>
  scale_velocities: <bool>
  zero_linear_momentum: <bool>
  distribution: <gaussian_or_uniform>
  deterministic_noise: <bool>
  region: <string>
  atom_type: <string>
```

```{ .yaml title="Parameters" .params-block }
T:                     float, default 300.0 K    # Target temperature. A bare scalar is accepted as shorthand for T.
override_velocities:   bool, default true        # Draw fresh velocities, then rescale the selected population to hit T exactly.
add_velocities:        bool, default false       # Draw velocity increments and add them to existing velocities (no rescale/momentum-zeroing pass).
scale_velocities:      bool, default false       # Skip the random draw; just rescale existing velocities to hit T.
zero_linear_momentum:  bool, default true        # Remove net center-of-mass momentum before rescaling. Only applies in override_velocities mode.
distribution:          string, default "gaussian" # "gaussian" or "uniform" velocity draw.
deterministic_noise:   bool, default false       # Deterministic seed, independent of the MPI/OpenMP decomposition.
region:                string, optional          # Restrict to a geometric region.
atom_type:             string, optional          # Restrict to one named species; falls back to all atoms (with a warning) if the name isn't found.
```

The modern, general way to draw an initial Maxwell-Boltzmann velocity distribution at a target temperature. Exactly one of `override_velocities`/`add_velocities`/`scale_velocities` may be true — `add_velocities` and `scale_velocities` both skip the momentum-zeroing step even if `zero_linear_momentum` is set; only `override_velocities` applies it. See [Simulation Starter Pack → Input Data](../../Beginner/StarterPack/4_setup_system.md#generating-a-crystal-lattice) for a full walkthrough.

```yaml title="Usage example"
init_temperature_new: 300. K
```

### `init_temperature`

```{ .yaml title="Syntax" .syntax-block }
init_temperature:
  T: <float>
  generate_velocity: <bool>
  deterministic_noise: <bool>
  region: <string>
  atom_type: <string>
```

```{ .yaml title="Parameters" .params-block }
T:                    float, default 300.0 K  # Target temperature.
generate_velocity:    bool, default false     # Draw fresh gaussian velocities before rescaling (otherwise just rescales existing velocities).
deterministic_noise:  bool, default false     # Deterministic seed, independent of the MPI/OpenMP decomposition.
region:               string, optional        # Restrict to a geometric region.
atom_type:            string, optional        # Restrict to one named species.
```

An older, simpler variant of `init_temperature_new`, restricted to a single species (`atom_type`) and/or a `region`. Momentum removal and rescaling are unconditional here — there's no equivalent of `zero_linear_momentum` or a mode toggle.

!!! warning "Known issue: momentum removal looks dimensionally wrong"

    The center-of-mass momentum subtraction multiplies the already-computed CM *velocity* shift by particle mass a second time (`vx[j] -= momentum_shift.x * pmass`, where `momentum_shift` is already `momentum / total_mass`) — `init_temperature_new`'s equivalent step has no such extra mass factor. This looks like a real inconsistency between the two operators rather than an intentional difference. Prefer `init_temperature_new` when precise momentum control matters.

### `init_temperature_rigidmol`

```{ .yaml title="Syntax" .syntax-block }
init_temperature_rigidmol:
  T: <float>
  deterministic_noise: <bool>
```

```{ .yaml title="Parameters" .params-block }
T:                    float, required     # Target temperature. No scalar shorthand — must be given as `T: ...`.
deterministic_noise:  bool, default false # Deterministic seed, independent of the MPI/OpenMP decomposition.
```

Draws both linear *and* angular (rotational) velocities at a target temperature — use this instead of `init_temperature_new` for rigid-molecule systems, which have rotational degrees of freedom the latter doesn't set. Applies unconditionally to every particle: there's no `region`/`atom_type` restriction, and it always overwrites rather than adding to existing velocities. Net linear and angular momentum are removed, then both are rescaled independently so the measured translational and rotational temperatures match `T`.

### `random_orient`

```{ .yaml title="Syntax" .syntax-block }
random_orient:
  deterministic_noise: <bool>
```

```{ .yaml title="Parameters" .params-block }
deterministic_noise:  bool, default false  # Deterministic seed, independent of the MPI/OpenMP decomposition.
```

Randomly reorients every particle's quaternion (`orient`), independently of temperature initialization — no region/species restriction, applies to the whole grid.

!!! warning "Known issue: not actually a uniform distribution"

    Despite the name, the underlying draw uses `std::normal_distribution<double>(-1., 1.)` per quaternion component — those constructor arguments are *(mean, standard deviation)*, not *(min, max)* — so this is a Gaussian centered at −1 with stddev 1, not a uniform draw. After normalizing to a unit quaternion, the resulting orientations are **not** uniformly distributed over SO(3). Worth knowing if you rely on this for an unbiased random-orientation ensemble.

## **Mechanics-specific: filtered position**

```{ .yaml title="Syntax" .syntax-block }
positions_filtering:
  alpha: <float>
  dt: <float>
  timestep: <int>
  time_start: <float>
```

```{ .yaml title="Parameters" .params-block }
alpha:       float, default 0.01  # Filter weight given to the new sample each step (higher = faster response).
dt:          float, required      # Simulation timestep.
timestep:    int, required        # Current step index — curtime = dt * timestep.
time_start:  float, required      # Simulation time before which the filtered position is just initialized to the raw position, not yet averaged.
```

`positions_filtering` maintains a smoothed copy of each particle's position — the `rxf`/`ryf`/`rzf` "Filtered Position" field used by the `full_mechanics` grid flavor (see [Grids Features](../E_Grids/flavors.md#per-particle-fields-by-flavor)). It isn't a simple linear low-pass filter: each axis is mapped onto a circular angle scaled to the domain's extent, and the new/previous filtered angles are combined as a weighted **circular mean** (`alpha` weight on the new sample) before being mapped back to a position — this avoids the discontinuity a plain linear average would produce when a particle crosses a periodic boundary.

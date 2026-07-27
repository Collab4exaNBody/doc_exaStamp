---
icon: material/wall
---

# **Repulsive Walls**

Three repulsive-wall operators confine or impact the system with a planar, cylindrical, or spherical barrier. All three share the same repulsive power-law form and are fed into force computation like any other potential, via `compute_force`. Each has a companion `move_*` operator that computes the wall's time-varying position/size — this is what gives a "piston" its motion.

!!! tip "Repulsive wall equations"

    For a particle at signed distance $d$ from the wall geometry (plane/cylinder axis/sphere center), with $|d| \le$ `cutoff`, the energy contribution is:

    $$
    E_p \mathrel{+}= \varepsilon \left(1 - \frac{\text{cutoff}}{d}\right)^{\text{exponent}}
    $$

    and the resulting force:

    $$
    \mathbf{f} = -\varepsilon \cdot \text{exponent} \cdot \frac{\text{cutoff}}{d^2} \left(1 - \frac{\text{cutoff}}{d}\right)^{\text{exponent}-1} \hat{\mathbf{n}}
    $$

Particles just inside the wall are pushed further inward, particles just outside are pushed further outward — a thin repulsive shell/membrane, not a one-sided barrier.

## **Planar Wall**

### `plane_wall`

```{ .yaml title="Syntax" .syntax-block }
plane_wall:
  normal: <Vec3d>
  offset: <float>
  cutoff: <float>
  exponent: <int>
  epsilon: <float>
```

```{ .yaml title="Parameters" .params-block }
normal:    Vec3d, default [1,0,0]     # Unit normal of the plane.
offset:    float, default 0.0         # Signed distance of the plane from the origin along normal.
cutoff:    float, required            # Interaction range from the plane.
exponent:  int, default 12            # Power-law exponent.
epsilon:   float, default 1.0e-19 J   # Energy scale.
```

Typically fed by `move_plane_wall` rather than set directly, so the wall can move over time.

```yaml title="Usage example"
left_wall:
  - plane_wall: { normal: [1.0,0.0,0.0], offset: 17.0 ang, cutoff: 2.2 ang, epsilon: 1.0e-19 J }
right_wall:
  - plane_wall: { normal: [-1.0,0.0,0.0], offset: -83.0 ang, cutoff: 2.2 ang, epsilon: 1.0e-19 J }

+compute_force: [ left_wall, right_wall ]
```

### `move_plane_wall`

```{ .yaml title="Syntax" .syntax-block }
move_plane_wall:
  init_normal: <Vec3d>
  init_offset: <float>
  init_cutoff: <float>
  init_epsilon: <float>
  init_exponent: <int>
  init_time: <float>
  init_velocity: <float>
  final_time: <float>
  final_velocity: <float>
  times: [<float>, ...]
  velocities: [<float>, ...]
  velocity_profile: <step_or_linear>
  freeze_at_end: <bool>
  csv_filename: <string>
  csv_separator: <string>
  csv_append: <bool>
```

```{ .yaml title="Parameters" .params-block }
init_normal:       Vec3d, default [1,0,0]   # Unit normal of the plane.
init_offset:       float, default 0.0       # Initial signed offset.
init_cutoff:       float, required          # Interaction range.
init_epsilon:      float, required          # Energy scale.
init_exponent:     int, default 12          # Power-law exponent.
init_time:         float, see note          # Time at which the wall starts moving.
init_velocity:     float, see note          # Wall speed along normal, from init_time.
final_time:        float, optional          # Time at which the ramp to final_velocity completes; also when motion freezes and epsilon is forced to 0.
final_velocity:    float, optional          # Speed after final_time (constant acceleration between init_time and final_time); defaults to init_velocity. Requires final_time.
times:             list of floats, see note  # Waypoint times for multi-shock (reshock) loading — alternative to init_time/final_time/final_velocity.
velocities:        list of floats, see note  # Wall speed at each waypoint in times — same length as times.
velocity_profile:  string, default "step"    # "step": velocity jumps to each waypoint's value and holds. "linear": velocity ramps continuously between waypoints.
freeze_at_end:     bool, default true        # true: motion and epsilon freeze once the last waypoint/final_time is reached. false: wall keeps moving at the last velocity forever.
csv_filename:      string, optional          # If set, rank 0 appends one row per call (time, position, velocity, acceleration) to this file.
csv_separator:     string, default ","       # Field separator used in the CSV output.
csv_append:        bool, default false       # Append to an existing csv_filename instead of truncating it.
```

Two mutually exclusive ways to drive the wall: `init_time`+`init_velocity` (+ optional `final_time`/`final_velocity`) for a single ramp, or `times`+`velocities` (at least 2 strictly-increasing waypoints) for multi-shock/reshock loading — the two forms cannot be combined. Before motion starts, `offset` stays at `init_offset`; once frozen (`final_time` reached, or the last waypoint reached with `freeze_at_end: true`), `epsilon` is forced to `0`, so the wall it feeds is effectively removed.

```yaml title="Usage example"
left_wall:
  - move_plane_wall:
      init_normal: [1.0, 0.0, 0.0]
      init_offset: 0.0
      init_cutoff: 5.0 ang
      init_epsilon: 1.0e-19 J
      init_time: 10.0 ps
      init_velocity: 0.01 ang/ps
      final_time: 50.0 ps
      final_velocity: 0.05 ang/ps
      csv_filename: wall_trajectory.csv
  - plane_wall

+compute_force: [ left_wall ]
```

```yaml title="Usage example"
# multi-shock (reshock) loading
left_wall:
  - move_plane_wall:
      init_offset: 0.0
      init_cutoff: 5.0 ang
      init_epsilon: 1.0e-19 J
      times: [10.0 ps, 30.0 ps, 50.0 ps, 80.0 ps]
      velocities: [0.01 ang/ps, 0.03 ang/ps, 0.06 ang/ps, 0.0 ang/ps]
      velocity_profile: step
  - plane_wall

+compute_force: [ left_wall ]
```

## **Cylindrical Wall**

### `cylinder_wall`

```{ .yaml title="Syntax" .syntax-block }
cylinder_wall:
  origin: <Vec3d>
  axis: <Vec3d>
  radius: <float>
  cutoff: <float>
  exponent: <int>
  epsilon: <float>
```

```{ .yaml title="Parameters" .params-block }
origin:    Vec3d, default [0,0,0]     # Any point on the cylinder's axis.
axis:      Vec3d, default [0,0,1]     # Cylinder axis direction — must be a unit vector.
radius:    float, required            # Cylinder radius.
cutoff:    float, required            # Interaction range from the cylinder surface.
exponent:  int, default 12            # Power-law exponent.
epsilon:   float, default 1.0e-19 J   # Energy scale.
```

The cylinder is infinite along `axis` (unbounded ends). Typically fed by `move_cylinder_wall` rather than set directly.

```yaml title="Usage example"
confinement_wall:
  - cylinder_wall: { origin: [0.0,26.4,26.4] ang, axis: [1.0,0.0,0.0], radius: 20.0 ang, cutoff: 2.2 ang, epsilon: 1.0e-19 J }

+compute_force: [ confinement_wall ]
```

### `move_cylinder_wall`

```{ .yaml title="Syntax" .syntax-block }
move_cylinder_wall:
  init_origin: <Vec3d>
  init_axis: <Vec3d>
  init_radius: <float>
  init_cutoff: <float>
  init_epsilon: <float>
  init_exponent: <int>
  init_time: <float>
  init_velocity: <float>
  direction: <Vec3d>
  init_translation_velocity: <float>
  final_time: <float>
  final_velocity: <float>
  final_translation_velocity: <float>
  csv_filename: <string>
  csv_separator: <string>
  csv_append: <bool>
```

```{ .yaml title="Parameters" .params-block }
init_origin:                  Vec3d, default [0,0,0]   # Initial point on the cylinder's axis.
init_axis:                    Vec3d, default [0,0,1]   # Cylinder axis direction — passed through unchanged, it only orients the cylinder and never moves.
init_radius:                  float, required           # Initial radius.
init_cutoff:                  float, required           # Interaction range.
init_epsilon:                 float, required           # Energy scale.
init_exponent:                int, default 12           # Power-law exponent.
init_time:                    float, required           # Time at which the wall starts changing.
init_velocity:                float, default 0.0        # Radius growth rate, from init_time (negative = converging/imploding cylinder).
direction:                    Vec3d, default [0,0,0]    # Unit vector for optional origin translation, independent of axis.
init_translation_velocity:    float, default 0.0        # Translation speed of origin along direction.
final_time:                   float, optional           # Time the ramp(s) to the final_* values complete; also when motion freezes and epsilon is forced to 0.
final_velocity:                float, optional           # Radius growth rate after final_time; defaults to init_velocity. Requires final_time.
final_translation_velocity:   float, optional            # Translation speed after final_time; defaults to init_translation_velocity. Requires final_time.
csv_filename:                  string, optional          # If set, rank 0 appends one row per call (time, radius, radius_velocity, radius_acceleration, origin_x/y/z, translation_velocity, translation_acceleration) to this file.
csv_separator:                 string, default ","       # Field separator used in the CSV output.
csv_append:                    bool, default false       # Append to an existing csv_filename instead of truncating it.
```

Radius and origin position evolve independently — radius change is along the cylinder's own growth (`init_velocity`), and translation is along an unrelated `direction`, useful for an indentor moving through the sample perpendicular to the confinement axis. `init_velocity` defaults to `0`, so this operator can be used for translation-only motion.

```yaml title="Usage example"
confinement_wall:
  - move_cylinder_wall:
      init_origin: [0.0,66.0,135.0] ang
      init_axis: [1.0,0.0,0.0]
      init_radius: 50.0 ang
      init_cutoff: 2.2 ang
      init_epsilon: 1.0e-19 J
      init_time: 0.5 ps
      direction: [0.0,0.0,1.0]
      init_translation_velocity: -200 m/s
      csv_filename: cylinder_wall_trajectory.csv
  - cylinder_wall

+compute_force: [ confinement_wall ]
```

## **Spherical Wall**

### `sphere_wall`

```{ .yaml title="Syntax" .syntax-block }
sphere_wall:
  center: <Vec3d>
  radius: <float>
  cutoff: <float>
  exponent: <int>
  epsilon: <float>
```

```{ .yaml title="Parameters" .params-block }
center:    Vec3d, default [0,0,0]     # Sphere center.
radius:    float, required            # Sphere radius.
cutoff:    float, required            # Interaction range from the sphere surface.
exponent:  int, default 12            # Power-law exponent.
epsilon:   float, default 1.0e-19 J   # Energy scale.
```

Typically fed by `move_sphere_wall` rather than set directly.

```yaml title="Usage example"
confinement_wall:
  - sphere_wall: { center: [50.0,50.0,50.0] ang, radius: 45.0 ang, cutoff: 2.2 ang, epsilon: 1.0e-19 J }

+compute_force: [ confinement_wall ]
```

### `move_sphere_wall`

```{ .yaml title="Syntax" .syntax-block }
move_sphere_wall:
  init_center: <Vec3d>
  init_radius: <float>
  init_cutoff: <float>
  init_epsilon: <float>
  init_exponent: <int>
  init_time: <float>
  init_velocity: <float>
  direction: <Vec3d>
  init_translation_velocity: <float>
  final_time: <float>
  final_velocity: <float>
  final_translation_velocity: <float>
  csv_filename: <string>
  csv_separator: <string>
  csv_append: <bool>
```

```{ .yaml title="Parameters" .params-block }
init_center:                  Vec3d, default [0,0,0]   # Initial sphere center.
init_radius:                  float, required           # Initial radius.
init_cutoff:                  float, required           # Interaction range.
init_epsilon:                 float, required           # Energy scale.
init_exponent:                int, default 12           # Power-law exponent.
init_time:                    float, required           # Time at which the wall starts changing.
init_velocity:                float, default 0.0        # Radius growth rate, from init_time (negative = converging/imploding sphere).
direction:                    Vec3d, default [0,0,0]    # Unit vector for optional center translation.
init_translation_velocity:    float, default 0.0        # Translation speed of center along direction.
final_time:                   float, optional           # Time the ramp(s) to the final_* values complete; also when motion freezes and epsilon is forced to 0.
final_velocity:                float, optional           # Radius growth rate after final_time; defaults to init_velocity. Requires final_time.
final_translation_velocity:   float, optional            # Translation speed after final_time; defaults to init_translation_velocity. Requires final_time.
csv_filename:                  string, optional          # If set, rank 0 appends one row per call (time, radius, radius_velocity, radius_acceleration, center_x/y/z, translation_velocity, translation_acceleration) to this file.
csv_separator:                 string, default ","       # Field separator used in the CSV output.
csv_append:                    bool, default false       # Append to an existing csv_filename instead of truncating it.
```

Same shape as [`move_cylinder_wall`](#move_cylinder_wall) above, minus `axis` — a sphere has no orientation, so radius growth and center translation are the only two independent motions.

```yaml title="Usage example"
confinement_wall:
  - move_sphere_wall:
      init_center: [50.0,50.0,50.0] ang
      init_radius: 45.0 ang
      init_cutoff: 2.2 ang
      init_epsilon: 1.0e-19 J
      init_time: 0.5 ps
      init_velocity: -50 m/s
      csv_filename: sphere_wall_trajectory.csv
  - sphere_wall

+compute_force: [ confinement_wall ]
```

---
icon: material/wall
---

# **Pistons**

Three repulsive-wall operators confine or impact the system with a planar, cylindrical, or spherical barrier — in source these live under `exaStamp/src/shock/` (the module is called "shock", not "piston"). All three share the same repulsive power-law form and are fed into force computation like any other potential, via `compute_force`. Each has a companion `move_*` operator that computes the wall's time-varying position/size — this is what gives a "piston" its motion.

For a particle at signed distance $d$ from the wall geometry (plane/cylinder axis/sphere center), with $|d| \le$ `cutoff`:

$$
E_p \mathrel{+}= \varepsilon \left(1 - \frac{\text{cutoff}}{d}\right)^{\text{exponent}}, \qquad
\mathbf{f} = -\varepsilon \cdot \text{exponent} \cdot \frac{\text{cutoff}}{d^2} \left(1 - \frac{\text{cutoff}}{d}\right)^{\text{exponent}-1} \hat{\mathbf{n}}
$$

## **Planar Wall**

```{ .yaml title="Syntax" .syntax-block }
wall:
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
epsilon:   float, default 1.0e-19 J    # Energy scale.
```

```yaml title="Usage example"
left_wall:
  - wall: { normal: [1.0,0.0,0.0], offset: 17.0 ang, cutoff: 2.2 ang, epsilon: 1.0e-19 J }
right_wall:
  - wall: { normal: [-1.0,0.0,0.0], offset: -83.0 ang, cutoff: 2.2 ang, epsilon: 1.0e-19 J }

+compute_force: [ left_wall, right_wall ]
```

### `move_wall`

```{ .yaml title="Syntax" .syntax-block }
move_wall:
  init_normal: <Vec3d>
  init_offset: <float>
  init_cutoff: <float>
  init_epsilon: <float>
  init_time: <float>
  init_velocity: <float>
  final_time: <float>
  final_velocity: <float>
```

```{ .yaml title="Parameters" .params-block }
init_normal:     Vec3d, default [1,0,0]   # Unit normal of the plane.
init_offset:     float, default 0.0       # Initial signed offset.
init_cutoff:     float, required          # Interaction range.
init_epsilon:    float, required          # Energy scale.
init_time:       float, required          # Time at which the wall starts moving.
init_velocity:   float, required          # Wall speed along normal, from init_time.
final_time:      float, optional          # Time at which the ramp to final_velocity completes.
final_velocity:  float, optional          # Speed after final_time (constant acceleration between init_time and final_time).
```

Feeds `normal`/`offset`/`cutoff`/`epsilon`/`exponent` to a following `wall` step, recomputed every timestep: the offset stays fixed until `init_time`, then advances at `init_velocity`; if `final_time`/`final_velocity` are set, the speed ramps linearly between them; after `final_time`, motion stops and `epsilon` is forced to `0` (the wall is effectively removed).

```yaml title="Usage example"
left_wall:
  - move_wall:
      init_normal: [1.0,0.0,0.0]
      init_offset: 5.0 ang
      init_cutoff: 2.2 ang
      init_epsilon: 1.0e-19 J
      init_time: 0.5 ps
      init_velocity: 1000 m/s
  - wall

+compute_force: [ left_wall ]
```

## **Circular Wall**

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
axis:      Vec3d, default [0,0,1]     # Cylinder axis direction.
radius:    float, required            # Cylinder radius.
cutoff:    float, required            # Interaction range from the cylinder surface.
exponent:  int, default 12            # Power-law exponent.
epsilon:   float, default 1.0e-19 J   # Energy scale.
```

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
  init_time: <float>
  init_velocity: <float>
  direction: <Vec3d>
  init_translation_velocity: <float>
  final_time: <float>
  final_velocity: <float>
  final_translation_velocity: <float>
```

```{ .yaml title="Parameters" .params-block }
init_origin:                  Vec3d, default [0,0,0]   # Initial point on the cylinder's axis.
init_axis:                    Vec3d, default [0,0,1]   # Cylinder axis direction.
init_radius:                  float, required           # Initial radius.
init_cutoff:                  float, required           # Interaction range.
init_epsilon:                 float, required           # Energy scale.
init_time:                    float, required           # Time at which the wall starts changing.
init_velocity:                float, default 0.0        # Radius growth rate (negative = converging/imploding cylinder).
direction:                    Vec3d, default [0,0,0]    # Unit vector for optional origin translation, independent of axis.
init_translation_velocity:    float, default 0.0        # Translation speed of origin along direction.
final_time:                   float, optional            # Time the ramp(s) to the final_* values complete.
final_velocity:                float, optional            # Radius growth rate after final_time.
final_translation_velocity:   float, optional            # Translation speed after final_time.
```

Radius and origin position can evolve independently — radius change is along the cylinder's own growth (`init_velocity`), and translation is along an unrelated `direction`, useful for an indentor moving through the sample perpendicular to the confinement axis.

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
  - cylinder_wall

+compute_force: [ confinement_wall ]
```

## **Spherical Wall**

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

```yaml title="Usage example"
confinement_wall:
  - sphere_wall: { center: [50.0,50.0,50.0] ang, radius: 45.0 ang, cutoff: 2.2 ang, epsilon: 1.0e-19 J }

+compute_force: [ confinement_wall ]
```

### `move_sphere_wall`

Same shape as [`move_cylinder_wall`](#move_cylinder_wall) above, but with `init_center`/`center` in place of `init_origin`/`init_axis` — same `init_radius`/`init_cutoff`/`init_epsilon`/`init_time`/`init_velocity`/`direction`/`init_translation_velocity`/`final_*` parameters, feeding a following `sphere_wall` step.

```yaml title="Usage example"
confinement_wall:
  - move_sphere_wall:
      init_center: [50.0,50.0,50.0] ang
      init_radius: 45.0 ang
      init_cutoff: 2.2 ang
      init_epsilon: 1.0e-19 J
      init_time: 0.5 ps
      init_velocity: -50 m/s
  - sphere_wall

+compute_force: [ confinement_wall ]
```

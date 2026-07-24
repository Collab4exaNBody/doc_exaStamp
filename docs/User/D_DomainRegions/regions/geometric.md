---
icon: lucide/shapes
---

# **Defining regions**

Named regions are defined once via `particle_regions`, then consumed elsewhere — see [Restricting particle generation](restricting.md) and [Tracking particles in regions](tracking.md) for how they're used afterward.

## **`particle_regions`**

```{ .yaml title="Syntax" .syntax-block }
particle_regions:
  - <name>:
      id_range: [<int>, <int>]
      bounds: [[<float>, <float>, <float>], [<float>, <float>, <float>]]
      quadric:
        shape: <string>
        transform: [ { scale: [<float>, <float>, <float>] }, { translate: [<float>, <float>, <float>] } ]
```

```{ .yaml title="Parameters" .params-block }
id_range:  2 ints, default whole id range        # Particle-id range [start, end), end exclusive.
bounds:    AABB, default unbounded               # Axis-aligned box, in physical space.
quadric:   shape/matrix + transform, optional    # A canonical shape or a raw 4x4 matrix, optionally transformed — see below.
```

Each region can combine, in any subset, an `id_range`, a `bounds` box and a `quadric` shape; a point is inside the region only if it satisfies every criterion that was set. None of the three is required — a region with none of them matches the entire domain and every particle id.

```yaml
particle_regions:
  - REG1: { ... }
  - REG2: { ... }
  - REG3: { ... }
```

!!! warning

    All regions are defined in the physical space, not in the grid space. This is to be taken into account when creating regions, especially when dealing with triclinic physical domains.

!!! warning "Regions are not periodic"

    Region membership (`bounds` and `quadric`) is a plain geometric test against a particle's raw position — it has no awareness of the domain's `periodic` boundary conditions. A region that is meant to straddle a periodic boundary will **not** wrap around: it is simply cut off at the domain's edge, and particles on the other side of that boundary are excluded even if they'd be adjacent under periodicity. If you need a region that spans a periodic edge, define it as the union (`or`) of the two pieces on either side instead.

Every quadric-based region below — no matter which `shape` keyword it uses, or a raw `matrix` — is really just one symmetric 4×4 matrix $Q$ tested against the point's position.

!!! tip "The quadric equation behind every quadric-based region"

    A point $\mathbf{r}=(x,y,z)$ is inside a quadric region if, in homogeneous coordinates $\mathbf{r_h}=(x,y,z,1)$, it satisfies:

    $$
    \mathbf{r_h}^T Q \, \mathbf{r_h} \le 0
    $$

    where $Q$ is a symmetric 4×4 matrix — exactly the 16 coefficients you can provide directly via `quadric.matrix`. Expanded, this is the general quadric surface equation:

    $$
    Q_{11}x^2 + Q_{22}y^2 + Q_{33}z^2 + 2Q_{12}xy + 2Q_{13}xz + 2Q_{23}yz + 2Q_{14}x + 2Q_{24}y + 2Q_{34}z + Q_{44} \le 0
    $$

    Each named `shape` keyword is just a canonical, pre-built choice of $Q$:

    - `sphere`: $Q = \mathrm{diag}(1,1,1,-1)$ → $x^2+y^2+z^2 \le 1$ (unit sphere)
    - `cylx`/`cyly`/`cylz`: same, but the diagonal term for the cylinder's own axis is zeroed instead of squared — e.g. `cylx`: $Q=\mathrm{diag}(0,1,1,-1)$ → $y^2+z^2 \le 1$ (infinite unit cylinder along x)
    - `conex`/`coney`/`conez`: same idea, with that axis' diagonal term negated and $Q_{44}=0$ — e.g. `conex`: $Q=\mathrm{diag}(-1,1,1,0)$ → $y^2+z^2 \le x^2$ (double cone along x)
    - `planex`/`planey`/`planez`, or `plane: [Nx,Ny,Nz,D]`: only the terms coupling $x,y,z$ to the homogeneous `1` are non-zero, giving back the ordinary plane equation $N_x x + N_y y + N_z z + D \le 0$

    `transform`'s `scale`/`translate`/`xrot`/`yrot`/`zrot` operations don't move the point — they instead conjugate $Q$ by the transform's own matrix $T$: $Q' = (T^{-1})^T \, Q \, T^{-1}$. This is exactly what lets a single canonical unit shape be scaled, rotated and translated into place instead of needing a different $Q$ for every size/position. Providing `quadric.matrix` directly skips the canonical-shape step and lets you specify $Q$'s 16 coefficients yourself — `transform` still applies on top of it the same way.

## **Individual regions**

### Parallelepiped

```yaml
particle_regions:
  - B1:
      bounds: [ [ 10, 10, 5], [30, 50, 15] ]
  - B2:
      bounds: [ [ 15, 10, 25], [65,30,40] ]
  - B3:
      bounds: [ [ 30, 70, 10], [50, 90, 95] ]
```

<figure markdown="span">
  ![Parallelepiped regions](../img/boxes.png){ width="400" }
  <figcaption>Parallelepiped regions defined by <code>bounds</code></figcaption>
</figure>

### Plane-quadrics

```yaml
particle_regions:
  - P1:
      quadric:
        shape: { plane: [ 1, 0, 0, 0 ] }
        transform: { translate: [ 20, 0, 0 ] }
  - P2:
      quadric:
        shape: { plane: [ 0, 1, 0, 0 ] }
        transform: { translate: [ 0, 20, 0 ] }
  - P3:
      quadric:
        shape: { plane: [ 0, 0, 1, 0 ] }
        transform: { translate: [ 0, 0, 20 ] }
```

<figure markdown="span">
  ![Planes from quadrics](../img/planes.png){ width="400" }
  <figcaption>Plane regions defined by quadric <code>plane</code> shapes</figcaption>
</figure>

### Cylinder-quadrics

```yaml
particle_regions:
  - P1:
      quadric:
        shape: cylx
        transform:
          - scale: [ -1, 15, 15 ]
          - zrot: pi/4.
          - translate: [ 50, 50, 50 ]
  - P2:
      quadric:
        shape: cyly
        transform:
          - scale: [ 15, -1, 15 ]
          - zrot: pi/4.
          - translate: [ 50, 50, 50 ]
  - P3:
      quadric:
        shape: cylz
        transform:
          - scale: [ 15, 15, -1 ]
          - yrot: -pi/4.
          - translate: [ 50, 50, 50 ]
```

<figure markdown="span">
  ![Cylinders from quadrics](../img/cylinders.png){ width="400" }
  <figcaption>Cylinder regions defined by quadric <code>cylx</code>/<code>cyly</code>/<code>cylz</code> shapes</figcaption>
</figure>

### Ellipsoid-quadrics

```yaml
particle_regions:
  - S1:
      quadric:
        shape: sphere
        transform:
          - scale: [ 20, 20, 20 ]
          - translate: [ 45, 75, 70 ]
  - S2:
      quadric:
        shape: sphere
        transform:
          - scale: [ 40, 30, 10 ]
          - translate: [ 50, 60, 20 ]
  - S3:
      quadric:
        shape: sphere
        transform:
          - scale: [ 50, 10, 10 ]
          - yrot: pi/6.
          - translate: [ 50, 30, 50 ]
```

<figure markdown="span">
  ![Spheres/Ellipsoids from quadrics](../img/spheres.png){ width="400" }
  <figcaption>Ellipsoid regions defined by scaled quadric <code>sphere</code> shapes</figcaption>
</figure>

### Cone-quadric

```yaml
particle_regions:
  - CO1:
      quadric:
        shape: conex
        transform:
          - scale: [ 3, 0.75, 1.5 ]
          - translate: [ 50, 50, 50 ]
  - CO2:
      quadric:
        shape: coney
        transform:
          - scale: [ 1.5, 3, 0.75 ]
          - translate: [ 50, 50, 50 ]
  - CO3:
      quadric:
        shape: conez
        transform:
          - scale: [ 1, 1, 3 ]
          - translate: [ 50, 50, 50 ]
```

<figure markdown="span">
  ![Cones from quadrics](../img/cones.png){ width="400" }
  <figcaption>Cone regions defined by quadric <code>conex</code>/<code>coney</code>/<code>conez</code> shapes</figcaption>
</figure>

### Combining multiple transforms

`transform` accepts either a single map (one operation) or a sequence of maps, applied in listed order — the example below applies `scale`, then `xrot`/`yrot`/`zrot`, then `translate`. Available operations are `scale: [sx,sy,sz]`, `translate: [tx,ty,tz]`, `xrot`/`yrot`/`zrot: <angle>` (rotation around that axis) and `plane: [Nx,Ny,Nz,D]`.

```yaml
particle_regions:
  - CYL9:
      quadric:
        shape: cylz
        transform:
          - scale: [ 15 ang, 15 ang, 15 ang ]
          - xrot: pi/4
          - yrot: pi/3
          - zrot: pi/6
          - translate: [ 85 ang, 85 ang, 0 ang ]
```

### Providing the raw quadric matrix directly

Instead of a named `shape`, `quadric` also accepts a `matrix` key: the 16 row-major coefficients of the quadric's symmetric 4×4 matrix $Q$, evaluated as $\mathbf{r}^T Q \mathbf{r} \le 0$ with $\mathbf{r} = (x,y,z,1)$. `matrix` and `shape` are mutually exclusive — exactly one of the two must be given — but `transform` still applies on top of either.

The example below spells out the same unit-sphere quadric that `shape: sphere` produces internally, transformed exactly like the `S1` region in [Ellipsoid-quadrics](#ellipsoid-quadrics) above:

```yaml
particle_regions:
  - S4:
      quadric:
        matrix: [ 1, 0, 0, 0,
                  0, 1, 0, 0,
                  0, 0, 1, 0,
                  0, 0, 0, -1 ]
        transform:
          - scale: [ 20, 20, 20 ]
          - translate: [ 45, 75, 70 ]
```

Use `matrix` directly when you need a quadric shape that isn't one of the named `shape` keywords — e.g. a general ellipsoid or hyperboloid expressed by its own coefficients — rather than one of `sphere`/`conex`/`cylz`/etc.

### Range of particle ids

`id_range: [start, end]` selects particles whose id `i` satisfies `start <= i < end` (the upper bound is exclusive):

```yaml
particle_regions:
  - REGID1:
      id_range: [1, 1300]
```

---
icon: lucide/shapes
---

# **Spatial Regions**

## **Geometrically defined regions**

### The `particle_regions` operator

Spatial regions can be very useful in order to define areas in the simulation physical domain that are subsequently used to populate with particles or perform analysis on a subdomain for example. One or multiple named regions can be defined using the `particle_regions` YAML block:

```yaml
particle_regions:
  - REG1: { ... }
  - REG2: { ... }
  - REG3: { ... }
```

Each region can combine, in any subset, an `id_range`, a `bounds` box and a `quadric` shape (see below); a point is inside the region only if it satisfies all of the criteria that were set.

!!! warning

    All regions are defined in the physical space, not in the grid space. This is to be taken into account when creating regions, especially when dealing with triclinic physical domains.

!!! warning "Regions are not periodic"

    Region membership (`bounds` and `quadric`) is a plain geometric test against a particle's raw position — it has no awareness of the domain's `periodic` boundary conditions. A region that is meant to straddle a periodic boundary will **not** wrap around: it is simply cut off at the domain's edge, and particles on the other side of that boundary are excluded even if they'd be adjacent under periodicity. If you need a region that spans a periodic edge, define it as the union (`or`) of the two pieces on either side instead.

### Individual regions

#### Parallelepiped

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
  ![Parallelepiped regions](img/boxes.png){ width="400" }
</figure>

#### Plane-quadrics

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
  ![Planes from quadrics](img/planes.png){ width="400" }
</figure>

#### Cylinder-quadrics

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
  ![Cylinders from quadrics](img/cylinders.png){ width="400" }
</figure>

#### Ellipsoid-quadrics

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
  ![Spheres/Ellipsoids from quadrics](img/spheres.png){ width="400" }
</figure>

#### Cone-quadric

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
  ![Cones from quadrics](img/cones.png){ width="400" }
</figure>

!!! note "Combining several transforms"

    `transform` accepts either a single map (one operation) or a sequence of maps, applied in listed order — the example above applies `scale`, then `zrot`/`yrot`, then `translate`. Available operations are `scale: [sx,sy,sz]`, `translate: [tx,ty,tz]`, `xrot`/`yrot`/`zrot: <angle>` (rotation around that axis) and `plane: [Nx,Ny,Nz,D]`.

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

#### Range of particle ids

`id_range: [start, end]` selects particles whose id `i` satisfies `start <= i < end` (the upper bound is exclusive):

```yaml
particle_regions:
  - REGID1:
      id_range: [1, 1300]
```

## **Combining regions**

`particle_regions` only defines named geometric regions; operators that consume a region (`track_region_particles`, `set_cell_values`, …) take a `region`/`expr` string that combines those names with the boolean operators `and`, `or`, `not` and parentheses, e.g. `"PLANE1 and (SPHERE1 or not BOX1)"`.

## **User-defined source term**

Particle-generation operators (e.g. `bulk_lattice`) accept a `user_function`/`user_threshold` pair to further restrict where particles are generated: particles are only placed where the scalar function evaluates to a value greater than or equal to `user_threshold`.

```yaml
bulk_lattice:
  # ... lattice parameters ...
  user_function:
    wavefront:
      # first 3 values are interface plane (Pi)'s normal vector (X,Y,Z), last one is plane offset (position of origin relative to the plane).
      plane: [ -1, 0, 0, 125.0 ang ]
      # wave plane (normal and offset). Oriented distance to the plane, Pw(r), is used to add a sinusoid function sin(Pw(r))*amplitude to the plane function above
      wave: [ 0, 0.1, 0, 0 ]
      amplitude: 10.0 ang
  user_threshold: 0.0
```

```yaml
bulk_lattice:
  # ... lattice parameters ...
  user_function:
    sphere:
      center: [30, 30, 30]
      amplitude: 10.
      radius_mean: 20.
      radius_dev: 2.
      time_mean: 0.
      time_dev: 1.
```

```yaml
bulk_lattice:
  # ... lattice parameters ...
  user_function:
    constant: 10.
```

## **Regions-related operations**

### Tracking particles inside a region

`track_region_particles` reassigns particle IDs so that every particle inside the given region gets a contiguous block of IDs starting at 0, and every other particle gets IDs immediately after that block (contiguous across MPI ranks via `MPI_Exscan`). The region is then registered into `particle_regions` under `name`, with a fast `id_range`-based membership test for later operators. Only one region can be tracked at a time.

```yaml
track_region_particles:
  expr: PLANE1
  name: "PISTON"
```

### Tracking multiple regions at once

`track_region_particles_multiple` does the same thing for several regions in one pass: each tracked region gets its own contiguous ID block (region 0 first, then region 1, etc.), and particles outside all tracked regions get IDs after the last block. If a particle matches more than one of the given expressions, it's assigned to the first one that matches.

```yaml
# First define regions
particle_regions:
  - BOTTOMBOX:
      bounds: [ [ -200 ang, -200 ang, -200 ang ], [ 200 ang, 200 ang, 15 ang ] ]
  - TOPBOX:
      bounds: [ [ -200 ang, -200 ang, 135 ang ], [ 200 ang, 200 ang, 200 ang ] ]

# Then track them, in one pass
track_region_particles_multiple:
  exprs: [ "BOTTOMBOX", "TOPBOX" ]
  names: [ "BAS", "HAUT" ]
```

!!! warning

    Both operators reassign IDs for **every** particle in the simulation, not just the tracked region(s) — original ID values and ordering are not preserved anywhere, in or out of the tracked region. Use `track_region_particles` for a single region and `track_region_particles_multiple` when tracking more than one at once.

### Assigning regions to a grid field

```yaml
set_cell_values:
  field_name: "region"
  region: CYLX or CYLY or CYLZ
  value: [0,1]
  grid_subdiv: 10
```

---
icon: material/filter-variant
---

# **Restricting particle generation**

Beyond a plain geometric [region](geometric.md), particle generation can be filtered further by a grid mask, a boolean combination of regions, or a user-defined function — any combination of these can be applied together on the same particle-generation operator: a particle is generated only if every criterion that was given agrees.

## **Grid mask defined regions**

Besides the geometric shapes in [Defining regions](geometric.md), a region can also be defined by a discretized per-(sub)cell scalar field on the grid — a **mask**. Particle-generation operators (`lattice`, `bulk_lattice`) can be restricted to only the (sub)cells whose mask value matches a given value, via `grid_cell_mask_name`/`grid_cell_mask_value`.

### Building the mask

The mask field itself is grid data, not a region — it's built and read like any other grid-cell field, over in Grids Features:

- [Grids Features → Setters: `set_cell_values`](../../E_Grids/setters.md#set_cell_values) — writes a value to every (sub)cell falling inside a [region](geometric.md) (or the whole grid if none is given). Use a single-element `value` like `[1]` to produce a plain mask.
- [Grids Features → Input: `read_cell_values`](../../E_Grids/input.md#read_cell_values) — reads a scalar field from an external structured-grid `.vtk` file instead, e.g. one computed by an external tool.

### Using the mask to restrict particle generation

`lattice`/`bulk_lattice` accept `grid_cell_mask_name` (the field built above) and `grid_cell_mask_value`. A particle is only generated in a (sub)cell whose mask value is **exactly equal** to `grid_cell_mask_value` — this is a strict equality test, not a greater-than/less-than threshold, despite the name:

```yaml
lattice:
  structure: BCC
  types: [ W, W ]
  size: [ 3 ang, 3 ang, 3 ang ]
  grid_cell_mask_name: MASK1
  grid_cell_mask_value: 1
```

A geometric `region`, a grid mask, and a [`user_function`](#user-defined-source-term) can all be combined on the same particle-generation operator.

## **Combining regions**

`particle_regions` only defines named geometric regions; operators that consume a region (`track_region_particles`, `set_cell_values`, …) take a `region`/`expr` string that combines those names with the boolean operators `and`, `or`, `not` and parentheses, e.g. `"PLANE1 and (SPHERE1 or not BOX1)"`.

## **User-defined source term**

Particle-generation operators (e.g. `bulk_lattice`) accept a `user_function`/`user_threshold` pair to further restrict where particles are generated: particles are only placed where the scalar function evaluates to a value greater than or equal to `user_threshold`.

A moving or oscillating planar interface:

```yaml title="wavefront example"
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

Randomly nucleated spherical regions, distributed in time:

```yaml title="sphere example"
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

A flat threshold applied everywhere:

```yaml title="constant example"
bulk_lattice:
  # ... lattice parameters ...
  user_function:
    constant: 10.
```

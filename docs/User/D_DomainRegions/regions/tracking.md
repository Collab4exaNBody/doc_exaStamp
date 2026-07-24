---
icon: material/target
---

# **Tracking particles in regions**

Beyond [defining](geometric.md) and [consuming](restricting.md) regions, two operators exist purely to reassign particle IDs by region membership, giving later operators a fast `id_range`-based membership test instead of a geometric one.

## **`track_region_particles`**

```{ .yaml title="Syntax" .syntax-block }
track_region_particles:
  name: <string>
  expr: <string>
```

```{ .yaml title="Parameters" .params-block }
name:  string, required   # Name the tracked region is registered under in `particle_regions`.
expr:  string, optional   # Boolean region expression selecting which particles to track.
```

`track_region_particles` reassigns particle IDs so that every particle inside `expr` gets a contiguous block of IDs starting at 0, and every other particle gets IDs immediately after that block (contiguous across MPI ranks via `MPI_Exscan`). The region is then registered into `particle_regions` under `name`, with a fast `id_range`-based membership test for later operators. Only one region can be tracked at a time — see [`track_region_particles_multiple`](#track_region_particles_multiple) below for tracking several at once.

```yaml title="Usage example"
track_region_particles:
  expr: PLANE1
  name: "PISTON"
```

## **`track_region_particles_multiple`**

```{ .yaml title="Syntax" .syntax-block }
track_region_particles_multiple:
  names: [<string>, ...]
  exprs: [<string>, ...]
```

```{ .yaml title="Parameters" .params-block }
names:  list of strings, required   # Name each tracked region is registered under; also sets tracking order.
exprs:  list of strings, optional   # One boolean region expression per name — must be the same length as `names`.
```

`track_region_particles_multiple` does the same thing for several regions in one pass: each tracked region gets its own contiguous ID block, in the order given by `names` (region 0 first, then region 1, etc.), and particles outside every tracked region get IDs after the last block. If a particle matches more than one expression, it's assigned to the first one that matches.

```yaml title="Usage example"
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

See [Restricting particle generation](restricting.md#grid-mask-defined-regions) for `set_cell_values`/`read_cell_values`, which assign or read region-derived values on the grid itself.

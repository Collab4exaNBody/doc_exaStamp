---
icon: lucide/grid-3x3
---

# **Analysis**

Projects particle-carried quantities onto a regular analysis grid — the grid used for parallelism, subdivided by `grid_subdiv` — for later output or connected-component analysis.

## **`atom_cell_projection`**

```{ .yaml title="Syntax" .syntax-block }
atom_cell_projection:
  fields: [<string>, ...]
  grid_subdiv: <int>
  splat_size: <float>
```

```{ .yaml title="Parameters" .params-block }
fields:        list of strings, default [".*"]  # Regular expressions selecting which quantities to project — count, velocity, force, vnorm, mv2, mass, momentum, mv2tensor.
grid_subdiv:   int, default 1                   # Per-cell subdivision of the projection grid.
splat_size:    float, default 1.0               # Distance used to spread each particle's contribution onto neighboring grid cells.
```

Projects per-particle quantities onto a regular grid (`grid_cell_values`) by splatting each particle's contribution across nearby (sub)cells within `splat_size`. Requires `resize_grid_cell_values` to have run first (see [Setters](setters.md#resize_grid_cell_values)) and a `species` block to already be declared.

```yaml title="Usage example"
- grid_flavor
- resize_grid_cell_values
- atom_cell_projection:
    fields: [ mv2, mass, vnorm ]
    grid_subdiv: 2
    splat_size: 1.5 ang
```

!!! note "Projecting computed per-particle fields"

    Besides the built-in quantities, `atom_cell_projection` also projects the per-particle fields created at run time by other operators (scalar, vector or tensor), for example the mechanical metrics of [Particles Features → Analysis](../F_Particles/analysis.md#local-mechanical-metrics) (`defgrad`, `green_lagrange`, `von_mises`, ...). Select them by name in `fields`, like the built-in ones.

    `particle_cell_projection` (`exaNBody/src/analytics/`) is the generic, application-independent version: it projects count, velocity and force without the species-mass-aware quantities (kinetic energy, momentum) of `atom_cell_projection`.

If particle positions/velocities are shared across MPI ranks or updated between projections, `ghost_update_r_v` (and its siblings `ghost_update_r`, `ghost_update_r_v_vir`, `ghost_update_rq`, `ghost_update_all`, …) syncs the relevant fields into ghost cells first — needed for projection accuracy right at domain/subdomain boundaries:

```yaml title="Usage example"
- grid_flavor
- resize_grid_cell_values
- ghost_update_r_v
- atom_cell_projection:
    fields: [ mv2, mass, vnorm ]
    grid_subdiv: 2
    splat_size: 1.5 ang
```

## **Not yet covered here**

!!! note "Found in source, out of scope for this page"

    A handful of other operators also read or write per-cell `grid_cell_values` data but belong to more specific subsystems rather than core Grids Features, and aren't documented in depth on this page: `igar_compute_gradient`/`igar_force_interp`/`igar_force_from_gradient` (an implicit-potential force method), `fluid_friction` (a drag-force model driven by a cell-centered velocity field), `cc_label` (connected-component clustering on a thresholded cell field), `grid_stats` (a debug/diagnostic operator), and the `migrate_cell_particles*` family (keeps `grid_cell_values` consistent across MPI load-balancing events). Flagged here so they aren't mistaken for missing or unknown — they exist, just outside this page's scope for now.

!!! tip "Two-temperature model"
    The two-temperature model stores the electronic temperature in a `te` grid field (one value per subcell) and evolves it with `init_ttm` and `ionic_eletronic_heat_transfer`. See [Two-Temperature Model](../H_EnsemblesConstraints/ttm.md).

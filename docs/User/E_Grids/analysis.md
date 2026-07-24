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

!!! note "Two near-identical sibling operators exist"

    `mechanical_cell_projection` (`exaStamp/src/mechanical/`) does the same kinetic/mass projection, plus optionally the deformation-gradient/strain/rotation/stretch fields from `compute_local_mechanical_metrics` (see [Particles Features → Analysis](../F_Particles/analysis.md#compute_local_mechanical_metrics)). Its `splat_size` has no default (required), unlike `atom_cell_projection`'s. `particle_cell_projection` (`exaNBody/src/analytics/`, the generic, application-agnostic version) does the same generic count/velocity/force-field projection without `atom_cell_projection`'s species-mass-aware quantities (kinetic energy, momentum). All three are separate, independently-registered operators — not aliases of each other, despite the overlapping names and behavior.

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

    A handful of other operators also read or write per-cell `grid_cell_values` data but belong to more specific subsystems rather than core Grids Features, and aren't documented in depth on this page: `igar_compute_gradient`/`igar_force_interp`/`igar_force_from_gradient` (an implicit-potential force method), `fluid_friction` (a drag-force model driven by a cell-centered velocity field), `init_ttm` and the two-temperature-model heat-transfer operators (electronic/ionic temperature exchange), `cc_label` (connected-component clustering on a thresholded cell field), `grid_stats` (a debug/diagnostic operator), and the `migrate_cell_particles*` family (keeps `grid_cell_values` consistent across MPI load-balancing events). Flagged here so they aren't mistaken for missing or unknown — they exist, just outside this page's scope for now.

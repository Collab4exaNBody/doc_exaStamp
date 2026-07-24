---
icon: material/tune
---

# **Setters**

Writes or resizes per-cell data on the simulation grid.

## **`set_cell_values`**

```{ .yaml title="Syntax" .syntax-block }
set_cell_values:
  field_name: <string>
  region: <string>
  value: [<float>, ...]
  grid_subdiv: <int>
```

```{ .yaml title="Parameters" .params-block }
field_name:   string, required               # Name of the grid-cell field to write.
region:       string, optional                # Region (name or boolean expression) to restrict the write to; whole grid if omitted.
value:        list of floats, default [0.0]   # One entry per field component (ncomps = value.size()).
grid_subdiv:  int, default 1                  # Per-cell subdivision the field is stored at.
```

`set_cell_values` writes `value` to every grid (sub)cell that falls inside `region` — a named region or boolean expression, see [Domain & Regions → Combining regions](../D_DomainRegions/regions/restricting.md#combining-regions) — or to the whole grid if `region` is omitted. For a plain mask later consumed via `grid_cell_mask_name`, use a **single-element** `value` like `[1]`: the consumer expects exactly one component per cell (`subdiv³` values, not `subdiv³ × ncomps`), otherwise it fails with "expected a scalar value field for cell mask".

!!! note

    (Sub)cells outside `region` are only left at `0` if the field is being created for the first time by this call. If a field with that name already exists, cells outside `region` simply keep whatever value they already had.

```yaml title="Usage example"
particle_regions:
  - CYLX:
      quadric:
        shape: cylx
        transform:
          - scale: [ 15, 15, 15 ]
          - translate: [ 50, 50, 50 ]

set_cell_values:
  field_name: "MASK1"
  region: CYLX
  value: [1]
  grid_subdiv: 10
```

## **`resize_grid_cell_values`**

```{ .yaml title="Syntax" .syntax-block }
- resize_grid_cell_values
```

No parameters — it syncs `grid_cell_values`'s dimensions, ghost layers and offset to match the current particle grid. Run it before any projection or write operator that populates `grid_cell_values`, whenever the underlying grid may have changed size (e.g. after `replicate_domain`, or before the first projection of a run).

```yaml title="Usage example"
- grid_flavor
- resize_grid_cell_values
- atom_cell_projection:
    fields: [ mv2, mass, vnorm ]
    grid_subdiv: 2
    splat_size: 1.5 ang
```

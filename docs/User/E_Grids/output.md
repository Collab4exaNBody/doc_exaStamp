---
icon: material/export
---

# **Output**

Writes grid-projected data (built via [Analysis](analysis.md)) to disk as VTK ImageData, for visualization in ParaView or similar tools.

## **`write_grid_vtk`**

```{ .yaml title="Syntax" .syntax-block }
write_grid_vtk:
  filename: <string>
  use_point_data: <bool>
  adjust_spacing: <bool>
```

```{ .yaml title="Parameters" .params-block }
filename:        string, default "grid"  # Output base name — produces <filename>.pvti plus a <filename>/ directory of per-rank .vti pieces.
use_point_data:  bool, default true      # Attach values to grid vertices (true, smooth interpolation) or to voxel cells (false, blocky/faceted) — see note below.
adjust_spacing:  bool, default false     # Use the domain's real physical spacing instead of one grid cell = one VTK unit.
```

Exports every field in `grid_cell_values` to VTK ImageData format: a parallel `.pvti` master file referencing one `.vti` piece per MPI rank. Ghost layers are excluded automatically. Open the `.pvti` file in ParaView (not the individual pieces) to see the whole system.

!!! note "What `use_point_data` actually changes"

    `true` attaches the arrays to grid vertices (N cells → N+1 points per axis), so ParaView interpolates smoothly across cells — this is what Contour/Slice/iso-surface filters expect, and gives smooth color gradients. `false` attaches them to voxel cells instead (exact per-cell count, no +1), giving one flat color per cell — better suited to exact per-voxel inspection or a Threshold filter. Confirmed directly from the operator's own extent-computation code and embedded documentation string, resolving what older documentation left as "check what it means."

```yaml title="Usage example"
- grid_flavor
- resize_grid_cell_values
- atom_cell_projection:
    fields: [ mv2, mass, vnorm ]
    grid_subdiv: 2
    splat_size: 1.5 ang
- timestep_file: "grid_%09d"
- write_grid_vtk
```

## **The full analysis-to-output pipeline**

The real, working end-to-end pattern (from `exaStamp/data/config/config_analysis.msp` and `exaStamp/data/regression_new/analytics/*.msp`):

```yaml title="Usage example"
simulation_epilog:
  - grid_flavor
  - resize_grid_cell_values
  - atom_cell_projection:
      fields: [ "mv2", "mass" ]
      grid_subdiv: 2
      splat_size: 1.5 ang
  - timestep_file: "grid_%09d"
  - write_grid_vtk
```
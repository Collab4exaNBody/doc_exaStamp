# **Grids Features**

This section covers the simulation grid itself: how its per-particle data layout (the "flavor") is chosen, how per-cell fields are read, written and analyzed, and how grid-projected data is written to disk.

- [**Grid Flavor**](flavors.md) — choosing which per-particle fields are stored, via `grid_flavor_*`
- [**Input**](input.md) — reading external per-cell data onto the grid
- [**Setters**](setters.md) — writing or resizing per-cell data on the grid
- [**Analysis**](analysis.md) — projecting particle properties onto the grid
- [**Output**](output.md) — writing grid-projected data to disk

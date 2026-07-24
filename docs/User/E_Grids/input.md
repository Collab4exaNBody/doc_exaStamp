---
icon: material/import
---

# **Input**

Reads external per-cell data onto the simulation grid.

## **`read_cell_values`**

```{ .yaml title="Syntax" .syntax-block }
read_cell_values:
  field_name: <string>
  file_name: <string>
  grid_subdiv: <int>
  grid_ordering: <C_ORDER | F_ORDER>
```

```{ .yaml title="Parameters" .params-block }
field_name:     string, required          # Name of the grid-cell field to create.
file_name:      string, required          # Path to the structured-grid .vtk file to read.
grid_subdiv:    int, required             # Per-cell subdivision the field is stored at.
grid_ordering:  enum, default F_ORDER     # Cell ordering in the file: C_ORDER or F_ORDER.
```

`read_cell_values` reads a scalar field from an external structured-grid `.vtk` file into a per-cell field on the grid — e.g. a mask computed by an external tool, or any other precomputed per-cell scalar data. Only scalar fields are supported. See [Domain & Regions → Grid mask defined regions](../D_DomainRegions/regions/restricting.md#grid-mask-defined-regions) for how this is used to restrict particle generation.

```yaml title="Usage example"
read_cell_values:
  field_name: "MASK1"
  file_name: "points_40x40x40.vtk"
  grid_subdiv: 4
  grid_ordering: F_ORDER
```

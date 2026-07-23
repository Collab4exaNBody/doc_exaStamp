---
icon: material/export
---

# **Output**

To write particles out to disk, generate a filename — usually with `timestep_file`, so each dump gets a name unique to the current iteration — then call one of the writer operators below.

## **Generating an output filename**

`timestep_file` builds a filename from a printf-style `format` string and the current `timestep`, and outputs it as `filename`, which the writer operators below pick up automatically through same-name slot binding:

| Property | Description | Data Type | Default |
|---|---|---|---|
| `format` | printf-style format string, e.g. `"output_%09d"`. | string | *(required)* |

```yaml
- timestep_file: "paraview/output_%09d"
- write_paraview: { fields: [ mass, vz ] }
```

!!! note "Logging what was written"

    `exaStamp`'s own default snapshot configuration (`data/config/config_snapshot.msp`) additionally logs the filename to the console right before writing, using the generic `message` operator (`mesg`/`endl`) with its `mesg` slot rebound to the `filename` that `timestep_file` just produced:

    ```yaml
    - timestep_file: "paraview/output_%09d"
    - message: { mesg: "Write paraview file", endl: false }
    - print_dump_file:
        rebind: { mesg: filename }
        body:
          - message: { endl: true }
    - write_paraview
    ```

    `print_dump_file` isn't a distinct operator here — it's just a locally-chosen aggregate name wrapping `message` with a `rebind`, using the generic aggregate/`rebind` mechanism (see [YAML extensions](../B_GettingStarted/yaml_extensions.md)). The simple form above (just `timestep_file` + the writer) is enough for everyday use.

## **Writers**

### `write_paraview`

Writes particle positions and attached fields in parallel, in ParaView-readable `.vtp` format.

| Property | Description | Data Type | Default |
|---|---|---|---|
| `filename` | Output file name. | string | `"output"` |
| `fields` | List of regular expressions selecting which fields to write. | list of strings | `[".*"]` (everything) |
| `binary_mode` | Write in binary mode (with `compression`) rather than ASCII. | bool | `true` |
| `compression` | Compression level for binary mode. | string | `"default"` |
| `write_box` | Also write the domain box. | bool | `true` |
| `write_ghost` | Also write ghost particles. | bool | `false` |

```yaml
write_paraview:
  fields: [ type, vx, vy, vz, ep ]
  write_ghost: false
```

### `write_xyz`

`exaNBody`'s generic `.xyz` writer — despite the format's usual reputation, it isn't limited to positions/types/ids: any field can be selected the same way as `write_paraview`.

| Property | Description | Data Type | Default |
|---|---|---|---|
| `filename` | Output file name. | string | `"output"` |
| `fields` | List of regular expressions selecting which fields to write. | list of strings | `[".*"]` (everything) |
| `units` | Units to use for specific fields. | map | `{position: m, velocity: m/s, force: m/s/kg}` |
| `field_alias` | Shorter output-header names for specific fields. | map | `{position: pos, velocity: vel}` |
| `ghost` | Also write ghost particles. | bool | `false` |

### `write_xyz_file`

`exaStamp`'s own `.xyz` writer, used by its default snapshot configuration. Unlike `write_xyz` above, it integrates directly with the on-the-fly local-metrics analysis operators (`compute_local_metrics`, `compute_local_mechanical_metrics`, `compute_local_structural_metrics` — see [Analysis](analysis.md)), writing out their computed per-atom values alongside positions whenever those operators ran earlier in the graph.

| Property | Description | Data Type | Default |
|---|---|---|---|
| `filename` | Output file name. | string | *(required)* |
| `is_ghosts` | Also write ghost particles. | bool | `false` |
| `use_filtered_positions` | Write the [filtered position](setters.md#mechanics-specific-filtered-position) (`rxf`/`ryf`/`rzf`) instead of the raw position. | bool | `false` |

### `write_lmp`

Writes a LAMMPS `.data`-style file.

| Property | Description | Data Type | Default |
|---|---|---|---|
| `filename` | Output file name. | string | `"output.lmp"` |
| `triclinic` | Write the box as triclinic (`xy`/`xz`/`yz` tilt factors) instead of orthogonal. | bool | `false` |
| `write_velocities` | Include the Velocities section. | bool | `true` |

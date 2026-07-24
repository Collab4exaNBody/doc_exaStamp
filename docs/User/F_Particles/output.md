---
icon: material/export
---

# **Output**

To write particles out to disk, generate a filename — usually with `timestep_file`, so each dump gets a name unique to the current iteration — then call one of the writer operators below.

## **Generating an output filename**

```{ .yaml title="Syntax" .syntax-block }
- timestep_file: <format_string>
```

```{ .yaml title="Parameters" .params-block }
format:  string, required  # printf-style format string, e.g. "output_%09d".
```

`timestep_file` builds a filename from `format` and the current `timestep`, and outputs it as `filename`, which the writer operators below pick up automatically through same-name slot binding. `format` goes straight into a real `snprintf` call with `timestep` as its only argument — it must contain exactly **one** integer conversion (`%d`, `%09d`, …); a format string with more than one `%`-conversion isn't supported and reads past the supplied argument.

```yaml title="Usage example"
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

    `print_dump_file` isn't a distinct operator here — it's just a locally-chosen aggregate name wrapping `message` with a `rebind`, using the generic aggregate/`rebind` mechanism (see [YAML extensions](../../Beginner/GettingStarted/yaml_extensions.md)). The simple form above (just `timestep_file` + the writer) is enough for everyday use.

## **Writers**

### `write_paraview`

```{ .yaml title="Syntax" .syntax-block }
write_paraview:
  filename: <string>
  fields: [<string>, ...]
  binary_mode: <bool>
  compression: <string>
  write_box: <bool>
  write_ghost: <bool>
```

```{ .yaml title="Parameters" .params-block }
filename:     string, default "output"          # Output file name.
fields:       list of strings, default [".*"]   # Regular expressions selecting which fields to write (default = everything).
binary_mode:  bool, default true                # Write in binary mode (with compression) rather than ASCII.
compression:  string, default "default"         # Compression level for binary mode.
write_box:    bool, default true                # Also write the domain box.
write_ghost:  bool, default false               # Also write ghost particles.
```

Writes particle positions and attached fields in parallel, in ParaView-readable `.vtp` format.

```yaml title="Usage example"
write_paraview:
  fields: [ type, vx, vy, vz, ep ]
  write_ghost: false
```

!!! note

    `filename` names a **directory**, not a single file: the operator writes one `.vtp` piece per MPI rank under `<filename>/`, a master `<filename>.pvtp` tying them together, and (if `write_box`) a `<filename>/box.vtp`. Unlike `write_xyz` below, there's no `units`/`field_alias` equivalent here, and no simulation-time metadata is written into the file at all (confirmed unimplemented in the source, not just undocumented). A separate, distinct operator `mechanical_write_paraview` exists for mechanics fields specifically — don't confuse the two.

### `write_xyz`

```{ .yaml title="Syntax" .syntax-block }
write_xyz:
  filename: <string>
  fields: [<string>, ...]
  units: { <field>: <unit> }
  field_alias: { <field>: <alias> }
  ghost: <bool>
```

```{ .yaml title="Parameters" .params-block }
filename:       string, default "output"                                 # Output file name.
fields:         list of strings, default [".*"]                          # Regular expressions selecting which fields to write.
units:          map, default {position: m, velocity: m/s, force: m/s/kg}  # Units to use for specific fields (yes, "m/s/kg" for force — verified verbatim in source).
field_alias:    map, default {position: pos, velocity: vel}               # Shorter output-header names for specific fields.
ghost:          bool, default false                                      # Also write ghost particles (note: named `ghost` here, `write_ghost` on write_paraview).
physical_time:  float, default 0.0                                       # Stamped into the file's `Time=` header field.
```

`exaNBody`'s generic `.xyz` writer, in extended-XYZ format — despite the format's usual reputation, it isn't limited to positions/types/ids: any field can be selected the same way as `write_paraview`. Unlike `write_paraview`, it does write simulation-time metadata (`Time=<physical_time>`) into the file's header line, alongside a `Properties=` spec built from `units`/`field_alias`.

### `write_xyz_file`

```{ .yaml title="Syntax" .syntax-block }
write_xyz_file:
  filename: <string>
  is_ghosts: <bool>
  use_filtered_positions: <bool>
  per_atom_data: [<string>, ...]
```

```{ .yaml title="Parameters" .params-block }
filename:                string, required     # Output file name.
species:                 required             # Must already be declared — used for the type-name column and, for `f`, mass-based unit conversion.
is_ghosts:               bool, default false  # Also write ghost particles.
use_filtered_positions:  bool, default false  # Write the filtered position (rxf/ryf/rzf) instead of the raw position.
per_atom_data:           list of strings, optional  # Which computed local-metrics values to append as extra columns — see below.
```

`exaStamp`'s own `.xyz` writer, used by its default snapshot configuration. Each line is just `type x y z` by default — **no particle `id` column is written**, contrary to what a plain `.xyz` reader might assume.

Its integration with the on-the-fly local-metrics operators (`compute_local_metrics`, `compute_local_mechanical_metrics`, `compute_local_structural_metrics` — see [Analysis](analysis.md)) is **not automatic just because those operators ran earlier**: it additionally requires the same `per_atom_data` list of value names (e.g. `"pe"`, `"f"`, `"v"`, `"F"`, `"L"`, `"bispectrum"`) to be given to *both* the compute operator and `write_xyz_file` — only the names present in `per_atom_data` get appended as extra columns (and to the header line).

```yaml title="Usage example"
simulation_epilog:
  - compute_local_metrics: { per_atom_data: ["pe","f"] }
  - write_xyz_file: { per_atom_data: ["pe","f"], filename: xstamp.xyz }
```

### `write_lmp`

```{ .yaml title="Syntax" .syntax-block }
write_lmp:
  filename: <string>
  triclinic: <bool>
  write_velocities: <bool>
```

```{ .yaml title="Parameters" .params-block }
filename:          string, default "output.lmp"  # Output file name.
species:           required                      # Used for the Masses section (one line per species).
triclinic:         bool, default false            # false doesn't force orthogonal — see note below.
write_velocities:  bool, default true             # Include the Velocities section.
```

Writes a LAMMPS `.data`-style file, atom style `atomic` (fixed — there's no `atom_style` selection).

!!! note

    `triclinic: false` isn't a hard override: the box is still auto-detected as triclinic (and written with `xy`/`xz`/`yz` tilt factors) if the domain's actual off-diagonal `xform` terms exceed a small tolerance. Set `triclinic: true` to always force triclinic output; `false` only means "don't force it beyond what auto-detection already decides."

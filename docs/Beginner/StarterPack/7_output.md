---
icon: lucide/folder-up
---

# Output Data

Output is controlled by the frequency variables already introduced in [Global Control](1_global.md), together with the writer operators below. This page only covers particle-level output (the `species`/positions/velocities you defined earlier) — see the tip at the end for grid-level output.

## Thermodynamic state (screen & file) { #thermo-output }

Printing the thermodynamic state to the screen (`print_thermodynamic_state`) and writing it to a `.csv` file (`dump_thermodynamic_state`) are both enabled by default; only their frequency and columns need to be set from `global`:

```yaml linenums="1"
global:
  simulation_thermostate_screen_frequency: 10   # print to screen every 10 steps
  simulation_thermostate_file_frequency: 10     # append to file every 10 steps
  thermostate_file: "thermodynamic_state.csv"
  log_mode: mechanical                          # preset name, or a ';'-separated list of keywords
  # log_format: "%9.0f;%.6e"                    # optional printf formats, applied column by column
```

`log_mode` and `log_format` set in `global` are read by both the screen printer and the file writer, so the screen and the `.csv` file show the same columns. The file uses more significant digits by default.

### Presets

| `log_mode` | Columns |
| :--- | :--- |
| `default`, `thermo_basic` | `stp pht toe kie poe tmp pre sta` |
| `thermo`, `thermo_full` | `stp pht toe kie poe tmp tmx tmy tmz pre pxx pyy pzz sta` |
| `vol_fluct_ortho_basic` | `stp pht toe kie poe tmp pre vol bxa bxb bxc rho sta` |
| `vol_fluct_ortho`, `vol_fluct_ortho_full` | `stp pht toe kie poe tmp tmx tmy tmz pre pxx pyy pzz vol bxa bxb bxc rho sta` |
| `vol_fluct_tricl_basic` | `stp pht toe kie poe tmp pre vol bxa bxb bxc baa bab bag rho sta` |
| `vol_fluct_tricl`, `vol_fluct_tricl_full` | `stp pht toe kie poe tmp tmx tmy tmz pre pxx pyy pzz pxy pxz pyz vol bxa bxb bxc baa bab bag rho sta` |
| `mechanical` (default in `config_globals.msp`) | `stp pht prt sta toe kie poe tmp pre smi vol mas` |
| `dump_default` | `stp pht prt toe kie poe tmp pxx pyy pzz pxy pxz pyz bxa bxb bxc baa bab bag vol rho` |

### Keywords

Instead of a preset, `log_mode` accepts any `;`-separated list of the keywords below, printed in the given order, e.g. `log_mode: "stp;pht;tmp;pxx;pyy;pzz;vol"`. An unknown keyword stops the run and prints the list of valid keywords.

| Keyword | Column | Description |
| :---: | :--- | :--- |
| `stp` | Step | Timestep |
| `pht` | Time (ps) | Physical time |
| `prt` | Particles | Number of particles |
| `sta` | Mv/Ext/Imb. | Run status: particle migration (`m`, or a count), domain extension (`d`, or a count) and load imbalance |
| `toe` | Tot. E. (eV/part) | Total energy per particle (kinetic + potential + electronic, if any) |
| `kie` | Kin. E. (eV/part) | Kinetic energy per particle |
| `poe` | Pot. E. (eV/part) | Potential energy per particle |
| `ele` | Elec. E. (eV) | Total electronic energy of the [two-temperature model](../../User/H_EnsemblesConstraints/ttm.md) |
| `ite` | Ion Transf. E. (eV) | Energy transferred from the electrons to the ions during the step (two-temperature model) |
| `tmp` | Temp. (K) | Temperature, computed with $3N-3$ degrees of freedom |
| `tmx`, `tmy`, `tmz` | Tx, Ty, Tz (K) | Temperature components |
| `pre` | Press. (Pa) | Scalar pressure |
| `pxx`, `pyy`, `pzz`, `pxy`, `pxz`, `pyz` | Pxx ... Pyz (Pa) | Stress tensor components, kinetic contribution included |
| `vxx`, `vyy`, `vzz`, `vxy`, `vxz`, `vyz` | Vxx ... Vyz (Pa) | Virial tensor components, without the kinetic contribution |
| `smi` | sMises (Pa) | Von Mises equivalent stress |
| `vol` | Vol. (ang^3) | Simulation box volume |
| `mas` | Mass | Total mass |
| `bxa`, `bxb`, `bxc` | A, B, C (ang) | Box vector lengths |
| `baa`, `bab`, `bag` | alpha, beta, gamma (deg) | Box angles |
| `rho` | Rho (g/cm^3) | Density |

When a two-temperature model is active, the `ele` and `ite` columns are added at the end automatically if they are not already in the list.

!!! warning "Renamed keywords"
    The diagonal stress components are now `pxx`, `pyy`, `pzz` (formerly `prx`, `pry`, `prz`). Input files using the old names stop with an "unrecognized log_mode keyword" error.

### Column formats (`log_format`) { #log-format }

`log_format` is an optional `;`-separated list of printf-style formats, applied in order to the active columns. Fewer formats than columns only change the first columns, and an empty entry keeps the default format of that column:

```yaml linenums="1"
global:
  log_mode: "stp;pht;tmp;pre"
  log_format: "%9.0f;;%12.4f"     # step as integer, default time format, temperature with 4 decimals
```

### File writer options

`dump_thermodynamic_state` also accepts:

```{ .yaml title="Parameters" .params-block }
thermostate_file:     string, default "thermodynamic_state.csv"  # Output file (also settable in global).
print_header:         bool, default true          # Write the column header line.
internal_units:       bool, default false         # Write values in internal units instead of eV, K, Pa, g/cm^3.
force_flush_file:     bool, default false         # Flush the file after every write.
force_append_thermo:  bool, default false         # Append to an existing file instead of overwriting it.
is_dump_virial:       bool, default false         # Append the 9 raw virial components S11 ... S33 (Pa).
```

`print_thermodynamic_state` accepts `print_header` and `internal_units` (default `false` for both).

## Binary restart file

`write_restart` is `nop` by default; assign it one of the predefined aggregates from `config_restart.msp` (see [Restarts](../GettingStarted/configuration_files.md#restarts)) to activate restart writing, at the frequency set by `simulation_restart_frequency`:

```yaml linenums="1"
global:
  simulation_restart_frequency: 1000

write_restart: write_restart_atoms
```

This writes an exaNBody-native, MPI-IO binary dump (particles, velocities, domain, species and timestep) through `write_dump_atoms`, which can later be re-read with `read_dump_atoms` (see [Reading an atoms restart file](4_setup_system.md#reading-an-atoms-restart-file)). It also accepts `compression_level` (zlib level, default `6`) and `max_part_size` (file partition size, default: system value).

??? note "`write_restart_atoms` definition (`config_restart.msp`)"
    ```yaml linenums="1"
    write_restart_atoms:
      - timestep_file: "atoms_%09d.MpiIO"
      - message: { mesg: "Write restart " , endl: false }
      - print_restart_file:
          rebind: { mesg: filename }
          body:
            - message: { endl: true }
      - write_dump_atoms
    ```

## Snapshot file

`write_snapshot` is likewise `nop` by default; assign it a predefined aggregate to write snapshots for visualization, at the frequency set by `simulation_snapshot_frequency`. Two common formats:

```yaml linenums="1"
global:
  simulation_snapshot_frequency: 1000

write_snapshot: write_snapshot_xyz
```

`write_snapshot_xyz` writes a plain-text `.xyz` file (species name and position per atom) through `write_xyz_file`.

??? note "`write_snapshot_xyz` definition (`config_snapshot.msp`)"
    ```yaml linenums="1"
    write_snapshot_xyz:
      - timestep_file: "exaStamp_%09d.xyz"
      - message: { mesg: "Write xyz file" , endl: false }
      - print_dump_file:
          rebind: { mesg: filename }
          body:
            - message: { endl: true }
      - write_xyz_file
    ```

```yaml linenums="1"
global:
  simulation_snapshot_frequency: 1000

write_snapshot: write_snapshot_paraview
```

`write_snapshot_paraview` writes a Paraview/VTK file through `write_paraview`, including every available per-particle field (position, velocity, force, type, MPI rank, ...) by default — narrow it down with the `fields:` list of regular expressions if needed (e.g. `fields: [ "type", "vx|vy|vz" ]`).

??? note "`write_snapshot_paraview` definition (`config_snapshot.msp`)"
    ```yaml linenums="1"
    write_snapshot_paraview:
      - timestep_file: "paraview/output_%09d"
      - message: { mesg: "Write paraview file" , endl: false }
      - print_dump_file:
          rebind: { mesg: filename }
          body:
            - message: { endl: true }
      - write_paraview
    ```

!!! tip

    Both writers above output raw particle data. `exaNBody` can also project particle properties onto the parallelization grid and write that out instead (`write_grid_vtk`), which is much cheaper for large-scale, on-the-fly visualization — see [Output](../../User/E_Grids/output.md) in the Grids Features section.

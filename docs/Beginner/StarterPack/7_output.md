---
icon: lucide/folder-up
---

# Output Data

Output is controlled by the frequency variables already introduced in [Global Control](1_global.md), together with the writer operators below. This page only covers particle-level output (the `species`/positions/velocities you defined earlier) — see the tip at the end for grid-level output.

## Thermodynamic state (screen & file)

Printing the thermodynamic state to the screen and writing it to a `.csv` file are both enabled by default; only their frequency and format need to be set from `global`:

```yaml linenums="1"
global:
  simulation_thermostate_screen_frequency: 10   # print to screen every 10 steps
  simulation_thermostate_file_frequency: 10     # append to file every 10 steps
  thermostate_file: "thermodynamic_state.csv"
  log_mode: mechanical
```

`log_mode` selects which columns `print_thermodynamic_state` prints to screen (`mechanical`, `default`/`thermo_basic`, `thermo`/`thermo_full`, `vol_fluct_ortho[_basic]`, `vol_fluct_tricl[_basic]`, or a custom `;`-separated list of item names). The file writer (`dump_thermodynamic_state`) always writes the same fixed set of columns (step, time, energies, temperature, stress tensor, box, volume, density) to `thermostate_file`.

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

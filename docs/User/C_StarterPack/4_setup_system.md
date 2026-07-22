---
icon: lucide/hard-drive-upload
---

# Input Data

Populating the simulation domain with particles is done through the `setup_system` block, called in the `simulation` graph right after `init_prolog`:

```yaml linenums="1" hl_lines="7"
simulation:
  name: MySimulation
  body:
    - [...]
    - domain
    - init_prolog
    - setup_system
    - species: { verbose: false, fail_if_empty: true }
    - [...]
```

`setup_system` is a user-defined batch: you provide your own list of operators, replacing the default one (which just tries to read a legacy restart file, see [System setup](../B_GettingStarted/configuration_files.md#system-setup)). Two common ways of populating the domain are shown below: generating a crystal lattice, or reading particle positions from an external file. For the latter, we provide two examples where the external file is either an XYZ file or a binary restart file.

## Generating a crystal lattice

To fill the domain with a regular crystal structure, fully define `domain` (`cell_size`, `grid_dims`, `bounds`), distribute the grid across MPI ranks with `init_rcb_grid`, then call `lattice`:

```yaml linenums="1"
setup_system:
  - domain:
      cell_size: 3.3 ang
      grid_dims: [ 20, 20, 20 ]
      bounds: [ [ 0 ang, 0 ang, 0 ang ], [ 66 ang, 66 ang, 66 ang ] ]
      periodic: [ true, true, true ]
      expandable: false
  - init_rcb_grid
  - lattice:
      structure: BCC
      types: [ Ta, Ta ]
      size: [ 3.3 ang, 3.3 ang, 3.3 ang ]
  - init_temperature_new:
      T: 600 K
```

`structure` selects a predefined unit cell (`SC`, `BCC`, `2BCT`, `FCC`, `HCP`, `h-DIA`, `c-DIA`, `graphite`, or `CUSTOM` with an explicit `positions:` list), `types` assigns a species name (declared beforehand in `species`) to each atom of the unit cell — the required count depends on `structure` (`SC`: 1, `BCC`: 2, `2BCT`/`FCC`/`HCP`: 4, `c-DIA`/`h-DIA`/`graphite`: 8) — and `size` gives the unit cell's edge lengths, replicated to fill `domain`.

!!! note

    `init_rcb_grid` must be called between `domain` and `lattice`: it partitions the grid across MPI ranks so `lattice` can generate particles directly into each rank's own block.

`lattice` also accepts a `region:` (a region name or boolean expression of regions, see [Domain & Regions](../D_DomainRegions/regions.md)) to restrict generation to part of the domain, and `void_mode`/`void_center`/`void_radius`/`void_porosity` to carve out a cavity or a target porosity.

`lattice` only places atoms — it doesn't give them any velocity, so the system starts at 0 K. `init_temperature_new`, called as the last `setup_system` step above, draws random (Maxwell-Boltzmann) velocities and rescales them so the system starts at `T` (here 600 K); it also accepts `override_velocities`/`add_velocities`/`scale_velocities` (mutually exclusive; default is `override_velocities: true`), `distribution` (`"gaussian"` or `"uniform"`), and `zero_linear_momentum` (removes net drift, default `true`).

## Reading an XYZ file

`read_extended_xyz_file` reads particles from an extended XYZ file (OVITO/ASE-compatible format): particle count on line 1, a comment line 2 with `Lattice="..."` (the full row-major 3x3 cell matrix, so triclinic cells are supported) and `Properties=species:S:1:pos:R:3[:velo:R:3]`, then one data line per atom:

```yaml linenums="1"
setup_system:
  - domain:
      cell_size: 5.0 ang
      periodic: [ true, true, false ]
  - read_extended_xyz_file:
      filename: my_system.xyz
      bounds_mode: FILE
      read_velocities: true
```

`bounds_mode` tells `exaStamp` which domain bounds to keep: `FILE` (the cell matrix from the `Lattice=` key), `DOMAIN` (the `bounds:` you gave in `domain`), or `COMPUTED` (the bounding box of the atoms actually read); the domain's `xform` is set from the file's cell matrix accordingly. `grid_dims` doesn't need to be set — it's deduced from the resulting bounds and `cell_size`. Set `read_velocities: false` if you do not want to read a `velo` column from the file. If a `species` block was already declared, atom types in the file are matched to it by name; any unmatched name is added as a new species automatically.

!!! note

    This operator is also registered under the name `read_xyz_file_with_xform`; both names call the same operator. The older `read_xyz_file` only supports a simple axis-aligned box size on line 2 and no velocities — prefer `read_extended_xyz_file` for new input files.

## Reading an atoms restart file

`read_dump_atoms` restores particles, velocities, domain and species from a restart file written by a previous run (see [Restarts](../B_GettingStarted/configuration_files.md#restarts)):

```yaml linenums="1"
setup_system:
  - read_dump_atoms:
      filename: atoms_000010000.MpiIO
```

The domain, timestep and species are all restored from the file, so no separate `domain` block is needed. `read_dump_atoms` also accepts optional overrides — `periodic`, `mirror`, `expandable`, `bounds` (with `shrink_to_fit`) and `scale_cell_size` — if you need to change one of these aspects compared to when the restart file was written.

!!! note

    Unlike `lattice`, neither reader needs `init_rcb_grid`: they load all particles first, and the graph's later load-balancing step (`init_particles`, run right after `setup_system`) redistributes them evenly across MPI ranks.

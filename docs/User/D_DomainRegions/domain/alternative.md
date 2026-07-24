---
icon: material/source-branch
---

# **Alternative ways for defining the domain**

The simulation domain doesn't always need to be fully defined through the [`domain`](defining.md) operator itself — it can instead be derived from a particle-generation operator, or already be contained in an external file.

## **Built-in particles creators**

- `lattice`: Replicates a unit cell (SC, BCC, FCC, HCP, …) into a **pre-existing, fully-defined** `domain`. Unlike `bulk_lattice` below, it does not derive or resize the domain itself.

    !!! warning

        `lattice` requires `domain` to be fully defined *and* `init_rcb_grid` to be called in between `domain` and `lattice`, so the grid is already partitioned across MPI ranks before particles are generated into it:

        ```yaml
        input_data:
          - domain: { ... }
          - init_rcb_grid
          - lattice: { ... }
        ```

- `bulk_lattice`: The system shape and size is created according to the replication in the 3D space of a unit cell chosen by the user, from which a matching `domain` is derived (`grid_dims`, `xform`, `bounds` are computed from the lattice and the repeat count). It performs its own grid partitioning internally, so it does **not** need a separate `init_rcb_grid` step.

    !!! warning

        `bulk_lattice` unconditionally sets the domain's `periodic` flag to `[true, true, true]` — it is designed to generate a perfectly commensurate, fully 3D-periodic domain, and this cannot be overridden through the operator's parameters. If you need non-periodic or mixed boundary conditions, use `lattice` with a pre-defined `domain` instead.

See [Particles Features → Input](../../F_Particles/input.md) for the full set of built-in particle generators.

## **External file readers**

- `read_xyz_file_with_xform`: Instead of creating the system from a template, an external `.xyz` file is read in which the number of atoms, their positions and the simulation cell size and shape are provided. In that case, only the `cell_size` property of the `domain` YAML block is needed.
- `read_dump_atoms`: The simulation starts at a specific timestep for which a restart file was generated. That restart file usually contains all information for the simulation domain.
- `read_dump_molecule`: Same as above but for flexible molecules.
- `read_dump_rigidmol`: Same as above but for rigid molecules.

See [Particles Features → Input](../../F_Particles/input.md) for the full parameter reference of these readers.

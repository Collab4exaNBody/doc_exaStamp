---
icon: lucide/cuboid
---

# Simulation Domain

The simulation box — its size, shape, cell decomposition and periodicity — is defined by the `domain` block, called in the `simulation` graph before `setup_system`:

```yaml linenums="1" hl_lines="7"
simulation:
  name: MySimulation
  body:
    - [...]
    - particle_regions
    - preinit_rcut_max
    - domain
    - init_prolog
    - setup_system
    - [...]
```

## The `domain` block

```yaml linenums="1"
domain:
  cell_size: 5.0 ang
  grid_dims: [ 20, 20, 20 ]
  bounds: [ [ 0 ang, 0 ang, 0 ang ], [ 100 ang, 100 ang, 100 ang ] ]
  xform: [ [ 1., 0., 0. ], [ 0., 1., 0. ], [ 0., 0., 1. ] ]
  periodic: [ true, true, true ]
  mirror: []
  expandable: false
```

??? note "Parameters' description"

    | Property     | Type      | Default            | Description                                                         |
    | :------------ | :-------: | :----------------: | :-------------------------------------------------------------------- |
    | `cell_size`   | `float`   | `0.0`              | Size of a grid cell (used for parallel domain decomposition)         |
    | `grid_dims`   | `IJK`     | `[0,0,0]`           | Number of cells along each axis; if `0,0,0`, deduced from `bounds` and `cell_size` |
    | `bounds`      | `AABB`    | `[[0,0,0],[0,0,0]]` | Domain bounds `[[xmin,ymin,zmin],[xmax,ymax,zmax]]`                    |
    | `xform`       | `Mat3d`   | identity            | Grid space → physical space transformation matrix (for non-orthorhombic/triclinic domains) |
    | `periodic`    | `[bool;3]`| `[false,false,false]` | Periodic boundary conditions along each axis                       |
    | `mirror`      | `list`    | `[]`                | Mirror (reflective) boundary conditions, e.g. `[ "X-", "Z" ]` for a mirror at the lower X bound and both Z bounds |
    | `expandable`  | `bool`    | `true`              | Whether the domain is allowed to grow to contain particles that move outside its bounds |

!!! warning

    `periodic` and `mirror` are mutually exclusive per axis: setting one on a given bound disables the other.

`exaStamp`'s own default (in `main-config.msp`) leaves `cell_size`/`grid_dims` at `0`, so they are automatically deduced from the interatomic potential's cutoff radius, and sets `expandable: false`.

For the full derivation of the physical-space/grid-space transform, more `xform` examples (orthorhombic, triclinic domains) and alternative ways of defining a domain (from a lattice template, an external file, or a restart), see [Simulation Domain](../D_DomainRegions/domain.md) in the Domain & Regions reference section.

## Expandable domains

If `expandable: true` and the domain isn't fully periodic, the `extend_domain` operator (run automatically as part of `init_particles` and at every full particle update) grows the domain's bounds to keep containing any particle that has drifted outside them, rather than losing it. A fully periodic domain cannot be expandable — `exaStamp` will disable it and print a warning if both are set together.

## Filling the domain

Defining `domain` only reserves the simulation box — it doesn't create any particle. Populating it (e.g. with the `lattice` operator, or by reading particles from an external file) is done as part of `setup_system`, covered on the next page.

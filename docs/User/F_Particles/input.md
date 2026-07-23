---
icon: material/import
---

# Input

Particles can be created in a simulation two ways: replicated from a crystal lattice (or packed via Random Sequential Addition) directly by `exaStamp`, or read from an external file. See [Domain & Regions](../D_DomainRegions/domain.md#built-in-particles-creators) for how each of these interacts with the `domain` definition.

## Built-in particle creation

### `lattice` and `bulk_lattice`

Both replicate a crystallographic unit cell into 3D space and share the parameters below. See [Domain & Regions](../D_DomainRegions/domain.md#built-in-particles-creators) for the key difference between the two: `lattice` needs a pre-defined `domain` and a preceding `init_rcb_grid`, while `bulk_lattice` derives the domain from `repeat` and manages its own grid partitioning internally (and unconditionally forces full 3D periodicity).

| Property | Description | Data Type | Default |
|---|---|---|---|
| `structure` | Crystal structure: `SC`, `BCC`, `FCC`, `2BCT`, `HCP`, `h-DIA`, `c-DIA`, `graphite`, or `CUSTOM`. | string | *(required)* |
| `types` | Particle type name(s) for each atom in the unit cell — the required count depends on `structure` (see below). | list of strings | *(required)* |
| `size` | Unit cell edge lengths. | Vec3d | *(required)* |
| `positions` | Fractional atom positions within the unit cell — only used (and required) when `structure: CUSTOM`. | list of Vec3d | *(none)* |
| `shift` | Shifts all generated atomic positions. | Vec3d | `[0,0,0]` |
| `deterministic_noise` | Use a deterministic seed for any random noise, so results don't depend on the MPI/OpenMP decomposition. | bool | `false` |
| `repeat` *(`bulk_lattice` only)* | Number of unit-cell replications along x, y, z — also drives the derived domain size. | IJK | `[1,1,1]` |

Required `types` length per `structure`:

| `structure` | atoms per unit cell |
|---|---|
| `SC` | 1 |
| `BCC` | 2 |
| `FCC`, `2BCT`, `HCP` | 4 |
| `c-DIA`, `h-DIA`, `graphite` | 8 |
| `CUSTOM` | as given (must match `positions`) |

```yaml
lattice:
  structure: BCC
  types: [ Ta, Ta ]
  size: [ 3.3 ang, 3.3 ang, 3.3 ang ]
```

#### Cutting voids

`void_mode` carves particles out of the generated lattice:

| Property | Description | Data Type | Default |
|---|---|---|---|
| `void_mode` | `none`, `simple` (a single spherical void) or `porosity` (randomly-placed voids to a target porosity). | string | `"none"` |
| `void_center` | Center of the void — `simple` mode only. | Vec3d | `[0,0,0]` |
| `void_radius` | Radius of the void — `simple` mode only. | float | `0.` |
| `void_porosity` | Target porosity fraction — `porosity` mode only. | float | `0.` |
| `void_mean_diameter` | Mean void diameter — `porosity` mode only. | float | `0.` |

#### Restricting where particles are placed

By default, `lattice`/`bulk_lattice` fill the entire domain. Three independent, combinable filters can restrict that — a particle is only generated where *all* of the filters that were given agree:

| Property | Description | Data Type | Default |
|---|---|---|---|
| `region` | A single region name, or a boolean expression of names (`and`/`or`/`not`, parentheses) referencing regions declared in a `particle_regions` block. | string | *(none)* |
| `grid_cell_values` / `grid_cell_mask_name` / `grid_cell_mask_value` | Restrict to grid (sub)cells whose named field — built with `set_cell_values` or `read_cell_values` — is exactly equal to `grid_cell_mask_value`. | GridCellValues / string / float | *(none)* |
| `user_function` / `user_threshold` | Restrict to points where a scalar source-term function (`wavefront`, `sphere`, `constant`) evaluates to at least `user_threshold`. | source term / float | *(none)* / `0.0` |

```yaml
particle_regions:
  - HALFSPACE:
      quadric: { shape: { plane: [ 1, 0, 0, 0 ] } }

lattice:
  structure: BCC
  types: [ Ta, Ta ]
  size: [ 3.3 ang, 3.3 ang, 3.3 ang ]
  region: HALFSPACE
  grid_cell_mask_name: POROSITY_MASK
  grid_cell_mask_value: 1
```

See [Domain & Regions → Spatial Regions](../D_DomainRegions/regions.md) for how `region` expressions and quadric shapes work, [Grid mask defined regions](../D_DomainRegions/regions.md#grid-mask-defined-regions) for building/using a `grid_cell_mask`, and [User-defined source term](../D_DomainRegions/regions.md#user-defined-source-term) for `user_function`.

### `init_rsa`

Packs particles via Random Sequential Addition (randomly-placed, non-overlapping spheres) rather than a crystal lattice.

| Property | Description | Data Type | Default |
|---|---|---|---|
| `bounds` | Region to pack. If the domain is already defined, only the intersection of `bounds` with it is filled; if not, the domain is built from `bounds`. | AABB | *(none)* |
| `type` | Single-species particle type — an integer id or a species name (resolved via `particle_type_map`). Ignored if `rsa_species` is set. | int or string | *(none)* |
| `radius` | Single-species particle radius. Ignored if `rsa_species` is set. | float | *(none)* |
| `nb_particles` | Single-species exact number of particles to place; if unset, packs as densely as possible. Ignored if `rsa_species` is set. | int | *(none)* |
| `rsa_species` | Multi-species packing: list of `[radius, nb_particles, type]` entries — overrides `radius`/`type`/`nb_particles`. | list | *(none)* |
| `enlarge_bounds` | Enlarges the packing region beyond `bounds`. | float | `0.` |
| `pbc_adjust_xform` | Adjust the domain's `xform` to identity before packing (needed for periodicity to work correctly). | bool | `true` |
| `seed` | Seed for the RSA pseudo-random generator. | int | `0` |
| `verbose` | Print per-round packing diagnostics (miss rate, shot counts). | bool | `false` |

```yaml
init_rsa:
  bounds: [[0 ang,0 ang,0 ang],[200 ang,200 ang,200 ang]]
  rsa_species:
    - [ 0.5 ang, 100, Ta ]
    - [ 0.25 ang, 200, Cu ]
```

### `grid_insert_particles`

Inserts an explicit, hand-written list of particles directly into the grid — useful for a handful of manually-placed particles rather than a generated system. Each entry needs a `pos`; `vel` and `type` are optional (`type` defaults to `"0"`).

```yaml
grid_insert_particles:
  particles:
    - { pos: [0. ang, 0. ang, 0. ang], type: Ta }
    - { pos: [5. ang, 0. ang, 0. ang], type: Ta, vel: [0.1 ang/ps, 0., 0.] }
```

## Reading external files

Two different needs fall under "reading files": resuming a simulation from `exaStamp`'s own binary checkpoint, and reading a system built or exported by another tool.

### Restart files (binary dumps)

`read_dump_atoms`, `read_dump_molecule`, `read_dump_rigidmol` resume a simulation from `exaStamp`'s own binary restart/dump file — for atomic systems, flexible molecules, and rigid molecules respectively. All three share the same core parameters:

| Property | Description | Data Type | Default |
|---|---|---|---|
| `filename` | Path to the restart file. | string | *(required)* |
| `timestep` | Overwritten with the iteration number stored in the file. | int | *(none)* |
| `physical_time` | Overwritten with the physical time stored in the file. | float | *(none)* |
| `scale_cell_size` | If set, rescales the cell size stored in the file by this factor. | float | *(none)* |
| `periodic` | If set, overrides the domain's periodicity stored in the file. | 3 booleans | *(none)* |
| `mirror` | If set, overrides the domain's mirror flags stored in the file (same string codes as [`domain`](../D_DomainRegions/domain.md)). | list of strings | *(none)* |
| `expandable` | If set, overrides the domain's expandability stored in the file. | bool | *(none)* |
| `bounds` | If set, overrides the domain's bounds, filtering out particles that fall outside the new bounds. | AABB | *(none)* |
| `shrink_to_fit` | If `true` (and `bounds` was given), shrinks the domain's grid to the minimum size enclosing the new `bounds`. | bool | *(none)* |

```yaml
read_dump_atoms:
  filename: "checkpoint_000100.dump"
```

`read_dump_molecule` additionally restores every intramolecular force-field parameter (`potentials_for_bonds`, `potentials_for_angles`, `potentials_for_torsions`, `potentials_for_impropers`, …) — see [Bonding Potentials](../G_ForceFields/Intramolecular/index.md).

### Files generated by external tools

`read_xyz_file` and `read_xyz_file_with_xform` read a plain `.xyz` file — typically a system built or converted by an external tool (e.g. Atomsk, OVITO) rather than written by `exaStamp` itself.

#### `read_xyz_file`

Reads particle positions from a plain `.xyz` file.

| Property | Description | Data Type | Default |
|---|---|---|---|
| `file` | Path to the `.xyz` file. | string | *(required)* |
| `species` | Species list used to validate/assign particle types. If omitted, type IDs are allocated automatically from the types found in the file. | list | *(none)* |
| `bounds_mode` | How the domain bounds are determined: `FILE` (bounds stored in the file), `COMPUTED` (min/max of all particle positions read), or `DOMAIN` (use the `domain:` block's own bounds, ignoring the file). | string | `"FILE"` |
| `enlarge_bounds` | Enlarges the computed/file bounds by this amount on every side. | float | `0.` |
| `pbc_adjust_xform` | Reset the domain's `xform` to identity before applying periodic-boundary adjustments (the `xform` must already be identity). | bool | `false` |

```yaml
read_xyz_file:
  file: input.xyz
  bounds_mode: COMPUTED
```

#### `read_xyz_file_with_xform`

Like `read_xyz_file`, but also reads a transformation matrix from the file — used when the system's cell shape/orientation is stored alongside the positions, not just its size.

| Property | Description | Data Type | Default |
|---|---|---|---|
| `filename` | Path to the `.xyz` file. | string | *(required)* |
| `species` | Species list used to validate/assign particle types. | list | *(none)* |
| `bounds_mode` | Same as `read_xyz_file` above. | string | `"FILE"` |
| `read_velocities` | Also read per-particle velocities from the file. | bool | `false` |

### Other formats

A few more readers exist for specific molecule and legacy formats — `read_xyz_molecules`, `read_xyz_rigidmol`, `read_fatomes_mol`, `read_stamp_v3`, `read_stamp_v4`. These aren't part of the common workflow above and see comparatively little use; some cover formats specific to older, predecessor codes and may eventually be retired.

---
icon: material/import
---

# **Input**

Particles can be created in a simulation two ways: replicated from a crystal lattice (or packed via Random Sequential Addition) directly by `exaStamp`, or read from an external file. See [Domain & Regions](../D_DomainRegions/domain/alternative.md#built-in-particles-creators) for how each of these interacts with the `domain` definition.

## **Built-in particle creation**

### `lattice` and `bulk_lattice`

```{ .yaml title="Syntax: lattice" .syntax-block }
lattice:
  structure: <string>
  types: [<string>, ...]
  size: [<float>, <float>, <float>]
  positions: [[<float>, <float>, <float>], ...]
  shift: [<float>, <float>, <float>]
  deterministic_noise: <bool>
```

```{ .yaml title="Syntax: bulk_lattice" .syntax-block }
bulk_lattice:
  structure: <string>
  types: [<string>, ...]
  size: [<float>, <float>, <float>]
  positions: [[<float>, <float>, <float>], ...]
  shift: [<float>, <float>, <float>]
  deterministic_noise: <bool>
  repeat: [<int>, <int>, <int>]
```

```{ .yaml title="Parameters" .params-block }
structure:            string, required           # Crystal structure: SC, BCC, FCC, 2BCT, HCP, h-DIA, c-DIA, graphite, or CUSTOM.
types:                list of strings, required  # Particle type name(s) for each atom in the unit cell (count depends on structure).
size:                 Vec3d, required            # Unit cell edge lengths.
positions:            list of Vec3d, optional    # Fractional atom positions — required only for structure: CUSTOM.
shift:                Vec3d, default [0,0,0]     # Shifts all generated atomic positions.
deterministic_noise:  bool, default false        # Deterministic seed for any random noise, independent of the MPI/OpenMP decomposition.
repeat:               IJK, default [1,1,1]       # bulk_lattice only — unit-cell replications along x, y, z; also drives the derived domain size.
```

Both replicate a crystallographic unit cell into 3D space and share the parameters above. See [Domain & Regions](../D_DomainRegions/domain/alternative.md#built-in-particles-creators) for the key difference between the two: `lattice` needs a pre-defined `domain` and a preceding `init_rcb_grid`, while `bulk_lattice` derives the domain from `repeat` and manages its own grid partitioning internally (and unconditionally forces full 3D periodicity).

Required `types` length per `structure`:

| `structure` | atoms per unit cell |
|---|---|
| `SC` | 1 |
| `BCC` | 2 |
| `FCC`, `2BCT`, `HCP` | 4 |
| `c-DIA`, `h-DIA`, `graphite` | 8 |
| `CUSTOM` | as given (must match `positions`) |

```yaml title="Usage example"
lattice:
  structure: BCC
  types: [ Ta, Ta ]
  size: [ 3.3 ang, 3.3 ang, 3.3 ang ]
```

#### Cutting voids

`void_mode` carves particles out of the generated lattice:

```{ .yaml title="Parameters" .params-block }
void_mode:           string, default "none"      # none, simple (a single spherical void) or porosity (randomly-placed voids to a target porosity).
void_center:         Vec3d, default [0,0,0]      # Center of the void — simple mode only.
void_radius:         float, default 0.           # Radius of the void — simple mode only.
void_porosity:       float, default 0.           # Target porosity fraction — porosity mode only.
void_mean_diameter:  float, default 0.           # Mean void diameter — porosity mode only.
```

#### Restricting where particles are placed

By default, `lattice`/`bulk_lattice` fill the entire domain. Three independent, combinable filters can restrict that — a particle is only generated where *all* of the filters that were given agree:

```{ .yaml title="Parameters" .params-block }
region:                string, optional          # Region name or boolean expression referencing `particle_regions`.
grid_cell_values:      GridCellValues, optional  # Named field built with set_cell_values/read_cell_values.
grid_cell_mask_name:   string, optional          # Field name to test.
grid_cell_mask_value:  float, optional           # Value the field must exactly equal.
user_function:         source term, optional     # Scalar source-term function (wavefront, sphere, constant).
user_threshold:        float, default 0.0        # Minimum value user_function must reach.
```

`grid_cell_values`/`grid_cell_mask_name`/`grid_cell_mask_value` restrict to grid (sub)cells whose named field — built with `set_cell_values` or `read_cell_values` — is exactly equal to `grid_cell_mask_value`.

```yaml title="Usage example"
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

See [Defining regions](../D_DomainRegions/regions/geometric.md) for how quadric shapes work, [Combining regions](../D_DomainRegions/regions/restricting.md#combining-regions) for `region` boolean expressions, [Grid mask defined regions](../D_DomainRegions/regions/restricting.md#grid-mask-defined-regions) for building/using a `grid_cell_mask`, and [User-defined source term](../D_DomainRegions/regions/restricting.md#user-defined-source-term) for `user_function`.

### `init_rsa`

```{ .yaml title="Syntax" .syntax-block }
init_rsa:
  bounds: [[<float>, <float>, <float>], [<float>, <float>, <float>]]
  type: <int_or_string>
  radius: <float>
  nb_particles: <int>
  rsa_species: [[<float>, <int>, <string>], ...]
  enlarge_bounds: <float>
  pbc_adjust_xform: <bool>
  seed: <int>
  verbose: <bool>
```

```{ .yaml title="Parameters" .params-block }
bounds:            AABB, optional             # Region to pack; domain is built from bounds if not already defined.
type:              int or string, optional    # Single-species particle type. Ignored if rsa_species is set.
radius:            float, optional            # Single-species particle radius. Ignored if rsa_species is set.
nb_particles:      int, optional              # Single-species exact particle count; packs as densely as possible if unset.
rsa_species:       list, optional             # Multi-species packing: [radius, nb_particles, type] entries — overrides radius/type/nb_particles.
enlarge_bounds:    float, default 0.          # Enlarges the packing region beyond bounds.
pbc_adjust_xform:  bool, default true         # Adjusts the domain's xform to identity before packing (needed for periodicity to work correctly).
seed:              int, default 0             # Seed for the RSA pseudo-random generator.
verbose:           bool, default false        # Print per-round packing diagnostics (miss rate, shot counts).
```

Packs particles via Random Sequential Addition (randomly-placed, non-overlapping spheres) rather than a crystal lattice.

```yaml title="Usage example"
init_rsa:
  bounds: [[0 ang,0 ang,0 ang],[200 ang,200 ang,200 ang]]
  rsa_species:
    - [ 0.5 ang, 100, Ta ]
    - [ 0.25 ang, 200, Cu ]
```

### `grid_insert_particles`

```{ .yaml title="Syntax" .syntax-block }
grid_insert_particles:
  particles:
    - { pos: [<float>, <float>, <float>], vel: [<float>, <float>, <float>], type: <string> }
```

```{ .yaml title="Parameters" .params-block }
pos:   Vec3d, required     # Particle position.
vel:   Vec3d, optional     # Particle velocity.
type:  string, default "0" # Particle type name.
```

Inserts an explicit, hand-written list of particles directly into the grid — useful for a handful of manually-placed particles rather than a generated system.

```yaml title="Usage example"
grid_insert_particles:
  particles:
    - { pos: [0. ang, 0. ang, 0. ang], type: Ta }
    - { pos: [5. ang, 0. ang, 0. ang], type: Ta, vel: [0.1 ang/ps, 0., 0.] }
```

## **Reading external files**

Two different needs fall under "reading files": resuming a simulation from `exaStamp`'s own binary checkpoint, and reading a system built or exported by another tool.

### Restart files (binary dumps)

`read_dump_atoms`, `read_dump_molecule`, `read_dump_rigidmol` resume a simulation from `exaStamp`'s own binary restart/dump file — for atomic systems, flexible molecules, and rigid molecules respectively. They share a common core of parameters; `mirror` uses the same string codes as [`domain`](../D_DomainRegions/domain/defining.md).

#### `read_dump_atoms`

```{ .yaml title="Syntax" .syntax-block }
read_dump_atoms:
  filename: <string>
  scale_cell_size: <float>
  periodic: [<bool>, <bool>, <bool>]
  mirror: [<string>, ...]
  expandable: <bool>
  bounds: [[<float>, <float>, <float>], [<float>, <float>, <float>]]
  shrink_to_fit: <bool>
```

```{ .yaml title="Parameters" .params-block }
filename:         string, required          # Path to the restart file.
timestep:         int, output               # Overwritten with the iteration number stored in the file.
physical_time:    float, output             # Overwritten with the physical time stored in the file.
scale_cell_size:  float, optional           # Rescales the cell size stored in the file by this factor.
periodic:         3 booleans, optional      # Overrides the domain's periodicity stored in the file.
mirror:           list of strings, optional # Overrides the domain's mirror flags stored in the file (same codes as `domain`).
expandable:       bool, optional            # Overrides the domain's expandability stored in the file.
bounds:           AABB, optional            # Overrides the domain's bounds, filtering out particles that fall outside the new bounds.
shrink_to_fit:    bool, optional            # If true (and bounds was given), shrinks the domain's grid to the minimum size enclosing the new bounds.
```

Resumes an atomic-system simulation. This is the minimal variant — a `species` block declared earlier is optional (falls back to whatever the file itself provides).

```yaml title="Usage example"
read_dump_atoms:
  filename: "checkpoint_000100.dump"
```

#### `read_dump_molecule`

```{ .yaml title="Syntax" .syntax-block }
read_dump_molecule:
  filename: <string>
  scale_cell_size: <float>
  periodic: [<bool>, <bool>, <bool>]
  mirror: [<string>, ...]
  expandable: <bool>
  bounds: [[<float>, <float>, <float>], [<float>, <float>, <float>]]
  shrink_to_fit: <bool>
```

```{ .yaml title="Parameters" .params-block }
filename:         string, required          # Path to the restart file.
species:          required                  # Must already be declared (via `species`/`particle_types`) — unlike read_dump_atoms, this is mandatory here.
scale_cell_size:  float, optional           # Rescales the cell size stored in the file by this factor.
periodic:         3 booleans, optional      # Overrides the domain's periodicity stored in the file.
mirror:           list of strings, optional # Overrides the domain's mirror flags stored in the file (same codes as `domain`).
expandable:       bool, optional            # Overrides the domain's expandability stored in the file.
bounds:           AABB, optional            # Overrides the domain's bounds, filtering out particles that fall outside the new bounds.
shrink_to_fit:    bool, optional            # If true (and bounds was given), shrinks the domain's grid to the minimum size enclosing the new bounds.
```

Resumes a flexible-molecule simulation. It additionally restores every intramolecular force-field parameter from the dump file's own header — `potentials_for_bonds`, `potentials_for_angles`, `potentials_for_torsions`, `potentials_for_impropers`, `potentials_for_pairs`, `mol_pair_weights`, and the `molecules` topology itself — see [Bonding Potentials](../G_ForceFields/Intramolecular/index.md).

```yaml title="Usage example"
read_dump_molecule:
  filename: "checkpoint_000100.dump"
```

#### `read_dump_rigidmol`

```{ .yaml title="Syntax" .syntax-block }
read_dump_rigidmol:
  filename: <string>
  scale_cell_size: <float>
  periodic: [<bool>, <bool>, <bool>]
  mirror: [<string>, ...]
  expandable: <bool>
  bounds: [[<float>, <float>, <float>], [<float>, <float>, <float>]]
  shrink_to_fit: <bool>
```

```{ .yaml title="Parameters" .params-block }
filename:         string, required          # Path to the restart file.
species:          required                  # Must already be declared, same as read_dump_molecule.
scale_cell_size:  float, optional           # Rescales the cell size stored in the file by this factor.
periodic:         3 booleans, optional      # Overrides the domain's periodicity stored in the file.
mirror:           list of strings, optional # Overrides the domain's mirror flags stored in the file (same codes as `domain`).
expandable:       bool, optional            # Overrides the domain's expandability stored in the file.
bounds:           AABB, optional            # Overrides the domain's bounds, filtering out particles that fall outside the new bounds.
shrink_to_fit:    bool, optional            # If true (and bounds was given), shrinks the domain's grid to the minimum size enclosing the new bounds.
```

Resumes a rigid-molecule simulation. Rigid-body orientation and angular momentum are restored as ordinary per-particle grid fields read straight from the file, not as separate operator parameters.

```yaml title="Usage example"
read_dump_rigidmol:
  filename: "checkpoint_000100.dump"
```

### Files generated by external tools

`read_xyz_file` and `read_xyz_file_with_xform` read a plain `.xyz` file — typically a system built or converted by an external tool (e.g. Atomsk, OVITO) rather than written by `exaStamp` itself.

#### `read_xyz_file`

```{ .yaml title="Syntax" .syntax-block }
read_xyz_file:
  file: <string>
  species: [<string>, ...]
  bounds_mode: <FILE_or_COMPUTED_or_DOMAIN>
  enlarge_bounds: <float>
  pbc_adjust_xform: <bool>
```

```{ .yaml title="Parameters" .params-block }
file:              string, required         # Path to the .xyz file.
species:           list, optional           # Species list to validate/assign particle types; auto-allocated from the file if omitted.
bounds_mode:        enum, default FILE       # FILE (bounds stored in file), COMPUTED (min/max of read positions), or DOMAIN (use domain: block's own bounds).
enlarge_bounds:    float, default 0.        # Enlarges the computed/file bounds by this amount on every side.
pbc_adjust_xform:  bool, default false      # Reset the domain's xform to identity before periodic-boundary adjustments (xform must already be identity).
```

Reads particles from a bare, non-extended `.xyz` file: a particle count line, one line consumed as the box size, then one `type x y z` row per particle.

```text title="File format"
<atom count>
<box_size_x> <box_size_y> <box_size_z>
<type_1> <x_1> <y_1> <z_1>
<type_2> <x_2> <y_2> <z_2>
...
```

```yaml title="Usage example"
read_xyz_file:
  file: input.xyz
  bounds_mode: COMPUTED
```

!!! warning "The second line is not a free comment"

    Despite what the operator's own source comment claims ("a comment, not read by the code"), the second line **is** parsed — as three numbers, `box_size_x box_size_y box_size_z` — and used as the domain bounds when `bounds_mode: FILE`. A genuinely free-text comment line here will fail to parse as three numbers. This is a real mismatch between the code's own comment and its actual behavior, not just a docs gap.

    Also note: the atom-count on line 1 is parsed but not actually enforced — the reader keeps going until end of file regardless of that number.

No unit conversion is applied to the coordinates: numbers in the file are read as-is in `exaStamp`'s internal length unit (Å). If `species` is omitted, type IDs are auto-allocated in the order each type name is first encountered.

#### `read_xyz_file_with_xform`

```{ .yaml title="Syntax" .syntax-block }
read_xyz_file_with_xform:
  filename: <string>
  species: [<string>, ...]
  bounds_mode: <FILE_or_COMPUTED_or_DOMAIN>
  read_velocities: <bool>
```

```{ .yaml title="Parameters" .params-block }
filename:         string, required     # Path to the .xyz file.
species:          list, optional       # Species list to validate/assign particle types.
bounds_mode:      enum, default FILE   # See note below — behaves like `read_xyz_file` for DOMAIN, but FILE and COMPUTED are the same thing here.
read_velocities:  bool, default false  # Also read per-particle velocities from the file — requires velocity columns to be declared (see Properties= below).
```

Reads the **extended XYZ** format (OVITO/ASE-compatible) instead of the bare format above — the same particle data, but with the simulation cell and column layout described in the file itself rather than assumed:

```text title="File format"
<atom count>
Lattice="a1x a1y a1z b1x b1y b1z c1x c1y c1z" Properties=species:S:1:pos:R:3[:velo:R:3]
<type_1> <x_1> <y_1> <z_1> [<vx_1> <vy_1> <vz_1>]
...
```

`Lattice="..."` (a quoted, row-major 3×3 cell matrix) is **mandatory** — the operator aborts if it's missing. `Properties=...` is optional: if it isn't given, the reader falls back to a plain `species x y z` column layout (this is in fact what every real `.xyz`/regression file in the repo relies on — none of them actually specify `Properties=`). `read_velocities: true` requires a `:velo:R:3` entry in `Properties=`; without one, the operator aborts rather than silently skipping velocities.

```text title="Real example (exaStamp/data/regression_new/mliaps/pod/Ta_disturbed.xyz)"
16000
Lattice="6.600000000000e+01 0.000000000000e+00 0.000000000000e+00 0.000000000000e+00 6.600000000000e+01 0.000000000000e+00 0.000000000000e+00 0.000000000000e+00 6.600000000000e+01"
Ta        3.3832764081e+00  3.2242631539e+00  3.2969133505e+00
...
```

```yaml title="Usage example"
read_xyz_file_with_xform:
  filename: "input_Ta.xyz"
  read_velocities: true
```

!!! note "`bounds_mode` behaves slightly differently here than in `read_xyz_file`"

    `FILE` uses the box edge lengths derived from `Lattice=`'s row vectors, same as you'd expect. `COMPUTED`, however, does **not** compute a separate bounding box from the particle positions actually read (unlike `read_xyz_file`) — internally it reuses the exact same `Lattice=`-derived bounds as `FILE`, so the two modes are equivalent for this operator. `DOMAIN` still means "ignore the file, keep the `domain:` block's own bounds," as elsewhere.

!!! warning "`enlarge_bounds` / `pbc_adjust_xform` don't exist on this operator"

    Unlike `read_xyz_file`, `read_xyz_file_with_xform` has no `enlarge_bounds` or `pbc_adjust_xform` slot at all — despite a couple of the repo's own regression files (e.g. `mliaps/pace/NH_pace.msp`) passing `pbc_adjust_xform: true` to it. Unknown YAML keys are silently ignored by the underlying operator framework rather than raising an error, so that key currently has no effect wherever it's used with this operator.

`read_xyz_file_with_xform` is also registered under the alias `read_extended_xyz_file` — same class, same slots, same behavior, just a second name (not currently used by any real config in the repo, but valid to use).

### Other formats

A few more readers exist for specific molecule and legacy formats — `read_xyz_molecules`, `read_xyz_rigidmol`, `read_fatomes_mol`, `read_stamp_v3`, `read_stamp_v4`. These aren't part of the common workflow above and see comparatively little use; some cover formats specific to older, predecessor codes and may eventually be retired.

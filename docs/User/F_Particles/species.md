---
icon: lucide/atom
---

# Species

`exaStamp` supports three particle formalisms — atoms, rigid molecules, and fully-flexible molecules — all built on the same underlying species type. Every particle type used in a simulation, whatever its formalism, must first be declared in the `species` YAML block.

## The `species` operator

The simplest form is a bare list of named species:

```yaml
species:
  - O: { mass: 15.9994 Da, z: 8, charge: -1.1104 e- }
  - U: { mass: 238.02891 Da, z: 92, charge: 2.2208 e- }
```

The full form additionally exposes the operator's own parameters, with the species list nested under its own `species` key:

```yaml
species:
  verbose: true
  fail_if_empty: true
  species:
    - O: { mass: 15.9994 Da, z: 8, charge: -1.1104 e- }
```

| Property | Description | Data Type | Default |
|---|---|---|---|
| `verbose` | Print the resolved species list to the log. | bool | `true` |
| `fail_if_empty` | Abort if no species are defined. | bool | `false` |

!!! warning

    Species names used here must be consistent with any other place that references particle types by name — [`lattice`/`bulk_lattice`'s `types`](../D_DomainRegions/domain.md#built-in-particles-creators), external file readers, etc.

## Per-species properties

Each entry in the `species` list is a single-key map `name: { ... }`:

| Property | Description | Data Type | Default |
|---|---|---|---|
| `mass` | Particle mass. | float (physical quantity) | *(required)* |
| `z` | Atomic number. | int | `0` |
| `charge` | Particle charge. | float (physical quantity) | `0` |
| `molecule` | Name of the flexible molecule this atom belongs to — see [Bonding Potentials](../G_ForceFields/Intramolecular/index.md) for the bond/bend/torsion/improper terms connecting them. Omit for standalone atoms. | string | *(none)* |
| `rigid_molecule` | Defines this species as a rigid molecule made of other, already-declared single-atom species (see below), instead of a plain atom. | sequence | *(none)* |

```yaml
species:
  - h2o_H: { mass: 1.008 Da, z: 1, charge: 0.5564 e-, molecule: molH2O }
  - h2o_O: { mass: 15.999 Da, z: 8, charge: -1.1128 e-, molecule: molH2O }
  - o2_O:  { mass: 15.999 Da, z: 8, charge: 0.0 e-, molecule: molO2 }
```

## Rigid molecules

A species can instead be defined as a **rigid molecule**: a fixed assembly of 2 to 4 previously-declared single-atom species (4 is the default compile-time limit, `XSTAMP_MAX_RIGID_MOLECULE_ATOMS`), each placed at a fixed position relative to the molecule's own frame via `rigid_molecule`. `mass`, `z` and `charge` are still required keys on a rigid-molecule entry, but their values are ignored — they get automatically recomputed as the sum over the constituent atoms.

A rigid O₂ molecule:

```yaml
species:
  - O: { mass: 15.999 Da, z: 8, charge: 0.0 e- }
  - O2:
      mass: 0.0 Da
      z: 0
      charge: 0.0 e-
      rigid_molecule:
        - O: [ -0.604 ang, 0.0, 0.0 ]
        - O: [  0.604 ang, 0.0, 0.0 ]
```

A rigid, TIP4P-style water model with a fourth massless charge site `M`:

```yaml
species:
  - H: { mass: 1.007 Da, z: 1, charge: 0.5564 e- }
  - O: { mass: 16 Da, z: 8, charge: 0.0 e- }
  - M: { mass: 0.0 Da, z: 0, charge: -1.1128 e- }
  - H2O:
      mass: 0.0 Da
      z: 0
      charge: 0.0 e-
      rigid_molecule:
        - O: [  0.0 ang,        0.0 ang,        0.0 ang ]
        - H: [  0.75695033 ang, 0.58588228 ang, 0.0 ang ]
        - H: [ -0.75695033 ang, 0.58588228 ang, 0.0 ang ]
        - M: [  0.0 ang,        0.1546 ang,     0.0 ang ]
```

!!! warning "Ordering"

    All plain (single-atom) species must come before any rigid-molecule species in the `species` list — `exaStamp` aborts at startup if a single atom is declared after the first rigid molecule.

## Lower-level alternative: `particle_types` / `particle_type_add_properties`

`species` is `exaStamp`'s high-level way of declaring atomic species. Internally, it populates two generic `onika`/`exaNBody` slots: `particle_type_map` (name → integer type ID) and `particle_type_properties` (arbitrary named scalar/vector properties per type). These two slots can also be populated directly, which is useful when:

- a type-ID mapping is needed **before** `species` runs in the graph — for instance, `lattice`'s `types:` parameter needs `particle_type_map` to already exist;
- custom per-type properties are needed beyond `mass`/`z`/`charge` (e.g. a potential-specific parameter).

### `particle_types`

Defines the type-name-to-ID mapping and, optionally, per-type properties in one go:

| Property | Description | Data Type | Default |
|---|---|---|---|
| `particle_type_map` | Maps each type name to an integer type ID. | dict (string → int) | `{}` |
| `particle_type_properties` | Per-type scalar/vector properties. Each key is a type name from `particle_type_map`; a property left undefined for some types is created and set to `0` for those. | dict | `{}` |
| `verbose` | Log the resolved type map/properties. | bool | `true` |

```yaml
particle_types:
  verbose: true
  particle_type_map: { A: 0, B: 1, C: 2 }
  particle_type_properties:
    A: { mass: 30. Da, radius: 0.5 ang, charge: 1 e- }
    B: { mass: 20. Da, radius: 1.0 ang }
    C: { mass: 10. Da, radius: 3.0 ang }
```

### `particle_type_add_properties`

Attaches additional properties to particle types that already exist in `particle_type_map` — from `species` or a prior `particle_types` call. It fails with a fatal error if a given type name isn't already registered.

| Property | Description | Data Type | Default |
|---|---|---|---|
| `properties` | Per-type properties to add, same shape as `particle_type_properties` above. Can also be given directly as the operator's whole value, without the `properties:` wrapper — see the second example below. | dict | *(required)* |
| `verbose` | Log the resulting properties. | bool | `true` |

Split across two steps of `setup_system` — `particle_types` for the map, `particle_type_add_properties` for the properties:

```yaml
setup_system:
  - particle_types:
      particle_type_map: { Al: 0, Cu: 1 }
  - particle_type_add_properties:
      Al: { mass: 26.982 Da, z: 13, charge: 0 e- }
      Cu: { mass: 63.546 Da, z: 29, charge: 0 e- }
  - domain: { ... }
  - lattice:
      structure: FCC
      types: [ Al, Cu, Al, Cu ]
      size: [ 4.0 ang, 4.0 ang, 4.0 ang ]
```

Adding extra custom properties on top of types already defined by `species` or `particle_types`:

```yaml
particle_type_add_properties:
  Al: { lambda: 0.5 }
  Cu: { lambda: 0.2 }
```

See [Simulation Starter Pack → Particles Species](../C_StarterPack/2_species.md#lower-level-alternative-particle_types-particle_type_add_properties) for a guided walkthrough of when to reach for this instead of `species`.

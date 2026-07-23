---
icon: lucide/atom
---

# Particles Species

Every `exaStamp` simulation needs its particles' species — name, mass, atomic number, charge, and optionally molecule membership — to be defined. This is done through the `species` block, called in the `simulation` graph right after `setup_system`:

```yaml linenums="1" hl_lines="6"
simulation:
  name: MySimulation
  body:
    - [...]
    - setup_system
    - species: { verbose: false, fail_if_empty: true }
    - grid_post_processing
    - [...]
```

If no `species` block is provided, `exaStamp` falls back to `generate_default_species`, which populates the full periodic table (H to Og) documented in [Configuration files](../B_GettingStarted/configuration_files.md#particle-species).

## Defining atomic species

Each entry of the `species` list is a one-key dictionary `Name: { ... }` with the following properties:

| Property         | Type     | Required | Description                                       |
| :---------------- | :------: | :------: | :------------------------------------------------- |
| `mass`             | `float`  | yes      | Atomic/molecular mass                              |
| `z`                | `int`    | no       | Atomic number                                      |
| `charge`           | `float`  | no       | Electric charge                                    |
| `molecule`         | `string` | no       | Name of the flexible molecule this atom belongs to |
| `rigid_molecule`   | `list`   | no       | Describes a rigid multi-atom molecule (see [Rigid molecules](#rigid-molecules) below) |

```yaml linenums="1"
species:
  - O: { mass: 15.9994 Da, z: 8, charge: -1.1104 e- }
  - U: { mass: 238.02891 Da, z: 92, charge: 2.2208 e- }
```

Tagging atoms with a `molecule` name groups them for bonded, flexible-molecule force fields (see [Flexible molecules](../B_GettingStarted/configuration_files.md#flexible-molecules)), without changing how each atom itself is declared:

```yaml linenums="1"
species:
  - h2o_H: { mass: 1.008 Da, z: 1, charge: 0.5564 e-, molecule: molH2O }
  - h2o_O: { mass: 15.999 Da, z: 8, charge: -1.1128 e-, molecule: molH2O }
```

!!! warning

    Particle types declared in the `species` block must be consistent with the types read from external files (e.g. a `.xyz` file) or given to the `lattice` operator's `types:` parameter.

## Rigid molecules

A rigid, multi-atom species (treated as a single rigid body, see [Rigid molecules](../B_GettingStarted/configuration_files.md#rigid-molecules)) is declared with `rigid_molecule` instead of `mass`/`z`/`charge`, listing the relative position of each constituent atom (at least 2 are required):

```yaml linenums="1"
species:
  - O: { mass: 15.9994 Da, z: 8, charge: -0.8476 e- }
  - H: { mass: 1.008 Da, z: 1, charge: 0.4238 e- }
  - water:
      rigid_molecule:
        - O: [ 0.0 ang, 0.0 ang, 0.0 ang ]
        - H: [ 0.9572 ang, 0.0 ang, 0.0 ang ]
        - H: [ -0.2400 ang, 0.9266 ang, 0.0 ang ]
```

Each name referenced under `rigid_molecule` (here `O` and `H`) must already be declared as a single-atom species earlier in the same `species` list — `water`'s mass and charge are then derived automatically from its constituent atoms.

## Lower-level alternative: `particle_types` / `particle_type_add_properties`

`species` is `exaStamp`'s high-level way of declaring atomic species. Internally, it populates two generic `onika`/`exaNBody` slots: `particle_type_map` (name → integer type ID) and `particle_type_properties` (arbitrary named scalar/vector properties per type).

You can also populate these two slots directly with the lower-level `particle_types` operator. This is useful when:

- a type-ID mapping is needed **before** `species` runs in the graph — for instance, the `lattice` operator's `types:` parameter needs `particle_type_map` to already exist while `setup_system` is running;
- you need custom per-type properties beyond `mass`/`z`/`charge` (e.g. a potential-specific parameter).

`particle_types` takes both `particle_type_map` and `particle_type_properties` at once, the latter accepting arbitrary property names, not just `mass`/`z`/`charge`:

```yaml linenums="1"
particle_types:
  particle_type_map: { Al: 0, Cu: 1 }
  particle_type_properties:
    Al: { mass: 26.982 Da, z: 13, charge: 0 e-, lambda: 0.5 }
    Cu: { mass: 63.546 Da, z: 29, charge: 0 e-, lambda: 0.2 }
```

Or, split across two operators — `particle_types` for the map, `particle_type_add_properties` for the properties — for instance when the two need to be defined in separate steps of `setup_system`:

```yaml linenums="1"
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

`particle_type_add_properties` can also be used on its own, after `species` or `particle_types` has already defined the particle types, to attach extra custom properties (any name, not just `mass`/`z`/`charge`) to them:

```yaml linenums="1"
particle_type_add_properties:
  Al: { lambda: 0.5 }
  Cu: { lambda: 0.2 }
```

See [Particles Features → Species](../F_Particles/species.md#lower-level-alternative-particle_types-particle_type_add_properties) for the full parameter reference of both operators.

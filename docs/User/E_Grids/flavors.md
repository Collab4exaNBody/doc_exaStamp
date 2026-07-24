---
icon: material/shaker-outline
---

# **Grid Flavor**

`exaStamp` stores per-particle data in a fixed memory-layout "flavor" — chosen once via the `grid_flavor` operator, before any particles are created. The flavor determines which fields exist on every particle for the rest of the simulation; using an operator later that needs a field the chosen flavor doesn't have is an error, not a warning.

## **`grid_flavor`**

```{ .yaml title="Syntax" .syntax-block }
grid_flavor: <grid_flavor_name>
```

```{ .yaml title="Parameters" .params-block }
grid_flavor:  enum, default grid_flavor_full   # One of the six registered grid_flavor_* operators — see table below.
```

`grid_flavor` is the actual operator invoked in `exaStamp`'s framework pipeline (e.g. inside `main-config.msp`'s `simulation` body). The top-level `grid_flavor: <name>` entry isn't a bespoke "flavor selector" key — it's ONIKA's generic operator-alias mechanism: any top-level YAML entry whose name matches an operator being instantiated, and whose value is a plain string, redirects that operator to whichever name the string names. So `grid_flavor: grid_flavor_multimat` really means "the operator named `grid_flavor` is an alias for `grid_flavor_multimat`" — the same generic idiom works for overriding any operator's default elsewhere, not something specific to grids. Each of the six names below is itself a complete, parameterless operator that `grid_flavor` can alias to.

| Operator | Field set (source) |
|---|---|
| `grid_flavor_minimal` | `MultiMatFieldSet`  |
| `grid_flavor_multimat` | `MultiMatFieldSet` |
| `grid_flavor_full` | `MoleculeFieldSet` |
| `grid_flavor_full_mechanics` | `FullFieldMechSet` |
| `grid_flavor_multimat_mechanics` | `MultimatMechFieldSet` |
| `grid_flavor_rigidmol` | `RigidMoleculeFieldSet` |

```yaml title="Usage example"
grid_flavor: grid_flavor_multimat
```

!!! warning "`grid_flavor_minimal` isn't actually minimal"

    In the current source (`exaStamp/src/setup_system/grid_flavor.cpp`), `grid_flavor_minimal` registers the exact same field set as `grid_flavor_multimat` — the source comment literally calls it "just an alias to multimat". There is no reduced-field flavor beneath `multimat` today, despite the name — only 5 distinct field sets exist across the 6 registered names. Also note: the real name is `grid_flavor_full_mechanics` — there is no `grid_flavor_mechanics` (a shorter name older documentation used).

    `grid_flavor_full`/`grid_flavor_rigidmol` require `exaStamp` to have been built with `EXASTAMP_ENABLE_MOLECULE`, and `grid_flavor_full_mechanics`/`grid_flavor_multimat_mechanics` require `EXASTAMP_ENABLE_MECHANICAL` — these flavors aren't available in a build without the corresponding option.

## **Per-particle fields by flavor**

Position, velocity, force and potential energy are present on every flavor. Beyond that:

| Field | minimal | multimat | full | full_mechanics | multimat_mechanics | rigidmol |
|---|---|---|---|---|---|---|
| Particle Identifier (`id`) | YES | YES | YES | YES | YES | YES |
| Particle Type (`type`) | YES | YES | YES | YES | YES | YES |
| Virial (`virial`) | NO | NO | YES | YES | YES | NO |
| Particle Charge (`charge`) | NO | NO | YES | NO | NO | NO |
| Molecule Identifier (`idmol`) | NO | NO | YES | NO | NO | NO |
| Cmol (`cmol`) | NO | NO | YES | NO | NO | NO |
| Filtered Position (`rxf`/`ryf`/`rzf`) | NO | NO | NO | YES | NO | NO |
| Quaternion (`orient`) | NO | NO | NO | NO | NO | YES |
| Angular Momentum (`angmom`) | NO | NO | NO | NO | NO | YES |
| Torque (`couple`) | NO | NO | NO | NO | NO | YES |

!!! warning

    Depending on the grid flavor chosen, some fields won't be available for output or for operators that read them — e.g. the global stress tensor from `thermodynamic_state` needs `virial`, so use `grid_flavor_full` (or one of the `_mechanics` flavors) for that.

## **Recommendations**

### Mono-species and multi-species atomic systems

- `grid_flavor_multimat` (or the identical `grid_flavor_minimal`) for minimal per-particle data — not compatible with charged systems (no `charge` field).
- `grid_flavor_full` for multi-species systems with per-particle charges and virial.

### Rigid molecule systems

The only usable flavor is `grid_flavor_rigidmol`.

### Flexible molecule systems

The only usable flavor is `grid_flavor_full`.

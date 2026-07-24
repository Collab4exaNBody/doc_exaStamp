---
icon: material/pencil-outline
---

# **Modifying the domain**

Beyond the operators in [Defining the domain](defining.md) and [Alternative ways for defining the domain](alternative.md), a few operators exist purely to modify an already-defined `domain` later in the simulation graph.

## **`domain_override`**

```{ .yaml title="Syntax" .syntax-block }
domain_override:
  cell_size: <float>
  bounds: [[<float>, <float>, <float>], [<float>, <float>, <float>]]
  grid_dims: [<int>, <int>, <int>]
  periodic: [<bool>, <bool>, <bool>]
  expandable: <bool>
  mirror: [<string>, ...]
```

```{ .yaml title="Parameters" .params-block }
cell_size:   float, optional               # Override the domain's cell size.
bounds:      AABB, optional                # Override the domain's bounds.
grid_dims:   IJK, optional                 # Override the domain's grid dimensions.
periodic:    3 booleans, optional          # Override the domain's per-axis periodicity.
expandable:  bool, optional                # Override whether the domain can grow.
mirror:      sequence of strings, optional # Override the domain's mirrored faces (same codes as `domain`'s own `mirror`).
```

`domain_override` replaces individual properties of an already-defined `domain` — e.g. one loaded from a restart file — after the fact. Every property is genuinely optional: whatever is omitted keeps its existing value untouched, rather than falling back to some other default.

```yaml title="Usage example"
domain_override:
  cell_size: 6.0 ang
  periodic: [true, true, false]
  mirror: [z-]
```

## **`domain_update`**

```{ .yaml title="Syntax" .syntax-block }
- domain_update
```

`domain_update` takes no parameters. It recomputes the domain's bounds from the grid's actual current state and re-validates the domain — equivalent to calling `domain` again without changing any of its other properties.

## **`extend_domain`**

```{ .yaml title="Syntax" .syntax-block }
repartition_domain:
  - move_particles
  - extend_domain
  - load_balance_rcb
```

`extend_domain` takes no explicit YAML parameters either. It grows a (non-fully-periodic) domain by up to one cell in each direction to accommodate particles that moved outside its current `bounds`, provided `expandable` is set. It reads the out-of-bounds particle list produced by a preceding `move_particles` step in the same sequence: both operators declare a slot of the same name (`otb_particles`), and the underlying operator graph automatically connects same-named slots within a shared scope — so placing `extend_domain` right after `move_particles` is enough, no explicit wiring needed.

## **`replicate_domain`**

```{ .yaml title="Syntax" .syntax-block }
replicate_domain:
  repeat: [<int>, <int>, <int>]
```

```{ .yaml title="Parameters" .params-block }
repeat:  IJK, default [1,1,1]   # Number of replications along x, y and z.
```

`replicate_domain` replicates the current domain and its particles `repeat` times along each axis; the default `[1,1,1]` means no replication takes place. A bare sequence is also accepted as shorthand for the same thing:

```yaml title="Usage example"
replicate_domain: [2, 2, 2]
```

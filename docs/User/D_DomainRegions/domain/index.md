# **Simulation Domain**

This section explains how the simulation domain is defined and represented, from the low-level physical/grid space transform to the practical ways of setting it up or modifying it afterward.

- [**Physical space vs Grid space**](physical_grid_space.md) — the two spaces `exaStamp` represents the domain in, and the transform between them
- [**Defining the domain**](defining.md) — the `domain` operator and its properties, with usage examples for cubic, orthorhombic and triclinic domains
- [**Alternative ways for defining the domain**](alternative.md) — deriving the domain from a particle-generation operator or an external file instead of defining it explicitly
- [**Modifying the domain**](modifying.md) — operators that change an already-defined domain later in the simulation graph

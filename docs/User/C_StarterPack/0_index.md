---
icon: lucide/brick-wall
---

# Baseline Slots

As discussed before, some operators in the simulation's graph are required and need to be defined by the user. Among them are the interatomic potential, the particles species, the numerical scheme and so on. We consider that the mandatory blocks to be defined by the user to build a minimal input deck for `exaStamp` are the following ones:

```bash
- global         # Global control of simulation parameters
- species        # Definition of the particles' species
- compute_force  # Choice of the interatomic potential
- domain         # Definition of the simulation's domain
- input_data     # Population of the domain with particles
```

The following links will guide and help you to define the building blocks of an `exaStamp` simulation:

- Simulation global control through the [`global`](1_global.md) YAML block
- Defining particles' species through the [`species`](2_species.md) YAML block 
- Choosing an interatomic potential through the [`compute_force`](3_force.md) YAML block 
- Defining the simulation domain thorugh the [`domain`](4_domain.md) YAML block 
- Creating particles through the [`input_data`](5_input.md) YAML block
- Writing restart files or snapshots through the [`dump_data`](6_dump.md) YAML block 

All above are then gathered in one file and we provide a very simple working example [here](7_example.md).
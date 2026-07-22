# **Simulation Starter Pack**

Some operators in a simulation's graph are required and need to be defined by the user. Among them are the interatomic potential, the particles species, the simulation domain and so on. We consider that the mandatory blocks to be defined by the user to build a minimal input deck for `exaStamp` are the following ones:

```yaml
- global         # Global control of simulation parameters
- species        # Definition of the particles' species
- domain         # Definition of the simulation's domain
- setup_system   # Population of the domain with particles
- compute_force  # Choice of the interatomic potential
```

The numerical scheme (`numerical_scheme`) isn't in that list since it already has a working default (`verlet_nve`) — but it's covered too, since you'll often want to change it.

The following pages will guide you through defining each of these blocks, gathered into one working example at the end:

- [**Global control**](1_global.md) — simulation-wide parameters through `global`
- [**Particles species**](2_species.md) — defining particles' species through `species`
- [**Simulation domain**](3_domain.md) — defining the simulation domain through `domain`
- [**Input data**](4_setup_system.md) — creating particles through `setup_system`
- [**Interatomic potential**](5_force.md) — choosing an interatomic potential through `compute_force`
- [**Numerical scheme**](6_numerical_scheme.md) — choosing a time-integration scheme through `numerical_scheme`
- [**Output data**](7_output.md) — writing restart files or snapshots through `write_restart`/`write_snapshot`
- [**Working example**](8_example.md) — a complete working example gathering all blocks above

---
icon: lucide/brick-wall
---

# Building Blocks

This part of the documentation is dedicated to the `exaStamp` simulation graph and default configuration of its constitutive elements. The entire simulation workflow is defined by a combination of operators that can be interconnected, each of which can expect some data as input and generate data as output.

The default simulation graph of an `exaStamp` simulation is defined in `data/config/main-config.msp` where `data/config` contains a various set of configuration files that can be included in any simulation's input file. Below we define the building blocks of any `exaStamp` simulation, namely:

- `simulation` block
- `includes` block
- `configuration` block

## Simulation block

The most important block of an `exaStamp`simulation is the `simulation` block which entirely defines how a full simulation works, i.e. from the logo printed to the screen up to the hardware finalization after the simulation has run. The `simulation` block is a `YAML` batch operator that contains a `name` and a `body`.

```yaml linenums="1"
simulation:
  name: MySimulation
  body:
    - print_logo_banner                                   # Print the exaStamp banner
    - hw_device_init                                      # Default communicator + CUDA initialization
    - make_empty_grid                                     # Create an empty grid
    - grid_flavor                                         # Define what information is attached to the grid
    - global                                              # Global simulation controls
    - init_parameters                                     # Additional control parameters
    - generate_default_species                            # Generate default species
    - particle_regions                                    # Geometrical regions definition
    - preinit_rcut_max                                    # Automatic cell_size calculation
    - domain                                              # Simulation domain definition
    - init_prolog                                         # Initialization prologue
    - input_data                                          # Populate domain with particles
    - species:                                            # Species definition
        verbose: false
        fail_if_empty: true
    - grid_post_processing                                # Grid memory compaction
    - reduce_species_after_read                           # Update particle species
    - init_rcut_max                                       # Update neighborhood distance and displacement tolerance
    - print_domain                                        # Print Domain information
    - performance_adviser: { verbose: true }              # Print performance advices
    - do_init_temperature                                 # Initialize temperature if needed
    - init_epilog                                         # Initialization epilogue
    - species:                                            # Species definition recheck
        verbose: true
        fail_if_empty: true
    - first_iteration                                     # Simulation first iteration
    - compute_loop                                        # Simulation compute loop
    - simulation_epilog                                   # Simulation finalization
    - hw_device_finalize                                  # CUDA finalization
```

The above scenario represents the default simulation graph of an `exaStamp` simulation. A lot of the operators present in the `body` list are of course not to be defined by the user as they concern the hardware initialization, screen logging, satistics and other operations needed to initialize and configure the simulation. These operators are generally filled by `including` some configuration files.

However, some operators in that graph are required and need to be defined by the user. Among them are the interatomic potential, the particles species, the numerical scheme and so on. We consider that the mandatory blocks to be defined by the user to build a minimal input deck for `exaStamp` are the following ones:

```bash
- global         # Global control of simulation parameters
- species        # Definition of the particles' species
- compute_force  # Choice of the interatomic potential
- domain         # Definition of the simulation's domain
- input_data     # Population of the domain with particles
```


<!-- ``` mermaid
graph TD
  A(__print_logo_banner__)
  B("`__hw_device_init__
  Detect GPU Support
  Ghost configuration`")

  C(make empty grid)
  D(grid_flavor)
  E(global)
  F(init_parameters)
  G(generate_default_species)
  H(particle_regions)
  I[preinit_rcut_max]
  J(domain)
  K(init_prolog)
  L(input_data)
  M(species)
  N(grid_post_processing)
  O(reduce_species_after_read)
  P(init_rcut_max)
  Q(print_domain)
  R(performance_adviser)
  S(do_init_temperature)
  T(init_epilog)
  
  U["`**First Timestep**
  Init partcles
  - move
  - migration
  - neighbor lists
  - compute forces`"]
  
  V(compute_loop)
  W(simulation_epilog)
  X(__hw_device_finalize__)

  A -a-> B;
  B -a-> C;
  C -a-> D;
  D -a-> E;
  E -a-> F;
  F -a-> G;
  G -a-> H;
  H -a-> I;
  I -a-> J;
  J -a-> K;
  K -a-> L;
  L -a-> M;
  M -a-> N;
  N -a-> O;
  O -a-> P;
  P -a-> Q;
  Q -a-> R;
  R -a-> S;
  S -a-> T;
  T -a-> U;
  U -a-> V;
  V -a-> W;
  W -a-> X;
``` -->

## Includes block

The includes block allows you to include other `YAML` files to your input file. By default, the `includes` block is defined as follows:

```yaml linenums="1"
includes:
  - config_defaults.msp
  - config_debug.msp
  - config_move_particles.msp
  - config_numerical_schemes.msp
  - config_globals.msp
  - config_iteration_log.msp
  - config_iteration_dump.msp
  - config_end_iteration.msp
  - config_init_temperature.msp
  - config_input.msp  
```
where all the `config_*` files contain predefined operators and parameters required by an `exaStamp` simulation. These default configuration files are explained in ddetail in the next section.

Adding the `includes` block to your input file will not erase that definition but append the `included` files to the list above. Thus, if you want for example to consider an additional file named `my_additional_file.yaml` in which you have defined a specific operator, you can do as follows:

```yaml linenums="1"
includes:
  - my_additional_file.yaml
```

The advantage of this `includes`block is that you can avoid having a very long input file and allow for multiple variations of a simulation parametrization.


## Configuration block

The first elementary block for an `exaStamp` simulation is the `configuration` block. This block serves as a placeholder for configuring both physical units to be used, logging properties, profiling and debugging features as well as specific instructions of MPI x OMP and GPU execution. Below is the full `configuration` block with its default values.

```yaml linenums="1"
configuration:
  physics:
    units:
      length: angstrom
      mass: Dalton
      time: picosecond
      charge: elementary_charge
      temperature: kelvin
      amount: particle
      luminosity: candela
      angle: radian
      energy: joule
  logging:
    parallel: false
    debug: false
    profiling: false
  profiling:
    exectime: false
    summary: false
  debug:
    plugins: false
    config: false
    graph: false
    graph_lod: 0
    filter: []
  mpimt: true
  pinethreads: false
  num_threads: {}
  omp_max_nesting: 2  
```

Usually, you do not need to redeclare this entire block in your simulation input file. For example, if you just want to print a summary of the simulation execution graph at the end of your run, you can add to your input file the following:

```yaml linenums="1"
configuration:
  profiling:
    summary: true
```

This will only redefine the `summary` key's value of the `profiling` dictionary. Additionally, we do not recommend you to redefine units as for now they are design to better control the internal units. In addition, we do not guarantee yet that the appropriate conversions are correctly done for outputs. Thus, modifying units should be done at your own risk.
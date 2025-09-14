---
icon: fontawesome/solid/chain
---

# **Simulation's graph**


The default simulation sequence of ``exaStamp`` is defined in the ``main-config.msp`` file located in ``exaStamp/data/config``. In particular, the ``simulation`` block allows for the entire parametrization of the MD simulation, from the initial information output and hardware initialization to the main MD loop and hardware finalization.

**Default YAML block for an exaStamp simulation**
    
```yaml
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

In this YAML block, some operators are mandatory. We provide in the next section a input deck example with the minimal information required. In addition, some of the YAML operators defined in the `simulation` block are defined in other configuration files located in ``exaStamp/data/config``. However, the mandatory blocks to be defined by the user to build a minimal input deck for exaStamp are:

```bash
   - global         # Global control of simulation parameters
   - species        # Definition of the particles' species
   - compute_force  # Choice of the interatomic potential
   - domain         # Definition of the simulation's domain
   - input_data     # Population of the domain with particles
```
  
The next section provides a basic example on how to build an ``exaStamp`` input deck with the minimal information required.
    
``` mermaid
graph TD
  A["`**Initialization**
  Detect GPU Support
  Create Grid
  Preinit cutoff radius`"]
  
  B[Creating Particle Regions]
  
  C["`**Input Data**
  lattice, xyz, MpiIO
  + field initialization`"]

  D["`**Firs Timestep**
  Init partcles
  - move
  - migration
  - neighbor lists
  - compute forces`"]

  E[Time Loop];
  F[test];
  G[coucou];
  
  A --> B;
  B --> C;
  C --> D;
  D --> E;
  E --> F;
  F --> G
  G--->|"`t inf tfin`"| D;
  
  
```


  B -->|Yes| C[Hmm...];
  C --> D[Debug];
  D --> B;
  B ---->|No| E[Yay!];
  E ===> newLines["`Line1
                    Line 2
                    Line 3`"]  


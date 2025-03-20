How to exaStamp
===============

This section aims at providing a step-by-step tutorial on how to create and design a classical molecular dynamics simulation using ``exaStamp``. The application takes advantage of YAML and can be fully defined using a combination of YAML nodes that act as individual operators. This allows a fine customization of the simulation by the user. Default configuration files are located in ``exaStamp/data/config`` and are defined below.

Mandatory commands
******************

Simulation conditions
---------------------

.. code-block:: YAML

   global:
     dt: 1.0e-3 ps                               # simulation timestep
     timestep: 0                                 # simulation start iteration
     physical_time: 0. ps                        # simulation start physical time
     rcut_inc: 1.0 ang                           # additional distance beyond interatomic potential cutoff
     simulation_end_iteration: 1000              # final iteration of the current run
     simulation_log_frequency: 10                # screen log frequency
     simulation_dump_thermo_frequency: 10        # file log frequency
     simulation_dump_frequency: 50               # dump data frequency
     analysis_dump_frequency: 50                 # dump analysis frequency
     init_temperature: 300. K                    # required initial temperature (gaussian)
     scale_temperature: 300. K                   # required initial temperature (uniform)
     
     enable_load_balance: true                   # load balancing enabling
     simulation_load_balance_frequency: 100      # load balancing frequency (if triggered)
     trigger_cost_model_fitting: false           # load balancing cost model fitting
     cost_model_coefs: [ 0.0 , 0.0 , 1.0 , 0.0 ] # load balancing cost model coefficients
     
     enable_task_graph: false                    # task graph enabling
     enable_grid_compact: true                   # compact grid enabling
     log_mode: mechanical                        # log mode (in progress)
   
Domain definition
-----------------

Particle species
----------------

Interatomic potential
---------------------

Input data
----------

Output data
-----------

Analysis
--------

Example input decks
*******************

Advanced configuration
**********************

The default simulation sequence of ``exaStamp`` is defined in the ``main-config.msp`` file. In particular, the ``simulation`` block allows for the entire parametrization of the MD simulation, from the initial information output and hardware initialization to the main MD loop and hardware finalization.

.. code-block:: YAML
   :caption: **Default YAML block for an exaStamp simulation**

   simulation:
     name: sim
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


.. code-block:: bash

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

YAML blocks modification
************************

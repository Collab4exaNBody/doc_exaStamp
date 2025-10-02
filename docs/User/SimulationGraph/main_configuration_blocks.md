# **exaStamp configuration**

Default configuration files of an **exaStamp** simulation can be found in the `exaStamp/data/config` folder. These files contain all the YAML blocks required for an MD simulation to work correctly. We'll go over all of them in detail below where each section is associated with one configuration file, starting with the master one.

<hr style="height:4px;border:none;background: rgb(180, 180, 180) ;margin:50px 0;">
## **Configuration, includes and simulation blocks**

The first elementary block for an **exaStamp** simulation is the `configuration` block. This block serves as a placeholder for configuring both physical units to be used, logging properties, profilingand debugging features as well as specific instructions of MPI x OMP execution.

!!! note "`configuration` block"
  
    ```yaml
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

!!! note "`includes` block"

    ```yaml
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

!!! note "`simulation` block"

    ```yaml
    simulation:
      name: exaStamp_generic_simulation
      body:
        - print_logo_banner
        - hw_device_init
        - make_empty_grid
        - grid_flavor
        - global
        - init_parameters
        - generate_default_species
        - particle_regions
        - preinit_rcut_max
        - domain
        - init_prolog
        - input_data
        - species: { verbose: false , fail_if_empty: true }
        - grid_post_processing
        - reduce_species_after_read
        - init_rcut_max
        - print_domain
        - performance_adviser: { verbose: true }
        - do_init_temperature
        - init_epilog
        - species: { verbose: true , fail_if_empty: true }
        - first_iteration
        - compute_loop
        - simulation_epilog
        - hw_device_finalize
    ```

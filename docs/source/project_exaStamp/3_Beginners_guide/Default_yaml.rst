Default configuration
=====================

Configuration files for the default behavior of ``exaStamp`` can be found in the ``exaStamp/data/config`` folder. These files contain all the YAML block required for an MD simulation to work correctly. We'll go over all of them in detail below where each section is associated with one configuration file, starting with the master one.

``main-config.msp``
-------------------

.. code-block:: YAML
   
   print_logo_banner:
     profiling: false
     body:
       - message: |
  
          ███████╗██╗  ██╗ █████╗ ███████╗████████╗ █████╗ ███╗   ███╗██████╗     ██╗   ██╗██████╗
          ██╔════╝╚██╗██╔╝██╔══██╗██╔════╝╚══██╔══╝██╔══██╗████╗ ████║██╔══██╗    ██║   ██║╚════██╗
          █████╗   ╚███╔╝ ███████║███████╗   ██║   ███████║██╔████╔██║██████╔╝    ██║   ██║ █████╔╝
          ██╔══╝   ██╔██╗ ██╔══██║╚════██║   ██║   ██╔══██║██║╚██╔╝██║██╔═══╝     ╚██╗ ██╔╝ ╚═══██╗ 
          ███████╗██╔╝ ██╗██║  ██║███████║   ██║   ██║  ██║██║ ╚═╝ ██║██║          ╚████╔╝ ██████╔╝
          ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝           ╚═══╝  ╚═════╝
       - version_info

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

   # set various defaults
   memory_stats: { graph_res_mem: false }

   # usually outputs ParticleSpecies type to a slot named species, in case the data reader doesn't provide species description
   reduce_species_after_read: nop

   ############### compute loop stop condition #############
   compute_loop_stop:
     profiling: false
     rebind: { end_at: simulation_end_iteration , result: compute_loop_continue }
     body:
       - sim_continue

   # default force computation does nothing, these are placeholders used later on
   compute_loop_prolog: nop
   compute_loop_epilog: nop
   init_prolog: nop
   init_epilog: nop

   # executing potential sub nodes initializes rcut_max
   # won't actually compute anything since grid is empty at this time
   init_rcut_max:
     profiling: false
     rebind: { grid: null_grid, chunk_neighbors: null_neighbors }
     body:
       - compute_force    # executed on an empty grid, just here to update rcut_max
       - nbh_dist:        # compute neighborhood distance in grid space (nbh_dist),
           verbose: true  # also computes maximum particle move tolerance in grid space (max_displ)
                          # and ghost_dist, a constant scaling of of nbh_dist using scale factor nbh_ghost_scale

   # executed once (whitout verbosity) first to enable automatic cell_size calculation
   preinit_rcut_max:
     profiling: false
     rebind: { grid: null_grid, chunk_neighbors: null_neighbors, domain: empty_domain }
     body:
       - domain:
           cell_size: 0.0 ang
           grid_dims: [ 0 , 0 , 0 ]
           periodic: [ true , true , true ]
       - compute_force
       - nbh_dist

   first_iteration:
     - init_particles
     - compute_all_forces_energy
     - default_thermodynamic_state
     - default_print_thermodynamic_state: { lb_flag: false , move_flag: false , print_header: true }
     - default_dump_thermodynamic_state
     - next_time_step

   # definin this enables user to use --set-init_cuda-enable_cuda false to disable cuda
   init_cuda:
     enable_cuda: true

   hw_device_init:
     - mpi_comm_world
     - init_cuda

   hw_device_finalize:
     - finalize_cuda

   simulation_epilog:
     - default_thermodynamic_state
     - final_dump

   # by default, species use the default definition of species operator to generate initial species
   species: { species: [ ] , verbose: false }
   generate_default_species: species

   compute_loop:
     loop: true
     name: loop
     condition: compute_loop_continue
     body:
       - compute_loop_prolog
       - begin_iteration
       - numerical_scheme
       - end_iteration
       - compute_loop_epilog
       - next_time_step
       - compute_loop_stop
    
   particles_regions: []

   init_parameters: nop

   ######## simulation program description #################
   simulation:
     name: sim
     body:
       - print_logo_banner
       - hw_device_init   # provide MPI_COMM_WORLD as a default communicator
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

   
``config_defaults.msp``
-----------------------

The ``config_defaults.msp`` file contains the ``configuration`` YAML block that allows the user to parametrize different things:

- ``physics``: definiton of the simulation units 
- ``logging``: 
- profiling:
- debug:
- mpimt:
- pinethreads:
- num_threads:
- omp_max_nesting: 

.. code-block:: YAML

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
   
                
``config_debug.msp``
--------------------

.. code-block:: YAML

   # debug operators
   
   dbg:
     - simulation_thermodynamic_state
     - print_thermodynamic_state
     - dump_thermodynamic_state
     - grid_stats
   
``config_move_particles.msp``
-----------------------------

.. code-block:: YAML

   ########### Generic particle update block ################
   
   includes:
     - config_load_balance.msp
   
   # define a test node which outputs a boolean value 'trigger_move_particles'
   # which tells when to move particles across cells and update neighbor lists
   trigger_move_particles:
     rebind: { threshold: max_displ , result: trigger_move_particles }
     body:
       - particle_displ_over
   
   
   ################### AMR ############################
   rebuild_amr:
     sub_grid_density: 6.5
     amr_z_curve: false
     enforced_ordering: 1
   ####################################################
   
   
   ############ default ghost update parameters #######
   ghost_update_r: &ghost_update_parms
     gpu_buffer_pack: true
     async_buffer_pack: true
     staging_buffer: true
     serialize_pack_send: true
     wait_all: false
   
   ghost_update_rq: *ghost_update_parms
   
   update_force_energy_from_ghost: *ghost_update_parms
   
   ghost_update_all_no_fv: *ghost_update_parms
   ####################################################
   
   
   
   ################### Neighbor list update ############################
   chunk_neighbors:
     config:
       free_scratch_memory: false
       build_particle_offset: true
       subcell_compaction: true
       scratch_mem_per_cell: 1048576
       stream_prealloc_factor: 1.05 # standard value to avoid most of dynamic allocations
       chunk_size: 1
   
   chunk_neighbors_impl: chunk_neighbors
   
   update_particle_neighbors:
     - amr_grid_pairs
     - chunk_neighbors_impl
     - resize_particle_locks
   ####################################################################
   
   grid_post_processing: grid_memory_compact
   
   profile_ghost_comm_scheme: nop
   #profile_ghost_comm_scheme: print_ghost_comm_stats # exchange volume stats
   #profile_ghost_comm_scheme: print_ghost_comm_scheme # full print
   
   ghost_update_all_impl: ghost_update_all_no_fv
   
   ghost_full_update:
     - ghost_comm_scheme
     - profile_ghost_comm_scheme
     - ghost_update_all_impl
     
   
   ################### parallel particle migration ############################
   parallel_update_particles:
     - migrate_cell_particles
     - rebuild_amr
     - backup_r
     - ghost_full_update
     - grid_post_processing
     - update_particle_neighbors
   
   # define actions to initialize particles at startup, just after file read
   init_particles:
     - move_particles
     - extend_domain
     - load_balance
     - parallel_update_particles
   ###########################################################################
   
   
   update_particles_full_body:
     - move_particles
     - trigger_load_balance
     - load_balancing_if_triggered
     - parallel_update_particles
   
   update_particles_full:
     condition: trigger_move_particles
     body:
       - update_particles_full_body
   
   update_particles_fast_body:
       - ghost_update_r
   
   update_particles_fast:
     condition: not trigger_move_particles
     body:
       - update_particles_fast_body
   
   check_and_update_particles:
     - trigger_move_particles
     - update_particles_full
     - update_particles_fast
     - loadbalance_log_helper:
         rebind: { lb_flag: trigger_load_balance , move_flag: trigger_move_particles }
         body: [ lb_event_counter ]

``config_numerical_schemes.msp``
--------------------------------

.. code-block:: YAML

   compute_force: nop
   
   # default is no thermostat
   thermostat: nop
   
   compute_force: nop
   
   compute_force_prolog: zero_force_energy
   compute_force_epilog: force_to_accel
   
   compute_all_forces_energy:
     - compute_force_prolog
     - compute_force
     - compute_force_epilog
   
   verlet_first_half:
     - push_f_v_r: { dt_scale: 1.0 , xform_mode: INV_XFORM }
     - push_f_v: { dt_scale: 0.5  , xform_mode: IDENTITY }  
   
   verlet_second_half:
     - push_f_v: { dt_scale: 0.5 , xform_mode: IDENTITY }
   
   # define the verlet numerical scheme
   numerical_scheme_verlet:
     name: scheme
     body:
       - verlet_first_half
       - check_and_update_particles
       - load_balance_auto_tune_start
       - compute_all_forces_energy
       - verlet_second_half
       - thermostat
       - load_balance_auto_tune_end
   
   # define the verlet numerical scheme
   numerical_scheme_basic:
     - compute_all_forces_energy
     - push_f_v: { xform_mode: IDENTITY }
     - push_v_r: { xform_mode: INV_XFORM }
     - check_and_update_particles
     
   numerical_scheme_overdamped:
     - compute_all_forces_energy
     - push_f_r: { xform_mode: INV_XFORM }
     - check_and_update_particles
   
   numerical_scheme: numerical_scheme_verlet
   

``config_globals.msp``
----------------------

.. code-block:: YAML

   # default global values
   global:
     dt: 1.0e-3 ps
     rcut_inc: 1.0 ang   # additional distance so that we d'ont have to rebuild neighbor list each time step
     compute_loop_continue: true
     simulation_end_iteration: 10000
     simulation_log_frequency: 10
     simulation_load_balance_frequency: 100
     simulation_dump_frequency: 1000         # 0 means no dump at all
     simulation_dump_thermo_frequency: 10
     analysis_dump_frequency: 0
     trigger_thermo_state: true
     timestep: 0
     physical_time: 0.
     init_temperature: -1.0
     scale_temperature: -1.0
     enable_load_balance: true
     enable_task_graph: false
     enable_grid_compact: true
     trigger_cost_model_fitting: false
     cost_model_coefs: [ 0.0 , 0.0 , 1.0 , 0.0 ]
     log_mode: mechanical # set to chemistry or default
   
   # default grid variant we use
   grid_flavor: grid_flavor_full
   
   make_empty_grid:
     rebind: { grid: null_grid }
     body:
       - grid_flavor
   
   # default domain parameters
   domain:
     grid_dims: [ 0 , 0 , 0 ] # deduced from cell_size
     cell_size: 0.0 ang # deduced from max rcut (a.k.a. output slot ghost_dist from nbh_dist node)
   
   particle_regions: []

``config_interation_log.msp``
-----------------------------

.. code-block:: YAML

   # default operators to use
   default_print_thermodynamic_state: print_thermodynamic_state
   default_dump_thermodynamic_state: dump_thermodynamic_state
   
   # define when log must be printed
   trigger_print_log:
     rebind: { freq: simulation_log_frequency , result: trigger_print_log , lb_flag: trigger_load_balance , move_flag: trigger_move_particles }
     body:
       - nth_timestep: { first: true }
   
   # how to print log
   print_log_if_triggered:
     condition: trigger_print_log
     body:
       - default_print_thermodynamic_state: { print_header: false }
   
   # when to output thermo variables curve
   dump_thermo_if_triggered:
     condition: trigger_dump_thermo
     body:
       - default_dump_thermodynamic_state: { print_header: false }
   
   trigger_dump_thermo:
     rebind: { freq: simulation_dump_thermo_frequency , result: trigger_dump_thermo }
     body:
       - nth_timestep: { first: false }
   

``config_iteration_dump.msp``
-----------------------------

.. code-block:: YAML

   # define when log must be printed
   trigger_dump_data:
     rebind: { freq: simulation_dump_frequency , result: trigger_dump_data }
     body:
       - nth_timestep: { first: false }
   
   trigger_dump_analysis:
     rebind: { freq: analysis_dump_frequency , result: trigger_dump_analysis }
     body:
       - nth_timestep: { first: false }
   
   dump_data_exastamp_v4:
     rebind: { thermodynamic_state: thermodynamic_state_4_dump }
     body:
       - timestep_file: "ExaStampV4prot_%09d.MpiIO"
       - message: { mesg: "Write dump " , endl: false }
       - print_dump_file:
           rebind: { mesg: filename }
           body:
             - message: { endl: true }
       - simulation_thermodynamic_state
       - write_exastamp_v4
   
   dump_data_stamp_v4:
     rebind: { thermodynamic_state: thermodynamic_state_4_dump }
     body:
       - timestep_file: "StampV4prot_%09d.MpiIO"
       - message: { mesg: "Write dump " , endl: false }
       - print_dump_file:
           rebind: { mesg: filename }
           body:
             - message: { endl: true }
       - simulation_thermodynamic_state
       - write_stamp_v4
   
   dump_data_stamp_v3:
     - timestep_file: "StampV3prot_%09d.MpiIO"
     - message: { mesg: "Write dump " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - write_stamp_v3
   
   # Native ExaNB dump format for single atoms
   dump_data_atoms:
     - timestep_file: "atoms_%09d.MpiIO"
     - write_dump_atoms
   
   # Native ExaNB dump format for rigid molecules
   dump_data_rigidmol:
     - timestep_file: "rigidmol_%09d.MpiIO"
     - write_dump_rigidmol
   
   dump_data_vtklegacy:
     - timestep_file: "output_%09d.vtk"
     - message: { mesg: "Write vtk-legacy " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - write_vtklegacy: { ghost: false }
   
   dump_data_vtk:
     - timestep_file: "output_%09d"
     - message: { mesg: "Write vtk " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - write_vtk
   
   dump_data_paraview:
     - timestep_file: "paraview/output_%09d"
     - message: { mesg: "Write " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - write_paraview
   
   dump_data_grid_vtklegacy:
     - grid_flavor
     - resize_grid_cell_values
     - atom_cell_projection
     - timestep_file: "grid_%09d.vtk"
     - write_grid_vtklegacy
   
   dump_data_grid_vtk:
     - grid_flavor
     - resize_grid_cell_values
     - atom_cell_projection
     - timestep_file: "grid_%09d"
     - write_grid_vtk
   
   #dump_data: dump_data_stamp_v3
   dump_data: dump_data_atoms
   
   dump_data_CCL:
     - grid_flavor
     - resize_grid_cell_values
     - atom_cell_projection
     - cc_label
     - timestep_file: "cc_%09d"
     - write_grid_vtk
     - write_cc_table
   
   dump_data_xyz:
     - timestep_file: "exaStamp_%09d.xyz"
     - message: { mesg: "Write xyz " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - write_xyz_file
   
   dump_data_lmp:
     - timestep_file: "exaStamp_%09d.lmp"
     - message: { mesg: "Write xyz " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - write_lmp_file
   
   dump_analysis: dump_data_grid_vtk
   
   # usefull to cleanly place particles in corresponding cells
   # and/or extend domain, just before a dump
   cleanup_before_dump: init_particles
   
   # define how to print log
   dump_data_if_triggered:
     condition: trigger_dump_data
     body:
   #    - cleanup_before_dump
       - dump_data
   
   dump_analysis_if_triggered:
     condition: trigger_dump_analysis
     body:
       # - cleanup_before_dump
       - dump_analysis
   
   final_dump:
   #    - cleanup_before_dump
       - dump_data

``config_end_iteration.msp``
----------------------------

.. code-block:: YAML

   # define what to do at the end of an iteration
   
   trigger_thermo_state:
     - combine1:
         rebind: { in1: trigger_dump_data , in2: trigger_print_log , result: output1 }
         body:
           - boolean_or
     - combine2:
         rebind: { in1: output1 , in2: trigger_dump_thermo , result: trigger_thermo_state }
         body:
           - boolean_or
   
   default_thermodynamic_state: simulation_thermodynamic_state
   
   thermo_state_if_triggered:
     condition: trigger_thermo_state
     body:
   #    - message: "thermodynamic_state"
       - default_thermodynamic_state
   
   
   begin_iteration:
     - trigger_dump_data
     - trigger_print_log
     - trigger_dump_thermo
     - trigger_thermo_state
     - trigger_dump_analysis
   
   end_iteration:
     - thermo_state_if_triggered
     - dump_data_if_triggered
     - print_log_if_triggered
     - dump_thermo_if_triggered
     - dump_analysis_if_triggered
   

``config_init_temperature.msp``
-------------------------------

.. code-block:: YAML

   do_init_temperature:
     - block1:
         rebind: { value: init_temperature , result: enable_init_temperature }
         body:
           - greater_than: { threshold: 0.0 K }
     - block2:
         rebind: { value: scale_temperature , result: enable_scale_temperature }
         body:
           - greater_than: { threshold: 0.0 K }
     - block3:
         condition: enable_init_temperature
         rebind: { temperature: init_temperature }
         body:
           - gaussian_noise_v
           - init_temperature
     - block4:
         condition: enable_scale_temperature
         rebind: { temperature: scale_temperature }
         body:
           - init_temperature
   
``config_input.msp``
--------------------

.. code-block:: YAML

   # default input : read last dump with legacy StampV3 format 
   read_stamp_v3:
         file: lastLegacyDump
         filename: lastLegacyDump
         bounds_mode: FILE
   
   input_data: read_stamp_v3

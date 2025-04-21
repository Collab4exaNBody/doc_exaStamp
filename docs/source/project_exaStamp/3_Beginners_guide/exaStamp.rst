
Mandatory commands
------------------

Simulation conditions
*********************

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

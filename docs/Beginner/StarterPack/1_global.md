---
icon: lucide/sliders-horizontal
---

# Global Control

The general simulation parameters can be defined by the `global` block. This operator allows to define all control parameters such as the time step, the log/dump/restart frequencies, the log type, and any additional parameter that can be taken as an input by operators called during the simulation. 


```yaml linenums="1" hl_lines="8"
simulation:
  name: MySimulation
  body:
    - print_logo_banner                                  
    - hw_device_init                                     
    - make_empty_grid                                     
    - grid_flavor                                         
    - global                                             
    - [...]
    - simulation_epilog
    - hw_device_finalize
```

Below is the default definition of the `global` block as defined in `data/config/config_globals.msp` (included by default via `main-config.msp`):

```yaml linenums="1"
--8<-- "docs/files/config_globals.msp"
```

??? note "Parameters' description"

    | Parameter                                | Description                                        | Type     | Default                     |
    | :---------------------------------------- | :------------------------------------------------- | :------: |  -----------:               | 
    | `max_iteration`                           | Ending time-step (maximum number of iterations)    | `int`    | `1000`                      |
    | `start_iteration`                         | Starting iteration count                           | `int`    | `0`                         |
    | `rcut_inc`                                | Extra distance beyond cutoff (neighbor list skin)  | `float`  | `1.0 ang`                   | 
    | `timestep`                                | Starting time-step value                           | `int`    | `0`                         |
    | `physical_time`                           | Starting physical time                             | `float`  | `0.`                        | 
    | `dt`                                      | Time-step                                          | `float`  | `1.0e-3 ps`                 | 
    | `log_mode`                                | Log mode                                           | `string` | `mechanical` (other choices are `default` or `chemistry`) | 
    | `simulation_restart_frequency`            | Restart file write frequency                       | `int`    | `1000`                      | 
    | `simulation_snapshot_frequency`           | Snapshot file write frequency                      | `int`    | `1000`                      | 
    | `simulation_analysis_frequency`           | On-the-fly analysis frequency                      | `int`    | `1000`                      | 
    | `simulation_thermostate_file_frequency`   | Thermodynamic state file write frequency           | `int`    | `10`                        | 
    | `thermostate_file`                        | Name of the thermodynamic state `.csv` file        | `string` | `"thermodynamic_state.csv"` | 
    | `simulation_thermostate_screen_frequency` | Thermodynamic state screen-print frequency         | `int`    | `10`                        | 
    | `simulation_load_balance_frequency`       | Load balancing frequency                           | `int`    | `100`                       | 
    | `enable_load_balance`                     | Enables load balancing                             | `bool`   | `true`                      | 
    | `trigger_cost_model_fitting`              | Triggers automatic load-balancing cost model fitting | `bool` | `false`                     | 
    | `cost_model_coefs`                        | Load-balancing cost model coefficients (RCB)       | `list`   | `[ 0.0 , 0.0 , 1.0 , 0.0 ]` | 
    | `enable_grid_compact`                     | Enables grid memory compaction                     | `bool`   | `true`                      | 
    | `init_temperature`                        | Initial temperature (disabled if negative)         | `float`  | `-1.0`                      | 
    | `scale_temperature`                       | Temperature scaling factor (disabled if negative)  | `float`  | `-1.0`                      | 
    | `md_loop_continue`                        | Needed for the simulation loop to start            | `bool`   | `true`                      | 
    | `trigger_thermo_state`                    | Needed to get the initial thermodynamic state      | `bool`   | `true`                      | 

In practice, the user doesn't need to think about some of these variables as they only serve as input for the simulation initialization. Here's a minimal `global` block you can use to start your simulation with.

```yaml linenums="1"
global:
  max_iteration: 1000                            # number of timesteps
  rcut_inc: 1.0 ang                              # skin distance for neighbor list 
  dt: 1.0e-3 ps                                  # timestep
  simulation_restart_frequency: 1000             # restart frequency
  simulation_snapshot_frequency: 1000            # snapshot frequency  
  simulation_analysis_frequency: 0               # analysis frequency
  simulation_thermostate_file_frequency: 10      # thermostate to file frequency
  thermostate_file: "thermodynamic_state.csv"    # default name of .csv thermostate file
  simulation_thermostate_screen_frequency: 10    # thermostate to screen frequency
```  

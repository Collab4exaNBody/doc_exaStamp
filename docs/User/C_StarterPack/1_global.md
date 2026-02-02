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

Below is the default definition of the `global` block as defined in `data/config/main-config.msp`:

```yaml linenums="1"
global:
  timestep: 0
  physical_time: 0.
  dt: 1.0e-3 ps
  rcut_inc: 1.0 ang
  simulation_end_iteration: 10000
  simulation_log_frequency: 10
  log_mode: mechanical
  simulation_dump_frequency: 1000
  simulation_dump_thermo_frequency: 10
  analysis_dump_frequency: 0
  trigger_thermo_state: true
  compute_loop_continue: true
  init_temperature: -1.0
  scale_temperature: -1.0
  enable_load_balance: true
  simulation_load_balance_frequency: 100  
  trigger_cost_model_fitting: false
  cost_model_coefs: [ 0.0 , 0.0 , 1.0 , 0.0 ]
  enable_task_graph: false
  enable_grid_compact: true
```  

The table below contains the descriptions of these parameters.

| Parameter                             | Description                     | Type     | Default                     |
| :------------------------------------ | :------------------------------ | :------: |  -----------:               | 
| `timestep`                            | Starting time-step              | `int`    | `0`                         |
| `physical_time`                       | Starting physical time          | `float`  | `0.`                        | 
| `dt`                                  | Time-step                       | `float`  | `1.0e-3 ps`                 | 
| `rcut_inc`                            | Extra distance beyond cutoff    | `float`  | `1.0 ang`                   | 
| `simulation_end_iteration`            | Ending time-step                | `int`    | `10000`                     | 
| `simulation_log_frequency`            | Screen log frequency            | `int`    | `10`                        | 
| `log_mode`                            | Log mode                        | `string` | `mechanical` (other choices are `default` or `chemistry`) | 
| `simulation_dump_frequency`           | Dump data frequency             | `int`    | `1000`                      | 
| `simulation_dump_thermo_frequency`    | File log frequency              | `int`    | `10`                        | 
| `analysis_dump_frequency`             | Analysis frequency              | `int`    | `0`                         | 
| `trigger_thermo_state`                | Thermodynamic state calculation | `bool`   | `true`                      | 
| `compute_loop_continue`               | Whether loop continues or not   | `bool`   | `0`                         | 
| `init_temperature`                    | Initial temperature             | `float`  | `-1.0`                      | 
| `scale_temperature`                   | Scaling temperature             | `float`  | `-1.0`                      | 
| `enable_load_balanceg`                | Allows load balancing           | `bool`   | `true`                      | 
| `simulation_load_balance_frequency`   | Load balancing frequency        | `int`    | `100`                       | 
| `trigger_cost_model_fitting`          | Trigger cost model fitting      | `bool`   | `false`                     | 
| `cost_model_coefs`                    | Cost model coefs                | `list`   | `[ 0.0 , 0.0 , 1.0 , 0.0 ]` | 
| `enable_task_graph`                   | Enables task graph              | `bool`   | `false`                     | 
| `enable_grid_compact`                 | Enables grid compaction         | `bool`   | `true`                      | 

In practice, the user doesn't need to think about some of these variables as they only serve as input for the simulation initialization. Here's a minimal `global` block you can use to start your simulation with.

```yaml linenums="1"
global:
  dt: 1.0e-3 ps
  rcut_inc: 1.0 ang
  simulation_end_iteration: 1000
  simulation_log_frequency: 10
  simulation_dump_thermo_frequency: 10  
  simulation_dump_frequency: 1000
  analysis_dump_frequency: 0
```  

---
icon: lucide/cog
---

# **Configuration files**

In `exaStamp`, multiple configuration files are located in the `data/config` folder. The master configuration file is the `main-config.msp` file which controls the entire simulation graph and defines both `simulation`, `includes` and `configuration` blocks. The content of `main-config.msp` and all other configuration files are displayed below.

## **Files included by default**

### Main configuration

The `main-config.msp` file is included by default by your input file when launching `exaStamp`. You can redefine its content to define new simulation scenarios at your own risk.
    
??? note "`main-config.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/main-config.msp"
    ```

### Particle species

The `config_species.msp` file defines the default periodic table (H to Og) used to generate default particle species, with mass, atomic number and charge, whenever the input data reader does not provide a species description itself. It also defines `reduce_species_after_read`, which trims this species list down to the species actually present in the system once the input data has been read.

??? note "`config_species.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_species.msp"
    ```

### Default configuration block

The `config_defaults.msp` file defines the `configuration` block, which sets the default physical units (angstrom, Dalton, picosecond, elementary charge, kelvin, etc.), logging/profiling/debug options, and threading settings (`mpimt`, `pinethreads`, `num_threads`).

??? note "`config_defaults.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_defaults.msp"
    ```

### Particle motion and neighbor lists

The `config_move_particles.msp` file defines the operators used to move particles across MPI domains, update ghost particles and neighbor lists, and trigger load balancing. It includes `config_load_balance.msp` by default, which defines the default load-balancing cost model and RCB-based balancing operators.

??? note "`config_move_particles.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_move_particles.msp"
    ```
### Numerical schemes

The `config_numerical_schemes.msp` file contains the `exaStamp` default and available numerical schemes: velocity-Verlet NVE, Langevin NVT, Berendsen NVT, and Nosé-Hoover NVT/NPT. The scheme actually used is selected through the `numerical_scheme` variable.

??? note "`config_numerical_schemes.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_numerical_schemes.msp"
    ```

### Global block

The `config_globals.msp` file defines the `global` block, which holds simulation-wide default variables such as the number of timesteps, timestep size, restart/snapshot/analysis/thermostate frequencies, and load-balancing parameters.

??? note "`config_globals.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_globals.msp"
    ```

### Thermodynamic state

The `config_thermostate.msp` file defines the trigger, compute, screen-print and file-write operators for the thermodynamic state (temperature, pressure, energy, etc.).

??? note "`config_thermostate.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_thermostate.msp"
    ```

### Snapshots

The `config_snapshot.msp` file defines the trigger and write operators for simulation snapshots, along with a collection of predefined writers (Paraview, grid VTK, XYZ, LAMMPS data) used for visualization.

??? note "`config_snapshot.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_snapshot.msp"
    ```

### Restarts

The `config_restart.msp` file defines the trigger and write operators for restart files, along with a collection of predefined writers (ExaStampV4, StampV4, StampV3, native atoms/molecule/rigid-molecule formats) used to continue a stopped simulation.

??? note "`config_restart.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_restart.msp"
    ```

### Analysis

The `config_analysis.msp` file defines the trigger and compute operators for on-the-fly analysis, along with a predefined connected-component labeling operator (`perform_analysis_ccl`).

??? note "`config_analysis.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_analysis.msp"
    ```

### System setup

The `config_setup_system.msp` file contains the default definition of the `setup_system` block. By default, it tries to read the `lastLegacyDump` file with `StampV3` format. If the read fails, it generates a default species and print the message `No input data`.

??? note "`config_setup_system.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_setup_system.msp"
    ```

## **Additional available files**

Additional files available to the `includes:` command are located in `data/config`. Depending on your simulation scenario, include them as follows:

```yaml linenums="1"
includes:
  - file1.msp
  - file2.msp
```

### Applying deformation

Whenever you need to dynamically impose a deformation to your box through the `xform_function` operator, include the `config_deformation.msp` file. This file pre-applies a deformation gradient tensor called `deformation_xform` to the simulation cell and appends the `xform_function` operator to the `md_loop_prolog`. This basically means that each timestep, the user-defined deformation will be applied at the end of the step.

??? note "`config_deformation.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_deformation.msp"
    ```
### Nosé-Hoover ensembles

Whenever you use one of the Nosé-Hoover numerical schemes (`verlet_nhnvt` or `verlet_nhnpt`, defined in `config_numerical_schemes.msp`), include the `config_nose_hoover.msp` file. It initializes the Nosé-Hoover chain variables and defines `nose_hoover_additional_step`, the extra integration step these schemes require at the end of each timestep.

??? note "`config_nose_hoover.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_nose_hoover.msp"
    ```

### Symmetric force contributions

Whenever your force field can exploit Newton's third law to halve pair computations, include the `config_update_symmetric_forces.msp` file. It zeroes forces and energies on ghost particles too, then adds a step that accumulates ghost contributions back onto local particles before forces are pushed to acceleration.

??? note "`config_update_symmetric_forces.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_update_symmetric_forces.msp"
    ```

### Flexible molecules

Whenever your simulation involves flexible (bonded) molecules, include the `config_molecule.msp` file. It switches to an extramolecular neighbor list, adds bonded (bond/bend/torsion/improper) and non-bonded force computations, sets a dedicated molecule restart writer, and adjusts the default domain cell size.

??? note "`config_molecule.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_molecule.msp"
    ```

### Rigid molecules

Whenever your simulation involves rigid molecules, include the `config_rigid_molecule.msp` file. It defines rigid-molecule-specific thermodynamic state, restart, and numerical-scheme operators (quaternion/torque integration), plus an optional temperature initialization step.

??? note "`config_rigid_molecule.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_rigid_molecule.msp"
    ```

### Load balancing auto-tuning

Whenever you want the load-balancing cost model to be fitted automatically from measured per-cell compute costs, instead of relying on the fixed `cost_model_coefs` values, include the `config_load_balance_auto_tune.msp` file. It periodically profiles the grid and re-fits the cost model at the frequency set by `simulation_load_balance_frequency`.

??? note "`config_load_balance_auto_tune.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_load_balance_auto_tune.msp"
    ```
<!-- 
### Parrinello-Rahman barostat

!!! warning
    
    This feature is deprecated and unmaintained as a more general Nosé-Hoover NPT ensemble is now available.

Whenever you need an NPT simulation using the Parrinello-Rahman barostat, include the `config_parrinellorahman.msp` file. It replaces the default `numerical_scheme` with one that pushes and converges the cell deformation alongside particle positions and velocities.

??? note "`config_parrinellorahman.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_parrinellorahman.msp"
    ```

### Speculative Verlet integration

Whenever you want to overlap neighbor-list update checks with force computation to reduce synchronization overhead, include the `config_speculative_verlet.msp` file. It replaces the default `numerical_scheme` with a speculative velocity-Verlet scheme that starts checking whether a full particle update is needed in the background, falling back to a full update only if it turns out to be necessary.

??? note "`config_speculative_verlet.msp` content"
    ```yaml linenums="1"
    --8<-- "docs/files/config_speculative_verlet.msp"
    ``` -->

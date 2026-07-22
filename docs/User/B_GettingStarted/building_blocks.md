---
icon: lucide/brick-wall
---

# Building Blocks

This part of the documentation is dedicated to the `exaStamp` simulation graph and default configuration of its constitutive elements. The entire simulation workflow is defined by a combination of operators that can be interconnected, each of which can expect some data as input and generate data as output.

The default simulation graph of an `exaStamp` simulation is defined in `data/config/main-config.msp` where `data/config` contains a variety of configuration files that can be included in any simulation's input file. Below we define the building blocks of any `exaStamp` simulation, namely:

- `simulation` block
- `includes` block
- `configuration` block

## **Simulation block**

The most important block of an `exaStamp` simulation is the `simulation` block which entirely defines how a full simulation works, i.e. from the logo printed to the screen up to the hardware finalization after the simulation has run. The `simulation` block is a `YAML` batch operator that contains a `name` and a `body`.

```yaml linenums="1"
--8<-- "docs/files/simulation.msp"
```

The above scenario represents the default simulation graph of an `exaStamp` simulation. A lot of the operators present in the `body` list are of course not to be defined by the user as they concern the hardware initialization, screen logging, statistics and other operations needed to initialize and configure the simulation. These operators are generally filled by `including` some configuration files.

However, some operators in that graph are required and need to be defined by the user. Among them are the interatomic potential, the particles species, the numerical scheme and so on. We consider that the mandatory blocks to be defined by the user to build a minimal input deck for `exaStamp` are the following ones:

```yaml
- global           # Global control of simulation parameters
- species          # Definition of the particles' species
- compute_force    # Choice of the interatomic potential
- domain           # Definition of the simulation's domain
- particle_regions # Spatial regions (optional)
- setup_system     # Population of the domain with particles
```

## **Includes block**

The includes block allows you to include other `YAML` files to your input file. The behavior of the `includes` block itself is explained in detail in [YAML extensions](yaml_extensions.md).

### Default includes

By default, the `includes` block is defined as follows:

```yaml linenums="1"
includes:
  - config_defaults.msp                # Configuration block default definition
  - config_move_particles.msp          # Operators for updating particles/neighbors positions + move across domain + neighbor lists
  - config_numerical_schemes.msp       # Numerical schemes (NVE, LNVT, BNVT, NHNVT, NHNPT)
  - config_globals.msp                 # Global block definition with simulation-wide default variables (global control of simulation)
  - config_thermostate.msp             # Thermodynamic state trigger + print/write operators (screen/file/compute)
  - config_snapshot.msp                # Snapshots trigger + write operators (for visualization)
  - config_restart.msp                 # Restarts trigger + write operators (to continue a stopped simulation)
  - config_analysis.msp                # Analysis trigger + compute operators (for on-the-fly analysis)
  - config_setup_system.msp            # Default setup_system operator for setting up the system
```

where all the `config_*` files contain predefined operators and parameters required by an `exaStamp` simulation. These default configuration files are explained in detail in [Configuration files](configuration_files.md).

### Adding your own includes

Adding the `includes` block to your input file will not erase that definition but append the `included` files to the list above. Thus, if you want for example to consider an additional file named `my_additional_file.yaml` in which you have defined a specific operator, you can do as follows:

```yaml linenums="1"
includes:
  - my_additional_file.yaml
```

The advantage of this `includes` block is that you can avoid having a very long input file and allow for multiple variations of a simulation parametrization.

### Additional available includes

In addition to the default included files as described above, these files are also always available to the `includes:` strategy:

```yaml
config_deformation.msp               # Deformation-driven simulations
config_nose_hoover.msp               # Nosé-Hoover thermostat and/or barostat
config_update_symmetric_forces.msp   # For reciprocal forces contributions at ghosts boundaries
config_molecule.msp                  # Flexible molecules trajectories
config_rigid_molecule.msp            # Rigid molecules trajectories
config_load_balance_auto_tune.msp    # Automatic tuning of the load-balancing cost model
```    

They are available in the `data/config` folder located at the root of `exaStamp` code. The content of all configuration files is explained in [Configuration files](configuration_files.md).

## **Configuration block**

The first elementary block for an `exaStamp` simulation is the `configuration` block. This block serves as a placeholder for configuring both physical units to be used, logging properties, profiling and debugging features as well as specific instructions of MPI x OMP and GPU execution. Below is the full `configuration` block with its default values.

```yaml linenums="1"
--8<-- "docs/files/config_defaults.msp"
```

Usually, you do not need to redeclare this entire block in your simulation input file. For example, if you just want to print a summary of the simulation execution graph at the end of your run, you can add to your input file the following:

```yaml linenums="1"
configuration:
  profiling:
    summary: true
```

This will only redefine the `summary` key's value of the `profiling` dictionary. Additionally, we do not recommend you to redefine units as for now they are designed to better control the internal units. In addition, we do not guarantee yet that the appropriate conversions are correctly done for outputs. Thus, modifying units should be done at your own risk.
---
icon: lucide/square-play
---

# Working Example

Putting together the blocks introduced in this Starter Pack gives a complete, working `exaStamp` input file. The example below generates a BCC Tantalum crystal at 600 K with `lattice`/`init_temperature_new`, relaxes it towards 300 K under the `eam_alloy_force` potential with a Langevin thermostat, and periodically writes `.xyz` snapshots:

```yaml linenums="1"
# --- Particles species (see Particles Species) ---
species:
  - Ta: { mass: 180.95 Da, z: 73, charge: 0 e- }

# --- Domain + system setup: BCC lattice at 600 K (see Simulation Domain / Input Data) ---
setup_system:
  - domain:
      cell_size: 3.3 ang
      grid_dims: [ 20, 20, 20 ]
      bounds: [ [ 0 ang, 0 ang, 0 ang ], [ 66 ang, 66 ang, 66 ang ] ]
      periodic: [ true, true, true ]
      expandable: false
  - init_rcb_grid
  - lattice:
      structure: BCC
      types: [ Ta, Ta ]
      size: [ 3.3 ang, 3.3 ang, 3.3 ang ]
  - init_temperature_new:
      T: 600 K

# --- Interatomic potential: EAM alloy, single pass (see Interatomic Potential) ---
eam_alloy_force:
  rcut: 5.30 ang
  parameters:
    file: "Ta1_Ravelo_2013.eam.alloy"

compute_force:
  - eam_alloy_force

# --- Numerical scheme: Langevin NVT, 300 K target (see Numerical Scheme) ---
numerical_scheme: verlet_lnvt

langevin_thermostat:
  T: 300 K
  gamma: 0.1 ps^-1

# --- Global control (see Global Control) ---
global:
  max_iteration: 1000
  dt: 1.0e-3 ps
  rcut_inc: 1.0 ang
  simulation_thermostate_screen_frequency: 10
  simulation_thermostate_file_frequency: 10
  simulation_restart_frequency: 1000
  simulation_snapshot_frequency: 100
  simulation_analysis_frequency: 0

# --- Output: XYZ snapshots (see Output Data) ---
write_snapshot: write_snapshot_xyz
```

!!! note

    For compactness, `domain` and `init_rcb_grid` are nested directly inside `setup_system` above instead of being declared as separate top-level keys. This is not a problem: the [`simulation` block](../B_GettingStarted/building_blocks.md#simulation-block) already calls `domain` once, earlier in its `body`, before `setup_system` runs — nesting a fresh `domain:` step inside `setup_system` simply re-invokes that same operator with the full lattice-ready parameters right before `init_rcb_grid`/`lattice` need them, overwriting the earlier, auto-deduced values. Both forms are equivalent; keeping everything needed to populate the domain in one place is just easier to read.

Each block maps directly back to the page that introduced it:

| Block                    | Covered in                                          |
| :------------------------ | :--------------------------------------------------- |
| `species`                 | [Particles Species](2_species.md)                    |
| `setup_system` (`domain`, `init_rcb_grid`, `lattice`, `init_temperature_new`) | [Simulation Domain](3_domain.md), [Input Data](4_setup_system.md) |
| `eam_alloy_force`, `compute_force` | [Interatomic Potential](5_force.md#eam-alloy-tantalum) |
| `numerical_scheme`, `langevin_thermostat` | [Numerical Scheme](6_numerical_scheme.md#langevin-nvt-verlet_lnvt) |
| `global`                  | [Global Control](1_global.md)                        |
| `write_snapshot`          | [Output Data](7_output.md)                           |

!!! tip

    Save this as e.g. `ta_bcc.msp` and launch it with `mpirun -np ${N_MPI} exaStamp ta_bcc.msp` (see [Running your simulation](../../BuildInstall/running.md)); it needs the `Ta1_Ravelo_2013.eam.alloy` parameter file to be available alongside it.

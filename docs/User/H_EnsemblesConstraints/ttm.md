---
icon: material/thermometer-lines
---

# **Two-Temperature Model**

The two-temperature model (TTM) adds an electronic subsystem to the classical ionic dynamics. The electronic temperature $T_e$ is a continuous field stored on a regular mesh (the cells of the simulation grid, optionally subdivided), while the ionic temperature comes from the particle velocities. The two subsystems exchange energy through a Langevin coupling, and $T_e$ diffuses according to the heat equation:

$$
C_e \, \rho_e \, \frac{\partial T_e}{\partial t} = \kappa_e \, \nabla^2 T_e \;-\; G_{e \to i} \;+\; S_e(\mathbf{r},t)
$$

where $C_e$ is the electronic specific heat, $\rho_e$ the electronic density, $\kappa_e$ the electronic thermal conductivity, $G_{e \to i}$ the power density transferred from the electrons to the ions in each mesh cell, and $S_e$ an optional external source (e.g. a laser deposition).

Each particle feels an additional Langevin force built from the local electronic temperature:

$$
\mathbf{F}_i = \mathbf{F}_i^{pot} \;-\; \gamma \, \mathbf{v}_i \;+\; \sqrt{\frac{2 \, k_B \, \gamma_p \, T_e(\mathbf{r}_i)}{\Delta t}} \; \boldsymbol{\xi}_i,
\qquad
\gamma =
\begin{cases}
\gamma_p & \text{if } |\mathbf{v}_i| \le v_0 \\
\gamma_p + \gamma_s & \text{if } |\mathbf{v}_i| > v_0
\end{cases}
$$

with $\boldsymbol{\xi}_i$ a random vector of unit variance (the stopping term $\gamma_s$ only adds friction, not noise). $\gamma_p$ is the electron-phonon coupling and $\gamma_s$ the electronic stopping friction, active above the velocity threshold $v_0$. The work of this force on the particles of a cell is removed from the electronic energy of that cell, so the total energy (ions + electrons) is conserved in the absence of external source.

Two operators implement the model:

- `init_ttm` sets the initial $T_e$ field;
- `ionic_eletronic_heat_transfer` applies the Langevin coupling and advances $T_e$ by one timestep. It is called in `compute_force`, after the potential.

!!! note "Operator name"
    The heat-transfer operator is registered as `ionic_eletronic_heat_transfer` (with this exact spelling).

## **`init_ttm`**

Creates the `te` grid field (if it does not exist yet) and fills it from a source term evaluated at the center of each subcell, at the current physical time.

```{ .yaml title="Syntax" .syntax-block }
init_ttm:
  grid_subdiv: <int>
  te_source: <source term>
  ti_source: <source term>
```

```{ .yaml title="Parameters" .params-block }
grid_subdiv:  int, default 3            # Number of subdivisions of each grid cell per direction (subdiv^3 Te values per cell).
te_source:    source term               # Initial electronic temperature field (see Source terms below).
ti_source:    source term               # Not used by init_ttm; usually set to "null".
```

`init_ttm` must come after `resize_grid_cell_values` in `setup_system`, and `grid_subdiv` must match the value given to `ionic_eletronic_heat_transfer`.

## **`ionic_eletronic_heat_transfer`**

At each timestep the operator:

1. applies the Langevin force above to every particle, using a local $T_e$ averaged over the subcells overlapped by the particle footprint (a cube of side `splat_size`), and deposits the corresponding work back on the same subcells;
2. solves the heat equation for $T_e$ on the local cells with an explicit scheme: conduction $\kappa_e \nabla^2 T_e$, the coupling sink and the source $S_e$. If `substep_diffusion` is enabled and one timestep exceeds the stability limit of the explicit scheme, the diffusion step is split into several smaller substeps, with an exchange of the ghost $T_e$ values between them;
3. updates the total electronic energy and the energy transferred to the ions during the step.

On the first step (`timestep` 0), only the electronic energy is computed: the coupling and the diffusion start at step 1.

```{ .yaml title="Syntax" .syntax-block }
ionic_eletronic_heat_transfer:
  gamma_p: <float>
  gamma_s: <float>
  v_0: <float>
  uniform_noise: <bool>
  Ke: <float>
  Ce: <float>
  rho_e: <float>
  te_source: <source term>
  ti_source: <source term>
  grid_subdiv: <int>
  splat_size: <float>
  substep_diffusion: <bool>
  copy_ti_te: <bool>
```

```{ .yaml title="Parameters" .params-block }
gamma_p:            float, default 0.0     # Electron-phonon friction coefficient (mass/time, e.g. Da/ps). 0 disables the coupling.
gamma_s:            float, default 0.0     # Electronic stopping friction, added to gamma_p above v_0 (mass/time).
v_0:                float, default 0.0     # Velocity threshold for electronic stopping (velocity, e.g. ang/ps).
uniform_noise:      bool, default false    # false: Gaussian noise. true: uniform noise in [-0.5,0.5) with the same variance.
Ke:                 float, default 1.0     # Electronic thermal conductivity kappa_e (e.g. eV/ps/ang/K).
Ce:                 float, default 1.0     # Electronic specific heat C_e (e.g. eV/K).
rho_e:              float, default 1.0     # Electronic density rho_e (e.g. 1/ang^3).
te_source:          source term, "null"    # External electronic power density S_e(r,t) (energy/time/volume).
ti_source:          source term, "null"    # Not used by the dynamics; usually set to "null".
grid_subdiv:        int, default 3         # Subdivisions per grid cell and direction; must match init_ttm.
splat_size:         float, default 1.0     # Size of the particle footprint on the Te mesh; must not exceed the subcell size.
substep_diffusion:  bool, default false    # Split the diffusion step when the explicit-scheme stability limit is exceeded.
copy_ti_te:         bool, default false    # Debug: set Te to the local ionic temperature and skip the coupling and diffusion.
```

!!! warning "Units"
    Give physical parameters with their units (e.g. `Ce: 1.2470e-5 eV/K`). A bare number is interpreted in internal units (ang, Da, ps, K), not in eV.

!!! warning "Ghost velocities"
    The coupling is also applied to ghost particles, which need up-to-date velocities. Call `ghost_update_r_v` just before `ionic_eletronic_heat_transfer` in `compute_force` (the default ghost update only sends positions).

!!! note "Mesh and cutoff"
    The $T_e$ mesh is made of the simulation grid cells, each divided into `grid_subdiv`$^3$ subcells, so the mesh spacing is `cell_size / grid_subdiv`. Ghost cells must exist (the Laplacian needs them). The operator increases `rcut_max` if needed so that the ghost region covers `splat_size / 2`.

### Source terms

`te_source` and `ti_source` take one of the following forms. In `init_ttm` the value is a temperature; in `ionic_eletronic_heat_transfer`, `te_source` is a power density.

```yaml title="Source terms"
te_source: "null"                    # zero everywhere

te_source:
  constant: 1800.0 K                 # uniform value

te_source:
  sphere:                            # A * exp( -(|r-c|-r0)^2/(2 dr^2) - (t-t0)^2/(2 dt^2) )
    center: [ 66.0 ang, 66.0 ang, 16.5 ang ]
    amplitude: 5000.0 K
    radius_mean: 20.0 ang
    radius_dev: 2.0 ang
    time_mean: 0.3 ps
    time_dev: 0.01 ps

te_source:
  wavefront:                         # (r.N1 + D1) + A * sin( r.N2 + D2 )
    plane: [ 1.0, 0.0, 0.0, 0.0 ]    # N1x, N1y, N1z, D1
    wave:  [ 0.0, 1.0, 0.0, 0.0 ]    # N2x, N2y, N2z, D2
    amplitude: 1.0
```

## **Thermodynamic output**

The total electronic energy and the energy transferred from the electrons to the ions during the step are available as the `ele` and `ite` columns of the thermodynamic state (see [Output](../../Beginner/StarterPack/7_output.md#thermo-output)). They are added automatically to the printed columns when the model is active. The total energy `toe` includes the electronic energy.

## **Example**

Iron with an EAM potential, electrons initially at 1800 K and ions at room temperature, no external source:

```yaml title="Usage example (exaStamp/data/regression_new/ttm/ttm_Fe_test.msp)"
species:
  - Fe: { mass: 55.845 Da , z: 26 , charge: 0.0 e- }

eam_alloy_force:
  rcut: 4.1615 ang
  parameters:
    file: "Fe_Olsson_CMS2009.eam.alloy"

setup_system:
  - domain:
      cell_size: 5.7399999 ang
      periodic: [ true, true, true ]
      expandable: false
  - read_xyz_file_with_xform:
      filename: "Fe_disturbed.xyz"
  - resize_grid_cell_values
  - init_ttm:
      grid_subdiv: 1
      ti_source: "null"
      te_source:
        constant: 1800.0 K

compute_force:
  - eam_alloy_force
  - ghost_update_r_v
  - ionic_eletronic_heat_transfer:
      gamma_p: 29.5917 Da/ps
      gamma_s: 47.5679 Da/ps
      v_0: 58.4613 ang/ps
      Ke: 0.005365 eV/ps/ang/K
      Ce: 1.2470e-5 eV/K
      rho_e: 0.087614 1/ang^3
      splat_size: 0.1 ang
      grid_subdiv: 1
      ti_source: "null"
      te_source: "null"
      substep_diffusion: true

global:
  dt: 1e-4 ps
  rcut_inc: 1.5 ang
  max_iteration: 200
  simulation_thermostate_screen_frequency: 10
  log_mode: "stp;tmp;toe;poe;ele;ite"
```

Other examples are available in `exaStamp/data/regression_new/ttm/` (spherical and constant sources, diffusion substeps).

!!! tip "Electronic-temperature-dependent SNAP"
    The $T_e$ field can also drive an interatomic potential whose coefficients depend on the local electronic temperature. See the SNAP-TTM section of the [SNAP page](../G_ForceFields/MLIP/snap.md).

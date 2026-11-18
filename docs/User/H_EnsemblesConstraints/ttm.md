---
icon: material/thermometer-lines
---

# **Two-Temperature Model**

The two-temperature model (TTM) adds an electronic subsystem to the classical ionic dynamics. The electronic temperature $T_e$ is a continuous field stored on a regular mesh (the cells of the simulation grid, optionally subdivided), while the ionic temperature comes from the particle velocities. The two subsystems exchange energy through a Langevin coupling, and $T_e$ diffuses according to the heat equation:

$$
C_e \, \rho_e \, \frac{\partial T_e}{\partial t} = \kappa_e \, \nabla^2 T_e \;-\; G_{e \to i} \;+\; S_e(\mathbf{r},t)
$$

where $C_e$ is the electronic specific heat, $\rho_e$ the electronic density, $\kappa_e$ the electronic thermal conductivity, $G_{e \to i}$ the power density transferred from the electrons to the ions in each mesh cell, and $S_e$ an optional external source (e.g. a laser deposition). The volumetric heat capacity $C_e \rho_e$ and the electron-phonon coupling can also be given as functions of $T_e$ (see [Te-dependent electron parameters](#te-dependent-electron-parameters)).

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
2. solves the heat equation for $T_e$ on the local cells with an explicit scheme: conduction $\kappa_e \nabla^2 T_e$, the coupling sink and the source $S_e$. If `substep_diffusion` is enabled and one timestep exceeds the stability limit of the explicit scheme, the diffusion step is split into several smaller substeps, with an exchange of the ghost $T_e$ values between them. With a $T_e$-dependent heat capacity, the stability limit uses the smallest $C_e$ on the mesh at the start of the step;
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
  Ce_te: <piecewise polynomial>
  Gei_te: <piecewise polynomial>
  n_ion: <float>
  te_valid_min: <float>
  te_valid_max: <float>
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
Ce_te:              piecewise polynomial   # Optional. Volumetric electron heat capacity C_e(Te), replaces Ce*rho_e (see below).
Gei_te:             piecewise polynomial   # Optional. Electron-phonon coupling factor G_ei(Te), replaces gamma_p (see below).
n_ion:              float                  # Ionic number density (e.g. 1/ang^3). Required with Gei_te.
te_valid_min:       float, default 0.0     # Validity range of the Te-dependent fits [K]: a warning is printed when
te_valid_max:       float, default 1.0e4   #   Te leaves it. Values are not clipped.
```

!!! warning "Units"
    Give physical parameters with their units (e.g. `Ce: 1.2470e-5 eV/K`). A bare number is interpreted in internal units (ang, Da, ps, K), not in eV.

!!! warning "Ghost velocities"
    The coupling is also applied to ghost particles, which need up-to-date velocities. Call `ghost_update_r_v` just before `ionic_eletronic_heat_transfer` in `compute_force` (the default ghost update only sends positions).

!!! note "Mesh and cutoff"
    The $T_e$ mesh is made of the simulation grid cells, each divided into `grid_subdiv`$^3$ subcells, so the mesh spacing is `cell_size / grid_subdiv`. Ghost cells must exist (the Laplacian needs them). The operator increases `rcut_max` if needed so that the ghost region covers `splat_size / 2`.

### Te-dependent electron parameters

The electronic heat capacity and the electron-phonon coupling of most metals vary strongly with $T_e$ at the temperatures reached after a laser or ion irradiation. `Ce_te` and `Gei_te` give them as piecewise polynomials of $T_e$, evaluated in every subcell at every step:

$$
y(T_e) = y_{scale} \; P_k(x_{scale} \, T_e), \qquad P_k(x) = \sum_i c_{k,i} \, x^i
$$

where piece $k$ is used while $T_e$ is below breakpoint $k$, and the last piece is used above the last breakpoint. Each one replaces a constant parameter:

- `Ce_te` is the volumetric electron heat capacity $C_e(T_e)$ (energy per volume per kelvin, e.g. J/m³/K). It replaces the product `Ce*rho_e`, which is then ignored.
- `Gei_te` is the electron-phonon coupling factor $G_{ei}(T_e)$ (power per volume per kelvin, e.g. W/m³/K). It replaces `gamma_p` through the friction coefficient of each particle of mass $m$:

$$
\gamma_p(T_e) = \frac{m \, G_{ei}(T_e)}{3 \, n_{ion} \, k_B}
$$

with $n_{ion}$ the ionic number density (`n_ion`). The two parameters are independent: either one can be used alone, with the constant form of the other.

With a $T_e$-dependent heat capacity, $T_e$ is advanced in energy form. The electronic energy density

$$
E(T_e) = \int_0^{T_e} C_e(T) \, dT
$$

receives the conduction, coupling and source power over the step, and the new $T_e$ is obtained by inverting $E(T_e)$ (Newton iteration). The electronic energy therefore changes by exactly the energy exchanged with the ions and injected by the source, as with a constant heat capacity. The total electronic energy reported in the thermodynamic output is the sum of $E(T_e)$ over the mesh.

```{ .yaml title="Piecewise polynomial syntax" .syntax-block }
Ce_te:
  unit: <unit string>
  x_scale: <float>
  y_scale: <float>
  breakpoints: [ <float>, ... ]
  coefficients: [ [ <float>, ... ], ... ]
```

```{ .yaml title="Piecewise polynomial parameters" .params-block }
unit:          string, required      # Unit of y_scale*P(x), converted to internal units (e.g. J/m^3/K, J/s/m^3/K).
x_scale:       float, default 1.0    # The polynomials are evaluated at x = x_scale*Te (Te in K).
y_scale:       float, default 1.0    # Scale factor applied to the polynomial value.
breakpoints:   list of floats        # Temperatures [K] between the pieces, positive and strictly increasing.
                                     #   One less than the number of pieces; omitted for a single piece.
coefficients:  list of lists         # One list per piece, constant term first. Up to 4 pieces, 8 coefficients each.
```

!!! warning "Validity range"
    The fits are only valid over the temperature range they were made for. A warning is printed when $T_e$ leaves [`te_valid_min`, `te_valid_max`]. The polynomials are still evaluated there (values are not clipped). The run stops if the heat capacity becomes non-positive, or if a subcell loses all its electronic energy.

Example for gold, with $C_e$ in J/m³/K and $G_{ei}$ fitted in $x = T_e \times 10^{-4}$ and in units of $10^{17}$ W/m³/K:

```yaml title="Te-dependent parameters (gold)"
ionic_eletronic_heat_transfer:
  Ke: 0.01 eV/ps/ang/K
  splat_size: 0.1 ang
  grid_subdiv: 2
  ti_source: "null"
  te_source: "null"
  substep_diffusion: true
  Ce_te:                                   # 67.6*Te below 2200 K, then quadratic, then degree 5 above 5500 K
    unit: J/m^3/K
    breakpoints: [ 2200.0, 5500.0 ]
    coefficients:
      - [ 0.0, 67.6 ]
      - [ 22135.0, 12.685, 1.8962e-2 ]
      - [ -4.027e5, 210.74, -3.0463e-3, 4.0076e-8, 0.0, 1.0652e-18 ]
  Gei_te:
    unit: J/s/m^3/K
    x_scale: 1.0e-4
    y_scale: 1.0e17
    breakpoints: [ 2100.0, 4400.0 ]
    coefficients:
      - [ 0.251 ]
      - [ 0.25353, 0.042859, -0.92027, 3.1317 ]
      - [ -0.53893, 2.3867, -0.83833, 0.15177, -0.013335, -4.5018e-4 ]
  n_ion: 0.058983 1/ang^3                  # FCC gold, 4 atoms / (4.078 ang)^3
  te_valid_max: 1.0e4
```

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

Other examples are available in `exaStamp/data/regression_new/ttm/` (spherical and constant sources, diffusion substeps, $T_e$-dependent parameters for gold in `ttm_Au_te_dep.msp`) and in the `ttm_*` cases of `exaStamp/data/regression_new/physics_regression/`.

!!! tip "Electronic-temperature-dependent SNAP"
    The $T_e$ field can also drive an interatomic potential whose coefficients depend on the local electronic temperature. See the SNAP-TTM section of the [SNAP page](../G_ForceFields/MLIP/snap.md).

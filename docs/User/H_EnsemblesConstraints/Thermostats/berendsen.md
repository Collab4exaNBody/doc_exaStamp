---
icon: material/waves
---

# **Berendsen Thermostat**

A weak-coupling thermostat: atom velocities are rescaled every step so the system's temperature relaxes exponentially toward the target, with characteristic time $\tau$. It suppresses kinetic-energy fluctuations rather than sampling them correctly, so it does **not** produce trajectories consistent with the canonical ensemble — unlike Nosé-Hoover, this is a rescaling shortcut, not a real thermostat in the statistical-mechanics sense.

$$
\frac{dT}{dt} = \frac{1}{\tau}\left(T^* - T\right)
\quad\Rightarrow\quad
\Delta T = \frac{dt}{\tau}\left(T^* - T\right)
\quad\Rightarrow\quad
\lambda = \sqrt{1 + \frac{dt}{\tau}\left(\frac{T^*}{T} - 1\right)}
$$

where $T^*$ is the target temperature, $T$ the instantaneous temperature, and $\lambda$ the velocity-scaling factor applied each step.

```{ .yaml title="Syntax" .syntax-block }
berendsen_thermostat:
  T: <float>
  Tstart: <float>
  Tstop: <float>
  tserie: [<float>, ...]
  Tserie: [<float>, ...]
  tau: <float>
  region: <string>
```

```{ .yaml title="Parameters" .params-block }
T:       float, optional              # Constant target temperature — mutually exclusive with Tstart/Tstop and tserie/Tserie.
Tstart:  float, optional              # Starting target temperature (linear ramp with Tstop).
Tstop:   float, optional              # Final target temperature (linear ramp with Tstart).
tserie:  list of floats, optional     # Physical times for a piecewise-interpolated target temperature.
Tserie:  list of floats, optional     # Target temperatures at each tserie time — same length as tserie.
tau:     float, default 0.1           # Coupling characteristic time.
region:  string, optional             # Restrict to a geometric region.
```

Exactly one of the three target-temperature forms (`T` / `Tstart`+`Tstop` / `tserie`+`Tserie`) must be given — the simulation aborts if none or more than one is set.

```yaml title="Usage example"
numerical_scheme: verlet_bnvt

# constant target temperature
berendsen_thermostat: { T: 300. K, tau: 0.1 ps }

# linear ramp
berendsen_thermostat: { Tstart: 5. K, Tstop: 1000. K, tau: 0.1 ps }

# piecewise-interpolated
berendsen_thermostat:
  tserie: [0, 10., 20.]
  Tserie: [5., 500., 500.]
  tau: 0.1 ps
```

!!! warning

    `berendsen_thermostat` performs no time integration itself and needs the instantaneous temperature — it must come *after* `simulation_thermodynamic_state` in the scheme body, unlike Nosé-Hoover which replaces the scheme entirely. `exaStamp` already ships this wiring as the `verlet_bnvt` scheme below, so in practice you don't need to build the body yourself — just point `numerical_scheme` at it.

## **The `verlet_bnvt` scheme**

`verlet_bnvt` (`exaStamp/data/config/config_numerical_schemes.msp`) expands to:

```yaml title="Usage example"
verlet_bnvt:
  name: BNVT_scheme
  body:
    - verlet_first_half
    - check_and_update_particles
    - load_balance_auto_tune_start
    - compute_force_prolog
    - compute_force
    - compute_force_epilog
    - verlet_second_half
    - simulation_thermodynamic_state
    - berendsen_thermostat
    - load_balance_auto_tune_end
```

Plain velocity-Verlet (identical to [`verlet_nve`](../nve_ensemble.md#the-verlet_nve-scheme)) with `simulation_thermodynamic_state` + `berendsen_thermostat` appended after `verlet_second_half` — exactly why `berendsen_thermostat` needs the instantaneous temperature to already be available at that point in the body.

---
icon: material/thermometer
---

# **NVT ensemble**

## **Nosé-Hoover thermostat**

Unlike [Berendsen](Thermostats/berendsen.md) or [Langevin](Thermostats/langevin.md), the Nosé-Hoover thermostat doesn't bolt onto an existing integration scheme — it *replaces* the time-integration scheme itself, extending the equations of motion with an extra thermostat degree of freedom $\eta$ that couples the system to a target temperature.

!!! tip "Nosé-Hoover thermostat equations"

    At initialization, the thermostat variable and its derivatives start at zero, and the coupling frequency is set from the user-provided coupling period $t_{period}$ (`Tdamp`):

    $$
    \eta = \dot{\eta} = \ddot{\eta} = 0, \qquad t_{freq} = \frac{1}{t_{period}}
    $$

    At each step, given the target temperature $T^*$ (which may itself be constant, linearly ramped, or piecewise-interpolated over time — same three modes as the other thermostats), the target kinetic energy is:

    $$
    N_{dof} = 3 N_{atoms} - 3, \qquad KE^* = N_{dof} \, k_B \, T^*
    $$

    and the thermostat's own mass and acceleration are:

    $$
    \eta_M = \frac{KE^*}{t_{freq}^2}, \qquad \ddot{\eta} = t_{freq}^2 \left( \frac{KE_{cur}}{KE^*} - 1 \right)
    $$

This feeds a velocity-scaling factor applied to every atom alongside the usual position/velocity integration steps, keeping the measured kinetic energy oscillating around $KE^*$ rather than being rescaled to it exactly every step (unlike Berendsen).

```{ .yaml title="Syntax" .syntax-block }
init_nose_hoover:
  algo: NVT
  Tstart: <float>
  Tend: <float>
  Tdamp: <float>
  tchain: <int>
```

```{ .yaml title="Parameters" .params-block }
algo:    string, default "NVT"    # "NVT" here — "NPT" adds a barostat, see NPT ensemble.
Tstart:  float, required          # Target temperature at the start of the run.
Tend:    float, optional          # Target temperature at the end of the run (linear ramp); defaults to Tstart if omitted.
Tdamp:   float, default 0.1       # Thermostat coupling time.
tchain:  int, default 3           # Length of the Nosé-Hoover chain.
```

This is a genuinely different parameter set from Berendsen/Langevin — there's no `T`/`Tstart`+`Tstop`/`tserie`+`Tserie` three-way choice here, just `Tstart` (required) and an optional `Tend` for a linear ramp.

`init_nose_hoover` only sets up the thermostat context; the actual per-step integration is done by a handful of companion operators (`setup_nose_hoover`, `nhc_temp_integrate`, …) wired automatically once `config_nose_hoover.msp` is included and `numerical_scheme` points at `verlet_nhnvt`:

```yaml title="Usage example"
includes:
  - config_nose_hoover.msp

init_nose_hoover:
  algo: NVT
  Tstart: 150. K
  Tend:   150. K
  Tdamp:  0.05 ps
  tchain: 3

numerical_scheme: verlet_nhnvt
```

!!! warning

    `config_nose_hoover.msp` must be included — it's what wires the per-step Nosé-Hoover operators into `+init_epilog`/`numerical_scheme`. Without it, `init_nose_hoover`'s output context isn't consumed by anything. Its full content (`exaStamp/data/config/config_nose_hoover.msp`):

    ```yaml
    +init_prolog:
      - deformation_xform:
          defbox: { extension: [ 1.0 , 1.0 , 1.0 ] }

    +init_epilog:
      - init_nose_hoover

    nose_hoover_additional_step:
      - setup_nose_hoover
      - couple_npt
    ```

## **The `verlet_nhnvt` scheme**

`verlet_nhnvt` (`exaStamp/data/config/config_numerical_schemes.msp`) expands to:

```yaml title="Usage example"
verlet_nhnvt:
  name: NHNVT_scheme
  body:
    - simulation_thermodynamic_state
    - nhc_temp_integrate
    - nh_v_temp:
        rebind: { value: vscale }
        body: [ scale_v ]
    - compute_vel_bias:
        rebind: { out: vbias }
        body: [ avg_v_m ]
    - remove_vel_bias:
        rebind: { value: vbias }
        body: [ shift_v ]
    - push_f_v: { dt_scale: 0.5, xform_mode: IDENTITY }
    - push_v_r: { dt_scale: 1.0, xform_mode: INV_XFORM }
    - check_and_update_particles
    - load_balance_auto_tune_start
    - compute_all_forces_energy
    - push_f_v: { dt_scale: 0.5, xform_mode: IDENTITY }
    - simulation_thermodynamic_state
    - nhc_temp_integrate
    - nh_v_temp:
        rebind: { value: vscale }
        body: [ scale_v ]
    - load_balance_auto_tune_end
```

Unlike the plain-Verlet schemes, this isn't `verlet_first_half`/`verlet_second_half` plus a bolted-on thermostat step — the thermostat integration is interleaved with the position/velocity pushes on both half-steps, LAMMPS-`fix nvt`-style:

- `nhc_temp_integrate` (`exaStamp/src/npt/nhc_temp_integrate.cpp`) advances the Nosé-Hoover chain (length `tchain`) from the current kinetic energy and target `KE^*`, and produces a uniform velocity-scaling factor on its `vscale` output.
- `nh_v_temp` isn't a standalone operator — it's a named batch that runs `scale_v` (`exaNBody/src/compute/generic_op_vec3.cu`) with its `value` input slot rebound to `vscale`, i.e. it multiplies every particle's velocity by the chain's scaling factor.
- `compute_vel_bias` batches `avg_v_m` (`exaStamp/src/compute/avg_v_m.cu`), rebinding its `out` output to `vbias` — a mass-weighted average velocity of the whole system, negated.
- `remove_vel_bias` batches `shift_v`, rebinding its `value` input to `vbias` — adding that negated average to every particle's velocity, which cancels out the system's net (center-of-mass) drift after the thermostat scaling.
- The thermostat/bias block runs *twice* per step (once before the position push, once after the force recomputation) — the same Nosé-Hoover chain half-step pattern used by `verlet_nhnpt` below.

`rebind`/`body` here is the same generic ONIKA batch mechanism as `numerical_scheme` itself: a named block (`nh_v_temp`, `compute_vel_bias`, `remove_vel_bias`) that wraps one or more operators and renames one of their slots for that particular use, rather than a distinct operator type.

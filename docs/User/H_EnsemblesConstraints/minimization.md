---
icon: material/chart-line-variant
---

# **Energy Minimization**

Unlike NVE/NVT/NPT, a minimization run isn't selected through [`numerical_scheme`](numerical_scheme.md) — each minimizer's config file (`exaStamp/data/config/config_conjugate_gradient.msp` / `config_fire.msp`) overrides the whole `simulation:` scenario itself, swapping the default `first_iteration`/`md_trajectory_loop` pair for its own. There is no `numerical_scheme:` entry to set for either; everything else (species, domain, load balancing, force computation, …) is reused unchanged.

Two independent minimizers are available:

| Include | Method | Advances real time? |
|---|---|---|
| `config_conjugate_gradient.msp` | Fletcher-Reeves conjugate gradient[^1] + Armijo backtracking line search[^2] | No — `cg_dt` stays 0, only the iteration counter moves |
| `config_fire.msp` | FIRE 2.0 (Bitzek et al. 2006[^3] / Guénolé et al. 2020[^4]) — inertial pseudo-dynamics | Yes — adaptive `fire_dt` |

## **Conjugate Gradient**

This is a purely static minimization, using the Fletcher-Reeves conjugate-gradient method[^1] with an Armijo backtracking line search[^2]: `vx`/`vy`/`vz` are repurposed to hold the CG search direction $\mathbf{h}$ rather than a real velocity, and `cg_dt` is fixed at 0.

!!! warning

    Because `vx`/`vy`/`vz` hold the search direction, not velocity, don't resume a time-integrated scheme (`verlet_nve`, …) directly from a restart file written during/after a CG run without first re-initializing velocities (`init_temperature`/`scale_temperature`) — otherwise the leftover direction vector would be read back in as spurious atomic velocities.

!!! tip "Conjugate-gradient equations (Fletcher-Reeves[^1] + Armijo backtracking[^2])"

    Fletcher-Reeves coefficient, forced to 0 (a plain steepest-descent restart) on the first iteration or every `cg_restart_period` iterations — plain Fletcher-Reeves directions degrade without a periodic restart:

    $$
    \beta = \frac{\|\mathbf{F}_{new}\|^2}{\|\mathbf{F}_{old}\|^2}
    $$

    Search direction, updated in place from the new force:

    $$
    \mathbf{h} \leftarrow \mathbf{F} + \beta\,\mathbf{h}
    $$

    Trial step, scaled so the largest single-atom displacement equals the current step size $\alpha$:

    $$
    \mathbf{r} \mathrel{+}= H^{-1}\, \mathbf{h}\, \frac{\alpha}{\max|\mathbf{h}|}
    $$

    Armijo sufficient-decrease bound — a trial is accepted when its energy falls at or below this:

    $$
    E_{bound} = E_{ref} + c_1\,\alpha\,\text{slope}, \qquad \text{slope} = -\frac{\mathbf{F}\cdot\mathbf{h}}{\max|\mathbf{h}|}
    $$

```{ .yaml title="Syntax" .syntax-block }
includes:
  - config_conjugate_gradient.msp

global:
  cg_tolerance: <float>
  alpha: <length>
  alpha_min: <length>
  alpha_max: <length>
  alpha_shrink_factor: <float>
  alpha_grow_factor: <float>
  c1: <float>
  cg_restart_period: <int>
  cg_dt: <time>
```

```{ .yaml title="Parameters" .params-block }
cg_tolerance:         float, default 1.0e-4      # Convergence threshold on max atomic force, in eV/Å (compared against an eV-converted copy of force_max, not the raw force/mass value used internally).
alpha:                length, default 0.01 ang   # Current line-search step size — the largest single-atom displacement a trial makes; adapts every trial.
alpha_min:            length, default 1.0e-7 ang # Give up the line search (and the whole CG run) once alpha shrinks below this.
alpha_max:            length, default 1.0 ang    # Cap on step growth after repeated accepted trials.
alpha_shrink_factor:  float, default 0.5         # alpha *= this on a rejected trial.
alpha_grow_factor:    float, default 1.2         # alpha *= this on an accepted trial.
c1:                   float, default 1.0e-4      # Armijo sufficient-decrease constant.
cg_restart_period:    int, default 20            # Force a steepest-descent restart (beta = 0) every N outer iterations.
cg_dt:                time, default 0.0 ps       # Fed to next_time_step so physical_time never advances; the timestep counter still increments (restart/snapshot/screen triggers keep working).
```

```yaml title="Usage example (exaStamp/data/regression_new/numerical_schemes/conjugate_gradient/scheme_CG.msp)"
includes:
  - config_conjugate_gradient.msp

global:
  cg_tolerance: 1.0e-5
  alpha: 0.02 ang
  alpha_max: 0.2 ang
```

`cg_trajectory_loop` (`exaStamp/data/config/config_conjugate_gradient.msp`) expands to:

```yaml title="Usage example"
cg_trajectory_loop:
  loop: true
  condition: cg_loop_continue
  body:
    - begin_iteration
    - simulation_thermodynamic_state
    - cg_force_stats
    - cg_beta_step:
        rebind: { restart_period: cg_restart_period }
        body: [ cg_beta ]
    - cg_direction
    - cg_snapshot_ref_energy:
        rebind: { value: ref_energy }
        body: [ thermo_potential_energy ]
    - backup_r_lt
    - cg_line_search_loop
    - check_and_update_particles
    - end_iteration
    - next_time_step: { rebind: { dt: cg_dt } }
```

- `cg_force_stats` (`exaStamp/src/numerical_schemes/cg_force_stats.cpp`) reduces the per-particle force into `force_max` (convergence test) and `force_sqnorm` (Fletcher-Reeves numerator/denominator) — a fully generic force reduction despite the `cg_` prefix, also reused by FIRE below.
- `cg_beta_step` batches `cg_beta`, rebinding its `restart_period` input to `cg_restart_period` — computes $\beta$ and tracks the iteration count since the last restart.
- `cg_direction` (`exaStamp/src/numerical_schemes/cg_direction.cpp`) updates $\mathbf{h}$ in place and reduces the two scalars the line search needs: `dir_max` ($\max|\mathbf{h}|$) and `slope`.
- `backup_r_lt` checkpoints the current positions before the line search starts trying steps — paired with `restore_r_lt` inside the search below, which rolls back to this checkpoint on a rejected trial.
- `cg_line_search_loop` is the nested backtracking search, detailed next.
- The outer loop keeps going while three conditions all hold: the force hasn't converged yet, the line search didn't bottom out at `alpha_min`, and `sim_continue`'s own iteration/wall-clock limit hasn't been hit.

`cg_line_search_loop` expands to:

```yaml title="Usage example"
cg_line_search_loop:
  loop: true
  condition: cg_continue_search
  body:
    - cg_trial_step
    - ghost_update_r
    - compute_all_forces_energy
    - simulation_thermodynamic_state
    - cg_snapshot_trial_energy:
        rebind: { value: trial_energy }
        body: [ thermo_potential_energy ]
    - cg_armijo_bound
    - cg_check_armijo:
        rebind: { value: trial_energy, threshold: bound, result: reject_step }
        body: [ greater_than ]
    - cg_restore_if_rejected:
        condition: reject_step
        body: [ restore_r_lt ]
    - cg_check_alpha_floor:
        rebind: { value: alpha, threshold: alpha_min, result: line_search_ok }
        body: [ greater_than ]
    - cg_shrink_if_rejected:
        condition: reject_step
        body:
          - cg_alpha_shrink:
              rebind: { value: alpha, factor: alpha_shrink_factor }
              body: [ cg_value_scale ]
    - cg_grow_if_accepted:
        condition: not reject_step
        body:
          - cg_alpha_grow:
              rebind: { value: alpha, factor: alpha_grow_factor, max: alpha_max }
              body: [ cg_value_scale ]
```

- `cg_trial_step` (`exaStamp/src/numerical_schemes/cg_trial_step.cpp`) moves every particle by $H^{-1}\mathbf{h}\,(\alpha/d_{max})$, where $d_{max}$ is `cg_direction`'s `dir_max` output — a cheap trial, followed only by a ghost-position update and a force/energy recompute (a full neighbor-list rebuild only happens once per outer iteration, after a trial is finally accepted).
- `cg_armijo_bound` (`exaStamp/src/numerical_schemes/cg_armijo_bound.cpp`) computes $E_{bound}$; the trial is rejected (`reject_step = true`) whenever its energy exceeds it.
- On rejection, `restore_r_lt` undoes the trial and `cg_alpha_shrink` (an instance of `cg_value_scale`, the small generic clamped-rescale operator shared by both shrink/grow directions) shrinks `alpha`; on acceptance, positions are kept as-is and `cg_alpha_grow` grows `alpha` back up, capped at `alpha_max`. The search itself stops once a trial is accepted or `alpha` bottoms out below `alpha_min`.
- The source currently also prints per-trial `alpha`/`reject` debug output inside this loop, flagged in its own comment as temporary and likely to be removed.

## **FIRE 2.0**

FIRE performs genuine MD-with-inertia: unlike CG, `vx`/`vy`/`vz` hold a real velocity, integrated with ordinary velocity-Verlet, biased at each step towards the force direction. `fire_dt` is itself adaptive and is what actually advances `physical_time`. The algorithm implemented here is specifically **FIRE 2.0**: Bitzek et al.[^3] introduced the original method, and Guénolé et al.[^4] later revised its adaptation rules (the startup grace period, and shrinking `alpha` on a downhill step rather than only resetting it on an uphill one) into the FIRE 2.0 variant this scheme actually follows.

!!! tip "FIRE 2.0 equations (Bitzek et al. 2006[^3] / Guénolé et al. 2020[^4])"

    Power — the steering signal driving the whole adaptation:

    $$
    P = \mathbf{F}\cdot\mathbf{v}
    $$

    If $P>0$ (still going downhill): after more than `fire_delaystep` consecutive downhill steps, grow the timestep by $g_{dt}$ (`fire_dt_grow`), capped at $dt_{max}$ (`fire_dt_start` $\times$ `fire_dt_max_factor`), and shrink the mixing coefficient by $s_{\alpha}$ (`fire_alpha_shrink`):

    $$
    dt \leftarrow \min(dt \times g_{dt},\, dt_{max}), \qquad \alpha \leftarrow \alpha \times s_{\alpha}
    $$

    If $P\le0$ (uphill/stationary): undo the last half-drift, zero the velocity, and — unless still inside the startup grace period — shrink the timestep by $s_{dt}$ (`fire_dt_shrink`), floored at $dt_{min}$ (`fire_dt_start` $\times$ `fire_dt_min_factor`), and reset the mixing coefficient to $\alpha_{start}$ (`fire_alpha_start`):

    $$
    dt \leftarrow dt \times s_{dt}, \qquad \alpha \leftarrow \alpha_{start}
    $$

    Velocity mixing (Euler discretization of the bias term in the FIRE equation of motion), applied every step regardless of uphill/downhill:

    $$
    \mathbf{v} \leftarrow (1-\alpha)\,\mathbf{v} + \alpha\,\mathbf{F}\,\frac{|\mathbf{v}|}{|\mathbf{F}|}
    $$

```{ .yaml title="Syntax" .syntax-block }
includes:
  - config_fire.msp

global:
  fire_tolerance: <float>
  fire_dt_start: <time>
  fire_dt: <time>
  fire_dt_max_factor: <float>
  fire_dt_min_factor: <float>
  fire_delaystep: <int>
  fire_dt_grow: <float>
  fire_dt_shrink: <float>
  fire_alpha_start: <float>
  fire_alpha: <float>
  fire_alpha_shrink: <float>
  fire_pneg_max: <int>
  fire_initial_delay: <bool>
```

```{ .yaml title="Parameters" .params-block }
fire_tolerance:      float, default 1.0e-4     # Convergence threshold on max atomic force, in eV/Å (same eV-conversion caveat as cg_tolerance).
fire_dt_start:       time, default 1.0e-3 ps   # Reference timestep dt_max/dt_min are scaled from — same value an MD run at low temperature would use.
fire_dt:             time, default 1.0e-3 ps   # Current adaptive timestep; seeded to fire_dt_start.
fire_dt_max_factor:  float, default 10.0       # tmax: dt_max = fire_dt_start * this.
fire_dt_min_factor:  float, default 0.02       # tmin: dt_min = fire_dt_start * this.
fire_delaystep:      int, default 20           # N_delay: consecutive downhill steps needed before dt grows again; also gates the startup grace period before the first shrink.
fire_dt_grow:        float, default 1.1        # dt *= this after delaystep consecutive downhill steps.
fire_dt_shrink:      float, default 0.5        # dt *= this on an uphill/stationary step.
fire_alpha_start:    float, default 0.25       # alpha0: mixing coefficient right after a reset.
fire_alpha:          float, default 0.25       # Current adaptive mixing coefficient; seeded to fire_alpha_start.
fire_alpha_shrink:   float, default 0.99       # alpha *= this after delaystep consecutive downhill steps.
fire_pneg_max:       int, default 2000         # vdfmax: give up after this many consecutive uphill steps.
fire_initial_delay:  bool, default true        # Skip the very first dt-shrinks during the startup grace period.
```

Defaults mirror FIRE 2.0's published/LAMMPS defaults (Guénolé et al. 2020, Table 1).

```yaml title="Usage example (exaStamp/data/regression_new/numerical_schemes/fire/scheme_FIRE.msp)"
includes:
  - config_fire.msp

global:
  fire_tolerance: 1.0e-5
  fire_dt_start: 1.0e-3 ps
  fire_dt: 1.0e-3 ps
```

`fire_trajectory_loop` (`exaStamp/data/config/config_fire.msp`) expands to:

```yaml title="Usage example"
fire_trajectory_loop:
  loop: true
  condition: fire_loop_continue
  body:
    - begin_iteration
    - simulation_thermodynamic_state
    - fire_power
    - fire_adapt_step:
        rebind:
          dt_start: fire_dt_start
          dt_max_factor: fire_dt_max_factor
          dt_min_factor: fire_dt_min_factor
          delaystep: fire_delaystep
          dt_grow: fire_dt_grow
          dt_shrink: fire_dt_shrink
          alpha_start: fire_alpha_start
          alpha_shrink: fire_alpha_shrink
          pneg_max: fire_pneg_max
          initial_delay: fire_initial_delay
          dt: fire_dt
          alpha: fire_alpha
        body: [ fire_adapt ]
    - fire_uphill_correct:
        condition: fire_uphill
        body:
          - fire_halfstep_back:
              rebind: { dt: fire_dt }
              body: [ push_v_r: { dt_scale: -0.5, xform_mode: INV_XFORM } ]
          - fire_zero_velocity
    - fire_kick1:
        rebind: { dt: fire_dt }
        body: [ push_f_v: { dt_scale: 0.5 } ]
    - fire_norms
    - fire_velocity_mix_step:
        rebind: { alpha: fire_alpha }
        body: [ fire_velocity_mix ]
    - fire_drift:
        rebind: { dt: fire_dt }
        body: [ push_v_r: { dt_scale: 1.0, xform_mode: INV_XFORM } ]
    - check_and_update_particles
    - compute_all_forces_energy
    - fire_kick2:
        rebind: { dt: fire_dt }
        body: [ push_f_v: { dt_scale: 0.5 } ]
    - cg_force_stats
    - end_iteration
    - next_time_step: { rebind: { dt: fire_dt } }
```

- `fire_power` (`exaStamp/src/numerical_schemes/fire_power.cpp`) reduces $P=\mathbf{F}\cdot\mathbf{v}$ over all atoms, feeding `fire_adapt`'s uphill/downhill test.
- `fire_adapt` (`exaStamp/src/numerical_schemes/fire_adapt.cpp`) is the whole dt/alpha state machine above; besides `dt`/`alpha` it also tracks the consecutive downhill/uphill counters and reports `fire_uphill` and `fire_not_stalled` (goes false once `fire_pneg_max` consecutive uphill steps have piled up without a single downhill step, feeding into the outer loop's own stopping condition).
- On an uphill step, `fire_halfstep_back` (`push_v_r` with a **negative** `dt_scale`) undoes the half-drift the *previous* iteration already applied, then `fire_zero_velocity` clears $\mathbf{v}$ — order matters, the correction needs the still-nonzero velocity before it's cleared.
- `fire_kick1`/`fire_drift`/`fire_kick2` are the ordinary velocity-Verlet half-kick/drift/half-kick, reusing the same [generic push operators](push_operators.md#push_f_v) as `verlet_nve`, just rebound to the adaptive `fire_dt` instead of the simulation's fixed `dt`.
- `fire_norms` (`exaStamp/src/numerical_schemes/fire_norms.cpp`) reduces $|\mathbf{F}|^2$/$|\mathbf{v}|^2$ right after the first half-kick (so $\mathbf{F}$ is still the pre-step force, $\mathbf{v}$ is already at $t+\Delta t/2$), feeding `fire_velocity_mix`'s $|\mathbf{v}|/|\mathbf{F}|$ ratio.
- `cg_force_stats` is reused as-is for the end-of-step `force_max` convergence test/progress display — the same fully generic reduction CG uses above.

`fire_first_iteration` sets $\mathbf{v}(0)=0$ via `fire_zero_velocity` before the first progress print — the only difference from CG's first-iteration setup besides the scheme swap itself.

[^1]: [Fletcher, Reeves, The Computer Journal, 7, 149-154 (1964)](https://academic.oup.com/comjnl/article-abstract/7/2/149/335311?redirectedFrom=fulltext)

[^2]: [Nocedal, Wright, Numerical Optimization, Springer Series in Operations Research (1999)](https://link.springer.com/book/10.1007/978-0-387-40065-5)
      
[^3]: [Bitzek, Koskinen, Gahler, Moseler, Gumbsch, Phys Rev Lett, 97, 17021 (2006)](https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.97.170201)

[^4]: [Guénolé, Nöhring, Vaid, Houllé, Xie, Prakash, Bitzek, Comput Mater Sci, 175, 109584 (2020)](https://www.sciencedirect.com/science/article/pii/S0927025620300756?via%3Dihub)    
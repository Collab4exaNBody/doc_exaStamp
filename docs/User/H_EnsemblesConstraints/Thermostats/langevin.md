---
icon: material/dice-multiple
---

# **Langevin Thermostat**

Models an implicit solvent bath: the total force on each particle gains a viscous damping term and a random term, on top of the usual interatomic force.

$$
F = F_c + F_f + F_r, \qquad
F_f = -\frac{m}{\gamma} v, \qquad
F_r \propto \sqrt{\frac{m \, k_B \, T}{dt \cdot \gamma}}
$$

$F_c$ is the classical interatomic force; $F_f$ is a damping force proportional to velocity (damping parameter $\gamma$, user-defined); $F_r$ is a random force whose magnitude follows from the fluctuation-dissipation theorem, at target temperature $T$.

```{ .yaml title="Syntax" .syntax-block }
langevin_thermostat:
  T: <float>
  Tstart: <float>
  Tstop: <float>
  tserie: [<float>, ...]
  Tserie: [<float>, ...]
  gamma: <float>
  seed: <int>
  region: <string>
  deterministic_noise: <bool>
```

```{ .yaml title="Parameters" .params-block }
T:                    float, optional          # Constant target temperature — mutually exclusive with Tstart/Tstop and tserie/Tserie.
Tstart:               float, optional          # Starting target temperature (linear ramp with Tstop).
Tstop:                float, optional          # Final target temperature (linear ramp with Tstart).
tserie:               list of floats, optional  # Physical times for a piecewise-interpolated target temperature.
Tserie:               list of floats, optional  # Target temperatures at each tserie time — same length as tserie.
gamma:                float, default 0.1        # Damping constant, in ps^-1.
seed:                 int, optional              # RNG seed.
region:               string, optional           # Restrict the thermostat to a geometric region.
deterministic_noise:  bool, default false        # Force a single-threaded, deterministic RNG path.
```

A bare scalar is accepted as shorthand for `T`: `langevin_thermostat: 500 K`. Exactly one of the three target-temperature forms (`T` / `Tstart`+`Tstop` / `tserie`+`Tserie`) may be given.

```yaml title="Usage example"
numerical_scheme: verlet_lnvt

# constant target temperature
langevin_thermostat: { T: 300. K, gamma: 0.1 ps^-1 }

# linear ramp
langevin_thermostat: { Tstart: 5. K, Tstop: 1000. K, gamma: 0.1 ps^-1 }

# piecewise-interpolated
langevin_thermostat:
  tserie: [0, 10., 20.]
  Tserie: [5., 500., 500.]
  gamma: 0.1 ps^-1
```

Like Berendsen, `langevin_thermostat` performs no time integration itself — but unlike Berendsen, which rescales velocities *after* the position/velocity push, Langevin applies a force term directly, so it slots into the force-computation stage of the scheme instead.

!!! warning

    `verlet_lnvt` inserts `langevin_thermostat` between `compute_force` and `compute_force_epilog` — the force-computation phase, not the position/velocity push phase — so describing it as "added to `compute_force`" is directionally right but not literal: it's a distinct step in the scheme body, not nested inside the `compute_force` block itself. `exaStamp` already ships this wiring as the `verlet_lnvt` scheme below, so in practice you don't need to build the body yourself — just point `numerical_scheme` at it.

## **The `verlet_lnvt` scheme**

`verlet_lnvt` (`exaStamp/data/config/config_numerical_schemes.msp`) expands to:

```yaml title="Usage example"
verlet_lnvt:
  name: LNVT_scheme
  body:
    - verlet_first_half
    - check_and_update_particles
    - load_balance_auto_tune_start
    - compute_force_prolog
    - compute_force
    - langevin_thermostat
    - compute_force_epilog
    - verlet_second_half
    - load_balance_auto_tune_end
```

Identical to [`verlet_nve`](../nve_ensemble.md#the-verlet_nve-scheme) except for the single `langevin_thermostat` step inserted between `compute_force` and `compute_force_epilog` — consistent with it applying a force term rather than integrating anything itself.

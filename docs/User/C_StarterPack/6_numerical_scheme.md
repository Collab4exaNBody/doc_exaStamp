---
icon: lucide/waypoints
---

# Numerical Scheme

The time-integration scheme is chosen through the `numerical_scheme` block. Unlike `compute_force`/`species`/`domain`/`setup_system`, it isn't strictly mandatory: it already defaults to `verlet_nve` (see [Numerical schemes](../B_GettingStarted/configuration_files.md#numerical-schemes)), so a minimal input deck works without touching it at all. Redefine it when you need temperature control.

## NVE (default)

`verlet_nve` is a plain velocity-Verlet integrator: energy-conserving, no thermostat. Selecting it explicitly is only ever needed to override a different scheme set elsewhere:

```yaml linenums="1"
numerical_scheme: verlet_nve
```

## Langevin NVT (`verlet_lnvt`)

`verlet_lnvt` runs the same velocity-Verlet steps, with a `langevin_thermostat` call added into the force computation to couple the system to an implicit heat bath at a target temperature:

```yaml linenums="1"
numerical_scheme: verlet_lnvt

langevin_thermostat:
  T: 300 K
  gamma: 0.1 ps^-1
```

`T` is the (constant) target temperature and `gamma` the damping/coupling rate (has a default value, but is always given explicitly with a `ps^-1` unit in practice). Instead of a constant `T`, the target temperature can also ramp linearly over the run with `Tstart`/`Tstop`, or follow an arbitrary interpolated profile with `tserie`/`Tserie` (a list of times and a matching list of temperatures) — exactly one of the three forms (`T`, `Tstart`+`Tstop`, or `tserie`+`Tserie`) must be given.

!!! note

    `langevin_thermostat` only adds a force term — it performs no time integration itself, which is why it must be selected through `verlet_lnvt` (which inserts it into the force computation) rather than used on its own.

Combined with the [`init_temperature_new`](4_setup_system.md#generating-a-crystal-lattice) example from the previous page — which starts the system at 600 K — setting `verlet_lnvt` with a 300 K target lets the system relax/cool from its initial 600 K towards 300 K over the run.

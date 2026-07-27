---
icon: lucide/waypoints
---

# **NVE ensemble**

Time integration in `exaStamp` is performed using the velocity form of the Störmer-Verlet algorithm, better known as **velocity-Verlet**. It's a good fit for atomistic simulations because it's symplectic (it preserves the system's energy over long trajectories) and second-order accurate in both time and energy, at the cost of only one force evaluation per step:

!!! tip "Velocity-Verlet steps"

    1. Position at the full step:

    $$
    \mathbf{x}(t + \Delta t) = \mathbf{x}(t) + \mathbf{v}(t) \Delta t + \mathbf{a}(t) \frac{\Delta t^2}{2}
    $$

    2. Velocity at the half step:

    $$
    \mathbf{v}\left(t + \frac{\Delta t}{2}\right) = \mathbf{v}(t) + \mathbf{a}(t) \frac{\Delta t}{2}
    $$

    3. Recompute the acceleration $\mathbf{a}(t + \Delta t)$ from the interatomic potential, using the position from step 1.

    4. Velocity at the full step:

    $$
    \mathbf{v}(t + \Delta t) = \mathbf{v}\left(t + \frac{\Delta t}{2}\right) + \mathbf{a}(t + \Delta t) \frac{\Delta t}{2}
    $$

## **The `verlet_nve` scheme**

`verlet_nve` is `exaStamp`'s default value for [`numerical_scheme`](numerical_scheme.md) — plain velocity-Verlet, no thermostat or barostat attached:

```yaml title="Usage example"
numerical_scheme: verlet_nve
```

`verlet_nve` (`exaStamp/data/config/config_numerical_schemes.msp`) expands to:

```yaml title="Usage example"
verlet_nve:
  name: NVE_scheme
  body:
    - verlet_first_half
    - check_and_update_particles
    - load_balance_auto_tune_start
    - compute_all_forces_energy
    - verlet_second_half
    - load_balance_auto_tune_end

verlet_first_half:
  - push_f_v_r: { dt_scale: 1.0, xform_mode: INV_XFORM }
  - push_f_v: { dt_scale: 0.5, xform_mode: IDENTITY }

verlet_second_half:
  - push_f_v: { dt_scale: 0.5, xform_mode: IDENTITY }
```

`verlet_first_half`/`verlet_second_half` are themselves named `body:` lists — the same batch-label mechanism as `verlet_nve` itself, just one level down, wrapping the [generic push operators](push_operators.md); `check_and_update_particles` and `compute_all_forces_energy` are conventional batch labels (not standalone operators) that decide whether ghost cells/domain decomposition need rebuilding, and run the potential-specific force computation, respectively. Every other ensemble/thermostat/barostat on this site works by pointing `numerical_scheme` at a *different* named scheme instead of `verlet_nve` — see the [full list of schemes](numerical_scheme.md).

This is steps 1–2 and step 4 of the velocity-Verlet steps above, expressed directly in terms of the [generic push operators](push_operators.md):

- `verlet_first_half` calls [`push_f_v_r`](push_operators.md#push_f_v_r) at `dt_scale: 1.0` — step 1, the full position update from $\mathbf{v}(t)$ and $\mathbf{a}(t)$ — immediately followed by [`push_f_v`](push_operators.md#push_f_v) at `dt_scale: 0.5` — step 2, the half-step velocity kick.
- `compute_all_forces_energy` (step 3) then recomputes $\mathbf{a}(t + \Delta t)$ at the new position.
- `verlet_second_half` calls `push_f_v` again, at `dt_scale: 0.5` — step 4, completing the velocity kick with the freshly recomputed acceleration.

---
icon: material/arrow-decision
---

# **Generic push operators**

`exaNBody` provides the low-level building blocks every [`numerical_scheme`](numerical_scheme.md) on this site is built from — `exaNBody/src/defbox/`. All four share the same slot shape and the same general transform behavior; only which pair of fields they read/write, and their order, differs.

| Operator | Updates | From | Order |
|---|---|---|---|
| `push_v_r` | position | velocity | 1st |
| `push_f_v` | velocity | force/acceleration | 1st |
| `push_f_r` | position | force/acceleration | 1st |
| `push_f_v_r` | position **and** velocity | velocity and force/acceleration | 2nd |

Since `exaStamp` positions are stored in a reduced (grid-space) frame, any push that touches position needs `xform_mode: INV_XFORM` to convert the physical-space velocity/force into that frame — this is why `verlet_second_half`-style position pushes always carry it. Whenever `xform_mode` isn't `IDENTITY`, every update below is left-multiplied by the domain transform matrix $H$ (`domain->xform()` for `XFORM`, its inverse for `INV_XFORM`) before being added.

!!! note

    Older documentation mentioned only two `xform_mode` values (`IDENTITY`/`INV_XFORM`); a third, `XFORM`, also exists.

`verlet_first_half`/`verlet_second_half`, used by [`verlet_nve`](nve_ensemble.md#the-verlet_nve-scheme) and every scheme built on top of it, are themselves just named wrappers around these pushes — see the [`verlet_nve` scheme](nve_ensemble.md#the-verlet_nve-scheme) for how they're composed.

By the time any of these run in the force-computation part of a scheme, the `fx`/`fy`/`fz` fields already hold **acceleration**, not raw force: `compute_force_epilog` (`force_to_accel`, `exaStamp/src/compute/force_to_accel.cu`) divides the accumulated force by each particle's mass in place, before any push reads it.

## **`push_v_r`**

```{ .yaml title="Syntax" .syntax-block }
push_v_r:
  dt_scale: <float>
  xform_mode: <IDENTITY_or_XFORM_or_INV_XFORM>
```

```{ .yaml title="Parameters" .params-block }
dt:           float, required (context)     # Simulation timestep, wired from the pipeline's dt slot — not set inside push_v_r itself.
dt_scale:     float, default 1.0            # Fraction of dt actually applied this call (e.g. 0.5 for a half-kick).
xform_mode:   enum, default IDENTITY        # IDENTITY, XFORM, or INV_XFORM.
```

Updates position from velocity:

$$
\mathbf{x}(t + \Delta t) = \mathbf{x}(t) + \mathbf{v}(t)\,\Delta t, \qquad \Delta t = dt \times dt\_scale
$$

(or $\mathbf{x} \mathrel{+}= H\,\mathbf{v}(t)\,\Delta t$ when `xform_mode` isn't `IDENTITY`).

## **`push_f_v`**

```{ .yaml title="Syntax" .syntax-block }
push_f_v:
  dt_scale: <float>
  xform_mode: <IDENTITY_or_XFORM_or_INV_XFORM>
```

```{ .yaml title="Parameters" .params-block }
dt:           float, required (context)     # Simulation timestep, wired from the pipeline's dt slot.
dt_scale:     float, default 1.0            # Fraction of dt actually applied this call.
xform_mode:   enum, default IDENTITY        # IDENTITY, XFORM, or INV_XFORM.
```

Updates velocity from acceleration:

$$
\mathbf{v}(t + \Delta t) = \mathbf{v}(t) + \mathbf{a}(t)\,\Delta t, \qquad \Delta t = dt \times dt\_scale
$$

This is the operator behind every `verlet_first_half`/`verlet_second_half` half-kick.

## **`push_f_r`**

```{ .yaml title="Syntax" .syntax-block }
push_f_r:
  dt_scale: <float>
  xform_mode: <IDENTITY_or_XFORM_or_INV_XFORM>
```

```{ .yaml title="Parameters" .params-block }
dt:           float, required (context)     # Simulation timestep, wired from the pipeline's dt slot.
dt_scale:     float, default 1.0            # Fraction of dt actually applied this call.
xform_mode:   enum, default IDENTITY        # IDENTITY, XFORM, or INV_XFORM.
```

Updates position directly from acceleration (skipping velocity):

$$
\mathbf{x}(t + \Delta t) = \mathbf{x}(t) + \mathbf{a}(t)\,\Delta t, \qquad \Delta t = dt \times dt\_scale
$$

None of the schemes documented on this site use `push_f_r` — it exists as the third combination alongside `push_v_r`/`push_f_v`, available for custom schemes.

## **`push_f_v_r`**

```{ .yaml title="Syntax" .syntax-block }
push_f_v_r:
  dt_scale: <float>
  xform_mode: <IDENTITY_or_XFORM_or_INV_XFORM>
```

```{ .yaml title="Parameters" .params-block }
dt:           float, required               # Simulation timestep.
dt_scale:     float, required               # No default here, unlike the three 1st-order pushes above — must be set explicitly.
xform_mode:   enum, default INV_XFORM       # Note the different default from the 1st-order pushes: INV_XFORM, not IDENTITY.
```

Updates position from velocity **and** acceleration together, second-order accurate:

$$
\mathbf{x}(t + \Delta t) = \mathbf{x}(t) + \mathbf{v}(t)\,\Delta t + \mathbf{a}(t)\,\frac{\Delta t^2}{2}, \qquad \Delta t = dt \times dt\_scale
$$

This is exactly step 1 of the [velocity-Verlet integration](nve_ensemble.md) — `verlet_first_half` calls `push_f_v_r` (full step) immediately followed by `push_f_v` (half step) to cover steps 1 and 2 in one go. The Nosé-Hoover schemes (`verlet_nhnvt`/`verlet_nhnpt`) don't use it: they need to interleave thermostat/barostat operators between the velocity and position updates, so they call `push_f_v` and `push_v_r` separately instead of this combined operator.

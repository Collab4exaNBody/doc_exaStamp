---
icon: material/gauge
---

# **NPT ensemble**

## **Nosé-Hoover barostat**

An extension of the [Nosé-Hoover thermostat](nvt_ensemble.md): setting `algo: NPT` on `init_nose_hoover` adds a barostat degree of freedom alongside the thermostat one, targeting a stress tensor instead of just a temperature. The thermostat equations are unchanged from [NVT](nvt_ensemble.md); the barostat runs a parallel Nosé-Hoover chain per coupled axis $i \in \{x,y,z\}$ (`exaStamp/src/npt/`).

!!! tip "Nosé-Hoover barostat equations"

    Each active axis (per `Pcouple`) gets a coupling frequency from its damping time and a target pressure linearly ramped between `Pxxstart`/`Pxxend` (same scheme as `Tstart`/`Tend`), averaged into a target hydrostatic pressure:

    $$
    p_{freq,i} = \frac{1}{P_{i,damp}}, \qquad P_i^*(t) = P_{i,start} + \frac{t-t_{start}}{t_{end}-t_{start}}\left(P_{i,stop}-P_{i,start}\right), \qquad P_{hydro} = \frac{1}{N_{dim}}\sum_i P_i^*
    $$

    The barostat's own mass (`nhc_press_integrate`), analogous to the thermostat's $\eta_M$:

    $$
    W_i = \frac{(N_{atoms}+1)\,k_B T^*}{p_{freq,i}^2}
    $$

    The current pressure per axis (`couple_npt`), reduced from the full stress tensor $\sigma$ according to `Pcouple`:

    $$
    P_i^{cur} = \sigma_{ii} \quad (\texttt{Pcouple: NONE}), \qquad\qquad P_i^{cur} = \tfrac{1}{3}\,\mathrm{tr}(\sigma) \quad (\texttt{Pcouple: XYZ})
    $$

    The barostat's "velocity" $\dot\omega_i$ (`nh_omega_dot`), and the resulting scaling applied to every particle's velocity (`nh_v_press`):

    $$
    \dot\omega_i \mathrel{+}= \frac{\left(P_i^{cur} - P_{hydro}\right) V}{W_i}\,\frac{\Delta t}{2}, \qquad\qquad \mathbf{v}_i \mathrel{*}= \exp\!\left(-\dot\omega_i\,\frac{\Delta t}{2}\right)
    $$

    This covers the default orthogonal case (`Pcouple: NONE`/`XYZ`, no triclinic shear, no Martyna-Tobias-Klein volume correction) — `Pxy*`/`Pxz*`/`Pyz*`, `Pmode`, `Pdrag` and `mtkcorr` add correction terms on top of this core recurrence.

```{ .yaml title="Syntax" .syntax-block }
init_nose_hoover:
  algo: NPT
  Tstart: <float>
  Tend: <float>
  Tdamp: <float>
  tchain: <int>
  Pxxstart: <float>
  Pxxend: <float>
  Pxxdamp: <float>
  Pyystart: <float>
  Pyyend: <float>
  Pyydamp: <float>
  Pzzstart: <float>
  Pzzend: <float>
  Pzzdamp: <float>
  Pxystart: <float>
  Pxyend: <float>
  Pxydamp: <float>
  Pxzstart: <float>
  Pxzend: <float>
  Pxzdamp: <float>
  Pyzstart: <float>
  Pyzend: <float>
  Pyzdamp: <float>
  pchain: <int>
  Pcouple: <XYZ_or_NONE>
```

```{ .yaml title="Parameters" .params-block }
algo:      string, default "NVT"   # Set to "NPT" to enable the barostat.
Tstart:    float, required         # Target temperature at the start of the run.
Tend:      float, optional         # Target temperature at the end (linear ramp); defaults to Tstart.
Tdamp:     float, default 0.1      # Thermostat coupling time.
tchain:    int, default 3          # Nosé-Hoover thermostat chain length.
Pxxstart:  float, optional         # Target xx normal stress at the start of the run.
Pxxend:    float, optional         # Target xx normal stress at the end (linear ramp).
Pxxdamp:   float, optional         # xx barostat coupling time.
Pyystart:  float, optional         # Target yy normal stress at the start of the run.
Pyyend:    float, optional         # Target yy normal stress at the end (linear ramp).
Pyydamp:   float, optional         # yy barostat coupling time.
Pzzstart:  float, optional         # Target zz normal stress at the start of the run.
Pzzend:    float, optional         # Target zz normal stress at the end (linear ramp).
Pzzdamp:   float, optional         # zz barostat coupling time.
Pxystart:  float, optional         # Target xy shear stress at the start of the run (triclinic boxes).
Pxyend:    float, optional         # Target xy shear stress at the end (linear ramp).
Pxydamp:   float, optional         # xy barostat coupling time.
Pxzstart:  float, optional         # Target xz shear stress at the start of the run (triclinic boxes).
Pxzend:    float, optional         # Target xz shear stress at the end (linear ramp).
Pxzdamp:   float, optional         # xz barostat coupling time.
Pyzstart:  float, optional         # Target yz shear stress at the start of the run (triclinic boxes).
Pyzend:    float, optional         # Target yz shear stress at the end (linear ramp).
Pyzdamp:   float, optional         # yz barostat coupling time.
pchain:    int, default 3          # Nosé-Hoover barostat chain length.
Pcouple:   string, default "NONE"  # "XYZ" for isotropic coupling of all three normal stresses, "NONE" for fully independent x/y/z.
```

Omit whichever axes you don't need to constrain. `Pmode`, `Scalexy`/`Scalexz`/`Scaleyz`, `Pdrag` and `mtkcorr` are further, more specialized tuning knobs on the same operator.

```yaml title="Usage example"
includes:
  - config_nose_hoover.msp

numerical_scheme: verlet_nhnpt

init_nose_hoover:
  algo: NPT
  Tstart: 150. K
  Tend: 150. K
  Tdamp: 0.05 ps
  tchain: 3
  Pxxstart: 1.0e9
  Pxxend: 1.0e9
  Pxxdamp: 0.5 ps
  Pyystart: 1.0e9
  Pyyend: 1.0e9
  Pyydamp: 0.5 ps
  Pzzstart: 1.0e9
  Pzzend: 1.0e9
  Pzzdamp: 0.5 ps
  pchain: 3
  Pcouple: XYZ
```

!!! warning

    `config_nose_hoover.msp` must be included — it's what wires the per-step Nosé-Hoover operators into `+init_epilog`/`numerical_scheme`. Without it, `init_nose_hoover`'s output context isn't consumed by anything. Same file as [NVT](nvt_ensemble.md) — it covers both the thermostat and barostat wiring. Its full content (`exaStamp/data/config/config_nose_hoover.msp`):

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

### **The `verlet_nhnpt` scheme**

`verlet_nhnpt` (`exaStamp/data/config/config_numerical_schemes.msp`) expands to:

```yaml title="Usage example"
verlet_nhnpt:
  name: NHNPT_scheme
  body:
    - simulation_thermodynamic_state
    - nhc_press_integrate
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
    - simulation_thermodynamic_state
    - couple_npt
    - nh_omega_dot
    - nh_v_press
    - push_f_v: { dt_scale: 0.5, xform_mode: IDENTITY }
    - remap_npt
    - push_v_r: { dt_scale: 1.0, xform_mode: INV_XFORM }
    - remap_npt
    - check_and_update_particles
    - load_balance_auto_tune_start
    - compute_all_forces_energy
    - push_f_v: { dt_scale: 0.5, xform_mode: IDENTITY }
    - simulation_thermodynamic_state
    - nh_v_press
    - simulation_thermodynamic_state
    - couple_npt
    - nh_omega_dot
    - nhc_temp_integrate
    - nh_v_temp:
        rebind: { value: vscale }
        body: [ scale_v ]
    - nhc_press_integrate
    - load_balance_auto_tune_end
```

It's the same thermostat interleaving as [`verlet_nhnvt`](nvt_ensemble.md#the-verlet_nhnvt-scheme) (`nhc_temp_integrate`/`nh_v_temp`/`compute_vel_bias`/`remove_vel_bias`), plus a symmetric barostat chain wrapped around the position push (`exaStamp/src/npt/`):

- `nhc_press_integrate` runs the Nosé-Hoover chain integration for the barostat's own degree(s) of freedom — the pressure-side counterpart to `nhc_temp_integrate`.
- `couple_npt` reads the current stress tensor off `thermodynamic_state` and reduces it to per-axis current pressures according to `Pcouple`/barostat style (isotropic `XYZ`, per-axis `NONE`, …), storing the result in the NPT context for the other operators to target.
- `nh_omega_dot` updates the box's own "velocity" degrees of freedom (`omega_dot`) from the mismatch between current and target pressure — the barostat analogue of `nhc_temp_integrate`'s $\ddot\eta$.
- `nh_v_press` applies the barostat's contribution to particle velocities (an MTK-style extra scaling/force term, in addition to the thermostat's `vscale`).
- `remap_npt` rescales the simulation box and remaps particle positions to the updated cell — it runs once before the position push and once after, since the box transform itself changes over the course of the step.

Everything else (`push_f_v`/`push_v_r`, `check_and_update_particles`, `compute_all_forces_energy`, `load_balance_auto_tune_*`) is identical to the other Verlet-based schemes above.

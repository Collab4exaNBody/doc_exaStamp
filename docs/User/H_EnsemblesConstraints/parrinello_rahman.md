---
icon: material/cube-scan
---

# **Parrinello-Rahman Barostat**

!!! warning "Unmaintained"
    The Parrinello-Rahman scheme is kept for backward compatibility but is no longer maintained. For new NPT simulations, use the Nosé-Hoover barostat described in [NPT ensemble](npt_ensemble.md).

The Parrinello-Rahman scheme integrates the particle positions together with the cell matrix $\mathbf{h}$, which evolves under the difference between the instantaneous stress and the target external pressure, with a fictitious cell mass. The temperature is controlled by an additional thermostat variable with its own fictitious mass. Individual components of $\mathbf{h}$ can be frozen or tied together to impose isotropic, anisotropic or partially constrained deformations.

The scheme is enabled by including `config_parrinellorahman.msp`, which replaces the default `numerical_scheme`:

```yaml linenums="1"
--8<-- "docs/files/config_parrinellorahman.msp"
```

The energies and the virial are computed at every step in this scheme (`force_thermo_state`), whatever the output frequencies.

## **`init_parrinellorahman`**

Sets the targets and the fictitious masses. It must run once before the time loop, typically in `init_prolog`.

```{ .yaml title="Syntax" .syntax-block }
init_parrinellorahman:
  Text: <float>
  masseNVT: <float>
  Pext: <float>
  masseNPT: <float>
  hmask: <3x3 matrix>
  hblend: <3x3 matrix>
```

```{ .yaml title="Parameters" .params-block }
Text:      float, required                  # Target temperature.
masseNVT:  float, required                  # Fictitious mass of the thermostat variable.
Pext:      float, required                  # Target external pressure.
masseNPT:  float, required                  # Fictitious mass of the cell.
hmask:     3x3 matrix, default all ones     # Component-wise factors on the cell velocity and acceleration; a 0 freezes the corresponding component of h.
hblend:    3x3 matrix, default identity     # Blends the diagonal components of the cell velocity (e.g. rows of 1/3 for an isotropic deformation of x, y and z).
```

The other operators of the scheme are:

- `first_push_parrinellorahman` (`dt_scale`): first half of the position, velocity and cell update;
- `update_xform_parrinellorahman` (`file`, default `"parrinello_rahman.dat"`; `force_append_thermo`): applies the new cell matrix to the domain and writes the cell evolution to `file`;
- `convergence_push_parrinellorahman` (`dt_scale`, `epsilon` default `1.0e-6`, `max_iter` default `100`): second half of the update, solved iteratively until the change between two iterations is below `epsilon` (at most `max_iter` iterations).

```yaml title="Usage example (exaStamp/data/regression_new/numerical_schemes/npt_parrinello_rahman/copper_iso_xy_blend_xyz.msp)"
includes:
  - config_parrinellorahman.msp

init_prolog:
  - deformation_xform:
      defbox: { extension: [ 1.0 , 1.0 , 1.0 ] }
  - init_parrinellorahman:
      Text: 300 K
      masseNVT: 1.0e-14 Da
      Pext: 1.013e5 kg*m^-1*s^-2
      masseNPT: 1.0e2 Da
      hmask: [ [ 1 , 0 , 0 ] , [ 0 , 1 , 0 ] , [ 0 , 0 , 1 ] ]
      hblend: [ [ 1/3 , 1/3 , 1/3 ] , [ 1/3 , 1/3 , 1/3 ] , [ 0 , 0 , 0 ] ]
```

Other examples (isotropic, anisotropic, in-plane) are available in `exaStamp/data/regression_new/numerical_schemes/npt_parrinello_rahman/`.

---
icon: material/arrow-expand-all
---

# **Deformation Paths**

Three operators prescribe a time-varying deformation of the simulation box, each plugging into the same `xform_function` hook (default `nop`, i.e. no deformation) called every step. All three live in `exaNBody`, not `exaStamp`, and all three write directly to the domain's `xform`.

!!! warning

    `config_deformation.msp` must be included for any simulation using one of these three operators — it's what wires `xform_function` into `md_loop_prolog` so it actually gets called every step, and sets up the initial deformation box via `deformation_xform` in `+init_prolog`. Without it, setting `xform_function` alone has no effect. Its full content (`exaStamp/data/config/config_deformation.msp`):

    ```yaml
    +init_prolog:
      - deformation_xform:
          defbox: { extension: [ 1.0, 1.0, 1.0 ] }

    md_loop_prolog:
      - xform_function
      - nbh_dist

    xform_function: nop
    ```

    ```yaml title="Usage example"
    includes:
      - config_deformation.msp
    ```

## **`xform_constant_strain_rate`**

```{ .yaml title="Syntax" .syntax-block }
xform_constant_strain_rate:
  mode: <uniaxial_or_biaxial_or_triaxial_or_shear>
  strain_rate: <float>
  direction1: <Vec3d>
  direction2: <Vec3d>
  direction3: <Vec3d>
  sign1: <float>
  sign2: <float>
  sign3: <float>
  time_start: <float>
xform_function: xform_constant_strain_rate
```

```{ .yaml title="Parameters" .params-block }
mode:          string, required            # uniaxial, biaxial, triaxial, or shear — anything else is a no-op.
strain_rate:   float, required             # Strain rate applied.
direction1:    Vec3d, default [1,0,0]      # First deformation direction.
direction2:    Vec3d, default [0,1,0]      # Second deformation direction (biaxial/triaxial/shear).
direction3:    Vec3d, default [0,0,1]      # Third deformation direction (triaxial/shear).
diagpredef:    Vec3d, default [1,1,1]      # Pre-existing diagonal scale factor, multiplied in.
sign1:         float, default 1.0          # Sign/magnitude weight on direction1.
sign2:         float, default 1.0          # Sign/magnitude weight on direction2.
sign3:         float, default 1.0          # Sign/magnitude weight on direction3.
time_start:    float, default 0.0          # Deformation only starts once physical time passes this.
```

Applies a constant rate of strain along one, two, or three directions (`mode` selects how many of `direction1`/`direction2`/`direction3` are used) starting at `time_start`.

```yaml title="Usage example"
xform_constant_strain_rate:
  mode: uniaxial
  strain_rate: 1e+11
  direction1: [1.0, 1.0, 1.0]
  sign1: 1.0
xform_function: xform_constant_strain_rate
```

## **`xform_time_interpolate`**

```{ .yaml title="Syntax" .syntax-block }
xform_time_interpolate:
  time_serie: [<float>, ...]
  xform_serie: [<Mat3d>, ...]
xform_function: xform_time_interpolate
```

```{ .yaml title="Parameters" .params-block }
time_serie:   list of floats, required   # Physical times at each control point.
xform_serie:  list of Mat3d, required    # Box transform matrix at each control point — same length as time_serie.
```

Smoothly interpolates the box transform through an arbitrary number of `(time, transform)` control points using a cubic spline — not limited to two endpoints.

```yaml title="Usage example"
xform_time_interpolate:
  time_serie: [0.0, 0.2, 0.3, 0.5, 1.0]
  xform_serie:
    - [[1,0,0],[0,1,0],[0,0,1]]
    - [[1.5,0,0],[0,1,0],[0,0,1]]
    - [[1.8,0,0],[0,1,0],[0,0,1]]
    - [[2.0,0,0],[0,1,0],[0,0,1]]
    - [[2.2,0,0],[0,1,0],[0,0,1]]
xform_function: xform_time_interpolate
```

## **`xform_time_interpolate_byparts`**

```{ .yaml title="Syntax" .syntax-block }
xform_time_interpolate_byparts:
  time_serie: [<float>, ...]
  xform_serie: [<Mat3d>, ...]
xform_function: xform_time_interpolate_byparts
```

```{ .yaml title="Parameters" .params-block }
time_serie:   list of floats, required   # Physical times at each control point.
xform_serie:  list of Mat3d, required    # Box transform matrix at each control point — same length as time_serie.
```

Same idea as [`xform_time_interpolate`](#xform_time_interpolate) above, but piecewise-**linear** between consecutive control points instead of a cubic spline — use this when a smooth curve through the control points isn't what you want (e.g. genuinely piecewise-constant-rate segments).

!!! note

    All three operators plug into the same `xform_function` slot (default `nop`) — exactly the same "swap one named operator for another via a single slot" pattern used by [`numerical_scheme`](numerical_scheme.md) for thermostats/barostats.

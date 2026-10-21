# **IGAR Potential**

## **Description**

IGAR (Image Guided Atomistic Reconstruction) adds to each atom an energy read from a 3D image covering the simulation box. The image is a grid of $N_x \times N_y \times N_z$ voxels with values $v_{abc}$. The energy of atom $i$ and the force on it are

$$
E_i = A\, s\, V(\mathbf{r}_i), \qquad \mathbf{F}_i = -\frac{\partial E_i}{\partial \mathbf{R}_i}
$$

- $A$ is `energy_factor` (an energy) and $s$ is `value_scale` (dimensionless). For an 8-bit image with $s = 1/255$, the energy at the voxel centers goes from 0 (value 0) to $A$ (value 255).
- $V(\mathbf{r})$ interpolates the voxel values at the atom position, using the voxels around it:

$$
V(\mathbf{r}) = \sum_{a,b,c} w_a(u)\, w_b(v)\, w_c(w)\; v_{abc}
$$

  where $u, v, w$ are the offsets of the atom from its voxel center, in voxel units, and $w$ are the weights of the chosen interpolation scheme.
- The force is the exact derivative of this energy, so the total energy is conserved with the `catmull_rom` and `bspline` schemes.

Atoms are pushed down the gradient of the image, towards its low values. IGAR acts on each atom alone: it is always combined with an interatomic potential.

### **Geometry**

The image is attached to the simulation box: its $N_x \times N_y \times N_z$ voxels split the domain bounds evenly, and each value sits at a voxel center. The `SPACING` and `ORIGIN` lines of the file are ignored. The image does not need to match the cell grid: any number of voxels per axis works.

Positions are interpolated in grid coordinates. If the box is deformed (domain `xform`, deformation, NPT), the image deforms with it, and the forces are converted to real space: $\mathbf{F} = -A\, s\, X^{-T} \nabla_{grid} V$, with $X$ the box transform.

Along a periodic axis, the interpolation stencil wraps around the box. Along a non-periodic axis, voxels outside the box count as 0.

### **Operators**

<div class="center-table" markdown>

| Operator | Role |
| :------- | :------- |
| `igar_read_field` | Reads the image from a VTK file. Place it in `setup_system`. |
| `igar_force_interp` | Adds the IGAR energy and forces to every atom. Place it in `compute_force`, with the interatomic potential. |

</div>

```{ .yaml title="Syntax" .syntax-block }
igar_read_field:
  file_name: <string>
  storage: <string>
  value_scale: <float>
  grid_ordering: <string>

igar_force_interp:
  energy_factor: <float>
  interpolation: <string>
```

```{ .yaml title="Parameters" .params-block }
igar_read_field.file_name:         string, required            # legacy VTK file (STRUCTURED_POINTS), ASCII or BINARY.
igar_read_field.storage:           string, default=uint8       # uint8 (1 byte per voxel, 8-bit images) or double.
igar_read_field.value_scale:       float, default=1.0          # field = file value * value_scale (e.g. 1/255 for levels 0-255 -> [0,1]).
igar_read_field.grid_ordering:     string, default=F_ORDER     # F_ORDER (x varies fastest in the file) or C_ORDER (z fastest).
igar_force_interp.energy_factor:   float, required             # energy scale A (e.g. 2.0 eV). Internal units if no unit is given.
igar_force_interp.interpolation:   string, default=catmull_rom # catmull_rom, bspline or lagrange (see below).
```

### **Storage**

With `storage: uint8`, every value of the file must be an integer from 0 to 255; otherwise the run stops (values are never rounded). Since the image values are the same, energies and forces are identical to `storage: double`, for 8 times less memory. Use `storage: double` for a field with real values (a computed or filtered field).

Process 0 reads the file and sends the image to all processes: each process holds the whole image, which is never exchanged between processes afterwards. A $1024^3$ image takes 1 GiB per process with `uint8` (8 GiB with `double`). This suits runs with one MPI process per GPU; with many processes per node, check the memory available per node.

### **Interpolation schemes**

<div class="center-table" markdown>

| `interpolation` | Stencil | Energy and force | Range of the energy |
| :------- | :------- | :------- | :------- |
| `catmull_rom` (default) | 4×4×4 voxels | Continuous, energy conserved. Passes exactly through the voxel values. | Can overshoot between voxels: about 7% of a sharp jump in the image, per axis. |
| `bspline` | 3×3×3 voxels | Continuous, energy conserved. Smooths the image (does not pass through the voxel values). | Always within the range of the voxel values. |
| `lagrange` | 3×3×3 voxels | The energy jumps when an atom crosses a voxel face: energy is **not** conserved. | Can overshoot. |

</div>

`catmull_rom` reproduces the image most faithfully and is the default. Use `bspline` when the energy must stay strictly within $[0, A\,s\,v_{max}]$, for instance with a binary or very sharp image. `lagrange` is kept for comparison only.

!!! info "Cost"

    `igar_force_interp` runs one thread per atom on CPU and GPU, in double precision. It only reads the image, so its cost does not depend on the image size: on a laptop GPU, 238 000 atoms with a $1024^3$ image take about 2 ms per step. `catmull_rom` costs about twice `bspline`.

!!! note "Particle updates and ghosts"

    The image is held by every process, so IGAR needs nothing special from the particle updates: keep the default update scheme (particles are moved and neighbor lists rebuilt only when an atom has moved more than half the skin). The IGAR forces are computed on the atoms owned by each process only; the ghost settings are the ones of the interatomic potential.

### **Image file**

The image is read from a legacy VTK file with `DATASET STRUCTURED_POINTS` and one scalar per point:

```
# vtk DataFile Version 3.0
vtk output
BINARY
DATASET STRUCTURED_POINTS
DIMENSIONS 1024 1024 1024
SPACING 1 1 1
ORIGIN 0 0 0
POINT_DATA 1073741824
SCALARS ScalarData unsigned_char
LOOKUP_TABLE default
<data>
```

- `ASCII` and `BINARY` files are both accepted. BINARY files are much smaller and faster to read: a $1024^3$ 8-bit image (1 GiB) is read in a few seconds.
- In BINARY files, every numeric type is accepted (`unsigned_char`, `short`, `int`, `float`, `double`, `vtktypeint64`, ...), stored big-endian as the VTK format requires.
- Files where VTK wrote 8-bit data as `COLOR_SCALARS` (no `LOOKUP_TABLE`; in ASCII files the values are written divided by 255) are read back as bytes 0-255.

Two Python scripts are shipped in `exaStamp/data/regression_new/igar/`:

- `vtk_ascii_to_binary.py` converts an ASCII VTK file into a BINARY one, without loading the whole image in memory:

    ```bash
    python vtk_ascii_to_binary.py image.vtk image_bin.vtk                # integer data -> 8-bit
    python vtk_ascii_to_binary.py image.vtk image_bin.vtk --scale 255    # image normalized to [0,1] -> 8-bit
    python vtk_ascii_to_binary.py field.vtk field_bin.vtk --dtype float64  # real-valued field
    ```

    `--dtype uint8` (the default for integer data) stops if a value is not an integer 0-255 after `--scale`. After `--scale 255`, read the file with `value_scale: 0.00392156862745098` (1/255) to recover the original values.

- `generate_vtk_grid.py` writes test images (a sinusoid, or random spheres) as BINARY 8-bit files by default.

## **Usage examples**

!!! example "**REBO carbon guided by an 8-bit image**"
    ```yaml
    species:
      - C: { z: 12, mass: 12.0107 Da, charge: 0.0 e- }

    init_parameters:
      - species
      - rebo_init:
          parameters:
            potential_file: "CH.rebo"

    compute_force_prolog:
      - zero_force_energy: { ghost: true }

    compute_force:
      - rebo_bond_order
      - ghost_update_opt: { opt_fields: [ "NijC", "NijH" ] }
      - rebo_conjugation
      - ghost_update_opt: { opt_fields: [ "Nconj" ] }
      - rebo_pairwise
      - rebo_manybody
      - igar_force_interp: { energy_factor: 2.0 eV }   # image levels 0-255 -> 0 to 2 eV

    compute_force_epilog:
      - update_force_from_ghost
      - force_to_accel

    setup_system:
      - domain:
          cell_size: 15.5 ang
          periodic: [ true, true, true ]
          expandable: false
      - read_xyz_file_with_xform:
          filename: "carbon.xyz"
          bounds_mode: FILE
      - igar_read_field:
          file_name: "image_1024.vtk"
          storage: uint8
          value_scale: 0.00392156862745098   # 1/255
    ```

!!! example "**Real-valued field, smooth interpolation**"
    ```yaml
    compute_force:
      - lj_compute_force
      - igar_force_interp: { energy_factor: 20000.0, interpolation: bspline }

    setup_system:
      # ... domain and atoms ...
      - igar_read_field: { file_name: "field.vtk", storage: double }
    ```

Complete inputs are in `exaStamp/data/regression_new/igar/` (`LJ_igar.msp`, `CH_rebo_read_xyz.msp`) and in the `igar_interp` case of `exaStamp/data/regression_new/physics_regression/`.

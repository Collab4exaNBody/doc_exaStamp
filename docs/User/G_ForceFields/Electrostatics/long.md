# **Long range**

Long range electrostatics split the Coulomb energy into a short range part computed in real space and a long range
part computed in reciprocal space:

$$
E = \underbrace{\frac{1}{4\pi\varepsilon_0}\sum_{i<j} q_i q_j \frac{\operatorname{erfc}(g r_{ij})}{r_{ij}}}_{\text{real space, } r_{ij}<r_c}
  + \underbrace{\frac{1}{2V\varepsilon_0}\sum_{\mathbf{k}\neq 0} \frac{e^{-k^2/4g^2}}{k^2}\,|S(\mathbf{k})|^2}_{\text{reciprocal space}}
  - \frac{1}{4\pi\varepsilon_0}\frac{g}{\sqrt{\pi}}\sum_i q_i^2
  - \frac{1}{4\pi\varepsilon_0}\frac{\pi\, Q^2}{2 g^2 V}
$$

with $S(\mathbf{k}) = \sum_i q_i e^{i\mathbf{k}\cdot\mathbf{r}_i}$, $g$ the Ewald splitting parameter (`g_ewald`), $V$ the cell
volume and $Q=\sum_i q_i$ the total charge. The last two terms are the self energy and the neutralizing background
energy for a non-neutral system.

exaStamp provides two reciprocal space solvers, both following the LAMMPS algorithms and parameter choices
(`kspace_style ewald` and `kspace_style pppm`):

<div class="center-table" markdown>

| Method | Initialization | Real space | Reciprocal space | Cost |
| :----- | :------------- | :--------- | :--------------- | :--- |
| Ewald summation | `coulombic_ewald_init` | `coulombic_ewald_short_range` | `coulombic_ewald_long_range` | $O(N \cdot N_k)$ |
| PPPM | `coulombic_pppm_init` | `coulombic_ewald_short_range` | `coulombic_pppm` | $O(N + M\log M)$ |

</div>

Both methods have the following properties:

- [x] Orthogonal and triclinic periodic cells are supported.
- [x] Charges are read per particle (`charge` field) by default. To use the species charges instead, set `per_atom_charge: false` on `coulombic_ewald_short_range`.
- [x] Per-atom energies and the full virial tensor, including the reciprocal part, are computed.
- [x] Both methods run on CPU (OpenMP) and GPU (CUDA). PPPM FFTs use cuFFT on GPU and the bundled pocketfft library on CPU.
- [x] When the cell changes (NPT, deformation), the reciprocal space data is updated automatically at the next call of the initialization operator. Place that operator in `compute_force` when the cell changes during the run.

!!! warning "Required inputs"
    Both initialization operators need the total charge, the sum of squared charges and the number of atoms. These
    come from the `sum_charges` operator, which must run before `coulombic_ewald_init` or `coulombic_pppm_init`
    (typically at the end of `setup_system`). With species charges, call `copy_charge_specy_to_particle` before
    `sum_charges`.

All accuracies are **relative**: `accuracy_relative` is the target RMS force error divided by the force between two
unit charges 1 Å apart (14.399645 eV/Å). This is the same convention as the LAMMPS `kspace_style <style> <accuracy>`
value. The Coulomb constant is the LAMMPS metal units value, $1/(4\pi\varepsilon_0) = 14.399645$ eV·Å/e².

## **Ewald Summation**

`coulombic_ewald_init` builds the list of k vectors. `coulombic_ewald_long_range` computes the structure factors
$S(\mathbf{k})$ and the reciprocal space forces, per-atom energies and virial. Only half of k space is stored: $\mathbf{k}$
and $-\mathbf{k}$ give the same contribution. For a triclinic cell with matrix $H$ (columns = cell vectors), the k
vectors are $\mathbf{k} = 2\pi H^{-T}\mathbf{n}$.

<div class="center-table" markdown>

| Parameter | Units | Default | Description |
| :-------- | :---: | :-----: | :---------- |
| `accuracy_relative` | — | required | Relative RMS force accuracy. Used to choose `g_ewald` and `kmax` when they are automatic. |
| `g_ewald` | 1/distance | required | Ewald splitting parameter. `0` = automatic, from `accuracy_relative` and `radius`. |
| `radius` | distance | required | Real space cutoff $r_c$. |
| `kmax` | — | required | Maximum k vector index, the same in the 3 directions (LAMMPS `kspace_modify kmax/ewald`). `0` = automatic, per direction. |

</div>

```yaml
coulombic_ewald_init:
  accuracy_relative: 1.0e-5
  g_ewald: 0.0            # automatic
  radius: 10.0 ang
  kmax: 0                 # automatic

init_parameters:
  - coulombic_ewald_init  # sets rcut / rcut_max before the system exists

compute_force:
  - coulombic_ewald_short_range
  - coulombic_ewald_long_range

setup_system:
  # ... domain, particles ...
  - copy_charge_specy_to_particle
  - sum_charges
  - coulombic_ewald_init
```

The chosen parameters (`g_ewald`, `kmax` per direction, number of k vectors in half k space) are printed at
initialization in an `Ewald configuration` block. For the 12000-atom UO2 validation system with $r_c$ = 10 Å and
`accuracy_relative` $10^{-5}$, the automatic choice is `g_ewald` = 0.32644139 with 14335 half-space k vectors, the same as LAMMPS.

!!! tip
    The cost of `coulombic_ewald_long_range` grows like $N \cdot N_k$, and with an automatic `kmax` the number of
    k vectors grows with the box size. For more than a few thousand atoms, use PPPM.

## **Particle-Particle Particle-Mesh**

`coulombic_pppm` spreads the charges onto a regular mesh with a B-spline of order `order`, then solves Poisson's
equation by FFT with the optimal influence function (Hockney–Eastwood). The field is interpolated back onto the
particles. `coulombic_pppm_init` chooses `g_ewald` and the mesh size from `accuracy_relative` exactly as LAMMPS does.
The same mesh size and `g_ewald` are obtained for the same input. `coulombic_pppm_init` also fills the parameters used
by `coulombic_ewald_short_range`, so the real space part is shared with the Ewald method.

<div class="center-table" markdown>

| Parameter | Units | Default | Description |
| :-------- | :---: | :-----: | :---------- |
| `accuracy_relative` | — | `1.0e-5` | Relative RMS force accuracy. Used to choose `g_ewald` and the mesh when they are automatic. |
| `g_ewald` | 1/distance | `0.0` | Ewald splitting parameter. `0` = automatic. |
| `radius` | distance | required | Real space cutoff $r_c$. |
| `mesh` | — | `[0,0,0]` | Number of mesh points in x, y, z. `[0,0,0]` = automatic (sizes with factors 2, 3, 5 only). |
| `order` | — | `5` | Charge assignment order, 2 to 7. |
| `diff` | — | `ik` | Differentiation scheme: `ik` or `ad` (see below). |
| `slab` | — | `0.0` | Slab correction: z extension factor of the cell (> 1). `0` = no slab correction. |
| `slab_auto` | — | `false` | Slab correction with the z extension factor computed automatically. |
| `mesh_decomposition` | — | `distributed` | `distributed`, `replicated` or `auto` (see below). |

</div>

```yaml
coulombic_pppm_init:
  accuracy_relative: 1.0e-5
  g_ewald: 0.0            # automatic
  radius: 10.0 ang
  order: 5
  mesh: [ 0, 0, 0 ]       # automatic

init_parameters:
  - coulombic_pppm_init

compute_force:
  - coulombic_ewald_short_range
  - coulombic_pppm

setup_system:
  # ... domain, particles ...
  - copy_charge_specy_to_particle
  - sum_charges
  - coulombic_pppm_init
```

The chosen parameters (`g_ewald`, mesh, order, differentiation, decomposition, slab factor, estimated accuracy) are
printed at initialization in a `PPPM configuration` block. For the 12000-atom UO2 validation system, the automatic
choice is `g_ewald` = 0.33415064 with a 72³ mesh (72×75×75 for the triclinic cell), the same as LAMMPS.

### Differentiation: `ik` and `ad`

- **`ik`** (default) computes the field $\mathbf{E}(\mathbf{k}) = -i\mathbf{k}\,\phi(\mathbf{k})$ in k space. It works on orthogonal and triclinic cells.
- **`ad`** (analytic differentiation) differentiates the assignment function in real space. It needs fewer inverse FFTs and a larger mesh for the same accuracy, and it works on orthogonal cells only, as in LAMMPS. The self-force correction (`sf_coeff`) is applied.

!!! note "`g_ewald` with `diff: ad`"
    LAMMPS' automatic `g_ewald` search for `ad` is numerically ill-conditioned: a relative change of $10^{-13}$ in the
    sum of squared charges changes `g_ewald` by about $3\times10^{-5}$. exaStamp and LAMMPS can therefore pick slightly
    different automatic values for the same system. Both are equally valid. To reproduce a LAMMPS run exactly, set
    `g_ewald` explicitly.

### Slab correction

For systems that are periodic in x and y only (surfaces, interfaces), `slab` / `slab_auto` add the EW3DC correction of
Yeh and Berkowitz, like LAMMPS `kspace_modify slab <volfactor>` / `kspace_modify slab auto`:

- The z boundary of the domain must be non-periodic, and x and y must be periodic.
- The mesh is built on a cell extended by the factor `slab` in z (typically 3.0). The dipole correction removes the interaction with the periodic images in z.
- With `slab_auto: true`, the extension factor is computed from `accuracy_relative` and `g_ewald`.
- Triclinic cells are supported with an xy tilt only: the third cell vector must be along z ($H_{13}=H_{23}=H_{31}=H_{32}=0$).
- As in LAMMPS, the slab correction adds forces and energies, but no virial contribution.

```yaml
coulombic_pppm_init:
  accuracy_relative: 1.0e-5
  radius: 10.0 ang
  slab: 3.0               # or slab_auto: true

setup_system:
  - domain:
      periodic: [ true, true, false ]
      # ...
```

!!! warning "LAMMPS `ad` + slab"
    In LAMMPS, `fieldforce_ad` uses the mesh spacing of the unextended cell ($n_z / L_z$) for the z field, while the
    mesh covers the extended cell ($L_z \cdot$ volfactor). The z forces are therefore wrong with `pppm` + `kspace_modify diff ad`
    + `kspace_modify slab`. exaStamp uses the extended spacing. This was checked by mesh convergence: `ik` and `ad`
    agree to $1.6\times10^{-5}$ in exaStamp, while LAMMPS `ad` + slab z forces are off by up to 13 eV/Å on the
    validation system.

### Mesh decomposition across MPI ranks

<div class="center-table" markdown>

| `mesh_decomposition` | Behaviour |
| :------------------- | :-------- |
| `distributed` (default) | The mesh is split into z slabs among ranks. Each rank spreads its particles onto a local brick (the stencils of its particles), exchanges bricks with `MPI_Alltoallv`, and runs a distributed FFT (2D planes then 1D columns). |
| `replicated` | Every rank holds the whole mesh. Charge densities are summed with one `MPI_Allreduce`, and each rank runs the FFTs on the full mesh. |
| `auto` | `distributed` when running on more than one rank, `replicated` otherwise. |

</div>

Both decompositions give the same results. The cost of `replicated` grows with the number of ranks, since every
rank runs the full FFTs and the whole mesh is summed over all ranks. Time per step of `coulombic_pppm` on 12000 atoms,
72³ mesh, 1 thread per rank, energy and virial computed every step:

<div class="center-table" markdown>

| MPI ranks | `distributed` | `replicated` |
| :-------: | ------------: | -----------: |
| 1 | 30.0 ms | 20.9 ms |
| 2 | 26.2 ms | 24.5 ms |
| 4 | 20.5 ms | 29.3 ms |
| 8 | 20.7 ms | 55.9 ms |

</div>

On 1 rank, `replicated` (or `auto`) is faster; on 2 ranks the two are close; from 4 ranks on, `distributed` is faster.

## **Real space part**

`coulombic_ewald_short_range` computes the $\operatorname{erfc}(g r)/r$ pair term. It is used by both Ewald and PPPM.
It reads the parameters set by `coulombic_ewald_init` or `coulombic_pppm_init`, so it has no physics parameter of
its own.

<div class="center-table" markdown>

| Parameter | Default | Description |
| :-------- | :-----: | :---------- |
| `per_atom_charge` | `true` | Read charges from the per-particle `charge` field. `false` = use the species charges. |
| `use_symmetry` | `false` | Must match the symmetric setting of the neighbor lists. Each pair is computed once. |
| `ghost_fold_back` | `false` | Only valid with `use_symmetry: true`. Pairs are computed from owned cells only, and contributions to ghost particles are added back to their owners afterwards (faster, see below). |

</div>

With `use_symmetry: true` alone, the pair loop also visits ghost cells. With `ghost_fold_back: true`, it visits owned
cells only. On 12000 atoms, one thread, $r_c$ = 10 Å, this brings the real space time from 140 to 89 ms/step. The
ghost forces, energies and virials must then be zeroed before the force computation and folded back after it:

```yaml
coulombic_ewald_short_range:
  use_symmetry: true
  ghost_fold_back: true

compute_force_prolog:
  - zero_force_energy: { ghost: true }

compute_force_epilog:
  - update_virial_force_energy_from_ghost
  - force_to_accel

# optional with use_symmetry: half neighbor lists, halves the neighbor list memory
chunk_neighbors:
  config:
    half_symmetric: true
```

Setting `ghost_fold_back: true` without `use_symmetry: true` is a fatal error.

## **Validation against LAMMPS**

The test system is coulomb-only UO2 with 12000 atoms (disturbed fluorite, $r_c$ = 10 Å, accuracy $10^{-5}$),
orthogonal and triclinic (tilts xy=5, xz=3, yz=4 Å). It is compared with LAMMPS `coul/long` + `ewald` / `pppm` over
10 NVE steps. The inputs (`in.coul`, `exastamp_<case>.msp`, `compare.py`, data files) are in
`data/regression_new/potentials/coulombic/lammps_validation/` of the exaStamp repository.

<div class="center-table" markdown>

| Quantity | Max. difference vs LAMMPS |
| :------- | :------------------------ |
| `g_ewald`, k vector count, PPPM mesh, estimated accuracy | identical |
| Forces | 3 – 4 × 10⁻⁸ eV/Å |
| Per-atom energies | 3 – 4 × 10⁻⁸ eV |
| Pressure tensor | 9 × 10⁻⁸ relative (unit conversion constant) |
| Positions after 10 steps | 2.5 × 10⁻⁹ Å |

</div>

These differences hold for all of these runs:

- **Ewald:** automatic and user `kmax`, orthogonal and triclinic.
- **PPPM:** `ik` orthogonal and triclinic, `ad` (with the LAMMPS `g_ewald`), slab, `slab_auto`, and triclinic slab.
- **Real space options:** per-atom and species charges, `use_symmetry`, `ghost_fold_back`.
- **Parallel configurations:** 1 rank, 2 MPI ranks × 2 OpenMP threads, and GPU with 1 and 2 ranks.
- **PPPM mesh decomposition:** replicated and distributed; distributed also on 3, 4 and 8 MPI ranks (all PPPM cases).

The slab cases match LAMMPS to $1.5\times10^{-7}$ eV/Å (forces up to 15 eV/Å).

The ctest regression cases in `data/regression_new/potentials/coulombic/` (`ewald_*`, `pppm*`, `*_fold`) run
the same operators on a smaller generated system (768 atoms).

### Timings

12000 atoms UO2, energy and virial computed every step, time per step of the reciprocal space operator. CPU is
1 thread. The LAMMPS build uses the KISS FFT.

<div class="center-table" markdown>

| Case | exaStamp CPU | exaStamp GPU | LAMMPS CPU |
| :--- | -----------: | -----------: | ---------: |
| Ewald, `kmax` 8 | 30 ms | 5.2 ms | 162 ms |
| Ewald, automatic (28670 k) | 352 ms | 54 ms | 2210 ms |
| Ewald, triclinic automatic | 351 ms | 54 ms | 2190 ms |
| PPPM `ik`, 72³ | 45 ms | 5.5 ms | 199 ms |
| PPPM `ik` triclinic, 72×75×75 | 49 ms | 7.7 ms | 193 ms |
| PPPM `ad`, 96³ | 97 ms | 11 ms | 517 ms |

</div>

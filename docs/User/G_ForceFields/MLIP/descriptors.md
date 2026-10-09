---
icon: material/matrix
---

# **MLIP Descriptors**

SNAP, POD, MTP and k2b can compute their atomic **descriptors** without evaluating the potential. You can use them to analyse local environments, or to build the linear-regression data needed to **fit** a potential. Each model provides three operators with the same structure:

<div class="center-table" markdown>

| Model | Per-atom descriptors | Global design matrix | Writer | Required init | Derivative field prefix |
| :---- | :------------------- | :------------------- | :----- | :------------ | :---------------------- |
| SNAP | `compute_descriptor_snap` | `compute_descriptor_snap_global` | `write_descriptor_snap_global` | `snap_init` | `sda_` |
| POD  | `compute_descriptor_pod`  | `compute_descriptor_pod_global`  | `write_descriptor_pod_global`  | `pod_init`  | `pda_` |
| MTP  | `compute_descriptor_mtp`  | `compute_descriptor_mtp_global`  | `write_descriptor_mtp_global`  | `mtp_init`  | `mda_` |
| k2b  | `compute_descriptor_k2b`  | `compute_descriptor_k2b_global`  | `write_descriptor_k2b_global`  | `k2b_init`  | `k2bda_` |

</div>

The `*_init` operator goes in `init_parameters`, as for the force computation (see [MLIP overview](index.md)). The descriptor operators are typically placed in `simulation_epilog` for a single configuration, or inside a loop over a database (see [below](#looping-over-a-database-of-configurations)).

!!! note "Build"

    The descriptor operators are part of each model's plugin: SNAP needs `EXASTAMP_MLIP_SNAP_BUILD=ON`, POD needs `EXASTAMP_MLIP_POD_BUILD=ON`, MTP needs `EXASTAMP_MLIP_MTP_BUILD=ON`. k2b is always built.

## **Per-atom descriptors**

`compute_descriptor_<model>` computes, for every atom, the descriptor vector of its neighborhood. The result is stored in a flat buffer indexed by atom slot (`bispectrum` for SNAP, `pod_descriptors`, `mtp_descriptors`, `k2b_descriptors`), with stride `ncoeff`.

```{ .yaml title="Syntax" .syntax-block }
compute_descriptor_<model>:
  compute_derivative: <bool>
  deriv_agg_field_prefix: <string>
```

```{ .yaml title="Parameters" .params-block }
compute_derivative:      bool, default false     # Also compute the descriptor derivatives (needed by the *_global operators).
deriv_agg_field_prefix:  string, model default   # Name prefix of the per-atom derivative fields (sda_, pda_, mda_, k2bda_). Keep it short: field names are limited to 15 characters.
```

With `compute_derivative: true`, each atom $a$ also receives the derivative aggregate $\sum_i \partial D_{i,k} / \partial \mathbf{r}_a$: the derivatives, with respect to the position of $a$, of the descriptors of every atom $i$ that has $a$ as a neighbor (including $i=a$). They are stored as per-atom grid fields `<prefix>0`, `<prefix>1`, ... For a parallel run with several MPI ranks, fold the ghost contributions back into their owner atoms right after the operator:

```yaml
update_opt_from_ghost: { opt_fields: [ "sda_.*" ] }
```

!!! warning

    The `*_global` operators below need the **un-folded** per-rank aggregate. Call them **before** any `update_opt_from_ghost` on the derivative fields.

`compute_descriptor_k2b` reads the `rcut` and `parameters` given to `k2b_init`. The other models read the context built by their init operator.

### SNAP-specific options

`compute_descriptor_snap` has extra options:

```{ .yaml title="Parameters" .params-block }
nneigh_bispectrum:   int, default 0       # If > 0, constant-neighbor-count mode: the cutoff of each atom is adapted so that about this many neighbors contribute, instead of the fixed cutoff of the parameter file.
closest_bispectrum:  bool, default true   # With nneigh_bispectrum > 0: true = exact (cutoff at the N-th nearest neighbor, sort-based); false = density-scaled estimate rcut = rcutfac * (N/n)^(1/3), cheaper but approximate.
neigh_margin:        float, default 0.01  # With closest_bispectrum: true, margin added beyond the N-th nearest-neighbor distance.
```

In constant-neighbor-count mode, `rcutfac` in the parameter file must be large enough to contain at least `nneigh_bispectrum` neighbors everywhere, and `switchinnerflag` is not supported.

Only the header line of each element (`name radelem weight`) of the SNAP coefficient file is used to compute descriptors: the number of descriptors depends only on `twojmax` and the number of elements. A reduced coefficient file is therefore enough, for instance for a single element:

```text
1 0
Ta 0.5 1
```

## **Global design matrix**

`compute_descriptor_<model>_global` assembles, for the whole configuration, the matrix $A$ of a linear model $A\,\boldsymbol{\beta}$. It is row-major, with $1+3N+6$ rows ($N$ atoms) and `ncoeff_all` columns:

<div class="center-table" markdown>

| Rows | Content | $A\,\boldsymbol{\beta}$ gives |
| :--- | :------ | :---------------------------- |
| $0$ | descriptors summed over all atoms (one column block per species) | total energy |
| $1+3m+\{0,1,2\}$ | derivative with respect to $x,y,z$ of atom $m$ (`id` $=m$), already force-signed | force on atom $m$ |
| $3N+1 \dots 3N+6$ | $\sum \mathbf{r}\otimes$ (force-signed derivative), Voigt order $xx,yy,zz,yz,xz,xy$ | virial |

</div>

The force rows are already signed: $\mathbf{F} = +A\,\boldsymbol{\beta}$, no extra minus sign. Atom $m$ is identified by its particle `id`, so ids must run from $0$ to $N-1$. The matrix holds no reference (DFT) values: append them yourself when fitting. It is reduced over all MPI ranks, so every rank holds the full matrix.

Column layout per model:

- **SNAP**: `ncoeff * ntypes` columns, one block of `ncoeff` columns per species (column = `ncoeff * type + k`).
- **POD**: `nCoeffPerElement * nelements` columns, one block per element. Row 0 includes the one-body (atom count) term.
- **MTP**: `species_count + ncoeff` columns. The first `species_count` columns count the atoms of each species (row 0 only); the remaining `ncoeff` columns hold the basis functions $B_k$, shared by all species. Force and virial rows only populate the $B_k$ columns.
- **k2b**: `n_rbf` columns.

The global operator reads the output of `compute_descriptor_<model>`, which must run first with `compute_derivative: true`.

## **Writing the matrix**

`write_descriptor_<model>_global` writes the global matrix to a single file, from rank 0.

```{ .yaml title="Syntax" .syntax-block }
write_descriptor_<model>_global:
  filename: <string>
  format: <string>
```

```{ .yaml title="Parameters" .params-block }
filename:  string, default "<model>_global.txt"   # Output file. With format: npy, a trailing ".txt" is replaced by ".npy".
format:    string, default "text"                 # "text": one line per row, space-separated. "npy": a single NumPy .npy (v1.0) file of shape (1+3N+6, ncoeff_all), readable with numpy.load().
```

```yaml title="Usage example"
init_parameters:
  - species
  - pod_init:
      parameters: { pod_file: "Ta_param.pod", coeff_file: "Ta_coefficients.pod" }

setup_system:
  - domain:
      cell_size: 6.6 ang
      periodic: [ true, true, true ]
      expandable: false
  - read_xyz_file_with_xform:
      filename: "Ta_small.xyz"
      bounds_mode: FILE

simulation_epilog:
  - compute_descriptor_pod: { compute_derivative: true }
  - compute_descriptor_pod_global
  - write_descriptor_pod_global: { filename: "pod_global.txt" }
```

Examples for each model are in `exaStamp/data/regression_new/compute_descriptor/test_<model>_descriptors/`, and in `exaStamp/data/regression_new/mliaps/mtp/exastamp_example/compute_descriptor_mtp_{global,npy}.msp`.

## **Looping over a database of configurations**

To build a training set, two operators loop over every configuration file of a directory:

- `list_file_directory` recursively lists the files of `xyz_database` whose name ends with `pattern`.
- `next_database_file` picks the next file at each loop iteration. It sets `filename` (read by the XYZ reader) and `output_filename` = `desc_database/<file stem>` (used by the writer). When all files are processed, it sets `compute_desc_continue` to false, which ends the loop.

```{ .yaml title="Parameters" .params-block }
# list_file_directory
xyz_database:   string, required          # Directory searched recursively.
pattern:        string, default ".xyz"    # File name suffix to match.
# next_database_file
desc_database:  string, required          # Output directory of the descriptor files.
cursor:         int, default 0            # Index of the next file to process.
```

```yaml title="Usage example"
species:
  - Ta: { mass: 180.95 Da, z: 73, charge: 0 e- }

init_parameters:
  - species
  - k2b_init:
      rcut: 6.0 ang
      parameters: { n_rbf: 8, r_min: 0.5, r_cut: 6.0, sigma: 0.4, delta: 1.5, w: [ -1.057, -2.0949, 0.90561, -2.56538, 0.21529, -0.80587, -2.65201, 0.04461 ] }

read_single_file:
  - read_xyz_file_with_xform:
      verbose: false

get_desc_k2b:
  - compute_descriptor_k2b: { compute_derivative: true }
  - compute_descriptor_k2b_global

write_desc_k2b:
  rebind: { filename: output_filename }
  body:
    - write_descriptor_k2b_global:
        format: npy

process_files_loop:
  loop: true
  name: get_desc_files_loop
  condition: compute_desc_continue
  body:
    - next_database_file
    - grid_clear
    - read_single_file
    - species: { verbose: false , fail_if_empty: true }
    - grid_post_processing
    - reduce_species_after_read
    - init_particles
    - get_desc_k2b
    - write_desc_k2b

global:
  rcut_max: 6.0 ang
  rcut_inc: 1.0 ang
  xyz_database: "Ta_DB_XYZ"
  desc_database: "Ta_Desc_K2B"
  compute_desc_continue: true

simulation:
  name: exaStamp_training
  body:
    - print_logo_banner
    - hw_device_init
    - make_empty_grid
    - grid_flavor_full
    - global
    - init_parameters
    - generate_default_species
    - particle_regions
    - preinit_rcut_max
    - domain:
        cell_size: 6.0 ang
        periodic: [ true, true, true ]
        expandable: false
    - init_prolog
    - list_file_directory
    - process_files_loop
    - hw_device_finalize
```

This input replaces the default `simulation` block: no time integration, just one descriptor file per configuration. The same pattern works for SNAP and POD (`exaStamp/data/regression_new/mlip_training/create_descriptor_database_{snap,pod,k2b}.msp`).

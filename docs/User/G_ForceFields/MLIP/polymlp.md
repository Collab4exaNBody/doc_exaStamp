---
icon: material/function-variant
---

# **Polynomial MLP (pypolymlp)**

## **Description**

`polymlp_force` evaluates the polynomial machine-learning potentials of A. Seko ([pypolymlp](https://github.com/sekocha/pypolymlp), [Polynomial MLP Repository](https://cms.mtl.kyoto-u.ac.jp/seko/mlp-repository/), LAMMPS `pair_style polymlp`). The energy of atom $i$ is a polynomial of rotation-invariant features of its neighbourhood:

$$
a_{n l m}^{t_i t_j}(i) = \sum_{j} f_n(r_{ij})\, Y_{lm}(\hat{r}_{ij}), \qquad
d_k(i) = \sum_{s} c_{ks} \prod_{q} a_{s,q}(i), \qquad
E_i = \sum_{u} w_u \prod_{k \in u} d_k(i)
$$

with Gaussian radial functions $f_n(r) = e^{-\beta_n (r-\mu_n)^2}\, f_c(r)$, $f_c$ a cosine cutoff, and features $d_k$ built from invariant products of the order parameters $a$ (polynomial invariants of order up to 6, `feature_type: gtinv`) or from pair terms only (`feature_type: pair`).

The kernels are native exaStamp kernels: on a GPU if one is available, else vectorised OpenMP on the CPU. Products shared by several feature terms are evaluated once (prefix tree), complex-conjugate terms once.

!!! note "Build"

    Built by default; disable with `-DEXASTAMP_MLIP_POLYMLP_BUILD=OFF`.

## **Converting a potential**

The polymlp files (`polymlp.lammps`, `polymlp.yaml`) only give the model parameters: the invariant features are enumerated by the polymlp library. The exaStamp tool `exaStamp/scripts/polymlp_export` does this once, with the C++ core of pypolymlp, and writes flat tables read by `polymlp_init`:

```bash
pip install pypolymlp                     # its C++ sources and gtinv tables are used by the exporter
cd exaStamp/scripts/polymlp_export && make -j4 POLYMLP_SRC=$(python -c "import pypolymlp, os; print(os.path.dirname(pypolymlp.__file__))")/cxx/src
./polymlp_export polymlp.lammps polymlp.exastamp.yaml
```

Hybrid potentials (sums of several polymlp files) are not supported yet.

## **Operators**

```{ .yaml title="Syntax" .syntax-block }
init_parameters:
  - species
  - polymlp_init:
      parameters:
        file: <string>
        mem_gb: <float>
        emulate: <int>

compute_force:
  - polymlp_force
```

```{ .yaml title="Parameters" .params-block }
parameters.file:      string, required        # model exported by polymlp_export.
parameters.mem_gb:    float, default 1.0      # memory budget of the per-chunk work arrays (GB).
parameters.emulate:   int, default 0          # debug: N > 0 runs the GPU code paths on the CPU with blocks of N threads (slow).
```

The exaStamp species are matched to the elements of the model **by name**. `polymlp_init` raises `rcut_max` to the model cutoff. As for every MLIP, ghost forces must be zeroed before and folded back after `polymlp_force` (see [MLIP](index.md)). Per-atom energy: $E_i$. Per-atom virial: the whole virial of each bond on its central atom.

```yaml title="Usage example"
includes:
  - config_update_symmetric_forces.msp

species:
  - Ti: { mass: 47.867 Da, z: 22, charge: 0 e- }
  - Al: { mass: 26.9815 Da, z: 13, charge: 0 e- }

init_parameters:
  - species
  - polymlp_init:
      parameters: { file: "tial.polymlp.yaml" }

compute_force:
  - polymlp_force
```

A complete example is the regression case `exaStamp/data/regression_new/physics_regression/mlip_polymlp_tial` (Ti-Al potential of the repository, CC-BY-4.0).

## **Validation and performance**

Against pypolymlp on repository potentials (Al, Ta up to $l_{max} = 16$ and invariant order 6, Ti-Al): energies $\le 4\times10^{-10}$ eV, forces $5\times10^{-11}$ eV/Å, virials to round-off, identical for any MPI / OpenMP decomposition (pypolymlp and the LAMMPS package run on one MPI process only) and for the emulated GPU code path. On an Apple M4 Pro (3456 Ta atoms, per evaluation): small Ta model 228 ms on 1 core / 60 ms on 4 threads (pypolymlp 642 / 178 ms), largest Ta model 2.7 s / 0.70 s (pypolymlp 7.05 / 2.05 s).

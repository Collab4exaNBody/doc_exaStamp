# **Short range**

Short range electrostatic methods truncate the Coulomb interaction at a cutoff $r_c$ and modify it so that the
truncation error stays small, without any reciprocal space computation. Their cost is $O(N)$, like any pair potential.
For the exact long range sum, see [Long range](long.md).

exaStamp provides two families of operators for short range electrostatics:

- **Per-atom charge operators** (`coulombic_*`, this page). They read the charge of each particle from the `charge`
  field, so charges can differ between particles of the same species (charge equilibration, charged defects...).
  They can also use the species charges.
- **Pair potential styles** (`coul_cut`, `coul_wolf`, `coul_dsf`, `coul_rf`, and the combined styles
  `ljwolf`, `ljrf`, `exp6rf`...). They use the species charges only, and support the multi-species and hybrid
  strategies of the [pair potential template](../Pair/index.md).

Both families share the same kernels: a Wolf, DSF or reaction field run gives the same forces with either front-end.

<div class="center-table" markdown>

| Method | Per-atom charge operators | Pair style | LAMMPS equivalent |
| :----- | :------------------------ | :--------- | :---------------- |
| Plain cutoff | — | `coul_cut` | `pair_style coul/cut` |
| Damped shifted force | `coulombic_dsf` | `coul_dsf` (+ `coulombic_dsf_self`) | `pair_style coul/dsf` |
| Wolf summation | `coulombic_wolf` | `coul_wolf` (+ `coulombic_wolf_self`) | `pair_style coul/wolf` |
| Reaction field | `coulombic_rf` | `coul_rf` | — |

</div>

The Coulomb constant is the LAMMPS metal units value, $1/(4\pi\varepsilon_0) = 14.399645$ eV·Å/e², except for the
reaction field, which uses the CODATA value of $\varepsilon_0$ (relative difference $1.6\times10^{-5}$).

## **Common options of the per-atom charge operators**

`coulombic_wolf`, `coulombic_dsf` and `coulombic_rf` have the same slots. Only the content of `parameters` changes.

<div class="center-table" markdown>

| Parameter | Default | Description |
| :-------- | :-----: | :---------- |
| `parameters` | required | Physics parameters of the method (see each section below). Their cutoff `rc` sets the interaction range. |
| `per_atom_charge` | `true` | Read charges from the per-particle `charge` field. `false` = use the species charges. |
| `use_symmetry` | `false` | Must match the symmetric setting of the neighbor lists. Each pair is computed once. |
| `ghost_fold_back` | `false` | Only valid with `use_symmetry: true`. Pairs are computed from owned cells only, and contributions to ghost particles are added back to their owners afterwards. |
| `self_energy` | `true` | Add the one-body self energy to per-atom energies (Wolf and DSF; ignored by `coulombic_rf`, which has none). |
| `enable_pair_weights` | `true` | Apply the pair weights of `compact_nbh_weight` when they exist (e.g. intramolecular exclusions). |

</div>

All three operators compute forces, and when `trigger_thermo_state` is true, per-atom energies and the virial.
They run on CPU (OpenMP) and GPU (CUDA).

`ghost_fold_back` works as for the real space part of Ewald (see [Long range](long.md#real-space-part)). The ghost
forces, energies and virials must be zeroed before the force computation and added back to their owners after it:

```yaml
coulombic_wolf:
  parameters: { alpha: 0.2 ang^-1 , rc: 10.0 ang }
  use_symmetry: true
  ghost_fold_back: true

compute_force_prolog:
  - zero_force_energy: { ghost: true }

compute_force_epilog:
  - update_virial_force_energy_from_ghost
  - force_to_accel
```

!!! warning "Charges"
    With `per_atom_charge: true` (the default), the `charge` field must be filled. When the charges come from the
    species definitions, call `copy_charge_species_to_particle` in `setup_system`, or set `per_atom_charge: false`.

## **Standard Coulombic Interaction**

The plain truncated Coulomb potential is available as the pair style `coul_cut` (species charges only):

$$
E(r) = \frac{1}{4\pi\varepsilon_0\,\varepsilon_r}\,\frac{q_i q_j}{r} - E_{\text{cut}} \quad \text{for } r < r_c
$$

As for every pair style, the energy is shifted by its value at the cutoff, $E_{\text{cut}}$, so that $E(r_c)=0$. The
forces are not modified.

```yaml
coul_cut_compute_force:
  rcut: 12.0 ang
  parameters: { dielectric: 1.0, shift: true }
```

See the [Coul cut](../Pair/Models/coul_cut.md) page for the full syntax.

!!! warning
    A truncated $1/r$ interaction is not converged with respect to $r_c$ in ionic systems: the energy depends on the
    net charge inside the cutoff sphere. Use it only for screened or very dilute systems. For ionic solids and
    liquids, use DSF, Wolf, or a long range method.

## **Damped Shifted Force**

The damped shifted force method of Fennell and Gezelter (*J. Chem. Phys.* 124, 234104, 2006) damps the Coulomb
interaction with $\operatorname{erfc}(\alpha r)$, then shifts both the energy and the force so that they vanish at the
cutoff:

$$
E(r) = \frac{q_i q_j}{4\pi\varepsilon_0}\left[\frac{\operatorname{erfc}(\alpha r)}{r} - \frac{\operatorname{erfc}(\alpha r_c)}{r_c}
+ \left(\frac{\operatorname{erfc}(\alpha r_c)}{r_c^2} + \frac{2\alpha}{\sqrt{\pi}}\frac{e^{-\alpha^2 r_c^2}}{r_c}\right)(r - r_c)\right]
\quad \text{for } r < r_c
$$

Each particle also has a self energy:

$$
E_i^{\text{self}} = -\frac{q_i^2}{4\pi\varepsilon_0}\left(\frac{e_{\text{shift}}}{2} + \frac{\alpha}{\sqrt{\pi}}\right),
\qquad e_{\text{shift}} = \frac{\operatorname{erfc}(\alpha r_c)}{r_c} + \left(\frac{\operatorname{erfc}(\alpha r_c)}{r_c^2} + \frac{2\alpha}{\sqrt{\pi}}\frac{e^{-\alpha^2 r_c^2}}{r_c}\right) r_c
$$

The self energy does not depend on positions, so it adds no force. `coulombic_dsf` adds it to the per-atom energies
when `trigger_thermo_state` is true (slot `self_energy`, default `true`).

As in LAMMPS, $\operatorname{erfc}(\alpha r)$ in the pair term uses the Abramowitz–Stegun approximation, and the
shifts are computed once with the exact $\operatorname{erfc}$.

<div class="center-table" markdown>

| Parameter | Units | Description |
| :-------- | :---: | :---------- |
| `alpha` | 1/distance | Damping parameter $\alpha$. Typical values: 0.2 Å⁻¹ for $r_c$ = 10 Å. |
| `rc` | distance | Cutoff radius $r_c$. |

</div>

```yaml
coulombic_dsf:
  parameters: { alpha: 0.2 ang^-1 , rc: 10.0 ang }

compute_force:
  - coulombic_dsf
```

!!! note "Pair style `coul_dsf`"
    The pair style uses the same kernel with the species charges:

    ```yaml
    coul_dsf_compute_force:
      rcut: 10.0 ang
      parameters: { alpha: 0.2 ang^-1 , rc: 10.0 ang }
    ```

    The pair template subtracts $E(r_{\text{cut}})$ from every pair. With the approximate $\operatorname{erfc}$,
    $E(r_c)$ is about $1.8\times10^{-7}$ eV per unit charge product instead of 0, so `coul_dsf` energies differ from
    LAMMPS by this constant per pair (forces are identical). `coulombic_dsf` does not shift, and matches LAMMPS
    energies. The self energy is not included in the pair style: add the `coulombic_dsf_self` operator, with the same
    parameters and `per_atom_charge: false`. See [Coul DSF](../Pair/Models/coul_dsf.md).

## **Wolf Summation**

The Wolf method (Wolf *et al.*, *J. Chem. Phys.* 110, 8254, 1999) damps the Coulomb interaction with
$\operatorname{erfc}(\alpha r)$ and shifts the energy so that it vanishes at the cutoff. The implementation follows
LAMMPS `pair_style coul/wolf`:

$$
E(r) = \frac{q_i q_j}{4\pi\varepsilon_0}\left[\frac{\operatorname{erfc}(\alpha r)}{r} - \frac{\operatorname{erfc}(\alpha r_c)}{r_c}\right]
\quad \text{for } r < r_c
$$

$$
F(r) = \frac{q_i q_j}{4\pi\varepsilon_0}\left[\frac{\operatorname{erfc}(\alpha r)}{r^2} + \frac{2\alpha}{\sqrt{\pi}}\frac{e^{-\alpha^2 r^2}}{r}
- \frac{\operatorname{erfc}(\alpha r_c)}{r_c^2} - \frac{2\alpha}{\sqrt{\pi}}\frac{e^{-\alpha^2 r_c^2}}{r_c}\right]
$$

As in LAMMPS, the force is shifted to vanish at $r_c$ while the energy is only shifted, so $F \neq -\mathrm{d}E/\mathrm{d}r$.
The total energy is therefore not exactly conserved in NVE. Use DSF when energy conservation matters.

The self energy is the same expression as for DSF, with $e_{\text{shift}} = \operatorname{erfc}(\alpha r_c)/r_c$. It is
included by `coulombic_wolf` (slot `self_energy`), when `trigger_thermo_state` is true.

<div class="center-table" markdown>

| Parameter | Units | Description |
| :-------- | :---: | :---------- |
| `alpha` | 1/distance | Damping parameter $\alpha$. |
| `rc` | distance | Cutoff radius $r_c$. |

</div>

```yaml
coulombic_wolf:
  parameters: { alpha: 0.2 ang^-1 , rc: 10.0 ang }

compute_force:
  - coulombic_wolf
```

The pair style `coul_wolf` (and `ljwolf`) uses the same kernel with the species charges, see
[Coul wolf](../Pair/Models/coul_wolf.md). Like `coul_dsf`, it does not include the self energy: add the
`coulombic_wolf_self` operator, with the same parameters and `per_atom_charge: false`.

!!! warning "Self energy counted twice"
    `coulombic_wolf_self` and `coulombic_dsf_self` are meant for the pair styles only. Used together with
    `coulombic_wolf` or `coulombic_dsf`, they stop the run with an error, since the self energy would be counted twice.
    To keep a separate self energy operator anyway, set `self_energy: false` on the pair operator.

## **Reaction Field**

The reaction field method treats everything beyond the cutoff as a dielectric continuum of permittivity
$\varepsilon_{\text{rf}}$:

$$
E(r) = \frac{q_i q_j}{4\pi\varepsilon_0}\left[\frac{1}{r} + k_{\text{rf}}\, r^2 - C_{\text{rf}}\right] \quad \text{for } r < r_c,
\qquad
k_{\text{rf}} = \frac{\varepsilon_{\text{rf}} - 1}{2\varepsilon_{\text{rf}} + 1}\,\frac{1}{r_c^3},
\qquad
C_{\text{rf}} = \frac{1}{r_c} + k_{\text{rf}}\, r_c^2 = \frac{3\varepsilon_{\text{rf}}}{2\varepsilon_{\text{rf}} + 1}\,\frac{1}{r_c}
$$

so that $E(r_c) = 0$. There is no separate self term.

<div class="center-table" markdown>

| Parameter | Units | Description |
| :-------- | :---: | :---------- |
| `epsilon` | — | Dielectric constant $\varepsilon_{\text{rf}}$ of the continuum. `epsilon: 1` gives the plain shifted Coulomb potential; large values approach the conducting limit. |
| `rc` | distance | Cutoff radius $r_c$. |

</div>

```yaml
coulombic_rf:
  parameters: { epsilon: 100.0 , rc: 8.0 ang }

compute_force:
  - coulombic_rf
```

The same kernel is used by the pair styles `coul_rf`, `ljrf`, `exp6rf` and `ljexp6rf`, see
[Coul RF](../Pair/Models/coul_rf.md).

## **Validation against LAMMPS**

DSF and Wolf were compared with LAMMPS `pair_style coul/dsf` and `coul/wolf` on 12000 atoms of disturbed UO2
($\alpha$ = 0.2 Å⁻¹, $r_c$ = 10 Å, coulomb only) over 10 NVE steps. The inputs are in
`data/regression_new/potentials/coulombic/lammps_validation/` of the exaStamp repository
(`exastamp_wolf*.msp`, `exastamp_dsf*.msp`, `in.coul`, `compare.py`).

<div class="center-table" markdown>

| Quantity | Max. difference vs LAMMPS |
| :------- | :------------------------ |
| Total energy (pair + self) | 10⁻⁶ eV (precision of the thermo output) |
| Forces | 3 × 10⁻⁸ eV/Å |
| Per-atom energies | 3 × 10⁻⁸ eV |
| Pressure | 8 × 10⁻⁸ relative (unit conversion constant) |
| Positions after 10 steps | 2.4 × 10⁻⁹ Å |

</div>

These differences hold for both methods with per-atom and species charges, `use_symmetry`, and 2 MPI ranks. Wolf
was also checked with `ghost_fold_back`, with 2 MPI ranks × 2 OpenMP threads, and on GPU.
The pair styles `coul_wolf` and `coul_dsf` give the same forces; their energies follow the cutoff shift
described above. LAMMPS has no reaction field pair style, so `coulombic_rf` is covered only by the regression tests.

The ctest regression cases in `data/regression_new/potentials/coulombic/` (`wolf*`, `dsf`, `rf`) run the same
operators on a smaller generated system (768 atoms).

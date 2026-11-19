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

| Method | Per-atom charge operators | Pair style |
| :----- | :------------------------ | :--------- |
| Plain cutoff | — | `coul_cut` |
| Damped shifted force | `coulombic_dsf` | `coul_dsf` (+ `coulombic_dsf_self`) |
| Wolf summation | `coulombic_wolf` | `coul_wolf` (+ `coulombic_wolf_self`) |
| Reaction field | `coulombic_rf` | `coul_rf` |

</div>

The Coulomb constant is $1/(4\pi\varepsilon_0) = 14.399645$ eV·Å/e², except for the
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

$\operatorname{erfc}(\alpha r)$ in the pair term uses the Abramowitz–Stegun approximation, and the shifts are
computed once with the exact $\operatorname{erfc}$.

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
    `coulombic_dsf` (which does not shift) by this constant per pair. Forces are identical. The self energy is not included in the pair style: add the `coulombic_dsf_self` operator, with the same
    parameters and `per_atom_charge: false`. See [Coul DSF](../Pair/Models/coul_dsf.md).

## **Wolf Summation**

The Wolf method (Wolf *et al.*, *J. Chem. Phys.* 110, 8254, 1999) damps the Coulomb interaction with
$\operatorname{erfc}(\alpha r)$ and shifts the energy so that it vanishes at the cutoff:

$$
E(r) = \frac{q_i q_j}{4\pi\varepsilon_0}\left[\frac{\operatorname{erfc}(\alpha r)}{r} - \frac{\operatorname{erfc}(\alpha r_c)}{r_c}\right]
\quad \text{for } r < r_c
$$

$$
F(r) = \frac{q_i q_j}{4\pi\varepsilon_0}\left[\frac{\operatorname{erfc}(\alpha r)}{r^2} + \frac{2\alpha}{\sqrt{\pi}}\frac{e^{-\alpha^2 r^2}}{r}
- \frac{\operatorname{erfc}(\alpha r_c)}{r_c^2} - \frac{2\alpha}{\sqrt{\pi}}\frac{e^{-\alpha^2 r_c^2}}{r_c}\right]
$$

The force is shifted to vanish at $r_c$ while the energy is only shifted, so $F \neq -\mathrm{d}E/\mathrm{d}r$.
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
| `cutoff_mode` | — | Treatment of the force at $r_c$: `truncated` (default), `shifted_force` or `{ mode: switching, rs: VALUE UNITS }`, see below. |

</div>

```yaml
coulombic_rf:
  parameters: { epsilon: 100.0 , rc: 8.0 ang }

compute_force:
  - coulombic_rf
```

The same kernel is used by the pair styles `coul_rf`, `ljrf`, `exp6rf` and `ljexp6rf`, and by the molecular force
field (`ljexp6rf_pc`, `ljexp6rf_pc_fp32` and `intramolecular_pair_force`), see
[Coul RF](../Pair/Models/coul_rf.md) and [Bonding potentials](../Intramolecular/index.md#reaction-field-at-the-cutoff).

### **Force at the cutoff**

The energy is zero at $r_c$, but the force is not, unless $\varepsilon_{\text{rf}}$ is infinite:

$$
F(r_c) = -E'(r_c) = \frac{q_i q_j}{4\pi\varepsilon_0}\,\frac{3}{2\varepsilon_{\text{rf}} + 1}\,\frac{1}{r_c^2}
$$

When a pair crosses the cutoff, its force drops from this value to zero within one time step, and the total energy is
not conserved: it changes by a small step each time. `cutoff_mode` selects how the force is brought to zero:

- `truncated` (default): the reaction field above, the force drops to zero at $r_c$.
- `shifted_force`: the force at $r_c$ is subtracted at every distance,

    $$
    E_{\text{sf}}(r) = E(r) - (r - r_c)\,E'(r_c)
    $$

    Energy and force are both zero at $r_c$. All forces change, by a constant term for each pair, and so does the
    potential energy.

- `switching`: the energy is multiplied by a switching function between $r_s$ (key `rs`) and $r_c$,

    $$
    E_{\text{sw}}(r) = S(x)\,E(r), \qquad x = \frac{r - r_s}{r_c - r_s}, \qquad S(x) = 1 - 10x^3 + 15x^4 - 6x^5
    $$

    with $S = 1$ for $r \le r_s$. $S$, $S'$ and $S''$ are continuous at $r_s$ and $r_c$, so energy and force go
    smoothly to zero at $r_c$. Forces below $r_s$ are unchanged. The force between $r_s$ and $r_c$ includes the
    term $-S'(x)\,E(r)/(r_c - r_s)$ and can be larger than without switching.

```yaml
coulombic_rf:
  parameters: { epsilon: 2.2 , rc: 12.5 ang , cutoff_mode: { mode: switching , rs: 11.5 ang } }
```

!!! tip
    On condensed TATB ($\varepsilon_{\text{rf}} = 2.2$, $r_c$ = 12.5 Å), the force of an O–H pair at the cutoff
    is 0.012 eV/Å, 56% of the bare Coulomb force at that distance. Two runs whose time steps differ by $10^{-7}$
    have total energies that differ by $10^{-5}$ eV/atom after a pair crosses the cutoff in one run and not in the
    other. With `shifted_force` or `switching`, they stay within $6\times10^{-9}$ eV/atom. On two TATB inputs,
    switching from 11.5 Å changes the potential energy by $-4\times10^{-4}$ to $-3\times10^{-3}$ eV/atom, and the
    shifted force by $-0.1$ to $-0.2$ eV/atom (up to one third), since its constant force term acts on every pair
    inside $r_c$.

## **Tests**

DSF and Wolf were checked on 12000 atoms of disturbed UO2 ($\alpha$ = 0.2 Å⁻¹, $r_c$ = 10 Å, coulomb only) with
per-atom and species charges, `use_symmetry`, and 2 MPI ranks. Wolf was also checked with `ghost_fold_back`, with
2 MPI ranks × 2 OpenMP threads, and on GPU. The pair styles `coul_wolf` and `coul_dsf` give the same forces as
`coulombic_wolf` and `coulombic_dsf`; their energies follow the cutoff shift described above.

The ctest regression cases in `data/regression_new/potentials/coulombic/` (`wolf*`, `dsf`, `rf`) run the same
operators on a smaller generated system (768 atoms).

---
icon: material/atom
---

# **Embedded-Atom Model (EAM)**

In the Embedded-Atom Model, the energy of atom $i$ is the energy needed to embed it in the electron density created by its neighbors, plus a pair term:

$$
E_i = F\left(\rho_i\right) + \frac{1}{2}\sum_{j \neq i} \phi\left(r_{ij}\right),
\qquad
\rho_i = \sum_{j \neq i} \rho\left(r_{ij}\right)
$$

where $F$ is the embedding function, $\rho(r)$ the electron density contributed by a neighbor at distance $r$, and $\phi(r)$ the pair interaction. EAM models differ by the choice of $F$, $\rho$ and $\phi$:

<div class="center-table" markdown>

| Model | Operator prefix | Species | GPU | Parameters |
| :---- | :-------------- | :-----: | :-: | :--------- |
| [EAM alloy (tabulated, setfl file)](alloy.md) | `eam_alloy` | several | yes | file |
| [Johnson (Zhou–Johnson–Wadley form)](johnson.md) | `johnson` | one | yes | analytic |
| [Ravelo](ravelo.md) | `ravelo` | one | no | analytic + tabulated $F$ |
| [Sutton–Chen](sutton_chen.md) | `sutton_chen` | one | no | analytic |
| [VNIITF](vniitf.md) | `vniitf` | one | yes | analytic |
| [Tabulated EAM](tab.md) | `tabeam` | one | no | tabulated |

</div>

## **Single-species models**

Analytic and tabulated single-species models (`johnson`, `ravelo`, `sutton_chen`, `vniitf`, `tabeam`) all provide the same four operators. Below, `X` stands for the model prefix.

<div class="center-table" markdown>

| Operator | Description |
| :------- | :---------- |
| `X_force` | Complete EAM computation: embedding term on owned **and ghost** atoms, then forces and energies. |
| `X_emb` | First pass only: embedding term on owned atoms. |
| `X_force_reuse_emb` | Second pass only: forces and energies, using an embedding term computed before. |
| `X_init` | Reads the `parameters` once (typically in `init_parameters`), without computing anything. |

</div>

```{ .yaml title="Syntax" .syntax-block }
X_force:
  rcut: <float>
  parameters: <model parameters>
```

```{ .yaml title="Parameters" .params-block }
rcut:        float, required      # Cutoff radius of the potential.
parameters:  map, required        # Model parameters, see each model page.
```

`X_force` computes the embedding term on ghost atoms too, so that no communication is needed between the two passes. It therefore raises `ghost_dist_max` to twice the cutoff. To keep a ghost layer of one cutoff only, split the computation and exchange the embedding term (field `rho_dEmb`) between the two passes:

```yaml
compute_force:
  - johnson_emb
  - ghost_update_opt: { opt_fields: [ "rho_dEmb" ] }
  - johnson_force_reuse_emb
```

with the same `rcut` and `parameters` given to `johnson_emb` and `johnson_force_reuse_emb` (for instance with a YAML anchor).

## **Multi-species model**

[`eam_alloy`](alloy.md) handles several species and splits the computation into passes that can be called separately. Its options are described on its page.

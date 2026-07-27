---
icon: material/state-machine
---

# **`numerical_scheme`**

```{ .yaml title="Syntax" .syntax-block }
numerical_scheme: <scheme_name>
```

`numerical_scheme` is not itself an operator hard-coded in `exaStamp` — like [`grid_flavor`](../E_Grids/flavors.md), it's ONIKA's generic operator-alias mechanism: this top-level entry redirects the operator named `numerical_scheme` to whichever named **scheme** the string points at. A scheme is just a named `body:` list of operators (and/or nested batch labels) that gets executed, in order, once per timestep:

```yaml title="Anatomy of a scheme"
<scheme_name>:
  name: <arbitrary display name>
  body:
    - <operator_or_batch_1>
    - <operator_or_batch_2>
    - ...
```

Every ensemble, thermostat, and barostat on this site is a *specialization* of this same placeholder — a different scheme value, wiring together a different sequence of steps around the same [generic push operators](push_operators.md). `exaStamp` ships these named schemes out of the box:

| `numerical_scheme` value | Ensemble | Defined in |
|---|---|---|
| [`verlet_nve`](nve_ensemble.md#the-verlet_nve-scheme) | NVE | `config_numerical_schemes.msp` |
| [`verlet_bnvt`](Thermostats/berendsen.md#the-verlet_bnvt-scheme) | NVT, Berendsen thermostat | `config_numerical_schemes.msp` |
| [`verlet_lnvt`](Thermostats/langevin.md#the-verlet_lnvt-scheme) | NVT, Langevin thermostat | `config_numerical_schemes.msp` |
| [`verlet_nhnvt`](nvt_ensemble.md#the-verlet_nhnvt-scheme) | NVT, Nosé-Hoover thermostat | `config_numerical_schemes.msp` |
| [`verlet_nhnpt`](npt_ensemble.md#the-verlet_nhnpt-scheme) | NPT, Nosé-Hoover barostat | `config_numerical_schemes.msp` |

`exaStamp`'s own default config sets `numerical_scheme: verlet_nve` — nothing else needs to be included to get plain NVE. Every other row in the table above requires pointing `numerical_scheme` at that scheme explicitly (and, for the Nosé-Hoover rows, including the config file that defines the companion `init_*` operator).

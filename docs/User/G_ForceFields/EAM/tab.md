# **Tabulated EAM**

## **Description**

The `tabeam_force` operator computes a single-species EAM potential whose three functions are given as tables. The pair term $\phi(r)$, the electron density $\rho(r)$ and the embedding function $F(\rho)$, together with their derivatives, are interpolated with cubic splines:

$$
\phi(r) = \mathcal{S}_{\phi}(r), \qquad \rho(r) = \mathcal{S}_{\rho}(r), \qquad F(\rho) = \mathcal{S}_{F}(\rho)
$$

The values and the derivatives are interpolated independently, so the tables must provide consistent derivatives.

See the [EAM overview](index.md) for the total energy and the available operators (`tabeam_force`, `tabeam_emb`, `tabeam_force_reuse_emb`, `tabeam_init`). For multi-species tabulated potentials in the standard setfl format, use [EAM alloy](alloy.md).

The tables are read from a YAML file (searched in the data paths) with the following keys:

<div class="center-table" markdown>

| Key      | Grid    | Description                                 |
| :------- | :------ | :------------------------------------------ |
| `r`      | —       | Distance grid                               |
| `phi`, `dphi` | `r` | Pair term and its derivative              |
| `rho`, `drho` | `r` | Electron density and its derivative       |
| `rhof`   | —       | Electron density grid of the embedding function |
| `f`, `df` | `rhof` | Embedding function and its derivative       |
| `format` | —       | Optional. `exastampv1`: values are plain numbers in SI units (m, J, N) |

</div>

Without `format`, each value is read as a quantity, so units can be given value by value.

## **YAML syntax**

```yaml
tabeam_force:
  rcut: VALUE UNITS
  parameters: FILENAME
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.
- [x] FILENAME = YAML file with the tables. `parameters: { file: FILENAME }` is also accepted, and so are the tables given directly under `parameters`.

## **Usage example**

!!! example "**Copper (tabulated Sutton–Chen)**"
    ```yaml
    tabeam_force:
      rcut: 7.29 ang
      parameters: tab_sc.yaml

    compute_force: tabeam_force
    ```

`tab_sc.yaml` is shipped in `exaStamp/data/potentials/`. The complete input is `exaStamp/data/regression_new/potentials/eam/eam_tab/single_specy.msp`. This potential runs on CPU only.

# **Tabulated pair**

## **Description**

The `tabpair_compute_force` operator interpolates a pair potential given as a table. The table gives, on a set of distances $r_k$, the energy $E(r_k)$ and its derivative $\mathrm{d}E/\mathrm{d}r\,(r_k)$. Both are interpolated with cubic splines:

$$
E(r) = \mathcal{S}_E(r), \qquad \frac{\mathrm{d}E}{\mathrm{d}r}(r) = \mathcal{S}_{dE}(r) \quad \text{for} \quad r<r_c
$$

The energy and the derivative are interpolated independently, so the table must provide a consistent derivative.

The table is read from a YAML file (searched in the data paths) or given inline. It contains three lists of the same length:

<div class="center-table" markdown>

| Key      | Units        | Description                                                  |
| :------- | :----------: | :----------------------------------------------------------- |
| `r`      | distance     | Distances $r_k$, in increasing order                         |
| `e`      | energy       | Energy $E(r_k)$                                              |
| `de`     | energy/distance | Derivative $\mathrm{d}E/\mathrm{d}r$ at $r_k$             |
| `format` | —            | Optional. `exastampv1`: values are plain numbers in SI units (m, J, N) |

</div>

Without `format`, each value is read as a quantity, so units can be given value by value (`2.5 ang`, `0.01 eV`, ...). Values without units are taken in internal units.

## **YAML syntax**

```yaml
tabpair_compute_force:
  rcut: VALUE UNITS
  parameters: { file: FILENAME }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.
- [x] FILENAME = YAML file with the `r`, `e` and `de` lists. `parameters: FILENAME` is also accepted.

Inline data can be given instead of a file:

```yaml
tabpair_compute_force:
  rcut: 5.0 ang
  parameters:
    r:  [ 2.0 ang , 2.5 ang , ... ]
    e:  [ 1.2 eV , 0.3 eV , ... ]
    de: [ -5.1 eV/ang , -1.0 eV/ang , ... ]
```

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    tabpair_compute_force:
      parameters: { file: "lj_tab.yml" }
      rcut: 5.68 ang

    # Symetric variant
    tabpair_compute_force_symetric:
      parameters: { file: "lj_tab.yml" }
      rcut: 5.68 ang
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    tabpair_multi_force:
      rcut: 5.68 ang
      common_parameters: { file: "lj_tab.yml" }
      parameters:
        - { type_a: Zn , type_b: Zn , rcut: 5.68 ang , parameters: { file: "lj_tab.yml" } }
        - { type_a: Cu , type_b: Zn , rcut: 5.68 ang , parameters: { file: "lj_tab.yml" } }
    ```

!!! note

    `lj_tab.yml` (a tabulated Lennard-Jones potential, `exastampv1` format) is shipped in `exaStamp/data/potentials/`. The tabulated pair potential runs on CPU only.

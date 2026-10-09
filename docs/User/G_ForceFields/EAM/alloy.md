# **EAM alloy**

## **Description**

The `eam_alloy_force` operator computes a multi-species tabulated EAM potential read from a file in the standard DYNAMO *setfl* format (`.eam.alloy` files). For an atom $i$ of species $\alpha$ surrounded by atoms $j$ of species $\beta$:

$$
E_i = F_\alpha\left(\sum_{j \neq i} \rho_\beta(r_{ij})\right) + \frac{1}{2}\sum_{j \neq i} \phi_{\alpha\beta}(r_{ij})
$$

The file gives, on regular grids, the embedding function $F_\alpha(\rho)$ and the electron density $\rho_\alpha(r)$ of each element, and the products $r\,\phi_{\alpha\beta}(r)$ for each pair of elements. They are interpolated with cubic splines. Energies are in eV and distances in Å in the file.

**setfl format**

```text
line 1-3   comments
line 4     N  elem_1 ... elem_N
line 5     Nrho  drho  Nr  dr  rcut
           for each element:
             Z  mass  lattice_constant  lattice_type
             F(rho)   (Nrho values)
             rho(r)   (Nr values)
           for each pair (i >= j):
             r*phi(r) (Nr values)
```

!!! warning "Element order"

    Elements are matched **by position**: the first element of the file is used for the first species declared in the `species` block, and so on. Declare the species in the same order as the elements of the file. At most 7 species are supported.

## **Operators**

<div class="center-table" markdown>

| Operator | Description |
| :------- | :---------- |
| `eam_alloy_force` | EAM computation, as a single pass or split into passes (see below) |
| `eam_alloy_init`  | Reads the `parameters` once (typically in `init_parameters`) |

</div>

```{ .yaml title="Syntax" .syntax-block }
eam_alloy_force:
  rcut: <float>
  parameters: { file: <string> }
  types: [<string>, ...]
  eam_rho: <bool>
  eam_rho2emb: <bool>
  eam_ghost: <bool>
  eam_force: <bool>
  eam_symmetry: <bool>
```

```{ .yaml title="Parameters" .params-block }
rcut:          float, required          # Cutoff radius (use the cutoff of the file).
parameters:    map, required            # { file: <name> } or the file name alone; searched in the data paths.
types:         list of strings, default [] # Species handled by this potential. Empty means all species.
eam_rho:       bool, default true       # Pass 1: accumulate the electron density rho_i.
eam_rho2emb:   bool, default true       # Pass 2: evaluate F(rho_i) (energy) and F'(rho_i).
eam_ghost:     bool, default true       # Also run passes 1-2 on ghost atoms, so no communication is needed before pass 3. Requires a ghost layer of 2 x rcut.
eam_force:     bool, default true       # Pass 3: forces and pair energy.
eam_symmetry:  bool, default false      # Use half neighbor lists (each pair computed once).
```

With the default values, `eam_alloy_force` does everything in a single call. The intermediate value is stored in the particle field `rho_dEmb`.

## **Usage examples**

!!! example "**Single pass**"
    ```yaml
    species:
      - Al: { mass: 26.982 Da , z: 13 , charge: 0 e- }
      - Cu: { mass: 63.546 Da , z: 29 , charge: 0 e- }

    eam_alloy_force:
      rcut: 6.6825 ang
      parameters:
        file: AlCu.eam.alloy

    compute_force: eam_alloy_force
    ```

!!! example "**Split passes, ghost layer of one cutoff**"
    The parameters are read once in `init_parameters` and shared by the three calls through a `rebind`. `rho_dEmb` is exchanged with the neighbor processes before the force pass.

    ```yaml
    init_parameters:
      rebind: { parameters: eam_alloy_parameters }
      body:
        - eam_alloy_init:
            parameters: { file: "AlCu.eam.alloy" }

    eam_rho:
      - eam_alloy_force: { rcut: 6.6825 ang , eam_rho: true  , eam_rho2emb: false , eam_ghost: false , eam_force: false }
    eam_rho2emb:
      - eam_alloy_force: { rcut: 6.6825 ang , eam_rho: false , eam_rho2emb: true  , eam_ghost: false , eam_force: false }
    eam_force:
      - eam_alloy_force: { rcut: 6.6825 ang , eam_rho: false , eam_rho2emb: false , eam_ghost: false , eam_force: true }

    compute_force:
      rebind: { parameters: eam_alloy_parameters }
      body:
        - eam_rho
        - eam_rho2emb
        - ghost_update_opt: { opt_fields: [ "rho_dEmb" ] }
        - eam_force
    ```

The setfl files `AlCu.eam.alloy`, `Cu.eam.alloy`, `Sn.eam.alloy`, `Ta.eam.alloy`, `Ta1_Ravelo_2013.eam.alloy` and `Ta2_Ravelo_2013.eam.alloy` are shipped in `exaStamp/data/potentials/`. Single-pass, split and symmetric (`eam_symmetry: true`) setups are in `exaStamp/data/regression_new/potentials/eam/eam_alloy/` (see `benchmark_Al_Cu.msp` for all of them in one file).

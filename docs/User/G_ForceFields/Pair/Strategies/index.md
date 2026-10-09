# **Strategies**

Pair potentials can be used in multiple ways in **exaStamp**. Depending on whether a single specy or multiple species are present in the system, one can use different variants of a pair potential or even mix them. Every pair potential `X` (where `X` is `lj`, `buckingham`, `zbl`, ...) provides the following operators:

<div class="center-table" markdown>

| Operator                 | Use                                                                  |
| :----------------------- | :------------------------------------------------------------------- |
| `X_compute_force`        | One set of parameters for all atoms                                  |
| `X_compute_force_symetric` | Same, each pair is computed once and the force is applied to both atoms |
| `X_multi_force`          | One set of parameters per pair of species                            |
| `X_rigidmol_force`       | Rigid molecules (only for some potentials, see each model page)      |
| `X_plot`                 | Writes $r$, $E(r)$, $\mathrm{d}E/\mathrm{d}r$ and a finite-difference check of $\mathrm{d}E/\mathrm{d}r$ to a text file (`file`, default `X.csv`), for `samples` points up to `rcut` |

</div>

## **Single specy**  

!!! example "**Example: Basic usage of a pair potential**"
      
    ```yaml
    lj_compute_force:
      parameters: { epsilon: 0.0104 eV , sigma: 3.4 ang }
      rcut: 8.0 ang
  
    compute_force: lj_compute_force
    ```
  
!!! example "**Example: Symmetric variant of a pair potential**"
      
    ```yaml
    lj_compute_force_symetric:
      parameters: { epsilon: 0.0104 eV , sigma: 3.4 ang }
      rcut: 8.0 ang
  
    compute_force: lj_compute_force_symetric
    ```

## **Multiple species**  
  
!!! example "**Example: Multiple species variant of a pair potential**"
      
    ```yaml
    lj_multi_force:
      rcut: 8. ang
      common_parameters: { epsilon: 0.0 , sigma: 0.0 }
      parameters:
        - { type_a: Zn , type_b: Zn , rcut: 6.10 ang , parameters: { epsilon: 2.522E-20 J , sigma: 0.244E-09 m } }
        - { type_a: Cu , type_b: Zn , rcut: 5.89 ang , parameters: { epsilon: 4.853E-20 J , sigma: 0.236E-09 m } }
  
    compute_force: lj_multi_force
    ```

`common_parameters` is optional: it gives the parameters of the species pairs that are not listed in `parameters`.
  
## **Mixing pair potentials**  
        
In the presence of multiple types in the simulated sample, the `compute_force_pair_multimat` operator assigns a different pair potential to each pair of species. Each entry of `potentials` gives the two species, the potential name (`lj`, `buckingham`, `exp6`, `zbl`, `coul_rf`, ... — the same names as the operator prefixes), its cutoff and its parameters. Species pairs that are not listed get a zero potential.

!!! example "**Example: Mixing pair potentials**"
      
    ```yaml
    compute_force_pair_multimat:
      potentials:
        - { type_a: Si , type_b: Cu , potential: lj , rcut: 5.89 ang , parameters: { epsilon: 1.0 eV , sigma: 2.3 ang } }
        - { type_a: Si , type_b: Zn , potential: buckingham , rcut: 7.10 ang , parameters: { A: 1.3 eV , Rho: 1.2 ang , C: 1.5 eV*ang^6 } }
        - { type_a: Cu , type_b: Zn , potential: exp6 , rcut: 12.5 ang , parameters: { A: 37111.29 Da*kcal/g , B: 3.46350030 1/ang , C: 484.2991571 Da*kcal*ang^6/g , D: 5.0e-5 Da*kcal/g } }

    compute_force: compute_force_pair_multimat
    ```

```{ .yaml title="Parameters" .params-block }
potentials:          list, required        # { type_a, type_b, potential, rcut, parameters } for each species pair.
ghost:               bool, default false   # Also compute forces on ghost atoms.
enable_pair_weights: bool, default true    # Apply intramolecular pair weights when they exist.
symetric:            bool, default false   # Not supported: the simulation aborts if true.
```

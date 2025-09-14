# **Strategies**

Pair potentials can be used in multiple ways in **exaStamp**. Depending on whether a single specy or multiple species are present in the system, one can use different variants of a pair potential or even mix them. Below is a rapid presentation of these variants.

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
  
    compute_force: lj_compute_force
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
  
    compute_force: lj_compute_force
    ```
  
## **Mixing pair potentials**  
        
In the presence of multiple types in the simulated sample, and when applicable, the potentials defined hereafter may be used using the following formalism:

!!! example "**Example: Multiple species variant of a pair potential**"
      
    ```yaml
    compute_force_pair_multimat:
      potentials:
        - { type_a: Si , type_b: Cu , potential: lj , rcut: 5.89 ang , parameters: { epsilon: 1.0 eV , sigma: 2.3 ang } }
        - { type_a: Si , type_b: Zn , potential: buckingham , rcut: 7.10 ang , parameters: { A: 1.3 eV, Rho: 1.2 ang, C: 1.5 eV*ang^6} }
        - { type_a: Si  , type_b: Zn, potential: exp6, rcut: 12.5 ang, parameters: { A:  37111.29 Da*kcal/g, B: 3.46350030 1/ang, C: 484.2991571 Da*kcal*ang^6/g, D: 5.0e-5 Da*kcal/g } }  
    compute_force: lj_compute_force
    ```

# **Defining the interatomic potential**
    
In **exaStamp**, the interatomic potential or force field to be user during the simulation is simply defined by the `compute_force` operator. This operator is by definition a list of operators associated to a single or multiple instances of interatomic potentials. See a generic usage example below.

!!! example
      
    ```yaml
    # Single potential
    compute_force: potential_1
    compute_force:
      - potential_1

    # Multiple potentials
    compute_force: [ potential_1, potential_2, potential_1 ]
    compute_force:
      - potential_1
      - potential_2
      - potential_3
    ```
where `potential_1`, `potential_2` and `potential_3` can be different interatomic potentials or any operator that affects the atomic forces such as a Langevin thermostat for example.
    
Below are links (you can also access them using the left table of contents) to all types of interatomic potentials available in the code:

- [**Pair Potentials**](Pair/index.md)
- [**Embedded Atom Model (EAM)**](EAM/index.md)
- [**Modified EAM**](MEAM/index.md)
- [**Reactive potentials**](Reactive/index.md)
- [**Machine Learning Interatomic potentials (MLIP)**](MLIP/index.md)
- [**Electrostatic potentials**](Electrostatics/index.md)
- [**Intramolecular potentials**](Intramolecular/index.md)
  
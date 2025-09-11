# MultiPhysics Coupling Scheme

For `SLOTH`, the time loop of all multiphysics simulations is managed by the C++ object [`TimeDiscretization`](Time/index.md).

Figure 1 schematically represents a time-step of a `SLOTH` multiphysics simulations.

<figure markdown="span">
  ![Time-step](../../../img/TimeDiscretization.png){  width=800px}
  <figcaption>Figure 1 : Schematic description of one time-step for `SLOTH` simulations
</figcaption>
</figure>

It consists of two nested loops.

The first loop corresponds to solving a set of [Couplings](Couplings/index.md) using a partitioned algorithm.

For each coupling, there is an inner loop over a set of [Problems](Problems/index.md), each solved either with a partitioned or a monolithic algorithm. 

Depending on the simulation, users can also activate [Convergence](Convergence/index.md) criteria.


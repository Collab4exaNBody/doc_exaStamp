# Convergence

Definition of convergence criteria for `SLOTH` is made with a C++ object of type `Convergence` which is a collection of C++ objects of type `PhysicalConvergence`.

Currently, the `Convergence` object enables to find the steady solution from a transient calculation. 

For this purpose, it must be added to the list of parameters when defining the [problem](../Problems/index.md).

The number and order of `PhysicalConvergence` objects defining a `Convergence` object must match the number and order of the `Variable` objects collected in the `Variables`object of the problem.

The `PhysicalConvergence` objects are defined by:

- a type of criterion: the maximum of the absolute (`ConvergenceType::ABSOLUTE_MAX`) and/or relative (`ConvergenceType::RELATIVE_MAX`) error between two successive time-steps
- a threshold (type `double`)


!!! example "Definition of a problem with two unknowns and a `Convergence` object"

    This example assume a simulation based on a problem defined with a fictitious `Operator` (see `my_operator`), `Variables` (see `my_variables`) and `PostProcessing` (see `my_post_processing`). 
 
    For this problem, there are two variables `phi` and `mu`.

    Two `PhysicalConvergence` objects are then defined to find the steady solution from a transient calculation. When both convergence criteria are satisfied, the calculation stops normally.

    ```c++

    auto phi_cvg = PhysicalConvergence(ConvergenceType::ABSOLUTE_MAX, 1.e-12);
    auto mu_cvg = PhysicalConvergence(ConvergenceType::ABSOLUTE_MAX, 1.e-7);

    auto conv_criteria = Convergence(phi_cvg, mu_cvg);

    Problem<OPE, VARS, PST> my_problem(my_operator, my_variables, my_post_processing, conv_criteria);
    ```

!!! note "On the use of `Convergence` objects"
    From now, the `Convergence` objecs are only used to find steady solution from a transient calculation. 
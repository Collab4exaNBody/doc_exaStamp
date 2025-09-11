# _"The remainder"_ 

_"The remainder"_ refers to everything that is neither PDEs nor 0D problems, such as the computation of physical properties or the update of variables (_e.g._ $`c\sim f(\mu)`$ in the grand potential formulation of phase-field model).

The `SLOTH` development team recommends using `Property_problem`. 
This is a template class instantiated with three template parameters: first, an `PROPERTY` object, second, the `Variables` object (see `VARS`in the example), and third, the `Postprocessing` object (see `PST` in the example).

!!! example "Alias declaration for `Property_problem` class template"
    ```c++
    using PropertyProblem = PropertyProblem<PROPERTY, VARS, PST>;
    ```

The users are referred to dedicated pages of the user manual for details about [Variables](../../../Variables/index.md) and [PostProcessing](../../../PostProcessing/index.md).

The `PROPERTY` object in `Property_problem` corresponds to a C++ object that inherits from the template class `PropertyBase`, only defined with a set of `Parameter` (within a `Parameters` object).

Similar to other types of problems,  `Property_problem` take auxiliary `Variables` as inputs, and primary `Variables` as outputs.


!!! example "Defintion of a fictitious `Property_problem`"

    ```c++
    auto property_params = FictitiousProperty(property_params);
    using PropertyProblem = PropertyProblem<FictitiousProperty, VARS, PST>;

    PropertyProblem prop_pb = fictitious_property_problem(
      "Property problem", property_params, outputs_property_var, inputs_property_var);

    ```
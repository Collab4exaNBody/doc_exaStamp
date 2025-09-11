# 0D problems

Currently, only CALPHAD problems are available as 0D models. 
 
## __CALPHAD problems__ {#calphad}

Definition of CALPHAD problems for `SLOTH` is made with a C++ object of type `Calphad_Problem`. 

`Calphad_Problem` is a template class instantiated with three template parameters: first, a CALPHAD object, second, the `Variables` object, and third, the `Postprocessing` object.

!!! example "Alias declaration for `Calphad_Problem` class template"
    ```c++
    using CalphadProblem = Calphad_Problem<CALPHAD, VARS, PST>;
    ```


`Calphad_Problem` objects are defined by

- a collection of parameters (`SLOTH` type `Parameters'),
- a collection of primary variables (`SLOTH` type `Variables'),
- a post-processing (`SLOTH` type `PostProcessing`),
- auxiliary variables  (`SLOTH` type `Variables').

The parameters will be defined later on this page. Here, the focus is made on the variables. It is important to keep in mind that the inputs of the `Calphad_Problem` are the auxialiary variables whereas the outputs correspond the primary variables (see the [dedicated page of the manual](../../../Variables/index.md) for more details about `Variable` objects).

The inputs are the initial conditions expressed in terms of temperature, pressure and composition. When performing multiphysics simulations involving heat transfer, mass diffusion and CALPHAD calculations, it is often preferable to use separate auxiliary variables rather than a single and unified collection of variables within one `Variables` object.

!!! example "Definition of a fictitious  `Calphad_Problem`"
    ```c++
    auto  my_calphad_problem = CalphadProblem(params, outputs, calphad_pst, T, P, composition);
    ```
    In this example, a fictitious `Calphad_Problem`is defined with `Parameters` (see `params`), outputs (primary `Variables`) and inputs (auxiliary `Variables`, here T, P, composition)

All `Calphad_problems` share a set of optional output variables. For each variable, additional information must be provided in accordance with the semantics summarized in the table 1.

| Property                                           | Symbol               | Additional information order                |
| -------------------------------------------------- | -------------------- | ------------------------------------------- |
| chemical potentials                                | `mu`                 | (element, symbol)                           |
| diffusion chemical potentials                      | `dmu`                | (element, symbol)                           |
| mole fraction of phase                             | `xph`                | (phase, symbol)                             |
| element mole fraction by phase                     | `x`                  | (phase, element, symbol)                    |
| site fraction by sublattice by phase               | `y`                  | (species, sublattice number, phase, symbol) |
| (molar) Gibbs energy and (molar) enthalpy of phase | `g`, `gm`, `h`, `hm` | (phase, symbol)                             |
| driving forces                                     | `dgm`                | (phase, symbol)                             |
| heat capacity                                      | `cp`                 | (symbol)                                    |
| mobilities                                         | `mob`                | (phase, element, symbol)                    |
| nucleus                                            | `nucleus`            | (phase,symbol)                              |
| error equilibrium                                  | `error`              | (symbol)                                    |
*__Table 1__ - Semantics for defining the additional information of CALPHAD `Variables`*


!!! warning "On the use of additional information for CALPHAD output variables"
    - Additional information must always be provided as specified in the table 1
    - The last additional information is always the _symbol_ associated with the variable. 

!!! example "Defining fictitious CALPHAD variables"
    The following example consider a binary system U-O in a LIQUID-SOLID mixture. 
    Five `Variable` objects are defined and collected within a `Variables` object. 
    
    ```c++
    // Oxygen chemical potential
    auto muo = VAR(&spatial, bcs, "muO", level_of_storage, 0.);
    muo.set_additional_information("O", "mu");

    // Oxygen mobility in the phase SOLID
    auto mobO = VAR(&spatial, bcs, "Mo", level_of_storage, 0.);
    mobO.set_additional_information("SOLID", "O", "mob");

    // Molar fraction of the phase LIQUID
    auto xph_l = VAR(&spatial, bcs, "xph_l", level_of_storage, 0.);
    xph_l.set_additional_information("LIQUID", "xph");

    // Site fraction of the cation U+3
    auto yu = VAR(&spatial, bcs, "yu+3", level_of_storage, 0.);
    yu.set_additional_information("U+3", "0", "SOLID", "y");

    // Gibbs energy
    auto gl = VAR(&spatial, bcs, "g_l", level_of_storage, 0.);
    gl.set_additional_information("LIQUID", "g");

    auto calphad_outputs = VARS(muo, mobO, xph_l, yu, gl);

    ```    

At this stage, the `CALPHAD` object in `Calphad_Problem` remains to be defined. It corresponds to a `SLOTH` C++ object that inherits from the  template class `CalphadBase<mfem::Vector>`. It specializes the model to calculate thermodynamic properties. 

Depending on the simulation, three kind of `CALPHAD` models are currently available:

- [a Gibbs Energy Minimizer](gem)
- [an analytical thermodynamic model](analytical)
- [metamodels](ia)

Users will find on this page all information to define and use these `CALPHAD` models. 

### __Gibbs Energy Minimizer (GEM)__ {#gem}

A generic software interface is available for users who want to couple `SLOTH` with their own GEM.

The `SLOTH` development team remains available to provide first-level support to any user wishing to interface their own GEM (provided it is compatible with the `SLOTH` license).

!!! remark "Coupling between SLOTH and OpenCalphad"
    The CEA has developed under a proprietary license a software interface to the OpenCalphad thermodynamic solver[@sundman14][@sundman15].  
    The source code is not available to unauthorized users. 
 
### __Analytical thermodynamic model__ {#analytical}

In many multiphysics simulations involving thermodynamic equilibrium calculations, the thermodynamic description relies on analytical formulas.

This capability is illustrated in `SLOTH` with the object `AnalyticalIdealSolution<mfem::Vector>`, which computes the Gibbs free energy and the chemical potential for an ideal-solution phase.

```math
\begin{align}
g(x,T)&= R T (x ln(x) + (1.0 - x) ln(1.0 - x))
\end{align}
```

where $`R`$ is the  molar gas constant, $`T`$ the temperature and $`x`$ the molar fraction.

!!! warning "On the use of the `AnalyticalIdealSolution` object"    
    The `AnalyticalIdealSolution<mfem::Vector>` object is mainly intended for code analyses involving `Calphad_Problem` and as an example to guide users in building and using a `CALPHAD` model. 

!!! example "Definition of a `Calphad_Problem` based on `AnalyticalIdealSolution<mfem::Vector>`"
    In this example, a fictitious `Calphad_Problem` based on `AnalyticalIdealSolution<mfem::Vector>` is defined with `Parameters` (see `calphad_parameters`), outputs (primary `Variables`) and inputs (auxiliary `Variables`, here T, P, composition)
    
    ```c++
    Calphad_Problem<AnalyticalIdealSolution<mfem::Vector>, VARS, PST>  my_calphad_problem = CalphadProblem(calphad_parameters, outputs, calphad_pst, T, P, composition);
    
    ```


### __Metamodels__ {#ia}

SLOTH can also be linked to the [libtorch library](https://pytorch.org) to use serialized `PyTorch` models for approximating the behavior of a GEM. 

`CalphadInformedNeuralNetwork<mfem::Vector>` is an object developed to compute mobilities, chemical potentials, 
Gibbs free energy, and enthalpy for unary to n-ary systems either in a single phase or in a two phase mixture. 
This list of predicted thermodynamic quantities could be extended. 

Users can either employ a dedicated neural network for each thermodynamic quantity or use a single neural network for all properties.

!!! warning "On the use of several metamodels"
    All metamodels must share the same input variables, provided in the same order.

    

The parameters associated with `CalphadInformedNeuralNetwork<mfem::Vector>` are detailed in the table 3.

| Parameter Name                           | Type                 | Default Value | Description                                                              |
| ---------------------------------------- | -------------------- | ------------- | ------------------------------------------------------------------------ |
| `"ChemicalPotentialsNeuralNetwork"`      | [`vTupleStringString`](../../../Parameters/index.md) |               | Name of the serialized `PyTorch` model for chemical potentials by phase  |
| `"ChemicalPotentialsNeuralNetworkIndex"` | [`vTupleStringInt`](../../../Parameters/index.md)    |               | Index of the first chemical potential in the metamodel outputs, by phase |
| `"MobilitiesNeuralNetwork"`              | [`vTupleStringString`](../../../Parameters/index.md) |               | Name of the serialized `PyTorch` model for mobilities                    |
| `"MobilitiesNeuralNetworkIndex"`         | [`vTupleStringInt`](../../../Parameters/index.md)    |               | Index of the first mobility in the metamodel outputs, by phase           |
| `"EnergiesNeuralNetwork"`                | [`vTupleStringString`](../../../Parameters/index.md) |               | Name of the serialized `PyTorch` model for Gibbs energy and enthalpy     |
| `"EnergiesNeuralNetworkIndex"`           | [`vTupleStringInt`**](../../../Parameters/index.md)    |               | Index of the first energy in the metamodel outputs, by phase             |
| `"InputEnergiesOrder"`                   | [`vString`](../../../Parameters/index.md)            |               |  Order of the energy potentials in the metamodel outputs (_e.g._ `{"G","H"}`)                                                                        |
| `"InputCompositionOrder"`                | [`vString`](../../../Parameters/index.md)            |               |  Order of the elements in the metamodel inputs (_e.g._ `{"O","PU", "U"}`)                                                                        |
| `"ModelBuiltWithPressure"`               | `bool`               |  `True`             | Flag to indicate if the pressure is an input of the metamodel                                                                          |
| `"OwnMobilityModel"`                     | `bool`               |  `True`             |  Flag to indicate if a different metamodel is used for mobilities                                                                                                                                   |
| `"OwnEnergyModel"`                       | `bool`               |  `True`             |     Flag to indicate if a different metamodel is used for energies                                                                     |
| `"InputCompositionFactor"`               | `double`             | `1.0`          |  By default, initial composition is expressed in terms of molar fractions of  elements. This parameter should be used when the metamodels are built with moles.                                                                        |
| `"GivenPhase"`                           | `std::string`        | `""`          |     When working for a single phase, its name is given by this paramter.
| `"element_removed_from_nn_inputs"`       | `std::string`        |               |     By default, initial composition is expressed in terms of molar fraction of elements. This parameter should be used to define the element deduced from other thanks to the relation $`\sum_{i} x_i=1`$ |
*__Table 3__ - Parameters associated with `CalphadInformedNeuralNetwork`*


!!! warning "Inputs of metamodels"
    The inputs of the metamodels are assumed to be the temperature, the pressure (if used during the construction of the metamodels), and the composition.

!!! example "Definition of a `Calphad_Problem` based on `CalphadInformedNeuralNetwork<mfem::Vector>`"

    This example assume that metamodels are used to approximate chemical potentials and mobilities for the U-Pu-O ternary system in a liquid-solid mixture.

    The serialized `PyTorch`models are named `solid_model.pt` and `liquid_model.pt` for the solid and liquid, respectively.

    The same metamodel is used both for chemical potentials and mobilities in the solid phase. 

    Among the outputs, first chemical potential is found at index $`7`$ for the solid phase and $`4`$ for the liquid phase.
    Regarding the mobilities in the solid phase, first output is found at index $`4`$.

    ```c++
    vTupleStringString CommonNeuralNetwork;
    CommonNeuralNetwork.emplace_back(std::make_tuple("solid_model.pt", "SOLID"));
    CommonNeuralNetwork.emplace_back(std::make_tuple("liquid_model.pt", "LIQUID"));

    auto neural_network_model_mu = Parameter("ChemicalPotentialsNeuralNetwork", CommonNeuralNetwork);
    vTupleStringInt ChemicalPotentialNeuralNetworkIndex;
    ChemicalPotentialNeuralNetworkIndex.emplace_back(std::make_tuple("SOLID", 7));
    ChemicalPotentialNeuralNetworkIndex.emplace_back(std::make_tuple("LIQUID", 4));
    auto index_neural_network_model_mu =
        Parameter("ChemicalPotentialsNeuralNetworkIndex", ChemicalPotentialNeuralNetworkIndex);

    vTupleStringInt MobilitiesNeuralNetworkIndex;
    MobilitiesNeuralNetworkIndex.emplace_back(std::make_tuple("SOLID", 4));

    vTupleStringString MobNeuralNetwork;
    MobNeuralNetwork.emplace_back(std::make_tuple("solid_model.pt", "SOLID"));
    auto neural_network_model_mob = Parameter("MobilitiesNeuralNetwork", MobNeuralNetwork);
    auto index_neural_network_model_mob =
        Parameter("MobilitiesNeuralNetworkIndex", MobilitiesNeuralNetworkIndex);

    std::vector<std::string> composition_order{"O", "PU", "U"};
    auto input_composition_order = Parameter("InputCompositionOrder", composition_order);

    auto own_mobility_model = Parameter("OwnMobilityModel", false);

    auto element_removed_from_nn_inputs = Parameter("element_removed_from_nn_inputs", "PU");

    ```

    These parameters are then collected into a `Parameters` object and use to define the `Calphad_Problem`

    ```c++
    auto calphad_parameters = Parameters(neural_network_model_mu, index_neural_network_model_mu, 
                                         neural_network_model_mob, index_neural_network_model_mob,
                                        own_mobility_model, input_composition_order, 
                                        element_removed_from_nn_inputs) 

    Calphad_Problem<CalphadInformedNeuralNetwork<mfem::Vector>, VARS, PST>  my_calphad_problem = CalphadProblem(calphad_parameters, outputs, calphad_pst, T, P, composition);
    
    ```

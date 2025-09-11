# Post-Processing

This page presents all Post-processing features and describes all parameters with default values.

Definition of a post-processing for `SLOTH` is made with a C++ object of type `PostProcessing`.


`PostProcessing` is a template class instantiated with three template parameters: first, the kind of finite element, second the data format for saving results, and third, the spatial dimension.

The kind of finite element refers to a C++ class that inherits from the `mfem::FiniteElementCollection`. This class manages all collections of finite elements provided by `MFEM`.
Currently, the most commonly used finite element collection in `SLOTH` is `mfem::H1_FECollection`, which corresponds to arbitrary order H1-conforming continuous finite elements.

The dimension is simply an integer that can be 1, 2, or 3.
 
The data format refers to a C++ class that inherits from the `mfem::DataCollection`.  This class manages all collections of data provided by `MFEM`.
The development team primarily uses [`ParaView`](https://www.paraview.org) to visualize results, which corresponds to the `mfem::ParaviewDataCollection` C++ class.

!!! notes "Use of alternative software for visualizing results" 
    Users are free to employ alternative visualization software such as `Visit`.
    In that case, please contact the development team so that an interface to the `mfem::VisitDataCollection` class can be provided.


!!! example "Alias declaration for `PostProcessing` class template"
    ```c++
    using PST = PostProcessing<mfem::H1_FECollection, mfem::ParaviewDataCollection, 2>;
    ```
    This example show how to define a convenient alias for the `PostProcessing` class template instantiated with `mfem::H1_FECollection` and `mfem::ParaviewDataCollection` in dimension 2. 

Without loss of generality, the alias `PST` is used in this page in order to simplify each code snippet.


The `PST` object must be defined by:

- the spatial discretisation (see [Meshing](../SpatialDiscretization/Meshing/index.md)), 
- a set of parameters (see [Parameters](../Parameters/index.md)).

!!! example "Declaration of a `PostProcessing` object"
    ```c++
    auto post_processing = PST(&spatial, pst_parameters);
    ```
    This example show how to declare an object `PST` with the spatial discretisation `spatial` and the paramters `pst_parameters`. 

Each `PST` object is associated with a [`Problem`](../MultiPhysicsCouplingScheme/Problems/index.md) and its [`Variables`](../Variables/index.md) are saved in `Paraview` file.

The parameters allowed with `PostProcessing` for visualizing data with `Paraview` are summarized in table 1.

| Parameter Name | Type | Default Value | Description |
|----------------|------|---------------|---------------|
|  `"main_folder_path"` | `std::string` | | root directory for saving all results |
|  `"calculation_path"` | `std::string` | | directory for saving results of the problem|
|  `"force_clean_output_dir"` | `bool` | `false` | flag to force cleaning of the root directory |
|  `"frequency"` | `int` ||  data output frequency |
|  `"iterations_list"` | `std::vector<int>` | | Iteration indices for data output. Only if frequency is not provided. || 
|  `"times_list"` | `std::vector<double>` | | Times for data output. Only if `"frequency"` is not provided. Can be combined with `"iterations_list"`|

: Table 1 - parameters allowed with `PostProcessing` for visualizing data with `Paraview`


In addition to visualizing `Variables` with `ParaView`, some results can also be exported in `CSV` files format.  

The `time_specialized.csv` file contains:

- The L$`^2`$ and L$`^\infty`$ norms of the error for each variable with an analytical solution,
- The energy density of the problem,
- The surface tension of the problem (for phase-field problems), 
- The spatial average of the variable over the computational domain (if requested with the `integral_to_compute` parameter).

The parameters allowed with `PostProcessing` for exporting specialized values in the `time_specialized.csv` file are summarized in table 2.

| Parameter Name | Type | Default Value | Description |
|----------------|------|---------------|---------------|
| `"enable_save_specialized_at_iter"` | `bool` |false|By default, specialized values are written at end of the simulation. This flag enables to write the values at each time-step.|
 | `"iso_val_to_compute"` | `MapStringDouble` ||Map of isovalue for each variable. The key must match with the name of a `Variable`.|
 | `"integral_to_compute"` | `MapString2Double` ||Map of lower and upper bounds used to compute the average value of each variable. The key must match with the name of a `Variable`.|

: Table 2 - parameters allowed with `PostProcessing` to save specialized values in the `time_specialized.csv` file.

Isovalues are not stored in the `time_specialized.csv` file.
Instead, the parameter `"iso_val_to_compute"` generates separate `CSV` files, one for each variable.

!!! warning "On the dimension of `"iso_val_to_compute"` and `"integral_to_compute"` "
    Parameters `"iso_val_to_compute"` and `"integral_to_compute"` must have exactly the dimension equalt to the  number of variables.


!!! warning "On the lower and upper bounds used with `"integral_to_compute"` "
    Lower and upper bounds are used to limit the calculation of the integral to specific values of the variables. For example, it can be usefull to compute the volume of a bubble that corresponds to a phase indicator lower than $`0.5`$. 

!!! example "Example of `PostProcessing` with parameters"
    The following example assume the existence of a `Variable` named `"phi"` for Cahn-Hilliard equations. 

    The results are saved in the `Saves/CahnHilliard` directory, at each time-step (see `frequency`).  

    Specialized values are also written at each time-step with the average value of `"phi"`.

    ```c++
        const std::string& main_folder_path = "Saves";
        const std::string& calculation_path = "CahnHilliard";
        const int frequency = 1;
        std::map<std::string, std::tuple<double, double>> map_threshold_integral = { {"phi", {-1.1, 1.1}} };
        bool save_specialized_at_iter = true;
        auto pst_parameters = Parameters(
            Parameter("main_folder_path", main_folder_path),
            Parameter("calculation_path", calculation_path), 
            Parameter("frequency", frequency),
            Parameter("integral_to_compute", map_threshold_integral),
            Parameter("enable_save_specialized_at_iter", save_specialized_at_iter));

        auto post_processing = PST(&spatial, pst_parameters);
    ```



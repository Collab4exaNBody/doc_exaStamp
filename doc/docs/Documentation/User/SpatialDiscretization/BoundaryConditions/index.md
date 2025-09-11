# Boundary Conditions
This page described the definition and the use of boundary conditions in `SLOTH`.

Definition of boundary conditions for `SLOTH` is made with a C++ object of type `BoundaryConditions`. As for the object `SpatialDiscretization` (see [Meshing](../Meshing/index.md)), `BoundaryConditions` is a template class instantiated with two template parameters: first, the kind of finite element, and second, the spatial dimension. 

Currently, the most commonly used finite element collection in `SLOTH` is `mfem::H1_FECollection`, which corresponds to arbitrary order H1-conforming continuous finite elements.

The dimension is simply an integer that can be 1, 2, or 3.

!!! example "Alias declaration for `BoundaryConditions` class template"
    ```c++
    using BCS = BoundaryConditions<mfem::H1_FECollection, 3>;
    ```
    This example show how to define a convenient alias for the `BoundaryConditions` class template instantiated with `mfem::H1_FECollection` in dimension 3. This alias is often used in tests in order to simplify the code.

`BoundaryConditions` is roughly defined as a set of C++ object of type `Boundary`. 
Each geometrical boundary must be associated with a C++ object of type `Boundary`.

!!! warning "Number of boundaries"
    The number of `Boundary` objects inside the `Boundaries` object must be equal to the total number of geometrical boundary. 

A `Boundary` object is defined by

- a name (C++ type `std::string'),
- an index (C++ type `int`),
- a type (C++ type `std::string') among "Dirichlet", "Neumann", "Periodic",
- a value (C++ type `double`), equal to zero by default.

!!! warning "Consistency of the indices of the boundaries"
    `MFEM v4.7` provides new features for referring to boundary attribute numbers. Such an improvement is not yet implemented in `SLOTH`. Consequently, users must take care to the consistency of the indices used in the test file with the indices defined when building the mesh with `GMSH`.

!!! example "Defining boundary conditions"
    
    The following examples assume that the spatial discretisation is defined. 
    In the code snippets, it is referred to as a `spatial` object.

    These examples show how to define `Dirichlet`, `Neumann` and `periodic` boundary conditions in a square.

    === "Neumann"
        ```c++
            auto list_boundaries_1 = {Boundary("left", 0, "Neumann", 0.), Boundary("bottom", 1, "Neumann", 0.), Boundary("right", 2, "Neumann", 0.), Boundary("top", 3, "Neumann", 0.)};
            auto bcs_1 = BCS(&spatial, list_boundaries_1);
        ```  

        Non homogeneous Neumann boundary conditions can be defined; however, since they are not part of the `SLOTH` problems studied so far, their implementation has not yet been developed.          

    === "Dirichlet"
        ```c++
            auto list_boundaries_2 =  {Boundary("left", 0, "Dirichlet", 0.), Boundary("bottom", 1, "Neumann", 0.), Boundary("right", 2, "Dirichlet", 1.), Boundary("top", 3, "Neumann", 0.)};
            auto bcs_2 = BCS(&spatial, list_boundaries_2);
        ```

    === "Periodic"
        ```c++
            auto list_boundaries_3 = {Boundary("left", 0, "Periodic"), Boundary("bottom", 1, "Periodic"), Boundary("right", 2, "Periodic"), Boundary("top", 3, "Periodic")};
            auto bcs_3 = BCS(&spatial, list_boundaries_3);
        ```

Once defined, boundary conditions are associated with variables (see [Variables](../../Variables/index.md)). 
The user can define as many boundary conditions as there are variables.
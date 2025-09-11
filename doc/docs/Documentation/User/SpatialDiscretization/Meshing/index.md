# Meshing

Definition of a finite element mesh for `SLOTH` is made with a C++ object of type `SpatialDiscretization`.
`SLOTH` can either read a [`GMSH` mesh file](#gmsh) or use the [meshing functionalities provided by `MFEM`](#mfem).

`SpatialDiscretization` is a template class instantiated with two template parameters: first, the kind of finite element, and second, the spatial dimension.

The kind of finite element refers to a C++ class that inherits from the `mfem::FiniteElementCollection`. This class manages all collections of finite elements provided by `MFEM`.
Currently, the most commonly used finite element collection in `SLOTH` is `mfem::H1_FECollection`, which corresponds to arbitrary order H1-conforming continuous finite elements.

The dimension is simply an integer that can be 1, 2, or 3.

!!! example "Alias declaration for `SpatialDiscretization` class template"
    ```c++
    using SPA = SpatialDiscretization<mfem::H1_FECollection, 3>;
    ```
    This example show how to define a convenient alias for the `SpatialDiscretization` class template instantiated with `mfem::H1_FECollection` in dimension 3. 

Without loss of generality, the alias `SPA` is used in this page in order to simplify each code snippet.


## __Build a mesh from `GMSH` file__ {#gmsh}

`SLOTH` can read a mesh file directly built with `GMSH`.

!!! warning "On the `GMSH` version used to export meshes"
    For compatibility with the `GMSH` file reader provided by `MFEM`, meshes must be exported in **ASCII version 2 format**.


Defining a mesh from `GMSH` involves creating an object of type `SPA` with the following parameters:

1. A string exactly equal to `"GMSH"`,
2. An integer greater than or equal to 1 indicating the order of finite elements,
3. An integer greater than or equal to 0 indicating the level of uniform mesh refinement applied to the initial mesh,
4. A string associated with the name of the `GMSH` mesh file,
5. A boolean to indicate whether the imported mesh is periodic or not.

!!! example "Defining a mesh from `GMSH`"
    ```c++
    const int order_fe = 1;                                // finite element order
    const int refinement_level = 0;                        // number of levels of uniform refinement
    const std::string& filename = "pellet2Dinclusion.msh"; // name of the GMSH file
    bool is_periodic = false;                              // flag to indicate if the imported mesh is periodic

    SPA spatial("GMSH", order_fe, refinement_level, filename, is_periodic);
    ```
    This example demonstrates how to define a mesh from `GMSH`. It uses first-order finite elements without any refinement, and the mesh contained in the "pellet2Dinclusion.msh" file is not periodic.



## __Build a mesh from `MFEM` meshing functionalities__ {#mfem}

`SLOTH` can build a mesh using the meshing functionalities provided by `MFEM`.

Here again, defining a mesh involves creating an object of type `SPA` with the following parameters:

1. A string specifying the type of mesh from the following list:
   
    - `"InlineLineWithSegments"` : 1D mesh composed of segments
    - `"InlineSquareWithTriangles"` : 2D mesh composed of triangles
    - `"InlineSquareWithQuadrangles"` : 2D mesh composed of quadrangles
    - `"InlineSquareWithTetraedres"` : 2D mesh composed of tetrahedra
    - `"InlineSquareWithHexaedres"` : 2D mesh composed of hexahedra

2. An integer greater than or equal to 1 indicating the order of finite elements.
3. An integer greater than or equal to 0 indicating the level of uniform mesh refinement applied to the initial mesh.
4. A C++ object of type `std::tuple` to provide the number of elements and maximum length in each direction.
5. A C++ object of type `std::vector<mfem::Vector>` to provide translations to apply in each direction, if the final mesh is periodic.

The following examples specify the use of these parameters in [1D](#mfem1D), [2D](#mfem2D) and [3D](#mfem3D).

### __1D mesh__ {#mfem1D}

In this example, the domain corresponds to a line of 1 mm. The mesh is composed of 30 segments. There is no mesh refinement and the finite elements are of order 1.

!!! example "Defining a 1D mesh using the meshing functionalities provided by `MFEM`"
    ```c++
    const std::string& mesh_type = "InlineLineWithSegments"; // type of mesh
    const int order_fe = 1;                                  // finite element order
    const int refinement_level = 0;                          // number of levels of uniform refinement
    const std::tuple<int, double>& tuple_of_dimensions = std::make_tuple(30, 1.e-3) ; // Number of elements and maximum length 

    SPA spatial(mesh_type, order_fe, refinement_level, tuple_of_dimensions );
    ```

### __2D mesh__ {#mfem2D}

In these examples, the domain corresponds to a square with a side length of 1 mm. The mesh consists of 30 quadrangles per direction. Triangles can be used by removing `"InlineSquareWithQuadrangles"` by `"InlineSquareWithTriangles"`. There is no mesh refinement, and the finite elements are of order 1.

!!! example "Defining a 2D mesh using the meshing functionalities provided by `MFEM`"
    
    === "Without periodicity"
        ```c++
        const std::string& mesh_type = "InlineSquareWithQuadrangles"; // type of mesh 
        const int order_fe = 1;                                       // finite element order
        const int refinement_level = 0;                               // number of levels of uniform refinement
        const std::tuple<int, int, double, double>& tuple_of_dimensions = std::make_tuple(30, 30, 1.e-3, 1.e-3) ; // Number of elements and maximum length in each direction 

        SPA spatial(mesh_type, order_fe, refinement_level, tuple_of_dimensions );
        ```
    
    === "With periodicity"
        ```c++
        const std::string& mesh_type = "InlineSquareWithQuadrangles"; // type of mesh 
        const int order_fe = 1;                                       // finite element order
        const int refinement_level = 0;                               // number of levels of uniform refinement
        const std::tuple<int, int, double, double>& tuple_of_dimensions = std::make_tuple(30, 30, 1.e-3, 1.e-3) ; // Number of elements and maximum length in each direction 
      
        // Periodicity in x-direction
        mfem::Vector x_translation({1.e-3, 0.0});
        // mfem::Vector y_translation({0.0, 1.e-3});
        std::vector<mfem::Vector> translations = {x_translation};
        // std::vector<mfem::Vector> translations = {x_translation, y_translation};

        SPA spatial(mesh_type, order_fe, refinement_level, tuple_of_dimensions, translations );
        ```

        The initial mesh is transformed to a periodic mesh by specifying a translation in the x-direction. See comments in the example to extend periodicity to the top and bottom boundaries.

### __3D mesh__ {#mfem3D}

In these examples, one considers a cubic domain with a side length of 1 mm. The mesh consists of 30 tetrahedra per direction. Hexahedra can be used by removing `"InlineSquareWithTetraedres"` by `"InlineSquareWithHexaedres"`. There is no mesh refinement, and the finite elements are of order 1.

!!! example "Defining a 3D mesh using the meshing functionalities provided by `MFEM`"
    
    === "Without periodicity"
        ```c++
        const std::string& mesh_type = "InlineSquareWithTetraedres";  // type of mesh 
        const int order_fe = 1;                                       // finite element order
        const int refinement_level = 0;                               // number of levels of uniform refinement
        const std::tuple<int, int, int, double, double, double>& tuple_of_dimensions = std::make_tuple(30, 30, 30, 1.e-3, 1.e-3, 1.e-3) ; // Number of elements and maximum length in each direction 

        SPA spatial(mesh_type, order_fe, refinement_level, tuple_of_dimensions );
        ```
    
    === "With periodicity"
        ```c++
        const std::string& mesh_type = "InlineSquareWithTetraedres"; // type of mesh 
        const int order_fe = 1;                                       // finite element order
        const int refinement_level = 0;                               // number of levels of uniform refinement
        const std::tuple<int, int, int, double, double, double>& tuple_of_dimensions = std::make_tuple(30, 30, 30, 1.e-3, 1.e-3, 1.e-3) ; // Number of elements and maximum length in each direction 

        // Periodicity in one direction
        mfem::Vector x_translation({1.e-3, 0.0, 0.0});
        std::vector<mfem::Vector> translations = {x_translation};
        
        SPA spatial(mesh_type, order_fe, refinement_level, tuple_of_dimensions,  translations);
        ```

        A part of the cubic domain is transformed to a periodic domain by specifying a translation in the targeted direction. 

## __GMSH Split Meshes__

To read directly partitioned meshes, the MFEM miniapps called `mesh-explorer` must be used.

### __Use the Mesh Explorer__

Please refer to the documentation at [https://mfem.org/meshing-miniapps/#mesh-explorer](https://mfem.org/meshing-miniapps/#mesh-explorer).

Below is a simple example of how to partition the `Camembert2D` mesh into four files:

```bash
    spack location -i mfem`/share/mfem/miniapps/meshing/mesh-explorer --mesh camembert2D.msh

    PRESS p // partitioning
    PRESS 1 // metis
    PRESS 4 // number of mpi processes
    PRESS T // Save par
    PRESS "camembert2D." // mesh name
    PRESS 6 // digit
    PRESS q // exit
```

This must generate 4 files named: `camembert2D.000000`, `camembert2D.000000`, `camembert2D.000000`, and `camembert2D.000003`.

### __How to Read the Partitionned Files ?__

To read partitionned files, the pattern of the file name, ending explicitly with `.`, must be specified.

!!! example "Defining a 2D mesh using `GMSH` Split Meshes"

    ```c++
        const int order_fe = 1;                                // finite element order
        const int refinement_level = 0;                        // number of levels of uniform refinement
        const std::string& pattern = "camembert2D.";           // pattern of the file name
        SPA spatial("GMSH", order_fe, refinement_level, pattern, false);
    ```

!!! warning "Number of processes"
    The number of processes must be equal to the number of files, otherwise reading will fail.

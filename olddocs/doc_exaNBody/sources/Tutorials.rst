Tutorials
=========

Add a new plugin
----------------

You can create new plugins if you wish to develop a new set of operators that can be compiled independently of others or require specific plugin compilation. Here's how to define and add a new plugin.

First of all, add your new plugin directory in `src/CMakeLists.txt`:

.. code-block:: bash

   mkdir my_new_plugin
   add_subdirectory(my_new_plugin)
   cd my_new_plugin
   vi CMakeLists.txt

Create a CMakeLists.txt and use the macros defined to plug your operators to exaNBody support such as:

.. code-block:: bash

   set(list_of_plugins_required exanbIO exanbDefBox exanbParticleNeighbors exadem_numerical_scheme exadem_friction exadem_force_field)
   set(exadem_my_new_plugin_LINK_LIBRARIES ${list_of_plugins_required})
   xstamp_add_plugin(exadem_my_new_plugin ${CMAKE_CURRENT_SOURCE_DIR})

Warning: Do not forget to do a `make UpdatePluginDataBase`.

Add a new operator
------------------

Initially, it's crucial to establish a precise definition of the intended kernel, the targeted data, and the method for executing this kernel.

Define your kernel
^^^^^^^^^^^^^^^^^^

We recommend writing the computation kernel (in a functor) in a `.h` file within an `include/exaDEM` folder of your plugin directory. For instance, if one intends to apply gravitational force to a particle, it's necessary to have knowledge of the external force and access to mutators for modifying the force fields. The kernel for a particle is then written in a file `include/exaDEM/gravity_force.h`: 

.. code-block:: cpp

   namespace exaDEM
   {
     struct GravityForceFunctor
     {
       exanb::Vec3d g = { 0.0 , 0.0 , -9.807};
       ONIKA_HOST_DEVICE_FUNC inline void operator () (double mass, double& fx, double& fy, double& fz ) const
       {
         fx += g.x * mass;
         fy += g.y * mass;
         fz += g.z * mass;
       }
     };
   }		

It is possible to provide specific kernel `Traits` that will be used by the data traversal functions (ex: `ComputeCellParticles`). For example, if we want to provide the GPU capabilities for this kernel:

.. code-block:: cpp

   namespace exanb
   {
   template<> struct ComputeCellParticlesTraits<exaDEM::GravityForceFunctor>
     {
       static inline constexpr bool CudaCompatible = true;
     };
   }

Define an operator:
^^^^^^^^^^^^^^^^^^^

To begin with, all operators inherit from the OperatorNode class, where you establish the necessary physical fields for applying your operator. Following that, it's essential to define the slots that will establish the execution graph among operators. Ultimately, you are required to furnish an Execute() function, which the graph will execute, along with a Documentation() function.

This is an example of an empty operator:

.. code-block:: cpp
		
   #include <exaDEM/your_kernel.h>
   namespace exaDEM
   {
     using namespace exanb;
     template<typename GridT
       , class = AssertGridHasFields< GridT, list_of_fields>
       >
     class YourOperator : public OperatorNode
     {
       using ComputeFields = FieldSet< list_of_fields>;
       static constexpr ComputeFields compute_field_set {};
       ADD_SLOT( GridT  , grid     , INPUT_OUTPUT );
     public:

       inline std::string documentation() const override final
       {
         return R"EOF(Your operator.)EOF";
       }

       inline void execute () override final
       {
         YourFunctor func;
         compute_cell_particles( *grid , false , func , compute_field_set , gpu_execution_context() , gpu_time_account_func() );
       }
     };

     template<class GridT> using YourOperatorTmpl = YourOperator<GridT>;

     // === register factories ===  
     CONSTRUCTOR_FUNCTION
     {
       OperatorNodeFactory::instance()->register_factory( "your_operator_name", make_grid_variant_operator< YourOperatorTmpl > );
     }
   }

Comments:
`````````

* Please refers to `src/forcefields/gravity_force.cpp` to illustrate a simple example.
  
* AssertGridHasFields allows to eliminate wrong grids
  
* If `ComputeFields` does not correspond to the input parameters of your functor, the operator can't compile.
  
* ADD_SLOT macro works as `ADD_SLOT(Type, Name, TypeOfSlot, DefaultValue, Documentation)` with:
    * Type: `double`, `int` ...
    * TypeOfSlot: `INPUT`, `OUTPUT` or `INPUT_OUTPUT`
    * Documentation: is a DocString type: `DocString{slot documentation}`
* To access to a slot value, please add `*`.
* Constant value are hidden the operator, for example the gravity functor is initialized as: `GravityForceFunctor func { *gravity};`, gravity is a slot. 
* Note that you need to specify you operator for a given Grid and define the `operator_name` in your dictionnary. 

Comment:
````````

You can do your own traversal function by explicitely iterating over cells. Example:

.. code-block:: cpp
		
   ADD_SLOT( GridT  , grid            , INPUT_OUTPUT );
   inline void execute () override final
   {
     MPI_Comm comm = *mpi;
     auto cells = grid->cells();
     IJK dims = grid->dimension();
     size_t ghost_layers = grid->ghost_layers();
     IJK dims_no_ghost = dims - (2*ghost_layers);
   # pragma omp parallel
     {
       GRID_OMP_FOR_BEGIN(dims_no_ghost,_,loc_no_ghosts)
       {
         IJK loc = loc_no_ghosts + ghost_layers;
         size_t cell_i = grid_ijk_to_index(dims,loc);
         auto& cell_ptr = cells[cell_i];
         const size_t n = cells[cell_i].size();
         auto* __restrict__ _my_field = cell_ptr[field::my_field];
   #     pragma omp simd
         for(size_t j=0;j<n;j++)
           _my_field[j] += 27;
       }
     }
   }

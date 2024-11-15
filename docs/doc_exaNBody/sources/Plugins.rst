List of Plugins
===============

DefBox
------

Operator a
^^^^^^^^^^

Operator b
^^^^^^^^^^

Operator c
^^^^^^^^^^

Core features
-------------

Independently from any loaded plugins, a set of core feature are always available for use.
This includes, but is not limited to, domain description, particle grid, mpi core features, and more.

Domain
^^^^^^

The domain struct holds information about simulation domain size and properties. It is initialized by an operator named "domain" in the YAML input file.
Main domain properties are :

- domain lower and upper bounds
- cell size
- cell grid dimensions
- boundary condtions

Here after is an exemple of domain initialization using the "domain" operator :

.. code-block:: yaml

  domain:
    cell_size: 10.0 ang
    bounds: [ [ 0.0 , 0.0 , 0.0 ] , [ 10.0 , 10.0 , 10.0 ] ]
    periodic: [false,true,true]
    mirror: [ X- ]


Periodic indicates which directions have periodic boundary conditions. Mirror tells wich sides have mirror (reflective) boundary conditions.
A reflective mirror side can be applied on any side of the domain box. A direction with at leat one mirror boundary cannot be periodic, and vice-versa.
As an exemple, if X direction is not periodic, it can have mirror condition and the lower end (X-) and/or the upper end (X+). If user set X to be periodic and add a X-/X+
mirror, X periodicity is disabled automatically. Finally, mirror property is a list of sides on which mirror conditions are applied, among X-, X+, X, Y-, Y+, Y, Z-, Z+ and Z.
mirror sides X is a shortcut for enabling X- and X+ at the same time, so is Y and Z.


Logic
-----

AMR
---

ParticleNeighbors
-----------------

GridCellParticles
-----------------

Cartesian Field Grid
^^^^^^^^^^^^^^^^^^^^

* Operator Name: ``set_cell_values``
* Description: This operator initializes values of a specific cell value field, and creates it if needed. optionally, initialization can be bounded to a specified region, the rest of field beeing set to all 0. This operator can also be used to refine the grid.
* Parameters:

  * region: Region of the field where the value is to be applied.
  * grid_subdiv: Number of (uniform) subdivisions required for this field. Note that the refinement is an octree.
  * field_name: Name of the field.
  * value: List of the values affected to the field.

YAML example:

.. code-block:: yaml

  - set_cell_values:
     field_name: jet
     grid_subdiv: 30
     value: [1, 0, 0, 20]
     region: GEYSERE

IO
--

Extra Storage
-------------

The purpose of this plugin is to add dynamic storage of any type associated with a particle. This package provides the data structure for storage, the associated MPI buffers and operators to move data between grid cells (move particle and migrate cell particles). This package was designed to meet the needs of exaDEM, as friction force values must be preserved from one time step to another. Additionally, this package allows for additional storage in the dump.

To utilize this additional storage, you need to use the data structure *ExtraDynamicDataStorageCellMoveBufferT* with your data type and the slot name *ges* for *grid extra storage*. This structure is a grid of *CellExtraDynamicDataStorageT*, which itself contains an array of your data type (m_data) and a particle information array (m_info) containing the start index in the m_data array, the number of stored data, and the particle index.


.. code-block:: cpp

  template<typename ItemType> struct CellExtraDynamicDataStorageT
  using UIntType = uint64_t;
  using InfoType = ExtraStorageInfo;
  onika::memory::CudaMMVector<InfoType> m_info; /**< Info vector storing indices of the [start, number of items, particle id] of each cell's extra dynamic data in m_data. */
  onika::memory::CudaMMVector<ItemType> m_data; /**< Data vector storing the extra dynamic data for each cell. */

The filling of these data structures is your responsibility; however, it is possible to instantiate an operator to verify that the filling has been done correctly:

.. code-block:: cpp

 namespace exanb
 {
   template<class GridT> using CheckInfoConsistencyYourDataTypeTmpl = CheckInfoConsistency<GridT, GridExtraDynamicDataStorageT<YOUR_DATA_TYPE>>;

   // === register factories ===  
   CONSTRUCTOR_FUNCTION
   {
     OperatorNodeFactory::instance()->register_factory( "check_es_consistency_your_data_type", make_grid_variant_operator< CheckInfoConsistencyYourDataTypeTmpl > );
   }
 }

The following code is an example of how to correctly fill the data structure (type = Interaction):

.. code-block:: cpp

  typedef GridExtraDynamicDataStorageT<Interaction> GridCellParticleInteraction;
  ADD_SLOT( GridT, grid, INPUT_OUTPUT , REQUIRED );
  ADD_SLOT( GridCellParticleInteraction , ges , INPUT_OUTPUT );


.. code-block:: cpp

 auto& g = *grid;
 const auto cells = g.cells();
 const size_t n_cells = g.number_of_cells(); // nbh.size();
 auto & ces = ges->m_data;
 assert( ces.size() == n_cells );
 const IJK dims = g.dimension();
 const int gl = g.ghost_layers();

 #pragma omp parallel
 {
   Interaction item;
   GRID_OMP_FOR_BEGIN(dims-2*gl,_,block_loc, schedule(guided) )
   {
     IJK loc_a = block_loc + gl;
     size_t cell_a = grid_ijk_to_index( dims , loc_a );
     const unsigned int n_particles = cells[cell_a].size();
     auto& storage = ces[cell_a];
     auto& data = storage.m_data;
     auto& info = storage.m_info;
     // auto& history = extract_history(data);
     // You can extract data before initialize.
     storage.initialize(n_particles);
     for(size_t i = 0 ; i < n_particles ; i++)
     {
       // Do some stuff and fill item.
       // You can add several items here.
       auto& [offset, size, id] = info[i];
       size++
       m_data.push_back(item);
			 // you can update the particle offset here.
     }
   }
   GRID_OMP_FOR_END
   // you can fit offsets here instead of in the omp loop. (offset(i) = offset(i-1) + size(i-1))
 }

Warning:
 
  - This package allows for as many external storages as there are types; however, it's not possible to have two additional storages of the same type.
  - Don't forget to adjust the size of this storage to the number of cells in the grid when first using it.
  - This package does not integrate with routines for particle-level calculations such as `compute_cell_particles`.

Tip:

  - Before sending or writing data, consider removing unnecessary information. For example, in DEM, if the friction is equal to (0,0,0), you can overwrite this data to save space. (more details, see in exaDEM `compress_interaction` operator).

Extra Data Checker
^^^^^^^^^^^^^^^^^^

* Operator: `check_es_consistency_double`

  * `Description` : This opertor checks if for each particle information the offset and size are correct
  * `ges` : Your grid of addictionnal data storage. 

YAML example: 

.. code-block:: yaml

 check_es_consistency_double


Migrate Cell Particles With Extra Storage
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Operator: `migrate_cell_particles_double` (example)

  * `Description` : migrate_cell_particles does 2 things:

    - 1. it repartitions the data accross mpi processes, as described by lb_block.
    - 2. it reserves space for ghost particles, but do not populate ghost cells with particles. The ghost layer thickness (in number of cells) depends on ghost_dist. Inputs from different mpi process may have overlapping cells (but no duplicate particles). the result grids (of every mpi processes) never have overlapping cells. The ghost cells are always empty after this operator.

  * `ges` : Your grid of addictionnal data storage. 
  * `bes` : Your buffer used for particles moving outside the box
  * `buffer_size` : Performance tuning parameter. Size of send/receive buffers in number of particles.
  * `copy_task_threshold` :  Performance tuning parameter. Number of particles in a cell above which an asynchronous OpenMP task is created to pack particles to send buffer.
  * `extra_receive_buffers`: Performance tuning parameter. Number of extraneous receive buffers allocated allowing for asynchronous (OpenMP task) particle unpacking. A negative value n is interpereted as -n*NbMpiProcs
  * `force_lb_change` : Force particle packing/unpacking to and from send buffers even if a load balancing has not been triggered
  * `otb_particles` : Particles outside of local processor's grid
* In practice, do not tune this operator yourself.

How to create your operator:

.. code-block:: c++

  #include <exanb/extra_storage/migrate_cell_particles_es.hpp>
  namespace exanb
  {
    template<class GridT> using MigrateCellParticlesYourDataTypeTmpl = MigrateCellParticlesES<GridT, GridExtraDynamicDataStorageT<your_data_type>>;

    // === register factory ===
    CONSTRUCTOR_FUNCTION
    {
      OperatorNodeFactory::instance()->register_factory( "migrate_cell_particles_your_data_type", make_grid_variant_operator<MigrateCellParticlesYourDataTypeTmpl> );
    }
  }

YAML example:

.. code-block:: yaml

  migrate_cell_particles_double

Move Particles With Extra Storage
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Operator: `migrate_cell_particles_double` (example)

  * `Description` : This operator moves particles and extra data storage (es) across cells.
  * `ges` : Your grid of addictionnal data storage.
  * `bes` : Your buffer used for particles moving outside the box
  * `otb_particles` ; Particles outside of local processor's grid
  * In practice, do not tune this operator yourself

How to create your operator:

.. code-block:: c++

  #include <exanb/extra_storage/move_particles_es.hpp>
  namespace exanb
  {
    template<class GridT> using MoveParticlesYourDataTypeTmpl = MigrateCellParticlesWithES<GridT, GridExtraDynamicDataStorageT<your_data_type>>;

    // === register factory ===
    CONSTRUCTOR_FUNCTION
    { 
      OperatorNodeFactory::instance()->register_factory( "migrate_cell_particles_your_data_type", make_grid_variant_operator<MoveParticlesYourDataTypeTmpl> );
    }
  }

YAML example:

.. code-block:: yaml

  move_particles_double

IO Writer With Extra Data
^^^^^^^^^^^^^^^^^^^^^^^^^

There is no operator in exaNBody for writing dump files with storage because you need to explicitly specify the fields to store. However, we propose a non-instantiated templated operator for this purpose. We provide an example with exaDEM and Interaction data type.

.. code-block:: cpp

 #include <exaDEM/interaction/grid_cell_interaction.hpp>
 #include <exanb/extra_storage/sim_dump_writer_es.hpp>
 #include <exanb/extra_storage/dump_filter_dynamic_data_storage.h>

 namespace exaDEM
 {
   using namespace exanb;
   using DumpFieldSet = FieldSet<field::_rx,field::_ry,field::_rz, field::_vx,field::_vy,field::_vz, field::_mass, field::_homothety, field::_radius, field::_orient , field::_mom , field::_vrot , field::_arot, field::_inertia , field::_id , field::_shape >;

   template<typename GridT> using SimDumpWriteParticleInteractionTmpl = SimDumpWriteParticleES<GridT, exaDEM::Interaction, DumpFieldSet>;

   // === register factories ===
   CONSTRUCTOR_FUNCTION
   {
     OperatorNodeFactory::instance()->register_factory( "write_dump_particle_interaction" , make_grid_variant_operator<SimDumpWriteParticleInteractionTmpl> );
   }
 }

For the description of operator slots, see `write_dump_particle_interaction` in exaDEM documentation. Tip: compress extra storage before write dump data file.

YAML example:

.. code-block:: yaml

 dump_data_particles:
   - timestep_file: "exaDEM_%09d.dump"
   - message: { mesg: "Write dump " , endl: false }
   - print_dump_file:
       rebind: { mesg: filename }
       body:
         - message: { endl: true }
   - compress_interaction
   - stats_interactions
   - write_dump_particle_interaction
   - chunk_neighbors_impl 

IO Reader With Extra Data
^^^^^^^^^^^^^^^^^^^^^^^^^

There is no operator in exaNBody for reading dump files with storage because you need to explicitly specify the fields to store. However, we propose a non-instantiated templated operator for this purpose. We provide an example with exaDEM and Interaction data type.

.. code-block:: cpp

 #include <exaDEM/interaction/grid_cell_interaction.hpp>
 #include <exanb/extra_storage/sim_dump_reader_es.hpp>

 namespace exaDEM
 {
   using namespace exanb;
   using DumpFieldSet = FieldSet<field::_rx,field::_ry,field::_rz, field::_vx,field::_vy,field::_vz, field::_mass, field::_homothety, field::_radius, field::_orient , field::_mom , field::_vrot , field::_arot, field::_inertia , field::_id , field::_shape >;

   template<typename GridT> using SimDumpReadParticleInteractionTmpl = SimDumpReadParticleES<GridT, exaDEM::Interaction, DumpFieldSet>;

   // === register factories ===
   CONSTRUCTOR_FUNCTION
   { 
     OperatorNodeFactory::instance()->register_factory( "read_dump_particle_interaction" , make_grid_variant_operator<SimDumpReadParticleInteractionTmpl> );
   }
 }


For the description of operator slots, see `read_dump_paricle_interaction` in exaDEM documentation. 

YAML example:

.. code-block:: yaml

 read_dump_particle_interaction:
    filename: last.dump
    override_domain_bounds: false
    #scale_cell_size: 0.5



MPI
---


Update Ghost Layers
^^^^^^^^^^^^^^^^^^^

* Operator: `ghost_update_r` and `ghost_update_all`
	* `Description` : These operators are in charge of updating ghost zones between two sub-domains and copying the information required at sub-domains boundaries and for periodic conditions. The `ghost_update_r` operator copies the position while `ghost_update_all` copies all fields defined in your grid type.
	* `gpu_buffer_pack` : boolean value [false] to decide if you want to port pack/unpack routines on GPU.
	* `async_buffer_pack` : boolean value [false] triggering to overlap several calls to pack and unpack (send buffers as soon as possibles).
	* `staging_buffer` :  boolean value [false] triggering the copy to a pure CPU buffer before MPI calls (highly recommended if packaging on GPU)
	* `serialize_pack_send` : boolean value [false] triggering to wait that all send buffers are built up before sending the first one.

Example in your msp file:

.. code-block:: yaml

  - ghost_update_r:
     gpu_buffer_pack: true
     async_buffer_pack: true
     staging_buffer: true

Note that you can customize a `ghost_update_XXX` operator for your application such as : 

.. code-block:: c++

	namespace exaDEM
	{
		using namespace exanb;
		using namespace UpdateGhostsUtils;
		// === register factory ===
		template<typename GridT> using UpdateGhostsYourFields = UpdateGhostsNode< GridT , FieldSet<field::_rx, field::_ry, field::_rz , list_of_your_fields > , false >;

		CONSTRUCTOR_FUNCTION
		{
			OperatorNodeFactory::instance()->register_factory( "ghost_update_XXX",     make_grid_variant_operator<UpdateGhostsYourFields> );
		}
	}


MPI Barrier
^^^^^^^^^^^

This operator is used to create synchronization points between MPI processes. In practice, it is utilized to obtain accurate timing information from operators during performance studies. Otherwise, timing accumulate in operators containing MPI collective routines such as `displ_over`.

* Operator : `mpi_barrier`

  * `Description` : Add a MPI_Barrier(MPI_COMM_WORLD).
  * `mpi` : MPI_Comm, default is MPI_COMM_WORLD


YAML Example:

.. code-block:: yaml

     - mpi_barrier



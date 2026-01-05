---
icon: material/export
---

Output
======
     
When it comes to large scale MD simulations it can be very costly to output the entire system to the disk in order to perform post-analysis. ExaNBody offers a way to project particles properties to a regular grid, built on the grid used for paralellism defined by the `cell_size` parameter. One the properties are projected, a few output operators allow to dump the data using ImageData or UnstructuredGrid VTK formats. As for the discrete output operators, everything can be performed in the block `dump_analysis` :

.. code-block:: yaml

   dump_analysis:
     - project_data_to_grid
     - define_timestep_file
     - continuum_output_operator

Here, the `dump_analysis` block contains three distinct operators. The first one allows to perform the data projection using the `atom_cell_projection` operator which takes the following arguments:

* fields = List of strings corresponding to the projected fields onto the regular grid
* grid_subdiv = Subdivision of the parallelism grid
* splat_size = Distance used to project the data onto the regular grid and calculate each particle's contribution to neighboring cells

The user-defined operator `project_data_to_grid` can be defined as follows:

.. code-block:: yaml

   project_data_to_grid:
     - grid_flavor
     - resize_grid_cell_values
     - ghost_update_r_v
     - atom_cell_projection:
         fields: ["mv2", "mass", "vnorm", "f"]
         grid_subdiv: 2
         splat_size: 4.5 ang
         
Where `grid_flavor` sets the type of grid_flavor to use, `resize_grid_cell_values` allows to resize the data structure to the existing grid size to perform properties projections and where `ghost_update_r_v` allows to transfer both positions and velocities to the ghost layers at the domain boundaries and between MPI domains to ensure fields continuity on the projection grid.

The user-defined operator `define_timestep_file` corresponds to the block in which the output file name is defined base on the current iteration as well as some messages that will be printed to the screen when the operator `dump_analysis` is triggered :

.. code-block:: yaml

   define_timestep_file:                
     - timestep_file: "folder/output_%010d"
     - message: { mesg: "Write FILE_OUPTUT " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
       
Finally, we define in the following the different solutions available to replace the `continuum_output_operator` above. The solutions described here only concern continuum output operators, i.e. operators that outputs particles' properties projected onto a regular grid.

write_grid_vtk
--------------

This is a generic operator common to all applications, i.e. ExaDEM, ExaSTAMP and ExaSPH. It allows to dump particles attached properties on a regular grid that covers the entire simulation domain. Beware, this operator outputs a grid that is not scaled on the real simulation domain lengths. It uses the ImageData structure of VTK and therefore consists in a regular parallelepiped. It takes the unique following argument :

* use_point_data = Check what it means.

.. code-block:: yaml

   # Definition of the write_grid_vtk operator
   write_grid_vtk:
     use_point_data: true

write_deformed_grid_vtk
-----------------------

This is also a generic operator common to all applications, i.e. ExaDEM, ExaSTAMP and ExaSPH. It allows to dump particles attached properties on a regular grid that covers the entire simulation domain. This operator generalizes the `write_grid_vtk` operator to dynamically evolving simulation domains. Indeed, it uses the UnstructuredGrid format from VTK and therefore outputs a non-regular parallelepiped that follows the simulation domain shape with time. It is particularly usefull when applyging dynamic deformations to the simulation domain. The units of the output regular grid are the real units of the simulation domain. It takes the unique following argument :

* use_point_data = Check what it means.

.. code-block:: yaml

   # Definition of the write_deformed_grid_vtk operator
   write_deformed_grid_vtk:
     use_point_data: true

Usage examples
--------------

Let's take a simple case of a voided sample.


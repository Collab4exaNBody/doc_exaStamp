Input operators
===============

The present section describes in details the different operators used for simulation's setup, post-analysis, visualization and I/O operations in Molecular Dynamics simulations using exaStamp.

.. code-block:: yaml
                
   input_data:
     - domain
     - init_rcb_grid
     - particle_regions
     - lattice

Simulation domain
-----------------

.. code-block:: yaml
                
   domain:
      cell_size: 5.0 ang
      grid_dims: [20,20,20]
      bounds: [[0 ang ,0 ang,0 ang],[100 ang, 100 ang, 100 ang]]
      xform: [[1.,0.,0.],[0.,1.,0.],[0.,0.,1.]]
      periodic: [true,true,true]
      expandable: false
                
Spatial regions
---------------

quadric or box

.. code-block:: yaml

   example_box:
     - bounds: [ [ 250 ang , 0 ang , 0 ang ] , [ 300 ang , 300 ang , 300 ang ] ]
       
.. code-block:: yaml

   example_quadric:
     - quadric:
         - shape: cylx # or cyly or cylz or sphere or conex or coney or conez or plane
         - transform:
             - scale: [ 15 ang , 15 ang , 15 ang ]
             - xrot: pi/4
             - yrot: pi/3
             - zrot: pi/6             
             - translate: [ 85 ang , 85 ang , 0 ang ]      

.. code-block:: yaml

   CYL9:
     - quadric:
         - shape: cylz
         - transform:
             - scale: [ 15 ang , 15 ang , 15 ang ]
             - xrot: pi/4
             - yrot: pi/3
             - zrot: pi/6             
             - translate: [ 85 ang , 85 ang , 0 ang ]      

Built-in generators
-------------------

Lattice generator
^^^^^^^^^^^^^^^^^

Bulk lattice generator
^^^^^^^^^^^^^^^^^^^^^^

External file readers
---------------------

Readers of xyz File
^^^^^^^^^^^^^^^^^^^

- Name: `read_xyz`
- Description: This operator reads a file written according to the xyz format.
- Parameters:
   * `bounds_mode` : default mode corresponde to ReadBoundsSelectionMode.
   * `enlarge_bounds` : Define a layer around the volume size in the xyz file. Default size is 0.
   * `file` : File name, this parameter is required.
   * `pbc_adjust_xform` : Ajust the form.

Output operators
================

Discrete output operators
-------------------------

In order to post-process or visualize the particles with time, multiple solutions exist in ExaSTAMP. The general operator that defines the output is named `dump_analysis` and can be added as a general YAML block in the simulation input file. In this block, the name of the output files can be defined as well as some log message if needed. These properties are then passed as input to the desired output operator:

.. code-block:: yaml

   dump_analysis:
     - timestep_file: "folder/output_%010d"
     - message: { mesg: "Write FILE_OUPTUT " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - discrete_output_operator

It is to be noted that in the block `dump_analysis` the operator `timestep_file` is called. This operator takes format as an input and automatically generates the variable `filename` that is systematically required by all output operators. If the operator `timestep_file` is not called prior to the output operator, thne the latter requires the `filename` variable to be defined. We define in the following the different solutions available to replace the `discrete_output_operator` above. The solutions described here only concern discrete output operators, i.e. operators that outputs explicitely the particles positions with their attached properties. Other operators, that allow to project particles properties onto regular grids will be described in the section `Continuum output operators`.

write_paraview_generic
^^^^^^^^^^^^^^^^^^^^^^

This is a generic operator common to all applications, i.e. ExaDEM, ExaSTAMP and ExaSPH. It allows to dump particles positions and attached properties in parallel using the vtp format that can be read and processed using ParaView. It takes the following arguments:

* `binary_mode` = allows to write the paraview files in binary mode with a certain compression level. default value: true
* `compression` = compression level for the binary_mode, default value: 'default'. default value: 'default'
* `write_box` = outputs the paraview file that contains the box associated to the domain. default value: 'false'
* `write_ghost` = outputs the ghost particles around the domain. default value: 'false'
* `fields` =  List of strings corresponding to grid fields to dump as particle's attributes. Particles positions and ids are dumped by default.

YAML usage example:

.. code-block:: yaml

   # General dump_analysis operator, called each timestep defined with the anaysis_dump_frequency keyword
   dump_analysis:
     - timestep_file: "paraview/output_%010d"
     - message: { mesg: "Write paraview " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - write_paraview_generic

   # Definition of the write_paraview_generic operator
   write_paraview_generic:
     binary_mode: false
     write_ghost: false
     write_box: true
     fields: ["type", "vx","vy","vz", "ep"]

write_paraview
^^^^^^^^^^^^^^

This is an operator specific to ExaSTAMP and very similar to the operator `write_paraview_generic` that might be deleted soon. It allows to dump particles positions and attached properties in parallel using the vtp format that can be read and processed using ParaView. It takes the following arguments:

* `binary_mode` = allows to write the paraview files in binary mode with a certain compression level. default value: true
* `compression` = compression level for the binary_mode, default value: 'default'. default value: 'default'
* `write_box` = outputs the paraview file that contains the box associated to the domain. default value: 'false'
* `write_ghost` = outputs the ghost particles around the domain. default value: 'false'
* `fields` =  List of strings corresponding to grid fields to dump as particle's attributes. Particles positions and ids are dumped by default.

YAML usage example:

.. code-block:: yaml

   # General dump_analysis operator, called each timestep defined with the anaysis_dump_frequency keyword
   dump_analysis:
     - timestep_file: "paraview/output_%010d"
     - message: { mesg: "Write paraview " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - write_paraview

   # Definition of the write_paraview_generic operator
   write_paraview:
     binary_mode: false
     write_ghost: false
     write_box: true
     fields: ["type", "vx","vy","vz", "ep"]
     
write_xyz
^^^^^^^^^

Allows to dump particles positions, types and ids in a .xyz file. This operator does not allow to dump other attached properties. A Generic xyz file writer will added soon to exaNBody such that all variants ExaDEM, ExaSTAMP, ExaSPH can beneficiate from it.

* Operator name =  `write_xyz`

YAML usage example:

.. code-block:: yaml

   # General dump_analysis operator, called each timestep defined with the anaysis_dump_frequency keyword
   dump_analysis:
     - timestep_file: "xyz/output_%010d"
     - message: { mesg: "Write xyz " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - write_xyz

write_lmp
^^^^^^^^^

Allows to dump particles positions, types and ids in a .lmp file. This operator does not allow to dump other attached properties. A Generic LMP file writer will added soon to exaNBody such that all variants ExaDEM, ExaSTAMP, ExaSPH can beneficiate from it.

* Operator name =  `write_lmp`

YAML usage example:

.. code-block:: yaml

   # General dump_analysis operator, called each timestep defined with the anaysis_dump_frequency keyword
   dump_analysis:
     - timestep_file: "xyz/output_%010d"
     - message: { mesg: "Write xyz " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - write_lmp
       

write_vtklegacy
^^^^^^^^^^^^^^^

This is a generic operator common to all applications, i.e. ExaDEM, ExaSTAMP and ExaSPH. It allows to dump particles positions and all attached grid properties in parallel using the vtp format that can be read and processed using ParaView. It takes the following arguments:

* `ghost` = outputs the ghost particles around the domain. default value: 'false'
* `ascii` = outputs the data in ascii format. default value: 'false'

YAML usage example:

.. code-block:: yaml

   # General dump_analysis operator, called each timestep defined with the anaysis_dump_frequency keyword
   dump_analysis:
     - timestep_file: "paraview/output_%010d"
     - message: { mesg: "Write paraview " , endl: false }
     - print_dump_file:
         rebind: { mesg: filename }
         body:
           - message: { endl: true }
     - write_vtklegacy

   # Definition of the write_paraview_generic operator
   write_vtklegacy:
     ascii: true
     ghost: false
       
     
Continuum output operators
---------------------------

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
^^^^^^^^^^^^^^

This is a generic operator common to all applications, i.e. ExaDEM, ExaSTAMP and ExaSPH. It allows to dump particles attached properties on a regular grid that covers the entire simulation domain. Beware, this operator outputs a grid that is not scaled on the real simulation domain lengths. It uses the ImageData structure of VTK and therefore consists in a regular parallelepiped. It takes the unique following argument :

* use_point_data = Check what it means.

.. code-block:: yaml

   # Definition of the write_grid_vtk operator
   write_grid_vtk:
     use_point_data: true

write_deformed_grid_vtk
^^^^^^^^^^^^^^^^^^^^^^^

This is also a generic operator common to all applications, i.e. ExaDEM, ExaSTAMP and ExaSPH. It allows to dump particles attached properties on a regular grid that covers the entire simulation domain. This operator generalizes the `write_grid_vtk` operator to dynamically evolving simulation domains. Indeed, it uses the UnstructuredGrid format from VTK and therefore outputs a non-regular parallelepiped that follows the simulation domain shape with time. It is particularly usefull when applyging dynamic deformations to the simulation domain. The units of the output regular grid are the real units of the simulation domain. It takes the unique following argument :

* use_point_data = Check what it means.

.. code-block:: yaml

   # Definition of the write_deformed_grid_vtk operator
   write_deformed_grid_vtk:
     use_point_data: true

Usage examples
--------------

Let's take a simple case of a voided sample.

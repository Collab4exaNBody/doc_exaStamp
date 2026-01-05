---
icon: material/export
---

.. _particles-output:

Output
======


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
----------------------

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
--------------

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
---------

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
---------

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
---------------

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
       

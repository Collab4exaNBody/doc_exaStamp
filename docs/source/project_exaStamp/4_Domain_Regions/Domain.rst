Domain
======

Defining all domain parameters
------------------------------

Domain parameters description
*****************************

The simulation domain properties can be fully specified using the domain structure that holds information about the simulation domain size, shape and additional properties. It is initialized by the `domain` operator that can be appended in the YAML input file:
   
.. code-block:: yaml
   :caption: **YAML block for simulation domain definition**

   domain:
     cell_size: 5.0 ang
     grid_dims: [20,20,20]
     bounds: [[0 ang ,0 ang,0 ang],[100 ang, 100 ang, 100 ang]]
     xform: [[1.,0.,0.],[0.,1.,0.],[0.,0.,1.]]
     periodic: [true,true,true]
     expandable: false

.. warning::

   If the user decides to fully define the simulaton domain through this operator, all properties must be consistent with each other. Especially, ``cell_size`` multiplied by ``grid_dims`` must be equal to max(``bounds``) - min(``bounds``).

Below are displayed the different parameters of ``domain`` as well as their types and corresponding examples.

.. list-table:: **Properties for domain definition**
   :widths: 40 40 40
   :header-rows: 1

   * - Property
     - Data Type
     - Example
   * - ``cell_size``
     - float
     - .. code-block:: yaml
             
          cell_size: 3.5 ang
   * - ``grid_dims``
     - IJK
     - .. code-block:: yaml
             
          grid_dims: [20, 20, 20]
   * - ``bounds``
     - AABB
     - .. code-block:: yaml
             
          bounds: [ [0 ang,0 ang,0 ang], [100 ang, 100 ang, 100 ang] ]
   * - ``xform``
     - Mat3d
     - .. code-block:: yaml
             
          xform: [ [1.,0.,0.], [0.,1.,0.], [0.,0.,1.] ]
   * - ``periodic``
     - sequence
     - .. code-block:: yaml
             
          periodic: [true, true, false]
   * - ``mirror``
     - sequence
     - .. code-block:: yaml
             
          mirror: [Z-, Z+]
   * - ``expandable``
     - bool
     - .. code-block:: yaml
             
          expandable: true

We provide a detailed explanation of what the properties enumerated above correspond to:

- ``cell size``: the entire domain is split in multiple cells on which particles are distributed. These cells are then attributed to MPI domains and fed to threads for further calculation,
- ``grid_dims``: this corresponds to the total number of cells in each boundary directions of the simulation domain,
- ``bounds``: this corresponds to the simulation domain bounds. The difference between maximum and minimum values of bounds should strictly be equal to cell_size*grid_dims. If this is not the case, an error will be displayed. 
- ``xform``: this will translate the above information in term of domain physical size and shape. If xform equals the identity matrix, then the physical domain equals the one defined in terms of cells and is perfectly orthorhombic (e.g. if grid_dims: [10,20,30]) or cubic (e.g. if grid_dims: [20,20,20]). If xform is diagonal, then the physical domain equals the one defined in terms of cells scaled by the diagonal components of xform. Finally, if xform contains off-diagonal components, this will generate a non-orthorhombic simulation domain.
- ``periodic``: this property specifies if the three simulation domain directions are associated with periodic of free boundary conditions. Setting a periodic direction to ``true`` indicates that particles passing through the boundary in that direction will be wrapped into the box on the other side and that particles at the boundary interact with the periodic image of the simulation box through the ghost atoms.
- ``mirror``: this property specifies whether a mirror boundary conditions is applied to what side of the simulation domain and in what direction. Setting a boundary using the ``mirror`` property will assign the corresponding reflective boundary conditions. A reflective mirror side can be applied on any side of the domain box. A direction with at least one mirror boundary cannot be periodic, and vice-versa. As an example, if the X direction is not periodic, it can have mirror conditions atboth lower end (X-) and upper end (X+). If the user sets X to be periodic and add a X-/X+ mirror condition, the X periodicity is automatically disabled. The sequence can contain the following values : X-,X+,X,Y-,Y+,Y,Z-,Z+,Z.
- ``expandable``: this boolean allows for the simulation box to automatically expand itself if particles are created or move off the domain boundaries.

Usage examples
**************
  
Multiple examples of domain definitions are provided below.

.. list-table:: **Non expandable 3D-periodic cubic domain with 100 ang side lengths** 
   :widths: 50 50
   :header-rows: 0

   * - .. code-block:: yaml
             
          domain:
            cell_size: 5.0 ang
            grid_dims: [20,20,20]
            bounds: [[0 ang ,0 ang,0 ang],[100 ang, 100 ang, 100 ang]]
            xform: [[1.,0.,0.],[0.,1.,0.],[0.,0.,1.]]
            periodic: [true,true,true]
            expandable: false
     - .. image:: /_static/cubic_domain.png
         :width: 300pt

.. list-table:: **Non expandable 3D-periodic orthorhombic domain with 80, 100 and 120 ang side lengths**
   :widths: 50 50
   :header-rows: 0

   * - .. code-block:: yaml
     
          # 1st solution
          domain:
           cell_size: 5.0 ang
           grid_dims: [16,20,24]
           bounds: [[0 ang ,0 ang,0 ang],[80 ang, 100 ang, 120 ang]]
           xform: [[1.,0.,0.],[0.,1.,0.],[0.,0.,1.]]
           periodic: [true,true,true]
           expandable: false

         # 2nd solution
         domain:
           cell_size: 5.0 ang
           grid_dims: [20,20,20]
           bounds: [[0 ang ,0 ang,0 ang],[100 ang, 100 ang, 100 ang]]
           xform: [[0.8,0.,0.],[0.,1.,0.],[0.,0.,1.2]]
           periodic: [true,true,true]
           expandable: false
     - .. image:: /_static/orthorhombic_domain.png
         :width: 300pt

.. list-table:: **Non expandable 3D-periodic restricted triclinic domain**
   :widths: 50 50
   :header-rows: 0

   * - .. code-block:: yaml
                 
          # 1st solution: restricted triclinic
          # (e.g. **a** is parallel to x and
          # **b** is in the (x,y) plane)
          domain:
            cell_size: 5.0 ang
            grid_dims: [20,20,20]
            bounds: [[0 ang ,0 ang,0 ang],[100 ang, 100 ang, 100 ang]]
            xform: [[1.,0.1,0.2],[0.,1.,0.2],[0.,0.,1.]]
            periodic: [true,true,true]
            expandable: false

     - .. image:: /_static/triclinic_domain.png
         :width: 300pt

.. list-table:: **Non expandable 3D-periodic general triclinic domain**
   :widths: 50 50
   :header-rows: 0

   * - .. code-block:: yaml
                 
          # 2nd solution: general triclinic
          # (e.g. no constraints on **a** or **b**)          
          domain:
            cell_size: 5.0 ang
            grid_dims: [20,20,20]
            bounds: [[0 ang ,0 ang,0 ang],[100 ang, 100 ang, 100 ang]]
            xform: [[1.,0.05,0.1],[0.05,1.,0.1],[0.1,0.1,1.2]]
            periodic: [true,true,true]
            expandable: false

     - .. image:: /_static/general_triclinic_domain.png
         :width: 300pt

Alternative ways for defining the domain
----------------------------------------

In some cases, the simulation domain does not need to be fully defined as explained above. Indeed, the domain information can sometimes already be contained in external files or fully defined by the material the user needs to model. Below is a list of situations where the domain is fully or partially defined. Additional details can be found in the corresponding documentation sections.

- ``bulk_lattice``: The system shape and size is created according to the replication in the 3D space of a unit cell chosen by the user. See :ref:`input-bulk-lattice`.
- ``read_xyz_file_with_xform``: Instead of creating the system from a template, an external ``.xyz`` file is read in which the number of atoms, their positions and the simulation cell size and shape ir provided. In that case, only the ``cell_size`` property of the ``domain`` YAML block is needed. See :ref:`input-read-xyz-xform`.
- ``read_dump_atoms``: The simulation starts at a specific timestep for which a restart file was generated. That restart files usually contains all information for the simulation domain. See :ref:`input-read-dump-atoms`.
- ``read_dump_molecule``: Same as above but for flexible molecules. See :ref:`input-read-dump-mol`.
- ``read_dump_rigidmol``: Same as above but for rigid molecules. See :ref:`input-read-dump-rigidmol`.

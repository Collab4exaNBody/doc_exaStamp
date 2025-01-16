.. _flavors:

Grid Flavors
============

In ``ExaStamp``, the grid flavor pre-defines the data attached to particles during the simulation, meaning that such data is stored anyway along the entire trajectory. Some fields can evolve with time such as positions or velocity while some can be fixed such as the particle identifiers or partial charges.

General Concept
---------------

To define the grid flavor to be used in the simulation, a ``YAML`` block can be used in the input file. Below are exemples of definitions for all grid flavors available in ``ExaStamp``.

.. code-block:: yaml

   # Minimal
   grid_flavor: grid_flavor_minimal
   
   # Multimat
   grid_flavor: grid_flavor_multimat

   # Full
   grid_flavor: grid_flavor_full

   # Mechanics
   grid_flavor: grid_flavor_mechanics

   # Multimat Mechanics
   grid_flavor: grid_flavor_multimat_mechanics

   # Rigid Molecules
   grid_flavor: grid_flavor_rigidmol

.. warning::

   Depending on the grid flavor chosen by the user, some fields won't be available for output. For example if one needs the global stress tensor computed by the `thermodynamic_state` operator, an appropriate `grid_flavor` to use would be the `grid_flavor_full`.
                

Amongst these grid flavors, mutliple fields are attached to particles. The following table lists the fields common to all grid flavors

.. list-table:: Common fields to all grid flavors
   :widths: 30 30
   :header-rows: 1
   :align: center

   * - Field
     - Type
   * - Potential Energy
     - float
   * - Position
     - Vec3d
   * - Velocity
     - Vec3d
   * - Force
     - Vec3d
     
Below is another table listing the additional per-particle fields in the different grid flavors. Depending on the application you're thinking about, you may choose the appropriate grid_flavor for your simulation.

.. list-table:: Per-particle fields available in the different grid flavors
   :widths: 30 30 30 30 30 30 30
   :header-rows: 1
   :align: center

   * - Field \\ Grid Flavor
     - mimimal
     - multimat
     - multimat_mechanics
     - full
     - full_mechanics
     - rigidmol
   * - Filtered Position
     - NO
     - NO
     - YES
     - NO
     - YES
     - NO
   * - Particle Identifier
     - NO
     - YES
     - YES 
     - YES
     - YES 
     - YES
   * - Particle Type
     - NO
     - YES
     - YES
     - YES
     - YES 
     - YES
   * - Virial
     - NO
     - NO
     - YES  
     - YES
     - YES    
     - NO
   * - Particle Charge
     - NO
     - NO
     - NO  
     - YES
     - NO 
     - YES
   * - Molecule Identifier
     - NO
     - NO
     - NO  
     - YES
     - NO 
     - YES
   * - Cmol
     - NO
     - NO
     - NO  
     - YES
     - NO 
     - YES
   * - Quaternion
     - NO
     - NO
     - NO  
     - NO
     - NO 
     - YES
   * - Angular Momentum
     - NO
     - NO
     - NO  
     - NO
     - NO 
     - YES
   * - Torque
     - NO
     - NO
     - NO  
     - NO
     - NO 
     - YES

Recommendations
---------------

Below are some recommendations on using the different grid flavors, depending on the particle types involved in your simulation.

Mono-specy and Multi-species Atomic Systems
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For mono-species and multi-species atomic systems, the different grid flavors that can be used are the following:

- ``grid_flavor_minimal`` to model system with minimal per-particle data. Not compatible with charged systems.
- ``grid_flavor_multimat`` to model multi-species systems and analyse the system using particle identifiers.
- ``grid_flavor_full`` to model multi-species systems with per-particle charges and virial.
  
Rigid Molecules Systems
^^^^^^^^^^^^^^^^^^^^^^^

For rigid molecules system, the only grid flavor that can be used is the ``grid_flavor_rigidmol``.  

Flexible Molecules Systems
^^^^^^^^^^^^^^^^^^^^^^^^^^

For systems containing fully flexible molecules, the only grid flavor that can be used is the ``grid_flavor_full``.


.. _species:

Particle Species
================

Particle Types
--------------

Multiple particle types can be used in ``ExaStamp`` such as atoms, rigid molecules or fully-flexible molecules. These three formalisms have an influence on the way the interactions are computed which will be explained in detail below. However, the common basis for all particle types is the definition of a ``YAML`` block containing information about the atoms themselves. The particles properties are initialized by the ``species`` operator that must be appended in the YAML input file:

.. code-block:: yaml
   :caption: **YAML block for particles type definition**
                
   # 1st solution: Species definition for atomic systems
   species:
     - O:
         mass:  15.9994 Da
         z: 8
         charge: -1.1104 e-
     - U:
         mass:  238.02891 Da
         z: 92
         charge: 2.2208 e-

   # 2nd solution: Species definition for molecular systems
   species:
     - h2o_H:
         mass:  1.008 Da
         z: 1
         charge: 0.5564 e-
         molecule: molH20
     - h2o_O:
         mass:  15.999 Da
         z: 8
         charge: -1.1128 e-
         molecule: molH20
     - o2_O:
         mass:  15.999 Da
         z: 8
         charge: 0.0 e-
         molecule: molO2

.. warning::

   The particle types enumerated in the ``species`` YAML block must be consistent with particle types that are read in external files, e.g. when reading a ``.xyz`` file generated with an external software. In addition, the ``lattice`` operator needs the user to assign particle species associated with the template used (e.g. SC, BCC, FCC etc). These species must also be consistent with the ``species`` block. See :ref:`input-lattice` for further details.
         
The ``species`` YAML block contains a sequence of particle types that contain different properties explained below.

.. list-table:: **Properties for each particle specy**
   :widths: 40 40 40
   :header-rows: 1

   * - Property
     - Data Type
     - Example
   * - ``mass``
     - float
     - .. code-block:: yaml
             
          mass: 15.9994 Da
   * - ``z``
     - int
     - .. code-block:: yaml
             
          z: 8
   * - ``charge``
     - float
     - .. code-block:: yaml
             
          charge: -1.1104 e-
   * - ``molecule``
     - string
     - .. code-block:: yaml
             
          molecule: molH2O

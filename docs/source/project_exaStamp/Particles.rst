Populating the domain with particles
====================================

.. _species:

Particle Types
^^^^^^^^^^^^^^

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

.. _builtin-particles:

Built-in particle creation
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. _input-lattice:

Lattice generator
-----------------

.. _input-bulk-lattice:

Bulk lattice generator
----------------------

.. _external-readers:

Reading external files
^^^^^^^^^^^^^^^^^^^^^^

.. _input-read-dump-atoms:

Readers of restart files for atomic systems
-------------------------------------------

.. _input-read-dump-mol:

Readers of restart files for flexible molecules systems
-------------------------------------------------------

.. _input-read-dump-rigidmol:

Readers of restart files for rigid molecules systems
----------------------------------------------------

.. _input-read-xyz-xform:

Readers of xyz File
-------------------

- Name: `read_xyz`
- Description: This operator reads a file written according to the xyz format.
- Parameters:
   * `bounds_mode` : default mode corresponde to ReadBoundsSelectionMode.
   * `enlarge_bounds` : Define a layer around the volume size in the xyz file. Default size is 0.
   * `file` : File name, this parameter is required.
   * `pbc_adjust_xform` : Ajust the form.


Reading external file formats
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. warning::
    Only supported for atomic systems

.. warning::
    If multiple structures are present in the file, the operator will always read the first one.

In addition to :ref:`builtin-particles creation <builtin-particles>` and :ref:`restart files<input-read-dump-atoms>`, ``ExaStamp`` can read external file formats though the ``read_external_file_format`` operator.

.. code-block:: yaml

   read_external_file_format:
     file: /path/to/example-file.xyz.gz
     format: xyz
     compression: gz
     units_style: metal
     style_style: full

.. list-table::
   :widths: 10 40 10
   :header-rows: 1

   * - Property
     - Description
     - Data Type
   * - ``file``
     - File name
     - string
   * - ``format``
     - File format extension (see :ref:`supported format<input-supported-ext-format>`)
     - string
   * - ``compression``
     - File compression extension (``gz`` , ``bz2`` , ``xz``)
     - string
   * - ``units_style``
     - LAMMPS units style (only used for LAMMPS format)
     - string
   * - ``atom_style``
     - LAMMPS atom style (only used for LAMMPS format)
     - string

Only the ``file`` parameters is required. By default, ``format`` and ``compression`` are deduced from the file's extension. The ``units_style`` and ``atom_style`` parametyers are used only with LAMMPS format to define the unit system and the atom style.

.. _input-supported-ext-format:

**Supported file formats**


Currently ``ExaStamp`` support the following external file formats:

.. list-table::
   :widths: 40 40 40
   :header-rows: 1

   * - Name
     - Description
     - Extension

   * - :ref:`LAMMPS Data <input-lammps-data-format>`
     - File format used by `LAMMPS <https://docs.lammps.org/Run_formats.html#input-file>`_
     - ``lmp``, ``lmp-data``, ``data``

   * - LAMMPS Dump
     - File format used by `LAMMPS <https://docs.lammps.org/Run_formats.html#input-file>`_
     - ``dump``, ``lmp-dump``

   * - XYZ
     - `Extended XYZ <https://github.com/libAtoms/extxyz?tab=readme-ov-file#xyz-file>`_ format.
     - ``xyz``



.. _input-lammps-data-format:

**LAMMPS Data**


**LAMMPS Dump**


**Extented XYZ**



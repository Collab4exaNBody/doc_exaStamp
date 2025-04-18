Input operators
===============

The present section describes in details the different operators used for simulation's setup, post-analysis, visualization and I/O operations in Molecular Dynamics simulations using exaStamp.

.. code-block:: yaml
                
   input_data:
     - domain
     - init_rcb_grid
     - particle_regions
     - lattice


.. _builtin-particles:

Built-in particle creation
--------------------------

.. _input-lattice:

Lattice generator
*****************

.. _input-bulk-lattice:

Bulk lattice generator
**********************

.. _external-readers:

Reading external files
----------------------

.. _input-read-dump-atoms:

Readers of restart files for atomic systems
*******************************************

.. _input-read-dump-mol:

Readers of restart files for flexible molecules systems
*******************************************************

.. _input-read-dump-rigidmol:

Readers of restart files for rigid molecules systems
****************************************************

.. _input-read-xyz-xform:

Readers of xyz File
*******************

- Name: `read_xyz`
- Description: This operator reads a file written according to the xyz format.
- Parameters:
   * `bounds_mode` : default mode corresponde to ReadBoundsSelectionMode.
   * `enlarge_bounds` : Define a layer around the volume size in the xyz file. Default size is 0.
   * `file` : File name, this parameter is required.
   * `pbc_adjust_xform` : Ajust the form.

Reading external file formats
*****************************

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


       

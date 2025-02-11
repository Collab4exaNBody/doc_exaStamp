Installation
============

``ExaSTAMP`` currently provides a single installation method through the use of ``CMake``, dedicated to both users and developer. The use of ``CMake`` allows the full support on both `CPU` and `GPU` architectures.

Installation With CMAKE
^^^^^^^^^^^^^^^^^^^^^^^

Minimal Requirements
--------------------

To proceed with the installation, your system must meet the minimum prerequisites. The first step involves the download and installation of ``exaNBody``:

.. code-block:: bash

   git clone https://github.com/Collab4exaNBody/exaNBody.git
   export exaNBody_DIR=${PWD}/exaNBody

The next step involves the installation of ``yaml-cpp``, which can be achieved using ``CMake``

.. code-block:: bash

   git clone https://github.com/jbeder/yaml-cpp.git
   mkdir build_yaml && cd build_yaml
   cmake -DYAML_BUILD_SHARED_LIBS=ON ../yaml-cpp
   make -j8 && make install

In any case, the ``cmake`` configuration files of ``exaNBody`` includes an automatic search of ``yaml-cpp`` installation on the machine and an error message will be displayed if it cannot be found.

Optional Dependencies
---------------------

Before proceeding further, you have the option to consider the following dependencies:

- ``Cuda``
- ``MPI``
- ``HIP``  

ExaSTAMP Installation
---------------------

To install ``ExaStamp``, follow these steps:

Ensure that the environment variable `exaNBody_DIR` is set. Clone the ``ExaStamp`` repository using the command:

.. code-block:: bash
		
   git clone https://github.com/Collab4exaNBody/exaSTAMP.git

Create a directory `build-exaStamp` and navigate to it:

.. code-block:: bash

   mkdir build-exaStamp && cd build-exaStamp

Run ``CMake`` to configure the ``ExaStamp`` build, specifying that ``CUDA`` support should be turned off:

.. code-block:: bash
		
   cmake ../exaSTAMP -DXNB_BUILD_CUDA=OFF

You can also define the `exaNBody_DIR` variable as follows:

.. code-block:: bash
		
   cmake ../exaSTAMP -DXNB_BUILD_CUDA=OFF -DexaNBody_DIR=${path_to_exaNBody}

Additional adjustments can be done using ``CMake`` by running the following command:

.. code-block:: bash
		
   ccmake .

.. note::
  To install with CUDA on architecture ``sm_80``, run the following command: ``cmake ../exaStamp -DXNB_BUILD_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=80``

.. warning::
  It's important to note that the maximum number of neighbors is set to 512 in the general case and to 32 for MEAM potentials. To change these value, you can specify the required number by adding : ``-DXSTAMP_MAX_PARTICLE_NEIGHBORS=N`` or ``-DXSTAMP_MEAM_MAX_NEIGHBORS=N`` to the `cmake` command.
  
Build ``ExaStamp`` using the `make` command with a specified number of parallel jobs (e.g., -j 4 for 4 parallel jobs):

.. code-block:: bash
		
   make -j4

Finally, you need to build the plugins database:

.. code-block:: bash
		
   make UpdatePluginDataBase

This command will display all plugins and related operators. Example: 

.. code-block:: bash

   + exanbDefBoxPlugin
     operator    apply_xform
     operator    xform_constant_strain_rate
     operator    deformation_xform
     operator    domain_extract_xform
     operator    domain_set_xform
     operator    xform_time_interpolate_byparts
     operator    xform_time_interpolate
     operator    push_v_r
     operator    push_f_v
     operator    push_f_r
   + exaStampIOPlugin
     operator    read_dump_atoms
     operator    read_dump_molecule
     operator    read_dump_rigidmol
     operator    read_xyz_file_with_xform
     operator    read_xyz_file_with_xform_molecules
     operator    lattice
     operator    write_dump_atoms
     operator    write_dump_molecule
     operator    write_dump_rigidmol
     operator    write_xyz

.. note::
  The list of plugins and overall organization is still subject to changes. This will be announced in the relase notes above.
     
Running your simulation
^^^^^^^^^^^^^^^^^^^^^^^

Now that you have installed the ``ExaStamp`` and ``exaNBody`` packages, you can create your simulation file using the ``YAML`` format (refer to the ``example`` folder or the documentation for each operator for more information). Once this file is constructed, you can run your simulation with a specified number of ``MPI`` processes and threads per `MPI`` process (e.g. 2 MPI with 4 threads per MPI) using the following instructions:

.. code-block:: bash
		
   export N_OMP=4
   export N_MPI=2
   export OMP_NUM_THREADS=$N_OMP
   mpirun -n $N_MPI ./exaStamp test-case.msp

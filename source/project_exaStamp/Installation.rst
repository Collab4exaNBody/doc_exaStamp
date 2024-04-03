Installation
============

Minimal Requirements
--------------------

To proceed with the installation, your system must meet the minimum prerequisites. The first step involves the download and installation of exaNBody:

.. code-block:: bash

   git clone https://github.com/Collab4exaNBody/exaNBody.git
   mkdir build-exaNBody/ && cd build-exaNBody/
   cmake ../exaNBody/ -DCMAKE_INSTALL_PREFIX=path_to_exaNBody_install
   make install
   export exaNBody_DIR=path_to_exaNBody_install

The next step involves the installation of yaml-cpp, which can be achieved using either the spack package manager or cmake:

.. code-block:: bash

   spack install yaml-cpp
   spack load yaml-cpp

Optional Dependencies
---------------------

Before proceeding further, you have the option to consider the following dependencies:

- Cuda
- MPI
- ML-SNAP

ExaSTAMP Installation
---------------------

As for exaNBody, you can first download the exaStamp and prepare the build repository:

.. code-block:: bash
		
   git clone https://github.com/Collab4exaNBody/exaSTAMP.git
   mkdir build-exaSTAMP/ && cd build-exaSTAMP/

Then, two solutions are possible. Since an installation of exaNBody is needed, you can either specify the exaNBody install directory or the exaNBody source directory to the cmake environment. For the first solution, the exaSTAMP installation can be done as follows.

**1st solution:** The exaNBody_DIR environment variable is already defined (as described above). Then run CMake to configure the exaSTAMP build:

.. code-block:: bash
		
   cmake ../exaStamp

**2nd solution:** The exaNBody_DIR path can be passed as an argument to the CMake command:

.. code-block:: bash
		
   cmake ../exaStamp -DexaNBody_DIR=path_to_exaNBody_install

**3rd solution:** You can specify the path to exaNBody to CMake by defining the CMAKE_PREFIX_PATH variable:

.. code-block:: bash
		
   cmake ../exaStamp -DCMAKE_PREFIX_PATH=path_to_exaNBody_install

Additional adjustments can be done using CMake by running the following command:

.. code-block:: bash
		
   ccmake .

Finally, build exaSTAMP using the make command with a specified number of parallel jobs (e.g., -j 4 for 4 parallel jobs):

.. code-block:: bash
		
   make -j 4

In addition, you need tu update the plugins database using the following:

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

Running your simulation
-----------------------

Now that you have installed the exaSTAMP and exaNBody packages, you can create your simulation file using the YAML format (refer to the 'example' folder or the documentation for each operator). Once this file is constructed, you can run your simulation with a specified number of MPI processes and number of threads per MPI process (e.g. 2 MPI with 4 threads per MPI) using the following instructions:

.. code-block:: bash
		
   export N_OMP=4
   export N_MPI=2
   export OMP_NUM_THREADS=$N_OMP
   mpirun -n $N_MPI ./exaStamp test-case.msp



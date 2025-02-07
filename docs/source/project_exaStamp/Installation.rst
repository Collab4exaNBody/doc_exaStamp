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

Installation 2.0
================

``exaSTAMP`` installation 2.0 consists in first building both the ``ONIKA`` HPC platform and the ``exaNBody`` (version 2.0) particle simulation platform. Below are instructions for building both as well as final instruction for building ``exaSTAMP``.

For all three codes, a single installation method through the use of ``CMake`` is provided, dedicated to both users and developer. The use of ``CMake`` allows the full support on both `CPU` and `GPU` architectures.

Prerequisistes
^^^^^^^^^^^^^^^^^^^^^^^

CMake from sources
------------------

YAML from sources
-----------------

All three platforms extensively use the YAML Library. To build YAML from sources, read the following instructions. Installations procedures for both Ubuntu-22.04 and Rhel_8__x86_64 architectures are provided.

.. code-block:: bash
   :caption: **Retrieve YAML from GitHub repository**

   # Common instructions
   YAMLTMPFOLDER=${path_to_yaml_for_build_from_sources}
   mkdir ${YAMLTMPFOLDER}
   cd ${YAMLTMPFOLDER}
   git clone -b yaml-cpp-0.6.3 git@github.com:jbeder/yaml-cpp.git
   *OR* git clone -b yaml-cpp-0.6.3 https://github.com/jbeder/yaml-cpp.git
   YAML_CPP_INSTALL_DIR=${HOME}/local/yaml-cpp-0.6.3 # adapt this to your environment
   cd ${YAMLTMPFOLDER}
   mkdir build
   cd build

.. code-block:: bash
   :caption: **Building on Ubuntu-22.04 X g++-11.4 X CMake 3.26.6**

   cmake -DCMAKE_BUILD_TYPE=Debug \
         -DCMAKE_INSTALL_PREFIX=${YAML_CPP_INSTALL_DIR} \
         -DYAML_BUILD_SHARED_LIBS=OFF \
         -DYAML_CPP_BUILD_CONTRIB=ON \
         -DYAML_CPP_BUILD_TESTS=OFF \
         -DYAML_CPP_BUILD_TOOLS=OFF \
         -DYAML_CPP_INSTALL=ON \
         -DCMAKE_CXX_FLAGS=-fPIC \
         ../yaml-cpp

.. code-block:: bash
   :caption: **Building on Rhel_8__x86_64 X gcc-11.2.0**

   module purge ; module load gnu/11.2.0 cmake/3.26.4
   cmake -DCMAKE_BUILD_TYPE=Debug \
         -DCMAKE_INSTALL_PREFIX=${YAML_CPP_INSTALL_DIR} \
         -DYAML_BUILD_SHARED_LIBS=OFF \
         -DYAML_CPP_BUILD_CONTRIB=ON \
         -DYAML_CPP_BUILD_TESTS=OFF \
         -DYAML_CPP_BUILD_TOOLS=OFF \
         -DYAML_CPP_INSTALL=ON \
         -DCMAKE_CXX_FLAGS="-fPIC" \
         ../yaml-cpp

.. code-block:: bash
   :caption: **Build and install**
         
   # Common build, install and cleanup commands
   make -j4 install
   cd ../..
   rm -fr ${YAMLTMPFOLDER}

Building ONIKA from sources
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Description
-----------

``Onika`` (Object Network Interface for Knit Applications), is a component based HPC software platform to build numerical simulation codes.

``Onika`` is the foundation for the ``exaNBody`` particle simulation platform but is not bound to N-Body problems nor other domain specific simulation code.

Existing applications based on its building blocks include Molecular Dynamics, particle based fluid simulations using methods such as Smooth Particle Hydrodynamics (SPH) or rigid body simulations using methods such as Discrete Element Method (DEM).

It uses industry grade standards and widely adopted technologies such as CMake and C++20 for development and build, YAML for user input files, MPI and OpenMP for parallel programming, Cuda and HIP for GPU acceleration.

Retrieve Onika sources
--------------------------

To build ``Onika`` from sources, read the following instructions. First step is to retrieve the ``Onika`` sources fro the GitHub repository.

.. code-block:: bash
   :caption: **Retrieve Onika from GitHub repository**

   cd ${HOME}/dev #Adapt depending on where you want to download ``Onika``
   git clone git@github.com:Collab4exaNBody/onika.git
   cd onika
   ONIKA_SRC_DIR=${PWD}
   cd ../
   mkdir build_onika
   cd build_onika

Build and install Onika on Ubuntu 22.04
---------------------------------------
         
.. tabs::

   .. tab:: **Ubuntu 22.04 | GCC 11.4.0 | CUDA 12**
            
      .. code-block:: bash

         ONIKA_INSTALL_DIR=${HOME}/local/onika
         ONIKA_SRC_DIR=${HOME}/dev/onika
         YAML_CPP_INSTALL_DIR=${HOME}/local/yaml-cpp-0.6.3/lib/cmake/yaml-cpp
         ONIKA_SETUP_ENV_COMMANDS=""
         eval ${ONIKA_SETUP_ENV_COMMANDS}
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${ONIKA_INSTALL_DIR} \
               -Dyaml-cpp_DIR=${YAML_CPP_INSTALL_DIR} \
               -DONIKA_BUILD_CUDA=ON \
               -DCMAKE_CUDA_COMPILER=${PATH_TO_NVCC} \
               -DCMAKE_CUDA_ARCHITECTURES=${ARCH} \
               -DONIKA_SETUP_ENV_COMMANDS="${ONIKA_SETUP_ENV_COMMANDS}" \
               ${ONIKA_SRC_DIR}

   .. tab:: **Ubuntu 22.04 | GCC 12.3.0**
            
      .. code-block:: bash

         # Works also for GCC 12.3.0 | 10.5.0 | 9.5.0
         ONIKA_INSTALL_DIR=${HOME}/local/onika
         ONIKA_SRC_DIR=${HOME}/dev/onika
         YAML_CPP_INSTALL_DIR=${HOME}/local/yaml-cpp-0.6.3/lib/cmake/yaml-cpp
         ONIKA_SETUP_ENV_COMMANDS=""
         eval ${ONIKA_SETUP_ENV_COMMANDS}
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${ONIKA_INSTALL_DIR} \
               -Dyaml-cpp_DIR=${YAML_CPP_INSTALL_DIR} \
               -DONIKA_BUILD_CUDA=OFF \
               -DONIKA_SETUP_ENV_COMMANDS="${ONIKA_SETUP_ENV_COMMANDS}" \
               ${ONIKA_SRC_DIR}

        make -j4 install
               
Build and install Onika on Rhel architectures
---------------------------------------------
         
.. tabs::
               
   .. tab:: **Rhel_8__x86_64 | INTEL-24.2.0 | CUDA 12.4**

      .. code-block:: bash

         ONIKA_INSTALL_DIR=${HOME}/local/onika
         ONIKA_SRC_DIR=${HOME}/dev/onika
         YAML_CPP_INSTALL_DIR=${HOME}/local/yaml-cpp-0.6.3/lib/cmake/yaml-cpp            
         ONIKA_SETUP_ENV_COMMANDS="module purge ; module load gnu/11.2.0 nvhpc/24.3 inteloneapi/24.2.0 mpi/openmpi cmake/3.26.4"
         eval ${ONIKA_SETUP_ENV_COMMANDS}
         CXX_COMPILER=`which icpx`
         C_COMPILER=`which icx`
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${ONIKA_INSTALL_DIR} \
               -DCMAKE_C_COMPILER=${C_COMPILER} \
               -DCMAKE_CXX_COMPILER=${CXX_COMPILER} \
               -DCMAKE_CXX_FLAGS=-diag-disable=15518,15552 \
               -Dyaml-cpp_DIR=${YAML_CPP_INSTALL_DIR} \
               -DONIKA_BUILD_CUDA=ON \
               -DCMAKE_CUDA_COMPILER=/ccc/products/cuda-12.4/system/default/bin/nvcc \
               -DCMAKE_CUDA_FLAGS="-ccbin ${CXX_COMPILER} -allow-unsupported-compiler" \
               -DCMAKE_CUDA_ARCHITECTURES=80 \
               -DONIKA_MPIRUN_CMD="/usr/bin/ccc_mprun" \
               -DMPIEXEC_EXECUTABLE=`which mpiexec` \
               -DMPIEXEC_MAX_NUMPROCS=32 \
               -DMPIEXEC_NUMCORE_FLAG="-c" \
               -DMPIEXEC_NUMPROC_FLAG="-n" \
               -DMPIEXEC_PREFLAGS="-pa100-bxi" \
               -DMPIEXEC_PREFLAGS_DBG="-pa100-bxi;-Xall;xterm;-e" \
               -DONIKA_ALWAYS_USE_MPIRUN=ON \
               -DONIKA_SETUP_ENV_COMMANDS="${ONIKA_SETUP_ENV_COMMANDS}" \
               ${ONIKA_SRC_DIR}

   .. tab:: **Rhel_8__x86_64 | GCC-11.2.0 | CUDA 12.4**

      .. code-block:: bash

         ONIKA_INSTALL_DIR=${HOME}/local/onika
         ONIKA_SRC_DIR=${HOME}/dev/onika
         YAML_CPP_INSTALL_DIR=${HOME}/local/yaml-cpp-0.6.3/lib/cmake/yaml-cpp
         ONIKA_SETUP_ENV_COMMANDS="module purge ; module load gnu/11.2.0 nvhpc/24.3 mpi/openmpi cmake/3.26.4"
         eval ${ONIKA_SETUP_ENV_COMMANDS}
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${ONIKA_INSTALL_DIR} \
               -Dyaml-cpp_DIR=${YAML_CPP_INSTALL_DIR} \
               -DONIKA_BUILD_CUDA=ON \
               -DCMAKE_CUDA_COMPILER=/ccc/products/cuda-12.4/system/default/bin/nvcc \
               -DCMAKE_CUDA_ARCHITECTURES=80 \
               -DONIKA_MPIRUN_CMD="/usr/bin/ccc_mprun" \
               -DMPIEXEC_EXECUTABLE=`which mpiexec` \
               -DMPIEXEC_MAX_NUMPROCS=32 \
               -DMPIEXEC_NUMCORE_FLAG="-c" \
               -DMPIEXEC_NUMPROC_FLAG="-n" \
               -DMPIEXEC_PREFLAGS="-pa100-bxi" \
               -DMPIEXEC_PREFLAGS_DBG="-pa100-bxi;-Xall;xterm;-e" \
               -DONIKA_ALWAYS_USE_MPIRUN=ON \
               -DONIKA_SETUP_ENV_COMMANDS="${ONIKA_SETUP_ENV_COMMANDS}" \
               ${ONIKA_SRC_DIR}

   .. tab:: **Rhel_8__x86_64 | GCC-12.3.0 | CUDA 12.4**

      .. code-block:: bash

         ONIKA_INSTALL_DIR=${HOME}/local/onika
         ONIKA_SRC_DIR=${HOME}/dev/onika
         YAML_CPP_INSTALL_DIR=${HOME}/local/yaml-cpp-0.6.3/lib/cmake/yaml-cpp
         ONIKA_SETUP_ENV_COMMANDS="module purge ; module load gnu/12.3.0 nvhpc/24.3 mpi/openmpi cmake/3.26.4"
         eval ${ONIKA_SETUP_ENV_COMMANDS}
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${ONIKA_INSTALL_DIR} \
               -Dyaml-cpp_DIR=${YAML_CPP_INSTALL_DIR} \
               -DONIKA_BUILD_CUDA=ON \
               -DCMAKE_CUDA_COMPILER=/ccc/products/cuda-12.4/system/default/bin/nvcc \
               -DCMAKE_CUDA_ARCHITECTURES=80 \
               -DONIKA_MPIRUN_CMD="/usr/bin/ccc_mprun" \
               -DMPIEXEC_EXECUTABLE=`which mpiexec` \
               -DMPIEXEC_MAX_NUMPROCS=32 \
               -DMPIEXEC_NUMCORE_FLAG="-c" \
               -DMPIEXEC_NUMPROC_FLAG="-n" \
               -DMPIEXEC_PREFLAGS="-pa100-bxi" \
               -DMPIEXEC_PREFLAGS_DBG="-pa100-bxi;-Xall;xterm;-e" \
               -DONIKA_ALWAYS_USE_MPIRUN=ON \
               -DONIKA_SETUP_ENV_COMMANDS="${ONIKA_SETUP_ENV_COMMANDS}" \
               ${ONIKA_SRC_DIR}

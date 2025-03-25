Installation
============

Installation for developers
***************************

.. warning::

   This section concerns the installation procedure for ``exaStamp`` with a version of ``exaNBody`` >= 2.0. Another installation procedure for version < 2.0 is provided in the next section but will be obsolete soon.

``exaSTAMP`` installation 2.0 consists in first building both the ``ONIKA`` HPC platform and the ``exaNBody`` (version 2.0) particle simulation platform. Below are instructions for building both as well as final instruction for building ``exaSTAMP``.

For all three codes, a single installation method through the use of ``CMake`` is provided, dedicated to both users and developer. The use of ``CMake`` allows the full support on both `CPU` and `GPU` architectures.

Build YAML-cpp from sources
^^^^^^^^^^^^^^^^^^^^^^^^^^^

All three platforms extensively use the YAML Library. To build YAML from sources, read the following instructions. Installations procedures for both Ubuntu-22.04 and Rhel_8__x86_64 architectures are provided. The first step is to retrieve the YAML sources from the corresponding GitHub repository.

Retrieve YAML sources
---------------------

.. code-block:: bash

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

Build and install YAML
----------------------
   
.. tabs::

   .. tab:: **UBUNTU-22.04 | GCC-11.4 | CMake 3.26.6**
   
      .. code-block:: bash

         cmake -DCMAKE_BUILD_TYPE=Debug \
               -DCMAKE_INSTALL_PREFIX=${YAML_CPP_INSTALL_DIR} \
               -DYAML_BUILD_SHARED_LIBS=OFF \
               -DYAML_CPP_BUILD_CONTRIB=ON \
               -DYAML_CPP_BUILD_TESTS=OFF \
               -DYAML_CPP_BUILD_TOOLS=OFF \
               -DYAML_CPP_INSTALL=ON \
               -DCMAKE_CXX_FLAGS=-fPIC \
               ../yaml-cpp

         make -j4 install
         cd ../..
         rm -fr ${YAMLTMPFOLDER}
               
   .. tab:: **Rhel_8__x86_64 | GCC-11.2.0 | CMake 3.26.4**
                  
      .. code-block:: bash

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
         
         make -j4 install
         cd ../..
         rm -fr ${YAMLTMPFOLDER}

Build Onika from sources
^^^^^^^^^^^^^^^^^^^^^^^^

Description
-----------

``Onika`` (Object Network Interface for Knit Applications), is a component based HPC software platform to build numerical simulation codes.
``Onika`` is the foundation for the ``exaNBody`` particle simulation platform but is not bound to N-Body problems nor other domain specific simulation code.
Existing applications based on its building blocks include Molecular Dynamics, particle based fluid simulations using methods such as Smooth Particle Hydrodynamics (SPH) or rigid body simulations using methods such as Discrete Element Method (DEM).
It uses industry grade standards and widely adopted technologies such as CMake and C++20 for development and build, YAML for user input files, MPI and OpenMP for parallel programming, Cuda and HIP for GPU acceleration. To build ``Onika`` from sources, read the following instructions.

Retrieve Onika sources
----------------------
   
First step is to retrieve the ``Onika`` sources fro the GitHub repository.

.. code-block:: bash

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

   .. tab:: **UBUNTU 22.04 | GCC 12.3.0 | CUDA 12**
            
      .. code-block:: bash

         ONIKA_INSTALL_DIR=${HOME}/local/onika
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

        make -j4 install
               
   .. tab:: **UBUNTU 22.04 | GCC 12.3.0**
            
      .. code-block:: bash

         ONIKA_INSTALL_DIR=${HOME}/local/onika
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

Build exaNBody from sources
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Description
-----------

``exaNBody`` is a software platform to build-up numerical simulations solving N-Body like problems.
Typical applications include Molecular Dynamics, particle based fluid simulations using methods such as Smooth Particle Hydrodynamics (SPH) or rigid body simulations using methods such as Discrete Element Method (DEM).
It uses standard and widely adopted technologies such as C++17, YAML, OpenMP , Cuda or HIP.

Retrieve exaNBody sources
-------------------------
   
First step is to retrieve the ``exaNBody`` sources fro the GitHub repository.

.. code-block:: bash

   cd ${HOME}/dev #Adapt depending on where you want to download ``exaNBody``
   git clone -b release-2.0 git@github.com:Collab4exaNBody/exaNBody.git
   cd exaNBody
   XNB_SRC_DIR=${PWD}
   cd ../
   mkdir build_exaNBody
   cd build_exaNBody

Build and install exaNBody on Ubuntu 22.04
------------------------------------------
         
.. tabs::

   .. tab:: **Ubuntu 22.04 | GCC 11.4.0**
            
      .. code-block:: bash

         # Works also for GCC 12.3.0
         # Sourcing the ONIKA environment will automatically update whether CUDA is needed or not
         ONIKA_INSTALL_DIR=${HOME}/local/onika
         XNB_INSTALL_DIR=${HOME}/local/exaNBody
         source ${ONIKA_INSTALL_DIR}/bin/setup-env.sh
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${XNB_INSTALL_DIR} \
               -Donika_DIR=${ONIKA_INSTALL_DIR} \
	             ${XNB_SRC_DIR}

         make -j4 install
         
   .. tab:: **Rhel_8__x86_64 | INTEL-24.2.0 | CUDA 12.4**
            
      .. code-block:: bash

         ONIKA_INSTALL_DIR=${HOME}/local/onika
         XNB_INSTALL_DIR=${HOME}/local/exaNBody
         source ${ONIKA_INSTALL_DIR}/bin/setup-env.sh
         CXX_COMPILER=`which icpx`
         C_COMPILER=`which icx`
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${XNB_INSTALL_DIR} \
               -DCMAKE_C_COMPILER=${C_COMPILER} \
               -DCMAKE_CXX_COMPILER=${CXX_COMPILER} \
               -DCMAKE_CXX_FLAGS=-diag-disable=15518,15552 \
               -Donika_DIR=${ONIKA_INSTALL_DIR} \
               ${XNB_SRC_DIR}
               
         make -j4 install
         
   .. tab:: **Rhel_8__x86_64 | GCC-12.3.0 | CUDA 12.4**
            
      .. code-block:: bash
                      
         # Works also with gcc-11.2.0
         ONIKA_INSTALL_DIR=/ccc/home/cont001/xstampdev/xstampdev/releases/onika
         XNB_INSTALL_DIR=${HOME}/local/exaNBody
         source ${ONIKA_INSTALL_DIR}/bin/setup-env.sh
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${XNB_INSTALL_DIR} \
               -Donika_DIR=${ONIKA_INSTALL_DIR} \
               ${XNB_SRC_DIR}

         make -j4 install

Build exaStamp from sources
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Retrieve exaStamp sources
-------------------------
   
First step is to retrieve the ``exaStamp`` sources fro the GitHub repository.

.. code-block:: bash

   cd ${HOME}/dev #Adapt depending on where you want to download ``exaNBody``
   git clone -b exaNBody-release-2.0 git@github.com:Collab4exaNBody/exaStamp.git
   cd exaStamp && EXASTAMP_SRC_DIR=${PWD} && cd ../
   mkdir build_exaStamp && build_exaStamp

Build and install exaStamp
--------------------------
         
.. tabs::

   .. tab:: **Ubuntu 22.04 | GCC 11.4.0**
            
      .. code-block:: bash

         # Works also for GCC 12.3.0
         # Sourcing the EXANBODY environment will automatically update whether CUDA is needed or not
         XNB_INSTALL_DIR=${HOME}/local/exaNBody
         source ${XNB_INSTALL_DIR}/bin/setup-env.sh
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${EXASTAMP_INSTALL_DIR} \
               -DexaNBody_DIR=${XNB_INSTALL_DIR} \
	             ${EXASTAMP_SRC_DIR}

         make -j4 install
         
   .. tab:: **Rhel_8__x86_64 | INTEL-24.2.0**
            
      .. code-block:: bash

         XNB_INSTALL_DIR=${HOME}/local/exaNBody
         source ${XNB_INSTALL_DIR}/bin/setup-env.sh
         CXX_COMPILER=`which icpx`
         C_COMPILER=`which icx`
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${EXASTAMP_INSTALL_DIR} \
               -DCMAKE_C_COMPILER=${C_COMPILER} \
               -DCMAKE_CXX_COMPILER=${CXX_COMPILER} \
               -DCMAKE_CXX_FLAGS=-diag-disable=15518,15552 \
               -DexaNBody_DIR=${XNB_INSTALL_DIR} \
               ${EXASTAMP_SRC_DIR}
               
         make -j4 install
         
   .. tab:: **Rhel_8__x86_64 | GCC-12.3.0**
            
      .. code-block:: bash
                      
         # Works also with gcc-11.2.0
         XNB_INSTALL_DIR=${HOME}/local/exaNBody
         source ${XNB_INSTALL_DIR}/bin/setup-env.sh
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${XNB_INSTALL_DIR} \
               -DexaNBody_DIR=${ONIKA_INSTALL_DIR} \
               ${EXASTAMP_SRC_DIR}

         make -j4 install


Installation (v<2.0)
********************

.. warning::

   This section concerns the installation procedure for ``exaStamp`` with a version of ``exaNBody`` < 2.0. Another installation procedure for version >= 2.0 is provided in the next section. The latter will be the main procedure to follow in a near future.
   
``ExaSTAMP`` currently provides a single installation method through the use of ``CMake``, dedicated to both users and developer. The use of ``CMake`` allows the full support on both `CPU` and `GPU` architectures. A second installation procedure will be provided in a near future through the use of ``Spack`` package manager which offers a straightforward installation process, mostly dedicated to users only. However, for those who would like to be involved in the development of ``ExaStamp``, ``CMake`` is recommended as the ``Spack`` route won't provide access to the main branch but rather to stable versions of ``ExaStamp``.

Prerequisites
^^^^^^^^^^^^^

To proceed with the installation, your system must meet the minimum prerequisites.

exaNBody
--------

The first step involves the download of the ``exaNBody`` platform:

.. code-block:: bash

   git clone https://github.com/Collab4exaNBody/exaNBody.git
   export exaNBody_DIR=${PWD}/exaNBody

yaml-cpp
--------
   
The next step involves the installation of ``yaml-cpp``, which can be achieved using ``Spack``, ``apt-get`` or ``CMake``

.. tabs::

   .. tab:: **CMake**
   
      .. code-block:: bash

         export CURRENT_HOME=$PWD
         git clone -b yaml-cpp-0.6.3 git@github.com:jbeder/yaml-cpp.git
         mkdir ${CURRENT_HOME}/buil-yaml-cpp && cd ${CURRENT_HOME}/buil-yaml-cpp
         cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${CURRENT_HOME}/install-yaml-cpp -DYAML_BUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_TESTS=OFF ../yaml-cpp
         make -j8 install
         cd ${CURRENT_HOME}
         export PATH_TO_YAML=${CURRENT_HOME}/install-yaml-cpp

   .. tab:: **apt-get install**
   
      .. code-block:: bash

         sudo apt install libyaml-cpp-dev
                      
   .. tab:: **Spack**
   
      .. code-block:: bash

         spack install yaml-cpp@0.6.3
         spack load yaml-cpp@0.6.3

In any case, the ``cmake`` configuration files of ``exaNBody`` includes an automatic search of ``yaml-cpp`` installation on the machine and an error message will be displayed if it cannot be found. Please ensure to remove `yaml-cpp` and `build-yaml-cpp` folders afterwards. When installing ``exaSTAMP``, you can specify the YAML path by adding either ``-DCMAKE_PREFIX_PATH=${PATH_TO_YAML}`` or ``-Dyaml-cpp_DIR=${YAML_PATH}`` to the cmake command.

Optional Dependencies
---------------------

Before proceeding further, you have the option to consider the following dependencies:

- ``CUDA``
- ``MPI``
- ``HIP``  

ExaSTAMP CMake Installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

To install ``ExaStamp``, first ensure that the environment variable `exaNBody_DIR` is set as indicated above. You can also define the `exaNBody_DIR` variable directly in the `cmake` command by adding ``-DexaNBody_DIR=${path_to_exaNBody}`` to it. Then, clone the ``exaStamp`` repository and create a build folder:

.. code-block:: bash
		
   git clone https://github.com/Collab4exaNBody/exaStamp.git
   mkdir build-exaStamp && cd build-exaStamp

Run ``CMake`` to configure the ``exaStamp`` build, specifying that ``CUDA`` support should be turned on or off. Below are a few compilations examples.

.. tabs::

   .. tab:: **CMake Minimal**
   
      .. code-block:: bash
		
         cmake ../exaStamp -DXNB_BUILD_CUDA=OFF
         make -j8 && make UpdatePluginDataBase

   .. tab:: **CMake with GPU A100**
   
      .. code-block:: bash
		
         cmake ../exaStamp -DXNB_BUILD_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=80
         make -j8 && make UpdatePluginDataBase

Additional adjustments can be done using ``CMake`` by running the following command:

.. code-block:: bash
		
   ccmake .

.. warning::
  It's important to note that the maximum number of neighbors is set to 512 in the general case and to 32 for MEAM potentials. To change these value, you can specify the required number by adding : ``-DXSTAMP_MAX_PARTICLE_NEIGHBORS=N`` or ``-DXSTAMP_MEAM_MAX_NEIGHBORS=N`` to the `cmake` command.

The command `make UpdatePluginDataBase` shown above will display all plugins and related operators:

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

ExaSTAMP Spack Installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. warning::

   This section is under construction and is not effective yet.
   
Installation with ``spack`` is preferable for people who don't want to develop in ``exaStamp``. Only stable versions are added when you install ``exaStamp`` with ``Spack``.

.. note::
  The main of ``exaStamp`` will never be directly accessible via this installation method.

Installing Spack
----------------

.. code-block:: bash

  git clone https://github.com/spack/spack.git
  export SPACK_ROOT=$PWD/spack
  source ${SPACK_ROOT}/share/spack/setup-env.sh

Installing exaStamp
-------------------

First go to the ``exaStamp`` repository and add it to spack. It contains two packages: ``exanbody`` and ``exastamp``:

.. code-block:: bash
		
   git clone https://github.com/Collab4exaNBody/exaStamp.git
   cd exaStamp
   spack repo add spack_repo

Secondly, install ``exaStamp`` (this command will install ``cmake``, ``yaml-cpp`` and ``exanbody``).

.. code-block:: bash

  spack install exastamp

Running your simulation
^^^^^^^^^^^^^^^^^^^^^^^

Now that you have installed the ``exaStamp`` and ``exaNBody`` packages, you can create your simulation file using the ``YAML`` format (refer to the ``example`` folder or the documentation for each operator for more information). Once this file is constructed, you can run your simulation with a specified number of ``MPI`` processes and threads per `MPI`` process (e.g. 2 MPI with 4 threads per MPI) using the following instructions:

.. code-block:: bash
		
   export N_OMP=4
   export N_MPI=2
   export OMP_NUM_THREADS=$N_OMP
   mpirun -n $N_MPI ./exaStamp test-case.msp
                      
Installation for user-only
**************************
         
Install YAML
^^^^^^^^^^^^

The next step involves the installation of ``yaml-cpp``, which can be achieved using ``Spack``, ``apt-get`` or ``CMake``

.. tabs::

   .. tab:: **CMake**
   
      .. code-block:: bash

         export CURRENT_HOME=$PWD
         git clone -b yaml-cpp-0.6.3 git@github.com:jbeder/yaml-cpp.git
         mkdir ${CURRENT_HOME}/buil-yaml-cpp && cd ${CURRENT_HOME}/buil-yaml-cpp
         cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${CURRENT_HOME}/install-yaml-cpp -DYAML_BUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_TESTS=OFF ../yaml-cpp
         make -j8 install
         cd ${CURRENT_HOME}
         export PATH_TO_YAML=${CURRENT_HOME}/install-yaml-cpp

   .. tab:: **apt-get install**
   
      .. code-block:: bash

         sudo apt install libyaml-cpp-dev
                      
   .. tab:: **Spack**
   
      .. code-block:: bash

         spack install yaml-cpp@0.6.3
         spack load yaml-cpp@0.6.3

In any case, the ``cmake`` configuration files of ``exaNBody`` includes an automatic search of ``yaml-cpp`` installation on the machine and an error message will be displayed if it cannot be found. Please ensure to remove `yaml-cpp` and `build-yaml-cpp` folders afterwards. When installing ``exaSTAMP``, you can specify the YAML path by adding either ``-DCMAKE_PREFIX_PATH=${PATH_TO_YAML}`` or ``-Dyaml-cpp_DIR=${YAML_PATH}`` to the cmake command.

Optional Dependencies
^^^^^^^^^^^^^^^^^^^^^

Before proceeding further, you have the option to consider the following dependencies:

- ``CUDA``
- ``MPI``
- ``HIP``  

Install ONIKA
^^^^^^^^^^^^^

Install exaNBody
^^^^^^^^^^^^^^^^

Install exaStamp
^^^^^^^^^^^^^^^^

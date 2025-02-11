Installation 2.0
================

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

Build ONIKA from sources
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

   .. tab:: **UBUNTU 22.04 | GCC 11.4.0 | CUDA 12**
            
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

        make -j4 install
               
   .. tab:: **UBUNTU 22.04 | GCC 12.3.0**
            
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

Build exaNBody from sources
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Description
-----------

``exaNBody`` is a software platform to build-up numerical simulations solving N-Body like problems.
Typical applications include Molecular Dynamics, particle based fluid simulations using methods such as Smooth Particle Hydrodynamics (SPH) or rigid body simulations using methods such as Discrete Element Method (DEM).
It uses standard and widely adopted technologies such as C++17, YAML, OpenMP , Cuda or HIP.

Retrieve Onika sources
----------------------
   
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

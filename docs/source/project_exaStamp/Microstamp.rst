  
Mini app microStamp
*******************

At the ``exaNBody`` level, a mini MD app is avaiable for benchmark and optimization purposes. That mini app only contains the Lennard-Jones and the SNAP potentials. Below are the minimal instructions to build that mini app.

The following installation consists in first building both the ``ONIKA`` HPC platform and the ``exaNBody`` particle simulation platform. Below are instructions for building both as well as final instruction for running the SNAP case where the initial system is read from a dump file.

For all the codes, a single installation method through the use of ``CMake`` is provided, dedicated to both users and developer. The use of ``CMake`` allows the full support on both `CPU` and `GPU` architectures.

Build YAML from sources
^^^^^^^^^^^^^^^^^^^^^^^

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

   git clone --branch onk-bench-microstamp git@github.com:Collab4exaNBody/onika.git
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
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${ONIKA_INSTALL_DIR} \
               -Dyaml-cpp_DIR=${YAML_CPP_INSTALL_DIR} \
               -DONIKA_BUILD_CUDA=ON \
               -DCMAKE_CUDA_COMPILER=${PATH_TO_NVCC} \
               -DCMAKE_CUDA_ARCHITECTURES=${ARCH} \
               -DONIKA_SETUP_ENV_COMMANDS="${ONIKA_SETUP_ENV_COMMANDS}" \
               ${ONIKA_SRC_DIR}

        make -j20 install
               
   .. tab:: **UBUNTU 22.04 | GCC 12.3.0**
            
      .. code-block:: bash

         ONIKA_INSTALL_DIR=${HOME}/local/onika
         ONIKA_SETUP_ENV_COMMANDS=""
         cmake -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=${ONIKA_INSTALL_DIR} \
               -Dyaml-cpp_DIR=${YAML_CPP_INSTALL_DIR} \
               -DONIKA_BUILD_CUDA=OFF \
               -DONIKA_SETUP_ENV_COMMANDS="${ONIKA_SETUP_ENV_COMMANDS}" \
               ${ONIKA_SRC_DIR}

        make -j20 install

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

   git clone --branch xnb-bench-microstamp git@github.com:Collab4exaNBody/exaNBody.git
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
               -DEXANB_BUILD_CONTRIB_MD=ON \
               -DEXANB_BUILD_MICROSTAMP=ON \
	             ${XNB_SRC_DIR}

         make -j20 install
         source ./exaNBody
         
Run the SNAP benchmark
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   tar -zxvf benchmark-snap-new.tgz
   cd benchmark-snap-new/
   ${ONIKA_INSTALL_DIR}/bin/onika-exec snap_from_dump.msp
   
   # To increase the number of cells (thus number of used cuda blocks)
   # and the total number of particles, one can add the --set-replicate_domain-repeat "[Nx,Ny,Nz]"
   # where Nx, Ny, Nz are the number of replication in each direction of the 3D space.
   
   # Example for replicating 8 times (2 in each direction):
   ${ONIKA_INSTALL_DIR}/bin/onika-exec snap_from_dump.msp --set-replicate_domain-repeat "[2,2,2]"

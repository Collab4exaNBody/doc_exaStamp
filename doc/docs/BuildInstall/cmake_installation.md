---
icon: simple/cmake
---
  
# **Installation with CMake**

``exaStamp`` installation first consists in building both the ``ONIKA`` HPC platform and the ``exaNBody`` particle simulation framework. Below are instructions for building both as well as final instruction for building ``exaStamp``. Please note that the required minimal `CMake` version is `3.26`. 

## **Minimal requirements**

### **YAML library**

All three platforms extensively use the ``YAML`` Library. To build ``YAML`` from sources, read the following instructions. Installations procedures using `spack`, `apt-get` or `CMake` are provided.

!!! note "Installation procedure for YAML"

    === "CMake"

        ```py
        def funct(a,b):
            return 0
        ```  
        ```{ .bash }
        # Retrieve YAML sources into temporary folder
        YAMLTMPFOLDER=${path_to_tmp_yaml}
        mkdir ${YAMLTMPFOLDER} && cd ${YAMLTMPFOLDER}
        git clone --depth 1 --branch yaml-cpp-0.6.3 git@github.com:jbeder/yaml-cpp.git

        # Define installation directory
        YAML_CPP_INSTALL_DIR=${HOME}/local/yaml-cpp-0.6.3

        # Build and install YAML from sources using CMake 
        cd ${YAMLTMPFOLDER} && mkdir build && cd build
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
        export YAML_CPP_INSTALL_DIR=${YAML_CPP_INSTALL_DIR}/yaml-cpp-0.6.3
        # Remove temporary folder
        cd ../..
        rm -r ${YAMLTMPFOLDER}            
        ```  
  
    === "Spack"

        ``` bash
        spack install yaml-cpp@0.6.3
        spack load yaml-cpp@0.6.3
        ```

    === "apt-get install"

        ``` bash
        sudo apt-get install libyaml-cpp-dev
        ```  
    
At this point, you should have YAML installed on your system. Please note that the installation procedure of YAML from sources using `CMake` also works on HPC clusters. In the following, remember to add the `-DCMAKE_PREFIX_PATH=${YAML_CPP_INSTALL_DIR} argument to your cmake command.

### **Onika**

`ONIKA` (Object Network Interface for Knit Applications), is a component based HPC software platform to build numerical simulation codes. It is the foundation for the `exaNBody` particle simulation platform but is not bound to N-Body problems nor other domain specific simulation code. Existing applications based on its building blocks include Molecular Dynamics, particle based fluid simulations using methods such as Smooth Particle Hydrodynamics (SPH) or rigid body simulations using methods such as Discrete Element Method (DEM). It uses industry grade standards and widely adopted technologies such as CMake and C++20 for development and build, `YAML` for user input files, MPI and OpenMP for parallel programming, Cuda and HIP for GPU acceleration. To build `ONIKA` from sources, read the following instructions.

!!! note "Installation procedure for ONIKA"

    === "UBUNTU CPU"

        ``` bash
        # Adapt depending on where you want to download onika
        cd ${HOME}/dev
        git clone git@github.com:Collab4exaNBody/onika.git
        ONIKA_SRC_DIR=${HOME}/dev/onika
        ONIKA_INSTALL_DIR=${HOME}/local/onika            
        mkdir build_onika && cd build_onika

        ONIKA_SETUP_ENV_COMMANDS=""
        eval ${ONIKA_SETUP_ENV_COMMANDS}
        cmake -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${ONIKA_INSTALL_DIR} \
              -Dyaml-cpp_DIR=${YAML_CPP_INSTALL_DIR} \
              -DONIKA_BUILD_CUDA=OFF \
              -DONIKA_SETUP_ENV_COMMANDS="${ONIKA_SETUP_ENV_COMMANDS}" \
              ${ONIKA_SRC_DIR}
        make -j4 install
        ```
  
    === "UBUNTU GPU"
            
        ``` bash
        # Adapt depending on where you want to download onika
        cd ${HOME}/dev
        git clone git@github.com:Collab4exaNBody/onika.git
        ONIKA_SRC_DIR=${HOME}/dev/onika
        ONIKA_INSTALL_DIR=${HOME}/local/onika            
        mkdir build_onika && cd build_onika

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
        ```
  
    === "Rhel x INTEL x CUDA"

        ``` bash
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
        make -j32 install
        ```
  
    === "Rhel x GCC x CUDA"

        ``` bash
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
        make -j32 install                
        ```
  
### **exaNBody**

`exaNBody` is a software platform to build-up numerical simulations solving N-Body like problems.
Typical applications include Molecular Dynamics, particle based fluid simulations using methods such as Smooth Particle Hydrodynamics (SPH) or rigid body simulations using methods such as Discrete Element Method (DEM). It uses standard and widely adopted technologies such as C++20, YAML, OpenMP , Cuda or HIP. When installing `exaNBody`, first sourcing the `ONIKA` environment will automatically update whether CUDA is activated or not.

!!! note "Installation procedure for exaNBody"

    === "UBUNTU"
            
        ``` bash
        # Adapt depending on where you want to download ``exaNBody``
        cd ${HOME}/dev
        git clone -b release-2.0 git@github.com:Collab4exaNBody/exaNBody.git
        XNB_SRC_DIR=${HOME}/dev/exaNBody
        XNB_INSTALL_DIR=${HOME}/local/exaNBody
        mkdir build_exaNBody && cd build_exaNBody

        source ${ONIKA_INSTALL_DIR}/bin/setup-env.sh
        cmake -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${XNB_INSTALL_DIR} \
              -Donika_DIR=${ONIKA_INSTALL_DIR} \
              ${XNB_SRC_DIR}
        make -j4 install
        ```
          
    === "Rhel x INTEL"

        ``` bash
        # Adapt depending on where you want to download ``exaNBody``
        cd ${HOME}/dev
        git clone -b release-2.0 git@github.com:Collab4exaNBody/exaNBody.git
        XNB_SRC_DIR=${HOME}/dev/exaNBody
        XNB_INSTALL_DIR=${HOME}/local/exaNBody
        mkdir build_exaNBody && cd build_exaNBody

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
        make -j32 install
        ```

    === "Rhel x GCC"
            
        ```bash
        XNB_INSTALL_DIR=${HOME}/local/exaNBody
        source ${ONIKA_INSTALL_DIR}/bin/setup-env.sh
        cmake -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${XNB_INSTALL_DIR} \
              -Donika_DIR=${ONIKA_INSTALL_DIR} \
              ${XNB_SRC_DIR}
        make -j32 install
        ```

## exaStamp installation

When installing `exaStamp`, first sourcing the `exaNBody` environment will automatically update whether CUDA is activated or not.

!!! note "Installation procedure for exaStamp"

    === "UBUNTU"
            
        ```bash
        # Adapt depending on where you want to download ``exaStamp``
        cd ${HOME}/dev
        git clone -b exaNBody-release-2.0 git@github.com:Collab4exaNBody/exaStamp.git
        XSP_SRC_DIR=${HOME}/dev/exaStamp
        mkdir build_exaStamp && build_exaStamp

        XSP_INSTALL_DIR=${HOME}/local/exaStamp
        source ${XNB_INSTALL_DIR}/bin/setup-env.sh
        cmake -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${XSP_INSTALL_DIR} \
              -DexaNBody_DIR=${XNB_INSTALL_DIR} \
              ${XSP_SRC_DIR}
        make -j4 install
        source ${XSP_INSTALL_DIR}/bin/setup-env.sh
        ```
  
    === "Rhel x INTEL"

        ```bash
        XSP_INSTALL_DIR=${HOME}/local/exaStamp
        source ${XNB_INSTALL_DIR}/bin/setup-env.sh
        CXX_COMPILER=`which icpx`
        C_COMPILER=`which icx`
        cmake -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${XSP_INSTALL_DIR} \
              -DCMAKE_C_COMPILER=${C_COMPILER} \
              -DCMAKE_CXX_COMPILER=${CXX_COMPILER} \
              -DCMAKE_CXX_FLAGS=-diag-disable=15518,15552 \
              -DexaNBody_DIR=${XNB_INSTALL_DIR} \
              ${XSP_SRC_DIR}        
        make -j32 install
        source ${XSP_INSTALL_DIR}/bin/setup-env.sh      
        ```

    === "Rhel x GCC"
            
        ```bash
        XNB_INSTALL_DIR=${HOME}/local/exaNBody
        source ${XNB_INSTALL_DIR}/bin/setup-env.sh
        cmake -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_INSTALL_PREFIX=${XSP_INSTALL_DIR} \
              -DexaNBody_DIR=${ONIKA_INSTALL_DIR} \
              ${XSP_SRC_DIR}
        make -j32 install
        source ${XSP_INSTALL_DIR}/bin/setup-env.sh      
        ```  
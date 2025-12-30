---
icon: simple/cmake
---
  
# **Installation with CMake**

`exaStamp` installation first consists in building both the `onika` HPC layout as well as the `exaNBody` particles simulation framework. Below are instructions for building both as well as final instruction for building `exaStamp`. Please note that the required minimal `CMake` version is `3.26`. 

## **Minimal requirements**

### **YAML library**

All three platforms extensively use the ``YAML`` Library. To build ``YAML`` from sources, read the following instructions. Installations procedures using `apt-get`, `spack`  or `CMake` are provided.

=== "`apt-get`"

    ```bash linenums="1"
    sudo apt-get install libyaml-cpp-dev
    ```
    
=== "`Spack`"

    ```bash linenums="1"
    spack install yaml-cpp@0.6.3
    spack load yaml-cpp@0.6.3
    ```

=== "`CMake`"

    ```bash linenums="1" hl_lines="1 7 11 25"
    # 1. Retrieve yaml-cpp-0.6.3 sources into temporary folder
    
    YAMLTMPFOLDER=${path_to_tmp_yaml}
    mkdir ${YAMLTMPFOLDER} && cd ${YAMLTMPFOLDER}
    git clone --depth 1 --branch yaml-cpp-0.6.3 git@github.com:jbeder/yaml-cpp.git

    # 2. Setup environment variable for installation directory (add this to your .bashrc)
    
    export YAML_CPP_INSTALL_DIR=${HOME}/local/yaml-cpp-0.6.3

    # 3. Build and install using CMake
    
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
    
    # 4. Remove the temporary folder
    cd ../../
    rm -r ${YAMLTMPFOLDER}
    ```
    
At this point, you should have YAML installed on your system. Please note that the installation procedure of YAML from sources using `CMake` also works on HPC clusters. In the following, remember to add the `-DCMAKE_PREFIX_PATH=${YAML_CPP_INSTALL_DIR} argument to your `CMake` command.

### **Onika**

`onika` (Object Network Interface for Knit Applications), is a component based HPC software platform to build numerical simulation codes. It is the foundation for the `exaNBody` particle simulation platform but is not bound to N-Body problems nor other domain specific simulation code. `onika` uses industry grade standards and widely adopted technologies such as `CMake` and `C++20` for development and build, `YAML` for user input files, `MPI` and `OpenMP` for parallel programming, `Cuda` and `HIP` for GPU acceleration. To build `onika` from sources, read the following instructions. First, create and go to a directory in which you'll download the sources and declare some environment variables.

```bash linenums="1"
cd ${HOME}/dev
git clone git@github.com:Collab4exaNBody/onika.git
export ONIKA_SRC_DIR=${HOME}/dev/onika
export ONIKA_INSTALL_DIR=${HOME}/local/onika
```

Finally, build and install `onika` using the following instructions depending on the platform. Available instructions are for Linux machines with and without `Cuda`support.

=== "`Linux x GCC`"

    ```bash linenums="1"
    mkdir build_onika && cd build_onika
    ONIKA_SETUP_ENV_COMMANDS=""
    eval ${ONIKA_SETUP_ENV_COMMANDS}
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${ONIKA_INSTALL_DIR} \
          -DCMAKE_PREFIX_PATH=${YAML_CPP_INSTALL_DIR} \
          -DONIKA_BUILD_CUDA=OFF \
          -DONIKA_SETUP_ENV_COMMANDS="${ONIKA_SETUP_ENV_COMMANDS}" \
          ${ONIKA_SRC_DIR}
    make -j4 install
    ```
  
=== "`Linux x GCC x CUDA`"
            
    ``` bash linenums="1"
    mkdir build_onika && cd build_onika
    ONIKA_SETUP_ENV_COMMANDS=""
    PATH_TO_NVCC=$(which nvcc)
    eval ${ONIKA_SETUP_ENV_COMMANDS}
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${ONIKA_INSTALL_DIR} \
          -DCMAKE_PREFIX_PATH=${YAML_CPP_INSTALL_DIR} \
          -DONIKA_BUILD_CUDA=ON \
          -DCMAKE_CUDA_COMPILER=${PATH_TO_NVCC} \
          -DCMAKE_CUDA_ARCHITECTURES=${ARCH} \
          -DONIKA_SETUP_ENV_COMMANDS="${ONIKA_SETUP_ENV_COMMANDS}" \
          ${ONIKA_SRC_DIR}
    make -j4 install
    ```
  
### **exaNBody**

`exaNBody` is a software platform to build-up numerical simulations solving N-Body like problems. To build `exaNBody` from sources, read the following instructions. First, create and go to a directory in which you'll download the sources and declare some environment variables.

```bash linenums="1"
cd ${HOME}/dev
git clone git@github.com:Collab4exaNBody/exaNBody.git
export XNB_SRC_DIR=${HOME}/dev/exaNBody
export XNB_INSTALL_DIR=${HOME}/local/exaNBody
```

Finally, build and install `exaNBody` using the following instructions. First sourcing the `onika` environment will automatically update whether `cuda` support is available.

```bash linenums="1"
mkdir build_exaNBody && cd build_exaNBody
source ${ONIKA_INSTALL_DIR}/bin/setup-env.sh
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${XNB_INSTALL_DIR} \
      -Donika_DIR=${ONIKA_INSTALL_DIR} \
      ${XNB_SRC_DIR}
make -j4 install
```

## exaStamp installation

To build `exaStamp` from sources, read the following instructions. First, create and go to a directory in which you'll download the sources and declare some environment variables.

```bash linenums="1"
cd ${HOME}/dev
git clone git@github.com:Collab4exaNBody/exaStamp.git
export XSP_SRC_DIR=${HOME}/dev/exaStamp
export XSP_INSTALL_DIR=${HOME}/local/exaStamp
```

Finally, build and install `exaStamp` using the following instructions. First sourcing the `exaNBody` environment will automatically update whether `cuda` support is available.

```bash
mkdir build_exaStamp && build_exaStamp
source ${XNB_INSTALL_DIR}/bin/setup-env.sh
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${XSP_INSTALL_DIR} \
      -DexaNBody_DIR=${XNB_INSTALL_DIR} \
      ${XSP_SRC_DIR}
make -j4 install
```

---
icon: simple/linux
---

# **Installation with Spack**

Installation with `Spack` is easy and preferable for users who don't want to develop in `exaStamp`. Only stable versions are added when you install `exaStamp` with `Spack` (version `1.1.0`), meaning that it doesn't provide you access to the development branches. In addition, the main branch of `exaStamp` will never be directly accessible via this installation method.

## **Minimal requirements**

### **Spack package manager**

Below are instructions to first retrieve spack sources and install it on your system. First, clone the corresponding git repository and source the appropriate environment.

!!! note "Clone Spack"
  
    ```bash
    cd ${HOME}/dev
    git clone --depth=2 --branch=v1.1.0 https://github.com/spack/spack.git
    export SPACK_ROOT=${HOME}/dev/spack
    source ${SPACK_ROOT}/share/spack/setup-env.sh
    ```

### **YAML library**

All three platforms extensively use the ``YAML`` Library. To build ``YAML`` from sources, read the following instructions. Installations procedures using `spack`, `apt-get` or `CMake` are provided.

!!! note "Installation procedure for YAML"

    === "Spack"

        ``` bash
        spack install yaml-cpp@0.6.3
        spack load yaml-cpp@0.6.3
        ```

    === "apt-get install"

        ``` bash
        sudo apt-get install libyaml-cpp-dev
        ```  

    === "CMake"

        ``` bash
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
    
At this point, you should have YAML installed on your system. Please note that the installation procedure of YAML from sources using `CMake` also works on HPC clusters. In the following, remember to add the `-DCMAKE_PREFIX_PATH=${YAML_CPP_INSTALL_DIR} argument to your cmake command.

## **exaStamp installation**

First, clone the `spack-repos` GitHub repository on your computer and add this repository to spack. This repository contains `onika`, `exaNBody` and `exaStamp` recipes that allow for their installation.

!!! note "Clone spack-repos"
  
    ```bash
    git clone https://github.com/Collab4exaNBody/spack-repos.git
    spack repo add spack-repos
    ```

Then, simply install `exaStamp` using the following command.

!!! note "Install exaStamp"
  
    ```bash
    spack install exastamp
    ```

If you have a GPU on your machine, you can also ask for a CUDA installation through the following command:
  
!!! note "Install exaStamp with CUDA support"

    ```bash
    spack install exastamp+cuda
    ```

The default version will be the latest stable release. However, you can also ask for a specific branch as follow:

!!! note "Install exaStamp specific version"
  
    ```bash
    spack install exastamp@3.7.2
    spack install exastamp@3.7.0
    ```

Finally, the commands listed above will install the appropriate version of `cmake`, `yaml-cpp`, `onika` and `exaNBody` and additional required packages by the `exaStamp` recipe. Eventually, to run an `exaStamp` case, do the following:

!!! note "Install exaStamp"
  
    ```bash
    spack load exastamp
    exaStamp myinput.msp
    ```
    

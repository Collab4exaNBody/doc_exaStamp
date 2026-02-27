---
icon: simple/linux
---

# **Installation with Spack**

Installation with `Spack` is easy and preferable for users who don't want to develop in `microStamp` or `exaNBody`. Only stable versions are added when you install `exaNBody` with `Spack`, meaning that it doesn't provide you access to the development branches. In addition, the main branch of `exaNBody` will never be directly accessible via this installation method.

## **Minimal requirements**

### **Spack package manager**

Below are instructions to first retrieve spack sources and install it on your system. First, clone the corresponding git repository and source the appropriate environment.

```bash
cd ${HOME}/dev
git clone --depth=2 --branch=v1.1.0 https://github.com/spack/spack.git
export SPACK_ROOT=${HOME}/dev/spack
source ${SPACK_ROOT}/share/spack/setup-env.sh
```

### **YAML library**

All three platforms extensively use the ``YAML`` Library. To build ``YAML`` from sources, read the following instructions. Installations procedures using `spack`, `apt-get` or `CMake` are provided.
    
=== "`Spack`"

    ```bash linenums="1"
    spack install yaml-cpp@0.6.3
    spack load yaml-cpp@0.6.3
    ```
  
=== "`apt-get`"

    ```bash linenums="1"
    sudo apt-get install libyaml-cpp-dev
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
    
At this point, you should have YAML installed on your system. Please note that the installation procedure of YAML from sources using `CMake` also works on HPC clusters. In the following, remember to add the `-DCMAKE_PREFIX_PATH=${YAML_CPP_INSTALL_DIR} argument to your cmake command.

## **exaNBody x microStamp**

First, clone the `spack-repos` GitHub repository on your computer and add this repository to spack. This repository contains `onika` and `exaNBody` recipes that allow for their installation.

```bash
git clone https://github.com/Collab4exaNBody/spack-repos.git
spack repo add spack-repos
```

Then, simply install `exaNBody`. To get access to the `microStamp` mini application, you need to require the `contribs` variant as follows:

=== "`Linux x GCC`"
    
    ```bash
    spack install exanbody+contribs
    ```

=== "`Linux x GCC x CUDA`"
  
    ```bash
    spack install exanbody+contribs+cuda
    ```

The default version will be the latest stable release.
    
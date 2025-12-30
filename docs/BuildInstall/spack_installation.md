---
icon: simple/linux
---

# **Installation with Spack**

Installation with `Spack` is easy and preferable for users who don't want to develop in `exaStamp`. Only stable versions are added when you install `exaStamp` with `Spack` (version `1.1.0`), meaning that it doesn't provide you access to the development branches. In addition, the main branch of `exaStamp` will never be directly accessible via this installation method.

## **Minimal requirements**

### **Spack package manager**

Below are instructions to first retrieve spack sources and install it on your system. First, clone the corresponding git repository and source the appropriate environment.

```bash linenums="1" hl_lines="1 7"
# 1. Retrieve Spack and add the path to your .bashrc

mkdir ${HOME}/dev && cd ${HOME}/dev
git clone --depth=2 --branch=v1.1.0 https://github.com/spack/spack.git
export SPACK_ROOT=${HOME}/dev/spack

# 2. Activate the Spack environment

source ${SPACK_ROOT}/share/spack/setup-env.sh
```

### **YAML library**

All three platforms extensively use the ``YAML`` library. It can be easily installed through `spack` as follows:

```bash linenums="1"
spack install yaml-cpp@0.6.3
spack load yaml-cpp@0.6.3
```
    
At this point, you should have YAML installed on your system. Please note that the installation procedure of YAML from sources using `CMake` also works on HPC clusters. In the following, remember to add the `-DCMAKE_PREFIX_PATH=${YAML_CPP_INSTALL_DIR} argument to your cmake command.

## **exaStamp installation**

First, clone the `spack-repos` GitHub repository on your computer and add this repository to spack. This repository contains `onika`, `exaNBody` and `exaStamp` recipes allowing for their installation.
  
```bash linenums="1"
git clone https://github.com/Collab4exaNBody/spack-repos.git
spack repo add spack-repos
```

Then, `exaStamp` can be installed using the following command:
  
```bash linenums="1"
spack install exastamp
```

If you are lucky enough to have a `GPU` on your machine, you can also ask for a `CUDA` installation through the following command:

```bash linenums="1"
spack install exastamp+cuda
```

The default version that will be installed systematically corresponds to the latest stable release. If for any reason you wand to install a specific (older) version, you can require it as follows:
  
```bash linenums="1"
spack install exastamp@3.7.4
spack install exastamp@3.7.3
spack install exastamp@3.7.2
spack install exastamp@3.7.0
```

Thanks to the `spack` ecosystem, appropriate versions of `cmake`, `yaml-cpp`, `onika` and `exaNBody` will be automatically installed, as well as any package required by `exaStamp`.

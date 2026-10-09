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
    
At this point, you should have YAML installed on your system. Please note that the installation procedure of YAML from sources using `CMake` also works on HPC clusters. In the following, remember to add the `-DCMAKE_PREFIX_PATH=${YAML_CPP_INSTALL_DIR}` argument to your `CMake` command.

### **Onika**

`onika` (Object Network Interface for Knit Applications), is a component based HPC software platform to build numerical simulation codes. It is the foundation for the `exaNBody` particle simulation platform but is not bound to N-Body problems nor other domain specific simulation code. `onika` uses industry grade standards and widely adopted technologies such as `CMake` and `C++20` for development and build, `YAML` for user input files, `MPI` and `OpenMP` for parallel programming, `Cuda` and `HIP` for GPU acceleration. To build `onika` from sources, read the following instructions. First, create and go to a directory in which you'll download the sources and declare some environment variables.

```bash linenums="1"
cd ${HOME}/dev
git clone git@github.com:Collab4exaNBody/onika.git
export ONIKA_SRC_DIR=${HOME}/dev/onika
export ONIKA_INSTALL_DIR=${HOME}/local/onika
```

Finally, build and install `onika` using the following instructions depending on the platform. Available instructions are for Linux machines without GPU, with `Cuda` (NVIDIA) and with `HIP` (AMD) support.

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
  
=== "`Linux x GCC x HIP`"

    ``` bash linenums="1"
    mkdir build_onika && cd build_onika
    ONIKA_SETUP_ENV_COMMANDS=""
    eval ${ONIKA_SETUP_ENV_COMMANDS}
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${ONIKA_INSTALL_DIR} \
          -DCMAKE_PREFIX_PATH=${YAML_CPP_INSTALL_DIR} \
          -DONIKA_BUILD_CUDA=ON \
          -DONIKA_ENABLE_HIP=ON \
          -DROCM_INSTALL_ROOT=/opt/rocm \
          -DCMAKE_HIP_ARCHITECTURES=${ARCH} \
          -DONIKA_SETUP_ENV_COMMANDS="${ONIKA_SETUP_ENV_COMMANDS}" \
          ${ONIKA_SRC_DIR}
    make -j4 install
    ```

!!! note "GPU options"

    `ONIKA_BUILD_CUDA=ON` enables GPU acceleration. With `ONIKA_ENABLE_HIP=ON`, `HIP` is used instead of `Cuda`. `ROCM_INSTALL_ROOT` defaults to `/opt/rocm`. `${ARCH}` is the target GPU architecture (e.g. `80` for an NVIDIA A100 with `Cuda`, `gfx90a` for an AMD MI250 with `HIP`).

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
      -DEXANB_BUILD_CONTRIB_MD=ON \
      -DEXANB_BUILD_MICROSTAMP=ON \
      -DEXANB_BUILD_CONTRIB_PI=ON \
      -DEXANB_BUILD_MICROCOSMOS=ON \
      ${XNB_SRC_DIR}
make -j4 install
```

!!! note "SNAP potentials"

    `-DEXANB_BUILD_CONTRIB_MD=ON` builds the molecular dynamics contribs of `exaNBody`, which provide the SNAP kernels used by `exaStamp`. Keep it `ON` to be able to build SNAP in `exaStamp` (see [machine learning potentials](#machine-learning-potentials)). The `exaNBody` option `SNAP_FP32_MATH` (default `ON`) selects single precision for the `snap_force` operator.

## **exaStamp installation**

To build `exaStamp` from sources, read the following instructions. First, create and go to a directory in which you'll download the sources and declare some environment variables.

```bash linenums="1"
cd ${HOME}/dev
git clone git@github.com:Collab4exaNBody/exaStamp.git
export XSP_SRC_DIR=${HOME}/dev/exaStamp
export XSP_INSTALL_DIR=${HOME}/local/exaStamp
```

Finally, build and install `exaStamp` using the following instructions. First sourcing the `exaNBody` environment will automatically update whether GPU support is available.

```bash linenums="1"
mkdir build_exaStamp && cd build_exaStamp
source ${XNB_INSTALL_DIR}/bin/setup-env.sh
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${XSP_INSTALL_DIR} \
      -DexaNBody_DIR=${XNB_INSTALL_DIR} \
      ${XSP_SRC_DIR}
make -j4 install
```

Optional features and packages are enabled by adding `-D<OPTION>=<VALUE>` arguments to the `cmake` command above (or interactively with `ccmake .` in the build directory). They are described in the next section.

## **Build options and optional packages**

### **General options**

<div class="center-table" markdown>

| Option | Default | Description |
|---|---|---|
| `CMAKE_BUILD_TYPE` | `Release` | `Release`, `RelWithDebInfo` or `Debug` |
| `EXASTAMP_ENABLE_MOLECULE` | `ON` | Support for rigid and flexible molecules |
| `EXASTAMP_ENABLE_MECHANICAL` | `ON` | Support for mechanical analysis operators |
| `EXASTAMP_ENABLE_PAIR_WEIGHTING` | `ON` | Support for weighted pair potentials |
| `EXASTAMP_BUILD_CONTRIBS` | `OFF` | Build the contributed tools in `contribs/` |
| `USE_RSA` | `OFF` | Random sequential adsorption package (`init_rsa`), requires the `rsa_mpi` library |
| `YAML_CPP_INSTALL_DIR` | empty | `yaml-cpp` installation directory |

</div>

### **Compile-time limits**

Some data structures have a fixed maximum size set at compile time. Increase these values only if a simulation requires it, since they impact memory usage and performance.

<div class="center-table" markdown>

| Option | Default | Description |
|---|---|---|
| `XSTAMP_MAX_MOLECULE_ATOMS` | `24` | Maximum number of atoms in a flexible molecule |
| `XSTAMP_MAX_MOLECULE_BONDS` | `24` | Maximum number of bonds in a molecule |
| `XSTAMP_MAX_MOLECULE_BENDS` | `24` | Maximum number of bends (angles) in a molecule |
| `XSTAMP_MAX_MOLECULE_TORSIONS` | `24` | Maximum number of torsions in a molecule |
| `XSTAMP_MAX_MOLECULE_IMPROPERS` | `24` | Maximum number of impropers in a molecule |
| `XSTAMP_MAX_MOLECULE_PAIRS` | `32` | Maximum number of distant atom pairs in a molecule |
| `XSTAMP_MAX_RIGID_MOLECULE_ATOMS` | `4` | Maximum number of atoms in a rigid molecule |
| `XSTAMP_MEAM_MAX_NEIGHBORS` | `32` | MEAM maximum number of neighbors per atom |
| `XSTAMP_MEAM_MULTIMAT_MAX_TYPES` | `4` | MEAM maximum number of atom types |
| `XSTAMP_MEAM_ENFORCE_OVERFLOW_CHECK` | `OFF` | MEAM compute buffer overflow checking |
| `XSTAMP_MEAM_MERGE_FORCE_UPDATES` | `ON` | MEAM merged force updates |
| `XSTAMP_MEAM_USE_SHARED_MEM` | `OFF` | MEAM uses more GPU shared memory and fewer local variables |

</div>

### **Machine learning potentials**

Each machine learning potential lives in its own plugin and is disabled by default. Enable it with the corresponding `EXASTAMP_MLIP_<NAME>_BUILD` option. Nothing from a disabled package is compiled.

<div class="center-table" markdown>

| Option | Potential | Plugin | External dependency |
|---|---|---|---|
| `EXASTAMP_MLIP_SNAP_BUILD` | SNAP (and legacy SNAP) | `exaStampMlipSnap`, `exaStampMlipSnapLegacy` | `exaNBody` built with `EXANB_BUILD_CONTRIB_MD=ON` |
| `EXASTAMP_MLIP_POD_BUILD` | POD | `exaStampMlipPOD` | BLAS and LAPACK |
| `EXASTAMP_MLIP_MTP_BUILD` | MTP | `exaStampMlipMTP` | none |
| `EXASTAMP_MLIP_PACE_BUILD` | ACE (PACE) | `exaStampMlipPace` | PACE library, downloaded at configure time |
| `EXASTAMP_MLIP_N2P2_BUILD` | Behler-Parrinello NNP (n2p2) | `exaStampMlipN2P2` | n2p2 installation |
| `EXASTAMP_MLIP_SNAPLMP_BUILD` | SNAP, reference implementation | `exaStampMlipSnapLMP` | external SNAP reference source tree, `exaNBody` built with `EXANB_BUILD_CONTRIB_MD=ON` |

</div>

=== "SNAP"

    ```bash
    -DEXASTAMP_MLIP_SNAP_BUILD=ON
    ```

    The SNAP kernels are provided by `exaNBody`, which must be built with `-DEXANB_BUILD_CONTRIB_MD=ON`. If they are not available, the option has no effect. The `exaNBody` option `SNAP_FP32_MATH` (default `ON`) makes the `snap_force` operator compute in single precision; the `snap_force_fp64` operator always computes in double precision.

=== "POD"

    ```bash
    -DEXASTAMP_MLIP_POD_BUILD=ON \
    -DEXASTAMP_MLIP_POD_BLAS_VENDOR=OpenBLAS
    ```

    POD requires BLAS and LAPACK. `EXASTAMP_MLIP_POD_BLAS_VENDOR` (default empty, CMake auto-selects) is passed to CMake's `BLA_VENDOR` to select a specific implementation, e.g. `OpenBLAS`, `Intel10_64lp` or `Generic`.

=== "MTP"

    ```bash
    -DEXASTAMP_MLIP_MTP_BUILD=ON
    ```

    MTP has no external dependency.

=== "ACE (PACE)"

    ```bash
    -DEXASTAMP_MLIP_PACE_BUILD=ON \
    -DEXASTAMP_MLIP_PACE_GIT_REPO=git@github.com:Collab4exaNBody/exaStamp_mlip_pace.git \
    -DEXASTAMP_MLIP_PACE_GIT_TAG=main
    ```

    At configure time, the PACE library is cloned from `EXASTAMP_MLIP_PACE_GIT_REPO` (branch or tag `EXASTAMP_MLIP_PACE_GIT_TAG`, default `main`) into `<build>/external/pace`, then built with `exaStamp`. If that directory already contains a clone, it is reused. The machine running `cmake` therefore needs access to the repository. PACE uses `yaml-cpp` (see `YAML_CPP_INSTALL_DIR`).

=== "n2p2"

    ```bash
    -DEXASTAMP_MLIP_N2P2_BUILD=ON \
    -DEXASTAMP_MLIP_N2P2_ROOT_DIR=${HOME}/local/n2p2
    ```

    `EXASTAMP_MLIP_N2P2_ROOT_DIR` (default `/usr/local/n2p2`) must point to an n2p2 installation containing `include/`, `lib/libnnp.so` and `lib/libnnpif.so`. If the directory does not exist, the package is disabled with a configure message.

=== "SNAP reference"

    ```bash
    -DEXASTAMP_MLIP_SNAPLMP_BUILD=ON \
    -DEXASTAMP_MLIP_SNAPLMP_LMP_SRC_DIR=/path/to/reference/source/tree
    ```

    This package compiles the SNAP kernels of an external SNAP reference source tree, pointed to by `EXASTAMP_MLIP_SNAPLMP_LMP_SRC_DIR`. It is mostly useful for validation. It is disabled with a configure message if the directory does not exist or if `exaNBody` was built without `EXANB_BUILD_CONTRIB_MD=ON`.

!!! warning "Renamed options"

    The machine learning options were renamed. Update your build scripts if they use the old names:

    | Old option | New option |
    |---|---|
    | `EXASTAMP_BUILD_PACE` | `EXASTAMP_MLIP_PACE_BUILD` |
    | `PACE_GIT_REPO`, `PACE_GIT_TAG` | `EXASTAMP_MLIP_PACE_GIT_REPO`, `EXASTAMP_MLIP_PACE_GIT_TAG` |
    | `EXASTAMP_BUILD_POD` | `EXASTAMP_MLIP_POD_BUILD` |
    | `EXASTAMP_POD_BLAS_VENDOR` | `EXASTAMP_MLIP_POD_BLAS_VENDOR` |
    | `N2P2_ROOT_DIR` | `EXASTAMP_MLIP_N2P2_ROOT_DIR` (and `EXASTAMP_MLIP_N2P2_BUILD=ON`) |
    | `LMP_SRC_DIR` | `EXASTAMP_MLIP_SNAPLMP_LMP_SRC_DIR` (and `EXASTAMP_MLIP_SNAPLMP_BUILD=ON`) |
    | SNAP built automatically with `exaNBody`'s MD contribs | `EXASTAMP_MLIP_SNAP_BUILD=ON` |

    The plugins were renamed accordingly (`exaStampSnap` → `exaStampMlipSnap`, `exaStampPOD` → `exaStampMlipPOD`, ...). When re-installing into an existing prefix, remove the old plugin libraries from `${XSP_INSTALL_DIR}/plugins` so they are not loaded together with the new ones.

### **Long-range electrostatics (PPPM)**

The FFT backend used by the `coulombic_pppm` operator is selected automatically from the `onika` GPU configuration. No option is required.

<div class="center-table" markdown>

| `onika` build | FFT backend | Requirement |
|---|---|---|
| CPU only | pocketfft (bundled) | none |
| `Cuda` | cuFFT | Cuda toolkit (always available with `Cuda`) |
| `HIP` | hipFFT | hipFFT found in `ROCM_INSTALL_ROOT` (default `/opt/rocm`) or `$ROCM_PATH`; falls back to pocketfft on CPU otherwise |

</div>

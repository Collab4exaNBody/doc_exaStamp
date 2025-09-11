---
icon: material/remote-desktop

---

## Installing SLOTH On Supercomputers Without Internet Access

This guide provides detailed steps to install SLOTH on a supercomputer without internet access using provided scripts. It includes using Spack for package management and compiling dependencies required by SLOTH.

Installing SLOTH on a supercomputer without internet access involves preparing the environment, downloading necessary components, creating a local Spack mirror, and building SLOTH with all dependencies.

### Use And Adapt Scripts

The installation is performed in two main parts using the scripts provided below:

1. `sloth-topaze-part1.sh`: Prepares the environment and creates an archive of necessary components.
2. `sloth-topaze-part2.sh`: Sets up Spack and compiles SLOTH on the target supercomputer.

Make sure to adapt the environment variables in the scripts (e.g., `MY_LOG`, `DEST_DIR`) to your specific user settings.

On your local machine:

```
source sloth-topaze-part1.sh
```

On your distant machine (Topaze in our example)

```
sloth-topaze-part2.sh
```

### Part 1: Preparing the Environment (`sloth-topaze-part1.sh`)

This script is designed to be run on a local machine with internet access. It sets up the environment, clones necessary repositories, prepares Spack, and packages everything into an archive for transfer to the supercomputer.

#### Step-by-Step Breakdown

1. **Define Root and Working Directories:**
   ```bash
   export ROOT_DIR=$PWD
   mkdir -p sloth-topaze-dir && cd sloth-topaze-dir
   export WORK_DIR=$ROOT_DIR/sloth-topaze-dir
   export MY_LOG=your_login      # Replace with your Topaze login
   export DEST_DIR=/path/to/destination # Replace with your destination directory
   ```
   - `ROOT_DIR` is set to the current directory.
   - Creates a subdirectory `sloth-topaze-dir` where all operations will occur.
   - `WORK_DIR` is set to the path of `sloth-topaze-dir`.
   - `MY_LOG` and `DEST_DIR` are placeholders for your supercomputer login and destination directory. You need to replace these with your actual login and path on the supercomputer.

2. **Clone Spack Repository:**
   ```bash
   echo "Getting Spack ..."
   if [ ! -d "spack" ]; then
       git clone --depth=2 --branch=v0.23.0 https://github.com/spack/spack.git
   fi
   export SPACK_ROOT=$PWD/spack
   rm -r ~/.spack
   source ${SPACK_ROOT}/share/spack/setup-env.sh
   ```
   - Clones Spack from GitHub.
   - Sets `SPACK_ROOT` to the path of the cloned Spack directory.
   - Removes any existing `.spack` configuration to ensure a clean setup.
   - Sources the Spack environment to set up paths and commands for use.

3. **Clone SLOTH Repository:**
   ```bash
   echo "Getting PLEIADES/SLOTH ..."
   if [ ! -d "sloth" ]; then
       git clone [https://www-git-cad.intra.cea.fr/DEC/collaboratif/ci230846/DEV_PROJECT/sloth.git](https://github.com/Collab4Sloth/SLOTH.git)
   fi
   ```
   - Similar to Spack, this step clones the SLOTH repository if it doesn't already exist in the working directory.

4. **Create a Spack Bootstrap Mirror:**
   ```bash
   spack bootstrap mirror --binary-packages my_bootstrap
   ```
   - Creates a bootstrap mirror that includes binary packages of the basic build tools that Spack needs to work offline.

5. **Create a Specific Spack Mirror for Dependencies:**
   ```bash
   spack mirror create -d mirror-mfem -D gcc@11.2.0 mfem+mpi+debug+openmp+petsc+strumpack+suite-sparse+sundials+superlu-dist+miniapps%gcc@11.2.0
   ```
   - Creates a mirror named `mirror-mfem` for all specified dependencies (`mfem`, `petsc`, etc.), ensuring that Spack can access these packages without internet access on the supercomputer.
   - You can add extra packages here.

6. **Package and Transfer Files:**
   ```bash
   cd $ROOT_DIR
   tar cvf archive.tar.gz sloth-topaze-dir/
   scp archive.tar.gz $MY_LOG@topaze.ccc.cea.fr:$DEST_DIR/
   ```
   - Archives the entire `sloth-topaze-dir` directory into `archive.tar.gz`.
   - Uses `scp` to securely copy this archive to the specified destination directory on the supercomputer. Replace `topaze.ccc.cea.fr` with the appropriate hostname if needed.

---

### Part 2: Setting Up and Building SLOTH (`sloth-topaze-part2.sh`)

This script is run on the supercomputer. It unpacks the archive, sets up the Spack environment, configures Spack to work offline, and builds SLOTH with all required dependencies.

#### Step-by-Step Breakdown

1. **Define Directories:**
   ```bash
   export DEST_DIR=$PWD
   export WORK_DIR=$DEST_DIR/sloth-topaze-dir
   ```
   - `DEST_DIR` is set to the current working directory (where the archive was transferred).
   - `WORK_DIR` points to the `sloth-topaze-dir` directory inside `DEST_DIR`.

2. **Clean Up and Extract the Archive:**
   ```bash
   rm -r ~/.spack
   cd $DEST_DIR
   tar xvf archive.tar.gz
   cd $WORK_DIR
   ```
   - Removes any existing Spack configuration (`~/.spack`) to ensure a fresh environment setup.
   - Extracts the archive (`archive.tar.gz`) containing all previously prepared files.

3. **Set Up Spack Environment:**
   ```bash
   source $WORK_DIR/spack/share/spack/setup-env.sh
   spack bootstrap reset -y
   spack bootstrap add --scope=site --trust local-binaries $PWD/my_bootstrap/metadata/binaries/
   spack bootstrap add --scope=site --trust local-sources $PWD/my_bootstrap/metadata/sources/
   spack bootstrap disable --scope=site github-actions-v0.5
   spack bootstrap disable --scope=site github-actions-v0.4
   spack bootstrap disable --scope=site spack-install
   spack bootstrap root $PWD/spack/bootstrap
   spack bootstrap now
   spack bootstrap status
   ```
   - Sources the Spack environment to set up the paths and commands.
   - Resets Spack’s bootstrap configuration and adds the local bootstrap mirror (`my_bootstrap`) created earlier, ensuring all dependencies are fetched locally.
   - Disables unnecessary bootstrap sources (`github-actions-v0.5`, etc.) to avoid any attempt to connect online.
   - Sets the root path for Spack’s bootstrap environment and checks the status.

4. **Set Compiler and Environment Variables:**
   ```bash
   export CC='gcc'
   export CXX='g++'
   export FC='mpifort'
   export OMPI_CC='gcc'
   export OMPI_CXX='g++'
   export OMPI_FC='gfortran'
   ```
   - Specifies compilers for C, C++, and Fortran, ensuring the correct toolchain is used during the build.
   - Sets OpenMPI environment variables to link the compilers correctly.

5. **Load Required Modules and Add Spack Mirror:**
   ```bash
   module load gnu/11.2.0 mpi cmake/3.29.6 
   spack mirror add SLOTH $WORK_DIR/mirror-mfem/
   spack compiler find
   spack external find openmpi
   spack external find cmake
   spack external find openssh
   ```
   - Loads necessary modules (`gnu`, `mpi`, `cmake`) to provide the required tools and compilers.
   - Adds the previously created Spack mirror (`mirror-mfem`) so that dependencies are fetched from the local mirror instead of the internet.
   - Detects and registers available compilers and external software (e.g., `openmpi`, `cmake`, `openssh`) within Spack.

6. **Install Dependencies and Build SLOTH:**
   ```bash
   spack install gcc@11.2.0 mfem+mpi+debug+openmp+petsc+strumpack+suite-sparse+sundials+superlu-dist+miniapps%gcc@11.2.0
   cd $WORK_DIR/sloth
   mkdir build && cd build
   spack load mfem
   spack load metis
   export HYPRE_DIR=`spack location -i hypre`
   export MPI_DIR=`spack location -i mpi`
   export METIS_DIR=`spack location -i metis`

   cmake .. -DMFEM_USE_PETSC=ON -DPETSC_DIR=${PETSC_DIR} -DPETSC_ARCH="" -DPETSC_INCLUDES=${PETSC_DIR}/include -DPETSC_LIBRARIES=${PETSC_DIR}/lib -DPETSC_EXECUTABLE_RUNS=${PETSC_DIR}/bin
   make -j 10
   ctest
   ```
   - Installs GCC and other specified dependencies from the local mirror without accessing the internet.
   - Sets up the build directory within the SLOTH repository (`build`).
   - Loads required dependencies (`mfem`, `metis`) to ensure they are available for the build process.
   - Sets environment variables to locate specific dependency installations.
   - Configures SLOTH with `cmake`, pointing to relevant dependencies (`PETSC`, etc.), and builds the software using `make`.
   - Runs tests with `ctest` to verify the build.

---

### Run Your Simulation On Topaze


Script example of a simulation running on milan partition over 8192 mpi processes with a duration limit of about 24 hours:

```
#!/bin/bash
#MSUB -r sloth_big_run
#MSUB -n 8192
#MSUB -c 1
#MSUB -T 86000
#MSUB -m scratch
#MSUB -o sloth_big_run_%I.o
#MSUB -e sloth_big_run_%I.e
#MSUB -q milan

set -x
export OMP_NUM_THREADS=1
ccc_mprun ./test3D

```


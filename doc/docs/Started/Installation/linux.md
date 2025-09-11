---
icon: simple/linux
---

# On Linux with Spack

A straightforward way to install MFEM is to use [spack](https://spack.readthedocs.io/en/latest/getting_started.html).

!!! info "Installing spack"
    To install spack on Linux, the first step consists in cloning and loading it into a `$SPACK` directory (see [spack](https://spack.readthedocs.io/en/latest/getting_started.html) for more details.)

Assuming `spack` well installed into the `$SPACK` directory, the following command enables to install MFEM with right additional packages:

```bash
source $SPACK/share/spack/setup-env.sh

spack install mfem+mpi+suite-sparse+sundials+superlu-dist+miniapps
```
!!! note "Installing a given version of MFEM"
    The user is free to install different version of MFEM. 
    By default, the last released is considered. otherwise, "@version" must be added at the end of the `spack` command.


Once MFEM is installed, priori to compile SLOTH, MFEM must be loaded and several environment variables must be defined:

```bash
   spack load mfem

   export HYPRE_DIR=$(spack location -i hypre)
    
   export MPI_DIR=$(spack location -i mpi)
   
   export METIS_DIR=$(spack location -i metis)
```

!!! tip "On the use of the  `envSloth.sh` configuration file"
    These definitions are written into the configuration file `envSloth.sh` located in the root directory of the SLOTH repository. 
    The use of this file is recommended to load the MFEM environment before compilling SLOTH.

- Load the SLOTH configuration file:
```bash
bash ../envSloth.sh [OPTIONS] 
```
where [OPTIONS] are:
```bash
    --release to build with Release compiler options 

    --optim to build with Optim compiler options 
        
    --debug to build with Debug compiler options 
        
    --coverage to build with Coverage compiler options 
        
    --minsizerel to build with MinSizeRel compiler options 
        
    --relwithdebinfo to build with RelWithDebInfo compiler options 

    --external to built SLOTH with an external package
        
```

By default, SLOTH is built with release compiler options.


- Finally, compile 
```bash
make -j N 
```
with N the number of jobs.




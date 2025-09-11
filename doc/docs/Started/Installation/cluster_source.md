---
icon: material/remote-desktop

---

# Cluster from source files

The following installation procedure describes how to install `SLOTH` from source files on a supercomputer. Here, the description is based on an installation done on CCRT Topaze.

This procedure is mainly based on the installation procedure [from source files on local computer](sources.md). 


## __Getting source files on local computer__

The first step consists in cloning `MFEM`, `METIS`, `HYPRE` and `SuiteSparse`.

!!! warning "Clone of the default branch"
    - The current installation procedure assumes that the clone of the source files is based on the default branch of each repository.
    - Users are free to consider different branches for their installation.

All sources are collected in a global directory called `MFEM4SLOTH`. 

```bash
cd $HOME
mkdir MFEM4SLOTH
cd MFEM4SLOTH
```

### MFEM
MFEM's source files are obtained by running the following command:

```bash
git clone https://github.com/mfem/mfem.git
```

### HYPRE
HYPRE's source files are obtained by running the following command:

```bash
git clone https://github.com/hypre-space/hypre.git
```

### METIS
METIS's source files are obtained by running the following commands:

```bash
git clone https://github.com/mfem/tpls.git
mv tpls/metis-4.0.3.tar.gz .
tar -zxvf metis-4.0.3.tar.gz
rm -fr metis-4.0.3.tar.gz tpls
```

### SuiteSparse
SuiteSparse's source files are obtained by running the following command:

```bash
git clone https://github.com/DrTimothyAldenDavis/SuiteSparse.git
```

## __Copy of source files on the supercomputer__
Copy of the `MFEM4SLOTH` folder on the supercomputer by running the following command:

```bash
rsync --info=progress2 -e ssh -avz MFEM4SLOTH <login>@<remote_host>:$DEST_DIR
```

## __Building dependencies on the supercomputer__
The second step consists in building `METIS`, `HYPRE` and `SuiteSparse` on the supercomputer. 
From now, all command are run on the supercomputer. 

### Load required modules
Before building dependencies, it is necessary to load some modules. Please keep in mind that versions depend on the targeted environment. 

`gnu`, `mpi`, `cmake` are required to build MFEM with `METIS`, `HYPRE` and `SuiteSparse`. 
For `SuiteSparse`, `blas` and `mpfr` are also needed.

```bash 
module load gnu/11.1.0
module load mpi/openmpi/4.1.4
module load cmake/3.29.6
module load blas/openblas/0.3.26
module load mpfr/4.2.0
```

!!! remark "Find available modules"
    The list of available modules can be obtained using the following command:
    ```bash
    module avail [optional_string]
    ```
    where an optional string can be specified to refine the search for modules. 
    This string can be a partial name. 

### METIS
To build `METIS`, the following command must be run:

```bash
cd metis-4.0.3
make OPTFLAGS=-Wno-error=implicit-function-declaration
mkdir include
cp Lib/*.h include/
cd ..
ln -s metis-4.0.3 metis-4.0
```

The fourth instruction differs from the installation procedure [from source files on local computer](sources.md). 

### HYPRE 

To build `HYPRE`, the following command must be run:

```bash
cd hypre/src
./configure --disable-fortran
make -j N
cd ../..
```
where `N` is a user defined number of CPUs.


### SuiteSparse
To build `SuiteSparse`, the following commands must be run:

```bash 
cd SuiteSparse/
make -j N
make install DESTDIR=$PWD/INSTALLDIR
mv INSTALLDIR/usr/local/lib64/* lib/
mv INSTALLDIR/usr/local/include/suitesparse/* include/
mv INSTALLDIR/usr/local/bin/* bin/
cd ..
```
where `N` is a user defined number of CPUs.

The fourth instruction differs from the installation procedure [from source files on local computer](sources.md). 

## __Building MFEM with dependencies__
Here, we assume that all dependencies are well built according to the previous directives. 
At this stage, `MFEM` can be installed by running the following commands:

```bash
cd mfem
make -j N parallel MFEM_USE_SUITESPARSE=YES 
make install PREFIX=INSTALLDIR
cd ..
``` 

## __SLOTH compilation__
Once `MFEM` is installed, priori to compile `SLOTH`, several environment variables must be defined:

```bash
    export MFEM_DIR="$MFEM4SLOTH/mfem/INSTALLDIR/"
    export HYPRE_DIR="$MFEM4SLOTH/hypre/src/hypre/"
    export METIS_DIR="$MFEM4SLOTH/metis-4.0/"
    export SuiteSparse_DIR="$MFEM4SLOTH/SuiteSparse/"
```

!!! tip "On the use of the  `envSloth.sh` configuration file"
    These definitions are written into the configuration file `envSloth.sh` located in the root directory of the `SLOTH` repository. 
    The use of this file is recommended to load the `MFEM` environment before compilling `SLOTH`.

- Load the `SLOTH` configuration file:
```bash
bash ../envSloth.sh [OPTIONS] --mfem=$MFEM4SLOTH
```
where `$MFEM4SLOTH` is a variable associated with the path towards the `MFEM` installation (_ie_ `$HOME/MFEM4SLOTH` in the current description) and [OPTIONS] are:
```bash
    --release to build SLOTH with Release compiler options 

    --optim to build SLOTH with Optim compiler options 
        
    --debug to build SLOTH with Debug compiler options 
        
    --coverage to build SLOTH with Coverage compiler options 
        
    --minsizerel to build with MinSizeRel compiler options 
        
    --relwithdebinfo to build with RelWithDebInfo compiler options 

    --external to built SLOTH with an external package
        
```

By default, `SLOTH` is built with release compiler options.


- Finally, compile 
```bash
make -j N 
```
with N the number of jobs.


---
icon: simple/linuxcontainers
---

# On Linux from source files

The following installation procedure describes how to install `SLOTH` from source files. 

It is assumed that the user has a Unix environment with a recent GCC compiler (C++20 compatible) and MPI libraries. Obviously, Git is also needed to clone source files.

The following procedure is mainly based on the installation procedure of a [parallel MPI version of `MFEM`](https://mfem.org/building/). 
Only the installation of SuiteSparse will be added.


## __Getting source files__

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

## __Building dependencies__
The second step consists in building `METIS`, `HYPRE` and `SuiteSparse`.

### METIS
To build `METIS`, the following command must be run:

```bash
cd metis-4.0.3
make OPTFLAGS=-Wno-error=implicit-function-declaration
cd ..
ln -s metis-4.0.3 metis-4.0
```
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
mv INSTALLDIR/usr/local/lib/* lib/
mv INSTALLDIR/usr/local/include/suitesparse/* include/
mv INSTALLDIR/usr/local/bin/* bin/
cd ..
```
where `N` is a user defined number of CPUs.

!!! warning "Possible errors"
    Depending the Unix configuration of the user, it is possible to have errors because some dependencies are not found as, for example, [`MFPR`](https://www.mpfr.org/mpfr-current/mpfr.html). In that case, these missing dependencies must be installed. 
    For example, to install `MFPR` on Ubuntu Jammy, the following command can be run:
    ```bash
    sudo apt-get install libmpfr-dev
    ```

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
        
    --minsizerel to build with MinSizeRel compiler options 
        
    --relwithdebinfo to build with RelWithDebInfo compiler options 
        
    --coverage to build SLOTH with Coverage compiler options 

    --external to built SLOTH with an external package
        
```

By default, `SLOTH` is built with release compiler options.


- Finally, compile 
```bash
make -j N 
```
with N the number of jobs.


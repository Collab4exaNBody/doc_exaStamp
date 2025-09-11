---
icon: simple/apple
---
# On MacOS with Homebrew

Following the [MFEM website](https://mfem.org), the simplest way to install MFEM on MacOS consists in using the package manager Homebrew (see [https://brew.sh](https://brew.sh) for more details):


``` bash 
brew install mfem
```

!!! note "Installing a given version of MFEM"
      By default, this MFEM installation depends on hypre, metis, openblas, suite-sparse.

      It is possible rebuild MFEM with additional dependencies (see [https://formulae.brew.sh/formula/mfem#default](https://formulae.brew.sh/formula/mfem#default) for more details). 
      To do this,  
      
       - Get the .rb file : run `brew edit mfem` to open the default rb file or get it from [Github](https://github.com/Homebrew/homebrew-core/blob/5ecde7427aa47ac931795c78669f0a4da53a12ed/Formula/m/mfem.rb)
       - Add your dependencies with `depends_on` directive. Here, let us consider the `petsc` dependency:

      ```bash 
      depends_on "cmake" => :build
      depends_on "hypre"       
      depends_on "metis"       
      depends_on "openblas"
      depends_on "suite-sparse"
      depends_on "petsc"
      ```

      - Save the file in the directory and run the following command:

      ```bash 
      brew install --formula mfem.rb
      ```

      Installation with petsc can be checked by editing once again the mfem.rb file. petsc must be mentioned as default dependency. 

      Each dependency can be installed easily using homebrew. 
      

Once MFEM is installed, priori to compile SLOTH several environment variables must be defined:

```bash
export MFEM_DIR=$(echo `brew --prefix mfem`)

export MPI_DIR=$(echo `brew --prefix open-mpi`)

export HYPRE_DIR=$(echo `brew --prefix hypre`)

export METIS_DIR=$(echo `brew --prefix metis`)

```

!!! tip "On the use of the  `envSloth.sh` configuration file"
    These definitions are written into the configuration file `envSloth.sh` located in the root directory of the SLOTH repository. 
    The use of this file is recommended to load the MFEM environment before compilling SLOTH.

- Load the SLOTH configuration file:
```bash
source ../envSloth.sh [OPTIONS] 
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



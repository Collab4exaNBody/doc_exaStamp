---
icon: material/run
---    
  
# **Running your simulation**

Now that you have installed `onika`, `exaNBody` and `exaStamp`, you can create your simulation file using the `YAML` format. Please refer to the `User guide` or `Tutorials` to learn how to build your first input deck. Once this file is constructed, you can run your simulation with a specified number of `MPI` processes and threads per `MPI` process. Whether you installed `exaStamp` using `CMake` or `spack`, follow the following instructions.

=== "`CMake`"
   
    ```bash linenums="1"
    source ${XSP_INSTALL_DIR}/bin/setup-env.sh
    export exaStamp_exec=${XSP_INSTALL_DIR}/bin/exaStamp
    export OMP_NUM_THREADS=10
    export N_MPI=2
    mpirun -np ${N_MPI} exaStamp_exec myinput.msp
    ```
  
=== "`Spack`"
               
    ```bash linenums="1"
    export OMP_NUM_THREADS=10
    export N_MPI=2
    spack load exastamp
    mpirun -np ${N_NMPI} exaStamp myinput.msp
    ```

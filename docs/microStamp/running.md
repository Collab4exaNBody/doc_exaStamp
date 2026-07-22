---
icon: material/run
---    

# **Running your microStamp simulation**

Now that you have installed `onika` and `exaNBody`, the `microStamp` MD mini app is available and you can create your simulation file using the `YAML` format. Please refer to the `User guide` or `Tutorials` to learn how to build your first input deck. Once this file is constructed, you can run your simulation with a specified number of `MPI` processes and threads per `MPI` process. Whether you installed `exaStamp` using `CMake` or `spack`, follow the following instructions.

=== "`CMake`"
   
    ```bash linenums="1"
    export microStamp_exec=${XNB_INSTALL_DIR}/bin/exaNBody
    export OMP_NUM_THREADS=10
    export N_MPI=2
    mpirun -np ${N_MPI} microStamp_exec myinput.msp
    ```
  
=== "`Spack`"
               
    ```bash linenums="1"
    export OMP_NUM_THREADS=10
    export N_MPI=2
    spack load exanbody
    mpirun -np ${N_NMPI} exaNBody myinput.msp

!!! note "Examples"

    A lot of examples for `microStamp` are located in the [exaNBody/contribs/microStamp/samples](https://github.com/Collab4exaNBody/exaNBody/tree/main/contribs/microStamp/samples) folder. A good start is to inspect these examples to design your first simulation.
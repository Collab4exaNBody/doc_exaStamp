---
icon: material/run
---    
  
# **Running your simulation**

Now that you have installed ``onika``, ``exaNBody`` and ``exaStamp``, you can create your simulation file using the ``YAML`` format. Please refer to the ``Beginner's guide to exaStamp`` section to learn how to build your first input deck. Once this file is constructed, you can run your simulation with a specified number of ``MPI`` processes and threads per ``MPI`` process. Whether you installed `exaStamp` using CMake or spack, follow these instructions:

!!! note "Running an exaStamp simulation"

    === "CMake"
   
        ```bash
        source ${XSP_BUILD_DIR}/exaStamp
        export OMP_NUM_THREADS=10
        export N_MPI=2
        mpirun -np ${N_MPI} ${XSP_BUILD_DIR}/exaStamp myinput.msp
        ```
  
    === "Spack"
                  
        ```bash
        export OMP_NUM_THREADS=10
        export N_MPI=2
        spack load exastamp
        mpirun -np ${N_NMPI} exaStamp myinput.msp
        ```

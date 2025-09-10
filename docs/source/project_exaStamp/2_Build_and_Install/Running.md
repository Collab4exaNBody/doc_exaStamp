## Running your simulation

Now that you have installed ``onika``, ``exaNBody`` and ``exaStamp``, you can create your simulation file using the ``YAML`` format. Please refer to the ``Beginner's guide to exaStamp`` section to learn how to build your first input deck! Once this file is constructed, you can run your simulation with a specified number of ``MPI`` processes and threads per ``MPI`` process. 

### Simple YAML input file

Below is an example of an `YAML` input file that allows to:

- Define a 3D-periodic simulation cell containing an FCC Copper sample
- Assign a gaussian random noise to particles positions and velocities
- Performs the time integration using a Velocity-Verlet scheme
- Uses a Langevin thermostat to maintain the temperature at 300. K
- Dumps `.xyz` files at a specific frequency for vizualization with `OVITO`

```yaml
A:
    B
    C
```

### It's go time

To run the above case, and depending if you installed `exaStamp` using CMake or spack follow these instructions:

```{eval-rst}
.. tabs::

   .. tab:: **CMake**
   
      .. code-block:: bash

         source ${XSP_BUILD_DIR}/exaStamp
         export OMP_NUM_THREADS=10
         export N_MPI=2
         mpirun -np ${N_MPI} ${XSP_BUILD_DIR}/exaStamp myinput.msp

   .. tab:: **Spack**
                  
      .. code-block:: bash

         export OMP_NUM_THREADS=10
         export N_MPI=2
         spack load exastamp
         mpirun -np ${N_NMPI} exaStamp myinput.msp
```



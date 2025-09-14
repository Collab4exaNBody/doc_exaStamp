---
icon: material/run
---    

# **Running your simulation**

Now that you have installed ``onika``, ``exaNBody`` and ``exaStamp``, you can create your simulation file using the ``YAML`` format. Please refer to the ``Beginner's guide to exaStamp`` section to learn how to build your first input deck! Once this file is constructed, you can run your simulation with a specified number of ``MPI`` processes and threads per ``MPI`` process. 

## **Simple YAML input file**

Below is an example of an `YAML` input file that allows to:

- Define a 3D-periodic simulation cell containing an FCC Copper sample
- Assign a gaussian random noise to particles positions and velocities
- Performs the time integration using a Velocity-Verlet scheme
- Uses a Langevin thermostat to maintain the temperature at 300. K
- Dumps `.xyz` files at a specific frequency for vizualization with `OVITO`

!!! note "Basic YAML example for exaStamp"
  
    ```yaml
    # Choose the grid flavor
    grid_flavor: grid_flavor_full

    # Define the species present in the system
    species:
      - Cu: { mass: 63.546 Da , z: 29 , charge: 0.0 e- }

    # Interatomic potential
    sutton_chen_force:
      rcut: 7.29 ang
      parameters:
        c: 3.317E+01
        epsilon: 3.605E-21 J
        a0: 0.327E-09 m
        n: 9.050E+00
        m: 5.005E+00

    # Force operator (interatomic potential + Langevin thermostat)
    compute_force:
      - sutton_chen_force
      - langevin_thermostat: { T: 300. K, gamma: 0.1 ps^-1 }

    # System's creation
    input_data:
      - domain:
          cell_size: 5.0 ang
      - bulk_lattice:
          structure: FCC
          types: [ Cu, Cu, Cu, Cu]
          size: [ 3.615 ang , 3.615 ang , 3.615 ang ]
          repeat: [ 20, 20, 20 ]
      - gaussian_noise_r:
      - gaussian_noise_v:
  
    # Simulation parameters        
    global:
      simulation_end_iteration: 1000
      simulation_log_frequency: 20
      simulation_dump_thermo_frequency: -1
      simulation_dump_frequency: -1
      rcut_inc: 1.0 ang
      dt: 2.0e-3 ps
      init_temperature: 5. K
    ```

## **It's go time**

To run the above case, and depending if you installed `exaStamp` using CMake or spack follow these instructions:

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

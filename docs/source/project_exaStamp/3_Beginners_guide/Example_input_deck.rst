Input deck example
==================

Individual building blocks
--------------------------

``global`` block definition
***************************

Below is an example of the ``global`` YAML block:

.. code-block:: YAML

   global:
     timestep: 0                      
     physical_time: 0.                
     dt: 1.0e-3 ps                    
     rcut_inc: 1.0 ang                
     log_mode: default                
     simulation_log_frequency: 10     
     simulation_end_iteration: 10000  
     init_temperature: 300. K

allowing to define a simulation of 10000 steps with a 1 fs timestep where the thermodynamic state is printed on the screen every 10 steps. The screen log mode is set to the `default` mode for which the timestep, physical time, total energy, kinetic energy, potential energy, temperature, pressure and simulation status are printed. The initial temperature is also set to 300. K using a gaussian distribution of atomic velocities.

``domain`` block definition
***************************

The ``domain`` block allows the user to entirely define the simulation domain in which the particles will evolve dynamically. It contains multiple parameters that have to be consistent with each other:

.. code-block:: YAML

   domain:
     cell_size: 6.6 ang
     grid_dims: [10, 10, 10]
     bounds: [[ 0.0 ang,  0.0 ang,  0.0 ang],
              [66.0 ang, 66.0 ang, 66.0 ang]]
     periodic: [true,true,true]
     expandable: false

Define as above, the simulation domain will be a cubic box with side length equal to 72.3 ang with a total of 1000 cells that define a 3D-periodic grid used for parallelism. In addition, the variable `expandable` set to false means that when creating particles, the domain should not be expanded to contain particles that are outside of it.

``species`` block definition
****************************

The ``species`` block allows the definition of the particles' species that will be considered in the simulation.

.. code-block:: YAML

   species:
     - Ta:
         mass: 180.95 Da
         z: 73
         charge: 0 e-

Here, the system will only be constituted of Tantalum particles.

``compute_force`` block definition
**********************************

Probably one of the most important YAML block when it comes to classical molecular dynamics, the ``compute_force`` block allows the user to define the interatomic potential that will be used and from which the forces acting on atoms will be derived.

.. code-block:: YAML
                
   compute_force: johnson_force

   johnson_force:
     rcut: 6.1 ang
     parameters:
       re: 2.860082 ang
       fe: 3.08634 eV/ang
       rhoe: 33.787168 eV/ang
       alpha: 8.489528
       beta: 4.527748
       A: 0.611679 eV
       B: 1.032101 eV
       kappa: 0.176977
       lambda: 0.353954
       Fn0: -5.103845 eV
       Fn1: -0.405524 eV
       Fn2: 1.112997 eV
       Fn3: -3.585325 eV
       F0: -5.14 eV
       F1: 0.0 eV
       F2: 1.640098 eV
       F3: 0.221375 eV
       eta: 0.848843 eV
       Fo: -5.141526 eV

Above, the ``compute_force`` block is built upon the ``johnson_force`` operator that defines the interatomic potential as the Embedded-Atom Model from Johnson et al. parametrized for Tantalum. Additional interatomic potential are described in XXX.

``input_data`` block definition
*******************************

Finally, what would be a molecular dynamics simulation without atoms? The ``input_data`` block allows the user to create or insert particles in the simulation domain. 

.. code-block:: YAML

   input_data:
     - init_rcb_grid
     - lattice:
         structure: BCC
         types: [ Ta, Ta ]
         size: [ 3.3 ang, 3.3 ang, 3.3 ang ]

That ``input_data`` block first applies the ``init_rcb_grid`` operators that distributes the simulation domain cells on the different processors so the particles can be appropriately distributed. It then calls the ``lattice`` operator that replicates a BCC unit cell of Tantalum with lattice parameter equal to 3.3 ang in the entire domain. Whether the final simulation cell is commensurized with the minimal BCC unit cell defined above strictly depends on the way the domain was defined. Other ways to create the particles can be found in XXX.

Running the simulation
----------------------

Full input deck
***************

Gathering all the YAML blocks above, the final input decks is defined as below:

.. code-block:: YAML

   global:
     timestep: 0                      
     physical_time: 0.                
     dt: 1.0e-3 ps                    
     rcut_inc: 1.0 ang                
     log_mode: default                
     simulation_log_frequency: 10     
     simulation_end_iteration: 10000  

   domain:
     cell_size: 6.6 ang
     grid_dims: [10, 10, 10]
     bounds: [[ 0.0 ang,  0.0 ang,  0.0 ang],
              [66.0 ang, 66.0 ang, 66.0 ang]]
     periodic: [true,true,true]
     expandable: false

   species:
     - Ta:
         mass: 180.95 Da
         z: 73
         charge: 0 e-

   compute_force: johnson_force

   johnson_force:
     rcut: 6.1 ang
     parameters:
       re: 2.860082 ang
       fe: 3.08634 eV/ang
       rhoe: 33.787168 eV/ang
       alpha: 8.489528
       beta: 4.527748
       A: 0.611679 eV
       B: 1.032101 eV
       kappa: 0.176977
       lambda: 0.353954
       Fn0: -5.103845 eV
       Fn1: -0.405524 eV
       Fn2: 1.112997 eV
       Fn3: -3.585325 eV
       F0: -5.14 eV
       F1: 0.0 eV
       F2: 1.640098 eV
       F3: 0.221375 eV
       eta: 0.848843 eV
       Fo: -5.141526 eV

   input_data:
     - init_rcb_grid
     - lattice:
         structure: BCC
         types: [ Ta, Ta ]
         size: [ 3.3 ang, 3.3 ang, 3.3 ang ]
       
Running the case
****************

Copy-pasting the above YAML structure into a file named ``tantalum_nve.msp``, you should be able to run the case by using the following commands in a terminal:

.. code-block:: bash

   source ${XSP_INSTALL_DIR}/bin/setup-env.sh
   OMP_NUM_THREADS=20
   onika-exec input_deck.msp

When running this case, you'll notice that multiple files are created. First, a ``thermodynamic_state.csv`` file is written to disk with information every 10 steps. This is because in the ``global`` clock, the default value for ``simulation_dump_thermo_frequency`` is se to 10. In addition, multiple ``*.MpiIO`` files have been created and are the consequence of the ``simulation_dump_frequency`` set to 1000. The later triggers the ``dump_data`` operation that outputs by default a restart file in the ``exaStamp`` format. A detailed explanation of YAML configuration and default parameters is provided in the next section.


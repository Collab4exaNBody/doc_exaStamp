Exhaustive List of ExaSTAMP Operators
=====================================

In the present section, we describe the main ExaSTAMP operators and the ones used from ExaNBody by inheritance. Each operator's description is accompanied by a general description, a slot description and YAML example that can directly be included in your simulation's input file.


Global Operators
----------------

Some operators from the default `exaNBody` operator list. Here's a list of the main operators that will be useful for your simulations.

* Operator `domain` : see @exaNBody in plugin @exanbIOPlugin
    * `cell_size` : It corresponds to the side lenght of cells containing particles that are distributed to the threads during the calculations.
    * `periodic` : Defines the boundary conditions required for the simulation, i.e. periodic or free boundary conditions along the three axes defining the simulation domain.

YAML example:

.. code-block:: yaml
    
   domain:
      cell_size: 3. ang
      periodic: [true,true,true]

* Operator `global` :  see @exaNBody in plugin @exanbCorePlugin
    * `simulation_end_iteration` = Total number of iterations
    * `dt` = Timestep for time integration
    * `rcut_inc` = Corresponds to the extra skin cutoff added to the force field cutoff leading to the Verlet radius used by the Verlet list method. Note that the smaller the radius, the more often verlet lists are reconstructed. On the other hand, the larger the radius, the more expensive it is to build the verlet lists.
    * `simulation_log_frequency` = Frequency at which the thermodynamic state is printed to the screen. This does not write anything to an external file
    * `simulation_dump_thermo_frequency` = Frequency at which the thermodynamic state is printed to the external file `thermodynamic_state.csv`
    * `simulation_dump_frequency` = Frequency at which an mpiio file is written by calling the operator **dump_data**
    * `analysis_dump_frequency` = Frequency at which various analysis can be performed by calling the operator **dump_analysis**
    * `grid_flavor` = Defines the grid attached to particles and what fields it contains. Options are : grid_flavor_full, grid_flavor_full_mechanics, grid_flavor_multimat, grid_flavor_multimat_mechanics, grid_flavor_rigidmol, grid_flavor_minimal.

YAML example:

.. code-block:: yaml

  global:
    simulation_end_iteration: 5400
    dt: 0.001 ps
    rcut_inc: 1.0 ang
    simulation_log_frequency: 10
    simulation_dump_thermo_frequency: 10
    simulation_dump_frequency: 50
    analysis_dump_frequency: 100
    grid_flavor: grid_flavor_full

Force Fields Operators
----------------------

Multiple force fields are available in ExaSTAMP. The general operator that defines the way forces are calculated is named `compute_force` and can be added as a general YAML block in the simulation input file. In this block, multiple force fields can be called and are processed in the order they appear in the `compute_force` block :

* Name: `compute_force`

YAML usage:

.. code-block:: yaml

   compute_force:
     - force_operator_1
     - force_operator_2
     - thermostat_1

We define in the following the different force fields available in ExaSTAMP, as well as thermostat operators.

Langevin thermostat
^^^^^^^^^^^^^^^^^^^

Apply a Langevin thermostat to the system. No time integration is performed by this operator as it just modifies the forces of the particles to effect thermostatting.

* Name: `langevin_thermostat`
* `Tstart` = desired temperature at run start
* `Tstop` = desired temperature at end start
* `gamma` = damping parameter
* `seed` = random number seed to use for white noise (positive integer)  

YAML usage:

.. code-block:: yaml

   langevin_thermostat:
     Tstart: 500.0 K
     Tend: 3000.0 K     
     gamma: 0.1 ps^-1
     seed: 36782

Lennard-Jones potential
^^^^^^^^^^^^^^^^^^^^^^^

Computes the standard 12/6 Lennard-Jones potentiel given by

.. math::
   :label: pair_lj

   E = 4 \epsilon \left[ \left( \frac{\sigma}{r} \right)^{12} - \left( \frac{\sigma}{r} \right)^{6} \right] \quad \quad r < r_c


* Name: `lj_compute_force`
* `parameters` =  Data structure that contains compute force parameters (epsilon, sigma).
* `epsilon` = energy value at the energy minimum of the potential (energy units)
* `sigma` = zero-crossing distance for the potential (distance units)

.. code-block:: yaml

   lj_compute_force:
     parameters: { epsilon: 0.58 eV, sigma: 2.27 ang }
     rcut: 5.68 ang

Note that the YAML block above can be used only in the presence of a single atom type. The multi-materials version of the Lennard-Jones can be defined as follows:

.. code-block:: yaml

   compute_force_pair_multimat:
      potentials:
        - { type_a: Cu, type_b: Cu, potential: lj, rcut: 8.47 ang, parameters: { epsilon: 0.26 eV , sigma: 3.39 ang } }
        - { type_a: Zn, type_b: Zn, potential: lj, rcut: 6.10 ang, parameters: { epsilon: 0.16 eV , sigma: 2.44 ang } }
        - { type_a: Cu, type_b: Zn, potential: lj, rcut: 5.89 ang, parameters: { epsilon: 0.30 eV , sigma: 2.36 ang } }
          

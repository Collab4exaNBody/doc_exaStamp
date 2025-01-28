exaStamp Software
=================

Overview of exaStamp
^^^^^^^^^^^^^^^^^^^^

``ExaStamp`` is a software solution in the field of computational simulations of particle-based systems. It stands for "Simulations Temporelles Atomistiques et Moléculaires en Parallèle à l'Exascale" or Exascale Atomistic and Molecular Simulations in Parallel. ``ExaStamp`` is a classical molecular dynamics (``MD``) simulation code developed within the ``exaNBody framework`` and it is dedicated to the modeling of materials behavior at extreme conditions at the microscopic scale. It adopts a hybrid parallelization approach, combining the use of ``MPI`` (Message Passing Interface) and Threads (``OpenMP``). This combination aims at optimizing computational cost for simulations, making them more efficient and manageable.

Additionally, ``ExaStamp`` offers combatibility with ``MPI`` + ``GPUs``, using the ``CUDA`` programming model integrated as the ``Onika`` layer. This feature provides the option to leverage ``GPU`` processing power for potential performance gains in simulations. Written in ``C++17``, ``ExaStamp`` is built on a contemporary codebase and aims at providing researchers and engineers with a tool for adressing ``MD`` simulations.

ExaStamp Capabilities
^^^^^^^^^^^^^^^^^^^^^

The following tables provide a glossary of features supported by ``ExaStamp``, categorized by their computational platform (``CPU`` or ``GPU``). Please note that this information is indicative and may be subject to change based on updates or modifications to the ``ExaStamp`` framework.

.. list-table:: Input/Output Features
  :widths: 40 40 40
  :header-rows: 1
  :align: center

  * - Denomination
    - CPU
    - GPU
  * - Field Set Plugin
    - YES
    - YES
  * - Particles Generator
    - YES
    - X
  * - Reader : XYZ files
    - YES
    - X
  * - Reader : LAMMPS
    - YES
    - X
  * - Reader : ExaStamp binary restart 
    - YES
    - X
  * - Writer : XYZ files (extended)
    - YES
    - X
  * - Writer : ParaView files
    - YES
    - X
  * - Particle Migration (MPI)
    - YES
    - X
  * - Load Balancing (RCB)
    - YES
    - X
  * - Numerical Scheme Plugin
    - YES
    - YES
  * - Regions
    - YES
    - YES
  * - Potential : LJ
    - YES
    - YES
  * - Potential : EAM
    - YES
    - YES
  * - Potential : MEAM
    - YES
    - X
  * - Potential : SNAP
    - YES
    - YES
  * - Potential : N2P2
    - YES
    - X
      
Default Execution Graph With ExaStamp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``ExaStamp`` is based on the operator execution system implemented by the ``exaNBody`` framework. In particular, this allows us to define a set of default operators for ``ExaStamp`` to run an ``MD`` simulation using the Velocity-Verlet integration scheme. ``ExaStamp`` offers multiple variants, depending on whether the user wants to simulate monoatomic or polyatomic systems or even a set of flexible/rigid molecules. To choose between these two variants, the user will need to include either one of these configuration files at the beginning of the main input file for ``ExaStamp``:

- **config_species.msp** for both monoatomic and polyatomic systems
- **config_species_rigidmol.msp** for rigid molecules systems
- **config_molecule.msp** for flexible molecules systems

If neither is included, the simulation will not start. Including these files allows the user to override specific operators left at *nop* (for no operation). The graph below shows the sequence of ``ExaStamp``'s main operators.

TODO : Ajout du graphe comme pour exaDEM.

Release Note
^^^^^^^^^^^^

Release Notes for Version X.X.X (XX/XXXX):
------------------------------------------

New Features:

   * Feature 1

        - Short description

   * Feature 2

        - Short description

Changes and Enhancements:

   * Changes 1

        - Short description

Removed Features:

   * Removed 1

        - Short description

Added Examples:

   * New Example 1



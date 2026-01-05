# Zero

The Zero pair potential zeros out the energy and forces contribution between two atoms.

.. list-table:: Lennard-Jones Parameters
   :widths: 40 40
   :header-rows: 1
   :align: center

   * - Denomination
     - Units
   * - $\\epsilon$
     - energy
   * - $\\sigma$
     - distance
   * - $r_c$
     - distance

Below is a usage example for a system containing one single atomic specy

.. code-block:: yaml

   # Basic force computation
   zero_compute_force:
     rcut: 7.0 ang

   # General force calculation block called in the integration scheme
   compute_force:
     - zero_compute_force

In the case of a system with multiple species, the force operator can be defined as follows

.. code-block:: yaml

   # Basic force computation
   compute_force_pair_multimat:
     potentials:
       - { type_a: Si , type_b: Si , potential: zero , rcut: 8.47 ang }
       - { type_a: Si , type_b:  O , potential: zero , rcut: 5.00 ang }

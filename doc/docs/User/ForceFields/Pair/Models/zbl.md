# Ziegler-Biersack-Littmark

The Ziegler-Biersack-Littmark pair potential computes the screened nuclear repulstion that describes high-enery collisions between atoms. Energy, forces and curvature are smoothly rapmed to zero between and inner and an outer cutoff thanks to a switch function. The energy contribution for to atoms $i$ and $j$ at a idstance $r_{ij}$ from each other reads

.. math::

   E_{ij} = \frac{1}{4 \pi \epsilon_0} \frac{Z_i Z_j e^2}{r_{ij}} \phi \left(r_{ij}/a \right) + S\left(r_{ij}\right)

where $e$ is the electron charge density, $\\epsilon_0$ the vacuum electrical permittivity, $Z_i$ and $Z_j$ the nuclear charges of the two interacting atoms. The scaling factor $a$ is defined as:

.. math::

   a = \frac{0.46850}{Z_i^{0.23}+Z_j^{0.23}}

and the switch function reads

.. math::

   \phi\left(x\right) = 0.18175e^{-3.19980x}+0.50986e^{-0.94229x}+0.28022e^{-0.40290x}+0.02817e^{-0.20162x}

.. list-table:: Ziegler-Biersack-Littmark Parameters
   :widths: 40 40
   :header-rows: 1
   :align: center

   * - Denomination
     - Units
   * - $Z_i$
     - atomic charge
   * - $Z_j$
     - atomic charge
   * - $\r_1$
     - distance
   * - $r_c$
     - distance
       
Below is a usage example for a system containing one single atomic specy

.. code-block:: yaml

   # Basic force computation
   zbl_compute_force: &zbl_params
     parameters: { r1: 5. ang , rc: 5.68 ang }
     rcut: 5.68 ang

   # Symetric interaction variant
   zbl_compute_force_symetric: *zbl_params

   # General force calculation block called in the integration scheme
   compute_force:
     - zbl_compute_force

The atomic charges are not passed as parameters of the potential since they are already attached to particle species and defined in the ``YAML`` block ``species`` defined in the :ref:`particles-species` section. In the case of a system with multiple species, the force operator can be defined as follows

.. code-block:: yaml

   # Basic force computation
   compute_force_pair_multimat:
     potentials:
       - { type_a: Si , type_b: Si , potential: zbl , rcut: 5.68 ang , parameters: { r1: 5 ang, rc: 5.68 ang } }
       - { type_a: Si , type_b: O  , potential: zbl , rcut: 5.4 ang , parameters: { r1: 5.1 ang, rc: 5.4 ang } }

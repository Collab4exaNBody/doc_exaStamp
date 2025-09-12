# Exponential-6

Analogous to the Buckingham pair potential, the Exponential-6 potential has an extra term and reads

.. math::

   E = A e^{-Br} - \frac{C}{r^6} + D \left( \frac{12}{Br} \right)^{12} \quad \text{for} \quad r<r_c


where $ D \\left( \\frac{12}{Br} \\right)^{12} $ is the additional term compared to Buckingham.

.. list-table:: Exponential-6 Parameters
   :widths: 40 40
   :header-rows: 1
   :align: center

   * - Denomination
     - Units
   * - A
     - energy
   * - B
     - distance$^{-1}$
   * - C
     - energy $\\cdot$distance$^6$
   * - D
     - energy

Below is a usage example in the case of a monoatomic system

.. code-block:: yaml

   # Basic force computation
   exp6_compute_force:
     parameters: { A: 1.0 eV, B: 1.0 ang^-1, C: 1.0 eV*ang^6, D: 1.0 eV }
     rcut: 6.0 ang
     
   # General force calculation block called in the integration scheme
   compute_force:
     - exp6_compute_force   

In the case of a system with multiple species, the force operator can be defined as follows

.. code-block:: yaml

   # Basic force computation
   compute_force_pair_multimat:
     potentials:
       - { type_a: Zn , type_b: Zn , potential: exp6 , rcut: 6.10 ang , parameters: { A: 1.0 eV, B: 1.0 ang^-1, C: 1.0 eV*ang^6, D: 0.5 eV } }
       - { type_a: Zn , type_b: Cu , potential: exp6 , rcut: 7.10 ang , parameters: { A: 1.3 eV, B: 1.2 ang^-1, C: 1.5 eV*ang^6, D: 0.6 eV } }
         

.. list-table:: Exponential-6 Parameters
   :widths: 40 40
   :header-rows: 1
   :align: center

   * - Denomination
     - Units
   * - A
     - energy
   * - $\\rho$
     - distance
   * - C
     - energy $\\cdot$distance$^6$
   * - $r_c$
     - distance

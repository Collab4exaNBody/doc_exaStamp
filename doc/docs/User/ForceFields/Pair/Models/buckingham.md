# **Buckingham**

The Buckingham pair potential computes the standard 12/6 formulation given by

$$
E = A e^{-r/\rho} - \frac{C}{r^6} \quad \text{for} \quad r<r_c
$$

where $\\rho$ represents a ionic-pair dependent length parameter and $r_c$ is the cutoff radius for computing the interaction between two particles.

.. list-table:: Buckingham Parameters
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

Below is a usage example in the case of a monoatomic system

.. code-block:: yaml

   # Basic force computation
   buckingham_compute_force:
     parameters: { A: 1.0 eV, Rho: 1.0 ang, C: 1.0 eV*ang^6 }
     rcut: 5.68 ang
     
   # General force calculation block called in the integration scheme
   compute_force:
     - buckingham_compute_force   

In the case of a system with multiple species, the force operator can be defined as follows

.. code-block:: yaml

   # Basic force computation
   compute_force_pair_multimat:
     potentials:
       - { type_a: Zn , type_b: Zn , potential: buckingham , rcut: 6.10 ang , parameters: { A: 1.0 eV, Rho: 1.0 ang, C: 1.0 eV*ang^6} }
       - { type_a: Zn , type_b: Cu , potential: buckingham , rcut: 7.10 ang , parameters: { A: 1.3 eV, Rho: 1.2 ang, C: 1.5 eV*ang^6} }





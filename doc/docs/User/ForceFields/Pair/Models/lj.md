# **Lennard-Jones**

The Lennard-Jones pair potential computes the standard 12/6 formulation given by

$$
E = 4 \epsilon \left[ \left(\frac{\sigma}{r}\right)^{12} - \left(\frac{\sigma}{r}\right)^{6} \right] \quad \text{for} \quad r<r_c
$$

with $r_c$ the cutoff radius for computing the interaction between two particles. $\epsilon$ and $\sigma$ represent the depth of the energy well and its distance to the central particle, respectively.
  
!!! info "**Lennard-Jones potential parameters**"
  
    <div class="center-table" markdown>
  
    | Parameter     | Units    |
    | :------------ | :------: |
    | $\varepsilon$ | energy   |
    | $\sigma$      | distance |
    | $r_c$         | distance |
  
    </div>
  
Below is a usage example for a system containing one single atomic specy

!!! example
      
    ```yaml
    # Basic force computation
    lj_compute_force: &lj_mono_params
      parameters: { epsilon: 0.583 eV , sigma: 2.27 ang }
      rcut: 5.68 ang

    # Flat arrays variant
    lj_compute_force_flat: *lj_mono_params

    # Symetric interaction variant
    lj_compute_force_symetric: *lj_mono_params

    # General force calculation block called in the integration scheme
    compute_force:
      - lj_compute_force
    ```
      
In the case of a system with multiple species, the force operator can be defined as follows

.. code-block:: yaml

   # Basic force computation
   compute_force_pair_multimat:
     potentials:
       - { type_a: Si , type_b: Si , potential: lj , rcut: 8.47 ang , parameters: { epsilon: 4.117E-21 J , sigma: 0.339E-09 m } }
       - { type_a: Cu , type_b: Cu , potential: lj , rcut: 5.68 ang , parameters: { epsilon: 9.340E-20 J , sigma: 0.227E-09 m } }
       - { type_a: Zn , type_b: Zn , potential: lj , rcut: 6.10 ang , parameters: { epsilon: 2.522E-20 J , sigma: 0.244E-09 m } }
       - { type_a: Cu , type_b: Zn , potential: lj , rcut: 5.89 ang , parameters: { epsilon: 4.853E-20 J , sigma: 0.236E-09 m } }

## Buckingham

The Buckingham pair potential computes the standard 12/6 formulation given by

.. math::

   E = A e^{-r/\rho} - \frac{C}{r^6} \quad \text{for} \quad r<r_c


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


## Exponential-6

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

## Ziegler-Biersack-Littmark

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

## Zero

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

.. _nve:

Isochoric-Isoenergetic Ensemble (NVE)
-------------------------------------

The time integration in ``ExaStamp`` is performed using the velocity form of the Soermer-Verlet time integration algorithm, well-known as the `velocity-Verlet` algorithm. It is advantageous for atomistic simulations due to its simplicity, stability, and accuracy. It provides a straightforward method for integrating Newton's equations of motion, efficiently calculating both positions and velocities. This algorithm is symplectic, preserving the system's energy over long simulation times, which is crucial for accurately modeling physical systems. Additionally, its second-order accuracy in both time and energy ensures precise trajectory calculations, making it a preferred choice for molecular dynamics simulations where the conservation of physical properties and computational efficiency are essential.

.. _nvt:

Isochoric-Isothermal Ensemble (NVT)
-----------------------------------

Langevin Thermostat
^^^^^^^^^^^^^^^^^^^

Apply a Langevin thermostat to the system to model an interaction with a background implicit solvent. This thermostat has to be appended to the ``compute_force`` YAML block since no time integration is performed by this operator, contrarily to the Nosé-Hoover thermostat described below. Using a Langevin thermostat, the total force on each atom of the system reads:

.. math::

   F = F_c + F_f + F_r

where \\(F_c\\) is the classical force computed via the interatomic potential and \\(F_f\\) corresponds to the first term added by the Langevin thermostat. This first therm is a viscous damping therm directly proportional to the particle's velocity:

.. math::
   
   F_f = - \frac{m}{\gamma} v

with the prefacto defined as the ratio between the particle's mass and the damping parameter \\(\\gamma\\) defined by the user. The second term added by the Langevin thermostat mimics a force due to solvent atoms at a temperature \\(T\\) randomly bumping the particle. From the fluctuation/dissipation theorem, the magnitude of this term is

.. math::
   
   F_r \propto \sqrt{\frac{m k_b T}{dt \gamma}}

with \\(m\\) the mass of the particle, \\(k_b\\) the Boltzman constant, \\(T\\) the target temperature, \\(dt\\) the timestep and \\(\\gamma\\) the damping parameter. The proportionality of this term is ensured by random numbers generation using a uniform distribution. The Langevin thermostat can be defined in the input file using the following ``YAML`` block;

.. code-block:: yaml
     
   langevin_thermostat:
     T: 300. K
     gamma: 0.1 ps^-1
     seed: 8327

with \\(T\\) the target temperature, \\(\\gamma\\) the damping constant and `seed` the integer for the random number generation. Finally, the Langevin thermostat can be added to the ``compute_force`` YAML block as follows

.. code-block:: yaml
     
   compute_force:
     - interatomic_force_operator_1
     - langevin_thermostat

.. list-table:: Langevin Thermostat Parameters
   :widths: 40 40 40
   :header-rows: 1
   :align: center

   * - Parameter
     - Denomination
     - Units
   * - T
     - target temperature
     - temperature
   * - \\(\\gamma\\)
     - damping parameter
     - time\\(^{-1}\\)
   * - seed
     - seed for random number
     - integer

Berendsen Thermostat
^^^^^^^^^^^^^^^^^^^^

Apply a Berendsen thermostat to the system by rescaling the atoms velocities at each timestep. This thermostatting method is a weakly coupling between the system and a heat bath with the target temperature. Kinetic energy fluctuations are suppressed with the Berendsen thermostat which cannot produce trajectories consistent with the canonical ensemble. Atoms velocities are rescaled at each timestep such that the rate of change exponentially decays with some characteristic time \\(\\tau\\)

.. math::

   \frac{dT}{dt} = \frac{1}{\tau} \left( T^* - T \right)

with \\(T^*\\) the target temperature and  \\(T\\) the current system's temperature. The increase in temperature between two time steps reads

.. math::

   \Delta T = \frac{dt}{\tau} \left( T^* - T \right)

leading to the following scaling factor of atoms velocities:

.. math::

   \lambda = \sqrt{1 + \frac{dt}{\tau} \left( \frac{T^*}{T} - 1\right)}

The Berendsen thermostat can be defined in the input file using the following ``YAML`` block;

.. code-block:: yaml
     
   berendsen_thermostat:
     T: 300. K
     tau: 0.1 ps

with \\(T\\) the target temperature and \\(\\tau\\) the thermostat characteristic time. Finally, the Berendsen thermostat can be added to the ``compute_force`` YAML block as follows

.. code-block:: yaml
     
   compute_force:
     - interatomic_force_operator_1
     - berendsen_thermostat

.. list-table:: Langevin Thermostat Parameters
   :widths: 40 40 40
   :header-rows: 1
   :align: center

   * - Parameter
     - Denomination
     - Units
   * - T
     - target temperature
     - temperature
   * - \\(\\tau\\)
     - characteristic time
     - time

Nosé-Hoover thermostat
^^^^^^^^^^^^^^^^^^^^^^



.. _npt:

Isobaric-Isothermal Ensemble (NPT)
----------------------------------

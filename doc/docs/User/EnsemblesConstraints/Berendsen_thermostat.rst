.. _berendsen_thermostat:

Berendsen Thermostat
--------------------

Apply a Berendsen thermostat to the system by rescaling the atoms velocities at each timestep. This thermostatting method is a weak coupling between the system and a heat bath with the target temperature. Kinetic energy fluctuations are suppressed with the Berendsen thermostat which cannot produce trajectories consistent with the canonical ensemble. Atoms velocities are rescaled at each timestep such that the rate of change exponentially decays with some characteristic time \\(\\tau\\). This thermostat has to b

.. math::

   \frac{dT}{dt} = \frac{1}{\tau} \left( T^* - T \right)

with \\(T^*\\) the target temperature and  \\(T\\) the current system's temperature. The increase in temperature between two time steps reads

.. math::

   \Delta T = \frac{dt}{\tau} \left( T^* - T \right)

leading to the following scaling factor of atoms velocities:

.. math::

   \lambda = \sqrt{1 + \frac{dt}{\tau} \left( \frac{T^*}{T} - 1\right)}

.. warning::

   This thermostat has to be appended to the end of the numerical scheme ``numerical_scheme`` YAML block since no time integration is performed by this operator and it needs the instantaneous temperature, contrarily to the Nosé-Hoover thermostat (See :ref:`nose_hoover_thermostat`). In addition, prior to this operator, the ``thermodynamic_state`` operator has to be called since the instantaneous temperature is required by the thermostat.
   
The Berendsen thermostat can be defined in the input file using three ways that are presented in the following ``YAML`` block:

.. code-block:: yaml
   :caption: **Different ways of defining a Berendsen thermostat**

   # 1st solution: constant target temperature
   berendsen_thermostat:
     T: 300. K
     tau: 0.1 ps
     
   # 2nd solution: linear target temperature     
   berendsen_thermostat:
     Tstart: 5. K
     Tstop: 1000. K
     tau: 0.1 ps

   # 3rd solution: linearly interpolated target temperature
   berendsen_thermostat:
     tserie: [0, 10., 20.]
     Tserie: [5., 500., 500.]
     tau: 0.1 ps

Finally, since the Berendsen thermostat directly operates on atomic forces and needs the instantaneous temperature to be calculated by the ``thermodynamic_state`` operator, both must be added to the ``numerical_scheme`` YAML block as follows:

.. code-block:: yaml

   thermostat: berendsen_thermostat
   
   compute_force:
     - interatomic_force_operator_1
                
   numerical_scheme:
     verlet_first_half
     check_and_update_particles
     compute_all_forces_energy
     verlet_second_half
     simulation_thermodynamic_state
     thermostat


Below are displayed the different parameters of ``langevin_thermostat`` as well as their types and corresponding examples.

.. list-table:: **Properties for the Berendsen thermostat**
   :widths: 40 40 40 40
   :header-rows: 1

   * - Property
     - Denomination
     - Data Type
     - Example
   * - ``T``
     - target temperature (K)
     - float
     - .. code-block:: yaml
             
          T: 300 K
   * - ``Tstart``
     - starting target temperature (K)
     - float
     - .. code-block:: yaml
             
          Tstart: 300 K
   * - ``Tstop``
     - final target temperature (K)
     - float
     - .. code-block:: yaml
             
          Tstop: 1000 K
   * - ``Tserie``
     - serie of target temperature (K)
     - float
     - .. code-block:: yaml
             
          Tserie: [5, 200, 1000, 100]
   * - ``tserie``
     - serie of physical times (ps)
     - float
     - .. code-block:: yaml
             
          tserie: [0,10,20,30]
   * - ``tau``
     - coupling characteristic time (ps)
     - float
     - .. code-block:: yaml
             
          tau: 0.1 ps
   
.. warning::

   When using a Berendsen thermostat, the target temperature must be defined by one of the three ways presented above. If it is misdefined, the simulation will be aborted.

.. _nve:

Isochoric-Isoenergetic Ensemble (NVE)
-------------------------------------

The time integration in ``ExaStamp`` is performed using the velocity form of the Störmer-Verlet time integration algorithm, well-known as the `velocity-Verlet` algorithm. It is advantageous for atomistic simulations due to its simplicity, stability, and accuracy. It provides a straightforward method for integrating Newton's equations of motion, efficiently calculating both positions and velocities. This algorithm is symplectic, preserving the system's energy over long simulation times, which is crucial for accurately modeling physical systems. Additionally, its second-order accuracy in both time and energy ensures precise trajectory calculations, making it a preferred choice for molecular dynamics simulations where the conservation of physical properties and computational efficiency are essential. The `velocity-verlet` algorithm is integrated using the following scheme at each time step:

1. Calculate position vector at full time-step:

.. math::

    \mathbf{x} \left( t + \Delta t \right) = \mathbf{x} \left( t \right) + \mathbf{v} \left( t \right) \Delta t + \mathbf{a} \left(t\right)\frac{\Delta t}{2}

2. Calculate velocity vector at half time-step:

.. math::

    \mathbf{v} \left( t + \frac{\Delta t}{2} \right) = \mathbf{v} \left( t \right) + \mathbf{a} \left( t \right) \frac{\Delta t}{2}
   

3. Compute the acceleration vector at full time-step \\( \\mathbf{a} \\left( t + \\Delta t\\right) \\) from the interatomic potential using the position at full time-step \\( \\mathbf{x} \\left( t + \\Delta t\\right) \\)

4. Finally, calculate the velocity vector at full time-step:
   
.. math::

    \mathbf{v} \left( t + \Delta t \right) = \mathbf{v} \left( t + \frac{\Delta t}{2} \right) + \frac{1}{2} \mathbf{a} \left( t + \Delta t\right) \Delta t

In ``ExaStamp``, the numerical scheme definition can be found in ``exaStamp/data/config/config_numerical_scheme.msp`` and the YAML block for the Velocity-Verlet scheme reads

.. code-block:: yaml

   numerical_scheme: numerical_scheme_verlet
   
   numerical_scheme_verlet:
     name: scheme
     body:
       - push_f_v_r: { dt_scale: 1.0  , xform_mode: INV_XFORM }
       - push_f_v: { dt_scale: 0.5  , xform_mode: IDENTITY }  
       - check_and_update_particles
       - compute_all_forces_energy
       - push_f_v: { dt_scale: 0.5 , xform_mode: IDENTITY }

The ``exaNBody`` code provides a generic operator for 1st order time-integration purposes. For example, the file ``exaNBody/src/exanb/push_vec3_1st_order_xform.cpp`` provides 3 different variants:

- ``push_v_r`` : for updating positions from velocities
- ``push_f_v`` : for updating velocities from forces (i.e. acceleration)
- ``push_f_r`` : for udpdating positions from forces (i.e. acceleration)

In addition, the ``exaNBody`` code also provides a generic operator for 2nd order time-integration purposes. For example, the file ``exaNBody/src/exanb/push_vec3_2nd_order_xform.cpp`` provides the following variant:

- ``push_f_v_r`` : for updating positions from both velocities and forces (i.e. accelerations)

Since in ``ExaStamp`` positions are expressed in a reduced frame, the argument ``xform_mode: INV_XFORM`` is mandatory when using any operator that updates the particles positions.

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

Apply a Nosé-Hoover thermostat to the system. This thermostat actually performs the time integration of the particles so the numerical scheme YAML block is replaced in exaStamp by the one provided below. We first describe the general process of the Nosé-Hoover thermostat.

1. Initialization at the beginning of the simulation:

   - Set thermostat variables and derivatives to 0:

   .. math::

      \eta = \dot{\eta} = \ddot{\eta} = 0.0

   - Set thermostat mass to 0:

   .. math::

      \eta_M = 0.0

   - Set the thermostat coupling frequency:


   .. math::

      t_{freq} = \frac{1}{t_{period}}

   where \\(t_{period}\\) is the coupling period between the system and the thermostat, provided by the user.
      
2. Setup the thermostat parameters at the beginning of the simulation:
      
   - Compute the current target temperature \\(T^*\\) and the corresponding degrees of freedom and target kinetic energy:

   .. math::

     N_{dof} = 3 N_{atoms} - 3
   
   .. math::

     KE^* = N_{dof} k_B T^*

   where the \\(^*\\) upperscript denotes the target value of either kinetic energy or temperature. Note that the target temperature can evolved with time depending if the user has provided a single temperature (constant target temperature), two temperatures (linear ramp) or a list of times and temperatures greater than 2, meaning that an interpolation by parts is done to compute the target temperature at each time-step.
   
   - Initialize masses and initial forces on thermostat variables:

   .. math::

      \eta_M = \frac{N_{dof} \cdot k_B \cdot T^*}{t_f^2} = \frac{KE^*}{t_f^2}

3. During each time-step, supposing that the positions, velocities and forces are up-to-date, the folowing steps are performed:

   a. Compute target temperature \\(T^*\\) and kinetic energy \\(KE^*\\)
   b. Compute current temperature \\(T_{cur}\\) and kinetic energy \\(KE_{cur}\\)      
   c. Compute thermostat mass :

      .. math::

         \eta_M = \frac{N_{dof} \cdot k_B \cdot T^*}{t_f^2} = \frac{KE^*}{t_f^2}

   d. Compute acceleration and velocity of thermostat variable as well as scaling factors for atoms velocities:

      .. math::

         \ddot{\eta} = t_f^2 \left( \frac{KE_{cur}}{KE^*} - 1 \right)

      .. math::

         \gamma_e = e^{\left( -\right)}
         
   e. Perform one Nosé-Hoover integration step
   f. Perform velocity update with half a 
     
.. _npt:

Isobaric-Isothermal Ensemble (NPT)
----------------------------------

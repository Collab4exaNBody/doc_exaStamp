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

.. _thermostats:

Isochoric-Isothermal Ensemble (NVT)
-----------------------------------


.. _nose-hoover:

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

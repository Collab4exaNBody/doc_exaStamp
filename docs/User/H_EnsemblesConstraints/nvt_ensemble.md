.. _nose_hoover_thermostat:

Nosé-Hoover thermostat
----------------------

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

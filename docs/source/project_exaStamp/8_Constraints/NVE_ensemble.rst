.. _nve_ensemble:

NVE ensemble
============

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

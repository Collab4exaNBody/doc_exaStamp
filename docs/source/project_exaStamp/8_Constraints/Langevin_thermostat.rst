.. _langevin_thermostat:

Langevin Thermostat
-------------------

Apply a Langevin thermostat to the system to model an interaction with a background implicit solvent. Using a Langevin thermostat, the total force on each atom of the system reads:

.. math::

   F = F_c + F_f + F_r

where \\(F_c\\) is the classical force computed via the interatomic potential and \\(F_f\\) corresponds to the first term added by the Langevin thermostat. This first therm is a viscous damping therm directly proportional to the particle's velocity:

.. math::
   
   F_f = - \frac{m}{\gamma} v

with the prefacto defined as the ratio between the particle's mass and the damping parameter \\(\\gamma\\) defined by the user. The second term added by the Langevin thermostat mimics a force due to solvent atoms at a temperature \\(T\\) randomly bumping the particle. From the fluctuation/dissipation theorem, the magnitude of this term is

.. math::
   
   F_r \propto \sqrt{\frac{m k_b T}{dt \gamma}}

with \\(m\\) the mass of the particle, \\(k_b\\) the Boltzman constant, \\(T\\) the target temperature, \\(dt\\) the timestep and \\(\\gamma\\) the damping parameter. The proportionality of this term is ensured by random numbers generation using a uniform distribution.

.. warning::

   This thermostat has to be appended to the ``compute_force`` YAML block since no time integration is performed by this operator, contrarily to the Nosé-Hoover thermostat (See :ref:`nose_hoover_thermostat`).
   
The Langevin thermostat can be defined in the input file using three ways that are presented in the following ``YAML`` block:

.. code-block:: yaml
   :caption: **Different ways of defining a Langevin thermostat**

   # 1st solution: constant target temperature
   langevin_thermostat:
     T: 300. K
     gamma: 0.1 ps^-1

   # 2nd solution: linear target temperature     
   langevin_thermostat:
     Tstart: 5. K
     Tstop: 1000. K
     gamma: 0.1 ps^-1

   # 3rd solution: linearly interpolated target temperature
   langevin_thermostat:
      tserie: [0, 10., 20.]
      Tserie: [5., 500., 500.]
      gamma: 0.1 ps^-1

Finally, since the Langevin thermostat directly operates on atomic forces, it can be added to the ``compute_force`` YAML block as follows:

.. code-block:: yaml
   :caption: **Extending the force operator with a Langevin thermostat**
             
   compute_force:
     - interatomic_force_operator_1
     - langevin_thermostat

Below are displayed the different parameters of ``langevin_thermostat`` as well as their types and corresponding examples.

.. list-table:: **Properties for the Langevin thermostat**
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
   * - ``gamma``
     - damping constant (ps^-1)
     - float
     - .. code-block:: yaml
             
          gamma: 0.1 ps^-1

.. warning::

   When using a Langevin thermostat, the target temperature must be defined by one of the three ways presented above. If it is misdefined, the simulation will be aborted.

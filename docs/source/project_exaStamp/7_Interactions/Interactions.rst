Interatomic Potentials
$$$$$$$$$$$$$$$$$$$$$$

Defining the interatomic potential
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In ``ExaStamp``, the integration of the dynamics of the system uses the velocity verlet numerical scheme in which the YAML block ``compute_all_forces_energy``:

.. code-block:: yaml

   compute_all_forces_energy:
     - compute_force_prolog: zero_force_energy
     - compute_force: { here lies the operator associated with the interatomic potential }
     - compute_force_epilog: force_to_accel

In order to compute forces and energies, the interatomic potential must be defined by the ``compute_force`` YAML block which can be a sequence of multiple operators, in the case of hybrid potential where multiple usual forms are additively considered:

.. code-block:: yaml

   interatomic_force_operator_1:
     {do something}
     
   interatomic_force_operator_2:
     {do something else}
     
   compute_force:
     - interatomic_force_operator_1
     - interatomic_force_operator_2       
     - thermostat
     - external_force

which is called at every timestep during the integration loop. As explained above, multiple force operators can be stacked under the ``compute_force`` block. Specific force operators corresponding to different interatomic potentials are defined hereafter. In addition, thermostats (that do not need a modification of the numerical scheme) can also be appended to the ``compute_force`` block and the latter are defined in the :ref:`thermostats` section. Finally, external forces coming from a repulsive wall for example can also be appended to the ``compute_force`` block. Such operators are defined in the :ref:`external_forces` section.

.. include::
   pair_potentials.rst

Electrostatic Potentials
------------------------

.. toctree::

   electrostatic_potentials.rst

Embedded Atom Model
-------------------

.. toctree::

   eam.rst

Modified Embedded Atom Model
----------------------------

.. toctree::

   meam.rst

Bond Order Potentials
---------------------

.. toctree::

   bondorder.rst

Machine-Learning Interatomic Potentials
---------------------------------------

.. toctree::

   mlip.rst

Force Fields
------------

.. toctree::

   forcefields.rst

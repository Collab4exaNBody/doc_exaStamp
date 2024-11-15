Interatomic Potentials
======================

The general formalism to compute forces and energies from an interatomic potential is through the use of the YAML block ``compute_force`` as follows:

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

which is called at every timestep during the integration loop. Multiple force operators can be stacked under the ``compute_force`` block. Spefici force operators corresponding to different interatomic potentials are defined hereafter. In addition, thermostats can also be appended to the ``compute_force`` block and the latter are defined in the :ref:`nvt` section. Finally, external forces coming from a repulsive wall for example can also be appended to the ``compute_force`` block. Such operators are defined in the :ref:`external_forces` section.

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

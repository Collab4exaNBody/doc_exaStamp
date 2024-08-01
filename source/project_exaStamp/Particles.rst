.. _species:

Particle Types
==============

Multiple particle types can be used in ``ExaStamp`` such as atoms, rigid molecules or fully-flexible molecules. These three formalism have an influence on the way the interactions are computed and will be explained in detail below. However, the common basis for all particle types is the definition of a ``YAML`` block containing information about the atoms. The species block can be defined as follows

.. code-block:: yaml
                
   # Species definition for atomic systems
   species:
     - O:
         mass:  15.9994 Da
         z: 8
         charge: -1.1104 e-
     - U:
         mass:  238.02891 Da
         z: 92
         charge: 2.2208 e-

   # Species definition for molecular systems
   species:
     - h2o_H:
         mass:  1.008 Da
         z: 1
         charge: 0.5564 e-
         molecule: molH20
     - h2o_O:
         mass:  15.999 Da
         z: 8
         charge: -1.1128 e-
         molecule: molH20
     - o2_O:
         mass:  15.999 Da
         z: 8
         charge: 0.0 e-
         molecule: molO2

.. toctree::
   :name: particle types

   atoms.rst
   rigid_molecules.rst
   flexible_molecules.rst

Default Execution Graph With ExaStamp
=====================================

``ExaStamp`` is based on the operator execution system implemented by the ``exaNBody`` framework. In particular, this allows us to define a set of default operators for ``ExaStamp`` to run an ``MD`` simulation using the Velocity-Verlet integration scheme. ``ExaStamp`` offers multiple variants, depending on whether the user wants to simulate monoatomic or polyatomic systems or even a set of flexible/rigid molecules. To choose between these two variants, the user will need to include either one of these configuration files at the beginning of the main input file for ``ExaStamp``:

- **config_species.msp** for both monoatomic and polyatomic systems
- **config_species_rigidmol.msp** for rigid molecules systems
- **config_molecule.msp** for flexible molecules systems

If neither is included, the simulation will not start. Including these files allows the user to override specific operators left at *nop* (for no operation). The graph below shows the sequence of ``ExaStamp``'s main operators.

TODO : Ajout du graphe comme pour exaDEM.

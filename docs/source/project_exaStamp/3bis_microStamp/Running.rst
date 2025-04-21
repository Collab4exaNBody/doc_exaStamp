Run the SNAP benchmark
----------------------

.. code-block:: bash

   tar -zxvf benchmark-snap-new.tgz
   cd benchmark-snap-new/
   ${ONIKA_INSTALL_DIR}/bin/onika-exec snap_from_dump.msp
   
   # To increase the number of cells (thus number of used cuda blocks)
   # and the total number of particles, one can add the --set-replicate_domain-repeat "[Nx,Ny,Nz]"
   # where Nx, Ny, Nz are the number of replication in each direction of the 3D space.
   
   # Example for replicating 8 times (2 in each direction):
   ${ONIKA_INSTALL_DIR}/bin/onika-exec snap_from_dump.msp --set-replicate_domain-repeat "[2,2,2]"


Running your simulation
=======================

Now that you have installed ``ONIKA``, ``exaNBody`` and ``exaStamp``, you can create your simulation file using the ``YAML`` format (refer to the ``Beginner's guide to exaStamp`` section to learn how to build your first input deck! Once this file is constructed, you can run your simulation with a specified number of ``MPI`` processes and threads per ``MPI`` process:

.. tabs::

   .. tab:: **CMake**
   
      .. code-block:: bash

         source ${XSP_BUILD_DIR}/exaStamp
         export OMP_NUM_THREADS=10
         export N_MPI=2
         mpirun -np ${N_MPI} onika-exec input_deck.msp
         **OR**
         mpirun -np ${N_MPI} ${XSP_BUILD_DIR}/exaStamp input_deck.msp

   .. tab:: **Spack**
                  
      .. code-block:: bash

         source ${XSP_BUILD_DIR}/exaStamp
         export OMP_NUM_THREADS=10
         export N_MPI=2
         spack load exastamp
         mpirun -np ${N_NMPI} exaStamp input_deck.msp
         
   .. tab:: **Docker**
                  
      .. warning::
         Under construction...

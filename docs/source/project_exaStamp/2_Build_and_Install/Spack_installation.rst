Installation with Spack
=======================
         
Install YAML
------------

The next step involves the installation of ``yaml-cpp``, which can be achieved using ``Spack``, ``apt-get`` or ``CMake``

.. tabs::

   .. tab:: **CMake**
   
      .. code-block:: bash

         export CURRENT_HOME=$PWD
         git clone -b yaml-cpp-0.6.3 git@github.com:jbeder/yaml-cpp.git
         mkdir ${CURRENT_HOME}/buil-yaml-cpp && cd ${CURRENT_HOME}/buil-yaml-cpp
         cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${CURRENT_HOME}/install-yaml-cpp -DYAML_BUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_TESTS=OFF ../yaml-cpp
         make -j8 install
         cd ${CURRENT_HOME}
         export PATH_TO_YAML=${CURRENT_HOME}/install-yaml-cpp

   .. tab:: **apt-get install**
   
      .. code-block:: bash

         sudo apt install libyaml-cpp-dev
                      
   .. tab:: **Spack**
   
      .. code-block:: bash

         spack install yaml-cpp@0.6.3
         spack load yaml-cpp@0.6.3

In any case, the ``cmake`` configuration files of ``exaNBody`` includes an automatic search of ``yaml-cpp`` installation on the machine and an error message will be displayed if it cannot be found. Please ensure to remove `yaml-cpp` and `build-yaml-cpp` folders afterwards. When installing ``exaSTAMP``, you can specify the YAML path by adding either ``-DCMAKE_PREFIX_PATH=${PATH_TO_YAML}`` or ``-Dyaml-cpp_DIR=${YAML_PATH}`` to the cmake command.

Optional Dependencies
---------------------

Before proceeding further, you have the option to consider the following dependencies:

- ``CUDA``
- ``MPI``
- ``HIP``  

Install ONIKA
-------------

Install exaNBody
----------------

Install exaStamp
----------------

ExaSTAMP Spack Installation
---------------------------

.. warning::

   This section is under construction and is not effective yet.
   
Installation with ``spack`` is preferable for people who don't want to develop in ``exaStamp``. Only stable versions are added when you install ``exaStamp`` with ``Spack``.

.. note::
  The main of ``exaStamp`` will never be directly accessible via this installation method.

Installing Spack
----------------

.. code-block:: bash

  git clone https://github.com/spack/spack.git
  export SPACK_ROOT=$PWD/spack
  source ${SPACK_ROOT}/share/spack/setup-env.sh

Installing exaStamp
-------------------

First go to the ``exaStamp`` repository and add it to spack. It contains two packages: ``exanbody`` and ``exastamp``:

.. code-block:: bash
		
   git clone https://github.com/Collab4exaNBody/exaStamp.git
   cd exaStamp
   spack repo add spack_repo

Secondly, install ``exaStamp`` (this command will install ``cmake``, ``yaml-cpp`` and ``exanbody``).

.. code-block:: bash

  spack install exastamp

Running your simulation
***********************

Now that you have installed the ``exaStamp`` and ``exaNBody`` packages, you can create your simulation file using the ``YAML`` format (refer to the ``example`` folder or the documentation for each operator for more information). Once this file is constructed, you can run your simulation with a specified number of ``MPI`` processes and threads per `MPI`` process (e.g. 2 MPI with 4 threads per MPI) using the following instructions:

.. code-block:: bash
		
   export N_OMP=4
   export N_MPI=2
   export OMP_NUM_THREADS=$N_OMP
   mpirun -n $N_MPI ./exaStamp test-case.msp
                      


.. warning::
  It's important to note that the maximum number of neighbors is set to 512 in the general case and to 32 for MEAM potentials. To change these value, you can specify the required number by adding : ``-DXSTAMP_MAX_PARTICLE_NEIGHBORS=N`` or ``-DXSTAMP_MEAM_MAX_NEIGHBORS=N`` to the `cmake` command.

   

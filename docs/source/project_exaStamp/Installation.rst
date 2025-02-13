Installation
============

.. warning::

   This section concerns the installation procedure for ``exaStamp`` with a version of ``exaNBody`` < 2.0. Another installation procedure for version >= 2.0 is provided in the next section. The latter will be the main procedure to follow in a near future.
   
``ExaSTAMP`` currently provides a single installation method through the use of ``CMake``, dedicated to both users and developer. The use of ``CMake`` allows the full support on both `CPU` and `GPU` architectures. A second installation procedure will be provided in a near future through the use of ``Spack`` package manager which offers a straightforward installation process, mostly dedicated to users only. However, for those who would like to be involved in the development of ``ExaStamp``, ``CMake`` is recommended as the ``Spack`` route won't provide access to the main branch but rather to stable versions of ``ExaStamp``.

Prerequisites
^^^^^^^^^^^^^

To proceed with the installation, your system must meet the minimum prerequisites.

exaNBody
--------

The first step involves the download of the ``exaNBody`` platform:

.. code-block:: bash

   git clone https://github.com/Collab4exaNBody/exaNBody.git
   export exaNBody_DIR=${PWD}/exaNBody

yaml-cpp
--------
   
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

ExaSTAMP CMake Installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

To install ``ExaStamp``, first ensure that the environment variable `exaNBody_DIR` is set as indicated above. You can also define the `exaNBody_DIR` variable directly in the `cmake` command by adding ``-DexaNBody_DIR=${path_to_exaNBody}`` to it. Then, clone the ``exaStamp`` repository and create a build folder:

.. code-block:: bash
		
   git clone https://github.com/Collab4exaNBody/exaStamp.git
   mkdir build-exaStamp && cd build-exaStamp

Run ``CMake`` to configure the ``exaStamp`` build, specifying that ``CUDA`` support should be turned on or off. Below are a few compilations examples.

.. tabs::

   .. tab:: **CMake Minimal**
   
      .. code-block:: bash
		
         cmake ../exaStamp -DXNB_BUILD_CUDA=OFF
         make -j8 && make UpdatePluginDataBase

   .. tab:: **CMake with GPU A100**
   
      .. code-block:: bash
		
         cmake ../exaStamp -DXNB_BUILD_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=80
         make -j8 && make UpdatePluginDataBase

Additional adjustments can be done using ``CMake`` by running the following command:

.. code-block:: bash
		
   ccmake .

.. warning::
  It's important to note that the maximum number of neighbors is set to 512 in the general case and to 32 for MEAM potentials. To change these value, you can specify the required number by adding : ``-DXSTAMP_MAX_PARTICLE_NEIGHBORS=N`` or ``-DXSTAMP_MEAM_MAX_NEIGHBORS=N`` to the `cmake` command.

The command `make UpdatePluginDataBase` shown above will display all plugins and related operators:

.. code-block:: bash

   + exanbDefBoxPlugin
     operator    apply_xform
     operator    xform_constant_strain_rate
     operator    deformation_xform
     operator    domain_extract_xform
     operator    domain_set_xform
     operator    xform_time_interpolate_byparts
     operator    xform_time_interpolate
     operator    push_v_r
     operator    push_f_v
     operator    push_f_r
   + exaStampIOPlugin
     operator    read_dump_atoms
     operator    read_dump_molecule
     operator    read_dump_rigidmol
     operator    read_xyz_file_with_xform
     operator    read_xyz_file_with_xform_molecules
     operator    lattice
     operator    write_dump_atoms
     operator    write_dump_molecule
     operator    write_dump_rigidmol
     operator    write_xyz

.. note::
  The list of plugins and overall organization is still subject to changes. This will be announced in the relase notes above.

ExaSTAMP Spack Installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^

Now that you have installed the ``exaStamp`` and ``exaNBody`` packages, you can create your simulation file using the ``YAML`` format (refer to the ``example`` folder or the documentation for each operator for more information). Once this file is constructed, you can run your simulation with a specified number of ``MPI`` processes and threads per `MPI`` process (e.g. 2 MPI with 4 threads per MPI) using the following instructions:

.. code-block:: bash
		
   export N_OMP=4
   export N_MPI=2
   export OMP_NUM_THREADS=$N_OMP
   mpirun -n $N_MPI ./exaStamp test-case.msp

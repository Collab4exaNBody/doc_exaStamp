Installation with Spack
=======================

Installation with ``Spack`` is easy and preferable for users who don't want to develop in ``exaStamp``. Only stable versions are added when you install ``exaStamp`` with ``Spack``.

.. note::
   The main of ``exaStamp`` will never be directly accessible via this installation method.

Spack
-----

.. code-block:: bash

   cd ${HOME}/dev
   git clone https://github.com/spack/spack.git
   export SPACK_ROOT=${HOME}/dev/spack
   source ${SPACK_ROOT}/share/spack/setup-env.sh

YAML
----

.. tabs::

   .. tab:: **Spack**
   
      .. code-block:: bash

         spack install yaml-cpp@0.6.3
         spack load yaml-cpp@0.6.3
   
   .. tab:: **CMake**
   
      .. code-block:: bash

         YAMLTMPFOLDER=${path_to_tmp_yaml}
         mkdir ${YAMLTMPFOLDER} && cd ${YAMLTMPFOLDER}
         git clone -b yaml-cpp-0.6.3 git@github.com:jbeder/yaml-cpp.git
         *OR* git clone -b yaml-cpp-0.6.3 https://github.com/jbeder/yaml-cpp.git
         YAML_CPP_INSTALL_DIR=${HOME}/local/yaml-cpp-0.6.3
         cd ${YAMLTMPFOLDER} && mkdir build && cd build

         cmake -DCMAKE_BUILD_TYPE=Debug \
               -DCMAKE_INSTALL_PREFIX=${YAML_CPP_INSTALL_DIR} \
               -DYAML_BUILD_SHARED_LIBS=OFF \
               -DYAML_CPP_BUILD_CONTRIB=ON \
               -DYAML_CPP_BUILD_TESTS=OFF \
               -DYAML_CPP_BUILD_TOOLS=OFF \
               -DYAML_CPP_INSTALL=ON \
               -DCMAKE_CXX_FLAGS=-fPIC \
               ../yaml-cpp

         make -j4 install
         cd ../..
         rm -fr ${YAMLTMPFOLDER}

   .. tab:: **apt-get install**
   
      .. code-block:: bash

         sudo apt install libyaml-cpp-dev

exaStamp
--------

First go to the ``exaStamp`` repository and add it to spack. It contains two packages: ``exanbody`` and ``exastamp``:

.. code-block:: bash

   git clone https://github.com/Collab4exaNBody/spack-repos.git
   spack repo add spack-repos		            
   
Secondly, install ``exaStamp`` (this command will install ``cmake``, ``yaml-cpp``, ``ONIKA`` and ``exaNBody``).

.. code-block:: bash

  spack install exastamp


Installing ExaNB
================

To proceed with the installation, your system must meet the minimum prerequisites. The first step involves the installation of exaNBody:

.. code-block:: bash

   git clone https://github.com/Collab4exaNBody/exaNBody.git
   mkdir build-exaNBody/ && cd build-exaNBody/
   cmake ../exaNBody/ -DCMAKE_INSTALL_PREFIX=path_to_install
   make install
   export exaNBody_DIR=path_to_install   



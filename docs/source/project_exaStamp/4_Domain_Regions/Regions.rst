Spatial Regions
===============

Spatial regions can be very usefull in order to define areas in the simulation domain that are subsequently used to populate with particles or perform analysis on a subdomain for example. The regions can be defined using the ``particle_regions`` YAML block, defined as follows:

.. code-block:: yaml
   :caption: **YAML block for regions definition**

   particles_regions:
     - REG1
     - REG2
     - REG3

where `REG1`, `REG2` and `REG3` can be regions defined using different ways. Indeed, a region can be defined using either:

- A geometrical definition that can either be a parallelepiped or q quadric mathematical function that gives access to planes, spheres/ellipsoids, cones and any mathematical 3*{rd} order 3D function
- A user-defined analytical function evaluated on the 3D domain grid
- A mask read on an external file with dimensions equal to the 3D domain grid
- A range of particles ids

Geometrical Definition
----------------------

Parallelepiped
**************

.. list-table:: **Parallelepiped regions** 
   :widths: 50 50
   :header-rows: 0

   * - .. code-block:: yaml

          particle_regions:  
            - B1:
                bounds: [ [ 10, 10, 5], [30, 50, 15] ]
            - B2:
                bounds: [ [ 15, 10, 25], [65,30,40] ]
            - B3:
                bounds: [ [ 30, 70, 10], [50, 90, 95] ]
     - .. image:: /_static/boxes.png
         :width: 400px

Quadrics
********

Planes
******

.. list-table:: **Planes from quadrics** 
   :widths: 50 50
   :header-rows: 0

   * - .. code-block:: yaml
             
          particle_regions:  
            - P1:
                quadric:
                  shape: { plane: [ 1, 0, 0, 0 ] }
                  transform: { translate: [ 20, 0, 0 ] }
            - P2:
                quadric:
                  shape: { plane: [ 0, 1, 0, 0 ] }
                  transform: { translate: [ 0, 20, 0 ] }
            - P3:
                quadric:
                  shape: { plane: [ 0, 0, 1, 0 ] }
                  transform: { translate: [ 0, 0, 20 ] }
     - .. image:: /_static/planes.png
         :width: 400px

Cylinders
*********

.. list-table:: **Cylinders from quadrics**
   :widths: 50 50
   :header-rows: 0

   * - .. code-block:: yaml
             
          particle_regions:  
            - P1:
                quadric:
                  shape: cylx
                  transform:
                    scale: [ -1, 15, 15 ]
                    zrot: pi/4.
                    translate: [ 50, 50, 50 ]
            - P2:
                quadric:
                  shape: cyly
                  transform:
                    scale: [ 15, -1, 15 ]
                    zrot: pi/4.
                    translate: [ 50, 50, 50 ]
            - P3:
                quadric:
                  shape: cylz
                  transform:
                    scale: [ 15, 15, -1 ]
                    yrot: -pi/4.
                    translate: [ 50, 50, 50 ]
     - .. image:: /_static/cylinders.png
         :width: 400px

Spheres/Ellipsoïds
******************

.. list-table:: **Spheres/Ellipsoids from quadrics**
   :widths: 50 50
   :header-rows: 0

   * - .. code-block:: yaml
             
          particle_regions:  
            - S1:
                quadric:
                  shape: sphere
                  transform:
                    scale: [ 20, 20, 20 ]
                    translate: [ 45, 75, 70 ]
            - S2:
                quadric:
                  shape: sphere
                  transform:
                    scale: [ 40, 30, 10 ]
                    translate: [ 50, 60, 20 ]
            - P3:
                quadric:
                  shape: sphere
                  transform:
                    scale: [ 50, 10, 10 ]
                    yrot: pi/6.
                    translate: [ 50, 30, 50 ]
     - .. image:: /_static/spheres.png
         :width: 400px

Cones
*****

.. list-table:: **Cones from quadrics**
   :widths: 50 50
   :header-rows: 0

   * - .. code-block:: yaml
             
          particle_regions:  
            - CO1:
                quadric:
                  shape: conex
                  transform:
                    scale: [ 3, 0.75, 1.5 ]
                    translate: [ 50, 50, 50 ]
            - CO2:
                quadric:
                  shape: coney
                  transform:
                    scale: [ 1.5, 3, 0.75 ]
                    translate: [ 50, 50, 50 ]
            - CO3:
                quadric:
                  shape: conez
                  transform:
                    scale: [ 1, 1, 3 ]
                    translate: [ 50, 50, 50 ]
     - .. image:: /_static/cones.png
         :width: 400px

Matrix4d
********

.. code-block:: yaml

   CYL9:
     - quadric:
         - shape: cylz
         - transform:
             - scale: [ 15 ang , 15 ang , 15 ang ]
             - xrot: pi/4
             - yrot: pi/3
             - zrot: pi/6             
             - translate: [ 85 ang , 85 ang , 0 ang ]      

Assigning Regions to Grid
*************************

.. code-block:: yaml

   set_cell_values:
     field_name: "region"
     region: CYLX or CYLY or CYLZ
     value: [0,1]
     grid_subdiv: 10

Using the Grid as a mask
************************

User-defined function
*********************

.. code-block:: yaml

   user_function:
     # WaveFrontSourceTerm
     wavefront:
       # first 3 values are interface plane (Pi)'s normal vector (X,Y,Z) , last one is plane offset (position of origin relative to the plane).     
       plane: [ -1 , 0 , 0 , 125.0 ang ]
       # wave plane (normal and offset). Oriented distance to the plane, Pw(r), is used to add a sinusoid function sin(P(r))*amplitude to the plane function above
       wave: [ 0 , 0.1 , 0 , 0 ]
       # User function is F(r) = Pi(r)+sin(Pw(r))*amplitude , interface is implicit surface F(r)=0, atoms are placed everywhere where F(r)>=0
       amplitude: 10.0 ang
   user_threshold: 0.0

   user_function:
     # SphericalTemporalSourceTerm   
     sphere:
       center: [30, 30, 30]
       amplitude: 10.
       radius_mean:
       radius_dev:
       time_mean:
       time_dev:
       
   user_function:
     # ConstantSourceTerm   
     constant: 10.

Based on Particles' ids
***********************

.. code-block:: yaml

   REGID1:
     - id_range: [1, 1300]

Tracking Particles
******************

.. code-block:: yaml

   track_region_particles:
     expr: PLANE1
     name: "PISTON"

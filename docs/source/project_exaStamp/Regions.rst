Spatial Regions Definition
--------------------------

quadric or box

.. code-block:: yaml

   example_box:
     - bounds: [ [ 250 ang , 0 ang , 0 ang ] , [ 300 ang , 300 ang , 300 ang ] ]
       
.. code-block:: yaml

   example_quadric:
     - quadric:
         - shape: cylx # or cyly or cylz or sphere or conex or coney or conez or plane
         - transform:
             - scale: [ 15 ang , 15 ang , 15 ang ]
             - xrot: pi/4
             - yrot: pi/3
             - zrot: pi/6             
             - translate: [ 85 ang , 85 ang , 0 ang ]      

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

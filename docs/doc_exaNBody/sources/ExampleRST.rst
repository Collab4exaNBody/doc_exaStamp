Example for rst usage (math, code etc)
======================================

Example of math citatiion :
---------------------------

To cite paper, place the appropriate reference in the file source/Bibliography.rst. Then, you can cite it by using this kind of command:

My paper is written by :ref:`(AaBbCcDd et al.) <AuthorYear>`


Example of math with latex as equation :
----------------------------------------

.. math::
   :label: eqtest

   \frac{ \sum_{t=0}^{N}f(t,k) }{N}	   

Example of math with latex as inline text :
-------------------------------------------

Quand \\(a > 0\\) alors il y a deux solutions à \\(ax^2 + bx + c = 0\\) et elles sont exactement $$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}.$$

Le double dollar indique une équation "standalone" sur sa ligne

Example of bash code :
----------------------

.. code-block:: bash

   mkdir my_new_plugin
   add_subdirectory(my_new_plugin)
   cd my_new_plugin
   vi CMakeLists.txt

Example of cpp code :
---------------------

.. code-block:: cpp

   namespace exaSPH
   {
     struct TestFunctor
     {
       exanb::Vec3d a = { 1.0 , 2.0 , 3.0};
       ONIKA_HOST_DEVICE_FUNC inline void operator () (double mass, double& fx, double& fy, double& fz ) const
       {
         fx += a.x * mass;
         fy += a.y * mass;
         fz += a.z * mass;
       }
     };
   }		

Example of yaml code :
----------------------

.. code-block:: yaml
		
   domain:
     cell_size: 2 m
     periodic: [false,true,false]


.. |ex1start| image:: ../../doc_exaNBody/sources/images/rotating_drum_start.png
   :width: 300pt

.. |ex1end| image:: ../../doc_exaNBody/sources/images/rotating_drum_end.png
   :width: 300pt

Example of simple figure :
--------------------------

.. figure:: ../../doc_exaNBody/sources/images/rotating_drum_start.png
   :width: 300pt
   :alt: map to buried treasure
   :align: center
	   
   Figure 1: This is the caption of the figure (a simple paragraph).



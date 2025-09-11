N-Body Background
=================

N-body methods
--------------

N-body methods encompass a variety of techniques used to model the behavior and interactions of a set of particles over time. 
These methods consist in solving Newton’s equation of motion f = ma for each particle at each time step, where f corresponds to the sum of the forces applied to the particle, a its acceleration and m its mass. 
The forces are deduced from the interactions between particles according to their types, i.e. contact, short-range, or long-range interactions, and external forces applied to the sample (i.e. gravity). 
Velocities are then deduced from the accelerations and subsequently used to update the particle positions at the next time step. 
This process is repeated, typically with a fixed time step ∆t, according to an integration scheme4 until the desired duration is reached. 
The collection of particle configurations over time allows to study a wide range of phenomena, from granular media movements, with the Discrete Element Method (Dem), to material crystal plasticity at the atomic scale using Molecular Dynamics (Md), going up to the galaxy formation with the Smoothed-Particle Hydrodynamics (Sph).

N-body simulation codes
-----------------------

The development of a N-body code is led by the need to figure out the neighborhood of a given particle for every timestep in order to process interactions of different kinds.

Particle interactions can be categorized as short-range and long-range.
Short-range interactions are considered negligible beyond a specified cut-off radius. 
To optimize calculations, neighboring particle detection algorithms are employed to eliminate unnecessary computations with distant particles. 
Each N-Body method employs a wide variety of short-range interactions that capture different particle physics. 
For example, visco-elastic contacts in Discret Element Method follow Hooke’s law or Hertz law to model contact elasticity between rigid particles, while pair potentials like Lennard-Jones or Morse are used for gas or liquid atom interactions in classical Md. Long-range interactions, on the other hand, can sometimes not be neglected and result in algorithmic complexity of O(N 2 ).
Such interactions, like gravitation in astrophysics, or electrostatic forces in Molecular Dynamics, are typically modeled using the Ewald summation method. 
Fortunately, calculation approaches such as the fast multipole method can achieve a complexity of O(N ), thanks to an octree structure, and can be efficiently parallelized.
Although this paper primarily focuses on short-range interactions, both types of interaction can be dealt with in exaNBody.

Neighbor lists are built, using different strategies, to shorten the process of finding out the neighbors of a particle within the simulation domain. 
It helps optimizing the default algorithm having a complexity of O(N^2) that tests every pair of particles (if N is the number of particles). 
The most common strategy to deal with any kind of simulation (static or dynamic, homogeneous and heterogeneous density) is a fusion between the linked-cell method, see figure 2, and the Verlet list, see figure 2 method. 
The combination of these methods has a complexity of O(N) and a refresh rate that depends on the displacement of the fastest particle. 
This algorithm is easily thread-parallelized. Others less-used neighbor search strategies have been developed to address specific simulations

.. figure:: ../../doc_exaNBody/sources/images/Verlet.png
   :width: 250pt
   :alt: map to buried treasure
   :align: center
	   
   Figure 1: A method for building neighbor lists using the Verlet lists. `rcut` is the radius cut-off and `rVerlet` is the radius of Verlet.


.. figure:: ../../doc_exaNBody/sources/images/LC.png
   :width: 250pt
   :alt: map to buried treasure
   :align: center
	   
   Figure 2: A method for building neighbor lists using linked cells. `rcut` is the radius cut-off.


Domain decomposition is usually employed in N-Body methods to address distributed memory parallelization, assigning one subdomain to each MPI process. 
This implies the addition of ghost areas (replicated particles) around subdomains to ensure each particle has access to its neighborhood. 
Over time, many algorithms have been designed to improve load-balancing such as: Recursive Coordinate Bisection (RCB), the Recursive Inertial Bisection (RIB), the Space Filling Curve (SFC), or graph method with ParMETIS. 
Note that the library Zoltan gathers the most popular methods. 
To ease neighbor list construction (i.e. employing the linked-cell method), the simulation domain is described as a cartesian grid of cells, each of which containing embedded particles. 
Each subdomain then consists in a grid of entire cells assigned to one Mpi process. 
In contrast, concurent iteration over the cells of one subdomain’s grid provides the basis for thread parallelization at the NUMA node level.


Commonalities are shared across N-body simulation codes, such as numerical schemes, neighbor particle detection, or short/long-range interactions. 
The computation time dedicated to interaction and force calculations can be significant (over 80% of the total time) depending on the studied hpenomenon complexity. 
Additional factors, such as neighbor lists construction computational cost, can impact overall simulation time. 
For dynamic simulations involving rapidly moving particles and computationally inexpensive interactions, more than 50% of the total time may be spent on neighbor list construction. 
The computationally intensive sections of the code vary depending on methods and phenomena studied, requiring optimizations such as:

  * MPI parallelization
  * Vectorization
  * Multi-threading
  * GPU usage

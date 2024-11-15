Performance and portability
===========================

The complex and ever-changing architectures of modern supercomputers make it difficult to maintain software performance. exaNBody aims at providing performance portability and sustainability on those supercomputers with robust domain decomposition, automated inter-process communications algorithms, adaptable particle data layout, and a set of hybrid (CPU/GPU) parallelization
templates specialized for N-Body problems.


Application level specialization
--------------------------------

First of all, the internal units to be used are specified as well as the physical quantities to be stored as particle attributes. 
These quantities (or fields), are defined using a symbolic name associated with a type, e.g. velocity as a 3D vector. 
A field set is a collection of declared fields. 
One of the available field sets is selected and used at runtime, depending on simulation specific needs. 
As depicted in figure below, particles are dispatched in cells of a cartesian grid spanning the simulation domain. 
In short, the data structure containing all particles’ data will be shaped as a cartesian grid of cells, each cell containing all fields for all particles it (geometrically) contains. 
More specifically, the reason why fields and field sets are defined at compile time is that particle data storage at the cell level is handled via a specific structure guaranteeing access performance and low memory footprint.


Spatial domain decomposition and inter-process communications
-------------------------------------------------------------

The coarsest parallelization level can become the main bottleneck due to network latencies and load imbalance issues.
To take advantage of this first level of parallelization, the simulation domain is divided into subdomains using an recursive coordinate bisection (RCB) algorithm, as depicted in figure below, assigning one subdomain to each MPI process.

.. figure:: ../../doc_exaNBody/sources/images/inter_process_communications.png
   :width: 450pt
   :alt: map to buried treasure
   :align: center
	   
   Figure 1: Overview of domain decomposition and inter process communications in exaNBody framework.

This is achieved thanks to three main components: cell cost estimator, RCB domain decomposition, and particle migration. 
Particle migration can be used as-is by any N-Body application, thanks to the underlying generic particle data storage. 
It supportsheavily multi-threaded, large scale, simulations while lowering peak memory usage. 
Additionally, the migration algorithm is also customizable to fit specific application needs, keeping unchanged the core implementation. 
For instance, molecualr dynamics simulations may transport per-cell data fields and discret element method simulations may migrate friction information related to pair of particles. 
Finally, ghost particle updates are available to any N-Body application, via customizable components.


Intra-node parallelization API
------------------------------

This API is available in exaNBody to help developers express parallel computations within a MPI process. 
This API offers a set of parallelization templates associated with three types of computation kernels:

  * Local calculations on a particle (such as resetting force operator)
  * calculations coupled with reduction across all particles (such as getting the total number of particles or the current temperature)
  * calculations involving each particle and its neighbors (such as computing potential forces in molecular dynamics or contact forces in discret element method)

When a developer injects a compute function into these templates, computation may be routed to CPU or GPU, as illustrated in figure below. 

.. figure:: ../../doc_exaNBody/sources/images/compute_kernel_sample.png
   :width: 450pt
   :alt: map to buried treasure
   :align: center
	   
   Figure 2: Example of a particle centered computation executable on both COU and GPU. Three ingredients: a user functor (the kernel), static execution properties (via traits specialization), a ready to use parallelization function template.

While thread parallelization on the CPU is powered by OpenMP, Cuda is employed to execute the computation kernel on the Gpu, using the same provided function. 
The main difference between the two execution modes is that each cell is a unitary work unit for a single thread in OpenMP context but it is processed by a block of threads in Cuda. 
Those two parallelization levels (multi-core and GPU) are easily accessible to developers thanks to the execution support layer of Onika. 
Onika is the low-level software interface that powers exaNBody building blocks. 
It is responsible for aforementioned data containers, memory management (unified with GPU), and it is the foundation for hybrid execution abstraction layer.


Particle data layout and auxiliary data structures
--------------------------------------------------

These two points are two essential features to maximize performance at the NUMA node level. 
In exaNBody, particle data are packed independently in each cell using a container specifically designed to match both CPU’s SIMD and GPU’s thread blocks requirements concerning data alignment and vectorization friendly padding. 
This generic container, available in ONIKA toolbox, not only adapts to specific hardware characteristics at compile time, but ensures minimal memory footprint with as low as 16 bytes overhead per cell regardless of the number of data fields, allowing for very large and sparse simulation domains. 
N-Body simulations also heavily depend on particles’ neighbors search algorithm and storage structure. 
The search usually leverages the grid of cell structure to speed up the process, and neighbors lists data structure holds information during several iterations. 
However, depending on the simulation, particles may move rapidly while their distribution may be heterogeneously dense. 
Those two factors respectively impact neighbor list update frequency and its memory footprint. 
On the one hand, exaNBody takes advantage of an Adaptive Mesh Refinement (AMR) grid to accelerate (frequent) neighbor list reconstructions. 
On the other hand, a compressed neighbor list data structure saves up to 80% of memory (compared to uncompressed lists) while still ensuring fast access from both the CPU and the GPU.

Flexible and user friendly construction of N-Body simulations
-------------------------------------------------------------

A crucial aspect for software sustainability is to maintain performance over time while managing software complexity and evolution. 
Complex and rapidly evolving scientific software often encounter common pitfalls, such as code duplication, uncontrolled increase in software inter-dependencies, and obscure data/control
flows. This observation has led us to develop our component-based model to avoid these pitfalls. 
In our model, individual software components are implemented using C++17 and are application structure oblivious, meaning they only know their input and output data flows. Application obliviousness is a crucial aspect of the present design, promoting reusability while preventing uncontrolled growth of internal software dependencies. 
Each component is developed as a class, inheriting from a base class OperatorNode and explicitly declares its input and output slots (data flow connection points). 
Once compiled, these components are hierarchically assembled at runtime using a Sequential Task Flow (STF), with a YAML syntax, as shown in figure below.

.. figure:: ../../doc_exaNBody/sources/images/yaml_components.png
   :width: 450pt
   :alt: map to buried treasure
   :align: center
	   
   Figure 3: Illustrative sample of components assembly using YAML description. 1) C++ developed components are assembled and connected in the manner of a STF, creating a batch component. 2) and 3) illustrate batch components aggregation to higher and higher level components, up to full simulation task flow.


A set of base components are already available to developers, embedded within exaNBody, such as: common computations, checkpoint/restart, visualization and In-Situ analytics, allowing developers to focus on their application specific components. 
We also observed that this component based approach not only prevents some development pitfalls, but enables various simulation code structures. 
YAML formatted component configuration makes it simple for a user to amend or fine tune the simulation process. 
For instance it can be used to change the numerical scheme or even to insert In-Situ analysis components at specific stages of the simulation process, leveraging In-Situ processing to limit disk I/O. 
Finally, this component based splitting of the code gives exaNBody the opportunity to provide integrated profiling features that automatically give meaningful performance metrics for each part of the simulation. 
It allows the user to access computation time spent on CPU and GPU, as well as imbalance indicator. 
It can also interoperate with nSight System from NVIDIA and summarize memory footprint with detailed consumption.





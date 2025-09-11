ExaNBody: Framework for N-Body Simulations on HPC Platforms
===========================================================

This framework, developed at the French Atomic Agency (CEA), is tailored for N-Body simulations on High-Performance Computing (HPC) platforms. Originally designed for the ExaSTAMP Molecular Dynamics code, it has been extended to cater to various N-Body problems.

Key Characteristics:

* **Language:** Implemented in C++17, leveraging modern language features for efficiency and versatility.

* **Parallelization:**: Hybrid approach integrating:
	* Vectorization for CPU optimization.
	* Thread-parallelization using OpenMP for multi-core architectures.
	* GPU-parallelization via CUDA to harness GPU computational power.
	* MPI-parallelization for distributed memory systems.
  
* **Spatial Domain Decomposition:** Utilizes spatial domain decomposition techniques for efficient workload distribution among processors.

* **Load Balancing (RCB):** Implements Load Balancing using Recursive Coordinate Bisection (RCB) for optimal task distribution among processing units.

* **Parallel IO:** Enables efficient handling of parallel Input/Output operations. Supports checkpoint files, parallel Paraview files, and diagnostics in a parallelized manner.

* **In-situ Analysis:** Provides real-time data analysis capabilities during simulation execution, minimizing data movement and storage overhead.


ExaDEM Variant
--------------

``ExaDEM`` is a software solution in the field of computational simulations. It's a Discrete Element Method (``DEM``) code developed within the ``exaNBody framework``. This framework provides the basis for DEM functionalities and performance optimizations. A notable aspect of ``ExaDEM`` is its hybrid parallelization approach, which combines the use of ``MPI`` (Message Passing Interface) and Threads (``OpenMP``). This combination aims to enhance computation times for simulations, making them more efficient and manageable.

Additionally, ``ExaDEM`` offers compatibility with ``MPI``+``GPUs``, using the ``CUDA`` programming model (Onika layer). This feature provides the option to leverage ``GPU`` processing power for potential performance gains in simulations. Written in ``C++17``, ``ExaDEM`` is built on a contemporary codebase. It aims to provide researchers and engineers with a tool for adressing ``DEM`` simulations.

ExaSPH Variant
--------------

ExaSTAMP Variant
----------------

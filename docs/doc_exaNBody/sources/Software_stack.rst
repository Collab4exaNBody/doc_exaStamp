Software stack of ExaNBody
==========================

Software Stack Layers:
----------------------

#. External Libraries: This layer encompasses external dependencies utilized by the software. These libraries are leveraged to access functionalities that are not internally developed, enhancing the overall capabilities of the system.

	* HPC Libraries: High-Performance Computing (HPC) libraries serve as powerful tools within the software stack, providing optimized routines and functionalities specifically designed for high-computational tasks.

#. Low-Level and Runtime Support (Onika): Foundational infrastructure and runtime support are provided by this layer. Onika serves as the backbone, offering essential utilities for the execution and management of the software. It's important to note that ongoing efforts are directed towards integrating frameworks like OpenMP or CUDA.

#. N-Body Framework: Positioned at the core of the software stack, the N-Body Framework proposes a large variety of N-Body features to build efficiently N-Body simulation such as traditionnal integration schemes, IO, or partiionning methods.

#. Application Layer: This layer encapsulates the specific applications built upon the software stack. It provides the interface for users to interact with the functionalities offered by the stack and serves as the platform for N-Body application-specific implementations and functionalities.

.. |exanb-st| image:: ../../doc_exaNBody/sources/images/software_stack.png
   :width: 500pt

|exanb-st|

Guidelines for operators:
-------------------------

* Common Operators: These operators serve as N-Body fundamental operations utilized across various components of the software, facilitating consistent functionality and reducing redundancy.
* Application-Specific Operators: Tailored operators designed to cater to the unique requirements of specific applications built on top of the software stack.
* Mutualization: This process involves the consolidation and centralization of specific operators shared by multiple applications. It aims to optimize resources and streamline the execution of these shared functionalities.
* Specific Operators Shared Among Applications: For increased efficiency and ease of access, specific operators that are shared among multiple applications are centralized within exaNBody. This consolidation not only ensures optimized utilization but also simplifies management and maintenance, benefiting all associated applications.



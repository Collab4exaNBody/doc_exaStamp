---
icon: material/hammer-wrench
---

# **Installation guide**

`exaStamp` is written in `C++17`/`C++20`. It can be built under Linux using either `CMake` or `Spack`. The `Spack` installation is recommended for users who do not want to develop in `exaStamp`. However, we provide extensive installation instructions for HPC clusters through the `CMake` procedure only.

Installing `exaStamp` therefore consists of first installing `onika` and `exaNBody` that both depend on `YAML` as `exaStamp`. The `Spack` manager is only required if you do not want to install `exaStamp` through `CMake`. To allow for a clean and simple installation of `exaStamp`, we also provide the installation instructions for the required packages.

A basic procedure is provided for a [Spack installation](spack_installation.md) as well as a [CMake installation](cmake_installation.md) from the sources.

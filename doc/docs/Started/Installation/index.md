# Installation guide

`SLOTH` is written in `C++17`/`C++20`. It can be built under Linux and MacOS using `CMake`. 
The main prerequisite is the `MFEM` Finite Element library developed in C++ by LLNL[@mfem].

`MFEM` can be installed in several ways but the use of `spack` on [Linux](linux.md) and `Homebrew`on [MacOS](mac.md) is recommended for sake of simplicity.

Installing `SLOTH` therefore consists of first installing `MFEM` and compiling `SLOTH`. 
The basic procedure is then provided for the [Linux platforms using spack](linux.md), the [Linux platforms from source files](sources.md) and the [MacOs platforms](mac.md), but also for [supercomputers](cluster.md) where `SLOTH` is intended to be used.

For certain applications, `SLOTH` utilizes C++ APIs contained within the library [`libTorch`](https://pytorch.org/cppdocs/installing.html) to load `PyTorch` models. The basic procedure also includes [instructions for installing `libTorch`.](libtorch.md)





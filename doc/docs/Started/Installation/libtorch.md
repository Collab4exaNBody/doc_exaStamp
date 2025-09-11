---
icon: simple/pytorch
---

# PyTorch C++ API

The following installation procedure describes how to install and link the library `libTorch` that contains C++ APIs used to load `PyTorch` models in some `SLOTH` applications. 
The procedure focuses on the CPU-only `libTorch`

## __Getting libTorch__

The library `libTorch` can be downloaded either from the [`PyTorch` website](https://pytorch.org/) or by running the following instructions in a terminal:

```bash
wget https://download.pytorch.org/libtorch/nightly/cpu/libtorch-shared-with-deps-latest.zip
     
unzip libtorch-shared-with-deps-latest.zip
```

This will result in an uncompressed folder named `libtorch` that can be linked to `SLOTH` during the configuration of the project.

## __Linking SLOTH and libTorch__

To link `SLOTH` with `libTorch`, the user must load the `SLOTH` configuration file with the `--libtorch` option:

```bash
bash ../envSloth.sh --libtorch=$LIBTORCH_PATH
```

where `LIBTORCH_PATH` is an environment variable containing the path toward the `libtorch` folder previously uncompressed.
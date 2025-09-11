# Code quality 

## Static code analyis

[CppLint]() is used to check code quality according to Google's C++ style guide.

CppLint is a static code checker that can be easily installed from PyPI:

```bash
pip install cpplint
```

The options considered for static code analysis are:

- `linelength=100` to set the maximum allowed line length for your code
- `filter=-runtime/references,-build/header_guard,-runtime/string`

These options are placed in the file CPPLINT.cfg, available in the root of the SLOTH repository.

In practice, after loading the SLOTH environement file, using the CMake target  `lint` enables to run the static code analysis:

```bash
make lint
```


## Code coverage analysis

Performing code coverage analysis consists of three simple steps:

- Compilling SLOTH in coverage mode
```bash
mkdir build
cd build
source ../envSloth.sh --coverage
make -j N
```
- Running the tests (here, for example, all cases stored in the folder `tests`):
```bash
ctest -j N
```
- Running the CMake target `cc` to generate the code coverage analysis within the Coverage folder:
```bash
make cc
```

!!! warning "Code quality control before contributing"
    It is a prerequisite that both static code analysis and code coverage analysis are conducted prior to the incorporation of new functionalities in SLOTH. The results of these two analyses should get better or at least stay the same.


# Features

## General features

- Shared-memory multithreading (OpenMP)
- Message-passing parallelism (MPI)
- Graphics Processing Units (GPUs) via CUDA and HIP
- Can run on a single processor or with MPI only, though multithreading is recommended
- With MPI, spatial decomposition via Recursive Coordinate Bisection (RCB)
- Open-source under the Apache License 2.0
- Highly portable, modular C++20 code built on the Onika/exaNBody framework
- Entire simulation graph can be user-defined in the input file (simulation block)
- Easy to extend with new features and functionality
- Input files use an extended YAML-based format
- Run one or multiple simulations concurrently from a single script
- Assign independent resources to run the simulation and perform on-the-fly analysis
- Large suite of regression tests

## Particle types

- Atoms (metals, oxides, ceramics)
- Rigid molecules
- Flexible molecules (polymers, molecular crystals)

## Interatomic potentials

- Pair potentials: Buckingham, Exp-6, Lennard-Jones, ZBL, Morse, tabulated
- Short-range electrostatics: Coulombic
- Long-range electrostatics: Ewald, Wolf, reaction-field
- Many-body potentials: EAM, MEAM
- Machine-learning interatomic potentials (MLIPs): SNAP, N2P2, ACE
- Interface to the OpenKIM repository of potentials
- Bond potentials: harmonic, FENE, Morse, nonlinear, Class II (COMPASS), quartic (breakable), tabulated, scripted
- Angle potentials:
- Dihedral potentials:
- Improper potentials:
- Hybrid potentials: combine multiple pair, bond, angle, dihedral, and improper terms in a single simulation
- Overlay potentials: superposition of multiple pair and many-body potentials

## Particles creation

- Read external files (``.xyz``, ``.data``, ``.mpiio``)
- Create atoms on specific spatial regions 
- Logical operation to define regions and populate them with particles
- Replication of the system
- Uniform or gaussian oise on atomic positions, atomic velocities and forces in specific regions

## Thermodynamic and boundary conditions

- General triclinic simulation domain
- Isochoric-isoenergetic (NVE) ensemble
- Isochoric-isothermal (NVT) ensemble
- Isobaric-Isothermal (NPT) ensemble
- Two-temperature model (TTM)
- Parrinello/Rahman, Nosé-Hoover integrators
- Region-wise thermostatting of particles
- Pressure or component-wise stress barostats using Nosé/Hoover
- Deformation paths formalism for straining the box (any type of deformation can be applied)
- Periodic, Free, Mirror boundary conditions


## Time integration

- Velocity-Verlet integrator
- User-defined time integrator
- Rigid body integration for rigid molecules
- Energy minimization via conjugate gradient and relaxation dynamics

## Statistics and diagnostics

- Simulation graph
- Performance results
- Highly customizable configuration

## On-the-fly analysis

- Particle to grid projection
- Local average of per-particle field
- Local structural metrics (entropy, number of neighbors, centrosymmetry, crystal structure classification)
- Local mechanical metrics (deformation gradient tensor, velocity gradient tensor, slip/twinning system identification)
- Connected Component Labelling
- Slice projection and longitudinal profile calculation
- Histograms
- Radial distribution function (type-wise)

## Output

- Thermodynamic state and logging file
- Dump output on fixed and variable intervals, based on timestep or simulated time
- Simulation snapshots (``.xyz``, ``.vtk``, ``.vtp``) for OVITO and ParaView
- Binary restart files
- Per-atom quantities that can be appended to particles in simulation snapshots

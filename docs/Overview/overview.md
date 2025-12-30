---
icon: octicons/history-16
---

# A little background

`exaStamp` is a software package for molecular dynamics simulations. It stands for `Simulations Temporelles Atomistiques et Moléculaires Parallèle à l’Exascale` (in French) or `exascale Simulations of Time-dependent Atomistic and Molecular systems in Parallel` (in English).

`exaStamp` is a classical molecular dynamics (MD) code developed within the `exaNBody`[^exanbody] framework HTML, allowing users to model systems of particles in any state (liquid, solid, or gas). For example, polymers, molecular crystals, and dense crystalline materials such as metals, ceramics, and oxides can be simulated with `exaStamp`. A wide range of force fields and boundary conditions is available, enabling complex simulations with up to a few billion particles.

In general terms, `exaStamp` integrates Newton’s equations of motion for collections of interacting particles. Each particle can represent an atom or a rigid molecule. Most interaction models in `exaStamp` are short-ranged, with some long-range models also available. `exaStamp` uses neighbor cells to track nearby particles; these cell lists are optimized for systems with strong short-range repulsion, so local particle density remains manageable. On parallel machines, `exaStamp` employs the RCB (Recursive Coordinate Bisection) spatial-decomposition technique with `MPI` parallelization to partition the simulation domain into subdomains of roughly equal computational cost (i.e. similar number of particles), each assigned to a processor. Processes communicate and store `ghost` data for atoms near subdomain boundaries. The code targets microscopic-scale modeling of material behavior under extreme conditions, with an emphasis on high strain rates, shock physics, and small-scale mechanics.

`exaStamp` can be built and run on a single laptop or desktop, but it is primarily designed for parallel computers. It adopts a hybrid parallelization approach combining `MPI` (Message Passing Interface) and threads (`OpenMP`) to optimize computational cost and improve efficiency. Additionally, `exaStamp` supports `MPI` + GPUs via the `Cuda` programming model integrated through the `Onika` layer, enabling GPU acceleration for substantial performance gains. Written in `C++20`, `exaStamp` provides researchers and engineers with a modern tool for `MD` simulations in physics and mechanics.

At first glance, `exaStamp` may seem difficult to modify or extend with new features—such as additional interatomic potentials, thermodynamic conditions, or on-the-fly analysis tools. However, a developer’s guide will soon be made available for those who wish to contribute.

[^exanbody]: Thierry Carrard, Raphaël Prat, Guillaume Latu, Killian Babilotte, Paul Lafourcade, Lhassan Amarsid, and Laurent Soulard. Exanbody: a hpc framework for n-body applications. In Euro-Par 2023: Parallel Processing Workshops, 342–354. Cham, 2024. Springer Nature Switzerland [doi](https://link.springer.com/chapter/10.1007/978-3-031-50684-0_27)

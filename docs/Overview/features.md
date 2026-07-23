---
icon: material/feature-search
---  

# **Main Features**

<div class="grid cards" markdown>

-   :simple-yaml:{ .lg .middle } __YAML-based input__

    ---

    The entire simulation graph — the sequence of components that make up a run — is defined in a single extended `YAML` file, with file inclusion and operator overriding to build complex, modular configurations incrementally.

    [:octicons-arrow-right-24: YAML basics](../User/B_GettingStarted/yaml_basics.md)

-   :fontawesome-solid-microchip:{ .lg .middle } __MPI x OpenMP x GPU__

    ---

    Hybrid parallelism combining MPI with OpenMP or CUDA/HIP, with RCB spatial decomposition. Built with CMake or Spack.

    [:octicons-arrow-right-24: Build & Install](../BuildInstall/index.md)

-   :simple-microeditor:{ .lg .middle } __microStamp MiniApp__

    ---

    A lightweight exaNBody-based mini-app with just the Lennard-Jones and SNAP potentials, for fast benchmarking and for developers integrating new features without building the full exaStamp code.

    [:octicons-arrow-right-24: microStamp MiniApp](../microStamp/index.md)

-   :lucide-cuboid:{ .lg .middle } __Domain & Regions__

    ---

    General triclinic simulation domains, periodic/mirror boundary conditions, and geometric regions (parallelepipeds, planes, spheres, cylinders, cones) for populating or analyzing subdomains.

    [:octicons-arrow-right-24: Domain & Regions](../User/D_DomainRegions/domain.md)

-   :lucide-atom:{ .lg .middle } __Particles Features__

    ---

    Atomic systems, rigid molecules and fully-flexible molecules, defined through the `species` YAML block (mass, atomic number, charge, molecule grouping), with setters to assign or modify per-particle field values.

    [:octicons-arrow-right-24: Particles Features](../User/F_Particles/index.md)

-   :lucide-grid-3x3:{ .lg .middle } __Grids Features__

    ---

    Grid flavors (minimal, multimat, full, mechanics, rigid molecules) control which per-particle fields — charge, virial, quaternion, molecule id, … — are tracked during the simulation, with setters to assign per-cell field values.

    [:octicons-arrow-right-24: Grids Features](../User/E_Grids/flavors.md)

-   :material-function-variant:{ .lg .middle } __Interatomic Potentials__

    ---

    - Pair potentials (Buckingham, Lennard-Jones, ZBL, tabulated, …)
    - Short- and long-range electrostatics (Coulombic, Ewald, Wolf, reaction-field)
    - Many-body potentials (EAM, MEAM) and machine-learning potentials (SNAP, N2P2, ACE)

    [:octicons-arrow-right-24: Interatomic Potentials](../User/G_ForceFields/index.md)

-   :fontawesome-solid-link:{ .lg .middle } __Bonding Potentials__

    ---

    Intramolecular energy is decomposed into bond, bending, torsion and improper torsion terms, each with its own set of functional forms.

    [:octicons-arrow-right-24: Bonding Potentials](../User/G_ForceFields/Intramolecular/index.md)

-   :fontawesome-solid-chain:{ .lg .middle } __Ensembles & Constraints__

    ---

    Thermodynamic ensembles (NVE, NVT, NPT), thermostats and barostats, and constraints for straining or restraining the simulation box. *(section under construction)*

    [:octicons-arrow-right-24: Ensembles & Constraints](../User/H_EnsemblesConstraints/index.md)

</div>


---
icon: material/image-filter-hdr
---

# **Field potentials**

Field potentials act on each atom through its position only: the energy of an atom is read from a scalar field defined over the simulation box, independently of the other atoms. They are combined with an interatomic potential, to drive or bias the atoms rather than to describe their bonding.

- [**IGAR**](igar.md): Image Guided Atomistic Reconstruction. The field is a 3D image (for instance tomography or electron microscopy data) read from a VTK file and interpolated at each atom position. Atoms are pushed towards the low values of the image.

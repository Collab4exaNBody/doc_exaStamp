---
icon: material/axis-arrow
---

# **Physical space vs Grid space**

`exaStamp` does all of its parallelization work in a **Grid space**: an integer grid of cubic cells that approximates your (possibly triclinic) **physical space** simulation box. The [`domain`](defining.md) operator defines both at once, from a physical `bounds`/`xform` and a grid `cell_size`/`grid_dims` — the two must be consistent with each other (see the warning on the [Defining the domain](defining.md) page). 

!!! tip "Full derivation of the physical space ↔ grid space transform."

    The 3D simulation box can be represented by its **3x3** frame matrix $\mathbf{H_P}$ (with the subscript $(\cdot)_P$ for physical space) built on the 3 periodicity vectors $\mathbf{a}$, $\mathbf{b}$ and $\mathbf{c}$:

    $$
    \mathbf{H_P} = \begin{pmatrix} \mathbf{a} | \mathbf{b} | \mathbf{c} \end{pmatrix} = \begin{pmatrix} a_x & b_x & c_x \\ a_y & b_y & c_y \\ a_z & b_z & c_z\end{pmatrix}
    $$

    without any constraints on the periodicity vectors $\mathbf{a}$, $\mathbf{b}$ and $\mathbf{c}$ w.r.t the orthonormal frame. From this, we assume that the $\mathbf{H_P}$ matrix can be decomposed as:

    $$
    \mathbf{H_P} = \mathbf{F_1} \cdot \mathbf{D} = \mathbf{F_1} \cdot \begin{pmatrix} || \mathbf{a} || & 0 & 0 \\ 0 & || \mathbf{b} || & 0 \\ 0 & 0 & || \mathbf{c} || \end{pmatrix}
    $$

    where $\mathbf{D}$ is a diagonal matrix with components equal to the norm of each periodicity vector and $\mathbf{F_1}$ a transformation matrix that allows to transform the general (triclinic) physical domain to a pure orthorhombic unphysical one. $\mathbf{F_1}$ can be trivially calculated as:

    $$
    \mathbf{F_1} = \mathbf{H_P} \cdot \mathbf{D}^{-1} = \mathbf{H_P} \cdot \begin{pmatrix} \frac{1}{ || \mathbf{a} || } & 0 & 0 \\ 0 & \frac{1}{|| \mathbf{b} ||} & 0 \\ 0 & 0 & \frac{1}{ || \mathbf{c} || } \end{pmatrix}
    $$

    In the Grid space, the domain needs to be defined through a diagonal matrix $\mathbf{H_G}$ (with the subscript $(\cdot)_G$ for grid space) where each diagonal component equals an integer multiple $(n_x, n_y, n_z)$ of the cell_size $c_s$:

    $$
    \mathbf{H_G} = \begin{pmatrix} n_x \cdot c_s & 0 & 0 \\ 0 & n_y \cdot c_s & 0 \\ 0 & 0 & n_z \cdot c_s \end{pmatrix}
    $$

    Finally, both physical space and grid space meet through the following equality:

    $$
    \mathbf{H_G} = \mathbf{X_f} \cdot \mathbf{H_P}
    $$

    which adds an additional constraint on the compatibility between the physical space and grid space. Indeed, for the compatibility to be satisfied, the diagonal matrix $\mathbf{D}$ is mapped to the $\mathbf{H_G}$ matrix through the following operation:

    $$
    \mathbf{D} = \mathbf{F_2} \cdot \mathbf{H_G}
    $$

    leading to:

    $$
    \mathbf{F_2} = \mathbf{D} \cdot \mathbf{H_G}^{-1} = \begin{pmatrix} \frac{||\mathbf{a}||}{n_x \cdot c_s} & 0 & 0 \\ 0 & \frac{||\mathbf{b}||}{n_y \cdot c_s} & 0 \\ 0 & 0 & \frac{||\mathbf{c}||}{n_z \cdot c_s} \end{pmatrix}
    $$

    where $(n_x,n_y,n_z)$ and $c_s$ are fixed by the user as explained hereafter. If the user requires a specific cell size $c_s$, then the number of cells and the appropriate $\mathbf{X_f}$ are automatically calculated and vice versa. The final expression of the $\mathbf{X_f}$ reads:

    $$
    \mathbf{X_f} = \mathbf{F_1} \cdot \mathbf{F_2} = \mathbf{H_P} \cdot \mathbf{D}^{-1} \cdot \mathbf{D} \cdot \mathbf{H_G}^{-1}
    $$

    which simplifies to:

    $$
    \mathbf{X_f} = \mathbf{H_P} \cdot \mathbf{H_G}^{-1} = \begin{pmatrix} \mathbf{a} | \mathbf{b} | \mathbf{c} \end{pmatrix} = \begin{pmatrix} a_x & b_x & c_x \\ a_y & b_y & c_y \\ a_z & b_z & c_z\end{pmatrix} \cdot \begin{pmatrix} n_x \cdot c_s & 0 & 0 \\ 0 & n_y \cdot c_s & 0 \\ 0 & 0 & n_z \cdot c_s \end{pmatrix}^{-1}
    $$

    which simplifies further — down to the identity matrix, for example — when the physical domain's side lengths are exact multiples of the cell size (see the [Usage examples](defining.md#usage-examples) on the Defining the domain page).

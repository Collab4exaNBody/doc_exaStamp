# Torsion potentials

A torsion type is defined by a quadruplet of atom types, a functional form and the corresponding parameters values.
The order of the atom types in the quadruplet is that of the figure.

<figure markdown="span">
  ![Image title](img/torsion.png){ width="400" }
  <figcaption>A torsion angle between atoms 1, 2, 3 and 4.  </figcaption>
</figure>

<figure markdown="span">
  ![Animation](img/torsion_anim.gif){ width="640" }
  <figcaption>Atom 4 rotates around the 2-3 axis: the torsion angle $\phi$ is the angle between the planes 1-2-3 (yellow) and 2-3-4 (green). Energy of an OPLS torsion with the parameters of the butane backbone.</figcaption>
</figure>

To express the torsion angle $\phi$, it is useful to define first the vectors $\mathbf{V}$ and $\mathbf{W}$:

$$
\mathbf{V} = \frac{\mathbf{r}_{21}\times \mathbf{r}_{23}}{\lVert \mathbf{r}_{21} \lVert \lVert \mathbf{r}_{23} \lVert}
$$

$$
\mathbf{W} = \frac{\mathbf{r}_{34}\times \mathbf{r}_{23}}{\lVert \mathbf{r}_{34} \lVert \lVert \mathbf{r}_{23} \lVert}.
$$

The torsion angle $\phi$ is then given by its cosine and sign:

$$
\cos{\phi} = \mathbf{V}\cdot\mathbf{W}
$$

$$
\text{sgn }\phi = \text{sgn} \left ( \mathbf{V}\times\mathbf{W}\cdot\mathbf{r}_{23} \right )
$$


In practice $\phi$ is computed with $\operatorname{atan2}$, which is accurate for all angles, including 0 and 180 degrees.
When atoms 1, 2, 3 or atoms 2, 3, 4 are (almost) aligned, the torsion angle is undefined and the torsion term gives no force.

The following types of torsion potentials are defined in **exastamp**:

- [**harm_torsion**](harm_torsion.md)
- [**opls_torsion**](opls_torsion.md)
- [**compass_torsion**](compass_torsion.md)
- [**0.5compass_torsion**](0.5compass_torsion.md)
- [**cos_two**](cos_two.md)
- [**no_potential**](no_potential.md)


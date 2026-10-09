# **Ziegler–Biersack–Littmark (ZBL)**

## **Description**

The `zbl_compute_force` operator computes the universal ZBL screened nuclear repulsion, which describes high-energy, short-distance collisions between atoms:

$$
E_{ij}(r) = \frac{1}{4\pi\varepsilon_0} \frac{Z_i Z_j e^2}{r} \, \phi\!\left(\frac{r}{a}\right) + S(r) \quad \text{for} \quad r<r_c
$$

with the screening function

$$
\phi(x) = 0.18175\,e^{-3.19980x} + 0.50986\,e^{-0.94229x} + 0.28022\,e^{-0.40290x} + 0.02817\,e^{-0.20162x}
$$

and the screening length (in Å)

$$
a = \frac{0.46850}{Z_i^{0.23} + Z_j^{0.23}}
$$

$S(r)$ is a switching function that brings the energy and its first and second derivatives smoothly to zero between an inner cutoff $r_1$ and the outer cutoff $r_c$. With $t = r - r_1$:

$$
S(r) =
\begin{cases}
C & r \le r_1 \\
\dfrac{A}{3}t^3 + \dfrac{B}{4}t^4 + C & r_1 < r < r_c
\end{cases}
$$

where $A$, $B$ and $C$ are computed from the value and the first two derivatives of the unscreened ZBL term at $r_c$.

The atomic numbers $Z_i$ and $Z_j$ are **not** potential parameters: they are taken from the `z` property of each species (see the `species` block).

<div class="center-table" markdown>

| Parameter | Units    | Description                                         |
| :-------- | :------: | :-------------------------------------------------- |
| `r1`      | distance | Inner cutoff, where the switching function starts   |
| `rc`      | distance | Outer cutoff, where energy and forces reach zero    |
| `rcut`    | distance | Cutoff radius of the pair potential (use `rc`)      |

</div>

## **YAML syntax**

```yaml
zbl_compute_force:
  rcut: VALUE UNITS
  parameters: { r1: VALUE UNITS , rc: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**

!!! example "**Systems with a single atomic specy**"
    ```yaml
    species:
      - Ta: { mass: 180.95 Da , z: 73 , charge: 0.0 e- }

    # Default variant
    zbl_compute_force:
      parameters: { r1: 4.0 ang , rc: 4.8 ang }
      rcut: 4.8 ang

    # Symetric variant
    zbl_compute_force_symetric:
      parameters: { r1: 4.0 ang , rc: 4.8 ang }
      rcut: 4.8 ang
    ```

!!! example "**Systems with multiple atomic species**"

    ```yaml
    species:
      - In: { mass: 114.818 Da , z: 49 , charge: 0.0 e- }
      - P:  { mass: 30.974 Da  , z: 15 , charge: 0.0 e- }

    zbl_multi_force:
      rcut: 4.2 ang
      common_parameters: { r1: 3.0 ang , rc: 4.2 ang }
      parameters:
        - { type_a: In , type_b: In , rcut: 4.2 ang , parameters: { r1: 3.0 ang , rc: 4.2 ang } }
        - { type_a: In , type_b: P  , rcut: 4.2 ang , parameters: { r1: 3.0 ang , rc: 4.2 ang } }
        - { type_a: P  , type_b: P  , rcut: 4.2 ang , parameters: { r1: 3.0 ang , rc: 4.2 ang } }
    ```

!!! tip

    ZBL is typically added to a machine-learning potential (for example [SNAP](../../MLIP/snap.md)) to handle very short interatomic distances. List both operators in `compute_force`.

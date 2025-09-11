
# **Example 2: from a square to a bubble**


### __Files__ 

- Comprehensive test file: [main.cpp](https://github.com/Collab4Sloth/SLOTH/tree/master/tests/CahnHilliard/2D/test3/main.cpp)
- Reference results for comparison: [time_specialized.csv](https://github.com/Collab4Sloth/SLOTH/tree/master/tests/CahnHilliard/2D/test3/ref/time_specialized.csv)


### __Statement of the problem__ 
This test corresponds to a 2D simulation of a square evolving to a bubble. 

The domain $`\Omega`$ is a square $`[0,2\pi]\times[0,2\pi]`$

```math

\begin{align}
\frac{\partial \phi}{\partial t}&= \Delta \mu \text{ in }\Omega 
\\[6pt]    
\mu &= F'(\phi) - \lambda\Delta \phi \text{ in }\Omega 
\end{align}

```

where $`\phi`$ is the phase indicator, $`\mu`$ the generalized chemical potential and $`F'`$ the derivative against $`\phi`$ of the potential $`F`$ defined by:

```math

\begin{align} 
F(\phi)&=\frac{\phi^4}{4} - \frac{\phi^2}{2}
\end{align}

```

### __Initial condition__

The initial condition consists of square:

```math

    \phi =
    \begin{cases}
    
    1, & \text{if } (x - \pi + 1) \leq 1 \;\; \text{or} \;\;  (y - \pi) \leq 1 
    \\
    -1, & \text{otherwise}

    \end{cases}

```

<figure markdown="span">
    ![SquareBubble](img/square_ic.jpg){  width=400px}
    <figcaption>Figure 1 : square bubble at initial state
    </figcaption>
</figure>

### **Parameters used for the test**
    
For this test, all parameters are equal to one except the energy gradient coefficient. 

| Name              | Description                        | Symbol       | Value                         |
| -----   | ---------------------------------- | ------------ | ----------------------------- |
| `mob` | mobility coefficient               | $`M_\phi`$   | $`1.0`$                     |
    | `lambda` | energy gradient coefficient        | $`\lambda`$  | $`4.10^{-4}`$ |
    | `omega` | depth of the double-well potential | $`\omega`$   | $`1.0`$     |

### __Boundary conditions__

Neumann boundary conditions are prescribed on the boundary of the domain:

```math

\begin{align} 
{\bf{n}} \cdot{} \lambda \nabla \phi&=0 \text{ on }\partial\Omega

\\[6pt]

{\bf{n}} \cdot{} \lambda \nabla \mu&=0 \text{ on }\partial\Omega
\end{align}
```

### __Numerical scheme__

- Time integration: Euler Implicit over the interval $`t\in[0,1]`$ (it could be extended further) with a time-step $`\delta t=0.1`$
- Spatial discretization: uniform grid with $`N=128`$ nodes in each spatial direction
- Newton solver: relative tolerance $`10^{-8}`$, absolute tolerance $`10^{-14}`$
- Iterative solver: HYPRE_GMRES 
- Preconditioner: HYPRE_ILU


### __Results__ 

The average value of $`\phi`$ is an available ouput of the simulation (see the file `time_specialized.csv`). It is defined by:

```math

\dfrac{1}{|\Omega|}\displaystyle\int_{\Omega} \phi dv 

```

For this test, the computed average value should remain constant over time.

The figure 2 shows the evolution of a square to a bubble, with a final simulation time set to $`10`$.

<figure markdown="span">
    ![SquareBubble](img/square_1.gif){  width=400px}
    <figcaption>Figure 2 : evolution of a square to a bubble
    </figcaption>
</figure>


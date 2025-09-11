
# **Example 1: nonlinear diffusion in a star**

### __Files__ 

- Comprehensive test files: 
    - explicit diffusion coefficient : [main.cpp](https://github.com/Collab4Sloth/SLOTH/tree/master/tests/Diffusion/2D/test1/main.cpp)
    - implicit diffusion coefficient : [main.cpp](https://github.com/Collab4Sloth/SLOTH/tree/master/tests/Diffusion/2D/test2/main.cpp)

- Reference results for comparison: 
    - explicit diffusion coefficient :[time_specialized.csv](https://github.com/Collab4Sloth/SLOTH/tree/master/tests/Diffusion/2D/test1/ref/time_specialized.csv)
    - implicit diffusion coefficient :[time_specialized.csv](https://github.com/Collab4Sloth/SLOTH/tree/master/tests/Diffusion/2D/test1/ref/time_specialized.csv)


### __Statement of the problem__ 

This example code is based on the ["Example 16: Time Dependent Heat Conduction",  on MFEM's website](https://mfem.org/examples/). It solves a diffusion equation in a 2D star $`\Omega`$ (GMSH mesh coming from MFEM examples).

```math

\begin{align}
\frac{\partial c}{\partial t}&=[\nabla \cdot{} \displaystyle(\kappa+\alpha c) \nabla c ]\text{ in }\Omega
\end{align}

```
where the concentration $`c`$ in the diffusion coefficient can be evaluated at the previous time step, as done in the MFEM example, or at the current time step to form a fully nonlinear system.

### __Initial condition__

The initial condition is set to $`2`$ inside a circle of radius $`0.5`$, $`1`$ outside.

### **Parameters used for the test**
    
For this test, the following parameters are considered:

| Parameter                          | Symbol     | Value                       |
| ---------------------------------- | ---------- | --------------------------- |
| Primary coefficient                | $`\kappa`$   | $`0.5`$                       |
| Secondary coefficient              | $`\alpha`$   | $`10^{-2}`$                     |

### __Boundary conditions__

Neumann boundary conditions are prescribed on the boundary of the domain:

```math

\begin{align} 
{\bf{n}} \cdot{} \lambda \nabla c&=0 \text{ on }\partial\Omega
\end{align}
```

### __Numerical scheme__

- Time integration: Euler Implicit over the interval $`t\in[0,0.5]`$, $`\delta t=0.01`$
- Spatial discretization: built from GMSH + quadratic FE + $`2`$ uniform levels of refinement (it could be extended further)

### __Results__ 

The figure 1 shows the nonlinear diffusion inside the star.

<figure markdown="span">
    ![NonLinearStarDiffusion](img/NonLinearStarDiffusion.gif){width=800px}
    <figcaption>Figure 1: nonlinear diffusion in a star obtained with $`5`$ level of refinement.
    </figcaption>
</figure>

---
icon: material/graph
---

# **Simulation's graph**

``` mermaid
graph TD
  A["`**Initialization**
  Detect GPU Support
  Create Grid
  Preinit cutoff radius`"]
  
  B[Creating Particle Regions]
  
  C["`**Input Data**
  lattice, xyz, MpiIO
  + field initialization`"]

  D["`**Firs Timestep**
  Init partcles
  - move
  - migration
  - neighbor lists
  - compute forces`"]

  E[Time Loop];
  F[test];
  G[coucou];
  
  A --> B;
  B --> C;
  C --> D;
  D --> E;
  E --> F;
  F --> G
  G--->|"`t inf tfin`"| D;
  
  
```


  B -->|Yes| C[Hmm...];
  C --> D[Debug];
  D --> B;
  B ---->|No| E[Yay!];
  E ===> newLines["`Line1
                    Line 2
                    Line 3`"]  
  
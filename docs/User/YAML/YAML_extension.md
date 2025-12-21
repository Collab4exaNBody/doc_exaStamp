## **YAML extension**
  
In the original **YAML** format, the entire document must be contained in a single file, which can make complex documents heavy. **exaNBody** uses **YAML** in a somewhat special way by adding the notions of **inclusion** and **overriding** to make the construction of complex structures more incremental.

In all **exaNBody** applications, the first level element in the **YAML** input file is a **dictionary** that contains two categories of keys:

- Reserved keywords
- Free entreies defining default values of a component or an aggregate

Reserved keywords are: **configuration**, **includes** and **simulation**.

- **configuration** is a key associated to a dictionary whose keys correspond to execution options for an **exaNBody**-based application,
- **includes** allows to merge the current document with additional documents contained in external files,
- **simulation** key contains the actual course of the simulation, that is, the sequence of components or aggregates of components that make up the simulation as a whole.

!!! note "Predefined aggregates, default values, simulation structure or pre-assembled numerical scheme, etc."
  
    ```yaml
    includes:
      - base.cfg
      - model.cfg
    ```

!!! note "Application execution context configuration: debugging, parallelism, profiling, etc."
    
    ```yaml
    configuration:
      logging:
        debug: true
      profiling:
        summary: true
    ```
  
!!! note "Simulation sequence, chaining of components or macro-components, etc."
  
    ```yaml
    simulation:
      - read_data:
          file: input.xyz
      - init_neighbors
      - compute_force
      - integration_step
      - write_data:
          file: output.xyz    
    ```

<hr style="height:4px;border:none;background: rgb(180, 180, 180) ;margin:50px 0;">

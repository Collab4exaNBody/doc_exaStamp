# **YAML basics**

## **Generalities about YAML**
    
**YAML** is a human-readable data serialization often used for writing configuration files and in applications where data is being stored or transmitted by/between operators. Recursive definition of `YAML` document is pretty simple and a `YAML` document usually contains three types of elements:

- **A scalar**: text, number, boolean
- **A list**: an ensemble of ordered elements
- **A dictionary**: an ensemble, ordered or not, of tuples each with a key and an associated value

For more information, please visit the following links:

- [**YAML Tutorials**](https://gettaurus.org/docs/YAMLTutorial/)
  
- [**YAML Online Parser**](http://yaml-online-parser.appspot.com/)
  
- [**YAML Wiki**](https://en.wikipedia.org/wiki/YAML/)


Below are some examples of scalar, list or dictionary definitions in `YAML` format.
      
```yaml
# Scalar definition examples
val: "text only"
val: 3.5
val: true

# List definition examples
list: ["list", "with", 5, true, "elements"]
list:
  - "list"
  - "with"
  - 5
  - true
  - elements

# Dictionary definition examples
dict: {A: "value", B: 3, C: false}
dict:
  - A: "value"
  - B: 3
  - C: false
```

In addition, you can combine multiple types (scalar, list, dictionary):

```yaml
# Multiple types combination in a list
dictA:   
  key1: { A: "value", B: 3 }
  key2: [ "aaa", "bbb" ]
  key3: 4.67
  key4:
    A: [ 5, 6 ]
    B: { X: 1, Y: 2 }

# Alternative format  
dictA: { key1: { A: "value", B: 3 }, key2: [ "aaa", "bbb" ], key3: 4.67, key4: { A: [ 5, 6 ], B: { X: 1, Y: 2 } } }
  
```

Here, `key1` is bind to a value of type dictionary, `key2` is bind to a value of type list, `key3` is bind to a value of type scalar, key3 is bind to a value of type dictionary.

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

## **Definition of components or aggregates**

Non-reserved keys can be used either to define default values for an existing component (available by default in the application), or to create a “batch” component — that is, an aggregate that groups together (and chains) several components (whether pre-existing or other batches defined elsewhere). There is no specific rule for declaring a batch: if a key is defined at the top level that is not recognized as a base component, the system assumes it is the definition of an aggregate (batch).

For example, the following `write_paraview` operator is a known component. If it is later referenced without a re-specification of its parameters in the worfklow, `file` will be set and used as `output.vtk`.
    
```yaml
write_paraview: { file: "output.vtk" }  
```

Below, `compute_force` is not a known component. It therefore corresponds to the declaration of an aggregate component, or batch. It can then be used as any other component.
    
```yaml
compute_force:
  - lennard_jones_force
  - boundary_wall_force
```

Additionally, we can define `compute_force` using an alternative syntax. It allows additional parameters:

- `name`: name in listing
- `rebind`: outside change of connectors name
- `condition`: aggregate is executed if and only if the boolean operator is `true`
- `loop`: if set to true, the component is executed while `condition=true`.

With the alternative syntax, aggregate components are listed under the `body` key.
      
```yaml
compute_force:
  name: forces_computation
  rebind: { grid: other_grid, ... }
  condition active_computation
  loop: true
  body:
    - lennard_jones_force
    - boundary_wall_force  
```

Below, `read_data` is a component used while specifying one of its parameters. If it had been previously defined, the previous definition would be ignored. The `compute_force` however was previously defined as a batch (e.g. aggregate), which can be used as a base component. The first instance of `write_paraview` is used without parameters, meaning its `file` parameter is set as `output.vtk`. Eventually, `write_paraview` is re-used `file` set to `output_renamed.vtk` so the previous definition is overriden.
  
```yaml
simulation:
  - read_data:
      file: "input.xyz"
  - init_neighbors
  - compute_force
  - integration_step
  - write_paraview
  - write_paraview:
      file : "output_named.vtk"
```

## Combining YAML files

As discussed before, it is possible to include files using the `includes` key. The included files are merged with - and overriden by - the file that includes them, ultimately forming a single YAML document.

Each time an **exaStamp** input file **includes** another (for example, **base.yaml**), the included file is first loaded to form a YAML document. Then, the including file is also loaded to form a second YAML document. The two documents are then merged using the algorithm that specifically designed for **exaNbody** and **exaStamp**.

!!! note "file_A.yaml"

    ```yaml
    configuration:
      debug: false
      profiling: true
    ```

!!! note "file_B.yaml"

    ```yaml
    includes:
      - file_A.yaml

    configuration:
      debug: true

    compute_force:
      - lennard_jones
      - langevin_thermostat
    ```

!!! note "file_C.yaml"

    ```yaml
    includes:
      - file_B.yaml

    +compute_force:
      - repulsive_wall
    ```
Usage example of files inclusion and operators overload:

- From basic definitions in **file_A.yaml**, **file_B.yaml** overleads `debug` in `configuration` and adds the aggregate component `compute_force`.
- From **file_B.yaml**, **file_C.yaml** adds at the end of `compute_force` the component `repulsive_wall`.
- This enables the construction of the final document **final.yaml** defined below:

!!! note "final.yaml"

    ```yaml
    configuration:
      debug: true
      profiling: true

    compute_force:
      - lennard_jones
      - langevin_thermostat
      - repulsive_wall
    ```

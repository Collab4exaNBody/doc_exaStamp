---
icon: lucide/blocks
---

# YAML extensions

This page assumes familiarity with plain `YAML` (see [YAML basics](yaml_basics.md)) and describes the extensions that `exaStamp` and the underlying `onika`/`exaNBody` platform add on top of it: reserved top-level keys, component/aggregate declarations, and how included files are merged together.

## **Reserved top-level keys**

In the original **YAML** format, the entire document must be contained in a single file, which can make complex documents heavy. We use **YAML** in a somewhat special way by adding the notions of **inclusion** and **overriding** to make the construction of complex structures more incremental. In all **exaNBody** applications, the first level element in the **YAML** input file is a **dictionary** that contains two categories of keys:

- Reserved keywords: **configuration**, **includes** and **simulation**
- Free entries defining default values of a component or an aggregate

### `configuration`

**configuration** is a key associated to a dictionary whose keys correspond to execution, logging and debugging options for an **exaNBody**-based application:

```yaml linenums="1"
configuration:
  logging:
    debug: true
  profiling:
    summary: true
```

### `includes`

**includes** allows to merge the current document with additional documents contained in external files:

```yaml linenums="1"
includes:
  - base.msp
  - model.msp
```

See [Files combination](#files-combination) below for how included files are actually merged into the current document.

### `simulation`

**simulation** key contains the actual course of the simulation, that is, the sequence of components or aggregates of components that make up the simulation as a whole. See a short example below:

```yaml linenums="1"
simulation:
  - read_data:
      file: input.xyz
  - init_neighbors
  - compute_force
  - integration_step
  - write_data:
      file: "output.xyz"    
```

This bare-list form is the simple syntax for any aggregate, introduced below in [Defining and reusing components](#defining-and-reusing-components). In practice, `exaStamp`'s own `simulation` block is declared with the extended `name`/`body` syntax (see [Building blocks](building_blocks.md)), but both forms are valid.

## **Components and aggregates**

Non-reserved keys can be used either to define default values for an existing component (available by default in the application), or to create a "batch" component — that is, an aggregate that groups together (and chains) several components (whether pre-existing or other batches defined elsewhere). There is no specific rule for declaring a batch: if a key is defined at the top level that is not recognized as a base component, the system assumes it is the definition of an aggregate (batch).

### Defining and reusing components

For example, the following `write_paraview` operator is a known component. If it is later referenced without a re-specification of its parameters in the workflow, `file` will be set and used as `output.vtk`.

```yaml linenums="1"
write_paraview: { file: "output.vtk" }  
```

Below, `compute_force` is not a known component. It therefore corresponds to the declaration of an aggregate component, or batch. It can then be used as any other component.

```yaml linenums="1"
compute_force:
  - lennard_jones_force
  - boundary_wall_force
```

### Extended aggregate syntax

Additionally, we can define `compute_force` using an alternative syntax. It allows additional parameters:

- `name`: name in listing
- `rebind`: outside change of connectors name
- `condition`: aggregate is executed if and only if the boolean operator is `true`
- `loop`: if set to true, the component is executed while `condition=true`.

With the alternative syntax, aggregate components are listed under the `body` key.

```yaml linenums="1"
compute_force:
  name: forces_computation
  rebind: { grid: other_grid, ... }
  condition: active_computation
  loop: true
  body:
    - lennard_jones_force
    - boundary_wall_force  
```

### Overriding previous definitions

Below, `read_data` is a component used while specifying one of its parameters. If it had been previously defined, the previous definition would be ignored. The `compute_force` however was previously defined as a batch (e.g. aggregate), which can be used as a base component. The first instance of `write_paraview` is used without parameters, meaning its `file` parameter is set as `output.vtk`. Eventually, `write_paraview` is re-used with `file` set to `output_named.vtk` so the previous definition is overridden.

```yaml linenums="1"
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

## **Files combination**

As discussed above, it is possible to include files using the `includes` key. The included files are merged with - and overridden by - the file that includes them, ultimately forming a single YAML document.

Each time an **exaStamp** input file **includes** another (for example, **base.msp**), the included file is first loaded to form a YAML document. Then, the including file is also loaded to form a second YAML document. The two documents are then merged using an algorithm that is specifically designed for **exaNBody** and **exaStamp**.

```yaml linenums="1" title="file_A.msp"
configuration:
  debug: false
  profiling: true
```

```yaml linenums="1" title="file_B.msp"
includes:
  - file_A.msp

configuration:
  debug: true
  
compute_force:
  - lennard_jones
  - langevin_thermostat
```

```yaml linenums="1" title="file_C.msp"
includes:
  - file_B.msp
  
+compute_force:
  - repulsive_wall
```

Usage example of files inclusion and operator overriding:

- From basic definitions in **file_A.msp**, **file_B.msp** overrides `debug` in `configuration` and adds the aggregate component `compute_force`.
- From **file_B.msp**, **file_C.msp** adds at the end of `compute_force` the component `repulsive_wall`.
- This enables the construction of the final document **final.msp** defined below:

```yaml linenums="1" title="final.msp"
configuration:
  debug: true
  profiling: true

compute_force:
  - lennard_jones
  - langevin_thermostat
  - repulsive_wall
```

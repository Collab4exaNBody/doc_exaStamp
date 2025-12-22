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

<hr style="height:4px;border:none;background: rgb(180, 180, 180) ;margin:50px 0;">
